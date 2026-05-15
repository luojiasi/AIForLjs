import 'dart:isolate';

import '../models/workflow_model.dart';
import '../models/execution_data.dart';
import 'execution_context.dart';
import 'executor_registry.dart';
import 'exceptions.dart';
import 'isolate_messaging.dart';

/// Top-level entry point for worker isolates.
///
/// This function runs in a dedicated Isolate. It deserializes the request,
/// re-creates the ExecutionContext, looks up the executor from the global
/// registry, executes the node, and sends back the response.
void executeNodeInIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is! Map<String, dynamic>) return;

    final request = IsolateExecuteRequest.fromJson(message);
    final stopwatch = Stopwatch()..start();
    IsolateExecuteResponse response;

    try {
      final node = WorkflowNode.fromJson(request.nodeJson);
      final inputData = request.inputDataJson
          .map((j) => NodeExecutionData.fromJson(j))
          .toList();

      final snapshot = ContextSnapshot.fromJson(request.contextSnapshot);
      final context = ExecutionContext(snapshot: snapshot);
      if (snapshot.currentInput != null) {
        context.setCurrentInput(snapshot.currentInput!);
      }

      final executor = ExecutorRegistry.instance.get(request.nodeType);
      if (executor == null) {
        response = IsolateExecuteResponse(
          success: false,
          error: 'Unknown node type: ${request.nodeType}',
          durationMs: stopwatch.elapsedMilliseconds,
        );
        Isolate.exit(sendPort, response.toJson());
      }

      // Retry loop
      int attempt = 0;
      Exception? lastError;

      while (attempt <= request.retryOnFail) {
        attempt++;
        try {
          final output = await executor.execute(node, inputData, context);
          response = IsolateExecuteResponse(
            success: true,
            outputJson: output.map((d) => d.toJson()).toList(),
            durationMs: stopwatch.elapsedMilliseconds,
            attempts: attempt,
          );
          Isolate.exit(sendPort, response.toJson());
        } on NodeExecutionException catch (e) {
          lastError = e;
          if (attempt <= request.retryOnFail &&
              request.waitBetweenTries > 0) {
            await Future.delayed(
                Duration(milliseconds: request.waitBetweenTries));
          }
        } catch (e) {
          lastError = NodeExecutionException(
            e.toString(),
            nodeId: request.nodeJson['id'] as String? ?? '',
            nodeType: request.nodeType,
          );
          if (attempt <= request.retryOnFail &&
              request.waitBetweenTries > 0) {
            await Future.delayed(
                Duration(milliseconds: request.waitBetweenTries));
          }
        }
      }

      // All retries exhausted
      if (request.alwaysOutputData) {
        response = IsolateExecuteResponse(
          success: true,
          outputJson: [const NodeExecutionData().toJson()],
          error: lastError?.toString(),
          durationMs: stopwatch.elapsedMilliseconds,
          attempts: attempt,
        );
      } else {
        response = IsolateExecuteResponse(
          success: false,
          error: lastError?.toString() ?? 'Unknown error',
          durationMs: stopwatch.elapsedMilliseconds,
          attempts: attempt,
        );
      }
    } catch (e) {
      response = IsolateExecuteResponse(
        success: false,
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }

    Isolate.exit(sendPort, response.toJson());
  });
}
