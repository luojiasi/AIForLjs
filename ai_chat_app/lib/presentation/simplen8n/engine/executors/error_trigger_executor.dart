import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

/// Executor for the Error Trigger node.
/// In manual execution mode, outputs the trigger data as-is.
/// When triggered by an actual error workflow, it receives the failed execution data.
class ErrorTriggerExecutor implements INodeExecutor {
  @override
  String get nodeType => 'error_trigger';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    if (inputData.isNotEmpty) {
      return inputData;
    }
    return [const NodeExecutionData(json: {'trigger': 'error', 'manual': true})];
  }
}
