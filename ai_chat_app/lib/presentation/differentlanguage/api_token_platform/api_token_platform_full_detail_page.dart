import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'api_token_platform_data.dart';
import 'api_token_platform_full_detail.dart';

class ApiTokenPlatformFullDetailPage extends StatelessWidget {
  final ApiTokenPlatformTopic topic;

  const ApiTokenPlatformFullDetailPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final markdown = topicFullDetails[topic.id] ?? topic.detailedContent;

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.name} — 完整详解'),
        backgroundColor: topic.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '查看摘要',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Markdown(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(color: topic.color, fontWeight: FontWeight.bold, fontSize: 24),
          h2: TextStyle(color: topic.color.withValues(alpha: 0.85), fontWeight: FontWeight.bold, fontSize: 20),
          h3: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          p: const TextStyle(height: 1.8, fontSize: 15),
          code: const TextStyle(fontFamily: 'monospace', fontSize: 13, backgroundColor: Color(0xFFF5F5F5)),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: topic.color, width: 3)),
            color: topic.color.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}
