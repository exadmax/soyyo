import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  static Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (photo == null) return null;
    return _saveImage(photo);
  }

  static Future<String?> pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (photo == null) return null;
    return _saveImage(photo);
  }

  static Future<String> _saveImage(XFile photo) async {
    if (kIsWeb) {
      return photo.path;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'warranty_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final fileName = '${_uuid.v4()}${path.extension(photo.path)}';
    final savedPath = path.join(imagesDir.path, fileName);
    await photo.saveTo(savedPath);
    return savedPath;
  }

  static Future<void> deletePhoto(String imagePath) async {
    if (kIsWeb) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deletePhotos(List<String> imagePaths) async {
    for (final p in imagePaths) {
      await deletePhoto(p);
    }
  }
}
