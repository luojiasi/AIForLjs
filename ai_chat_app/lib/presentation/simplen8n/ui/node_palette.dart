import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/node_type.dart';

/// Left sidebar — frosted glass panel with searchable node list.
class NodePalette extends StatefulWidget {
  final List<NodeTypeDefinition> nodes;
  final void Function(NodeTypeDefinition nodeType) onAddNode;
  final VoidCallback? onClose;

  const NodePalette({
    super.key,
    required this.nodes,
    required this.onAddNode,
    this.onClose,
  });

  @override
  State<NodePalette> createState() => _NodePaletteState();
}

class _NodePaletteState extends State<NodePalette> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<NodeTypeDefinition> _filtered() {
    if (_query.isEmpty) return widget.nodes;
    final q = _query.toLowerCase();
    return widget.nodes
        .where((n) =>
            n.displayName.toLowerCase().contains(q) ||
            n.type.toLowerCase().contains(q) ||
            (n.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = NodeCategory.values;
    final filtered = _filtered();

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: 268,
          decoration: BoxDecoration(
            color: cs.surface.withAlpha(210),
            border: Border(
              right: BorderSide(color: cs.outlineVariant.withAlpha(30), width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cs, filtered.length),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptySearch(cs)
                    : _buildNodeList(categories, filtered, cs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(25), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary.withAlpha(25), cs.primary.withAlpha(8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.widgets_outlined, size: 17, color: cs.primary.withAlpha(200)),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.simplen8nNodesLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary.withAlpha(200)),
                ),
              ),
              if (widget.onClose != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withAlpha(8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(Icons.close_rounded, size: 14, color: cs.onSurface.withAlpha(100)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: TextStyle(fontSize: 12.5, color: cs.onSurface),
              cursorHeight: 15,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.simplen8nSearchNodes,
                hintStyle: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(70), fontWeight: FontWeight.w400),
                prefixIcon: Icon(Icons.search_rounded, size: 17, color: cs.onSurface.withAlpha(90)),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.close_rounded, size: 15, color: cs.onSurface.withAlpha(100)),
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(60),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                  borderSide: BorderSide(color: cs.primary.withAlpha(60), width: 1),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: cs.onSurface.withAlpha(50)),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.simplen8nNoNodesFound, style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(90))),
        ],
      ),
    );
  }

  Widget _buildNodeList(List<NodeCategory> categories, List<NodeTypeDefinition> filtered, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      children: categories
          .where((cat) => filtered.any((n) => n.category == cat))
          .expand((cat) {
        final catNodes = filtered.where((n) => n.category == cat).toList();
        return [
          _buildCategoryHeader(cat, cs),
          ...catNodes.map((nt) => _buildNodeCard(nt, cs)),
        ];
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(NodeCategory category, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: category.color.withAlpha(200),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: category.color.withAlpha(40), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withAlpha(120),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(NodeTypeDefinition nodeType, ColorScheme cs) {
    final color = nodeType.color;
    final hasInput = nodeType.inputs.isNotEmpty;
    final hasOutput = nodeType.outputs.isNotEmpty;

    final card = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onAddNode(nodeType),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: color.withAlpha(30), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withAlpha(25), color.withAlpha(8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(nodeType.icon, size: 18, color: color.withAlpha(220)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nodeType.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          height: 1.2,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (nodeType.description != null)
                        Text(
                          nodeType.description!,
                          style: TextStyle(fontSize: 10.5, color: cs.onSurface.withAlpha(80), height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (hasInput) _miniPort(Icons.arrow_back_rounded, const Color(0xFFFF9F0A), cs),
                if (hasInput && hasOutput) const SizedBox(width: 3),
                if (hasOutput) _miniPort(Icons.arrow_forward_rounded, const Color(0xFF34C759), cs),
              ],
            ),
          ),
        ),
      ),
    );

    return LongPressDraggable<NodeTypeDefinition>(
      data: nodeType,
      delay: const Duration(milliseconds: 280),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 8,
        shadowColor: Colors.black.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        color: cs.surface,
        child: Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(70)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(nodeType.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(nodeType.displayName,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  Widget _miniPort(IconData icon, Color color, ColorScheme cs) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(90), width: 1.2),
        color: color.withAlpha(12),
      ),
      child: Icon(icon, size: 10, color: color.withAlpha(200)),
    );
  }
}
