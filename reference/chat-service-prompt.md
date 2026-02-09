GitHub Copilot Pull Request Prompt for Flutter Chat Integration
I have a Flutter app that needs to integrate with the existing chat-service backend. I need you to create a pull request that adds a complete, production-ready chat feature to communicate between customers and kitchen staff.

Backend Information
Service URL: http://localhost:8086 (update for production)
WebSocket Endpoint: /ws/chat (uses SockJS + STOMP)
API Base: /api/v1
Authentication Headers Required:
X-User-Id: Current user ID
X-User-Type: Either CUSTOMER or KITCHEN
X-Kitchen-Id: Kitchen ID (if applicable)
API Endpoints to Integrate
REST APIs
POST /api/v1/conversations - Create new conversation
Body: {"kitchen_id": 1, "order_id": 123, "title": "Order #123"}
GET /api/v1/conversations/customer?page=0&size=20 - List customer conversations
GET /api/v1/conversations/kitchen?page=0&size=20 - List kitchen conversations
GET /api/v1/conversations/{id}/messages?page=0&size=50 - Get conversation messages
POST /api/v1/conversations/{id}/messages - Send message
Body: {"content": "Hello", "message_type": "TEXT"}
PUT /api/v1/conversations/{id}/messages/read - Mark messages as read
GET /api/v1/conversations/unread/count - Get unread count
GET /api/v1/notifications?page=0&size=20 - Get notifications
WebSocket (STOMP over SockJS)
Connect: /ws/chat
Subscribe: /topic/conversations/{conversationId} - Receive real-time messages
Subscribe: /user/{userType}/{userId}/queue/notifications - Receive notifications
Send: /app/chat/{conversationId}/send - Send message via WebSocket
Send: /app/chat/{conversationId}/typing - Send typing indicator
Message DTO Structure
JSON
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
WebSocket Event Types
NEW_MESSAGE - New message received
MESSAGE_READ - Messages marked as read
MESSAGE_DELIVERED - Messages delivered
TYPING_START - User started typing
TYPING_STOP - User stopped typing
CONVERSATION_UPDATED - Conversation metadata changed
Requirements
1. Project Structure
   Create a proper Flutter architecture:

Code
lib/
├── features/
│   └── chat/
│       ├── data/
│       │   ├── models/
│       │   │   ├── conversation_model.dart
│       │   │   ├── message_model.dart
│       │   │   └── notification_model.dart
│       │   ├── repositories/
│       │   │   └── chat_repository_impl.dart
│       │   └── datasources/
│       │       ├── chat_remote_datasource.dart
│       │       └── chat_websocket_datasource.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── conversation.dart
│       │   │   ├── message.dart
│       │   │   └── notification.dart
│       │   ├─��� repositories/
│       │   │   └── chat_repository.dart
│       │   └── usecases/
│       │       ├── send_message.dart
│       │       ├── get_conversations.dart
│       │       └── mark_as_read.dart
│       └── presentation/
│           ├── providers/
│           │   ├── chat_provider.dart
│           │   ├── conversation_provider.dart
│           │   └── websocket_provider.dart
│           ├── screens/
│           │   ├── conversations_screen.dart
│           │   ├── chat_screen.dart
│           │   └── notifications_screen.dart
│           └── widgets/
│               ├── conversation_list_item.dart
│               ├── message_bubble.dart
│               ├── chat_input.dart
│               ├── typing_indicator.dart
│               └── message_status_icon.dart
└── core/
├── network/
│   ├── api_client.dart
│   └── websocket_client.dart
└── utils/
├── date_formatter.dart
└── chat_constants.dart
2. Dependencies to Add
   Add these to pubspec.yaml:

YAML
dependencies:
# State Management
provider: ^6.1.1  # or riverpod/bloc

# Networking
http: ^1.1.0
dio: ^5.4.0  # Alternative to http

# WebSocket
stomp_dart_client: ^1.0.0
web_socket_channel: ^2.4.0

# JSON Serialization
json_annotation: ^4.8.1

# Time/Date
intl: ^0.18.1
timeago: ^3.6.0

# UI Components
cached_network_image: ^3.3.0
flutter_chat_ui: ^1.6.10  # Optional: Pre-built chat UI
image_picker: ^1.0.7  # For attachments

# Local Storage
shared_preferences: ^2.2.2

# Utils
uuid: ^4.3.3

dev_dependencies:
json_serializable: ^6.7.1
build_runner: ^2.4.8
3. UI Requirements
   Conversations List Screen
   WhatsApp-style conversation list
   Show: Avatar, name (Kitchen #X or Customer #Y), last message preview, timestamp, unread badge
   Pull-to-refresh
   Unread count badge on each conversation
   Search conversations
   Floating action button to start new chat (for customers)
   Empty state when no conversations
   Chat Screen
   WhatsApp/Telegram-style message bubbles:
   Sent messages: Right-aligned, green background (#DCF8C6)
   Received messages: Left-aligned, white background
   System messages: Center-aligned, yellow background
   Show sender name on received messages (for kitchen staff)
   Message status icons: ✓ (sent), ✓✓ (delivered), ✓✓ blue (read)
   Timestamp on each message
   Date separators ("Today", "Yesterday", "Jan 15")
   Typing indicator when other user is typing
   Chat input with send button
   Quick reply buttons at bottom
   Message long-press menu: Copy, Delete, Edit (if own message, within 15 min)
   Auto-scroll to bottom on new message
   Load more messages on scroll up
   Show "edited" label on edited messages
   Notifications Screen
   List of notifications with title, body, time
   Unread badge
   Mark all as read button
   Tap to navigate to related conversation
4. Features to Implement
   Core Chat Features
   ✅ Send text messages (REST + WebSocket fallback)
   ✅ Receive messages in real-time (WebSocket)
   ✅ Create conversations
   ✅ List conversations with pagination
   ✅ View conversation messages with pagination
   ✅ Message status tracking (sent, delivered, read)
   ✅ Mark messages as read
   ✅ Unread count badge
   ✅ Typing indicators
   ✅ Date/time formatting
   ✅ Search messages in conversation
   ✅ Edit messages (within 15 min)
   ✅ Delete messages (for self/everyone)

WebSocket Features
✅ Auto-reconnect on connection loss
✅ Connection status indicator
✅ Subscribe to conversation updates
✅ Subscribe to notifications
✅ Handle connection state (connecting, connected, disconnected)
✅ Show connection error with retry button

Polish Features
✅ Pull-to-refresh conversations
✅ Swipe to delete conversation (archive)
✅ Empty states with illustrations
✅ Loading skeletons
✅ Error handling with retry
✅ Offline message queue (send when back online)
✅ Local cache for conversations
✅ Background notifications (Firebase Cloud Messaging integration prep)

5. State Management Pattern
   Use Provider (or your preferred state management):

ChatProvider - Manages WebSocket connection, sends messages
ConversationProvider - Manages conversation list, unread counts
MessageProvider - Manages messages for current conversation
NotificationProvider - Manages notifications
6. User Type Detection
   The app should determine X-User-Type based on:

If user is logged in as customer → CUSTOMER
If user is logged in as kitchen staff → KITCHEN
Store this in shared preferences or state management.

7. Navigation
   Integrate chat into existing app navigation:

Add "Messages" tab/button in main navigation
Show unread badge on messages icon
Deep linking to specific conversations
Navigate to chat from order details page
8. Error Handling
   Network errors: Show retry button
   WebSocket disconnection: Show banner "Connecting..." with retry
   Message send failure: Show red icon, allow retry
   Empty states: Show friendly messages
   Permission errors: Show dialog
9. Testing Requirements
   Create widget tests for:

Message bubble rendering
Conversation list item
Chat input widget
Typing indicator
10. Documentation
    Include:

README_CHAT.md - How to use chat feature
Code comments for WebSocket handling
API integration guide
Example UI Behavior
Customer taps "Message Kitchen" from order details
App calls POST /api/v1/conversations with kitchen_id and order_id
Opens chat screen, connects WebSocket
Customer types → sends typing indicator via /app/chat/{id}/typing
Customer sends message → sends via WebSocket /app/chat/{id}/send
Kitchen receives real-time message on /topic/conversations/{id}
Kitchen's app shows notification
Kitchen opens chat → messages marked as read via PUT /api/v1/conversations/{id}/messages/read
Customer sees ✓✓ turn blue (read receipt via WebSocket event)
Design References
Match the style of WhatsApp or Telegram:

Clean, minimal design
Green accent color for sent messages
White/light gray for received messages
Rounded message bubbles
Clear typography
Smooth animations
Additional Notes
Handle both portrait and landscape orientations
Support dark mode (if app has it)
Implement haptic feedback on send
Add sound notification on new message (optional)
Prepare for push notifications (FCM setup for background messages)
Test on both Android and iOS
Expected Deliverables
✅ Complete chat feature with conversations list and chat screens
✅ WebSocket integration with auto-reconnect
✅ REST API integration for all endpoints
✅ State management with Provider
✅ WhatsApp-style UI matching design system
✅ Error handling and offline support
✅ Typing indicators and read receipts
✅ Message editing and deletion
✅ Unread count badges
✅ Pull-to-refresh
✅ Search functionality
✅ Unit tests for models and repositories
✅ Widget tests for UI components
✅ Documentation

