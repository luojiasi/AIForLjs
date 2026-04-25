import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/presentation/providers/chat_provider.dart';
import 'package:ai_chat_app/di/providers.dart';

/// Model switcher chip shown in AppBar.
class ModelSwitcherChip extends ConsumerWidget {
  final String conversationId;

  const ModelSwitcherChip({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(modelProviderRegistryProvider);

    return PopupMenuButton<({String providerId, String modelId})>(
      icon: const Icon(Icons.smart_toy_outlined),
      tooltip: '切换模型',
      itemBuilder: (context) {
        final items = <PopupMenuEntry<({String providerId, String modelId})>>[];
        for (final adapter in registry.allAdapters) {
          items.add(PopupMenuItem(
            enabled: false,
            child: Text(adapter.providerName,
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ));
          for (final model in adapter.supportedModels) {
            items.add(PopupMenuItem(
              value: (providerId: adapter.providerId, modelId: model.id),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(model.displayName),
              ),
            ));
          }
        }
        return items;
      },
    );
  }

  /// Dialog for creating a new chat with model selection.
  static Widget newChat() {
    return Consumer(
      builder: (context, ref, child) {
        final registry = ref.watch(modelProviderRegistryProvider);
        return AlertDialog(
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
                        Navigator.of(context).pop();
                        ref.read(chatProvider.notifier).createNewChat(model, adapter);
                      },
                    ));
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
