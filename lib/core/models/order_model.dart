class Order {
  final int id;
  final int userId;
  final int kitchenId;
  final String? kitchenName;
  final String deliveryAddress;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;
  final DateTime? deliveryTime;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.kitchenId,
    this.kitchenName,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.deliveryTime,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? json['orderId'],
      userId: json['userId'] ?? 0,
      kitchenId: json['kitchenId'] ?? 0,
      kitchenName: json['kitchenName'],
      deliveryAddress: json['deliveryAddress'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : [],
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'kitchenId': kitchenId,
      'kitchenName': kitchenName,
      'deliveryAddress': deliveryAddress,
      'totalAmount': totalAmount,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PREPARING':
        return 'Preparing';
      case 'READY':
        return 'Ready';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canCancel => status == 'PENDING' || status == 'CONFIRMED';
  bool get isActive => !['DELIVERED', 'CANCELLED'].contains(status);
  bool get isCompleted => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
}

class OrderItem {
  final int itemId;
  final String itemName;
  final int quantity;
  final double price;
  final double? totalPrice;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
    this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: json['totalPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}
