import 'package:flutter/material.dart';

import '../services/execution_storage_service.dart';
import 'execution_detail_page.dart';

/// Shows a list of past workflow executions.
class ExecutionHistoryPage extends StatefulWidget {
  final String? workflowId;

  const ExecutionHistoryPage({super.key, this.workflowId});

  @override
  State<ExecutionHistoryPage> createState() => _ExecutionHistoryPageState();
}

class _ExecutionHistoryPageState extends State<ExecutionHistoryPage> {
  List<ExecutionSummary>? _items;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final storage = ExecutionStorageService();
    final items = await storage.listSummaries(workflowId: widget.workflowId);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workflowId != null
            ? 'Workflow History'
            : 'All Execution History'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items == null || _items!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 48,
                          color: cs.onSurface.withAlpha(60)),
                      const SizedBox(height: 12),
                      Text('No execution history yet',
                          style: TextStyle(
                              color: cs.onSurface.withAlpha(120))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items!.length,
                  itemBuilder: (_, i) {
                    final item = _items![i];
                    return _ExecutionCard(
                      summary: item,
                      onTap: () async {
                        final storage = ExecutionStorageService();
                        final result = await storage.load(item.executionId);
                        if (result != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExecutionDetailPage(result: result),
                            ),
                          );
                        }
                      },
                      onDelete: () async {
                        await ExecutionStorageService()
                            .delete(item.executionId);
                        await _refresh();
                      },
                    );
                  },
                ),
    );
  }
}

class _ExecutionCard extends StatelessWidget {
  final ExecutionSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExecutionCard({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSuccess = summary.status == 'success';
    final statusColor = isSuccess ? Colors.green : Colors.red.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 20,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.workflowName ?? 'Untitled',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${summary.nodeCount} nodes  •  ${summary.durationMs}ms  •  ${_formatDate(summary.startedAt)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withAlpha(100)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
