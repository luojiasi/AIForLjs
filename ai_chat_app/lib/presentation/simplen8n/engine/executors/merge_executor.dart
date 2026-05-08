import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import '../execution_context.dart';
import '../node_executor.dart';

class MergeExecutor implements INodeExecutor {
  @override
  String get nodeType => 'merge';

  @override
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  ) async {
    final mode = node.parameters['mode'] as String? ?? 'combine';

    switch (mode) {
      case 'passThrough':
        return inputData.isNotEmpty
            ? [inputData.first]
            : [const NodeExecutionData()];

      case 'combine':
      default:
        final merged = <String, dynamic>{};
        merged['inputCount'] = inputData.length;
        for (var i = 0; i < inputData.length; i++) {
          merged['input_$i'] = inputData[i].json;
        }
        return [NodeExecutionData(json: merged)];
    }
  }
}
