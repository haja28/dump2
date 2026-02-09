class Delivery {
  final int deliveryId;
  final int orderId;
  final int kitchenId;
  final int userId;
  final int itemId;
  final String deliveryStatus;
  final String? assignedTo;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final DateTime estimatedDeliveryTime;
  final String? currentLocation;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Delivery({
    required this.deliveryId,
    required this.orderId,
    required this.kitchenId,
    required this.userId,
    required this.itemId,
    required this.deliveryStatus,
    this.assignedTo,
    this.pickupTime,
    this.deliveryTime,
    required this.estimatedDeliveryTime,
    this.currentLocation,
    this.deliveryNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      deliveryId: json['deliveryId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      kitchenId: json['kitchenId'] ?? 0,
      userId: json['userId'] ?? 0,
      itemId: json['itemId'] ?? 0,
      deliveryStatus: json['deliveryStatus'] ?? 'PENDING',
      assignedTo: json['assignedTo'],
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'])
          : null,
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      estimatedDeliveryTime: DateTime.parse(
        json['estimatedDeliveryTime'] ?? DateTime.now().toIso8601String(),
      ),
      currentLocation: json['currentLocation'],
      deliveryNotes: json['deliveryNotes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'orderId': orderId,
      'kitchenId': kitchenId,
      'userId': userId,
      'itemId': itemId,
      'deliveryStatus': deliveryStatus,
      'assignedTo': assignedTo,
      'pickupTime': pickupTime?.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime.toIso8601String(),
      'currentLocation': currentLocation,
      'deliveryNotes': deliveryNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (deliveryStatus) {
      case 'PENDING':
        return 'Pending';
      case 'ASSIGNED':
        return 'Assigned';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'IN_TRANSIT':
        return 'In Transit';
      case 'DELIVERED':
        return 'Delivered';
      case 'FAILED':
        return 'Failed';
      default:
        return deliveryStatus;
    }
  }

  int getStatusStep() {
    switch (deliveryStatus) {
      case 'PENDING':
        return 0;
      case 'ASSIGNED':
        return 1;
      case 'PICKED_UP':
        return 2;
      case 'IN_TRANSIT':
        return 3;
      case 'DELIVERED':
        return 4;
      case 'FAILED':
        return -1;
      default:
        return 0;
    }
  }

  bool get isPending => deliveryStatus == 'PENDING';
  bool get isAssigned => deliveryStatus == 'ASSIGNED';
  bool get isPickedUp => deliveryStatus == 'PICKED_UP';
  bool get isInTransit => deliveryStatus == 'IN_TRANSIT';
  bool get isDelivered => deliveryStatus == 'DELIVERED';
  bool get isFailed => deliveryStatus == 'FAILED';
  bool get isActive => !isDelivered && !isFailed;
}
