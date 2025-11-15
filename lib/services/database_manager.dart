import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/mesure.dart';
import '../models/utilisateur.dart';

class DBHelper {
  //  Firestore
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  Noms de collections uniformes (mêmes que sur Firestore)
  static final CollectionReference _users = _firestore.collection('users');
  static final CollectionReference _mesures = _firestore.collection('mesures');

  //  SQLite
  static Database? _db;

  /// Initialisation de la base SQLite locale
  static Future<void> initDB() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, "houefasense.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE utilisateurs (
            id TEXT PRIMARY KEY,
            username TEXT,
            password TEXT,
            email TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE mesures (
            id TEXT PRIMARY KEY,
            userId TEXT,
            lieu TEXT,
            date TEXT,
            ph REAL,
            temperature REAL,
            turbidite REAL,
            conductivite REAL,
            tds REAL,
            latitude REAL,
            longitude REAL,
            photoUrl TEXT,
            interpretation TEXT
          )
        ''');
      },
    );
  }

  ///////////////////////////////
  //  UTILISATEURS
  ///////////////////////////////

  /// Crée un utilisateur dans Firestore et localement
  static Future<void> createUser(Utilisateur user) async {
    final doc = _users.doc(); // crée un nouvel ID Firestore
    user.id = doc.id;

    await doc.set(user.toMap());
    await _db?.insert(
      'utilisateurs',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("✅ Utilisateur créé : ${user.username}");
  }

  /// Récupère un utilisateur par nom (depuis Firestore ou local)
  static Future<Utilisateur?> getUserByUsername(String username) async {
    print("🔍 Recherche utilisateur Firestore : $username");

    try {
      final result = await _users.where('username', isEqualTo: username).get();
      if (result.docs.isNotEmpty) {
        print("✅ Utilisateur trouvé sur Firestore");
        return Utilisateur.fromMap(result.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("⚠️ Erreur Firestore : $e");
    }

    // Recherche locale (si hors ligne)
    final local = await _db?.query(
      'utilisateurs',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (local != null && local.isNotEmpty) {
      print("✅ Utilisateur trouvé localement");
      return Utilisateur.fromMap(local.first);
    }

    print("❌ Aucun utilisateur trouvé");
    return null;
  }

  /// Authentifie un utilisateur (nom + mot de passe)
  static Future<Utilisateur?> auth(String username, String password) async {
    final user = await getUserByUsername(username);

    if (user != null && user.password == password) {
      print("🔐 Authentification réussie pour $username");
      return user;
    } else {
      print("❌ Authentification échouée pour $username");
    }
    return null;
  }

  /// Met à jour le mot de passe (local + Firestore)
  static Future<void> updatePassword(String username, String newPassword) async {
    try {
      final query = await _users.where('username', isEqualTo: username).get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'password': newPassword});
        print("✅ Mot de passe Firestore mis à jour pour $username");
      }

      await _db?.update(
        'utilisateurs',
        {'password': newPassword},
        where: 'username = ?',
        whereArgs: [username],
      );
      print("✅ Mot de passe SQLite mis à jour pour $username");
    } catch (e) {
      print("⚠️ Erreur lors de la mise à jour du mot de passe : $e");
    }
  }

  ///////////////////////////////
  //  MESURES
  // /////////////////////////////

  /// Sauvegarde une mesure dans Firestore
  static Future<void> saveMesure(Mesure m) async {
    await _mesures.doc(m.id).set(m.toMap());
    print("✅ Mesure enregistrée dans Firestore : ${m.id}");
  }

  /// Sauvegarde une mesure localement dans SQLite
  static Future<void> saveMesureLocal(Mesure m) async {
    await _db?.insert(
      'mesures',
      m.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("💾 Mesure enregistrée localement : ${m.id}");
  }

  /// Récupère toutes les mesures locales
  static Future<List<Mesure>> getAllMesures() async {
    final result = await _db?.query('mesures', orderBy: 'date DESC');
    if (result == null || result.isEmpty) {
      print("📭 Aucune mesure locale trouvée");
      return [];
    }
    print("📊 ${result.length} mesures récupérées localement");
    return result.map((e) => Mesure.fromMap(e)).toList();
  }

  /// Supprime une mesure (local + Firestore)
  static Future<void> deleteMesure(String id) async {
    await _db?.delete('mesures', where: 'id = ?', whereArgs: [id]);
    await _mesures.doc(id).delete();
    print("🗑️ Mesure supprimée : $id");
  }

  /// Supprime toutes les mesures
  static Future<void> deleteAllMesures() async {
    await _db?.delete('mesures');

    final batch = _firestore.batch();
    final allDocs = await _mesures.get();
    for (var d in allDocs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();

    print("🧹 Toutes les mesures supprimées");
  }

  /// Synchronisation optionnelle : importer les données Firestore en local
  static Future<void> syncFromCloud() async {
    final cloud = await _mesures.get();
    for (var doc in cloud.docs) {
      final m = Mesure.fromMap(doc.data() as Map<String, dynamic>);
      await saveMesureLocal(m);
    }
    print("🔄 Synchronisation depuis Firestore terminée");
  }


    // --- 🔹 Récupérer la dernière mesure locale enregistrée ---
  static Future<Mesure?> getDerniereMesureLocale() async {
    final result = await _db?.query(
      'mesures',
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result != null && result.isNotEmpty) {
      return Mesure.fromMap(result.first);
    }
    return null;
  }

  static Future<void> deleteMesureFirebase(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('mesures')
          .doc(id)
          .delete();
    } catch (e) {
      print("Erreur suppression Firebase : $e");
    }
  }

}

