class CartModel {
  final int cartId;
  final int userId;
  final int? kitchenId;
  final String? kitchenName;
  final String? couponCode;
  final String? couponDescription;
  final double discountAmount;
  final double deliveryFee;
  final List<CartItemModel> items;
  final double subtotal;
  final double total;
  final bool isValid;
  final bool hasStockIssues;
  final bool hasPriceChanges;
  final List<String> warnings;
  final DateTime? expiresAt;
  final int? minutesUntilExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.cartId,
    required this.userId,
    this.kitchenId,
    this.kitchenName,
    this.couponCode,
    this.couponDescription,
    required this.discountAmount,
    required this.deliveryFee,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.isValid,
    required this.hasStockIssues,
    required this.hasPriceChanges,
    required this.warnings,
    this.expiresAt,
    this.minutesUntilExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cart_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      kitchenId: json['kitchen_id'],
      kitchenName: json['kitchen_name'],
      couponCode: json['coupon_code'],
      couponDescription: json['coupon_description'],
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 3.0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      isValid: json['is_valid'] ?? true,
      hasStockIssues: json['has_stock_issues'] ?? false,
      hasPriceChanges: json['has_price_changes'] ?? false,
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((w) => w.toString())
              .toList() ??
          [],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      minutesUntilExpiry: json['minutes_until_expiry'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'user_id': userId,
      'kitchen_id': kitchenId,
      'kitchen_name': kitchenName,
      'coupon_code': couponCode,
      'coupon_description': couponDescription,
      'discount_amount': discountAmount,
      'delivery_fee': deliveryFee,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'total': total,
      'is_valid': isValid,
      'has_stock_issues': hasStockIssues,
      'has_price_changes': hasPriceChanges,
      'warnings': warnings,
      'expires_at': expiresAt?.toIso8601String(),
      'minutes_until_expiry': minutesUntilExpiry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isExpiringSoon =>
      minutesUntilExpiry != null && minutesUntilExpiry! < 120;
}

class CartItemModel {
  final int cartItemId;
  final int itemId;
  final String itemName;
  final String? itemDescription;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double? originalPrice;
  final double? currentMenuPrice;
  final bool priceChanged;
  final bool inStock;
  final int? availableStock;
  final String? specialRequests;
  final DateTime? addedAt;
  final String? priceChangeMessage;

  CartItemModel({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    this.itemDescription,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    this.originalPrice,
    this.currentMenuPrice,
    required this.priceChanged,
    required this.inStock,
    this.availableStock,
    this.specialRequests,
    this.addedAt,
    this.priceChangeMessage,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cart_item_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      itemDescription: json['item_description'],
      imageUrl: json['image_url'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price']).toDouble()
          : null,
      currentMenuPrice: json['current_menu_price'] != null
          ? (json['current_menu_price']).toDouble()
          : null,
      priceChanged: json['price_changed'] ?? false,
      inStock: json['in_stock'] ?? true,
      availableStock: json['available_stock'],
      specialRequests: json['special_requests'],
      addedAt:
          json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
      priceChangeMessage: json['price_change_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'item_id': itemId,
      'item_name': itemName,
      'item_description': itemDescription,
      'image_url': imageUrl,
      'quantity': quantity,
      'unit_price': unitPrice,
      'original_price': originalPrice,
      'current_menu_price': currentMenuPrice,
      'price_changed': priceChanged,
      'in_stock': inStock,
      'available_stock': availableStock,
      'special_requests': specialRequests,
      'added_at': addedAt?.toIso8601String(),
      'price_change_message': priceChangeMessage,
    };
  }

  double get subtotal => unitPrice * quantity;
  double get priceDifference =>
      (originalPrice != null && currentMenuPrice != null)
          ? currentMenuPrice! - originalPrice!
          : 0.0;

  bool get isLowStock =>
      availableStock != null && availableStock! > 0 && availableStock! <= 5;
}

class AddToCartRequest {
  final int itemId;
  final int quantity;
  final String? specialRequests;

  AddToCartRequest({
    required this.itemId,
    required this.quantity,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      if (specialRequests != null) 'special_requests': specialRequests,
    };
  }
}

class UpdateCartItemRequest {
  final int quantity;
  final String? specialRequests;

  UpdateCartItemRequest({
    required this.quantity,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      if (specialRequests != null) 'special_requests': specialRequests,
    };
  }
}

class ApplyCouponRequest {
  final String couponCode;

  ApplyCouponRequest({required this.couponCode});

  Map<String, dynamic> toJson() {
    return {
      'coupon_code': couponCode,
    };
  }
}

