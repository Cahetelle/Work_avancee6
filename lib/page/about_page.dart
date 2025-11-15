import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/utilisateur.dart';
import '../widgets/drawer_menu.dart';
import 'theme.dart';

class AboutPage extends StatelessWidget {
  final Utilisateur user; //  pour afficher les infos du Drawer
  const AboutPage({super.key, required this.user});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Impossible d'ouvrir $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ✅ Ajout du Drawer
      drawer: DrawerMenu(user: user),

      appBar: AppBar(
        title: Text("À propos", style: AppTextStyles.appBarTitle(context)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        foregroundColor: theme.appBarTheme.foregroundColor,
        automaticallyImplyLeading: true, //  affiche le menu hamburger
      ),

      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Titre principal ---
              Row(
                children: [
                  Icon(Icons.water, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "HouefaSense",
                      style: AppTextStyles.title(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "HouefaSense est une application innovante qui accompagne un dispositif "
                "de mesure des paramètres physico-chimiques de l'eau. Elle permet de suivre "
                "la qualité de l'eau en temps réel grâce à des capteurs dédiés.",
                textAlign: TextAlign.justify,
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 20),

              // --- Paramètres mesurés ---
              ExpansionTile(
                leading: Icon(Icons.science, color: AppColors.primary),
                title: Text("Paramètres mesurés", style: AppTextStyles.subtitle(context)),
                backgroundColor: theme.cardColor,
                collapsedBackgroundColor: theme.cardColor,
                children: [
                  ListTile(
                    leading: Icon(Icons.opacity, color: AppColors.primary),
                    title: Text(
                      "pH – mesure de l'acidité ou de la basicité de l'eau.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.thermostat, color: AppColors.primary),
                    title: Text(
                      "Température – suivi thermique pour la gestion et la sécurité.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.blur_on, color: AppColors.primary),
                    title: Text(
                      "Turbidité – contrôle de la clarté de l'eau.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.electrical_services, color: AppColors.primary),
                    title: Text(
                      "Conductivité électrique – indicateur de la concentration en ions dissous.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.auto_fix_high, color: AppColors.primary),
                    title: Text(
                      "TDS (Total Dissolved Solids) – calcul automatique à partir de la CE.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Fonctionnalités principales ---
              ExpansionTile(
                leading: Icon(Icons.dashboard_customize, color: AppColors.primary),
                title: Text("Fonctionnalités principales", style: AppTextStyles.subtitle(context)),
                backgroundColor: theme.cardColor,
                collapsedBackgroundColor: theme.cardColor,
                children: [
                  ListTile(
                    leading: Icon(Icons.update, color: AppColors.primary),
                    title: Text(
                      "Collecte en temps réel : données actualisées automatiquement.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.lightbulb, color: AppColors.primary),
                    title: Text(
                      "Interprétation intelligente : explications claires pour chaque mesure.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.download, color: AppColors.primary),
                    title: Text(
                      "Export et analyse : possibilité de télécharger l'historique complet.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Développeur ---
              ExpansionTile(
                leading: Icon(Icons.people, color: AppColors.primary),
                title: Text("À propos des développeurs", style: AppTextStyles.subtitle(context)),
                backgroundColor: theme.cardColor,
                collapsedBackgroundColor: theme.cardColor,
                children: [
                  ListTile(
                    title: Text(
                      "Cette application a été réalisée par :\n"
                      "Sharlène Cahetelle Houéfa GBAYI dans le cadre de son mémoire de Master en Hydroinformatique à l'Institut National de l'Eau.\n"
                      "La version finale est reliée au dispositif IoT qui effectue les mesures en temps réel.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- Mission ---
              ExpansionTile(
                leading: Icon(Icons.flag, color: AppColors.primary),
                title: Text("Mission d'HouefaSense", style: AppTextStyles.subtitle(context)),
                backgroundColor: theme.cardColor,
                collapsedBackgroundColor: theme.cardColor,
                children: [
                  ListTile(
                    leading: Icon(Icons.check, color: AppColors.primary),
                    title: Text(
                      "Faciliter le suivi de la qualité de l'eau pour tous.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: AppColors.primary),
                    title: Text(
                      "Fournir un outil pratique et intuitif pour interpréter les mesures.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.check, color: AppColors.primary),
                    title: Text(
                      "Promouvoir une gestion durable et sûre de l'eau.",
                      style: AppTextStyles.body(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Bouton ---
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => _openUrl("mailto:cgbayi@gmail.com"),
                icon: const Icon(Icons.email, color: Colors.white),
                label: Text("Contacter le support", style: AppTextStyles.button(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
