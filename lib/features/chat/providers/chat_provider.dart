import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/websocket_event_model.dart';
import '../services/chat_service.dart';
import '../services/chat_websocket_service.dart';

class ChatProvider with ChangeNotifier {
  // Services
  final ChatWebSocketService _wsService = ChatWebSocketService();

  // State
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  List<ChatNotification> _notifications = [];
  Conversation? _currentConversation;
  int _unreadCount = 0;
  int _unreadNotificationCount = 0;
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;
  String? _typingUser;
  Timer? _typingTimer;

  // Subscriptions
  StreamSubscription<ChatConnectionState>? _connectionSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _eventSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _notificationSubscription;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  List<ChatNotification> get notifications => _notifications;
  Conversation? get currentConversation => _currentConversation;
  int get unreadCount => _unreadCount;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get typingUser => _typingUser;
  ChatConnectionState get connectionState => _wsService.connectionState;
  bool get isConnected => _wsService.isConnected;
  Stream<ChatConnectionState> get connectionStateStream => _wsService.connectionStateStream;

  ChatProvider() {
    _initWebSocketListeners();
  }

  void _initWebSocketListeners() {
    _connectionSubscription = _wsService.connectionStateStream.listen((state) {
      notifyListeners();

      if (state == ChatConnectionState.connected) {
        // Re-subscribe to current conversation if any
        if (_currentConversation != null) {
          _wsService.subscribeToConversation(_currentConversation!.conversationId);
        }
      }
    });

    _messageSubscription = _wsService.messageStream.listen((message) {
      if (_currentConversation != null &&
          message.conversationId == _currentConversation!.conversationId) {
        // Check if message already exists to avoid duplicates
        if (!_messages.any((m) => m.messageId == message.messageId)) {
          _messages.add(message);
          notifyListeners();
        }
      }
      // Refresh conversations to update last message preview
      loadConversations();
    });

    _eventSubscription = _wsService.eventStream.listen((event) {
      _handleWebSocketEvent(event);
    });

    _typingSubscription = _wsService.typingStream.listen((indicator) {
      if (_currentConversation != null &&
          indicator.conversationId == _currentConversation!.conversationId) {
        if (indicator.isTyping) {
          _typingUser = indicator.userName ?? 'Someone';
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 3), () {
            _typingUser = null;
            notifyListeners();
          });
        } else {
          _typingUser = null;
        }
        notifyListeners();
      }
    });

    _notificationSubscription = _wsService.notificationStream.listen((data) {
      // Handle incoming notification
      loadUnreadCounts();
    });
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    switch (event.eventType) {
      case WebSocketEventType.messageRead:
        // Update message statuses to read
        _updateMessageStatuses(MessageStatus.read);
        break;
      case WebSocketEventType.messageDelivered:
        _updateMessageStatuses(MessageStatus.delivered);
        break;
      case WebSocketEventType.conversationUpdated:
        loadConversations();
        break;
      default:
        break;
    }
  }

  void _updateMessageStatuses(MessageStatus status) {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].isOwnMessage && _messages[i].status != MessageStatus.read) {
        _messages[i] = _messages[i].copyWith(status: status);
      }
    }
    notifyListeners();
  }

  // =====================
  // WebSocket Operations
  // =====================

  /// Connect to WebSocket
  Future<void> connect() async {
    await _wsService.connect();
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _wsService.disconnect();
  }

  // =====================
  // Conversation Operations
  // =====================

  /// Load conversations based on user type
  Future<void> loadConversations({bool isKitchen = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (isKitchen) {
        _conversations = await ChatService.getKitchenConversations();
      } else {
        _conversations = await ChatService.getCustomerConversations();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new conversation
  Future<Conversation?> createConversation({
    required int kitchenId,
    int? orderId,
    String? title,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final conversation = await ChatService.createConversation(
        kitchenId: kitchenId,
        orderId: orderId,
        title: title,
      );

      _conversations.insert(0, conversation);
      _isLoading = false;
      notifyListeners();

      return conversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Select and open a conversation
  Future<void> selectConversation(Conversation conversation) async {
    _currentConversation = conversation;
    _messages = [];
    notifyListeners();

    // Subscribe to WebSocket for this conversation
    if (_wsService.isConnected) {
      _wsService.subscribeToConversation(conversation.conversationId);
    }

    // Load messages
    await loadMessages();

    // Mark messages as read
    await markMessagesAsRead();
  }

  /// Clear current conversation selection
  void clearConversation() {
    if (_currentConversation != null) {
      _wsService.unsubscribeFromConversation(_currentConversation!.conversationId);
    }
    _currentConversation = null;
    _messages = [];
    _typingUser = null;
    notifyListeners();
  }

  /// Archive a conversation
  Future<void> archiveConversation(int conversationId) async {
    try {
      await ChatService.archiveConversation(conversationId);
      _conversations.removeWhere((c) => c.conversationId == conversationId);

      if (_currentConversation?.conversationId == conversationId) {
        clearConversation();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // =====================
  // Message Operations
  // =====================

  /// Load messages for current conversation
  Future<void> loadMessages({bool loadAll = true}) async {
    if (_currentConversation == null) return;

    try {
      _isLoadingMessages = true;
      notifyListeners();

      if (loadAll) {
        _messages = await ChatService.getAllMessages(_currentConversation!.conversationId);
      } else {
        _messages = await ChatService.getMessages(
          conversationId: _currentConversation!.conversationId,
        );
      }

      _isLoadingMessages = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Send a message
  Future<bool> sendMessage(String content) async {
    if (_currentConversation == null || content.trim().isEmpty) return false;

    try {
      _isSending = true;
      notifyListeners();

      // Try WebSocket first
      if (_wsService.isConnected) {
        _wsService.sendMessage(
          conversationId: _currentConversation!.conversationId,
          content: content,
        );
        _isSending = false;
        notifyListeners();
        return true;
      }

      // Fallback to REST API
      final message = await ChatService.sendMessage(
        conversationId: _currentConversation!.conversationId,
        content: content,
      );

      // Add message to list if not already present
      if (!_messages.any((m) => m.messageId == message.messageId)) {
        _messages.add(message);
      }

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead() async {
    if (_currentConversation == null) return;

    try {
      await ChatService.markMessagesAsRead(_currentConversation!.conversationId);

      // Update local conversation unread count
      final index = _conversations.indexWhere(
        (c) => c.conversationId == _currentConversation!.conversationId,
      );
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }

      loadUnreadCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark messages as read: $e');
    }
  }

  /// Edit a message
  Future<bool> editMessage(int messageId, String newContent) async {
    if (_currentConversation == null) return false;

    try {
      final updatedMessage = await ChatService.editMessage(
        conversationId: _currentConversation!.conversationId,
        messageId: messageId,
        content: newContent,
      );

      final index = _messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(int messageId, {bool forEveryone = false}) async {
    if (_currentConversation == null) return false;

    try {
      await ChatService.deleteMessage(
        conversationId: _currentConversation!.conversationId,
        messageId: messageId,
        forEveryone: forEveryone,
      );

      _messages.removeWhere((m) => m.messageId == messageId);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Search messages
  Future<List<Message>> searchMessages(String query) async {
    if (_currentConversation == null) return [];

    try {
      return await ChatService.searchMessages(
        conversationId: _currentConversation!.conversationId,
        query: query,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_currentConversation == null || !_wsService.isConnected) return;

    _wsService.sendTypingIndicator(
      conversationId: _currentConversation!.conversationId,
      isTyping: isTyping,
    );
  }

  // =====================
  // Notification Operations
  // =====================

  /// Load notifications
  Future<void> loadNotifications() async {
    try {
      _notifications = await ChatService.getNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Load unread counts
  Future<void> loadUnreadCounts() async {
    try {
      _unreadCount = await ChatService.getUnreadCount();
      _unreadNotificationCount = await ChatService.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load unread counts: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await ChatService.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      loadUnreadCounts();
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      await ChatService.markAllNotificationsAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadNotificationCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  // =====================
  // Utility Methods
  // =====================

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh({bool isKitchen = false}) async {
    await Future.wait([
      loadConversations(isKitchen: isKitchen),
      loadUnreadCounts(),
    ]);
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _messageSubscription?.cancel();
    _eventSubscription?.cancel();
    _typingSubscription?.cancel();
    _notificationSubscription?.cancel();
    _typingTimer?.cancel();
    _wsService.dispose();
    super.dispose();
  }
}

