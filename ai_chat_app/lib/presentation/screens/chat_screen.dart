import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/presentation/providers/chat_provider.dart';
import 'package:ai_chat_app/presentation/widgets/chat/chat_message_list.dart';
import 'package:ai_chat_app/presentation/widgets/chat/message_input_bar.dart';
import 'package:ai_chat_app/presentation/widgets/chat/model_switcher_chip.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(chatProvider.notifier);
      notifier.loadConversations();
      if (widget.conversationId != null) {
        notifier.selectConversation(widget.conversationId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(state.currentConversationId != null
                  ? state.conversations
                      .where((c) => c.id == state.currentConversationId)
                      .map((c) => c.title)
                      .firstOrNull ?? 'AI Chat'
                  : 'AI Chat'),
              actions: state.currentConversationId != null
                  ? [ModelSwitcherChip(conversationId: state.currentConversationId!)]
                  : null,
            ),
      body: Column(
        children: [
          if (state.currentConversationId == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 80, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('选择或创建一个对话开始', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showNewChatDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('新对话'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ChatMessageList(
                messages: state.messages,
                streamingMessageId: state.streamingMessageId,
              ),
            ),
          if (state.errorMessage != null)
            MaterialBanner(
              content: Text(state.errorMessage!),
              leading: const Icon(Icons.error),
              actions: [
                TextButton(
                  onPressed: () => ref.read(chatProvider.notifier).sendMessage(
                        state.messages.lastWhere((m) => m.role == 'user').content,
                      ),
                  child: const Text('重试'),
                ),
              ],
            ),
          if (state.currentConversationId != null)
            MessageInputBar(
              isLoading: state.isLoading,
              onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
              onCancel: () => ref.read(chatProvider.notifier).cancelStream(),
            ),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ModelSwitcherChip.newChat(),
    );
  }
}
