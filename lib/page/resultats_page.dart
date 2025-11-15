import 'package:flutter/material.dart';
import '../models/mesure.dart';
import '../models/interpretation_helper.dart';
import '../models/utilisateur.dart';
import '../widgets/drawer_menu.dart';
import '../services/database_manager.dart'; // pour DBHelper (Firebase + local)
import 'theme.dart';

class ResultatsPage extends StatefulWidget {
  final Utilisateur user;
  const ResultatsPage({super.key, required this.user});

  @override
  State<ResultatsPage> createState() => _ResultatsPageState();
}

class _ResultatsPageState extends State<ResultatsPage> {
  Mesure? _derniereMesure;
  bool _loading = true;
  String? _messageErreur;

  @override
  void initState() {
    super.initState();
    _chargerDerniereMesure();
  }

  Future<void> _chargerDerniereMesure() async {
    try {
      final derniere = await DBHelper.getDerniereMesureLocale();
      if (derniere != null) {
        setState(() {
          _derniereMesure = derniere;
          _loading = false;
        });
      } else {
        setState(() {
          _messageErreur = "Aucune mesure enregistrée.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messageErreur = "Erreur de chargement : $e";
        _loading = false;
      });
    }
  }

  Color _getColorForQuality(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'bonne':
        return Colors.green;
      case 'moyenne':
        return Colors.orange;
      case 'mauvaise':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Résultats d'interprétation",
          style: AppTextStyles.appBarTitle(context),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      drawer: DrawerMenu(user: widget.user),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messageErreur != null
              ? Center(child: Text(_messageErreur!))
              : _buildResultats(context, _derniereMesure!),
    );
  }

  Widget _buildResultats(BuildContext context, Mesure mesure) {
    final interpretationGlobale = InterpretationHelper.interpreter(
      ph: mesure.ph,
      temperature: mesure.temperature,
      turbidite: mesure.turbidite,
      conductivite: mesure.conductivite,
    );

    final niveauQualite = InterpretationHelper.niveauQualite(
      ph: mesure.ph,
      temperature: mesure.temperature,
      turbidite: mesure.turbidite,
      conductivite: mesure.conductivite,
    );

    final couleurQualite = _getColorForQuality(niveauQualite);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lieu : ${mesure.lieu}", style: AppTextStyles.subtitle(context)),
                Text("Date : ${mesure.date.toLocal()}"),
                const SizedBox(height: 10),
                _buildRow("pH", mesure.ph.toStringAsFixed(2)),
                _buildRow("Température (°C)", mesure.temperature.toStringAsFixed(1)),
                _buildRow("Turbidité (NTU)", mesure.turbidite.toStringAsFixed(1)),
                _buildRow("Conductivité (µS/cm)", mesure.conductivite.toStringAsFixed(1)),
                _buildRow("TDS (mg/L)", mesure.tds.toStringAsFixed(1)),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: couleurQualite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: couleurQualite, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Niveau global de qualité : $niveauQualite",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: couleurQualite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        interpretationGlobale,
                        style: TextStyle(fontSize: 15, color: couleurQualite),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String param, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(param, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 1, child: Text(value)),
        ],
      ),
    );
  }
}