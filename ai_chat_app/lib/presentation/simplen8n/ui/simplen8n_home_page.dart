import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        title: const Text('simplen8n'),
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface),
        actions: [
          TextButton.icon(
            onPressed: () => _showAboutDialog(context),
            icon: Icon(Icons.info_outline, size: 16,
                color: cs.onSurface.withAlpha(120)),
            label: Text('About',
                style: TextStyle(
                    fontSize: 12, color: cs.onSurface.withAlpha(120))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _workflows == null || _workflows!.isEmpty
              ? _buildEmptyState(cs)
              : _buildWorkflowList(cs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Workflow'),
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
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withAlpha(25), cs.secondary.withAlpha(12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.primary.withAlpha(30), width: 1.5),
              ),
              child:
                  Icon(Icons.account_tree_rounded, size: 44, color: cs.primary),
            ),
            const SizedBox(height: 28),
            Text('simplen8n',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text('Visual workflow automation engine',
                style: TextStyle(fontSize: 15,
                    color: cs.onSurface.withAlpha(120))),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Your First Workflow'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _workflows!.length,
      itemBuilder: (_, i) {
        final s = _workflows![i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final wf = await WorkflowStorageService().load(s.id);
              if (wf != null && mounted) _openEditor(existing: wf);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_tree_rounded,
                        size: 22, color: cs.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          s.description.isNotEmpty
                              ? s.description
                              : '${s.nodeCount} nodes  •  ${_formatDate(s.updatedAt)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withAlpha(110)),
                        ),
                        if (_latestExecutions.containsKey(s.id))
                          _buildStatusChip(_latestExecutions[s.id]!, cs),
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
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ])),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18,
                                color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ])),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ExecutionSummary es, ColorScheme cs) {
    final isSuccess = es.status == 'success';
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green : Colors.red.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isSuccess ? 'Last run OK' : 'Last run failed',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isSuccess ? Colors.green : Colors.red.shade400,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${es.durationMs}ms',
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurface.withAlpha(80),
              fontFamily: 'monospace',
            ),
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
          '  • 5 core nodes (Trigger, HTTP, Set, IF, Merge)\n'
          '  • Visual canvas with vyuh_node_flow\n'
          '  • DAG execution engine with cycle detection\n'
          '  • Expression parser & template engine\n'
          '  • Multi-input aggregation & retry logic\n'
          '  • File persistence & JSON import/export',
        ),
      ],
    );
  }
}
