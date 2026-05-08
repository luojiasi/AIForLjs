import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../providers/workflow_provider.dart';
import '../services/workflow_storage_service.dart';
import '../engine/execution_engine.dart';
import '../converters/canvas_converter.dart';
import '../models/node_type.dart';
import 'node_widget.dart';
import 'node_palette.dart';
import 'node_config_panel.dart';
import 'execution_history_page.dart';

/// 工作流编辑主页面
class WorkflowCanvasPage extends StatefulWidget {
  const WorkflowCanvasPage({super.key});

  @override
  State<WorkflowCanvasPage> createState() => _WorkflowCanvasPageState();
}

class _WorkflowCanvasPageState extends State<WorkflowCanvasPage> {
  bool _showLogs = false;
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkflowProvider>();
    final cs = Theme.of(context).colorScheme;

    // Show error SnackBar when lastError changes
    if (provider.lastError != null) {
      final errorMsg = provider.lastError!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: cs.onError,
              onPressed: () {},
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: Row(
        children: [
          NodePalette(
            nodes: provider.availableTypes,
            onAddNode: (nodeType) {
              final dx = 350.0 + (DateTime.now().millisecond % 200).toDouble();
              final dy = 200.0 + (DateTime.now().millisecond % 200).toDouble();
              provider.addNode(nodeType, Offset(dx, dy));
            },
          ),
          Expanded(
            child: Column(
              children: [
                _buildToolbar(provider, cs),
                Expanded(child: _buildCanvas(provider, cs)),
                if (_showLogs) _buildLogPanel(provider, cs),
              ],
            ),
          ),
          NodeConfigPanel(
            node: provider.selectedWorkflowNode,
            nodeType: provider.selectedWorkflowNode != null
                ? provider.nodeTypeDef(provider.selectedWorkflowNode!.type)
                : null,
            onUpdateParameter: provider.updateNodeParameter,
            onUpdateName: provider.updateNodeName,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Toolbar
  // ============================================================================

  Widget _buildToolbar(WorkflowProvider provider, ColorScheme cs) {
    final hasSelection = provider.selectedNodeId != null;
    final nodeCount = provider.canvasController.nodeIds.length;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(80))),
      ),
      child: Row(
        children: [
          // Undo / Redo
          _ToolBtn(
            icon: Icons.undo_rounded,
            label: '',
            active: provider.canUndo,
            onTap: provider.canUndo ? () => provider.undo() : null,
            cs: cs,
          ),
          const SizedBox(width: 2),
          _ToolBtn(
            icon: Icons.redo_rounded,
            label: '',
            active: provider.canRedo,
            onTap: provider.canRedo ? () => provider.redo() : null,
            cs: cs,
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 18, color: cs.outlineVariant.withAlpha(80)),
          const SizedBox(width: 8),
          // Run
          _ToolBtn(
            icon: Icons.play_arrow_rounded,
            label: 'Run',
            color: const Color(0xFF16A34A),
            active: !provider.isExecuting,
            loading: provider.isExecuting,
            onTap: provider.isExecuting
                ? null
                : () => provider.executeWorkflow(
                      executor: (wf) => ExecutionEngine().execute(wf),
                    ),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Delete
          _ToolBtn(
            icon: Icons.delete_outline_rounded,
            label: '',
            color: cs.error,
            active: hasSelection,
            onTap: hasSelection ? () => provider.deleteSelectedNode() : null,
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Arrange
          _ToolBtn(
            icon: Icons.auto_fix_high_rounded,
            label: 'Arrange',
            active: nodeCount >= 2,
            onTap: nodeCount >= 2
                ? () {
                    provider.syncToWorkflow();
                    provider.recordBeforeMutation();
                    provider.canvasController.arrangeNodesHierarchically();
                    provider.canvasController.fitToView();
                    provider.syncToWorkflow();
                    provider.addLog('Applied hierarchical layout');
                  }
                : null,
            cs: cs,
          ),
          const Spacer(),
          // Workflow name
          Container(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              provider.workflow.name,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 18, color: cs.outlineVariant.withAlpha(80)),
          const SizedBox(width: 8),
          // Save
          _ToolBtn(
            icon: Icons.save_rounded,
            label: 'Save',
            active: true,
            onTap: () => provider.saveWorkflow(),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Load
          _ToolBtn(
            icon: Icons.folder_open_rounded,
            label: 'Load',
            active: true,
            onTap: () => _showLoadDialog(context, provider, cs),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Import
          _ToolBtn(
            icon: Icons.file_upload_rounded,
            label: 'Import',
            active: true,
            onTap: () => _importWorkflow(context, provider),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Export
          _ToolBtn(
            icon: Icons.file_download_rounded,
            label: 'Export',
            active: true,
            onTap: () => _exportWorkflow(context, provider),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Activate / Deactivate
          _ToolBtn(
            icon: provider.isActive
                ? Icons.stop_circle_rounded
                : Icons.play_circle_rounded,
            label: provider.isActive ? 'Stop' : 'Activate',
            color: provider.isActive ? Colors.red : const Color(0xFF16A34A),
            active: true,
            onTap: () {
              if (provider.isActive) {
                provider.deactivateWorkflow();
              } else {
                provider.activateWorkflow();
              }
            },
            cs: cs,
          ),
          const SizedBox(width: 3),
          // History
          _ToolBtn(
            icon: Icons.history_rounded,
            label: 'History',
            active: true,
            onTap: () => _showHistory(context, provider),
            cs: cs,
          ),
          const SizedBox(width: 3),
          // Logs toggle
          _ToolBtn(
            icon: _showLogs ? Icons.terminal_rounded : Icons.terminal_outlined,
            label: 'Logs',
            active: true,
            highlight: _showLogs,
            onTap: () => setState(() => _showLogs = !_showLogs),
            cs: cs,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Canvas
  // ============================================================================

  Widget _buildCanvas(WorkflowProvider provider, ColorScheme cs) {
    final nodeCount = provider.canvasController.nodeIds.length;

    return DragTarget<NodeTypeDefinition>(
      onAcceptWithDetails: (details) {
        final graphPos = provider.canvasController
            .screenToGraph(flow.ScreenPosition(details.offset))
            .offset;
        provider.addNode(details.data, graphPos);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // Dot grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(dotColor: cs.outlineVariant.withAlpha(25)),
              ),
            ),
            // NodeFlowEditor with keyboard focus
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                return _handleKeyboard(event, provider) ? KeyEventResult.handled : KeyEventResult.ignored;
              },
              child: flow.NodeFlowEditor<Simplen8nCanvasData, void>(
                controller: provider.canvasController,
                theme: flow.NodeFlowTheme.light,
                nodeBuilder: _buildCanvasNode,
                events: flow.NodeFlowEvents<Simplen8nCanvasData, void>(
                  node: flow.NodeEvents<Simplen8nCanvasData>(
                    onTap: (node) => provider.selectNode(node.id),
                  ),
                  viewport: flow.ViewportEvents(
                    onCanvasTap: (_) => provider.selectNode(null),
                  ),
                  connection: flow.ConnectionEvents<Simplen8nCanvasData, void>(
                    onCreated: (_) {
                      provider.syncToWorkflow();
                      provider.recordBeforeMutation();
                    },
                    onDeleted: (_) {
                      provider.syncToWorkflow();
                      provider.recordBeforeMutation();
                    },
                  ),
                ),
              ),
            ),
            // Empty state
            if (nodeCount == 0) _buildEmptyCanvas(cs),
            // Drop indicator
            if (candidateData.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(12),
                      border: Border.all(color: cs.primary.withAlpha(40), width: 2),
                    ),
                  ),
                ),
              ),
            // Minimap
            if (nodeCount > 0)
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant.withAlpha(80)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: flow.NodeFlowMinimap<Simplen8nCanvasData>(
                      controller: provider.canvasController,
                      size: const Size(170, 128),
                      interactive: true,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _handleKeyboard(KeyEvent event, WorkflowProvider provider) {
    if (event is! KeyDownEvent) return false;

    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    // Ctrl+Z = Undo
    if (ctrl && !shift && event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (provider.canUndo) provider.undo();
      return true;
    }
    // Ctrl+Shift+Z or Ctrl+Y = Redo
    if ((ctrl && shift && event.logicalKey == LogicalKeyboardKey.keyZ) ||
        (ctrl && event.logicalKey == LogicalKeyboardKey.keyY)) {
      if (provider.canRedo) provider.redo();
      return true;
    }
    // Ctrl+A = Select All
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyA) {
      provider.canvasController.selectAllNodes();
      return true;
    }
    // Delete / Backspace
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (provider.selectedNodeId != null) {
        provider.deleteSelectedNode();
        return true;
      }
    }
    // Ctrl+D = Duplicate
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyD) {
      final nid = provider.selectedNodeId;
      if (nid != null) {
        provider.canvasController.duplicateNode(nid);
        provider.syncToWorkflow();
        return true;
      }
    }
    // Ctrl+C = Copy
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyC) {
      provider.copySelectedNode();
      return true;
    }
    // Ctrl+X = Cut
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyX) {
      provider.cutSelectedNode();
      return true;
    }
    // Ctrl+V = Paste
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyV) {
      provider.recordBeforeMutation();
      provider.pasteNode();
      return true;
    }
    // F = Fit to view
    if (event.logicalKey == LogicalKeyboardKey.keyF) {
      provider.canvasController.fitToView();
      return true;
    }
    // Escape = Clear selection
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      provider.selectNode(null);
      return true;
    }

    return false;
  }

  Widget _buildEmptyCanvas(ColorScheme cs) {
    return Center(
      child: IgnorePointer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.account_tree_outlined, size: 36,
                  color: cs.primary.withAlpha(70)),
            ),
            const SizedBox(height: 20),
            Text(
              'Build your workflow',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withAlpha(130),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag nodes from the left panel\nor click + drag to add from palette',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurface.withAlpha(70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasNode(BuildContext context,
      flow.Node<Simplen8nCanvasData> node) {
    final provider = context.read<WorkflowProvider>();
    final isSelected = provider.selectedNodeId == node.id;

    String? execStatus;
    final result = provider.executionResult;
    if (result != null) {
      final nodeResult = result.nodeResults[node.id];
      if (nodeResult != null) {
        execStatus = nodeResult.status.name;
      }
    }

    return Simplen8nNodeWidget(
      node: node,
      isSelected: isSelected,
      executionStatus: execStatus,
      onContextMenu: (globalPos) => _showNodeContextMenu(context, node.id, node.data.label, globalPos, provider),
    );
  }

  // ============================================================================
  // Right-click context menu
  // ============================================================================

  void _showNodeContextMenu(BuildContext context, String nodeId, String nodeLabel,
      Offset position, WorkflowProvider provider) {
    final cs = Theme.of(context).colorScheme;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx + 1, position.dy + 1),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'execute_from',
          child: Row(children: [
            Icon(Icons.play_arrow, size: 18, color: Colors.green),
            const SizedBox(width: 8),
            Text('Execute From Here', style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(children: [
            Icon(Icons.copy, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text('Duplicate', style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.content_copy, size: 18, color: cs.onSurface.withAlpha(150)),
            const SizedBox(width: 8),
            Text('Copy', style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'cut',
          child: Row(children: [
            Icon(Icons.content_cut, size: 18, color: cs.onSurface.withAlpha(150)),
            const SizedBox(width: 8),
            Text('Cut', style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: cs.error),
            const SizedBox(width: 8),
            Text('Delete', style: TextStyle(fontSize: 13, color: cs.error)),
          ]),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      provider.selectNode(nodeId);
      switch (value) {
        case 'delete':
          provider.deleteSelectedNode();
          break;
        case 'duplicate':
          provider.recordBeforeMutation();
          provider.canvasController.duplicateNode(nodeId);
          provider.syncToWorkflow();
          provider.addLog('Duplicated node: $nodeLabel');
          break;
        case 'execute_from':
          provider.addLog('Execute from "$nodeLabel" (not yet implemented)');
          break;
        case 'copy':
          provider.copySelectedNode();
          break;
        case 'cut':
          provider.cutSelectedNode();
          break;
      }
    });
  }

  // ============================================================================
  // Log panel
  // ============================================================================

  Widget _buildLogPanel(WorkflowProvider provider, ColorScheme cs) {
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(100),
        border: Border(top: BorderSide(color: cs.outlineVariant.withAlpha(80))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 13, color: cs.onSurface.withAlpha(120)),
                const SizedBox(width: 6),
                Text('Execution Logs',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: cs.onSurface.withAlpha(140))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${provider.executionLogs.length}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    provider.executionLogs.clear();
                    setState(() {});
                  },
                  child: Icon(Icons.clear_all, size: 16, color: cs.onSurface.withAlpha(80)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _logScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: provider.executionLogs.length,
              itemBuilder: (_, i) {
                final log = provider.executionLogs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _logStatusIcon(log, cs),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          log,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: 'monospace',
                            color: cs.onSurface.withAlpha(140),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _logStatusIcon(String log, ColorScheme cs) {
    final lower = log.toLowerCase();
    if (lower.contains('error') || lower.contains('failed') || lower.contains('fail')) {
      return Icon(Icons.circle, size: 8, color: Colors.red.shade400);
    }
    if (lower.contains('ok') || lower.contains('completed') || lower.contains('success')) {
      return Icon(Icons.circle, size: 8, color: Colors.green.shade400);
    }
    if (lower.contains('starting') || lower.contains('running') || lower.contains('executing')) {
      return Icon(Icons.circle, size: 8, color: Colors.blue.shade400);
    }
    return Icon(Icons.circle, size: 8, color: cs.onSurface.withAlpha(40));
  }

  // ============================================================================
  // Save / Load / Import / Export
  // ============================================================================

  void _showLoadDialog(BuildContext context, WorkflowProvider provider, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (ctx) => _LoadWorkflowDialog(
        onLoad: (id) {
          provider.loadWorkflow(id);
          Navigator.pop(ctx);
        },
        onDelete: (id) async {
          await provider.deleteWorkflow(id);
        },
        currentId: provider.workflow.id,
      ),
    );
  }

  void _showHistory(BuildContext context, WorkflowProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExecutionHistoryPage(
          workflowId: provider.workflow.id,
        ),
      ),
    );
  }

  Future<void> _importWorkflow(BuildContext context, WorkflowProvider provider) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      String content;
      if (result.files.single.bytes != null) {
        content = String.fromCharCodes(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        content = await File(result.files.single.path!).readAsString();
      } else {
        return;
      }

      provider.importFromJson(content);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow imported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportWorkflow(BuildContext context, WorkflowProvider provider) async {
    try {
      final jsonStr = await provider.exportToJson();
      final name = provider.workflow.name.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final outputPath = await FilePicker.saveFile(
        dialogTitle: 'Export Workflow',
        fileName: '$name.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (outputPath == null) return;

      await File(outputPath).writeAsString(jsonStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Dialog for loading a saved workflow.
class _LoadWorkflowDialog extends StatefulWidget {
  final void Function(String id) onLoad;
  final Future<void> Function(String id) onDelete;
  final String? currentId;

  const _LoadWorkflowDialog({
    required this.onLoad,
    required this.onDelete,
    this.currentId,
  });

  @override
  State<_LoadWorkflowDialog> createState() => _LoadWorkflowDialogState();
}

class _LoadWorkflowDialogState extends State<_LoadWorkflowDialog> {
  List<WorkflowSummary>? _summaries;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final summaries = await WorkflowProvider.listWorkflows();
    if (mounted) {
      setState(() {
        _summaries = summaries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Load Workflow'),
      content: SizedBox(
        width: 420,
        height: 350,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _summaries == null || _summaries!.isEmpty
                ? Center(
                    child: Text('No saved workflows',
                        style: TextStyle(color: cs.onSurface.withAlpha(100))))
                : ListView.builder(
                    itemCount: _summaries!.length,
                    itemBuilder: (_, i) {
                      final s = _summaries![i];
                      final isCurrent = s.id == widget.currentId;
                      return Card(
                        color: isCurrent ? cs.primary.withAlpha(10) : null,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${s.nodeCount} nodes  •  ${_formatDate(s.updatedAt)}',
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withAlpha(100)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: cs.error.withAlpha(160),
                                onPressed: () async {
                                  await widget.onDelete(s.id);
                                  await _refresh();
                                },
                              ),
                              const SizedBox(width: 4),
                              FilledButton(
                                onPressed: () => widget.onLoad(s.id),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: const Text('Load', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Toolbar button
class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool active;
  final bool highlight;
  final bool loading;
  final VoidCallback? onTap;
  final ColorScheme cs;

  const _ToolBtn({
    required this.icon,
    required this.label,
    this.color,
    this.active = true,
    this.highlight = false,
    this.loading = false,
    this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !loading;
    final effectiveColor = color ?? cs.onSurface;

    return SizedBox(
      height: 30,
      child: Material(
        color: highlight ? cs.primary.withAlpha(20) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(effectiveColor.withAlpha(180)),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 16,
                    color: active
                        ? effectiveColor.withAlpha(disabled ? 60 : 220)
                        : cs.onSurface.withAlpha(60),
                  ),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    loading ? 'Running…' : label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? effectiveColor.withAlpha(disabled ? 60 : 220)
                          : cs.onSurface.withAlpha(60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle dot-grid background for the canvas
class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  _DotGridPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    const radius = 1.2;
    final paint = Paint()..color = dotColor;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
