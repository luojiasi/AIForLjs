import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'agent_architectures_data.dart';
import 'agent_architectures_full_detail.dart';

class AgentArchitecturesFullDetailPage extends StatelessWidget {
  final AgentArchitecture arch;

  const AgentArchitecturesFullDetailPage({super.key, required this.arch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullContent = architectureFullDetails[arch.id] ?? arch.detailedContent;

    return Scaffold(
      appBar: AppBar(
        title: Text('${arch.name} — 完整详解'),
        backgroundColor: arch.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: '查看摘要',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Markdown(
        data: fullContent,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: arch.color,
          ),
          h2: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: arch.color.withValues(alpha: 0.85),
          ),
          h3: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          p: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            backgroundColor: Color(0xFFF5F5F5),
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          blockquoteDecoration: BoxDecoration(
            color: arch.color.withValues(alpha: 0.05),
            border: Border(left: BorderSide(color: arch.color, width: 3)),
          ),
          tableBorder: TableBorder.all(color: Colors.grey.shade300),
          tableHead: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
