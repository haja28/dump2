import 'package:equatable/equatable.dart';

enum SenderType { customer, kitchen, system }
enum MessageType { text, image, file, system }
enum MessageStatus { sent, delivered, read }

class Message extends Equatable {
  final int messageId;
  final int conversationId;
  final int senderId;
  final SenderType senderType;
  final String content;
  final MessageType messageType;
  final MessageStatus status;
  final DateTime sentAt;
  final DateTime? editedAt;
  final bool isOwnMessage;
  final String? formattedTime;
  final bool isDeleted;

  const Message({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sent,
    required this.sentAt,
    this.editedAt,
    this.isOwnMessage = false,
    this.formattedTime,
    this.isDeleted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] ?? json['messageId'] ?? json['id'] ?? 0,
      conversationId:
          json['conversation_id'] ?? json['conversationId'] ?? 0,
      senderId: json['sender_id'] ?? json['senderId'] ?? 0,
      senderType: _parseSenderType(json['sender_type'] ?? json['senderType']),
      content: json['content'] ?? '',
      messageType:
          _parseMessageType(json['message_type'] ?? json['messageType']),
      status: _parseStatus(json['status']),
      sentAt: DateTime.parse(
          json['sent_at'] ?? json['sentAt'] ?? DateTime.now().toIso8601String()),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : json['editedAt'] != null
              ? DateTime.parse(json['editedAt'])
              : null,
      isOwnMessage: json['is_own_message'] ?? json['isOwnMessage'] ?? false,
      formattedTime: json['formatted_time'] ?? json['formattedTime'],
      isDeleted: json['is_deleted'] ?? json['isDeleted'] ?? false,
    );
  }

  static SenderType _parseSenderType(dynamic type) {
    if (type == null) return SenderType.customer;

    String typeStr;
    if (type is Map) {
      typeStr = (type['name'] ?? type.toString()).toString().toUpperCase();
    } else {
      typeStr = type.toString().toUpperCase();
    }

    switch (typeStr) {
      case 'KITCHEN':
        return SenderType.kitchen;
      case 'SYSTEM':
        return SenderType.system;
      default:
        return SenderType.customer;
    }
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;

    String typeStr;
    if (type is Map) {
      typeStr = (type['name'] ?? type.toString()).toString().toUpperCase();
    } else {
      typeStr = type.toString().toUpperCase();
    }

    switch (typeStr) {
      case 'IMAGE':
        return MessageType.image;
      case 'FILE':
        return MessageType.file;
      case 'SYSTEM':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseStatus(dynamic status) {
    if (status == null) return MessageStatus.sent;

    String statusStr;
    if (status is Map) {
      statusStr = (status['name'] ?? status.toString()).toString().toUpperCase();
    } else {
      statusStr = status.toString().toUpperCase();
    }

    switch (statusStr) {
      case 'DELIVERED':
        return MessageStatus.delivered;
      case 'READ':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType.name.toUpperCase(),
      'content': content,
      'message_type': messageType.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'sent_at': sentAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_own_message': isOwnMessage,
      'formatted_time': formattedTime,
      'is_deleted': isDeleted,
    };
  }

  Message copyWith({
    int? messageId,
    int? conversationId,
    int? senderId,
    SenderType? senderType,
    String? content,
    MessageType? messageType,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? editedAt,
    bool? isOwnMessage,
    String? formattedTime,
    bool? isDeleted,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      isOwnMessage: isOwnMessage ?? this.isOwnMessage,
      formattedTime: formattedTime ?? this.formattedTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isEdited => editedAt != null;

  String get senderTypeString => senderType.name.toUpperCase();

  @override
  List<Object?> get props => [
        messageId,
        conversationId,
        senderId,
        senderType,
        content,
        messageType,
        status,
        sentAt,
        editedAt,
        isOwnMessage,
        formattedTime,
        isDeleted,
      ];
}

