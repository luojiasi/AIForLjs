import 'dart:developer' as developer;

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../execution_engine.dart';
import '../dag_analyzer.dart';
import '../node_executor.dart';
import '../../services/workflow_storage_service.dart';

/// Executor for the Execute Workflow node.
/// Loads a child workflow and runs it with the current input data.
class ExecuteWorkflowExecutor implements INodeExecutor {
  @override
  String get nodeType => 'execute_workflow';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final targetId = node.parameters['workflowId'] as String?;
    if (targetId == null || targetId.isEmpty) {
      throw Exception('No target workflow selected');
    }

    final mode = node.parameters['mode'] as String? ?? 'waitForResult';

    final storage = WorkflowStorageService();
    final childWf = await storage.load(targetId);
    if (childWf == null) {
      throw Exception('Target workflow not found: $targetId');
    }

    // Pass current input as trigger data to the child workflow
    final inputJson = inputData.isNotEmpty
        ? inputData.first.json
        : <String, dynamic>{};

    developer.log('[ExecuteWorkflow] Calling child workflow: ${childWf.name}');

    final result = await ExecutionEngine().execute(
      childWf,
      workflowId: childWf.id,
      workflowName: childWf.name,
      triggerData: {
        'parentWorkflow': context.getVariable('workflow'),
        'input': inputJson,
      },
    );

    // Collect final outputs from sink nodes
    final dag = DagAnalyzer(childWf);
    final sinkNodes = dag.sinkNodes;
    final outputs = <Map<String, dynamic>>[];

    for (final sinkId in sinkNodes) {
      final nodeResult = result.nodeResults[sinkId];
      if (nodeResult != null &&
          nodeResult.status == NodeExecutionStatus.success &&
          nodeResult.output != null) {
        for (final data in nodeResult.output!) {
          outputs.add(data.json);
        }
      }
    }

    if (outputs.isEmpty) {
      outputs.add({
        'executionId': result.executionId,
        'status': result.status.name,
        'durationMs': result.durationMs,
      });
    }

    if (mode == 'fireAndForget') {
      developer.log('[ExecuteWorkflow] Fire-and-forget: ${childWf.name}');
    }

    return outputs.map((json) => NodeExecutionData(json: json)).toList();
  }
}
