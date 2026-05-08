import 'package:flutter/material.dart';

import '../models/node_type.dart';

/// 左侧节点面板 — 显示所有可用节点，支持搜索，点击添加到画布
class NodePalette extends StatefulWidget {
  final List<NodeTypeDefinition> nodes;
  final void Function(NodeTypeDefinition nodeType) onAddNode;

  const NodePalette({
    super.key,
    required this.nodes,
    required this.onAddNode,
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
    return widget.nodes.where((n) =>
        n.displayName.toLowerCase().contains(q) ||
        n.type.toLowerCase().contains(q) ||
        (n.description?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = NodeCategory.values;
    final filtered = _filtered();

    return Container(
      width: 264,
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(80))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cs.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.widgets_outlined, size: 16, color: cs.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nodes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filtered.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search bar
                SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: TextStyle(fontSize: 12, color: cs.onSurface),
                    cursorHeight: 14,
                    decoration: InputDecoration(
                      hintText: 'Search nodes…',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withAlpha(80),
                      ),
                      prefixIcon: Icon(Icons.search, size: 16,
                          color: cs.onSurface.withAlpha(100)),
                      suffixIcon: _query.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              child: Icon(Icons.close, size: 14,
                                  color: cs.onSurface.withAlpha(120)),
                            )
                          : null,
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withAlpha(100),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.primary.withAlpha(80)),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
              ],
            ),
          ),
          // Node list by category
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 32,
                            color: cs.onSurface.withAlpha(60)),
                        const SizedBox(height: 8),
                        Text('No nodes found',
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurface.withAlpha(100))),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    children: categories
                        .where((cat) => filtered.any((n) => n.category == cat))
                        .expand((cat) {
                      final catNodes = filtered.where((n) => n.category == cat).toList();
                      return [
                        _buildCategoryHeader(cat, cs),
                        ...catNodes.map((nt) => _buildNodeCard(nt, cs)),
                      ];
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(NodeCategory category, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withAlpha(130),
              letterSpacing: 0.6,
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
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget.onAddNode(nodeType),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withAlpha(40),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(nodeType.icon, size: 17, color: color),
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
                        ),
                      ),
                      if (nodeType.description != null)
                        Text(
                          nodeType.description!,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: cs.onSurface.withAlpha(90),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (hasInput) _miniPort(Icons.arrow_back, Colors.orange, cs),
                if (hasInput && hasOutput) const SizedBox(width: 3),
                if (hasOutput) _miniPort(Icons.arrow_forward, Colors.green, cs),
              ],
            ),
          ),
        ),
      ),
    );

    return LongPressDraggable<NodeTypeDefinition>(
      data: nodeType,
      delay: const Duration(milliseconds: 300),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        color: cs.surface,
        child: Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(nodeType.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(nodeType.displayName,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  Widget _miniPort(IconData icon, Color color, ColorScheme cs) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(100), width: 1.2),
        color: color.withAlpha(15),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }
}
