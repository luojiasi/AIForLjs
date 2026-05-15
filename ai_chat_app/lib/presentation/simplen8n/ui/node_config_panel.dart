import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/node_type.dart';
import '../models/workflow_model.dart';

/// Right sidebar — frosted glass panel for editing selected node parameters.
class NodeConfigPanel extends StatefulWidget {
  final WorkflowNode? node;
  final NodeTypeDefinition? nodeType;
  final void Function(String nodeId, String key, dynamic value) onUpdateParameter;
  final void Function(String nodeId, String name) onUpdateName;
  final VoidCallback? onClose;

  const NodeConfigPanel({
    super.key,
    required this.node,
    required this.nodeType,
    required this.onUpdateParameter,
    required this.onUpdateName,
    this.onClose,
  });

  @override
  State<NodeConfigPanel> createState() => _NodeConfigPanelState();
}

class _NodeConfigPanelState extends State<NodeConfigPanel> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  final Map<String, TextEditingController> _paramControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.node?.name ?? '');
    _notesController = TextEditingController(text: widget.node?.notes ?? '');
  }

  @override
  void didUpdateWidget(NodeConfigPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node?.id != widget.node?.id) {
      _nameController.text = widget.node?.name ?? '';
      _notesController.text = widget.node?.notes ?? '';
      _paramControllers.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
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

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: cs.surface.withAlpha(210),
            border: Border(
              left: BorderSide(color: cs.outlineVariant.withAlpha(30), width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(node, nodeType, cs),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    _buildNameField(node, cs),
                    const SizedBox(height: 24),
                    _buildParametersSection(node, nodeType, cs),
                    const SizedBox(height: 24),
                    _buildNotesField(node, cs),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: cs.surface.withAlpha(210),
            border: Border(
              left: BorderSide(color: cs.outlineVariant.withAlpha(30), width: 0.5),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary.withAlpha(20), cs.primary.withAlpha(6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.touch_app_outlined, size: 26, color: cs.primary.withAlpha(90)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppLocalizations.of(context)!.simplen8nSelectNode,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withAlpha(130),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.simplen8nSelectNodeHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurface.withAlpha(70),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WorkflowNode node, NodeTypeDefinition? nodeType, ColorScheme cs) {
    final color = nodeType?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(25), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(30), color.withAlpha(8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(nodeType?.icon ?? Icons.help_outline, size: 20, color: color.withAlpha(220)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nodeType?.displayName ?? node.type,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  node.id,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'SF Mono, monospace',
                    color: cs.onSurface.withAlpha(50),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: cs.onSurface.withAlpha(8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.close_rounded, size: 15, color: cs.onSurface.withAlpha(110)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Sections ----

  Widget _buildNameField(WorkflowNode node, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context)!.simplen8nNodeName, cs),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
          cursorHeight: 17,
          decoration: _inputDecoration(AppLocalizations.of(context)!.simplen8nEnterNodeName, cs),
          onChanged: (v) => widget.onUpdateName(node.id, v),
        ),
      ],
    );
  }

  Widget _buildNotesField(WorkflowNode node, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context)!.simplen8nNotes, cs),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          minLines: 1,
          style: TextStyle(fontSize: 12.5, color: cs.onSurface),
          cursorHeight: 16,
          decoration: _inputDecoration(AppLocalizations.of(context)!.simplen8nAddNotes, cs).copyWith(
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (v) => widget.onUpdateParameter(node.id, '_notes', v),
        ),
      ],
    );
  }

  Widget _buildParametersSection(WorkflowNode node, NodeTypeDefinition? nodeType, ColorScheme cs) {
    final schemas = nodeType?.parameterSchema ?? [];

    if (schemas.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(AppLocalizations.of(context)!.simplen8nParameters, cs),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context)!.simplen8nNoParameters,
              style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(70)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context)!.simplen8nParameters, cs),
        const SizedBox(height: 14),
        ...schemas.map((schema) => _buildParameterField(node, schema, cs)),
      ],
    );
  }

  Widget _sectionLabel(String text, ColorScheme cs) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: cs.onSurface.withAlpha(100),
        letterSpacing: 0.6,
      ),
    );
  }

  // ---- Parameter fields ----

  Widget _buildParameterField(WorkflowNode node, ParameterSchema schema, ColorScheme cs) {
    final currentValue = node.parameters[schema.name] ?? schema.defaultValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                schema.displayName,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withAlpha(200),
                  letterSpacing: -0.1,
                ),
              ),
              if (schema.required)
                Text(' *', style: TextStyle(fontSize: 12.5, color: cs.error, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (schema.type == ParameterType.expression)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAF52DE).withAlpha(15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.simplen8nExpression,
                    style: TextStyle(fontSize: 9, fontFamily: 'SF Mono, monospace', fontWeight: FontWeight.w700, color: const Color(0xFFAF52DE).withAlpha(220)),
                  ),
                ),
            ],
          ),
          if (schema.description != null) ...[
            const SizedBox(height: 3),
            Text(
              schema.description!,
              style: TextStyle(fontSize: 10.5, color: cs.onSurface.withAlpha(70), height: 1.3),
            ),
          ],
          const SizedBox(height: 8),
          _buildParameterInput(node, schema, currentValue, cs),
        ],
      ),
    );
  }

  Widget _buildParameterInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
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

  InputDecoration _inputDecoration(String hint, ColorScheme cs) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(60), fontWeight: FontWeight.w400),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withAlpha(60),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: cs.primary.withAlpha(80), width: 1),
      ),
    );
  }

  Widget _buildStringInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
      cursorHeight: 17,
      decoration: _inputDecoration(schema.defaultValue?.toString() ?? AppLocalizations.of(context)!.simplen8nEnterValue, cs),
      onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
    );
  }

  Widget _buildMultilineInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      maxLines: 5,
      minLines: 2,
      style: TextStyle(fontSize: 12, color: cs.onSurface, fontFamily: 'SF Mono, monospace', height: 1.5),
      cursorHeight: 16,
      decoration: _inputDecoration(schema.defaultValue?.toString() ?? AppLocalizations.of(context)!.simplen8nEnterValue, cs).copyWith(
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
    );
  }

  Widget _buildSelectInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
    final items = (schema.options ?? [])
        .map((opt) => DropdownMenuItem(
              value: opt.value,
              child: Text(opt.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(11),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: currentValue?.toString() ?? schema.defaultValue?.toString(),
          isExpanded: true,
          icon: Icon(Icons.unfold_more_rounded, size: 17, color: cs.onSurface.withAlpha(80)),
          style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 3),
          ),
          items: items,
          onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
        ),
      ),
    );
  }

  Widget _buildNumberInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
    final controller = _paramControllers.putIfAbsent(
      schema.name,
      () => TextEditingController(text: currentValue?.toString() ?? ''),
    );
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
      cursorHeight: 17,
      decoration: _inputDecoration(schema.defaultValue?.toString() ?? '0', cs),
      onChanged: (v) {
        final parsed = double.tryParse(v) ?? int.tryParse(v) ?? v;
        widget.onUpdateParameter(node.id, schema.name, parsed);
      },
    );
  }

  Widget _buildBooleanInput(WorkflowNode node, ParameterSchema schema, dynamic currentValue, ColorScheme cs) {
    final value = currentValue == true || currentValue == 'true';
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(11),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          value ? AppLocalizations.of(context)!.simplen8nEnabled : AppLocalizations.of(context)!.simplen8nDisabled,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: value ? cs.primary : cs.onSurface.withAlpha(110),
          ),
        ),
        value: value,
        dense: true,
        visualDensity: VisualDensity.compact,
        activeTrackColor: cs.primary.withAlpha(80),
        activeThumbColor: cs.primary,
        inactiveThumbColor: cs.onSurface.withAlpha(40),
        inactiveTrackColor: cs.surfaceContainerHighest.withAlpha(40),
        onChanged: (v) => widget.onUpdateParameter(node.id, schema.name, v),
      ),
    );
  }
}
