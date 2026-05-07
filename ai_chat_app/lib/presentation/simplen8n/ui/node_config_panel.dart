import 'package:flutter/material.dart';

import '../models/node_type.dart';
import '../models/workflow_model.dart';

/// 右侧节点配置面板 — 编辑选中节点的参数
class NodeConfigPanel extends StatefulWidget {
  final WorkflowNode? node;
  final NodeTypeDefinition? nodeType;
  final void Function(String nodeId, String key, dynamic value) onUpdateParameter;
  final void Function(String nodeId, String name) onUpdateName;

  const NodeConfigPanel({
    super.key,
    required this.node,
    required this.nodeType,
    required this.onUpdateParameter,
    required this.onUpdateName,
  });

  @override
  State<NodeConfigPanel> createState() => _NodeConfigPanelState();
}

class _NodeConfigPanelState extends State<NodeConfigPanel> {
  late TextEditingController _nameController;
  final Map<String, TextEditingController> _paramControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.node?.name ?? '');
  }

  @override
  void didUpdateWidget(NodeConfigPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node?.id != widget.node?.id) {
      _nameController.text = widget.node?.name ?? '';
      _paramControllers.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final node = widget.node;

    if (node == null) {
      return _buildEmptyState(cs);
    }

    final nodeType = widget.nodeType;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(left: BorderSide(color: cs.outlineVariant.withAlpha(80))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(node, nodeType, cs),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNameField(node, cs),
                const SizedBox(height: 22),
                _buildParametersSection(node, nodeType, cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(left: BorderSide(color: cs.outlineVariant.withAlpha(80))),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.touch_app_outlined, size: 24,
                    color: cs.primary.withAlpha(100)),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a node',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withAlpha(140),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Click any node on the canvas\nto configure its parameters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withAlpha(80),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      WorkflowNode node, NodeTypeDefinition? nodeType, ColorScheme cs) {
    final color = nodeType?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(80))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(nodeType?.icon ?? Icons.help, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nodeType?.displayName ?? node.type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  node.id,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    color: cs.onSurface.withAlpha(60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(WorkflowNode node, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Node Name', cs),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: TextStyle(fontSize: 13, color: cs.onSurface),
          cursorHeight: 16,
          decoration: InputDecoration(
            hintText: 'Enter node name…',
            hintStyle: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(70)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withAlpha(80),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.primary.withAlpha(100)),
            ),
          ),
          onChanged: (v) => widget.onUpdateName(node.id, v),
        ),
      ],
    );
  }

  Widget _buildParametersSection(
      WorkflowNode node, NodeTypeDefinition? nodeType, ColorScheme cs) {
    final schemas = nodeType?.parameterSchema ?? [];

    if (schemas.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Parameters', cs),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'No configurable parameters',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withAlpha(80),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Parameters', cs),
        const SizedBox(height: 12),
        ...schemas.map((schema) => _buildParameterField(node, schema, cs)),
      ],
    );
  }

  Widget _sectionLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurface.withAlpha(110),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildParameterField(
      WorkflowNode node, ParameterSchema schema, ColorScheme cs) {
    final currentValue = node.parameters[schema.name] ?? schema.defaultValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                schema.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withAlpha(190),
                ),
              ),
              if (schema.required)
                Text(' *', style: TextStyle(fontSize: 12, color: cs.error)),
              const Spacer(),
              if (schema.type == ParameterType.expression)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'expr',
                    style: TextStyle(fontSize: 9, fontFamily: 'monospace',
                        color: Colors.purple.shade300),
                  ),
                ),
            ],
          ),
          if (schema.description != null) ...[
            const SizedBox(height: 2),
            Text(
              schema.description!,
              style: TextStyle(
                fontSize: 10.5,
                color: cs.onSurface.withAlpha(80),
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 6),
          _buildParameterInput(node, schema, currentValue, cs),
        ],
      ),
    );
  }

  Widget _buildParameterInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    switch (schema.type) {
      case ParameterType.select:
        return _buildSelectInput(node, schema, currentValue, cs);
      case ParameterType.multiline:
      case ParameterType.json:
      case ParameterType.code:
        return _buildMultilineInput(node, schema, currentValue, cs);
      case ParameterType.number:
        return _buildNumberInput(node, schema, currentValue, cs);
      case ParameterType.boolean:
        return _buildBooleanInput(node, schema, currentValue, cs);
      default:
        return _buildStringInput(node, schema, currentValue, cs);
    }
  }

  // ---- Shared field decoration ----

  InputDecoration _fieldDecoration(String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(70)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withAlpha(80),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary.withAlpha(100)),
      ),
    );
  }

  Widget _buildStringInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 13, color: cs.onSurface),
      cursorHeight: 16,
      decoration: _fieldDecoration(schema.defaultValue?.toString() ?? 'Enter value…'),
      onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
    );
  }

  Widget _buildMultilineInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      maxLines: 5,
      minLines: 2,
      style: TextStyle(fontSize: 12, color: cs.onSurface, fontFamily: 'monospace'),
      cursorHeight: 16,
      decoration: _fieldDecoration(schema.defaultValue?.toString() ?? 'Enter value…')
          .copyWith(contentPadding: const EdgeInsets.all(10)),
      onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
    );
  }

  Widget _buildSelectInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    final items = (schema.options ?? [])
        .map((opt) => DropdownMenuItem(
              value: opt.value,
              child: Text(opt.label, style: const TextStyle(fontSize: 13)),
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue:
              currentValue?.toString() ?? schema.defaultValue?.toString(),
          isExpanded: true,
          icon: Icon(Icons.unfold_more, size: 16,
              color: cs.onSurface.withAlpha(100)),
          style: TextStyle(fontSize: 13, color: cs.onSurface),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 2),
          ),
          items: items,
          onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
        ),
      ),
    );
  }

  Widget _buildNumberInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13, color: cs.onSurface),
      cursorHeight: 16,
      decoration: _fieldDecoration(schema.defaultValue?.toString() ?? '0'),
      onChanged: (v) {
        final parsed = double.tryParse(v) ?? int.tryParse(v) ?? v;
        widget.onUpdateParameter(node.id, schema.name, parsed);
      },
    );
  }

  Widget _buildBooleanInput(WorkflowNode node, ParameterSchema schema,
      dynamic currentValue, ColorScheme cs) {
    final value = currentValue == true || currentValue == 'true';
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          value ? 'Enabled' : 'Disabled',
          style: TextStyle(
            fontSize: 12,
            color: value ? cs.primary : cs.onSurface.withAlpha(120),
          ),
        ),
        value: value,
        dense: true,
        visualDensity: VisualDensity.compact,
        activeColor: cs.primary,
        onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
      ),
    );
  }
}
