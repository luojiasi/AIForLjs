import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/execution_data.dart';

/// Shows the details of a single execution result — per-node input/output/duration/error.
class ExecutionDetailPage extends StatelessWidget {
  final ExecutionResult result;

  const ExecutionDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSuccess = result.status == ExecutionStatus.success;
    final statusColor = isSuccess ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          result.workflowName ?? AppLocalizations.of(context)!.simplen8nExecutionDetail,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.2),
        ),
        backgroundColor: cs.surface.withAlpha(230),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: cs.onSurface.withAlpha(10),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isSuccess ? AppLocalizations.of(context)!.simplen8nSuccess : AppLocalizations.of(context)!.simplen8nFailed,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(context, cs, statusColor),
          const SizedBox(height: 20),
          if (result.error != null) ...[
            _buildErrorCard(result.error!, cs),
            const SizedBox(height: 20),
          ],
          Text(
            AppLocalizations.of(context)!.simplen8nNodesCount(result.nodeResults.length),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          ...result.nodeResults.entries.map((entry) {
            return _buildNodeCard(entry.key, entry.value, cs);
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withAlpha(10), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(AppLocalizations.of(context)!.simplen8nDuration, '${result.durationMs}ms', cs),
          _stat(AppLocalizations.of(context)!.simplen8nNodesLabel, '${result.nodeResults.length}', cs),
          _stat(AppLocalizations.of(context)!.simplen8nStarted, _formatTime(result.startedAt), cs),
          _stat(AppLocalizations.of(context)!.simplen8nId, result.executionId.substring(0, 8), cs),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, ColorScheme cs) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: cs.onSurface.withAlpha(80), letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'SF Mono, monospace', color: cs.onSurface.withAlpha(220))),
      ],
    );
  }

  Widget _buildErrorCard(String error, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30).withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF3B30).withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(error,
                style: const TextStyle(fontSize: 12.5, fontFamily: 'SF Mono, monospace', color: Color(0xFFFF3B30), height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(String nodeId, NodeExecutionResult nr, ColorScheme cs) {
    final isOk = nr.status == NodeExecutionStatus.success;
    final statusColor = isOk ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: cs.outlineVariant.withAlpha(35)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: cs.outlineVariant.withAlpha(35)),
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withAlpha(25), statusColor.withAlpha(6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOk ? Icons.check_rounded : Icons.close_rounded,
              size: 18,
              color: statusColor.withAlpha(220),
            ),
          ),
          title: Text(nodeId,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'SF Mono, monospace',
                  color: cs.onSurface.withAlpha(220))),
          subtitle: Text(
            '${nr.durationMs}ms${nr.retryCount > 0 ? '  •  retries: ${nr.retryCount}' : ''}',
            style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(80)),
          ),
          children: [
            if (nr.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(nr.error!,
                      style: const TextStyle(fontSize: 11, fontFamily: 'SF Mono, monospace', color: Color(0xFFFF3B30), height: 1.4)),
                ),
              ),
            if (nr.output != null && nr.output!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(nr.output!.first.toJson()),
                  style: TextStyle(fontSize: 11, fontFamily: 'SF Mono, monospace', color: cs.onSurface.withAlpha(200), height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
