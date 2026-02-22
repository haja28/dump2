import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for picking and compressing images from camera or gallery
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from camera or gallery
  static Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      // Compress the image
      final compressedFile = await _compressImage(
        File(pickedFile.path),
        quality: quality,
      );

      return compressedFile ?? File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
        limit: limit,
      );

      if (pickedFiles.isEmpty) return [];

      // Compress all images
      final List<File> compressedFiles = [];
      for (final pickedFile in pickedFiles) {
        final compressedFile = await _compressImage(
          File(pickedFile.path),
          quality: quality,
        );
        compressedFiles.add(compressedFile ?? File(pickedFile.path));
      }

      return compressedFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Compress an image file
  static Future<File?> _compressImage(
    File file, {
    int quality = 85,
    int minWidth = 300,
    int minHeight = 300,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Show bottom sheet to choose image source
  static Future<ImageSource?> showImageSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet with option for single or multiple images
  static Future<ImagePickerResult?> showImagePickerSheet(BuildContext context) async {
    return showModalBottomSheet<ImagePickerResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to take a new photo'),
                onTap: () => Navigator.pop(
                  context,
                  ImagePickerResult(source: ImageSource.camera, isMultiple: false),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.photo, color: Colors.white),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select a single image'),
                onTap: () => Navigator.pop(
                  context,
                  ImagePickerResult(source: ImageSource.gallery, isMultiple: false),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Select Multiple Images'),
                subtitle: const Text('Choose multiple images from gallery'),
                onTap: () => Navigator.pop(
                  context,
                  ImagePickerResult(source: ImageSource.gallery, isMultiple: true),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result from image picker sheet
class ImagePickerResult {
  final ImageSource source;
  final bool isMultiple;

  ImagePickerResult({
    required this.source,
    required this.isMultiple,
  });
}

