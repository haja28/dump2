enum CouponType {
  PERCENTAGE,
  FIXED_AMOUNT,
  FREE_DELIVERY;

  String get displayName {
    switch (this) {
      case CouponType.PERCENTAGE:
        return 'Percentage Discount';
      case CouponType.FIXED_AMOUNT:
        return 'Fixed Amount Discount';
      case CouponType.FREE_DELIVERY:
        return 'Free Delivery';
    }
  }

  static CouponType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PERCENTAGE':
        return CouponType.PERCENTAGE;
      case 'FIXED_AMOUNT':
        return CouponType.FIXED_AMOUNT;
      case 'FREE_DELIVERY':
        return CouponType.FREE_DELIVERY;
      default:
        return CouponType.FIXED_AMOUNT;
    }
  }
}

class CouponModel {
  final int couponId;
  final String code;
  final CouponType type;
  final double discountValue;
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? maxUsesPerUser;
  final int? totalMaxUses;
  final int? currentUses;
  final List<int>? applicableKitchenIds;
  final bool isActive;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponModel({
    required this.couponId,
    required this.code,
    required this.type,
    required this.discountValue,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    this.maxUsesPerUser,
    this.totalMaxUses,
    this.currentUses,
    this.applicableKitchenIds,
    required this.isActive,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: json['coupon_id'] ?? json['id'] ?? 0,
      code: json['code'] ?? '',
      type: CouponType.fromString(json['type'] ?? 'FIXED_AMOUNT'),
      discountValue: (json['discount_value'] ?? 0.0).toDouble(),
      minimumOrderAmount: json['minimum_order_amount'] != null
          ? (json['minimum_order_amount']).toDouble()
          : null,
      maximumDiscountAmount: json['maximum_discount_amount'] != null
          ? (json['maximum_discount_amount']).toDouble()
          : null,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : DateTime.now(),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : DateTime.now().add(const Duration(days: 30)),
      maxUsesPerUser: json['max_uses_per_user'],
      totalMaxUses: json['total_max_uses'],
      currentUses: json['current_uses'] ?? 0,
      applicableKitchenIds: json['applicable_kitchen_ids'] != null
          ? List<int>.from(json['applicable_kitchen_ids'])
          : null,
      isActive: json['is_active'] ?? true,
      description: json['description'] ?? '',
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
      'coupon_id': couponId,
      'code': code,
      'type': type.name,
      'discount_value': discountValue,
      'minimum_order_amount': minimumOrderAmount,
      'maximum_discount_amount': maximumDiscountAmount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'max_uses_per_user': maxUsesPerUser,
      'total_max_uses': totalMaxUses,
      'current_uses': currentUses,
      'applicable_kitchen_ids': applicableKitchenIds,
      'is_active': isActive,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
           now.isAfter(validFrom) &&
           now.isBefore(validUntil) &&
           (totalMaxUses == null || (currentUses ?? 0) < totalMaxUses!);
  }

  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }

  bool get isNotYetActive {
    return DateTime.now().isBefore(validFrom);
  }

  bool isApplicableToKitchen(int kitchenId) {
    if (applicableKitchenIds == null || applicableKitchenIds!.isEmpty) {
      return true; // Applicable to all kitchens
    }
    return applicableKitchenIds!.contains(kitchenId);
  }

  bool hasReachedMaxUses() {
    if (totalMaxUses == null) return false;
    return (currentUses ?? 0) >= totalMaxUses!;
  }

  int? get remainingUses {
    if (totalMaxUses == null) return null;
    return totalMaxUses! - (currentUses ?? 0);
  }

  String get discountDisplay {
    switch (type) {
      case CouponType.PERCENTAGE:
        return '${discountValue.toStringAsFixed(0)}% OFF';
      case CouponType.FIXED_AMOUNT:
        return 'RM${discountValue.toStringAsFixed(2)} OFF';
      case CouponType.FREE_DELIVERY:
        return 'FREE DELIVERY';
    }
  }

  String get minOrderDisplay {
    if (minimumOrderAmount == null || minimumOrderAmount == 0) {
      return 'No minimum order';
    }
    return 'Min. order RM${minimumOrderAmount!.toStringAsFixed(2)}';
  }

  String get maxDiscountDisplay {
    if (maximumDiscountAmount == null) {
      return '';
    }
    return 'Max RM${maximumDiscountAmount!.toStringAsFixed(2)}';
  }

  String get validityDisplay {
    final formatter = (DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    };
    return 'Valid until ${formatter(validUntil)}';
  }

  CouponModel copyWith({
    int? couponId,
    String? code,
    CouponType? type,
    double? discountValue,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    DateTime? validFrom,
    DateTime? validUntil,
    int? maxUsesPerUser,
    int? totalMaxUses,
    int? currentUses,
    List<int>? applicableKitchenIds,
    bool? isActive,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouponModel(
      couponId: couponId ?? this.couponId,
      code: code ?? this.code,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      maxUsesPerUser: maxUsesPerUser ?? this.maxUsesPerUser,
      totalMaxUses: totalMaxUses ?? this.totalMaxUses,
      currentUses: currentUses ?? this.currentUses,
      applicableKitchenIds: applicableKitchenIds ?? this.applicableKitchenIds,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CouponModel(code: $code, type: ${type.name}, discountValue: $discountValue, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CouponModel && other.couponId == couponId;
  }

  @override
  int get hashCode => couponId.hashCode;
}

// Request/Response models for coupon operations
class ValidateCouponRequest {
  final String code;
  final int? kitchenId;
  final double? orderAmount;

  ValidateCouponRequest({
    required this.code,
    this.kitchenId,
    this.orderAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      if (kitchenId != null) 'kitchen_id': kitchenId,
      if (orderAmount != null) 'order_amount': orderAmount,
    };
  }
}

class ValidateCouponResponse {
  final bool isValid;
  final String? message;
  final double? discountAmount;
  final CouponModel? coupon;

  ValidateCouponResponse({
    required this.isValid,
    this.message,
    this.discountAmount,
    this.coupon,
  });

  factory ValidateCouponResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCouponResponse(
      isValid: json['is_valid'] ?? false,
      message: json['message'],
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount']).toDouble()
          : null,
      coupon: json['coupon'] != null
          ? CouponModel.fromJson(json['coupon'])
          : null,
    );
  }
}

