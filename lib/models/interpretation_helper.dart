class InterpretationHelper {
  /// Seuils basés sur les recommandations OMS pour l’eau potable
  static const double minPh = 6.5;
  static const double maxPh = 8.5;
  static const double maxTemperature = 30.0; // °C
  static const double maxTurbidite = 5.0; // NTU
  static const double maxConductivite = 2500.0; // µS/cm

  /// Calcule le TDS (Total Dissolved Solids) à partir de la conductivité
  static double calculerTDS(double conductivite) {
    return conductivite * 0.64; // rapport empirique standard
  }

  /// Retourne une interprétation textuelle des mesures
  static String interpreter({
    required double ph,
    required double temperature,
    required double turbidite,
    required double conductivite,
  }) {
    final anomalies = <String>[];

    // Analyse du pH
    if (ph < minPh) {
      anomalies.add("pH trop acide (< 6.5)");
    } else if (ph > maxPh) {
      anomalies.add("pH trop basique (> 8.5)");
    }

    // Analyse de la température
    if (temperature > maxTemperature) {
      anomalies.add("Température élevée (> 30°C)");
    }

    // Analyse de la turbidité
    if (turbidite > maxTurbidite) {
      anomalies.add("Eau trouble (> 5 NTU)");
    }

    // Analyse de la conductivité
    if (conductivite > maxConductivite) {
      anomalies.add("Conductivité élevée (> 2500 µS/cm)");
    }

    // Génération du message final
    if (anomalies.isEmpty) {
      return "✅ Eau de bonne qualité selon les seuils OMS.";
    } else {
      return "⚠️ Anomalies détectées :\n- ${anomalies.join('\n- ')}";
    }
  }

  /// Fournit un résumé sous forme de niveau global de qualité
  static String niveauQualite({
    required double ph,
    required double temperature,
    required double turbidite,
    required double conductivite,
  }) {
    int score = 0;

    if (ph < minPh || ph > maxPh) score++;
    if (temperature > maxTemperature) score++;
    if (turbidite > maxTurbidite) score++;
    if (conductivite > maxConductivite) score++;

    if (score == 0) return "Très bonne";
    if (score == 1) return "Bonne";
    if (score == 2) return "Moyenne";
    if (score == 3) return "Mauvaise";
    return "Très mauvaise";
  }

  /// Retourne une couleur indicative (utile pour affichage)
  static String couleurQualite({
    required double ph,
    required double temperature,
    required double turbidite,
    required double conductivite,
  }) {
    final niveau = niveauQualite(
      ph: ph,
      temperature: temperature,
      turbidite: turbidite,
      conductivite: conductivite,
    );

    switch (niveau) {
      case "Très bonne":
        return "green";
      case "Bonne":
        return "lightGreen";
      case "Moyenne":
        return "amber";
      case "Mauvaise":
        return "orange";
      default:
        return "red";
    }
  }
}
