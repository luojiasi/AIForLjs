import '../models/workflow_model.dart';
import '../models/execution_data.dart';
import 'execution_context.dart';

/// Interface for pluggable node executors.
///
/// Each node type has its own executor implementation registered
/// with [ExecutorRegistry]. Executors are stateless — all mutable
/// state lives in [ExecutionContext].
abstract class INodeExecutor {
  /// The node type this executor handles (e.g. 'http_request', 'set', 'if').
  String get nodeType;

  /// Execute the node and return output data.
  ///
  /// [node] — the node to execute (contains parameters).
  /// [inputData] — input data from upstream nodes.
  /// [context] — execution context (variables, current input, node outputs).
  Future<List<NodeExecutionData>> execute(
    WorkflowNode node,
    List<NodeExecutionData> inputData,
    ExecutionContext context,
  );
}
