import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Ouvre un dialog simple pour choisir caméra ou galerie,
  /// retourne un File ou null.
  static Future<File?> pickImageFromCameraOrGallery(BuildContext context) async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Prendre une photo'), onTap: () => Navigator.pop(ctx, 'camera')),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choisir depuis la galerie'), onTap: () => Navigator.pop(ctx, 'gallery')),
            ListTile(leading: const Icon(Icons.close), title: const Text('Annuler'), onTap: () => Navigator.pop(ctx, null)),
          ],
        ),
      ),
    );

    if (choice == null) return null;

    final XFile? xfile = await _picker.pickImage(source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return null;
    return File(xfile.path);
  }

  /// Sauvegarde le fichier dans le dossier de l'app et renvoie le chemin relatif
  static Future<String> saveImageToAppDirectory(File file, String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(file.path);
    final filename = 'mesure_$id$ext';
    final saved = await file.copy('${appDir.path}/$filename');
    return saved.path; // tu peux renvoyer URL si tu uploades sur Firebase Storage
  }
}
