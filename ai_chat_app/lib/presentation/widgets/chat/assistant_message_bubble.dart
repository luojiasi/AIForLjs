import 'package:flutter/material.dart';
import 'package:ai_chat_app/domain/entities/message.dart';
import 'package:ai_chat_app/presentation/widgets/chat/rendered_markdown.dart';

class AssistantMessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const AssistantMessageBubble({
    super.key,
    required this.message,
    required this.isStreaming,
  });

  @override
  Widget build(BuildContext context) {
    if (message.errorMessage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('错误: ${message.errorMessage}'),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8, right: 60),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: message.content.isEmpty
          ? const SizedBox(width: 24, height: 16, child: _LoadingDots())
          : RenderedMarkdown(
              content: message.content,
              isStreaming: isStreaming,
            ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dots = '.' * ((_controller.value * 3).floor() + 1);
        return Text(dots, style: Theme.of(context).textTheme.bodyLarge);
      },
    );
  }
}
