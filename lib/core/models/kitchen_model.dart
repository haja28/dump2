class Kitchen {
  final int id;
  final String kitchenName;
  final String address;
  final String city;
  final String ownerContact;
  final String ownerEmail;
  final String? cuisineTypes;
  final String? description;
  final bool isApproved;
  final bool isOpen;
  final double? rating;
  final int? totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  Kitchen({
    required this.id,
    required this.kitchenName,
    required this.address,
    required this.city,
    required this.ownerContact,
    required this.ownerEmail,
    this.cuisineTypes,
    this.description,
    required this.isApproved,
    this.isOpen = true,
    this.rating,
    this.totalOrders,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getter for name
  String get name => kitchenName;

  factory Kitchen.fromJson(Map<String, dynamic> json) {
    return Kitchen(
      id: json['id'] ?? json['kitchenId'],
      kitchenName: json['kitchenName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      ownerContact: json['ownerContact'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      cuisineTypes: json['cuisineTypes'],
      description: json['description'],
      isApproved: json['isApproved'] ?? json['approved'] ?? false,
      isOpen: json['isActive'] ?? json['isOpen'] ?? true,
      rating: json['rating']?.toDouble(),
      totalOrders: json['totalOrders'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Kitchen copyWith({
    int? id,
    String? kitchenName,
    String? address,
    String? city,
    String? ownerContact,
    String? ownerEmail,
    String? cuisineTypes,
    String? description,
    bool? isApproved,
    bool? isOpen,
    double? rating,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kitchen(
      id: id ?? this.id,
      kitchenName: kitchenName ?? this.kitchenName,
      address: address ?? this.address,
      city: city ?? this.city,
      ownerContact: ownerContact ?? this.ownerContact,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      description: description ?? this.description,
      isApproved: isApproved ?? this.isApproved,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitchenName': kitchenName,
      'address': address,
      'city': city,
      'ownerContact': ownerContact,
      'ownerEmail': ownerEmail,
      'cuisineTypes': cuisineTypes,
      'description': description,
      'isApproved': isApproved,
      'isOpen': isOpen,
      'rating': rating,
      'totalOrders': totalOrders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  List<String> get cuisineList {
    if (cuisineTypes == null || cuisineTypes!.isEmpty) return [];
    return cuisineTypes!.split(',').map((e) => e.trim()).toList();
  }
}
