import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../models/workflow_model.dart';
import '../models/execution_data.dart';
import 'execution_context.dart';
import 'dag_analyzer.dart';

// ============================================================================
// 执行堆栈条目
// ============================================================================

class ExecutionStackItem {
  final String nodeId;
  final String sourcePortId;
  final List<NodeExecutionData> data;

  const ExecutionStackItem({
    required this.nodeId,
    required this.sourcePortId,
    this.data = const [],
  });
}

// ============================================================================
// 主执行引擎 (Phase 1 — 完整 processRunExecutionData)
// ============================================================================

class ExecutionEngine {
  final ExecutionContext _context;
  final Map<String, NodeExecutionResult> _nodeResults = {};
  final List<ExecutionStackItem> _stack = [];

  /// 等待多输入聚合的节点数据
  /// {nodeId: {inputIndex: [data, ...]}}
  final Map<String, Map<int, List<NodeExecutionData>>> _waitingExecution = {};

  final Map<String, int> _receivedInputCount = {};

  DagAnalyzer? _dag;

  ExecutionEngine({ExecutionContext? context})
      : _context = context ?? ExecutionContext();

  // ===========================================================================
  // 主入口
  // ===========================================================================

  Future<ExecutionResult> execute(Workflow workflow,
      {String? workflowId, String? workflowName}) async {
    final executionId = _generateId();
    final startedAt = DateTime.now();

    developer.log('[Phase 1] Starting execution: $executionId');

    try {
      // 0. 校验
      if (workflow.nodes.isEmpty) {
        return _result(executionId, ExecutionStatus.error, startedAt,
            error: 'Workflow has no nodes');
      }

      // 0a. 循环检测
      _dag = DagAnalyzer(workflow);
      if (_dag!.hasCycle()) {
        final cycles = _dag!.findAllCycles();
        final cycleStr = cycles
            .map((c) => c.join(' → '))
            .join('\n  ');
        return _result(executionId, ExecutionStatus.error, startedAt,
            error: 'Workflow contains cycle(s):\n  $cycleStr');
      }

      // 1. 注入工作流变量到上下文
      _context.setVariable('workflow', {
        'id': workflowId ?? workflow.id,
        'name': workflowName ?? workflow.name,
      });

      // 2. 找到起始节点并初始化执行栈
      final startNodes = _dag!.sourceNodes;
      if (startNodes.isEmpty) {
        return _result(executionId, ExecutionStatus.error, startedAt,
            error: 'No start node found (all nodes have incoming connections)');
      }

      for (final nodeId in startNodes) {
        _stack.add(ExecutionStackItem(
          nodeId: nodeId,
          sourcePortId: 'init',
          data: [const NodeExecutionData()],
        ));
      }

      // 3. 主执行循环
      while (_stack.isNotEmpty) {
        final item = _stack.removeLast();

        // 跳过已执行的节点（除非是允许多次输入的节点）
        if (_nodeResults.containsKey(item.nodeId)) {
          final existing = _nodeResults[item.nodeId]!;
          if (existing.status == NodeExecutionStatus.success ||
              existing.status == NodeExecutionStatus.error) {
            // Phase 1: 多输入节点会继续聚合
            final node = _getNode(workflow, item.nodeId);
            if (node != null && _dag!.isMultiInput(item.nodeId)) {
              _aggregateInput(node, item);
            }
            continue;
          }
        }

        await _processNode(workflow, item);
      }

      // 4. 检查是否有未完成的等待节点
      if (_waitingExecution.isNotEmpty) {
        final waitingIds = _waitingExecution.keys.join(', ');
        developer.log('[Phase 1] Execution paused — waiting nodes: $waitingIds');
      }

      return _result(executionId, ExecutionStatus.success, startedAt);
    } catch (e, stack) {
      developer.log('[Phase 1] Fatal error: $e\n$stack');
      return _result(executionId, ExecutionStatus.error, startedAt,
          error: e.toString());
    }
  }

  // ===========================================================================
  // 节点处理
  // ===========================================================================

  Future<void> _processNode(
      Workflow workflow, ExecutionStackItem item) async {
    final node = _getNode(workflow, item.nodeId);
    if (node == null) return;

    final nodeStart = DateTime.now();
    _nodeResults[item.nodeId] = NodeExecutionResult(
      nodeId: item.nodeId,
      status: NodeExecutionStatus.running,
    );

    developer.log('[Phase 1] Executing: ${node.name} (${node.type})');

    // 注入凭据
    _context.injectCredentials(node.parameters);

    // 重试循环
    List<NodeExecutionData> output = [];
    int attempt = 0;
    Exception? lastError;

    while (attempt <= node.retryOnFail) {
      attempt++;
      try {
        output = await _executeNode(node, item.data, _context);

        final duration = DateTime.now().difference(nodeStart).inMilliseconds;
        _nodeResults[item.nodeId] = NodeExecutionResult(
          nodeId: item.nodeId,
          status: NodeExecutionStatus.success,
          output: output,
          durationMs: duration,
          retryCount: attempt - 1,
        );

        developer
            .log('[Phase 1] Node ${node.name} OK (${duration}ms, attempt $attempt)');

        // 将输出传递给下游
        _pushDownstream(workflow, node, output);
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        developer.log('[Phase 1] Node ${node.name} attempt $attempt failed: $e');

        if (attempt <= node.retryOnFail &&
            node.waitBetweenTries > 0) {
          await Future.delayed(
              Duration(milliseconds: node.waitBetweenTries));
        }
      }
    }

    // 所有重试都失败了
    final duration = DateTime.now().difference(nodeStart).inMilliseconds;
    _nodeResults[item.nodeId] = NodeExecutionResult(
      nodeId: item.nodeId,
      status: NodeExecutionStatus.error,
      error: lastError?.toString() ?? 'Unknown error',
      durationMs: duration,
      retryCount: attempt - 1,
    );

    if (!node.continueOnFail) {
      // 不再推送到下游，执行栈返回时错误会向上传播
      developer
          .log('[Phase 1] Node ${node.name} FAILED after $attempt attempts');
    }
  }

  // ===========================================================================
  // 推送到下游（含多输入聚合逻辑）
  // ===========================================================================

  void _pushDownstream(
      Workflow workflow, WorkflowNode node, List<NodeExecutionData> data) {
    // 保存节点输出
    if (data.isNotEmpty) {
      _context.setNodeOutput(node.id, data.first.json);
    }

    final outConns =
        workflow.connections[node.id];
    if (outConns == null || outConns.isEmpty) return;

    for (final portEntry in outConns.entries) {
      final sourcePortId = portEntry.key;
      final rules = portEntry.value;

      for (final rule in rules) {
        final targetNode = _getNode(workflow, rule.node);
        if (targetNode == null) continue;

        // 多输入节点：聚合等待
        if (_isMultiInputNode(targetNode)) {
          _waitingExecution
              .putIfAbsent(rule.node, () => {})
              .putIfAbsent(rule.index, () => [])
              .addAll(data);

          _receivedInputCount[rule.node] =
              (_receivedInputCount[rule.node] ?? 0) + 1;

          final totalInputs = _dag!.inDegree[rule.node] ?? 1;
          if (_receivedInputCount[rule.node]! >= totalInputs) {
            // 所有输入到齐，合并数据
            final merged = _mergeInputs(rule.node);
            _stack.add(ExecutionStackItem(
              nodeId: rule.node,
              sourcePortId: 'merged',
              data: merged,
            ));
            _waitingExecution.remove(rule.node);
            _receivedInputCount.remove(rule.node);
          }
        } else {
          // 单输入节点：直接推入执行栈
          _stack.add(ExecutionStackItem(
            nodeId: rule.node,
            sourcePortId: sourcePortId,
            data: data,
          ));
        }
      }
    }
  }

  /// 判断是否是多输入节点（IF/Switch 输出不算）
  bool _isMultiInputNode(WorkflowNode node) {
    // IF、Switch 等逻辑节点的下游不算"需要聚合"，它们是分支分发
    // Merge 节点是真正的多输入聚合节点
    switch (node.type) {
      case 'merge':
        return true;
      default:
        return false;
    }
  }

  /// 聚合多路输入数据
  List<NodeExecutionData> _mergeInputs(String nodeId) {
    final inputMap = _waitingExecution[nodeId]!;
    final allData = <NodeExecutionData>[];

    for (final entry in inputMap.entries) {
      allData.addAll(entry.value);
    }

    return allData;
  }

  /// 聚合输入到节点（增量模式 — 每次上游输出到达时追加）
  void _aggregateInput(WorkflowNode node, ExecutionStackItem item) {
    _waitingExecution
        .putIfAbsent(node.id, () => {})
        .putIfAbsent(0, () => [])
        .addAll(item.data);

    _receivedInputCount[node.id] =
        (_receivedInputCount[node.id] ?? 0) + 1;
  }

  // ===========================================================================
  // 节点执行分发
  // ===========================================================================

  Future<List<NodeExecutionData>> _executeNode(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    // 设置当前输入上下文
    if (inputData.isNotEmpty) {
      context.setCurrentInput(inputData.first.json);
    }

    switch (node.type) {
      case 'manual_trigger':
        return [const NodeExecutionData(json: {})];

      case 'http_request':
        return _executeHttpRequest(node, inputData, context);

      case 'set':
        return _executeSet(node, inputData, context);

      case 'if':
        return _executeIf(node, inputData, context);

      case 'merge':
        return _executeMerge(node, inputData, context);

      default:
        throw Exception('Unknown node type: ${node.type}');
    }
  }

  // ===========================================================================
  // HTTP Request
  // ===========================================================================

  Future<List<NodeExecutionData>> _executeHttpRequest(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final method = node.parameters['method'] as String? ?? 'GET';
    final rawUrl = node.parameters['url'] as String? ?? '';
    final url = context.evaluateTemplate(rawUrl);

    Map<String, String> headers = {};
    try {
      final raw = node.parameters['headers'] as String? ?? '{}';
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      headers = parsed.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {}

    String? body;
    if (node.parameters['body'] is String &&
        (node.parameters['body'] as String).isNotEmpty) {
      body = context.evaluateTemplate(node.parameters['body'] as String);
    }

    final uri = Uri.parse(url);
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: body);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = response.body;
    }

    return [
      NodeExecutionData(json: {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
      }),
    ];
  }

  // ===========================================================================
  // Set
  // ===========================================================================

  Future<List<NodeExecutionData>> _executeSet(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final rawValues = node.parameters['values'] as String? ?? '{}';

    Map<String, dynamic> values;
    try {
      values = Map<String, dynamic>.from(jsonDecode(rawValues));
    } catch (_) {
      values = {};
    }

    final result = Map<String, dynamic>.from(context.currentInput);
    for (final entry in values.entries) {
      if (entry.value is String) {
        final evaluated =
            context.evaluateTemplate(entry.value as String);
        // 尝试解析为 JSON
        try {
          result[entry.key] = jsonDecode(evaluated);
        } catch (_) {
          result[entry.key] = evaluated;
        }
      } else {
        result[entry.key] = entry.value;
      }
    }

    return [NodeExecutionData(json: result)];
  }

  // ===========================================================================
  // IF 节点 — 条件分支
  // ===========================================================================

  Future<List<NodeExecutionData>> _executeIf(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final rawCondition = node.parameters['condition'] as String? ?? 'true';
    final evaluated = context.evaluate(rawCondition);

    final condition = evaluated == true ||
        evaluated == 'true' ||
        (evaluated is num && evaluated != 0) ||
        (evaluated is String && evaluated.isNotEmpty && evaluated != 'false');

    developer
        .log('[IF] Condition "$rawCondition" → $evaluated → $condition');

    return [
      NodeExecutionData(
        json: {...context.currentInput, '_branch': condition},
      ),
    ];
  }

  // ===========================================================================
  // Merge 节点 — 多输入合并
  // ===========================================================================

  Future<List<NodeExecutionData>> _executeMerge(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final mode = node.parameters['mode'] as String? ?? 'combine';

    switch (mode) {
      case 'passThrough':
        return inputData.isNotEmpty
            ? [inputData.first]
            : [const NodeExecutionData()];

      case 'combine':
      default:
        final merged = <String, dynamic>{};
        merged['inputCount'] = inputData.length;
        for (var i = 0; i < inputData.length; i++) {
          merged['input_$i'] = inputData[i].json;
        }
        return [NodeExecutionData(json: merged)];
    }
  }

  // ===========================================================================
  // 辅助方法
  // ===========================================================================

  WorkflowNode? _getNode(Workflow workflow, String nodeId) {
    try {
      return workflow.nodes.firstWhere((n) => n.id == nodeId);
    } catch (_) {
      return null;
    }
  }

  ExecutionResult _result(
    String executionId,
    ExecutionStatus status,
    DateTime startedAt, {
    String? error,
  }) {
    return ExecutionResult(
      executionId: executionId,
      status: status,
      startedAt: startedAt,
      stoppedAt: DateTime.now(),
      nodeResults: Map.from(_nodeResults),
      error: error,
    );
  }

  String _generateId() {
    final r = Random();
    return 'exec_${DateTime.now().millisecondsSinceEpoch}_${r.nextInt(9999)}';
  }
}
