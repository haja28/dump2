import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/storage_service.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../services/chat_websocket_service.dart' show ChatConnectionState;
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String title;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isKitchen = false;
  bool _showQuickReplies = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final role = await StorageService.getUserRole();
    setState(() {
      _isKitchen = role == 'KITCHEN';
    });

    final chatProvider = context.read<ChatProvider>();

    // Find and select the conversation
    final conversations = chatProvider.conversations;
    final conversation = conversations.firstWhere(
      (c) => c.conversationId == widget.conversationId,
      orElse: () => conversations.first,
    );

    await chatProvider.selectConversation(conversation);

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<ChatProvider>().clearConversation();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content) async {
    final success = await context.read<ChatProvider>().sendMessage(content);
    if (success) {
      _scrollToBottom();
    }
  }

  void _onTyping() {
    context.read<ChatProvider>().sendTypingIndicator(true);
  }

  void _editMessage(Message message) {
    final controller = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter new message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ChatProvider>().editMessage(
                  message.messageId,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('How do you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().deleteMessage(
                message.messageId,
                forEveryone: false,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete for me'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().deleteMessage(
                message.messageId,
                forEveryone: true,
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete for everyone'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    List<Message> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Search Messages'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (controller.text.trim().isNotEmpty) {
                            final results = await this.context
                                .read<ChatProvider>()
                                .searchMessages(controller.text.trim());
                            setState(() {
                              searchResults = results;
                            });
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) async {
                      if (value.trim().isNotEmpty) {
                        final results = await this.context
                            .read<ChatProvider>()
                            .searchMessages(value.trim());
                        setState(() {
                          searchResults = results;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (searchResults.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final message = searchResults[index];
                          return ListTile(
                            title: Text(
                              message.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              message.formattedTime ??
                                DateFormat('MMM d, h:mm a').format(message.sentAt),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Scroll to message
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No results'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.typingUser != null) {
                  return Text(
                    '${provider.typingUser} is typing...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.green,
                    ),
                  );
                }
                return Text(
                  provider.isConnected ? 'Online' : 'Connecting...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: provider.isConnected ? Colors.green : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<ChatProvider>().loadMessages();
                  break;
                case 'mark_read':
                  context.read<ChatProvider>().markMessagesAsRead();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE5DDD5),
          image: DecorationImage(
            image: AssetImage('assets/images/chat_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            // Connection status banner
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final state = provider.connectionState;
                if (state == ChatConnectionState.connected) {
                  return const SizedBox.shrink();
                }
                return ConnectionStatusBanner(
                  isConnected: false,
                  isReconnecting: state == ChatConnectionState.reconnecting,
                  onRetry: () => provider.connect(),
                );
              },
            ),

            // Messages list
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingMessages && provider.messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group messages by date
                  final groupedMessages = _groupMessagesByDate(provider.messages);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      final item = groupedMessages[index];

                      if (item is String) {
                        // Date separator
                        return _buildDateSeparator(item);
                      }

                      final message = item as Message;
                      return MessageBubble(
                        message: message,
                        showSenderName: !message.isOwnMessage,
                        onEdit: () => _editMessage(message),
                        onDelete: () => _deleteMessage(message),
                      );
                    },
                  );
                },
              ),
            ),

            // Typing indicator
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.typingUser != null) {
                  return TypingIndicatorWidget(userName: provider.typingUser);
                }
                return const SizedBox.shrink();
              },
            ),

            // Quick replies
            if (_showQuickReplies)
              QuickReplyButtons(
                replies: _isKitchen ? kitchenQuickReplies : customerQuickReplies,
                onReply: _sendMessage,
              ),

            // Chat input
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                return ChatInput(
                  onSend: _sendMessage,
                  onTyping: _onTyping,
                  isSending: provider.isSending,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _groupMessagesByDate(List<Message> messages) {
    final List<dynamic> grouped = [];
    String? lastDate;

    for (final message in messages) {
      final dateStr = _formatDateHeader(message.sentAt);

      if (dateStr != lastDate) {
        grouped.add(dateStr);
        lastDate = dateStr;
      }

      grouped.add(message);
    }

    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F3FB).withAlpha(230),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

