import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/storage_service.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_list_item.dart';
import '../services/chat_websocket_service.dart' show ChatConnectionState;
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _isKitchen = false;

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
    await chatProvider.connect();
    await chatProvider.loadConversations(isKitchen: _isKitchen);
    await chatProvider.loadUnreadCounts();
  }

  Future<void> _refresh() async {
    await context.read<ChatProvider>().refresh(isKitchen: _isKitchen);
  }

  void _createNewConversation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateConversationSheet(
        isKitchen: _isKitchen,
        onCreated: (conversation) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: conversation.conversationId,
                title: conversation.title ?? 'Chat',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: provider.unreadNotificationCount > 0,
                  label: Text(provider.unreadNotificationCount.toString()),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => _showNotifications(context),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              final state = provider.connectionState;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: state != ChatConnectionState.connected ? 40 : 0,
                child: state != ChatConnectionState.connected
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: state == ChatConnectionState.reconnecting
                            ? Colors.orange
                            : Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state == ChatConnectionState.reconnecting) ...[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Reconnecting...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ] else ...[
                              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Connecting...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),

          // Conversations list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.conversations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null && provider.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load conversations',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isKitchen
                              ? 'Customers will message you here'
                              : 'Start a conversation with a kitchen',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (!_isKitchen) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _createNewConversation,
                            icon: const Icon(Icons.add),
                            label: const Text('New Chat'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: provider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = provider.conversations[index];
                      return Dismissible(
                        key: Key('conv_${conversation.conversationId}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.archive,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _confirmArchive(context);
                        },
                        onDismissed: (direction) {
                          provider.archiveConversation(conversation.conversationId);
                        },
                        child: ConversationListItem(
                          conversation: conversation,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: conversation.conversationId,
                                  title: conversation.title ?? 'Chat',
                                ),
                              ),
                            );
                          },
                          onLongPress: () => _showConversationOptions(
                            context,
                            conversation.conversationId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !_isKitchen
          ? FloatingActionButton(
              onPressed: _createNewConversation,
              child: const Icon(Icons.message),
            )
          : null,
    );
  }

  Future<bool> _confirmArchive(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Conversation'),
        content: const Text('Are you sure you want to archive this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Archive'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showConversationOptions(BuildContext context, int conversationId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatProvider>().archiveConversation(conversationId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => provider.markAllNotificationsAsRead(),
                            child: const Text('Mark all read'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: provider.notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No notifications',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: provider.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = provider.notifications[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: notification.isRead
                                        ? Colors.grey.shade200
                                        : Theme.of(context).primaryColor.withAlpha(26),
                                    child: Icon(
                                      Icons.notifications,
                                      color: notification.isRead
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(notification.body),
                                  trailing: Text(
                                    notification.formattedTime ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  onTap: () {
                                    provider.markNotificationAsRead(
                                      notification.notificationId,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateConversationSheet extends StatefulWidget {
  final bool isKitchen;
  final Function(dynamic) onCreated;

  const _CreateConversationSheet({
    required this.isKitchen,
    required this.onCreated,
  });

  @override
  State<_CreateConversationSheet> createState() => _CreateConversationSheetState();
}

class _CreateConversationSheetState extends State<_CreateConversationSheet> {
  final _kitchenIdController = TextEditingController(text: '1');
  final _orderIdController = TextEditingController();
  final _titleController = TextEditingController(text: 'New Chat');
  bool _isCreating = false;

  @override
  void dispose() {
    _kitchenIdController.dispose();
    _orderIdController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_isCreating) return;

    final kitchenId = int.tryParse(_kitchenIdController.text);
    if (kitchenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Kitchen ID')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final orderId = int.tryParse(_orderIdController.text);
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : null;

    final conversation = await context.read<ChatProvider>().createConversation(
      kitchenId: kitchenId,
      orderId: orderId,
      title: title,
    );

    setState(() => _isCreating = false);

    if (conversation != null) {
      widget.onCreated(conversation);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create conversation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'New Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _kitchenIdController,
              decoration: const InputDecoration(
                labelText: 'Kitchen ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'Order ID (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Chat Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _create,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Conversation'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

