import 'package:uuid/uuid.dart';

class Mesure {
  String id;
  String userId;
  String lieu;
  DateTime date;
  double ph;
  double temperature;
  double turbidite;
  double conductivite;
  double tds;
  double? latitude;
  double? longitude;
  String? photoUrl;
  String interpretation;

  Mesure({
    String? id,
    required this.userId,
    required this.lieu,
    required this.date,
    required this.ph,
    required this.temperature,
    required this.turbidite,
    required this.conductivite,
    required this.tds,
    this.latitude,
    this.longitude,
    this.photoUrl,
    required this.interpretation,
  }) : id = id ?? const Uuid().v4();

  //  Conversion d’un objet Mesure → Map (pour Firestore et SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lieu': lieu,
      'date': date.toIso8601String(),
      'ph': ph,
      'temperature': temperature,
      'turbidite': turbidite,
      'conductivite': conductivite,
      'tds': tds,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'interpretation': interpretation,
    };
  }

  //  Conversion d’une Map → Objet Mesure
  factory Mesure.fromMap(Map<String, dynamic> map) {
    return Mesure(
      id: map['id'] ?? const Uuid().v4(),
      userId: map['userId'] ?? '',
      lieu: map['lieu'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      ph: (map['ph'] ?? 0).toDouble(),
      temperature: (map['temperature'] ?? 0).toDouble(),
      turbidite: (map['turbidite'] ?? 0).toDouble(),
      conductivite: (map['conductivite'] ?? 0).toDouble(),
      tds: (map['tds'] ?? 0).toDouble(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      photoUrl: map['photoUrl'],
      interpretation: map['interpretation'] ?? '',
    );
  }

  // Calcul automatique du TDS (Total Dissolved Solids)
  static double calculerTDS(double conductivite) {
    return conductivite * 0.64; // formule empirique standard
  }

  // Génère une interprétation qualitative (OMS simplifiée)
  static String interpreter(double ph, double temperature, double turbidite, double conductivite) {
    String result = "";

    if (ph < 6.5 || ph > 8.5) {
      result += "⚠️ pH hors norme (6.5 - 8.5). ";
    }
    if (temperature > 30) {
      result += "⚠️ Température élevée (>30°C). ";
    }
    if (turbidite > 5) {
      result += "⚠️ Eau trouble (>5 NTU). ";
    }
    if (conductivite > 2500) {
      result += "⚠️ Conductivité élevée (>2500 µS/cm). ";
    }

    if (result.isEmpty) {
      result = "✅ Eau de bonne qualité selon les seuils OMS.";
    }

    return result.trim();
  }

  // Pour affichage lisible
  @override
  String toString() {
    return 'Mesure($lieu, pH=$ph, T=${temperature}°C, Turbidité=$turbidite NTU, Cond=$conductivite µS/cm)';
  }
}
