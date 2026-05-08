import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/execution_data.dart';

/// Shows the details of a single execution result — per-node input/output/duration/error.
class ExecutionDetailPage extends StatelessWidget {
  final ExecutionResult result;

  const ExecutionDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSuccess = result.status == ExecutionStatus.success;

    return Scaffold(
      appBar: AppBar(
        title: Text(result.workflowName ?? 'Execution Detail'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.withAlpha(20) : Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isSuccess ? 'Success' : 'Failed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary header
          _buildHeader(cs),
          const SizedBox(height: 16),
          // Error if any
          if (result.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withAlpha(40)),
              ),
              child: Text(result.error!,
                  style: const TextStyle(
                      fontSize: 12, fontFamily: 'monospace', color: Colors.red)),
            ),
            const SizedBox(height: 16),
          ],
          // Per-node results
          Text('Nodes (${result.nodeResults.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          ...result.nodeResults.entries.map((entry) {
            return _buildNodeCard(entry.key, entry.value, cs);
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Duration', '${result.durationMs}ms'),
          _stat('Nodes', '${result.nodeResults.length}'),
          _stat('Started', _formatTime(result.startedAt)),
          _stat('ID', result.executionId.substring(0, 8)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildNodeCard(String nodeId, NodeExecutionResult nr, ColorScheme cs) {
    final isOk = nr.status == NodeExecutionStatus.success;
    final statusColor = isOk ? Colors.green : Colors.red.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isOk ? Icons.check : Icons.close,
            size: 16,
            color: statusColor,
          ),
        ),
        title: Text(nodeId,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'monospace')),
        subtitle: Text(
          '${nr.durationMs}ms  ${nr.retryCount > 0 ? '• retries: ${nr.retryCount}' : ''}',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(100)),
        ),
        children: [
          if (nr.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(nr.error!,
                  style: const TextStyle(
                      fontSize: 11, fontFamily: 'monospace', color: Colors.red)),
            ),
          if (nr.output != null && nr.output!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ')
                      .convert(nr.output!.first.toJson()),
                  style: const TextStyle(
                      fontSize: 10.5, fontFamily: 'monospace'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
