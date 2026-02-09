import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../models/message_model.dart';
import '../models/websocket_event_model.dart';

enum ChatConnectionState { disconnected, connecting, connected, reconnecting }

class ChatWebSocketService {
  static String get wsUrl => AppConfig.chatWsUrl;

  StompClient? _stompClient;
  ChatConnectionState _connectionState = ChatConnectionState.disconnected;

  // Stream controllers
  final _connectionStateController = StreamController<ChatConnectionState>.broadcast();
  final _messageController = StreamController<Message>.broadcast();
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  final _typingController = StreamController<TypingIndicatorEvent>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  // Subscriptions map to track active subscriptions
  final Map<int, StompUnsubscribe?> _conversationSubscriptions = {};
  StompUnsubscribe? _notificationSubscription;

  // Auto-reconnect settings
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  Timer? _reconnectTimer;

  // User info
  int? _userId;
  String? _userType;

  // Getters for streams
  Stream<ChatConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<Message> get messageStream => _messageController.stream;
  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  Stream<TypingIndicatorEvent> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  ChatConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == ChatConnectionState.connected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_connectionState == ChatConnectionState.connected ||
        _connectionState == ChatConnectionState.connecting) {
      return;
    }

    _setConnectionState(ChatConnectionState.connecting);

    try {
      // Get user info
      _userId = StorageService.getUserId();
      _userType = StorageService.getUserRole() ?? 'CUSTOMER';

      final token = await StorageService.getAccessToken();

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: wsUrl,
          stompConnectHeaders: {
            'Authorization': token != null ? 'Bearer $token' : '',
            'X-User-Id': _userId?.toString() ?? '',
            'X-User-Type': _userType ?? 'CUSTOMER',
          },
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          onDebugMessage: (msg) {
            if (kDebugMode) {
              // print('STOMP Debug: $msg');
            }
          },
          reconnectDelay: reconnectDelay,
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      debugPrint('WebSocket connect error: $e');
      _setConnectionState(ChatConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;

    // Unsubscribe from all conversations
    for (var unsub in _conversationSubscriptions.values) {
      unsub?.call();
    }
    _conversationSubscriptions.clear();
    _notificationSubscription?.call();
    _notificationSubscription = null;

    _stompClient?.deactivate();
    _stompClient = null;
    _setConnectionState(ChatConnectionState.disconnected);
  }

  /// Subscribe to a conversation to receive real-time messages
  void subscribeToConversation(int conversationId) {
    if (!isConnected || _stompClient == null) {
      debugPrint('Cannot subscribe: not connected');
      return;
    }

    // Unsubscribe from previous subscription if exists
    _conversationSubscriptions[conversationId]?.call();

    final subscription = _stompClient!.subscribe(
      destination: '/topic/conversations/$conversationId',
      callback: (frame) {
        _handleConversationMessage(frame);
      },
    );

    _conversationSubscriptions[conversationId] = subscription;
    debugPrint('Subscribed to conversation $conversationId');
  }

  /// Unsubscribe from a conversation
  void unsubscribeFromConversation(int conversationId) {
    _conversationSubscriptions[conversationId]?.call();
    _conversationSubscriptions.remove(conversationId);
    debugPrint('Unsubscribed from conversation $conversationId');
  }

  /// Send a message via WebSocket
  void sendMessage({
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  }) {
    if (!isConnected || _stompClient == null) {
      throw Exception('Not connected to WebSocket');
    }

    _stompClient!.send(
      destination: '/app/chat/$conversationId/send',
      headers: {
        'userId': _userId?.toString() ?? '',
        'userType': _userType ?? 'CUSTOMER',
      },
      body: jsonEncode({
        'content': content,
        'message_type': messageType,
      }),
    );
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required int conversationId,
    required bool isTyping,
  }) {
    if (!isConnected || _stompClient == null) {
      return;
    }

    _stompClient!.send(
      destination: '/app/chat/$conversationId/typing',
      body: jsonEncode({
        'conversation_id': conversationId,
        'user_id': _userId,
        'user_name': 'User $_userId',
        'is_typing': isTyping,
      }),
    );
  }

  // =====================
  // Private Methods
  // =====================

  void _setConnectionState(ChatConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _onConnect(StompFrame frame) {
    debugPrint('WebSocket connected');
    _setConnectionState(ChatConnectionState.connected);
    _reconnectAttempts = 0;

    // Subscribe to user notifications
    _subscribeToNotifications();
  }

  void _onDisconnect(StompFrame frame) {
    debugPrint('WebSocket disconnected');
    _setConnectionState(ChatConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onStompError(StompFrame frame) {
    debugPrint('STOMP Error: ${frame.body}');
    _setConnectionState(ChatConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _setConnectionState(ChatConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay * (_reconnectAttempts + 1), () {
      _reconnectAttempts++;
      _setConnectionState(ChatConnectionState.reconnecting);
      connect();
    });
  }

  void _subscribeToNotifications() {
    if (_stompClient == null || _userId == null) return;

    final userTypeLower = _userType?.toLowerCase() ?? 'customer';

    _notificationSubscription = _stompClient!.subscribe(
      destination: '/user/$userTypeLower/$_userId/queue/notifications',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final notification = jsonDecode(frame.body!);
            _notificationController.add(notification);
          } catch (e) {
            debugPrint('Failed to parse notification: $e');
          }
        }
      },
    );

    debugPrint('Subscribed to notifications for $userTypeLower/$_userId');
  }

  void _handleConversationMessage(StompFrame frame) {
    if (frame.body == null) return;

    try {
      final data = jsonDecode(frame.body!);
      final event = WebSocketEvent.fromJson(data);

      _eventController.add(event);

      switch (event.eventType) {
        case WebSocketEventType.newMessage:
          if (event.message != null) {
            _messageController.add(event.message!);
          }
          break;
        case WebSocketEventType.typingStart:
        case WebSocketEventType.typingStop:
          if (event.typingIndicator != null) {
            _typingController.add(event.typingIndicator!);
          }
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Failed to parse WebSocket message: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _messageController.close();
    _eventController.close();
    _typingController.close();
    _notificationController.close();
  }
}
