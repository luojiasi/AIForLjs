import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../../../l10n/app_localizations.dart';
import '../providers/workflow_provider.dart';
import '../services/workflow_storage_service.dart';
import '../engine/execution_engine.dart';
import '../converters/canvas_converter.dart';
import '../models/node_type.dart';
import 'node_widget.dart';
import 'node_palette.dart';
import 'node_config_panel.dart';
import 'execution_history_page.dart';

/// Main workflow editor page with Apple-style design.
class WorkflowCanvasPage extends StatefulWidget {
  const WorkflowCanvasPage({super.key});

  @override
  State<WorkflowCanvasPage> createState() => _WorkflowCanvasPageState();
}

class _WorkflowCanvasPageState extends State<WorkflowCanvasPage> {
  bool _showLogs = false;
  bool _showLeftPanel = true;
  bool _showRightPanel = true;
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

    if (provider.lastError != null) {
      final errorMsg = provider.lastError!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: const TextStyle(fontSize: 13)),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.simplen8nDismiss,
              textColor: cs.onError,
              onPressed: () {},
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _buildToolbar(provider, cs),
          Expanded(
            child: Stack(
              children: [
                // Canvas fills entire area (painted first, behind sidebars)
                Positioned.fill(child: _buildCanvas(provider, cs)),
                // Left sidebar overlay with slide animation
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  offset: _showLeftPanel ? Offset.zero : const Offset(-1.05, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _showLeftPanel ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_showLeftPanel,
                      child: NodePalette(
                        nodes: provider.availableTypes,
                        onAddNode: (nodeType) {
                          final dx = 350.0 + (DateTime.now().millisecond % 200).toDouble();
                          final dy = 200.0 + (DateTime.now().millisecond % 200).toDouble();
                          provider.addNode(nodeType, Offset(dx, dy));
                        },
                        onClose: () => setState(() => _showLeftPanel = false),
                      ),
                    ),
                  ),
                ),
                // Right sidebar overlay with slide animation
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: _showLogs ? 170 : 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    offset: _showRightPanel ? Offset.zero : const Offset(1.05, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _showRightPanel ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: !_showRightPanel,
                        child: NodeConfigPanel(
                          node: provider.selectedWorkflowNode,
                          nodeType: provider.selectedWorkflowNode != null
                              ? provider.nodeTypeDef(provider.selectedWorkflowNode!.type)
                              : null,
                          onUpdateParameter: provider.updateNodeParameter,
                          onUpdateName: provider.updateNodeName,
                          onClose: () => setState(() => _showRightPanel = false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLogs) _buildLogPanel(provider, cs),
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
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(230),
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(25), width: 0.5)),
      ),
      child: Row(
        children: [
          _ToolBtn(icon: Icons.undo_rounded, label: '', tooltip: 'Undo (Ctrl+Z)', active: provider.canUndo, onTap: provider.canUndo ? () => provider.undo() : null, cs: cs),
          const SizedBox(width: 1),
          _ToolBtn(icon: Icons.redo_rounded, label: '', tooltip: 'Redo (Ctrl+Shift+Z)', active: provider.canRedo, onTap: provider.canRedo ? () => provider.redo() : null, cs: cs),
          const SizedBox(width: 10),
          _toolbarDivider(cs),
          const SizedBox(width: 10),
          _ToolBtn(
            icon: _showLeftPanel ? Icons.menu_open_rounded : Icons.menu_rounded,
            label: '',
            tooltip: 'Toggle Node Palette',
            highlight: _showLeftPanel,
            active: true,
            onTap: () => setState(() => _showLeftPanel = !_showLeftPanel),
            cs: cs,
          ),
          _ToolBtn(
            icon: _showRightPanel ? Icons.last_page_rounded : Icons.first_page_rounded,
            label: '',
            tooltip: 'Toggle Config Panel',
            highlight: _showRightPanel,
            active: true,
            onTap: () => setState(() => _showRightPanel = !_showRightPanel),
            cs: cs,
          ),
          const SizedBox(width: 6),
          _toolbarDivider(cs),
          const SizedBox(width: 6),
          _ToolBtn(
            icon: Icons.play_arrow_rounded,
            label: AppLocalizations.of(context)!.simplen8nRun,
            color: const Color(0xFF34C759),
            tooltip: 'Execute Workflow',
            active: !provider.isExecuting,
            loading: provider.isExecuting,
            onTap: provider.isExecuting ? null : () => provider.executeWorkflow(executor: (wf) => ExecutionEngine().execute(wf)),
            cs: cs,
          ),
          const SizedBox(width: 4),
          _ToolBtn(icon: Icons.delete_outline_rounded, label: '', color: cs.error, tooltip: 'Delete Selected (Del)', active: hasSelection, onTap: hasSelection ? () => provider.deleteSelectedNode() : null, cs: cs),
          const SizedBox(width: 4),
          _ToolBtn(
            icon: Icons.auto_fix_high_rounded,
            label: AppLocalizations.of(context)!.simplen8nArrange,
            tooltip: 'Auto Layout',
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
          Container(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              provider.workflow.name,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 14),
          _toolbarDivider(cs),
          const SizedBox(width: 10),
          _ToolBtn(icon: Icons.save_rounded, label: AppLocalizations.of(context)!.simplen8nSave, tooltip: 'Save (Ctrl+S)', active: true, onTap: () => provider.saveWorkflow(), cs: cs),
          const SizedBox(width: 2),
          _ToolBtn(icon: Icons.folder_open_rounded, label: AppLocalizations.of(context)!.simplen8nLoad, tooltip: 'Open Workflow', active: true, onTap: () => _showLoadDialog(context, provider, cs), cs: cs),
          const SizedBox(width: 2),
          _ToolBtn(icon: Icons.file_upload_rounded, label: AppLocalizations.of(context)!.simplen8nImport, tooltip: 'Import JSON', active: true, onTap: () => _importWorkflow(context, provider), cs: cs),
          const SizedBox(width: 2),
          _ToolBtn(icon: Icons.file_download_rounded, label: AppLocalizations.of(context)!.simplen8nExport, tooltip: 'Export JSON', active: true, onTap: () => _exportWorkflow(context, provider), cs: cs),
          const SizedBox(width: 2),
          _ToolBtn(
            icon: provider.isActive ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
            label: provider.isActive ? AppLocalizations.of(context)!.simplen8nStop : AppLocalizations.of(context)!.simplen8nActivate,
            color: provider.isActive ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
            tooltip: provider.isActive ? 'Deactivate Triggers' : 'Activate Triggers',
            active: true,
            onTap: () => provider.isActive ? provider.deactivateWorkflow() : provider.activateWorkflow(),
            cs: cs,
          ),
          const SizedBox(width: 2),
          _ToolBtn(icon: Icons.history_rounded, label: AppLocalizations.of(context)!.simplen8nHistory, tooltip: 'Execution History', active: true, onTap: () => _showHistory(context, provider), cs: cs),
          const SizedBox(width: 2),
          _ToolBtn(
            icon: _showLogs ? Icons.terminal_rounded : Icons.terminal_outlined,
            label: AppLocalizations.of(context)!.simplen8nLogs,
            tooltip: 'Toggle Log Panel',
            active: true,
            highlight: _showLogs,
            onTap: () => setState(() => _showLogs = !_showLogs),
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _toolbarDivider(ColorScheme cs) {
    return Container(width: 1, height: 16, decoration: BoxDecoration(color: cs.outlineVariant.withAlpha(40), borderRadius: BorderRadius.circular(1)));
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
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(dotColor: cs.outlineVariant.withAlpha(18)),
              ),
            ),
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                return _handleKeyboard(event, provider) ? KeyEventResult.handled : KeyEventResult.ignored;
              },
              child: flow.NodeFlowEditor<Simplen8nCanvasData, void>(
                controller: provider.canvasController,
                theme: Theme.of(context).brightness == Brightness.dark
                ? flow.NodeFlowTheme.dark
                : flow.NodeFlowTheme.light,
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
            if (nodeCount == 0) _buildEmptyCanvas(cs),
            if (candidateData.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(10),
                      border: Border.all(color: cs.primary.withAlpha(35), width: 1.5),
                    ),
                  ),
                ),
              ),
            if (nodeCount > 0)
              Positioned(
                right: 12,
                bottom: 12,
                child: Material(
                  elevation: 4,
                  shadowColor: Colors.black.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outlineVariant.withAlpha(50)),
                      borderRadius: BorderRadius.circular(12),
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

    final ctrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    if (ctrl && !shift && event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (provider.canUndo) provider.undo();
      return true;
    }
    if ((ctrl && shift && event.logicalKey == LogicalKeyboardKey.keyZ) || (ctrl && event.logicalKey == LogicalKeyboardKey.keyY)) {
      if (provider.canRedo) provider.redo();
      return true;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyA) {
      provider.canvasController.selectAllNodes();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.delete || event.logicalKey == LogicalKeyboardKey.backspace) {
      if (provider.selectedNodeId != null) {
        provider.deleteSelectedNode();
        return true;
      }
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyD) {
      final nid = provider.selectedNodeId;
      if (nid != null) {
        provider.canvasController.duplicateNode(nid);
        provider.syncToWorkflow();
        return true;
      }
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyC) {
      provider.copySelectedNode();
      return true;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyX) {
      provider.cutSelectedNode();
      return true;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyV) {
      provider.recordBeforeMutation();
      provider.pasteNode();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyF) {
      provider.canvasController.fitToView();
      return true;
    }
    if (ctrl && event.logicalKey == LogicalKeyboardKey.keyS) {
      provider.saveWorkflow();
      return true;
    }
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withAlpha(15), cs.primary.withAlpha(5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.account_tree_outlined, size: 38, color: cs.primary.withAlpha(60)),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.simplen8nBuildWorkflow,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface.withAlpha(120), letterSpacing: -0.2),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.simplen8nDragNodesHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurface.withAlpha(60)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasNode(BuildContext context, flow.Node<Simplen8nCanvasData> node) {
    final provider = context.read<WorkflowProvider>();
    final isSelected = provider.selectedNodeId == node.id;

    String? execStatus;
    final result = provider.executionResult;
    if (result != null) {
      final nodeResult = result.nodeResults[node.id];
      if (nodeResult != null) execStatus = nodeResult.status.name;
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

  void _showNodeContextMenu(BuildContext context, String nodeId, String nodeLabel, Offset position, WorkflowProvider provider) {
    final cs = Theme.of(context).colorScheme;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      elevation: 8,
      shadowColor: Colors.black.withAlpha(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem(
          value: 'execute_from',
          child: Row(children: [
            const Icon(Icons.play_arrow_rounded, size: 18, color: Color(0xFF34C759)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.simplen8nExecuteFromHere, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'duplicate',
          child: Row(children: [
            Icon(Icons.copy_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.simplen8nDuplicate, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.content_copy_rounded, size: 18, color: cs.onSurface.withAlpha(140)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.simplen8nCopy, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'cut',
          child: Row(children: [
            Icon(Icons.content_cut_rounded, size: 18, color: cs.onSurface.withAlpha(140)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.simplen8nCut, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.simplen8nDelete, style: TextStyle(fontSize: 13, color: cs.error)),
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
        color: cs.surface.withAlpha(235),
        border: Border(top: BorderSide(color: cs.outlineVariant.withAlpha(35), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              children: [
                Icon(Icons.terminal_rounded, size: 14, color: cs.onSurface.withAlpha(100)),
                const SizedBox(width: 7),
                Text(AppLocalizations.of(context)!.simplen8nExecutionLogs,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: cs.onSurface.withAlpha(130), letterSpacing: 0.2)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${provider.executionLogs.length}',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: cs.primary.withAlpha(200))),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    provider.executionLogs.clear();
                    setState(() {});
                  },
                  child: Icon(Icons.clear_all_rounded, size: 17, color: cs.onSurface.withAlpha(60)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _logScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.executionLogs.length,
              itemBuilder: (_, i) {
                final log = provider.executionLogs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _logStatusIcon(log),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          log,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: 'SF Mono, monospace',
                            color: cs.onSurface.withAlpha(130),
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

  Widget _logStatusIcon(String log) {
    final lower = log.toLowerCase();
    if (lower.contains('error') || lower.contains('failed') || lower.contains('fail')) {
      return const Icon(Icons.circle, size: 7, color: Color(0xFFFF3B30));
    }
    if (lower.contains('ok') || lower.contains('completed') || lower.contains('success')) {
      return const Icon(Icons.circle, size: 7, color: Color(0xFF34C759));
    }
    if (lower.contains('starting') || lower.contains('running') || lower.contains('executing')) {
      return const Icon(Icons.circle, size: 7, color: Color(0xFF007AFF));
    }
    return const Icon(Icons.circle, size: 7, color: Color(0x30FFFFFF));
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
        builder: (_) => ExecutionHistoryPage(workflowId: provider.workflow.id),
      ),
    );
  }

  Future<void> _importWorkflow(BuildContext context, WorkflowProvider provider) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.simplen8nWorkflowImported, style: const TextStyle(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.simplen8nImportFailed(e.toString()), style: const TextStyle(fontSize: 13)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
        dialogTitle: AppLocalizations.of(context)!.simplen8nExportWorkflow,
        fileName: '$name.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (outputPath == null) return;

      await File(outputPath).writeAsString(jsonStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.simplen8nExportedTo(outputPath), style: const TextStyle(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.simplen8nExportFailed(e.toString()), style: const TextStyle(fontSize: 13)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}

// ============================================================================
// Load Workflow Dialog
// ============================================================================

class _LoadWorkflowDialog extends StatefulWidget {
  final void Function(String id) onLoad;
  final Future<void> Function(String id) onDelete;
  final String? currentId;

  const _LoadWorkflowDialog({required this.onLoad, required this.onDelete, this.currentId});

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
      title: Text(AppLocalizations.of(context)!.simplen8nLoadWorkflow, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: 440,
        height: 380,
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _summaries == null || _summaries!.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.simplen8nNoSavedWorkflows, style: TextStyle(fontSize: 14, color: cs.onSurface.withAlpha(80))))
                : ListView.builder(
                    itemCount: _summaries!.length,
                    itemBuilder: (_, i) {
                      final s = _summaries![i];
                      final isCurrent = s.id == widget.currentId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: isCurrent ? cs.primary.withAlpha(8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => widget.onLoad(s.id),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: isCurrent ? cs.primary.withAlpha(40) : cs.outlineVariant.withAlpha(30)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [cs.primary.withAlpha(20), cs.primary.withAlpha(5)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(Icons.account_tree_rounded, size: 20, color: cs.primary.withAlpha(180)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.1)),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${s.nodeCount} nodes  •  ${_formatDate(s.updatedAt)}',
                                          style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(80)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: cs.error.withAlpha(150),
                                    onPressed: () async {
                                      await widget.onDelete(s.id);
                                      await _refresh();
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  FilledButton(
                                    onPressed: () => widget.onLoad(s.id),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      minimumSize: const Size(0, 34),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                      elevation: 0,
                                    ),
                                    child: Text(AppLocalizations.of(context)!.simplen8nLoad, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
          child: Text(AppLocalizations.of(context)!.simplen8nClose, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// Toolbar Button
// ============================================================================

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final Color? color;
  final bool active;
  final bool highlight;
  final bool loading;
  final VoidCallback? onTap;
  final ColorScheme cs;

  const _ToolBtn({
    required this.icon,
    required this.label,
    this.tooltip,
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

    final btn = SizedBox(
      height: 32,
      child: Material(
        color: highlight ? cs.primary.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(effectiveColor.withAlpha(180)),
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 17,
                    color: active ? effectiveColor.withAlpha(disabled ? 50 : 220) : cs.onSurface.withAlpha(50),
                  ),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    loading ? AppLocalizations.of(context)!.simplen8nRunning : label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: active ? effectiveColor.withAlpha(disabled ? 50 : 220) : cs.onSurface.withAlpha(50),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        preferBelow: false,
        verticalOffset: 14,
        decoration: BoxDecoration(
          color: cs.onSurface.withAlpha(220),
          borderRadius: BorderRadius.circular(7),
        ),
        textStyle: TextStyle(fontSize: 11, color: cs.surface, fontWeight: FontWeight.w500),
        child: btn,
      );
    }
    return btn;
  }
}

// ============================================================================
// Dot Grid Background
// ============================================================================

class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  _DotGridPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    const radius = 1.0;
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
