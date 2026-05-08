import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

/// Executor for the Webhook Trigger node.
/// In manual execution mode, outputs a single empty data item.
/// The actual webhook server is managed by [WebhookTrigger] via [TriggerManager].
class WebhookTriggerExecutor implements INodeExecutor {
  @override
  String get nodeType => 'webhook_trigger';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    return [const NodeExecutionData(json: {'trigger': 'webhook', 'manual': true})];
  }
}
