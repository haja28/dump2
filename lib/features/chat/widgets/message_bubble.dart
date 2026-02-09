import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showSenderName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isSystem = message.senderType == SenderType.system;
    final isSent = message.isOwnMessage;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageMenu(context),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
            minWidth: 80,
          ),
          margin: EdgeInsets.only(
            left: isSent ? 50 : 8,
            right: isSent ? 8 : 50,
            top: 2,
            bottom: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSent
                ? const Color(0xFFDCF8C6) // WhatsApp green
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isSent ? 12 : 0),
              bottomRight: Radius.circular(isSent ? 0 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name
              if (showSenderName && !isSent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _getSenderName(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: message.senderType == SenderType.kitchen
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),

              // Message content
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.3,
                ),
              ),

              // Edited label
              if (message.isEdited)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'edited',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // Footer: time and status
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    message.formattedTime ?? _formatTime(message.sentAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  if (isSent) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Colors.brown.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey.shade500;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey.shade500;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  String _getSenderName() {
    switch (message.senderType) {
      case SenderType.customer:
        return '👤 Customer #${message.senderId}';
      case SenderType.kitchen:
        return '👨‍🍳 Kitchen #${message.senderId}';
      case SenderType.system:
        return '🔔 System';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return timeago.format(dateTime);
    }
  }

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              if (message.isOwnMessage && _canEdit()) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit?.call();
                  },
                ),
              ],
              if (message.isOwnMessage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  bool _canEdit() {
    // Can only edit within 15 minutes
    final difference = DateTime.now().difference(message.sentAt);
    return difference.inMinutes < 15;
  }
}

