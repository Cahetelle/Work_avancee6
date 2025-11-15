import 'package:flutter/material.dart';
import '../page/saisie_page.dart';
import '../page/historique_page.dart';
import '../page/parametres_page.dart';
import '../page/about_page.dart';
import '../page/resultats_page.dart';
import '../models/utilisateur.dart';
import '../services/database_manager.dart';
import '../page/theme.dart';

class DrawerMenu extends StatelessWidget {
  final Utilisateur user;
  const DrawerMenu({super.key, required this.user});

  //  Ouvre la dernière mesure enregistrée ---
  Future<void> _openLastResult(BuildContext context) async {
    try {
      final data = await DBHelper.getAllMesures();
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune mesure disponible")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultatsPage(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement : $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          //  En-tête utilisateur 
          UserAccountsDrawerHeader(
            accountName: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),

          //  Navigation principale
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Nouvelle mesure'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SaisiePage(currentUser: user),
                ),
              );
            },
          ),

          
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Dernier résultat'),
            onTap: () {
              Navigator.pop(context);
              _openLastResult(context);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoriquePage(user: user),
                ),
              );
            },
          ),


          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParametresPage(user: user),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutPage(user: user),
                ),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Déconnexion'),
            onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
    );
  }
}
