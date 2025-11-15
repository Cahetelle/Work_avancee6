import 'package:flutter/material.dart';
import '../models/mesure.dart';
import '../models/interpretation_helper.dart';
import '../page/theme.dart';

class MesureCard extends StatelessWidget {
  final Mesure mesure;
  final VoidCallback? onTap;
  final bool selected;

  const MesureCard({
    super.key,
    required this.mesure,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final qualite = InterpretationHelper.niveauQualite(
      ph: mesure.ph,
      temperature: mesure.temperature,
      turbidite: mesure.turbidite,
      conductivite: mesure.conductivite,
    );

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: selected ? 8 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: selected
              ? BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mesure.lieu,
                style: AppTextStyles.subtitle(context),
              ),
              const SizedBox(height: 6),
              Text(
                "${mesure.date.toLocal()}".split('.')[0],
                style: AppTextStyles.body(context),
              ),
              const Divider(height: 20),
              Text(
                "pH : ${mesure.ph} | Température : ${mesure.temperature}°C",
                style: AppTextStyles.body(context),
              ),
              Text(
                "Turbidité : ${mesure.turbidite} NTU | CE : ${mesure.conductivite} µS/cm",
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 8),
              Text(
                mesure.interpretation,
                style: AppTextStyles.body(context).copyWith(
                  color: qualite.contains("Très bonne")
                      ? Colors.green
                      : qualite.contains("Mauvaise")
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
