import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../models/workflow_model.dart';
import '../models/node_type.dart';
import '../models/execution_data.dart';
import '../converters/canvas_converter.dart';
import '../engine/execution_engine.dart';
import '../services/workflow_storage_service.dart';
import '../services/execution_storage_service.dart';
import '../engine/triggers/trigger_manager.dart';
import 'history_manager.dart';

/// 工作流编辑器状态管理
class WorkflowProvider extends ChangeNotifier {
  final CanvasConverter converter;
  final WorkflowHistoryManager _history = WorkflowHistoryManager();
  late final flow.NodeFlowController<Simplen8nCanvasData, void> canvasController;

  /// 工作流数据
  Workflow _workflow;

  /// 选中的节点 ID
  String? _selectedNodeId;

  /// 执行状态
  ExecutionResult? _executionResult;
  bool _isExecuting = false;
  final List<String> _executionLogs = [];

  /// 最近一次错误（用于 UI 展示）
  String? _lastError;

  /// 剪贴板节点（内部实现 copy/cut/paste）
  List<Map<String, dynamic>>? _clipboard;

  /// 节点类型定义表
  final Map<String, NodeTypeDefinition> _availableTypes;

  WorkflowProvider({
    required Map<String, NodeTypeDefinition> availableTypes,
    Workflow? existingWorkflow,
  })  : _availableTypes = availableTypes,
        converter = CanvasConverter(),
        _workflow = existingWorkflow ?? Workflow(id: _generateId()) {
    _initCanvas();
    _history.record(_workflow.copyWith());
  }

  //===========================================================================
  // Getters
  //===========================================================================

  Workflow get workflow => _workflow;
  String? get selectedNodeId => _selectedNodeId;
  ExecutionResult? get executionResult => _executionResult;
  bool get isExecuting => _isExecuting;
  List<String> get executionLogs => _executionLogs;
  String? get lastError => _lastError;
  List<NodeTypeDefinition> get availableTypes => _availableTypes.values.toList();

  NodeTypeDefinition? nodeTypeDef(String type) => _availableTypes[type];

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  List<flow.Node<Simplen8nCanvasData>> get canvasNodes {
    return canvasController.nodeIds
        .map((id) => canvasController.getNode(id)!)
        .toList();
  }

  List<flow.Connection<void>> get canvasConnections {
    return canvasController.connectionIds
        .map((id) => canvasController.getConnection(id)!)
        .toList();
  }

  flow.Node<Simplen8nCanvasData>? get selectedCanvasNode {
    if (_selectedNodeId == null) return null;
    return canvasController.getNode(_selectedNodeId!);
  }

  WorkflowNode? get selectedWorkflowNode {
    if (_selectedNodeId == null) return null;
    try {
      return _workflow.nodes.firstWhere((n) => n.id == _selectedNodeId);
    } catch (_) {
      return null;
    }
  }

  //===========================================================================
  // Canvas 初始化
  //===========================================================================

  void _initCanvas() {
    final canvasNodes = _workflow.nodes
        .map((n) => converter.toCanvasNode(n, typeDef: _availableTypes[n.type]))
        .toList();
    final canvasConns = converter.toCanvasConnections(_workflow.connections);

    canvasController = flow.NodeFlowController<Simplen8nCanvasData, void>(
      nodes: canvasNodes,
      connections: canvasConns,
    );
  }

  // ==========================================================================
  // Undo/Redo
  // ==========================================================================

  void undo() {
    syncToWorkflow();
    final state = _history.undo();
    if (state != null) {
      _loadGraphFromWorkflow(state);
      addLog('Undo');
    }
  }

  void redo() {
    syncToWorkflow();
    final state = _history.redo();
    if (state != null) {
      _loadGraphFromWorkflow(state);
      addLog('Redo');
    }
  }

  /// 在变异操作前录制当前状态（供 canvas 事件回调使用）
  void recordBeforeMutation() => _recordBeforeMutation();

  void _recordBeforeMutation() {
    syncToWorkflow();
    _history.record(_workflow.copyWith());
  }

  /// 从 Workflow 模型完全重建画布
  void _loadGraphFromWorkflow(Workflow wf) {
    _workflow = wf;
    _selectedNodeId = null;
    final canvasNodes = wf.nodes
        .map((n) => converter.toCanvasNode(n, typeDef: _availableTypes[n.type]))
        .toList();
    final canvasConns = converter.toCanvasConnections(wf.connections);
    canvasController.loadGraph(flow.NodeGraph<Simplen8nCanvasData, void>(
      nodes: canvasNodes,
      connections: canvasConns,
    ));
    notifyListeners();
  }

  // ==========================================================================
  // Internal Clipboard
  // ==========================================================================

  void copySelectedNode() {
    final node = selectedWorkflowNode;
    if (node == null) return;
    _clipboard = [node.toJson()];
    addLog('Copied node');
  }

  void cutSelectedNode() {
    copySelectedNode();
    deleteSelectedNode();
    addLog('Cut node');
  }

  void pasteNode() {
    if (_clipboard == null || _clipboard!.isEmpty) return;
    for (final json in _clipboard!) {
      final node = WorkflowNode.fromJson(json);
      final offsetX = 60 + (DateTime.now().millisecond % 80);
      final offsetY = 60 + (DateTime.now().millisecond % 80);
      final newPos = [node.position[0] + offsetX, node.position[1] + offsetY];
      final pasted = WorkflowNode(
        id: _generateId(),
        name: '${node.name} (copy)',
        type: node.type,
        position: newPos,
        parameters: Map<String, dynamic>.from(node.parameters),
      );
      _addWithoutHistory(_availableTypes[node.type]!, converter.toCanvasNode(pasted,
          typeDef: _availableTypes[node.type]));
    }
    syncToWorkflow();
    addLog('Pasted ${_clipboard!.length} node(s)');
  }

  // ==========================================================================
  // 从画布同步到 Workflow 模型
  // ==========================================================================

  void syncToWorkflow() {
    final nodes = canvasNodes
        .map((n) => converter.fromCanvasNode(n))
        .toList();
    final connections = converter.fromCanvasConnections(canvasConnections);

    _workflow = _workflow.copyWith(
      nodes: nodes,
      connections: connections,
    );

    notifyListeners();
  }

  //===========================================================================
  // 节点操作
  //===========================================================================

  void addNode(NodeTypeDefinition nodeType, Offset position) {
    _recordBeforeMutation();
    _addWithoutHistory(nodeType, _buildCanvasNode(nodeType, _generateId(), position));
    addLog('Added node: ${nodeType.displayName}');
    syncToWorkflow();
  }

  void _addWithoutHistory(NodeTypeDefinition nodeType, flow.Node<Simplen8nCanvasData> canvasNode) {
    canvasController.addNode(canvasNode);
  }

  flow.Node<Simplen8nCanvasData> _buildCanvasNode(NodeTypeDefinition nodeType, String id, Offset position) {
    final ports = <flow.Port>[];
    for (final p in nodeType.inputs) {
      ports.add(flow.Port(id: p.id, name: p.name, position: flow.PortPosition.left, type: flow.PortType.input));
    }
    for (final p in nodeType.outputs) {
      ports.add(flow.Port(id: p.id, name: p.name, position: flow.PortPosition.right, type: flow.PortType.output));
    }
    return flow.Node<Simplen8nCanvasData>(
      id: id,
      type: nodeType.type,
      position: position,
      data: Simplen8nCanvasData(
        nodeType: nodeType.type,
        label: nodeType.displayName,
        category: nodeType.category,
        parameters: _defaultParams(nodeType),
      ),
      ports: ports,
    );
  }

  void selectNode(String? nodeId) {
    _selectedNodeId = nodeId;
    notifyListeners();
  }

  void updateNodeParameter(String nodeId, String key, dynamic value) {
    final node = canvasController.getNode(nodeId);
    if (node == null) return;
    _recordBeforeMutation();

    final updatedData = Simplen8nCanvasData(
      nodeType: node.data.nodeType,
      label: node.data.label,
      category: node.data.category,
      parameters: {...node.data.parameters, key: value},
    );

    _replaceNode(nodeId, updatedData);
    syncToWorkflow();
    addLog('Updated $key = $value');
  }

  void updateNodeName(String nodeId, String name) {
    final node = canvasController.getNode(nodeId);
    if (node == null) return;
    _recordBeforeMutation();

    final updatedData = Simplen8nCanvasData(
      nodeType: node.data.nodeType,
      label: name,
      category: node.data.category,
      parameters: node.data.parameters,
    );
    _replaceNode(nodeId, updatedData);
    syncToWorkflow();
  }

  void _replaceNode(String nodeId, Simplen8nCanvasData newData) {
    final node = canvasController.getNode(nodeId);
    if (node == null) return;
    final newNode = flow.Node<Simplen8nCanvasData>(
      id: node.id,
      type: node.type,
      position: node.position.value,
      data: newData,
      ports: [...node.ports],
      size: node.size.value,
    );
    canvasController.removeNode(nodeId);
    canvasController.addNode(newNode);
  }

  void deleteSelectedNode() {
    if (_selectedNodeId != null) {
      _recordBeforeMutation();
      canvasController.removeNode(_selectedNodeId!);
      _selectedNodeId = null;
      syncToWorkflow();
      addLog('Deleted node');
    }
  }

  void clearCanvas() {
    _recordBeforeMutation();
    final ids = canvasController.nodeIds.toList();
    for (final id in ids) {
      canvasController.removeNode(id);
    }
    _selectedNodeId = null;
    syncToWorkflow();
    addLog('Cleared canvas');
  }

  //===========================================================================
  // 工作流执行 (Phase 0: 同步执行)
  //===========================================================================

  Future<void> executeWorkflow({
    required Future<ExecutionResult> Function(Workflow) executor,
  }) async {
    if (_isExecuting) return;

    _isExecuting = true;
    _executionResult = null;
    _executionLogs.clear();
    addLog('Starting workflow execution...');
    notifyListeners();

    try {
      syncToWorkflow();
      final result = await executor(_workflow);
      _executionResult = result;

      if (result.status == ExecutionStatus.error) {
        _lastError = result.error;
      } else {
        _lastError = null;
      }

      addLog(result.status.name == 'success'
          ? 'Workflow completed successfully in ${result.durationMs}ms'
          : 'Workflow failed: ${result.error}');

      for (final entry in result.nodeResults.entries) {
        final s = entry.value.status.name;
        addLog('  Node ${entry.key}: $s (${entry.value.durationMs}ms)');
      }

      // Auto-save execution history
      await _saveExecutionResult(result);
    } catch (e) {
      _lastError = e.toString();
      addLog('Execution error: $e');
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  //===========================================================================
  // 序列化
  //===========================================================================

  String toJsonString() {
    syncToWorkflow();
    return const JsonEncoder.withIndent('  ').convert(_workflow.toJson());
  }

  //===========================================================================
  // 持久化
  //===========================================================================

  final WorkflowStorageService _storage = WorkflowStorageService();

  /// Save the current workflow to disk.
  Future<void> saveWorkflow() async {
    syncToWorkflow();
    await _storage.save(_workflow);
    addLog('Saved workflow: ${_workflow.name}');
    notifyListeners();
  }

  /// Load a workflow by ID, replacing the current state.
  Future<void> loadWorkflow(String id) async {
    final wf = await _storage.load(id);
    if (wf != null) {
      _loadGraphFromWorkflow(wf);
      _history.clear();
      _history.record(wf.copyWith());
      addLog('Loaded workflow: ${wf.name}');
    }
  }

  /// Delete a workflow from disk.
  Future<void> deleteWorkflow(String id) async {
    await _storage.delete(id);
    addLog('Deleted workflow: $id');
  }

  /// List all saved workflow summaries.
  static Future<List<WorkflowSummary>> listWorkflows() async {
    return WorkflowStorageService().listSummaries();
  }

  /// Import a workflow from a JSON string.
  void importFromJson(String jsonStr) {
    final wf = _storage.importFromJson(jsonStr);
    _loadGraphFromWorkflow(wf);
    _history.clear();
    _history.record(wf.copyWith());
    addLog('Imported workflow: ${wf.name}');
  }

  /// Export the current workflow as a JSON string.
  Future<String> exportToJson() async {
    syncToWorkflow();
    return _storage.exportJson(_workflow);
  }

  //===========================================================================
  // 执行历史
  //===========================================================================

  final ExecutionStorageService _execStorage = ExecutionStorageService();

  Future<void> _saveExecutionResult(ExecutionResult result) async {
    await _execStorage.save(
      result,
      workflowId: _workflow.id,
    );
  }

  /// Load execution history for the current workflow.
  Future<List<ExecutionSummary>> loadHistory() async {
    return _execStorage.listSummaries(workflowId: _workflow.id);
  }

  /// Replay a previous execution using the same workflow graph.
  Future<void> replayExecution(
    String executionId, {
    required Future<ExecutionResult> Function(Workflow) executor,
  }) async {
    final prev = await _execStorage.load(executionId);
    if (prev == null) {
      addLog('Execution $executionId not found');
      return;
    }

    _isExecuting = true;
    _executionResult = null;
    addLog('Replaying execution $executionId...');
    notifyListeners();

    try {
      syncToWorkflow();
      final result = await executor(_workflow);
      _executionResult = result;

      addLog(result.status.name == 'success'
          ? 'Replay completed successfully in ${result.durationMs}ms'
          : 'Replay failed: ${result.error}');
    } catch (e) {
      _lastError = e.toString();
      addLog('Replay error: $e');
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  /// Load all execution summaries (across all workflows).
  static Future<List<ExecutionSummary>> loadAllHistory() async {
    return ExecutionStorageService().listSummaries();
  }

  //===========================================================================
  // Trigger 激活/停用
  //===========================================================================

  /// Whether this workflow has active triggers.
  bool get isActive => TriggerManager.instance.isActive(_workflow.id);

  /// Activate all trigger nodes in the current workflow.
  Future<void> activateWorkflow() async {
    syncToWorkflow();
    await TriggerManager.instance.activateWorkflow(
      _workflow,
      onFire: (data) async {
        // Reload latest workflow from storage before executing
        final stored = await _storage.load(_workflow.id);
        final wf = stored ?? _workflow;

        final result = await ExecutionEngine().execute(
          wf,
          workflowId: wf.id,
          workflowName: wf.name,
        );
        await _execStorage.save(result, workflowId: wf.id);

        _executionResult = result;
        addLog('Triggered execution: ${result.status.name} (${result.durationMs}ms)');
        notifyListeners();
      },
    );

    _workflow.active = true;
    addLog('Workflow activated');
    notifyListeners();
  }

  /// Deactivate all trigger nodes for the current workflow.
  Future<void> deactivateWorkflow() async {
    await TriggerManager.instance.deactivateWorkflow(_workflow.id);
    _workflow.active = false;
    addLog('Workflow deactivated');
    notifyListeners();
  }

  //===========================================================================
  // Helpers
  //===========================================================================

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void addLog(String msg) {
    _executionLogs.add('[${DateTime.now().toIso8601String()}] $msg');
  }

  Map<String, dynamic> _defaultParams(NodeTypeDefinition def) {
    final params = <String, dynamic>{};
    for (final schema in def.parameterSchema) {
      if (schema.defaultValue != null) {
        params[schema.name] = schema.defaultValue;
      }
    }
    return params;
  }

  static String _generateId() {
    final r = Random();
    return 'node_${DateTime.now().millisecondsSinceEpoch}_${r.nextInt(9999)}';
  }
}
