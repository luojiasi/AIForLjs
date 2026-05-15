import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../services/execution_storage_service.dart';
import 'execution_detail_page.dart';

/// Shows a list of past workflow executions with Apple-style refinement.
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
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          widget.workflowId != null ? AppLocalizations.of(context)!.simplen8nWorkflowHistory : AppLocalizations.of(context)!.simplen8nAllExecutionHistory,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.2),
        ),
        backgroundColor: cs.surface.withAlpha(230),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: cs.onSurface.withAlpha(10),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _items == null || _items!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary.withAlpha(15), cs.primary.withAlpha(5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.history_rounded, size: 30, color: cs.onSurface.withAlpha(50)),
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.simplen8nNoHistory,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface.withAlpha(100))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
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
                              builder: (_) => ExecutionDetailPage(result: result),
                            ),
                          );
                        }
                      },
                      onDelete: () async {
                        await ExecutionStorageService().delete(item.executionId);
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
    final statusColor = isSuccess ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant.withAlpha(35)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withAlpha(25), statusColor.withAlpha(6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: 22,
                    color: statusColor.withAlpha(210),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.workflowName ?? AppLocalizations.of(context)!.simplen8nUntitled,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.nodeCount} nodes  •  ${summary.durationMs}ms  •  ${_formatDate(summary.startedAt)}',
                        style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(90)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'delete') onDelete();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.simplen8nDelete, style: const TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
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
