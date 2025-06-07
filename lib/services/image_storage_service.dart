import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveProfileImage() async {
    try {
      // Request permission only when needed
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        throw Exception(
            'Photo permission is required to select a profile image');
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      // Get application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profileImagesDir = '${appDir.path}/profile_images';

      // Create directory if it doesn't exist
      await Directory(profileImagesDir).create(recursive: true);

      // Generate unique filename
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '$profileImagesDir/$fileName';

      // Copy the picked image to our app directory
      final File savedImage = File(filePath);
      await savedImage.writeAsBytes(await image.readAsBytes());

      return filePath;
    } catch (e) {
      print('Error picking/saving profile image: $e');
      rethrow;
    }
  }

  Future<String?> getProfileImagePath() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profileImagesDir = '${appDir.path}/profile_images';
      final Directory dir = Directory(profileImagesDir);

      if (!await dir.exists()) {
        return null;
      }

      // Get the most recent profile image
      final List<FileSystemEntity> files = await dir.list().toList();
      if (files.isEmpty) {
        return null;
      }

      // Sort by last modified time and get the most recent
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return files.first.path;
    } catch (e) {
      print('Error getting profile image path: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final String? imagePath = await getProfileImagePath();
      if (imagePath != null) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    } catch (e) {
      print('Error deleting profile image: $e');
      rethrow;
    }
  }
}
