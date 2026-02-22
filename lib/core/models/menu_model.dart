import 'menu_item_image_model.dart';

class MenuItem {
  final int id;
  final int kitchenId;
  final String itemName;
  final String? description;
  final String? ingredients;
  final String? allergyIndication;
  final double cost;
  final String? imagePath;
  final String? availableTiming;
  final bool isActive;
  final int preparationTimeMinutes;
  final int? quantityAvailable;
  final bool isVeg;
  final bool isHalal;
  final int? spicyLevel;
  final double? rating;
  final List<MenuLabel>? labels;
  final List<MenuItemImage>? images;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Legacy field mapping
  bool get isAvailable => isActive && (quantityAvailable == null || quantityAvailable! > 0);

  MenuItem({
    required this.id,
    required this.kitchenId,
    required this.itemName,
    this.description,
    this.ingredients,
    this.allergyIndication,
    required this.cost,
    this.imagePath,
    this.availableTiming,
    this.isActive = true,
    this.preparationTimeMinutes = 30,
    this.quantityAvailable,
    required this.isVeg,
    required this.isHalal,
    this.spicyLevel,
    this.rating,
    this.labels,
    this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? json['itemId'],
      kitchenId: json['kitchenId'] ?? 0,
      itemName: json['itemName'] ?? '',
      description: json['description'],
      ingredients: json['ingredients'],
      allergyIndication: json['allergyIndication'],
      cost: (json['cost'] ?? json['price'] ?? 0).toDouble(),
      imagePath: json['imagePath'] ?? json['imageUrl'],
      availableTiming: json['availableTiming'],
      isActive: json['isActive'] ?? json['isAvailable'] ?? true,
      preparationTimeMinutes: json['preparationTimeMinutes'] ?? 30,
      quantityAvailable: json['quantityAvailable'],
      isVeg: json['isVeg'] ?? json['veg'] ?? false,
      isHalal: json['isHalal'] ?? json['halal'] ?? false,
      spicyLevel: json['spicyLevel'],
      rating: json['rating']?.toDouble(),
      labels: json['labels'] != null
          ? (json['labels'] as List).map((e) => MenuLabel.fromJson(e)).toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => MenuItemImage.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitchenId': kitchenId,
      'itemName': itemName,
      'description': description,
      'ingredients': ingredients,
      'allergyIndication': allergyIndication,
      'cost': cost,
      'imagePath': imagePath,
      'availableTiming': availableTiming,
      'isActive': isActive,
      'preparationTimeMinutes': preparationTimeMinutes,
      'quantityAvailable': quantityAvailable,
      'isVeg': isVeg,
      'isHalal': isHalal,
      'spicyLevel': spicyLevel,
      'rating': rating,
      'labels': labels?.map((e) => e.toJson()).toList(),
      'images': images?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to request body for create/update API
  Map<String, dynamic> toRequestJson({List<int>? labelIds}) {
    return {
      'itemName': itemName,
      if (description != null) 'description': description,
      if (ingredients != null) 'ingredients': ingredients,
      if (allergyIndication != null) 'allergyIndication': allergyIndication,
      'cost': cost,
      if (imagePath != null) 'imagePath': imagePath,
      if (availableTiming != null) 'availableTiming': availableTiming,
      'preparationTimeMinutes': preparationTimeMinutes,
      if (quantityAvailable != null) 'quantityAvailable': quantityAvailable,
      'isVeg': isVeg,
      'isHalal': isHalal,
      if (spicyLevel != null) 'spicyLevel': spicyLevel,
      if (labelIds != null) 'labelIds': labelIds,
    };
  }

  String getSpicyLevelText() {
    if (spicyLevel == null) return 'Not Spicy';
    switch (spicyLevel) {
      case 1:
        return 'Mild';
      case 2:
        return 'Medium';
      case 3:
        return 'Spicy';
      case 4:
        return 'Very Spicy';
      case 5:
        return 'Extremely Spicy';
      default:
        return 'Unknown';
    }
  }

  // Convenience getters
  String get name => itemName;
  double get price => cost;
  String? get imageUrl => imagePath;

  MenuItem copyWith({
    int? id,
    int? kitchenId,
    String? itemName,
    String? description,
    String? ingredients,
    String? allergyIndication,
    double? cost,
    String? imagePath,
    String? availableTiming,
    bool? isActive,
    int? preparationTimeMinutes,
    int? quantityAvailable,
    bool? isVeg,
    bool? isHalal,
    int? spicyLevel,
    double? rating,
    List<MenuLabel>? labels,
    List<MenuItemImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      kitchenId: kitchenId ?? this.kitchenId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      allergyIndication: allergyIndication ?? this.allergyIndication,
      cost: cost ?? this.cost,
      imagePath: imagePath ?? this.imagePath,
      availableTiming: availableTiming ?? this.availableTiming,
      isActive: isActive ?? this.isActive,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      isVeg: isVeg ?? this.isVeg,
      isHalal: isHalal ?? this.isHalal,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      rating: rating ?? this.rating,
      labels: labels ?? this.labels,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MenuLabel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  MenuLabel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory MenuLabel.fromJson(Map<String, dynamic> json) {
    return MenuLabel(
      id: json['id'] ?? json['labelId'],
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
