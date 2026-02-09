import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../../../core/services/storage_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isKitchen = StorageService.getUserRole() == 'KITCHEN';
        final otherParty = isKitchen
            ? 'Customer #${conversation.customerId}'
            : 'Kitchen #${conversation.kitchenId}';

        return InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isKitchen
                      ? Colors.blue.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    isKitchen ? Icons.person : Icons.restaurant,
                    color: isKitchen ? Colors.blue : Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title ?? 'Conversation #${conversation.conversationId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.lastMessageAt != null)
                            Text(
                              _formatTime(conversation.lastMessageAt!),
                              style: TextStyle(
                                fontSize: 12,
                                color: conversation.unreadCount > 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // Other party
                      Text(
                        otherParty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Preview row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessagePreview ?? 'No messages yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (conversation.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1 || (difference.inHours < 48 && dateTime.day != now.day)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return timeago.format(dateTime, locale: 'en_short');
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

