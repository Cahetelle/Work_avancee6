import 'package:flutter/material.dart';
import '../services/database_manager.dart';
import '../services/notification_service.dart';
import 'theme.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      //  1. Initialiser la base locale
      await DBHelper.initDB();

      //  2. Vérifier l’existence de l’utilisateur
      final userExists = await DBHelper.getUserByUsername(usernameCtrl.text.trim());
      if (userExists == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Nom d'utilisateur introuvable.",
              style: AppTextStyles.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      //  3. Mettre à jour le mot de passe (Firebase + SQLite)
      await DBHelper.updatePassword(usernameCtrl.text.trim(), newPassCtrl.text);

      //  4. Notification de succès
      await NotificationService.instance.show(
        "Mot de passe réinitialisé",
        "Vous pouvez maintenant vous connecter.",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Mot de passe mis à jour avec succès.",
              style: AppTextStyles.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // retour à la page précédente
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
            style: AppTextStyles.body(context).copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }


  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.body(context),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body(context),
          prefixIcon: Icon(icon, color: AppColors.primary), // 🔹 couleur forcée
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Réinitialiser le mot de passe", style: AppTextStyles.appBarTitle(context)),
        centerTitle: true,
        foregroundColor: theme.appBarTheme.foregroundColor,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Réinitialisation", style: AppTextStyles.subtitle(context)),
                  const SizedBox(height: 24),

                  // Nom d’utilisateur
                  _buildField(
                    controller: usernameCtrl,
                    label: "Nom d'utilisateur",
                    icon: Icons.person,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Obligatoire" : null,
                  ),
                  const SizedBox(height: 16),

                  // Nouveau mot de passe
                  _buildField(
                    controller: newPassCtrl,
                    label: "Nouveau mot de passe",
                    icon: Icons.lock,
                    obscure: _obscure,
                    validator: (v) => (v == null || v.length < 4) ? "Min. 4 caractères" : null,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary, // 🔹 couleur forcée
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirmation mot de passe
                  _buildField(
                    controller: confirmPassCtrl,
                    label: "Confirmer le mot de passe",
                    icon: Icons.lock,
                    obscure: _obscure,
                    validator: (v) => (v != newPassCtrl.text) ? "Mot de passe différent" : null,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary, // 🔹 couleur forcée
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _loading ? null : _resetPassword,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("Réinitialiser", style: AppTextStyles.button(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
