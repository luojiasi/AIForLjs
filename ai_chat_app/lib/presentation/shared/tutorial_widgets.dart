import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================
/// 教程通用组件库 v2.0
/// 提供静态展示组件 + 完整的交互式演示组件体系
/// ============================================================

// ─────────────────────────────────────────────────────────────
// 静态展示组件
// ─────────────────────────────────────────────────────────────

/// 代码块组件 —— 带背景色和复制按钮的代码展示
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFEAEAEA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // 红绿黄三个圆点
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                const SizedBox(width: 10),
                if (language != null)
                  Text(language!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const Spacer(),
                // 复制按钮
                _CopyButton(code: code),
              ],
            ),
          ),
          // 代码内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final String code;
  const _CopyButton({required this.code});
  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.code));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _copied
            ? const Icon(Icons.check, size: 16, color: Colors.green, key: ValueKey('check'))
            : Icon(Icons.copy, size: 16, color: Colors.grey[500], key: const ValueKey('copy')),
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
            child: SelectableText(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
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
      child: SelectableText(
        text,
        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.7),
      ),
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

// ─────────────────────────────────────────────────────────────
// 交互式演示组件体系
// ─────────────────────────────────────────────────────────────

/// 交互式演示容器 —— 统一包装所有互动演示模块
class InteractivePlayground extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const InteractivePlayground({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(fontSize: 12, color: cs.primary.withOpacity(0.7)),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('实时演示', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // 内容区
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// 实时输出框 —— 绿字终端风格，与参数同步更新
class LiveOutputBox extends StatelessWidget {
  final String output;
  final String label;

  const LiveOutputBox(this.output, {super.key, this.label = '▶ 实时输出'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF27C93F), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            output,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF79C0FF), height: 1.6),
          ),
        ],
      ),
    );
  }
}

/// 实时代码块 —— 显示带动态值的代码，突出显示变化部分
class LiveCodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const LiveCodeBlock(this.code, {super.key, this.language});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.6,
            color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF1E1E1E),
          ),
        ),
      ),
    );
  }
}

/// 滑块参数控件 —— double 值
class ParamSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? displayValue;

  const ParamSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    final display = displayValue != null ? displayValue!(value) : value.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// 整数滑块参数控件
class ParamIntSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? unit;

  const ParamIntSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return ParamSlider(
      label: label,
      value: value.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: max - min,
      onChanged: (v) => onChanged(v.round()),
      displayValue: (v) => '${v.round()}${unit ?? ''}',
    );
  }
}

/// 下拉选择控件
class ParamDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const ParamDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  items: items,
                  onChanged: onChanged,
                  isExpanded: true,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 文本输入控件
class ParamTextField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int? maxLength;

  const ParamTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: onChanged,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 开关控件
class ParamSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? trueLabel;
  final String? falseLabel;

  const ParamSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trueLabel,
    this.falseLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (falseLabel != null)
            Text(
              falseLabel!,
              style: TextStyle(fontSize: 12, color: value ? Colors.grey : Theme.of(context).colorScheme.primary),
            ),
          Switch(value: value, onChanged: onChanged),
          if (trueLabel != null)
            Text(
              trueLabel!,
              style: TextStyle(fontSize: 12, color: value ? Theme.of(context).colorScheme.primary : Colors.grey),
            ),
        ],
      ),
    );
  }
}

/// 选项组控件 —— ChoiceChip 形式
class ParamChoiceChips<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  const ParamChoiceChips({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((opt) {
                final isSelected = opt.$1 == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(opt.$2, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (_) => onChanged(opt.$1),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 对比展示组件 —— 左右两侧对比代码
class CompareBox extends StatelessWidget {
  final String leftTitle;
  final String leftCode;
  final String rightTitle;
  final String rightCode;
  final Color? leftColor;
  final Color? rightColor;

  const CompareBox({
    super.key,
    required this.leftTitle,
    required this.leftCode,
    required this.rightTitle,
    required this.rightCode,
    this.leftColor,
    this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12,
      height: 1.5,
      color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF1E1E1E),
    );

    Widget side(String title, String code, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ]),
              const SizedBox(height: 8),
              SelectableText(code, style: codeStyle),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          side(leftTitle, leftCode, leftColor ?? Colors.red),
          const SizedBox(width: 8),
          side(rightTitle, rightCode, rightColor ?? Colors.green),
        ],
      ),
    );
  }
}

/// 知识点卡片
class KnowledgeCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? color;

  const KnowledgeCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon ?? Icons.info_outline, size: 20, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 进度步骤条 —— 展示流程
class ProgressSteps extends StatelessWidget {
  final List<String> steps;
  final int activeStep;

  const ProgressSteps({super.key, required this.steps, this.activeStep = -1});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == activeStep;
          final isDone = i < activeStep;
          final color = isActive ? primary : (isDone ? Colors.green : Colors.grey[400]!);
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone ? Colors.green : (isActive ? primary : Colors.grey[200]!),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey[500])),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(steps[i], style: TextStyle(fontSize: 10, color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Container(width: 24, height: 2, color: i < activeStep ? Colors.green : Colors.grey[300]),
              ],
            ),
          );
        }),
      ),
    );
  }
}
