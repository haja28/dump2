import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/theme_config.dart';
import '../../../core/models/menu_item_image_model.dart';
import '../providers/menu_item_image_provider.dart';

/// Widget for displaying and managing menu item images
class MenuItemImageGallery extends StatelessWidget {
  final int? menuItemId;
  final bool readOnly;
  final Function(MenuItemImage?)? onPrimaryChanged;

  const MenuItemImageGallery({
    super.key,
    this.menuItemId,
    this.readOnly = false,
    this.onPrimaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuItemImageProvider>(
      builder: (context, imageProvider, _) {
        final uploadedImages = imageProvider.images;
        final pendingImages = imageProvider.pendingImages;
        final hasImages = uploadedImages.isNotEmpty || pendingImages.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (!readOnly)
                  TextButton.icon(
                    onPressed: () => imageProvider.pickImage(context),
                    icon: const Icon(Icons.add_photo_alternate, size: 20),
                    label: const Text('Add Images'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Upload progress indicator
            if (imageProvider.isUploading) ...[
              LinearProgressIndicator(
                value: imageProvider.uploadProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploading... ${(imageProvider.uploadProgress * 100).toInt()}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],

            // Error message
            if (imageProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        imageProvider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Images grid or empty state
            if (!hasImages && !imageProvider.isLoading)
              _buildEmptyState(context, imageProvider)
            else if (imageProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildImageGrid(context, imageProvider, uploadedImages, pendingImages),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, MenuItemImageProvider imageProvider) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: InkWell(
        onTap: readOnly ? null : () => imageProvider.pickImage(context),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                readOnly ? 'No images' : 'Tap to add images',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (!readOnly) ...[
                const SizedBox(height: 4),
                Text(
                  'Camera or Gallery',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    List<MenuItemImage> uploadedImages,
    List<File> pendingImages,
  ) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Uploaded images
          ...uploadedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            return _buildUploadedImageTile(context, imageProvider, image, index);
          }),
          // Pending images (not yet uploaded)
          ...pendingImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildPendingImageTile(context, imageProvider, file, index);
          }),
          // Add more button
          if (!readOnly) _buildAddMoreButton(context, imageProvider),
        ],
      ),
    );
  }

  Widget _buildUploadedImageTile(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    MenuItemImage image,
    int index,
  ) {
    final imageUrl = imageProvider.getImageUrl(image, thumbnail: true);
    final bool hasValidUrl = imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Image
          GestureDetector(
            onTap: () => _showImageOptions(context, imageProvider, image),
            onLongPress: () {
              // Show full URL for debugging
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('URL: $imageUrl', style: const TextStyle(fontSize: 10)),
                  duration: const Duration(seconds: 5),
                ),
              );
              debugPrint('Image URL (long press): $imageUrl');
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: image.isPrimary
                    ? Border.all(color: ThemeConfig.primaryColor, width: 3)
                    : Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: hasValidUrl
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Image load error for URL: $url, error: $error');
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  'Error',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'No URL',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          // Primary badge
          if (image.isPrimary)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Delete button
          if (!readOnly)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _confirmDeleteImage(context, imageProvider, image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingImageTile(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    File file,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, style: BorderStyle.solid),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Pending badge
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Remove button
          if (!readOnly)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => imageProvider.removePendingImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context, MenuItemImageProvider imageProvider) {
    return GestureDetector(
      onTap: () => imageProvider.pickImage(context),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey[600], size: 32),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    MenuItemImage image,
  ) {
    if (readOnly || menuItemId == null) return;

    showModalBottomSheet(
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
                'Image Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (!image.isPrimary)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.star, color: Colors.white),
                  ),
                  title: const Text('Set as Primary'),
                  subtitle: const Text('This image will be displayed first'),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await imageProvider.setAsPrimary(
                      menuItemId!,
                      image.id,
                    );
                    if (success) {
                      onPrimaryChanged?.call(image);
                    }
                  },
                ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.fullscreen, color: Colors.white),
                ),
                title: const Text('View Full Size'),
                onTap: () {
                  Navigator.pop(context);
                  _showFullSizeImage(context, imageProvider, image);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                title: const Text('Delete Image'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteImage(context, imageProvider, image);
                },
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

  void _showFullSizeImage(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    MenuItemImage image,
  ) {
    final imageUrl = imageProvider.getImageUrl(image, thumbnail: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteImage(
    BuildContext context,
    MenuItemImageProvider imageProvider,
    MenuItemImage image,
  ) {
    if (menuItemId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await imageProvider.deleteImage(menuItemId!, image.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

