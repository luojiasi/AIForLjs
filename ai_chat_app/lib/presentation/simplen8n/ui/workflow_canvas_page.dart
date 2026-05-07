import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../providers/workflow_provider.dart';
import '../engine/execution_engine.dart';
import '../converters/canvas_converter.dart';
import 'node_widget.dart';
import 'node_palette.dart';
import 'node_config_panel.dart';

/// 工作流编辑主页面
class WorkflowCanvasPage extends StatefulWidget {
  const WorkflowCanvasPage({super.key});

  @override
  State<WorkflowCanvasPage> createState() => _WorkflowCanvasPageState();
}

class _WorkflowCanvasPageState extends State<WorkflowCanvasPage> {
  bool _showLogs = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkflowProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // 左侧节点面板
          NodePalette(
            nodes: provider.availableTypes,
            onAddNode: (nodeType) {
              final dx = 250.0 + (DateTime.now().millisecond % 200).toDouble();
              final dy = 150.0 + (DateTime.now().millisecond % 200).toDouble();
              provider.addNode(nodeType, Offset(dx, dy));
            },
          ),

          // 中间主区域
          Expanded(
            child: Column(
              children: [
                _buildToolbar(provider, cs),
                Expanded(child: _buildCanvas(provider, cs)),
                if (_showLogs) _buildLogPanel(provider, cs),
              ],
            ),
          ),

          // 右侧配置面板
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

  Widget _buildToolbar(WorkflowProvider provider, ColorScheme cs) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            provider.workflow.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: provider.isExecuting ? Icons.stop : Icons.play_arrow,
            label: provider.isExecuting ? 'Stop' : 'Execute',
            color: provider.isExecuting ? Colors.red : Colors.green,
            onPressed: provider.isExecuting
                ? null
                : () => provider.executeWorkflow(
                      executor: (wf) => ExecutionEngine().execute(wf),
                    ),
          ),
          const SizedBox(width: 4),
          _ToolbarButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red,
            onPressed: provider.selectedNodeId != null
                ? () => provider.deleteSelectedNode()
                : null,
          ),
          const SizedBox(width: 4),
          _ToolbarButton(
            icon: Icons.cleaning_services_outlined,
            label: 'Clear',
            color: cs.onSurface,
            onPressed: () => provider.clearCanvas(),
          ),
          const Spacer(),
          _ToolbarButton(
            icon: Icons.code,
            label: 'JSON',
            color: cs.primary,
            onPressed: () => _showJsonDialog(provider),
          ),
          const SizedBox(width: 4),
          _ToolbarButton(
            icon: _showLogs ? Icons.terminal : Icons.terminal_outlined,
            label: 'Logs',
            color: _showLogs ? cs.primary : cs.onSurface.withAlpha(150),
            onPressed: () => setState(() => _showLogs = !_showLogs),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(WorkflowProvider provider, ColorScheme cs) {
    final nodeCount = provider.canvasController.nodeIds.length;

    return Stack(
      children: [
        flow.NodeFlowEditor<Simplen8nCanvasData, void>(
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
              onCreated: (_) => provider.syncToWorkflow(),
              onDeleted: (_) => provider.syncToWorkflow(),
            ),
          ),
        ),
        // 空状态提示
        if (nodeCount == 0)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 48,
                    color: cs.primary.withAlpha(60)),
                const SizedBox(height: 16),
                Text(
                  'Click nodes from the left panel\nto build your workflow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: cs.onSurface.withAlpha(80),
                  ),
                ),
              ],
            ),
          ),
      ],
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
    );
  }

  Widget _buildLogPanel(WorkflowProvider provider, ColorScheme cs) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 14,
                    color: cs.onSurface.withAlpha(150)),
                const SizedBox(width: 6),
                Text('Execution Logs',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withAlpha(180))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: provider.executionLogs.length,
              itemBuilder: (_, i) {
                return Text(
                  provider.executionLogs[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: cs.onSurface.withAlpha(180),
                    height: 1.4,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showJsonDialog(WorkflowProvider provider) {
    final jsonStr = provider.toJsonString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workflow JSON'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SelectableText(
            jsonStr,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// 工具栏按钮
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 32,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16,
            color: disabled ? cs.onSurface.withAlpha(80) : color),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: disabled ? cs.onSurface.withAlpha(80) : color,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
