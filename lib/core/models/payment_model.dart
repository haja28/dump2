class Payment {
  final int paymentId;
  final int orderId;
  final int userId;
  final double paymentAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final DateTime? paymentDate;
  final double? refundAmount;
  final DateTime? refundDate;
  final String? refundReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.userId,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.paymentDate,
    this.refundAmount,
    this.refundDate,
    this.refundReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      paymentAmount: (json['paymentAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CASH_ON_DELIVERY',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      transactionId: json['transactionId'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      refundAmount: json['refundAmount']?.toDouble(),
      refundDate: json['refundDate'] != null
          ? DateTime.parse(json['refundDate'])
          : null,
      refundReason: json['refundReason'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'userId': userId,
      'paymentAmount': paymentAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'paymentDate': paymentDate?.toIso8601String(),
      'refundAmount': refundAmount,
      'refundDate': refundDate?.toIso8601String(),
      'refundReason': refundReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getPaymentMethodText() {
    switch (paymentMethod) {
      case 'CREDIT_CARD':
        return 'Credit Card';
      case 'DEBIT_CARD':
        return 'Debit Card';
      case 'NET_BANKING':
        return 'Net Banking';
      case 'WALLET':
        return 'Wallet';
      case 'CASH_ON_DELIVERY':
        return 'Cash on Delivery';
      case 'UPI':
        return 'UPI';
      default:
        return paymentMethod;
    }
  }

  String getStatusText() {
    switch (paymentStatus) {
      case 'PENDING':
        return 'Pending';
      case 'COMPLETED':
        return 'Completed';
      case 'FAILED':
        return 'Failed';
      case 'REFUNDED':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  bool get isCompleted => paymentStatus == 'COMPLETED';
  bool get isPending => paymentStatus == 'PENDING';
  bool get isFailed => paymentStatus == 'FAILED';
  bool get isRefunded => paymentStatus == 'REFUNDED';
}

class PaymentStats {
  final int userId;
  final int totalPayments;
  final double totalAmount;
  final int completedPayments;
  final double completedAmount;
  final int pendingPayments;
  final double pendingAmount;
  final int failedPayments;
  final double failedAmount;
  final int refundedPayments;
  final double refundedAmount;
  final DateTime? lastPaymentDate;
  final double averagePaymentAmount;

  PaymentStats({
    required this.userId,
    required this.totalPayments,
    required this.totalAmount,
    required this.completedPayments,
    required this.completedAmount,
    required this.pendingPayments,
    required this.pendingAmount,
    required this.failedPayments,
    required this.failedAmount,
    required this.refundedPayments,
    required this.refundedAmount,
    this.lastPaymentDate,
    required this.averagePaymentAmount,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      userId: json['userId'] ?? 0,
      totalPayments: json['totalPayments'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      completedPayments: json['completedPayments'] ?? 0,
      completedAmount: (json['completedAmount'] ?? 0).toDouble(),
      pendingPayments: json['pendingPayments'] ?? 0,
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      failedPayments: json['failedPayments'] ?? 0,
      failedAmount: (json['failedAmount'] ?? 0).toDouble(),
      refundedPayments: json['refundedPayments'] ?? 0,
      refundedAmount: (json['refundedAmount'] ?? 0).toDouble(),
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'])
          : null,
      averagePaymentAmount: (json['averagePaymentAmount'] ?? 0).toDouble(),
    );
  }
}
