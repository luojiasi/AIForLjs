import 'package:flutter/material.dart';

/// ============================================================
/// 教程通用组件库
/// 提供 CodeBlock、SectionHeader、TipBox 等复用组件
/// 所有教程页面统一使用此组件库，保持风格一致
/// ============================================================

/// 代码块组件 —— 带背景色和行号效果的代码展示
class CodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const CodeBlock(this.code, {super.key, this.language});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null)
            Row(
              children: [
                Icon(Icons.code, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(language!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
              ],
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
                color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 章节标题组件
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader(this.title, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 提示框组件 —— 用于注意事项、提示、警告
class TipBox extends StatelessWidget {
  final String text;
  final TipType type;

  const TipBox(this.text, {super.key, this.type = TipType.info});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case TipType.warning:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case TipType.tip:
        icon = Icons.lightbulb_outline;
        color = Colors.blue;
        break;
      case TipType.caution:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case TipType.info:
        icon = Icons.info_outline;
        color = Colors.teal;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          ),
        ],
      ),
    );
  }
}

enum TipType { info, warning, tip, caution }

/// 步骤说明组件 —— 带编号的步骤
class StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String description;

  const StepItem({super.key, required this.step, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 正文段落组件
class Paragraph extends StatelessWidget {
  final String text;

  const Paragraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.7)),
    );
  }
}

/// 分隔线组件
class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey[200]),
    );
  }
}

/// 运行结果展示组件 —— 模拟终端/输出效果
class OutputBox extends StatelessWidget {
  final String output;

  const OutputBox(this.output, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('输出结果', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              output,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
