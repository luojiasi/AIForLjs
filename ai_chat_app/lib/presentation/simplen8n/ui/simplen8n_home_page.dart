import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../models/workflow_model.dart';
import '../providers/workflow_provider.dart';
import '../services/workflow_storage_service.dart';
import '../services/execution_storage_service.dart';
import '../nodes/node_registry.dart';
import 'workflow_canvas_page.dart';

/// simplen8n entry page — shows saved workflows + create new.
class Simplen8nHomePage extends StatefulWidget {
  const Simplen8nHomePage({super.key});

  @override
  State<Simplen8nHomePage> createState() => _Simplen8nHomePageState();
}

class _Simplen8nHomePageState extends State<Simplen8nHomePage> {
  List<WorkflowSummary>? _workflows;
  Map<String, ExecutionSummary> _latestExecutions = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final workflows = await WorkflowProvider.listWorkflows();
    final allHistory = await ExecutionStorageService().listSummaries();
    final latest = <String, ExecutionSummary>{};
    for (final es in allHistory) {
      if (es.workflowId != null && !latest.containsKey(es.workflowId)) {
        latest[es.workflowId!] = es;
      }
    }
    if (mounted) {
      setState(() {
        _workflows = workflows;
        _latestExecutions = latest;
        _loading = false;
      });
    }
  }

  void _openEditor({Workflow? existing}) {
    final provider = WorkflowProvider(
      availableTypes: NodeRegistry.instance.types,
      existingWorkflow: existing,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const WorkflowCanvasPage(),
        ),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'simplen8n',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        backgroundColor: cs.surface.withAlpha(230),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: cs.onSurface.withAlpha(10),
        actions: [
          TextButton.icon(
            onPressed: () => _showAboutDialog(context),
            icon: Icon(Icons.info_outline, size: 15, color: cs.onSurface.withAlpha(100)),
            label: Text(AppLocalizations.of(context)!.simplen8nAbout, style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(100), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _workflows == null || _workflows!.isEmpty
              ? _buildEmptyState(cs)
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: cs.primary,
                  child: _buildWorkflowList(cs),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        elevation: 2,
        highlightElevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(AppLocalizations.of(context)!.simplen8nNewWorkflow, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withAlpha(30), cs.primary.withAlpha(10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: cs.primary.withAlpha(15), blurRadius: 30, offset: const Offset(0, 12)),
                ],
              ),
              child: Icon(Icons.account_tree_rounded, size: 44, color: cs.primary.withAlpha(200)),
            ),
            const SizedBox(height: 32),
            Text('simplen8n',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.simplen8nTagline,
                style: TextStyle(fontSize: 15,
                    color: cs.onSurface.withAlpha(110), height: 1.4)),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.simplen8nCreateFirst, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _workflows!.length,
      itemBuilder: (_, i) {
        final s = _workflows![i];
        final latestExec = _latestExecutions[s.id];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final wf = await WorkflowStorageService().load(s.id);
                if (wf != null && mounted) _openEditor(existing: wf);
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant.withAlpha(40)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary.withAlpha(25), cs.primary.withAlpha(8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.account_tree_rounded, size: 24, color: cs.primary.withAlpha(200)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                          const SizedBox(height: 5),
                          Text(
                            s.description.isNotEmpty
                                ? s.description
                                : '${s.nodeCount} nodes  •  ${_formatDate(s.updatedAt)}',
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(100)),
                          ),
                          if (latestExec != null) _buildStatusChip(latestExec, cs),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) async {
                        switch (action) {
                          case 'delete':
                            await WorkflowStorageService().delete(s.id);
                            await _refresh();
                            break;
                          case 'duplicate':
                            final wf = await WorkflowStorageService().load(s.id);
                            if (wf != null) {
                              final copy = Workflow(
                                id: 'wf_${DateTime.now().millisecondsSinceEpoch}',
                                name: '${wf.name} (Copy)',
                                nodes: wf.nodes,
                                connections: wf.connections,
                              );
                              await WorkflowStorageService().save(copy);
                              await _refresh();
                            }
                            break;
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'duplicate',
                            child: Row(children: [
                              const Icon(Icons.copy, size: 18),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.simplen8nDuplicate),
                            ])),
                        PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.simplen8nDelete, style: const TextStyle(color: Colors.red)),
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ExecutionSummary es, ColorScheme cs) {
    final isSuccess = es.status == 'success';
    final color = isSuccess ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isSuccess ? AppLocalizations.of(context)!.simplen8nLastRunOk : AppLocalizations.of(context)!.simplen8nLastRunFailed,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '${es.durationMs}ms',
            style: TextStyle(fontSize: 10, color: cs.onSurface.withAlpha(70), fontFamily: 'SF Mono, monospace'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'simplen8n',
      applicationVersion: 'Phase 4 — Production Ready',
      children: const [
        Text(
          'A simplified n8n-like workflow automation engine\n'
          'built in Flutter + Dart.\n\n'
          'Features:\n'
          '  • 10 node types (Trigger, HTTP, Set, IF, Merge, AI, Webhook, Cron, Error, Sub-workflow)\n'
          '  • Visual canvas with vyuh_node_flow\n'
          '  • DAG execution engine with cycle detection\n'
          '  • Custom expression parser & template engine\n'
          '  • Multi-input aggregation & retry logic\n'
          '  • File persistence & JSON import/export\n'
          '  • Credential encryption & trigger system',
        ),
      ],
    );
  }
}
