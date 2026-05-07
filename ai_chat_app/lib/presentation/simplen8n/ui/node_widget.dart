import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../models/node_type.dart';
import '../converters/canvas_converter.dart';

/// 画布上的自定义节点渲染器
class Simplen8nNodeWidget extends StatelessWidget {
  final flow.Node<Simplen8nCanvasData> node;
  final bool isSelected;
  final bool isExecuting;
  final String? executionStatus;

  const Simplen8nNodeWidget({
    super.key,
    required this.node,
    this.isSelected = false,
    this.isExecuting = false,
    this.executionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final color = node.data.category.color;
    final cs = Theme.of(context).colorScheme;
    final hasSummary = node.data.parameterSummary != null &&
        node.data.parameterSummary!.isNotEmpty;

    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExecuting
              ? Colors.green.shade400
              : isSelected
                  ? color
                  : color.withAlpha(70),
          width: isSelected || isExecuting ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? color : Colors.black).withAlpha(isSelected ? 25 : 12),
            blurRadius: isSelected ? 14 : 8,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(color, cs),
          // Parameters summary
          if (hasSummary) _buildSummary(node.data.parameterSummary!, cs),
          // Mini footer bar
          _buildFooter(color, cs),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(28),
            color.withAlpha(8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(node.data.category.icon, size: 17, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.data.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withAlpha(210),
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (executionStatus != null) _buildStatusDot(executionStatus!),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String status) {
    switch (status) {
      case 'running':
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
          ),
        );
      case 'success':
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 12, color: Colors.green.shade600),
        );
      case 'error':
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, size: 11, color: Colors.red.shade600),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSummary(String summary, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Text(
        summary,
        style: TextStyle(
          fontSize: 10.5,
          color: cs.onSurface.withAlpha(100),
          fontFamily: 'monospace',
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(Color color, ColorScheme cs) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
        gradient: LinearGradient(
          colors: [color.withAlpha(50), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
