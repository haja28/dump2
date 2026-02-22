/// Model for menu item images
class MenuItemImage {
  final int id;
  final int menuItemId;
  final String uuid;
  final String originalFilename;
  final String originalImageUrl;
  final String thumbnailImageUrl;
  final String? contentType;
  final int? fileSize;
  final int? imageWidth;
  final int? imageHeight;
  final int? thumbnailWidth;
  final int? thumbnailHeight;
  final int displayOrder;
  final bool isPrimary;
  final bool isActive;
  final String? altText;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemImage({
    required this.id,
    required this.menuItemId,
    required this.uuid,
    required this.originalFilename,
    required this.originalImageUrl,
    required this.thumbnailImageUrl,
    this.contentType,
    this.fileSize,
    this.imageWidth,
    this.imageHeight,
    this.thumbnailWidth,
    this.thumbnailHeight,
    this.displayOrder = 0,
    this.isPrimary = false,
    this.isActive = true,
    this.altText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemImage.fromJson(Map<String, dynamic> json) {
    return MenuItemImage(
      id: json['id'] ?? json['imageId'] ?? 0,
      menuItemId: json['menuItemId'] ?? 0,
      uuid: json['uuid'] ?? '',
      originalFilename: json['originalFilename'] ?? '',
      originalImageUrl: json['originalImageUrl'] ?? '',
      thumbnailImageUrl: json['thumbnailImageUrl'] ?? '',
      contentType: json['contentType'],
      fileSize: json['fileSize'],
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
      thumbnailWidth: json['thumbnailWidth'],
      thumbnailHeight: json['thumbnailHeight'],
      displayOrder: json['displayOrder'] ?? 0,
      isPrimary: json['isPrimary'] ?? false,
      isActive: json['isActive'] ?? true,
      altText: json['altText'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'uuid': uuid,
      'originalFilename': originalFilename,
      'originalImageUrl': originalImageUrl,
      'thumbnailImageUrl': thumbnailImageUrl,
      'contentType': contentType,
      'fileSize': fileSize,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'thumbnailWidth': thumbnailWidth,
      'thumbnailHeight': thumbnailHeight,
      'displayOrder': displayOrder,
      'isPrimary': isPrimary,
      'isActive': isActive,
      'altText': altText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuItemImage copyWith({
    int? id,
    int? menuItemId,
    String? uuid,
    String? originalFilename,
    String? originalImageUrl,
    String? thumbnailImageUrl,
    String? contentType,
    int? fileSize,
    int? imageWidth,
    int? imageHeight,
    int? thumbnailWidth,
    int? thumbnailHeight,
    int? displayOrder,
    bool? isPrimary,
    bool? isActive,
    String? altText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemImage(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      uuid: uuid ?? this.uuid,
      originalFilename: originalFilename ?? this.originalFilename,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      contentType: contentType ?? this.contentType,
      fileSize: fileSize ?? this.fileSize,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      thumbnailWidth: thumbnailWidth ?? this.thumbnailWidth,
      thumbnailHeight: thumbnailHeight ?? this.thumbnailHeight,
      displayOrder: displayOrder ?? this.displayOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      altText: altText ?? this.altText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full URL for original image
  String getOriginalUrl(String baseUrl) {
    if (originalImageUrl.isEmpty) return '';
    if (originalImageUrl.startsWith('http://') || originalImageUrl.startsWith('https://')) {
      return originalImageUrl;
    }
    // The image URL from API already includes /api/v1/images/...
    // We need to use only the server base URL (without /api/v1)
    String serverBaseUrl = baseUrl;
    if (serverBaseUrl.contains('/api/')) {
      // Extract just the server URL: http://host:port
      final uri = Uri.parse(serverBaseUrl);
      serverBaseUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    }
    // Ensure proper path joining
    if (originalImageUrl.startsWith('/')) {
      return '$serverBaseUrl$originalImageUrl';
    }
    return '$serverBaseUrl/$originalImageUrl';
  }

  /// Get full URL for thumbnail image
  String getThumbnailUrl(String baseUrl) {
    if (thumbnailImageUrl.isEmpty) {
      // Fallback to original if thumbnail not available
      return getOriginalUrl(baseUrl);
    }
    if (thumbnailImageUrl.startsWith('http://') || thumbnailImageUrl.startsWith('https://')) {
      return thumbnailImageUrl;
    }
    // The image URL from API already includes /api/v1/images/...
    // We need to use only the server base URL (without /api/v1)
    String serverBaseUrl = baseUrl;
    if (serverBaseUrl.contains('/api/')) {
      // Extract just the server URL: http://host:port
      final uri = Uri.parse(serverBaseUrl);
      serverBaseUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    }
    // Ensure proper path joining
    if (thumbnailImageUrl.startsWith('/')) {
      return '$serverBaseUrl$thumbnailImageUrl';
    }
    return '$serverBaseUrl/$thumbnailImageUrl';
  }

  /// Format file size for display
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get dimensions string
  String get dimensions {
    if (imageWidth == null || imageHeight == null) return 'Unknown';
    return '${imageWidth}x$imageHeight';
  }
}

