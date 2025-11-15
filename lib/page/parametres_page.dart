import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_manager.dart';
import '../models/utilisateur.dart';
import '../widgets/drawer_menu.dart';
import 'reset_password_page.dart';
import 'theme.dart';
import '../main.dart'; // pour accéder à ThemeProvider

class ParametresPage extends StatefulWidget {
  final Utilisateur user;
  const ParametresPage({super.key, required this.user});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  Future<void> _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Suppression des mesures"),
        content: const Text(
          "Voulez-vous vraiment supprimer toutes les mesures enregistrées ? "
          "Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text("Supprimer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteAllMesures();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Toutes les mesures ont été supprimées."),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: DrawerMenu(user: widget.user),
      appBar: AppBar(
        title: Text("Paramètres", style: AppTextStyles.appBarTitle(context)),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- Switch Mode sombre ---
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text("Mode sombre", style: AppTextStyles.body(context)),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.isDark,
              onChanged: (v) => themeProvider.toggleTheme(v),
            ),
          ),

          const SizedBox(height: 8),

          // --- Modifier le mot de passe ---
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.lock_reset, color: AppColors.primary),
              title: Text("Modifier le mot de passe", style: AppTextStyles.body(context)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // --- Supprimer toutes les mesures ---
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: Text(
                "Supprimer toutes les mesures",
                style: AppTextStyles.body(context).copyWith(color: Colors.redAccent),
              ),
              onTap: _deleteAllData,
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              "HOUEFASENSE © 2025",
              style: AppTextStyles.body(context).copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
