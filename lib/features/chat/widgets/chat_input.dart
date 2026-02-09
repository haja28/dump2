import 'dart:async';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onTyping;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onTyping,
    this.isSending = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    // Send typing indicator
    _typingTimer?.cancel();
    widget.onTyping?.call();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      // Typing stopped
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button (optional)
            // IconButton(
            //   icon: const Icon(Icons.attach_file),
            //   onPressed: () {},
            //   color: Colors.grey.shade600,
            // ),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // Emoji button (optional)
                    // IconButton(
                    //   icon: const Icon(Icons.emoji_emotions_outlined),
                    //   onPressed: () {},
                    //   color: Colors.grey.shade600,
                    // ),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _hasText
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _hasText ? _send : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: widget.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

