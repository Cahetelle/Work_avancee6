import 'package:flutter/material.dart';
import '../models/mesure.dart';
import '../services/database_manager.dart';
import '../models/export_helper.dart';
import '../models/utilisateur.dart';
import '../widgets/drawer_menu.dart';
import 'theme.dart';

class HistoriquePage extends StatefulWidget {
  final Utilisateur user;
  const HistoriquePage({super.key, required this.user});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<Mesure> _mesures = [];
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _loadMesures();
  }

  Future<void> _loadMesures() async {
    final data = await DBHelper.getAllMesures();
    setState(() => _mesures = data);
  }

  Future<void> _exportSelectedCsv() async {
    final selectedMesures =
        _mesures.where((m) => _selected.contains(m.id)).toList();

    if (selectedMesures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sélectionnez au moins une mesure.")),
      );
      return;
    }

    try {
      final filePath = await ExportHelper.exportCSV(selectedMesures);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export CSV réussi : $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur export CSV : $e")),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sélectionnez au moins une mesure.")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Voulez-vous vraiment supprimer ces mesures ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteSelected();
    }
  }

  Future<void> _deleteSelected() async {
    for (var id in _selected) {
      await DBHelper.deleteMesure(id);
      await DBHelper.deleteMesureFirebase(id);
    }

    await _loadMesures();
    setState(() => _selected.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mesures supprimées")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: DrawerMenu(user: widget.user),

      appBar: AppBar(
        title: Text(
          "Historique des mesures",
          style: AppTextStyles.appBarTitle(context),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),

      body: _mesures.isEmpty
          ? const Center(child: Text("Aucune mesure enregistrée"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mesures.length,
              itemBuilder: (context, i) {
                final m = _mesures[i];
                final selected = _selected.contains(m.id);

                return Card(
                  color: selected ? Colors.blue.shade50 : theme.cardColor,
                  child: ListTile(
                    leading: Checkbox(
                      value: selected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(m.id);
                          } else {
                            _selected.remove(m.id);
                          }
                        });
                      },
                    ),
                    title: Text(
                      "${m.lieu} - ${m.date.toLocal().toString().split(' ').first}",
                    ),
                    subtitle: Text(
                      "pH : ${m.ph}, Temp : ${m.temperature}°C, Turb : ${m.turbidite} NTU",
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportSelectedCsv,
                  icon: const Icon(Icons.download),
                  label: const Text("Exporter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
