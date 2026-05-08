import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

class ManualTriggerExecutor implements INodeExecutor {
  @override
  String get nodeType => 'manual_trigger';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    return [const NodeExecutionData(json: {})];
  }
}
