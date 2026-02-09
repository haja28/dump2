import 'package:equatable/equatable.dart';

enum ConversationStatus { active, archived, closed }

class Conversation extends Equatable {
  final int conversationId;
  final int customerId;
  final int kitchenId;
  final int? orderId;
  final String? title;
  final ConversationStatus status;
  final int unreadCount;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.conversationId,
    required this.customerId,
    required this.kitchenId,
    this.orderId,
    this.title,
    this.status = ConversationStatus.active,
    this.unreadCount = 0,
    this.lastMessagePreview,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? 0,
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      kitchenId: json['kitchen_id'] ?? json['kitchenId'] ?? 0,
      orderId: json['order_id'] ?? json['orderId'],
      title: json['title'],
      status: _parseStatus(json['status']),
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      lastMessagePreview: json['last_message_preview'] ?? json['lastMessagePreview'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : json['lastMessageAt'] != null
              ? DateTime.parse(json['lastMessageAt'])
              : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static ConversationStatus _parseStatus(dynamic status) {
    if (status == null) return ConversationStatus.active;
    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'ARCHIVED':
        return ConversationStatus.archived;
      case 'CLOSED':
        return ConversationStatus.closed;
      default:
        return ConversationStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'customer_id': customerId,
      'kitchen_id': kitchenId,
      'order_id': orderId,
      'title': title,
      'status': status.name.toUpperCase(),
      'unread_count': unreadCount,
      'last_message_preview': lastMessagePreview,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    int? conversationId,
    int? customerId,
    int? kitchenId,
    int? orderId,
    String? title,
    ConversationStatus? status,
    int? unreadCount,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
      kitchenId: kitchenId ?? this.kitchenId,
      orderId: orderId ?? this.orderId,
      title: title ?? this.title,
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        customerId,
        kitchenId,
        orderId,
        title,
        status,
        unreadCount,
        lastMessagePreview,
        lastMessageAt,
        createdAt,
        updatedAt,
      ];
}

