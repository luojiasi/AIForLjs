import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../models/node_type.dart';
import '../converters/canvas_converter.dart';

/// Custom canvas node renderer with Apple-style refinement.
class Simplen8nNodeWidget extends StatelessWidget {
  final flow.Node<Simplen8nCanvasData> node;
  final bool isSelected;
  final bool isExecuting;
  final String? executionStatus;
  final void Function(Offset globalPosition)? onContextMenu;

  const Simplen8nNodeWidget({
    super.key,
    required this.node,
    this.isSelected = false,
    this.isExecuting = false,
    this.executionStatus,
    this.onContextMenu,
  });

  String get _typeLabel => node.data.nodeType.replaceAll('_', ' ');

  int get _inputCount => node.ports.where((p) => p.type == flow.PortType.input).length;
  int get _outputCount => node.ports.where((p) => p.type == flow.PortType.output).length;

  @override
  Widget build(BuildContext context) {
    final color = node.data.category.color;
    final cs = Theme.of(context).colorScheme;
    final hasSummary = node.data.parameterSummary != null && node.data.parameterSummary!.isNotEmpty;
    final isError = executionStatus == 'error';
    final isSuccess = executionStatus == 'success';

    final borderColor = isError
        ? const Color(0xFFFF3B30)
        : isSuccess
            ? const Color(0xFF34C759)
            : isSelected
                ? color
                : color.withAlpha(55);
    final borderWidth = (isSelected || isError || isSuccess) ? 2.0 : 1.0;

    return GestureDetector(
      onSecondaryTapDown: onContextMenu != null
          ? (details) => onContextMenu!(details.globalPosition)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 216,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? color : Colors.black).withAlpha(isSelected ? 20 : 6),
              blurRadius: isSelected ? 20 : 8,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: color.withAlpha(15),
                blurRadius: 36,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(color, cs),
            if (hasSummary) _buildSummary(node.data.parameterSummary!, color, cs),
            _buildFooter(color, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, ColorScheme cs) {
    final isError = executionStatus == 'error';
    final isSuccess = executionStatus == 'success';
    final isRunning = executionStatus == 'running';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withAlpha(35), width: 0.5),
            ),
            child: Icon(node.data.category.icon, size: 17, color: color.withAlpha(230)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.data.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withAlpha(230),
                    height: 1.2,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _typeLabel,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withAlpha(60),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          if (isRunning)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color.withAlpha(220)),
              ),
            ),
          if (isSuccess)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF34C759)),
            ),
          if (isError)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFFFF3B30)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(String summary, Color color, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withAlpha(20), width: 0.5),
          bottom: BorderSide(color: cs.outlineVariant.withAlpha(20), width: 0.5),
        ),
      ),
      child: Text(
        summary,
        style: TextStyle(
          fontSize: 10.5,
          color: cs.onSurface.withAlpha(100),
          fontFamily: 'SF Mono, monospace',
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(Color color, ColorScheme cs) {
    final hasPorts = _inputCount > 0 || _outputCount > 0;
    if (!hasPorts) return const SizedBox(height: 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
      ),
      child: Row(
        children: [
          if (_inputCount > 0)
            _portIndicator('$_inputCount in', Icons.arrow_back_rounded, const Color(0xFFFF9F0A), cs),
          const Spacer(),
          Container(
            width: 32,
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [color.withAlpha(5), color.withAlpha(50), color.withAlpha(5)],
              ),
            ),
          ),
          const Spacer(),
          if (_outputCount > 0)
            _portIndicator('$_outputCount out', Icons.arrow_forward_rounded, const Color(0xFF34C759), cs),
        ],
      ),
    );
  }

  Widget _portIndicator(String label, IconData icon, Color color, ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color.withAlpha(160)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withAlpha(80),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
