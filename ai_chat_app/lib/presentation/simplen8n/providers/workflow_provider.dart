import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../models/workflow_model.dart';
import '../models/node_type.dart';
import '../models/execution_data.dart';
import '../converters/canvas_converter.dart';

/// 工作流编辑器状态管理
class WorkflowProvider extends ChangeNotifier {
  final CanvasConverter converter;
  late final flow.NodeFlowController<Simplen8nCanvasData, void> canvasController;

  /// 工作流数据
  Workflow _workflow;

  /// 选中的节点 ID
  String? _selectedNodeId;

  /// 执行状态
  ExecutionResult? _executionResult;
  bool _isExecuting = false;
  List<String> _executionLogs = [];

  /// 节点类型定义表
  final Map<String, NodeTypeDefinition> _availableTypes;

  WorkflowProvider({
    required Map<String, NodeTypeDefinition> availableTypes,
    Workflow? existingWorkflow,
  })  : _availableTypes = availableTypes,
        converter = CanvasConverter(),
        _workflow = existingWorkflow ?? Workflow(id: _generateId()) {
    _initCanvas();
  }

  //===========================================================================
  // Getters
  //===========================================================================

  Workflow get workflow => _workflow;
  String? get selectedNodeId => _selectedNodeId;
  ExecutionResult? get executionResult => _executionResult;
  bool get isExecuting => _isExecuting;
  List<String> get executionLogs => _executionLogs;
  List<NodeTypeDefinition> get availableTypes => _availableTypes.values.toList();

  NodeTypeDefinition? nodeTypeDef(String type) => _availableTypes[type];

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

  /// 从画布同步到 Workflow 模型
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
    final ports = <flow.Port>[];
    for (final p in nodeType.inputs) {
      ports.add(flow.Port(
        id: p.id,
        name: p.name,
        position: flow.PortPosition.left,
        type: flow.PortType.input,
      ));
    }
    for (final p in nodeType.outputs) {
      ports.add(flow.Port(
        id: p.id,
        name: p.name,
        position: flow.PortPosition.right,
        type: flow.PortType.output,
      ));
    }

    final id = _generateId();
    final canvasNode = flow.Node<Simplen8nCanvasData>(
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

    canvasController.addNode(canvasNode);
    _addLog('Added node: ${nodeType.displayName}');
    syncToWorkflow();
  }

  void selectNode(String? nodeId) {
    _selectedNodeId = nodeId;
    notifyListeners();
  }

  void updateNodeParameter(String nodeId, String key, dynamic value) {
    final node = canvasController.getNode(nodeId);
    if (node == null) return;

    final updatedData = Simplen8nCanvasData(
      nodeType: node.data.nodeType,
      label: node.data.label,
      category: node.data.category,
      parameters: {...node.data.parameters, key: value},
    );

    _replaceNode(nodeId, updatedData);
    syncToWorkflow();
    _addLog('Updated $key = $value');
  }

  void updateNodeName(String nodeId, String name) {
    final node = canvasController.getNode(nodeId);
    if (node == null) return;

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
      canvasController.removeNode(_selectedNodeId!);
      _selectedNodeId = null;
      syncToWorkflow();
      _addLog('Deleted node');
    }
  }

  void clearCanvas() {
    final ids = canvasController.nodeIds.toList();
    for (final id in ids) {
      canvasController.removeNode(id);
    }
    _selectedNodeId = null;
    syncToWorkflow();
    _addLog('Cleared canvas');
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
    _executionLogs = [];
    _addLog('Starting workflow execution...');
    notifyListeners();

    try {
      syncToWorkflow();
      final result = await executor(_workflow);
      _executionResult = result;

      _addLog(result.status.name == 'success'
          ? 'Workflow completed successfully in ${result.durationMs}ms'
          : 'Workflow failed: ${result.error}');

      for (final entry in result.nodeResults.entries) {
        final s = entry.value.status.name;
        _addLog('  Node ${entry.key}: $s (${entry.value.durationMs}ms)');
      }
    } catch (e) {
      _addLog('Execution error: $e');
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
  // Helpers
  //===========================================================================

  void _addLog(String msg) {
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
