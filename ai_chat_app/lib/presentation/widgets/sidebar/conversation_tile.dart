import 'package:flutter/material.dart';
import 'package:ai_chat_app/domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
      title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(conversation.modelName, style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
        onSelected: (v) {
          if (v == 'delete') onDelete();
        },
      ),
    );
  }
}
