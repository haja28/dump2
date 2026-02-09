import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';

class ChatService {
  static const String apiBasePath = '/api/v1';

  static Dio? _chatDio;

  static Dio get dio {
    if (_chatDio == null) {
      _chatDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.chatServiceUrl + apiBasePath,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _chatDio!.interceptors.add(_ChatAuthInterceptor());
    }
    return _chatDio!;
  }

  // =====================
  // Conversation Endpoints
  // =====================

  /// Create a new conversation
  static Future<Conversation> createConversation({
    required int kitchenId,
    int? orderId,
    String? title,
  }) async {
    final response = await dio.post(
      '/conversations',
      data: {
        'kitchen_id': kitchenId,
        if (orderId != null) 'order_id': orderId,
        if (title != null) 'title': title,
      },
    );

    if (response.data['success'] == true) {
      return Conversation.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create conversation');
  }

  /// Get customer conversations with pagination
  static Future<List<Conversation>> getCustomerConversations({
    int page = 0,
    int size = 20,
  }) async {
    final response = await dio.get(
      '/conversations/customer',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List;
      return content.map((json) => Conversation.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load conversations');
  }

  /// Get kitchen conversations with pagination
  static Future<List<Conversation>> getKitchenConversations({
    int page = 0,
    int size = 20,
  }) async {
    final response = await dio.get(
      '/conversations/kitchen',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List;
      return content.map((json) => Conversation.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load conversations');
  }

  /// Get conversation by ID
  static Future<Conversation> getConversation(int conversationId) async {
    final response = await dio.get('/conversations/$conversationId');

    if (response.data['success'] == true) {
      return Conversation.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to load conversation');
  }

  /// Archive a conversation
  static Future<void> archiveConversation(int conversationId) async {
    final response = await dio.post('/conversations/$conversationId/archive');

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to archive conversation');
    }
  }

  /// Get unread count
  static Future<int> getUnreadCount() async {
    final response = await dio.get('/conversations/unread/count');

    if (response.data['success'] == true) {
      return response.data['data'] ?? 0;
    }
    return 0;
  }

  // =====================
  // Message Endpoints
  // =====================

  /// Get messages for a conversation with pagination
  static Future<List<Message>> getMessages({
    required int conversationId,
    int page = 0,
    int size = 50,
  }) async {
    final response = await dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      List messagesList;

      if (data is Map && data['content'] != null) {
        messagesList = data['content'] as List;
      } else if (data is List) {
        messagesList = data;
      } else {
        messagesList = [];
      }

      return messagesList.map((json) => Message.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load messages');
  }

  /// Get all messages for a conversation (no pagination)
  static Future<List<Message>> getAllMessages(int conversationId) async {
    final response = await dio.get('/conversations/$conversationId/messages/all');

    if (response.data['success'] == true) {
      final data = response.data['data'];
      List messagesList;

      if (data is Map && data['content'] != null) {
        messagesList = data['content'] as List;
      } else if (data is List) {
        messagesList = data;
      } else {
        messagesList = [];
      }

      return messagesList.map((json) => Message.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load messages');
  }

  /// Send a message
  static Future<Message> sendMessage({
    required int conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    final response = await dio.post(
      '/conversations/$conversationId/messages',
      data: {
        'content': content,
        'message_type': messageType.name.toUpperCase(),
      },
    );

    if (response.data['success'] == true) {
      return Message.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to send message');
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead(int conversationId) async {
    final response = await dio.put('/conversations/$conversationId/messages/read');

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to mark messages as read');
    }
  }

  /// Edit a message
  static Future<Message> editMessage({
    required int conversationId,
    required int messageId,
    required String content,
  }) async {
    final response = await dio.patch(
      '/conversations/$conversationId/messages/$messageId',
      queryParameters: {'content': content},
    );

    if (response.data['success'] == true) {
      return Message.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to edit message');
  }

  /// Delete a message
  static Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
    bool forEveryone = false,
  }) async {
    final response = await dio.delete(
      '/conversations/$conversationId/messages/$messageId',
      queryParameters: {'forEveryone': forEveryone},
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete message');
    }
  }

  /// Search messages in a conversation
  static Future<List<Message>> searchMessages({
    required int conversationId,
    required String query,
    int page = 0,
    int size = 20,
  }) async {
    final response = await dio.get(
      '/conversations/$conversationId/messages/search',
      queryParameters: {
        'query': query,
        'page': page,
        'size': size,
      },
    );

    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List;
      return content.map((json) => Message.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to search messages');
  }

  // =====================
  // Notification Endpoints
  // =====================

  /// Get notifications with pagination
  static Future<List<ChatNotification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.data['success'] == true) {
      final content = response.data['data']['content'] as List;
      return content.map((json) => ChatNotification.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load notifications');
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    final response = await dio.get('/notifications/unread/count');

    if (response.data['success'] == true) {
      return response.data['data'] ?? 0;
    }
    return 0;
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(int notificationId) async {
    await dio.put('/notifications/$notificationId/read');
  }

  /// Mark all notifications as read
  static Future<void> markAllNotificationsAsRead() async {
    await dio.put('/notifications/read-all');
  }
}

// Chat Auth Interceptor to add required headers
class _ChatAuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    final userId = await StorageService.getUserId();
    final userRole = await StorageService.getUserRole();
    final userData = StorageService.getUserData();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (userId != null) {
      options.headers['X-User-Id'] = userId.toString();
    }

    // Determine user type from role
    String userType = 'CUSTOMER';
    if (userRole != null) {
      userType = userRole.toUpperCase();
    } else if (userData != null && userData['role'] != null) {
      userType = userData['role'].toString().toUpperCase();
    }
    options.headers['X-User-Type'] = userType;

    // Add kitchen ID if user is kitchen staff
    if (userType == 'KITCHEN' && userData != null) {
      final kitchenId = userData['kitchenId'] ?? userData['kitchen_id'];
      if (kitchenId != null) {
        options.headers['X-Kitchen-Id'] = kitchenId.toString();
      }
    }

    handler.next(options);
  }
}

