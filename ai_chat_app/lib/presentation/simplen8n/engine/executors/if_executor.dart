import 'dart:developer' as developer;

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

class IfExecutor implements INodeExecutor {
  @override
  String get nodeType => 'if';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final rawCondition = node.parameters['condition'] as String? ?? 'true';
    final evaluated = context.evaluate(rawCondition);

    final condition = evaluated == true ||
        evaluated == 'true' ||
        (evaluated is num && evaluated != 0) ||
        (evaluated is String &&
            evaluated.isNotEmpty &&
            evaluated != 'false');

    developer.log('[IF] Condition "$rawCondition" → $evaluated → $condition');

    return [
      NodeExecutionData(
        json: {...context.currentInput, '_branch': condition},
      ),
    ];
  }
}
