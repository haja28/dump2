import 'package:equatable/equatable.dart';

enum NotificationType {
  newMessage,
  orderUpdate,
  systemAlert,
  conversationUpdated,
}

class ChatNotification extends Equatable {
  final int notificationId;
  final int userId;
  final String userType;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? formattedTime;

  const ChatNotification({
    required this.notificationId,
    required this.userId,
    required this.userType,
    required this.title,
    required this.body,
    this.type = NotificationType.newMessage,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.formattedTime,
  });

  factory ChatNotification.fromJson(Map<String, dynamic> json) {
    return ChatNotification(
      notificationId: json['notification_id'] ?? json['notificationId'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      userType: json['user_type'] ?? json['userType'] ?? 'CUSTOMER',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseType(json['type']),
      data: json['data'],
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      formattedTime: json['formatted_time'] ?? json['formattedTime'],
    );
  }

  static NotificationType _parseType(dynamic type) {
    if (type == null) return NotificationType.newMessage;
    final typeStr = type.toString().toUpperCase();
    switch (typeStr) {
      case 'ORDER_UPDATE':
        return NotificationType.orderUpdate;
      case 'SYSTEM_ALERT':
        return NotificationType.systemAlert;
      case 'CONVERSATION_UPDATED':
        return NotificationType.conversationUpdated;
      default:
        return NotificationType.newMessage;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'user_type': userType,
      'title': title,
      'body': body,
      'type': type.name.toUpperCase(),
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'formatted_time': formattedTime,
    };
  }

  ChatNotification copyWith({
    int? notificationId,
    int? userId,
    String? userType,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    String? formattedTime,
  }) {
    return ChatNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      formattedTime: formattedTime ?? this.formattedTime,
    );
  }

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        userType,
        title,
        body,
        type,
        data,
        isRead,
        createdAt,
        formattedTime,
      ];
}

