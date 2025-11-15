import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/mesure.dart';
import '../models/utilisateur.dart';
import '../models/interpretation_helper.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../services/database_manager.dart';
import '../widgets/drawer_menu.dart';
import '../page/resultats_page.dart';
import 'theme.dart';

class SaisiePage extends StatefulWidget {
  final Utilisateur currentUser;
  const SaisiePage({super.key, required this.currentUser});

  @override
  State<SaisiePage> createState() => _SaisiePageState();
}

class _SaisiePageState extends State<SaisiePage> {
  final _formKey = GlobalKey<FormState>();
  final _lieuCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _temperatureCtrl = TextEditingController();
  final _turbiditeCtrl = TextEditingController();
  final _conductiviteCtrl = TextEditingController();

  double? _latitude;
  double? _longitude;
  File? _photoFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(now);
  }

  @override
  void dispose() {
    _lieuCtrl.dispose();
    _dateCtrl.dispose();
    _phCtrl.dispose();
    _temperatureCtrl.dispose();
    _turbiditeCtrl.dispose();
    _conductiviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePosition() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position récupérée : ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’obtenir la position : $e')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImageService.pickImageFromCameraOrGallery(context);
      if (file != null) {
        setState(() => _photoFile = file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur sélection image : $e')),
      );
    }
  }

  double _calculateTds(double conductivite) {
    return conductivite * 0.64;
  }

  Future<void> _saveMesure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final id = const Uuid().v4();
      final date = DateFormat('yyyy-MM-dd HH:mm').parse(_dateCtrl.text);

      final ph = double.tryParse(_phCtrl.text.replaceAll(',', '.')) ?? 0.0;
      final temp =
          double.tryParse(_temperatureCtrl.text.replaceAll(',', '.')) ?? 0.0;
      final turb =
          double.tryParse(_turbiditeCtrl.text.replaceAll(',', '.')) ?? 0.0;
      final cond =
          double.tryParse(_conductiviteCtrl.text.replaceAll(',', '.')) ?? 0.0;
      final tds = _calculateTds(cond);

      final interpretation = InterpretationHelper.interpreter(
        ph: ph,
        temperature: temp,
        turbidite: turb,
        conductivite: cond,
      );

      String? photoUrl;
      if (_photoFile != null) {
        photoUrl = await ImageService.saveImageToAppDirectory(_photoFile!, id);
      }

      final mesure = Mesure(
        id: id,
        userId: widget.currentUser.id ?? '',
        lieu: _lieuCtrl.text.trim(),
        date: date,
        ph: ph,
        temperature: temp,
        turbidite: turb,
        conductivite: cond,
        tds: tds,
        latitude: _latitude,
        longitude: _longitude,
        photoUrl: photoUrl,
        interpretation: interpretation,
      );

      await DBHelper.saveMesureLocal(mesure);
      await DBHelper.saveMesure(mesure);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesure enregistrée avec succès')),
        );

        // Redirection vers la page des résultats
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultatsPage(user: widget.currentUser),
          ),
        );

      }

      _formKey.currentState?.reset();
      setState(() {
        _photoFile = null;
        _latitude = null;
        _longitude = null;
        _dateCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur enregistrement : $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Obligatoire';
          if (double.tryParse(v.replaceAll(',', '.')) == null) {
            return 'Nombre invalide';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Saisie de mesure', style: AppTextStyles.appBarTitle(context)),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      drawer: DrawerMenu(user: widget.currentUser),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _lieuCtrl,
                decoration: InputDecoration(
                  labelText: 'Lieu de mesure',
                  hintText: 'Ex : Rivière Ouémé, secteur X',
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    final finalDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time?.hour ?? 0,
                      time?.minute ?? 0,
                    );
                    _dateCtrl.text =
                        DateFormat('yyyy-MM-dd HH:mm').format(finalDate);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Date et heure',
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _latitude != null && _longitude != null
                            ? 'Lat: ${_latitude!.toStringAsFixed(5)}, Lon: ${_longitude!.toStringAsFixed(5)}'
                            : 'Coordonnées non définies',
                        style: AppTextStyles.body(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _takePosition,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Prendre position'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                  controller: _phCtrl, label: 'pH', hint: 'Ex : 7.2'),
              _buildNumberField(
                  controller: _temperatureCtrl,
                  label: 'Température (°C)',
                  hint: 'Ex : 25.5'),
              _buildNumberField(
                  controller: _turbiditeCtrl,
                  label: 'Turbidité (NTU)',
                  hint: 'Ex : 3.0'),
              _buildNumberField(
                  controller: _conductiviteCtrl,
                  label: 'Conductivité (µS/cm)',
                  hint: 'Ex : 450'),
              const SizedBox(height: 12),
              if (_photoFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _photoFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ajouter une photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final cond = double.tryParse(
                          _conductiviteCtrl.text.replaceAll(',', '.'));
                      if (cond == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Entrez une conductivité valide pour calculer le TDS')),
                        );
                        return;
                      }
                      final tds = _calculateTds(cond);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('TDS estimé : ${tds.toStringAsFixed(2)}')),
                      );
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculer TDS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveMesure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Enregistrer la mesure',
                          style: AppTextStyles.button(context)),
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
