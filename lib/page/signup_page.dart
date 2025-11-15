import 'package:flutter/material.dart';
import '../services/database_manager.dart';
import '../services/notification_service.dart';
import '../models/utilisateur.dart';
import 'theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => _loading = true);

    try {
      final exists = await DBHelper.getUserByUsername(usernameCtrl.text.trim());

      if (exists != null) {
        if (mounted) setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ce nom d'utilisateur est déjà pris.",
              style: AppTextStyles.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      await DBHelper.createUser(Utilisateur(
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      ));

      await NotificationService.instance
          .show("Inscription réussie", "Bienvenue !");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Compte créé avec succès.",
              style: AppTextStyles.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur: $e",
              style: AppTextStyles.body(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Champ de saisie stylisé avec ombres
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body(context),
          prefixIcon: Icon(icon, color: AppColors.primary), //  couleur forcée
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Inscription", style: AppTextStyles.appBarTitle(context)),
        centerTitle: true,
        foregroundColor: theme.appBarTheme.foregroundColor,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo avec ombre
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: theme.cardColor,
                      child: Icon(
                        Icons.water_drop,
                        size: 60,
                        color: AppColors.primary, //  couleur forcée
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Formulaire
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: usernameCtrl,
                        label: "Nom d'utilisateur",
                        icon: Icons.person,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Obligatoire"
                            : null,
                      ),
                      _buildTextField(
                        controller: passwordCtrl,
                        label: "Mot de passe",
                        icon: Icons.lock,
                        obscure: _obscure,
                        validator: (v) =>
                            (v == null || v.length < 4)
                                ? "Min. 4 caractères"
                                : null,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primary, //  couleur forcée
                          ),
                        ),
                      ),
                      _buildTextField(
                        controller: confirmCtrl,
                        label: "Confirmer le mot de passe",
                        icon: Icons.lock,
                        obscure: _obscure,
                        validator: (v) => (v != passwordCtrl.text)
                            ? "Mot de passe différent"
                            : null,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primary, //  couleur forcée
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bouton
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            shadowColor:
                                theme.colorScheme.primary.withOpacity(0.4),
                          ),
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text("Créer le compte",
                                  style: AppTextStyles.button(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}
