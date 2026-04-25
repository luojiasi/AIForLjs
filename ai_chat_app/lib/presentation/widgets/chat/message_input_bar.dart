import 'package:flutter/material.dart';

class MessageInputBar extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onSend;
  final VoidCallback onCancel;

  const MessageInputBar({
    super.key,
    required this.isLoading,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 5,
              minLines: 1,
              enabled: !widget.isLoading,
              decoration: const InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: widget.isLoading
                ? IconButton.filled(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.stop),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  )
                : IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
          ),
        ],
      ),
    );
  }
}
