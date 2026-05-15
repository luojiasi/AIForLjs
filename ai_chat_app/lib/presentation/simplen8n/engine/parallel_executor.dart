import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

import '../models/workflow_model.dart';
import '../models/execution_data.dart';
import 'execution_context.dart';
import 'dag_analyzer.dart';
import 'executor_registry.dart';
import 'exceptions.dart';
import 'isolate_messaging.dart';
import 'execution_isolate.dart';

/// Result of executing a single node in parallel mode.
class _NodeExecutionOutput {
  final String nodeId;
  final NodeExecutionResult result;
  final List<NodeExecutionData> outputData;

  const _NodeExecutionOutput({
    required this.nodeId,
    required this.result,
    this.outputData = const [],
  });
}

/// Parallel execution engine using level-based concurrency.
///
/// Uses [DagAnalyzer.topologicalLevels] to identify nodes that can run
/// concurrently within the same level (no data dependencies between them).
/// Executes all nodes in a level via [Future.wait], then advances to the
/// next level after all results are collected.
///
/// Supports two modes:
/// - **Future mode** (default): Uses [Future.wait] for I/O concurrency.
///   All executors run in the main isolate; suitable for HTTP, AI API calls.
/// - **Isolate mode**: Spawns a dedicated [Isolate] per node for true
///   parallel CPU execution. Requires serializable node data.
class ParallelExecutor {
  final ExecutionContext _context;
  final Map<String, NodeExecutionResult> _nodeResults = {};
  final Map<String, List<NodeExecutionData>> _nodeAccumulatedInputs = {};

  DagAnalyzer? _dag;
  final bool _useIsolates;

  ParallelExecutor({
    ExecutionContext? context,
    bool useIsolates = false,
  })  : _context = context ?? ExecutionContext(),
        _useIsolates = useIsolates;

  /// Execute a workflow using level-based parallel execution.
  ///
  /// Nodes at the same topological level are executed concurrently.
  /// Multi-input nodes (like Merge) wait until all their upstream inputs
  /// from the previous level have arrived before executing.
  Future<ExecutionResult> execute(
    Workflow workflow, {
    String? workflowId,
    String? workflowName,
    Map<String, dynamic>? triggerData,
  }) async {
    final executionId = _generateId();
    final startedAt = DateTime.now();
    final wfId = workflowId ?? workflow.id;
    final wfName = workflowName ?? workflow.name;

    developer.log('[Parallel] Starting execution: $executionId ($wfName)');

    try {
      if (workflow.nodes.isEmpty) {
        throw WorkflowValidationException('Workflow has no nodes',
            executionId: executionId);
      }

      _dag = DagAnalyzer(workflow);
      if (_dag!.hasCycle()) {
        final cycles = _dag!.findAllCycles();
        final cycleStr = cycles.map((c) => c.join(' → ')).join('\n  ');
        throw WorkflowValidationException(
            'Workflow contains cycle(s):\n  $cycleStr',
            executionId: executionId);
      }

      _context.setVariable('workflow', {'id': wfId, 'name': wfName});

      // Initialize source nodes with trigger data
      final initData = triggerData != null
          ? [NodeExecutionData(json: triggerData)]
          : [const NodeExecutionData()];

      final sourceNodes = _dag!.sourceNodes;
      if (sourceNodes.isEmpty) {
        throw WorkflowValidationException(
            'No start node found', executionId: executionId);
      }

      for (final nodeId in sourceNodes) {
        _nodeAccumulatedInputs[nodeId] = initData;
      }

      // Execute level by level
      final levels = _dag!.topologicalLevels();
      developer.log('[Parallel] Topological levels: ${levels.length}');

      final timeoutMs = workflow.settings.executionTimeoutMs;
      final stopwatch = Stopwatch()..start();

      for (var levelIdx = 0; levelIdx < levels.length; levelIdx++) {
        final level = levels[levelIdx];
        if (level.isEmpty) continue;

        // Check timeout
        if (timeoutMs > 0 && stopwatch.elapsedMilliseconds > timeoutMs) {
          throw WorkflowValidationException(
            'Workflow execution timed out after ${timeoutMs}ms',
            executionId: executionId,
          );
        }

        developer.log('[Parallel] Level $levelIdx: ${level.toList()}');

        // Execute all nodes in this level concurrently
        final futures = <Future<_NodeExecutionOutput?>>[];
        for (final nodeId in level) {
          final node = _getNode(workflow, nodeId);
          if (node == null) continue;

          final inputs = _nodeAccumulatedInputs[nodeId] ?? [];
          futures.add(_executeNodeParallel(node, inputs));
        }

        final outputs = await Future.wait(futures);

        // Process outputs and route data to downstream nodes
        for (final output in outputs) {
          if (output == null) continue;

          final node = _getNode(workflow, output.nodeId);
          if (node == null) continue;

          // Save node output to context
          if (output.outputData.isNotEmpty) {
            _context.setNodeOutput(
                output.nodeId, output.outputData.first.json);
          }

          // Route data to downstream nodes in next levels
          _routeToDownstream(workflow, node, output.outputData);
        }

        // Check for node failures
        for (final output in outputs) {
          if (output != null && output.result.status == NodeExecutionStatus.error) {
            final node = _getNode(workflow, output.nodeId);
            if (node != null && !node.continueOnFail && !node.alwaysOutputData) {
              final error = output.result.error ?? 'Node execution failed';
              throw NodeExecutionException(
                error,
                nodeId: output.nodeId,
                nodeType: node.type,
              );
            }
          }
        }
      }

      return _result(executionId, ExecutionStatus.success, startedAt,
          workflowId: wfId, workflowName: wfName);
    } on Simplen8nException catch (e) {
      developer.log('[Parallel] Error: $e');
      return _result(executionId, ExecutionStatus.error, startedAt,
          error: e.message, workflowId: wfId, workflowName: wfName);
    } catch (e, stack) {
      developer.log('[Parallel] Fatal: $e\n$stack');
      return _result(executionId, ExecutionStatus.error, startedAt,
          error: e.toString(), workflowId: wfId, workflowName: wfName);
    }
  }

  /// Route output data from a node to all its downstream nodes.
  void _routeToDownstream(
      Workflow workflow, WorkflowNode node, List<NodeExecutionData> data) {
    if (data.isEmpty) return;

    final outConns = workflow.connections[node.id];
    if (outConns == null || outConns.isEmpty) return;

    for (final portEntry in outConns.entries) {
      final rules = portEntry.value;
      for (final rule in rules) {
        _nodeAccumulatedInputs
            .putIfAbsent(rule.node, () => [])
            .addAll(data);
      }
    }
  }

  /// Execute a single node — either via Future (default) or Isolate.
  Future<_NodeExecutionOutput?> _executeNodeParallel(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
  ) async {
    final nodeStart = DateTime.now();

    // Each parallel node gets its own context copy to avoid races on _currentInput
    final nodeContext = _context.copy();
    if (inputData.isNotEmpty) {
      nodeContext.setCurrentInput(inputData.first.json);
    }

    if (_useIsolates) {
      return _executeInIsolate(node, inputData, nodeContext, nodeStart);
    }

    return _executeInFuture(node, inputData, nodeContext, nodeStart);
  }

  /// Execute node using Future (main isolate, I/O concurrency).
  Future<_NodeExecutionOutput?> _executeInFuture(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext nodeContext,
    DateTime nodeStart,
  ) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt <= node.retryOnFail) {
      attempt++;
      try {
        nodeContext.injectCredentials(node.parameters);
        final executor = ExecutorRegistry.instance.get(node.type);
        if (executor == null) {
          final duration = DateTime.now().difference(nodeStart).inMilliseconds;
          final result = NodeExecutionResult(
            nodeId: node.id,
            status: NodeExecutionStatus.error,
            error: 'Unknown node type: ${node.type}',
            durationMs: duration,
          );
          _nodeResults[node.id] = result;
          return _NodeExecutionOutput(nodeId: node.id, result: result);
        }

        final output = await executor.execute(node, inputData, nodeContext);
        final duration = DateTime.now().difference(nodeStart).inMilliseconds;
        final result = NodeExecutionResult(
          nodeId: node.id,
          status: NodeExecutionStatus.success,
          output: output,
          durationMs: duration,
          retryCount: attempt - 1,
        );
        _nodeResults[node.id] = result;
        return _NodeExecutionOutput(
            nodeId: node.id, result: result, outputData: output);
      } on NodeExecutionException catch (e) {
        lastError = e;
        developer
            .log('[Parallel] Node ${node.name} attempt $attempt failed: $e');
        if (attempt <= node.retryOnFail && node.waitBetweenTries > 0) {
          await Future.delayed(
              Duration(milliseconds: node.waitBetweenTries));
        }
      } catch (e) {
        lastError = NodeExecutionException(
          e.toString(),
          nodeId: node.id,
          nodeType: node.type,
        );
        if (attempt <= node.retryOnFail && node.waitBetweenTries > 0) {
          await Future.delayed(
              Duration(milliseconds: node.waitBetweenTries));
        }
      }
    }

    // All retries exhausted
    final duration = DateTime.now().difference(nodeStart).inMilliseconds;
    final errorMsg = lastError is NodeExecutionException
        ? lastError.message
        : lastError?.toString() ?? 'Unknown error';

    if (node.alwaysOutputData) {
      final emptyOutput = [const NodeExecutionData()];
      final result = NodeExecutionResult(
        nodeId: node.id,
        status: NodeExecutionStatus.success,
        output: emptyOutput,
        error: errorMsg,
        durationMs: duration,
        retryCount: attempt - 1,
      );
      _nodeResults[node.id] = result;
      return _NodeExecutionOutput(
          nodeId: node.id, result: result, outputData: emptyOutput);
    }

    final result = NodeExecutionResult(
      nodeId: node.id,
      status: NodeExecutionStatus.error,
      error: errorMsg,
      durationMs: duration,
      retryCount: attempt - 1,
    );
    _nodeResults[node.id] = result;
    return _NodeExecutionOutput(nodeId: node.id, result: result);
  }

  /// Execute node in a dedicated Isolate for true CPU parallelism.
  Future<_NodeExecutionOutput?> _executeInIsolate(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext nodeContext,
    DateTime nodeStart,
  ) async {
    try {
      final request = IsolateExecuteRequest(
        nodeJson: node.toJson(),
        nodeType: node.type,
        nodeParameters: node.parameters,
        retryOnFail: node.retryOnFail,
        waitBetweenTries: node.waitBetweenTries,
        continueOnFail: node.continueOnFail,
        alwaysOutputData: node.alwaysOutputData,
        inputDataJson: inputData.map((d) => d.toJson()).toList(),
        contextSnapshot: nodeContext.toSnapshot().toJson(),
      );

      // Spawn isolate and wait for response
      final receivePort = ReceivePort();
      await Isolate.spawn(executeNodeInIsolate, receivePort.sendPort);

      // Get the worker's send port from the first message
      final completer = Completer<IsolateExecuteResponse>();
      late SendPort workerSendPort;

      receivePort.listen((message) {
        if (message is SendPort) {
          workerSendPort = message;
          workerSendPort.send(request.toJson());
        } else if (message is Map<String, dynamic>) {
          final response = IsolateExecuteResponse.fromJson(message);
          completer.complete(response);
          receivePort.close();
        }
      });

      final response = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => IsolateExecuteResponse(
          success: false,
          error: 'Isolate execution timed out',
          durationMs: DateTime.now().difference(nodeStart).inMilliseconds,
        ),
      );

      if (response.success) {
        final output = response.outputJson
            .map((j) => NodeExecutionData.fromJson(j))
            .toList();
        final result = NodeExecutionResult(
          nodeId: node.id,
          status: NodeExecutionStatus.success,
          output: output,
          durationMs: response.durationMs,
          retryCount: response.attempts - 1,
        );
        _nodeResults[node.id] = result;
        return _NodeExecutionOutput(
            nodeId: node.id, result: result, outputData: output);
      } else {
        final result = NodeExecutionResult(
          nodeId: node.id,
          status: NodeExecutionStatus.error,
          error: response.error,
          durationMs: response.durationMs,
          retryCount: response.attempts - 1,
        );
        _nodeResults[node.id] = result;
        return _NodeExecutionOutput(nodeId: node.id, result: result);
      }
    } catch (e) {
      final duration = DateTime.now().difference(nodeStart).inMilliseconds;
      final result = NodeExecutionResult(
        nodeId: node.id,
        status: NodeExecutionStatus.error,
        error: 'Isolate error: $e',
        durationMs: duration,
      );
      _nodeResults[node.id] = result;
      return _NodeExecutionOutput(nodeId: node.id, result: result);
    }
  }

  // ---- Helpers ----

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
    return 'par_${DateTime.now().millisecondsSinceEpoch}';
  }
}
