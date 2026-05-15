import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import '../models/workflow_model.dart';
import '../models/execution_data.dart';
import '../services/credential_service.dart';
import '../services/workflow_storage_service.dart';
import 'execution_context.dart';
import 'dag_analyzer.dart';
import 'exceptions.dart';
import 'executor_registry.dart';
import 'parallel_executor.dart';

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
      {String? workflowId, String? workflowName,
       Map<String, dynamic>? triggerData,
       bool useParallel = false,
       bool useIsolates = false}) async {
    // Delegate to parallel executor if requested
    if (useParallel) {
      final parallel = ParallelExecutor(useIsolates: useIsolates);
      return parallel.execute(workflow,
          workflowId: workflowId ?? workflow.id,
          workflowName: workflowName ?? workflow.name,
          triggerData: triggerData);
    }

    final executionId = _generateId();
    final startedAt = DateTime.now();
    final wfId = workflowId ?? workflow.id;
    final wfName = workflowName ?? workflow.name;

    developer.log('[Engine] Starting execution: $executionId ($wfName)');

    try {
      // 0. 校验
      if (workflow.nodes.isEmpty) {
        throw WorkflowValidationException('Workflow has no nodes',
            executionId: executionId);
      }

      // 0b. 解析凭据
      await _resolveCredentials(workflow);

      // 0c. 循环检测
      _dag = DagAnalyzer(workflow);
      if (_dag!.hasCycle()) {
        final cycles = _dag!.findAllCycles();
        final cycleStr =
            cycles.map((c) => c.join(' → ')).join('\n  ');
        throw WorkflowValidationException(
            'Workflow contains cycle(s):\n  $cycleStr',
            executionId: executionId);
      }

      // 1. 注入工作流变量到上下文
      _context.setVariable('workflow', {
        'id': wfId,
        'name': wfName,
      });

      // 2. 找到起始节点并初始化执行栈
      final startNodes = _dag!.sourceNodes;
      if (startNodes.isEmpty) {
        throw WorkflowValidationException(
            'No start node found (all nodes have incoming connections)',
            executionId: executionId);
      }

      final initData = triggerData != null
          ? [NodeExecutionData(json: triggerData)]
          : [const NodeExecutionData()];

      for (final nodeId in startNodes) {
        _stack.add(ExecutionStackItem(
          nodeId: nodeId,
          sourcePortId: 'init',
          data: initData,
        ));
      }

      // 3. 主执行循环
      final timeoutMs = workflow.settings.executionTimeoutMs;
      final stopwatch = Stopwatch()..start();

      while (_stack.isNotEmpty) {
        // Check timeout
        if (timeoutMs > 0 && stopwatch.elapsedMilliseconds > timeoutMs) {
          throw WorkflowValidationException(
            'Workflow execution timed out after ${timeoutMs}ms',
            executionId: executionId,
          );
        }

        final item = _stack.removeLast();

        // 跳过已执行的节点（除非是允许多次输入的节点）
        if (_nodeResults.containsKey(item.nodeId)) {
          final existing = _nodeResults[item.nodeId]!;
          if (existing.status == NodeExecutionStatus.success ||
              existing.status == NodeExecutionStatus.error) {
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
        developer.log('[Engine] Execution paused — waiting nodes: $waitingIds');
      }

      return _result(executionId, ExecutionStatus.success, startedAt,
          workflowId: wfId, workflowName: wfName);
    } on WorkflowValidationException catch (e) {
      developer.log('[Engine] Validation error: $e');
      final result = _result(executionId, ExecutionStatus.error, startedAt,
          error: e.message, workflowId: wfId, workflowName: wfName);
      await _triggerErrorWorkflow(workflow, result);
      return result;
    } on Simplen8nException catch (e) {
      developer.log('[Engine] Execution error: $e');
      final result = _result(executionId, ExecutionStatus.error, startedAt,
          error: e.message, workflowId: wfId, workflowName: wfName);
      await _triggerErrorWorkflow(workflow, result);
      return result;
    } catch (e, stack) {
      developer.log('[Engine] Fatal error: $e\n$stack');
      final result = _result(executionId, ExecutionStatus.error, startedAt,
          error: e.toString(), workflowId: wfId, workflowName: wfName);
      await _triggerErrorWorkflow(workflow, result);
      return result;
    }
  }

  /// Resolve all credential references before execution.
  Future<void> _resolveCredentials(Workflow workflow) async {
    final paramList = workflow.nodes.map((n) => n.parameters).toList();
    final creds = await CredentialService.instance.resolveAll(paramList);
    for (final entry in creds.entries) {
      _context.setCredential(entry.key, entry.value);
    }
  }

  /// Trigger the error workflow if one is configured.
  Future<void> _triggerErrorWorkflow(
      Workflow failedWorkflow, ExecutionResult failedResult) async {
    final errorWfId = failedWorkflow.errorWorkflowId;
    if (errorWfId == null || errorWfId.isEmpty) return;

    try {
      developer.log('[Engine] Triggering error workflow: $errorWfId');
      final storage = WorkflowStorageService();
      final errorWf = await storage.load(errorWfId);
      if (errorWf == null) {
        developer.log('[Engine] Error workflow $errorWfId not found');
        return;
      }

      // Execute the error workflow with failed execution data as input
      await ExecutionEngine().execute(
        errorWf,
        workflowId: errorWf.id,
        workflowName: errorWf.name,
        triggerData: {
          'error': {
            'message': failedResult.error,
            'workflowId': failedWorkflow.id,
            'workflowName': failedWorkflow.name,
            'executionId': failedResult.executionId,
          },
          'nodeResults': failedResult.nodeResults.map(
            (k, v) => MapEntry(k, v.toJson()),
          ),
        },
      );
    } catch (e) {
      developer.log('[Engine] Error workflow execution failed: $e');
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
      } on NodeExecutionException catch (e) {
        lastError = e;
        developer
            .log('[Phase 1] Node ${node.name} attempt $attempt failed: $e');

        if (attempt <= node.retryOnFail &&
            node.waitBetweenTries > 0) {
          await Future.delayed(
              Duration(milliseconds: node.waitBetweenTries));
        }
      } catch (e) {
        lastError = NodeExecutionException(
          e.toString(),
          nodeId: node.id,
          nodeType: node.type,
        );
        developer
            .log('[Phase 1] Node ${node.name} attempt $attempt unexpected error: $e');

        if (attempt <= node.retryOnFail &&
            node.waitBetweenTries > 0) {
          await Future.delayed(
              Duration(milliseconds: node.waitBetweenTries));
        }
      }
    }

    // 所有重试都失败了
    final duration = DateTime.now().difference(nodeStart).inMilliseconds;
    final errorMsg = lastError is NodeExecutionException
        ? lastError.message
        : lastError?.toString() ?? 'Unknown error';
    _nodeResults[item.nodeId] = NodeExecutionResult(
      nodeId: item.nodeId,
      status: NodeExecutionStatus.error,
      error: errorMsg,
      durationMs: duration,
      retryCount: attempt - 1,
    );

    // Always output data: push an empty output even on failure so downstream continues
    if (node.alwaysOutputData) {
      final emptyOutput = [const NodeExecutionData()];
      _nodeResults[item.nodeId] = NodeExecutionResult(
        nodeId: item.nodeId,
        status: NodeExecutionStatus.success,
        output: emptyOutput,
        error: errorMsg,
        durationMs: duration,
        retryCount: attempt - 1,
      );
      _pushDownstream(workflow, node, emptyOutput);
    }

    if (!node.continueOnFail && !node.alwaysOutputData) {
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

    final executor = ExecutorRegistry.instance.get(node.type);
    if (executor == null) {
      throw NodeExecutionException(
        'Unknown node type: ${node.type}',
        nodeId: node.id,
        nodeType: node.type,
      );
    }

    return executor.execute(node, inputData, context);
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
    String? workflowId,
    String? workflowName,
  }) {
    return ExecutionResult(
      executionId: executionId,
      workflowId: workflowId,
      workflowName: workflowName,
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
