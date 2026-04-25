import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_chat_app/presentation/providers/chat_provider.dart';
import 'package:ai_chat_app/presentation/widgets/sidebar/conversation_tile.dart';
import 'package:ai_chat_app/data/datasources/remote/model_provider_registry.dart';
import 'package:ai_chat_app/di/providers.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final registry = ref.watch(modelProviderRegistryProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
          child: Row(
            children: [
              Expanded(child: Text('AI Chat', style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
                tooltip: '设置',
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showNewChatDialog(context, ref, registry),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新对话'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: state.conversations.isEmpty
              ? Center(
                  child: Text('暂无对话', style: Theme.of(context).textTheme.bodySmall),
                )
              : ListView.builder(
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = state.conversations[index];
                    return ConversationTile(
                      conversation: conv,
                      isSelected: conv.id == state.currentConversationId,
                      onTap: () {
                        ref.read(chatProvider.notifier).selectConversation(conv.id);
                        if (MediaQuery.of(context).size.width <= 768) {
                          Navigator.of(context).pop(); // close drawer on mobile
                        }
                      },
                      onDelete: () => ref.read(chatProvider.notifier).deleteConversation(conv.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showNewChatDialog(BuildContext context, WidgetRef ref, ModelProviderRegistry registry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择模型'),
        content: SizedBox(
          width: 300,
          child: ListView(
            shrinkWrap: true,
            children: registry.allAdapters.expand((adapter) {
              return adapter.supportedModels.map((model) => ListTile(
                    title: Text(model.displayName),
                    subtitle: Text(adapter.providerName),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(chatProvider.notifier).createNewChat(model, adapter);
                    },
                  ));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
