import 'dart:io';
import 'package:csv/csv.dart';
import 'mesure.dart';

class ExportHelper {
  static Future<String> exportCSV(List<Mesure> mesures) async {
    final List<List<dynamic>> rows = [
      [
        "Lieu",
        "Date",
        "pH",
        "Température (°C)",
        "Turbidité (NTU)",
        "Conductivité (µS/cm)",
        "TDS (ppm)",
        "Latitude",
        "Longitude",
        "Interprétation",
      ],
      ...mesures.map((m) => [
            m.lieu,
            m.date.toIso8601String(),
            m.ph,
            m.temperature,
            m.turbidite,
            m.conductivite,
            m.tds,
            m.latitude ?? '',
            m.longitude ?? '',
            m.interpretation,
          ]),
    ];

    // Convertir en CSV
    final csvData = const ListToCsvConverter().convert(rows);

    // Dossier Téléchargements Android
    final Directory downloads = Directory("/storage/emulated/0/Download");

    if (!downloads.existsSync()) {
      downloads.createSync(recursive: true);
    }

    final String filePath =
        "${downloads.path}/mesures_export_${DateTime.now().millisecondsSinceEpoch}.csv";

    final File file = File(filePath);

    await file.writeAsString(csvData);

    return filePath;
  }
}
