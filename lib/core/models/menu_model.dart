class MenuItem {
  final int id;
  final int kitchenId;
  final String itemName;
  final String? description;
  final double cost;
  final bool isVeg;
  final bool isHalal;
  final int? spicyLevel;
  final bool isAvailable;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final List<MenuLabel>? labels;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.kitchenId,
    required this.itemName,
    this.description,
    required this.cost,
    required this.isVeg,
    required this.isHalal,
    this.spicyLevel,
    required this.isAvailable,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.labels,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? json['itemId'],
      kitchenId: json['kitchenId'] ?? 0,
      itemName: json['itemName'] ?? '',
      description: json['description'],
      cost: (json['cost'] ?? json['price'] ?? 0).toDouble(),
      isVeg: json['isVeg'] ?? json['veg'] ?? false,
      isHalal: json['isHalal'] ?? json['halal'] ?? false,
      spicyLevel: json['spicyLevel'],
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      labels: json['labels'] != null
          ? (json['labels'] as List).map((e) => MenuLabel.fromJson(e)).toList()
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
      'cost': cost,
      'isVeg': isVeg,
      'isHalal': isHalal,
      'spicyLevel': spicyLevel,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'labels': labels?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
}

class MenuLabel {
  final int id;
  final String name;
  final String? description;

  MenuLabel({
    required this.id,
    required this.name,
    this.description,
  });

  factory MenuLabel.fromJson(Map<String, dynamic> json) {
    return MenuLabel(
      id: json['id'] ?? json['labelId'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
