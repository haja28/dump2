# Chat Feature Documentation

## Overview

This module implements a real-time chat service between customers and kitchens in the Makan For You app. It uses WebSocket (STOMP over SockJS) for real-time communication and REST APIs for persistence.

## Setup

### 1. Install Dependencies

Run the following command to install the required packages:

```bash
flutter pub get
```

### 2. Configuration

Update the chat service URLs in `lib/core/config/app_config.dart`:

```dart
static const String chatServiceUrl = 'http://YOUR_SERVER_IP:8086';
static const String chatWsUrl = 'http://YOUR_SERVER_IP:8086/ws/chat';
```

### 3. Backend Requirements

Ensure the chat-service backend is running and accessible. The service should expose:

- **REST API**: `http://localhost:8086/api/v1/`
- **WebSocket**: `http://localhost:8086/ws/chat`

## Architecture

```
lib/features/chat/
├── models/
│   ├── conversation_model.dart    # Conversation entity
│   ├── message_model.dart         # Message entity
│   ├── notification_model.dart    # Notification entity
│   └── websocket_event_model.dart # WebSocket event types
├── services/
│   ├── chat_service.dart          # REST API service
│   └── chat_websocket_service.dart # WebSocket service
├── providers/
│   └── chat_provider.dart         # State management
├── screens/
│   ├── conversations_screen.dart  # List of conversations
│   └── chat_screen.dart           # Chat messages view
├── widgets/
│   ├── conversation_list_item.dart
│   ├── message_bubble.dart
│   ├── chat_input.dart
│   └── typing_indicator.dart
└── chat.dart                      # Barrel export file
```

## Features

### Core Chat Features
- ✅ Send text messages (REST + WebSocket fallback)
- ✅ Receive messages in real-time (WebSocket)
- ✅ Create conversations
- ✅ List conversations with pagination
- ✅ View conversation messages with pagination
- ✅ Message status tracking (sent, delivered, read)
- ✅ Mark messages as read
- ✅ Unread count badge
- ✅ Typing indicators
- ✅ Date/time formatting
- ✅ Search messages in conversation
- ✅ Edit messages (within 15 min)
- ✅ Delete messages (for self/everyone)

### WebSocket Features
- ✅ Auto-reconnect on connection loss
- ✅ Connection status indicator
- ✅ Subscribe to conversation updates
- ✅ Subscribe to notifications
- ✅ Handle connection state (connecting, connected, disconnected, reconnecting)

### UI Features
- ✅ WhatsApp-style conversation list
- ✅ WhatsApp-style message bubbles
- ✅ Pull-to-refresh conversations
- ✅ Swipe to archive conversation
- ✅ Empty states with illustrations
- ✅ Quick reply buttons
- ✅ Date separators in chat

## API Endpoints

### REST APIs

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/conversations` | Create new conversation |
| GET | `/api/v1/conversations/customer` | List customer conversations |
| GET | `/api/v1/conversations/kitchen` | List kitchen conversations |
| GET | `/api/v1/conversations/{id}/messages` | Get conversation messages |
| GET | `/api/v1/conversations/{id}/messages/all` | Get all messages (no pagination) |
| POST | `/api/v1/conversations/{id}/messages` | Send message |
| PUT | `/api/v1/conversations/{id}/messages/read` | Mark messages as read |
| PATCH | `/api/v1/conversations/{id}/messages/{msgId}` | Edit message |
| DELETE | `/api/v1/conversations/{id}/messages/{msgId}` | Delete message |
| GET | `/api/v1/conversations/{id}/messages/search` | Search messages |
| GET | `/api/v1/conversations/unread/count` | Get unread count |
| POST | `/api/v1/conversations/{id}/archive` | Archive conversation |
| GET | `/api/v1/notifications` | Get notifications |

### WebSocket Endpoints

| Type | Destination | Description |
|------|-------------|-------------|
| Subscribe | `/topic/conversations/{id}` | Receive real-time messages |
| Subscribe | `/user/{userType}/{userId}/queue/notifications` | Receive notifications |
| Send | `/app/chat/{id}/send` | Send message via WebSocket |
| Send | `/app/chat/{id}/typing` | Send typing indicator |

### Required Headers

```
X-User-Id: Current user ID
X-User-Type: CUSTOMER or KITCHEN
X-Kitchen-Id: Kitchen ID (if applicable)
Authorization: Bearer {token}
```

## Usage

### Navigate to Conversations

```dart
// Using GoRouter
context.push('/conversations');

// Or using Navigator
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ConversationsScreen()),
);
```

### Open Chat from Order Details

```dart
// Create or get existing conversation
final chatProvider = context.read<ChatProvider>();
final conversation = await chatProvider.createConversation(
  kitchenId: order.kitchenId,
  orderId: order.id,
  title: 'Order #${order.id}',
);

if (conversation != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        conversationId: conversation.conversationId,
        title: conversation.title ?? 'Chat',
      ),
    ),
  );
}
```

### Access Chat Provider

```dart
// Get unread count
final unreadCount = context.watch<ChatProvider>().unreadCount;

// Check connection state
final isConnected = context.watch<ChatProvider>().isConnected;

// Connect to WebSocket
await context.read<ChatProvider>().connect();

// Send message
await context.read<ChatProvider>().sendMessage('Hello!');
```

## WebSocket Events

| Event Type | Description |
|------------|-------------|
| `NEW_MESSAGE` | New message received |
| `MESSAGE_READ` | Messages marked as read |
| `MESSAGE_DELIVERED` | Messages delivered |
| `TYPING_START` | User started typing |
| `TYPING_STOP` | User stopped typing |
| `CONVERSATION_UPDATED` | Conversation metadata changed |

## Message DTO Structure

```json
{
  "message_id": 123,
  "conversation_id": 1,
  "sender_id": 1,
  "sender_type": "CUSTOMER",
  "content": "Hello!",
  "message_type": "TEXT",
  "status": "DELIVERED",
  "sent_at": "2026-02-08T10:30:00Z",
  "edited_at": null,
  "is_own_message": true,
  "formatted_time": "10:30 AM"
}
```

## Testing

To test the chat feature:

1. Start the chat-service backend
2. Open the app and log in as a customer
3. Navigate to the Conversations screen
4. Create a new conversation with a kitchen
5. Send messages and verify real-time delivery

You can also use the test HTML client at `reference/test-chat-updated.html` for testing the backend APIs and WebSocket.

## Troubleshooting

### WebSocket Connection Issues
- Ensure the backend is running and accessible
- Check firewall settings
- Verify the WebSocket URL is correct

### Messages Not Sending
- Check network connectivity
- Verify authentication headers are set correctly
- Check backend logs for errors

### Real-time Updates Not Working
- Ensure WebSocket is connected (check connection status indicator)
- Verify conversation subscription is active

