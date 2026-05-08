import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

/// Executor for the Cron Trigger node.
/// In manual execution mode, outputs a single empty data item.
/// The actual cron scheduling is managed by [CronTrigger] via [TriggerManager].
class CronTriggerExecutor implements INodeExecutor {
  @override
  String get nodeType => 'cron_trigger';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    return [const NodeExecutionData(json: {'trigger': 'cron', 'manual': true})];
  }
}
