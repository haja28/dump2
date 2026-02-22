import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../../core/models/menu_item_image_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/image_picker_service.dart';

/// Provider for managing menu item images
class MenuItemImageProvider with ChangeNotifier {
  List<MenuItemImage> _images = [];
  List<File> _pendingImages = []; // Images to be uploaded (for new items)
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  double _uploadProgress = 0.0;

  List<MenuItemImage> get images => _images;
  List<File> get pendingImages => _pendingImages;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  /// Get the primary image
  MenuItemImage? get primaryImage {
    try {
      return _images.firstWhere((img) => img.isPrimary);
    } catch (_) {
      return _images.isNotEmpty ? _images.first : null;
    }
  }

  /// Check if there are any images (uploaded or pending)
  bool get hasImages => _images.isNotEmpty || _pendingImages.isNotEmpty;

  /// Total count of images
  int get totalImageCount => _images.length + _pendingImages.length;

  /// Clear all data
  void clear() {
    _images = [];
    _pendingImages = [];
    _isLoading = false;
    _isUploading = false;
    _error = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  /// Set images directly from a list (e.g., from MenuItem's embedded images)
  void setImages(List<MenuItemImage> images) {
    _images = List.from(images);
    _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    notifyListeners();
  }
  /// Fetch images for a menu item
  Future<void> fetchImages(int menuItemId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Fetching images for menu item: $menuItemId');
      final response = await ApiService.getMenuItemImages(menuItemId);
      debugPrint('Images response status: ${response.statusCode}');
      debugPrint('Images response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic>? imageList;

        // Handle different response structures
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            imageList = data;
          } else if (data is Map && data['content'] != null) {
            imageList = data['content'] as List;
          } else if (data is Map && data['images'] != null) {
            imageList = data['images'] as List;
          }
        } else if (responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            imageList = data;
          } else if (data is Map && data['content'] != null) {
            imageList = data['content'] as List;
          }
        } else if (responseData['content'] != null) {
          imageList = responseData['content'] as List;
        } else if (responseData['images'] != null) {
          imageList = responseData['images'] as List;
        } else if (responseData is List) {
          imageList = responseData;
        }

        if (imageList != null) {
          _images = imageList.map((json) => MenuItemImage.fromJson(json)).toList();
          // Sort by display order
          _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          debugPrint('Loaded ${_images.length} images');
        } else {
          _images = [];
          debugPrint('No images found in response');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching menu item images: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = 'Failed to load images';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a pending image (for new menu items or before upload)
  void addPendingImage(File file) {
    _pendingImages.add(file);
    notifyListeners();
  }

  /// Add multiple pending images
  void addPendingImages(List<File> files) {
    _pendingImages.addAll(files);
    notifyListeners();
  }

  /// Remove a pending image
  void removePendingImage(int index) {
    if (index >= 0 && index < _pendingImages.length) {
      _pendingImages.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear pending images
  void clearPendingImages() {
    _pendingImages = [];
    notifyListeners();
  }

  /// Upload a single image
  Future<MenuItemImage?> uploadImage(
    int menuItemId,
    File file, {
    String? altText,
    bool isPrimary = false,
  }) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      notifyListeners();

      final fileName = path.basename(file.path);
      final response = await ApiService.uploadMenuItemImage(
        menuItemId,
        file.path,
        fileName,
        altText: altText,
        isPrimary: isPrimary,
      );

      _isUploading = false;
      _uploadProgress = 1.0;

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newImage = MenuItemImage.fromJson(response.data['data']);
        _images.add(newImage);
        _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        notifyListeners();
        return newImage;
      }

      _error = response.data['message'] ?? 'Failed to upload image';
      notifyListeners();
      return null;
    } on DioException catch (e) {
      debugPrint('Error uploading image: $e');
      _error = e.response?.data['message'] ?? 'Failed to upload image';
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      _error = 'An unexpected error occurred';
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  /// Upload all pending images
  Future<List<MenuItemImage>> uploadPendingImages(int menuItemId) async {
    if (_pendingImages.isEmpty) return [];

    final uploadedImages = <MenuItemImage>[];
    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    for (int i = 0; i < _pendingImages.length; i++) {
      final file = _pendingImages[i];
      final fileName = path.basename(file.path);

      try {
        final response = await ApiService.uploadMenuItemImage(
          menuItemId,
          file.path,
          fileName,
          isPrimary: i == 0 && _images.isEmpty, // First image is primary if no existing images
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final newImage = MenuItemImage.fromJson(response.data['data']);
          uploadedImages.add(newImage);
          _images.add(newImage);
        }
      } catch (e) {
        debugPrint('Error uploading image ${i + 1}: $e');
      }

      _uploadProgress = (i + 1) / _pendingImages.length;
      notifyListeners();
    }

    _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    _pendingImages.clear();
    _isUploading = false;
    notifyListeners();

    return uploadedImages;
  }

  /// Upload multiple images at once (batch)
  Future<List<MenuItemImage>> uploadMultipleImages(
    int menuItemId,
    List<File> files, {
    String? altText,
  }) async {
    if (files.isEmpty) return [];

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
      notifyListeners();

      final filePaths = files.map((f) => f.path).toList();
      final fileNames = files.map((f) => path.basename(f.path)).toList();

      final response = await ApiService.uploadMenuItemImages(
        menuItemId,
        filePaths,
        fileNames,
        altText: altText,
      );

      _isUploading = false;
      _uploadProgress = 1.0;

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          final newImages = data.map((json) => MenuItemImage.fromJson(json)).toList();
          _images.addAll(newImages);
          _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          notifyListeners();
          return newImages;
        }
      }

      _error = response.data['message'] ?? 'Failed to upload images';
      notifyListeners();
      return [];
    } on DioException catch (e) {
      debugPrint('Error uploading images: $e');
      _error = e.response?.data['message'] ?? 'Failed to upload images';
      _isUploading = false;
      notifyListeners();
      return [];
    } catch (e) {
      debugPrint('Error uploading images: $e');
      _error = 'An unexpected error occurred';
      _isUploading = false;
      notifyListeners();
      return [];
    }
  }

  /// Set image as primary
  Future<bool> setAsPrimary(int menuItemId, int imageId) async {
    try {
      final response = await ApiService.setMenuItemImagePrimary(menuItemId, imageId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update local state
        for (int i = 0; i < _images.length; i++) {
          _images[i] = _images[i].copyWith(isPrimary: _images[i].id == imageId);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error setting primary image: $e');
      return false;
    }
  }

  /// Update display order
  Future<bool> updateDisplayOrder(int menuItemId, int imageId, int displayOrder) async {
    try {
      final response = await ApiService.updateMenuItemImageOrder(
        menuItemId,
        imageId,
        displayOrder,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _images.indexWhere((img) => img.id == imageId);
        if (index >= 0) {
          _images[index] = _images[index].copyWith(displayOrder: displayOrder);
          _images.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating display order: $e');
      return false;
    }
  }

  /// Update alt text
  Future<bool> updateAltText(int menuItemId, int imageId, String altText) async {
    try {
      final response = await ApiService.updateMenuItemImageAltText(
        menuItemId,
        imageId,
        altText,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _images.indexWhere((img) => img.id == imageId);
        if (index >= 0) {
          _images[index] = _images[index].copyWith(altText: altText);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating alt text: $e');
      return false;
    }
  }

  /// Deactivate image (soft delete)
  Future<bool> deactivateImage(int menuItemId, int imageId) async {
    try {
      final response = await ApiService.deactivateMenuItemImage(menuItemId, imageId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        _images.removeWhere((img) => img.id == imageId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deactivating image: $e');
      return false;
    }
  }

  /// Delete image permanently
  Future<bool> deleteImage(int menuItemId, int imageId) async {
    try {
      final response = await ApiService.deleteMenuItemImage(menuItemId, imageId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _images.removeWhere((img) => img.id == imageId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Pick and add image from camera or gallery
  Future<void> pickImage(BuildContext context) async {
    final result = await ImagePickerService.showImagePickerSheet(context);
    if (result == null) return;

    if (result.isMultiple) {
      final files = await ImagePickerService.pickMultipleImages();
      if (files.isNotEmpty) {
        addPendingImages(files);
      }
    } else {
      final file = await ImagePickerService.pickImage(source: result.source);
      if (file != null) {
        addPendingImage(file);
      }
    }
  }

  /// Get image URL helper
  String getImageUrl(MenuItemImage image, {bool thumbnail = true}) {
    final baseUrl = ApiService.getImageBaseUrl();
    final url = thumbnail ? image.getThumbnailUrl(baseUrl) : image.getOriginalUrl(baseUrl);
    debugPrint('Image URL constructed: $url (thumbnail: $thumbnail, base: $baseUrl)');
    debugPrint('  originalImageUrl: ${image.originalImageUrl}');
    debugPrint('  thumbnailImageUrl: ${image.thumbnailImageUrl}');
    return url;
  }
}

