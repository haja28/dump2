import 'message_model.dart';

enum WebSocketEventType {
  newMessage,
  messageRead,
  messageDelivered,
  typingStart,
  typingStop,
  conversationUpdated,
}

class WebSocketEvent {
  final WebSocketEventType eventType;
  final int? conversationId;
  final Message? message;
  final TypingIndicatorEvent? typingIndicator;
  final ReadReceipt? readReceipt;
  final dynamic data;

  WebSocketEvent({
    required this.eventType,
    this.conversationId,
    this.message,
    this.typingIndicator,
    this.readReceipt,
    this.data,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    final eventTypeStr = (json['event_type'] ?? json['eventType'] ?? '').toString().toUpperCase();

    return WebSocketEvent(
      eventType: _parseEventType(eventTypeStr),
      conversationId: json['conversation_id'] ?? json['conversationId'],
      message: json['message'] != null ? Message.fromJson(json['message']) : null,
      typingIndicator: json['typing_indicator'] != null
          ? TypingIndicatorEvent.fromJson(json['typing_indicator'])
          : null,
      readReceipt: json['read_receipt'] != null
          ? ReadReceipt.fromJson(json['read_receipt'])
          : null,
      data: json,
    );
  }

  static WebSocketEventType _parseEventType(String type) {
    switch (type) {
      case 'NEW_MESSAGE':
        return WebSocketEventType.newMessage;
      case 'MESSAGE_READ':
        return WebSocketEventType.messageRead;
      case 'MESSAGE_DELIVERED':
        return WebSocketEventType.messageDelivered;
      case 'TYPING_START':
        return WebSocketEventType.typingStart;
      case 'TYPING_STOP':
        return WebSocketEventType.typingStop;
      case 'CONVERSATION_UPDATED':
        return WebSocketEventType.conversationUpdated;
      default:
        return WebSocketEventType.newMessage;
    }
  }
}

class TypingIndicatorEvent {
  final int conversationId;
  final int userId;
  final String? userName;
  final bool isTyping;

  TypingIndicatorEvent({
    required this.conversationId,
    required this.userId,
    this.userName,
    required this.isTyping,
  });

  factory TypingIndicatorEvent.fromJson(Map<String, dynamic> json) {
    return TypingIndicatorEvent(
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      userName: json['user_name'] ?? json['userName'],
      isTyping: json['is_typing'] ?? json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'user_name': userName,
      'is_typing': isTyping,
    };
  }
}

class ReadReceipt {
  final int conversationId;
  final int readerId;
  final DateTime readAt;
  final int messageCount;

  ReadReceipt({
    required this.conversationId,
    required this.readerId,
    required this.readAt,
    this.messageCount = 0,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? 0,
      readerId: json['reader_id'] ?? json['readerId'] ?? 0,
      readAt: DateTime.parse(
          json['read_at'] ?? json['readAt'] ?? DateTime.now().toIso8601String()),
      messageCount: json['message_count'] ?? json['messageCount'] ?? 0,
    );
  }
}

