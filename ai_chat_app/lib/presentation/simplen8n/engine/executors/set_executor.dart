import 'dart:convert';

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

class SetExecutor implements INodeExecutor {
  @override
  String get nodeType => 'set';

  @override
  Future<List<NodeExecutionData>> execute(
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
}
