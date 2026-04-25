import 'package:flutter/material.dart';
import 'package:ai_chat_app/domain/entities/message.dart';
import 'package:ai_chat_app/presentation/widgets/chat/user_message_bubble.dart';
import 'package:ai_chat_app/presentation/widgets/chat/assistant_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<Message> messages;
  final String streamingMessageId;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.streamingMessageId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isStreaming = msg.id == streamingMessageId;

        switch (msg.role) {
          case 'user':
            return UserMessageBubble(message: msg);
          case 'assistant':
            if (msg.content.isEmpty && !isStreaming && msg.errorMessage == null) {
              return const SizedBox.shrink();
            }
            return AssistantMessageBubble(message: msg, isStreaming: isStreaming);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
