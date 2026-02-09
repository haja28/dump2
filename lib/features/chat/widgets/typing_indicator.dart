import 'package:flutter/material.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final String? userName;

  const TypingIndicatorWidget({
    super.key,
    this.userName,
  });

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animation = Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              delay,
                              delay + 0.4,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Transform.translate(
                            offset: Offset(0, -4 * animation.value),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          if (widget.userName != null) ...[
            const SizedBox(width: 8),
            Text(
              '${widget.userName} is typing...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ConnectionStatusBanner extends StatelessWidget {
  final bool isConnected;
  final bool isReconnecting;
  final VoidCallback? onRetry;

  const ConnectionStatusBanner({
    super.key,
    required this.isConnected,
    this.isReconnecting = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isReconnecting ? Colors.orange : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isReconnecting) ...[
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
              'No connection',
              style: TextStyle(color: Colors.white),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class QuickReplyButtons extends StatelessWidget {
  final List<QuickReply> replies;
  final Function(String) onReply;

  const QuickReplyButtons({
    super.key,
    required this.replies,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: replies.map((reply) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onReply(reply.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (reply.emoji != null) ...[
                          Text(reply.emoji!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          reply.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class QuickReply {
  final String label;
  final String text;
  final String? emoji;

  const QuickReply({
    required this.label,
    required this.text,
    this.emoji,
  });
}

// Default quick replies for kitchen
const List<QuickReply> kitchenQuickReplies = [
  QuickReply(label: 'Hello!', text: 'Hello! How can I help you?', emoji: '👋'),
  QuickReply(label: 'Preparing', text: 'Your order is being prepared.', emoji: '🍳'),
  QuickReply(label: 'Ready', text: 'Your order is ready for pickup!', emoji: '✅'),
  QuickReply(label: 'Thanks', text: 'Thank you for your order!', emoji: '🙏'),
];

// Default quick replies for customer
const List<QuickReply> customerQuickReplies = [
  QuickReply(label: 'Question', text: 'I have a question about my order.', emoji: '❓'),
  QuickReply(label: 'Thanks', text: 'Thank you!', emoji: '🙏'),
  QuickReply(label: 'ETA', text: 'What is the estimated time?', emoji: '⏰'),
];

