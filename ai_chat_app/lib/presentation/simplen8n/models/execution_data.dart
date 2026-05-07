/// 节点执行状态
enum NodeExecutionStatus {
  pending,
  running,
  success,
  error,
  waiting,
}

/// 执行状态
enum ExecutionStatus {
  queued,
  running,
  paused,
  success,
  error,
}

/// 节点间传递的执行数据
class NodeExecutionData {
  final Map<String, dynamic> json;
  final List<int>? binary;
  final int? pairedItem;
  final String? error;

  const NodeExecutionData({
    this.json = const {},
    this.binary,
    this.pairedItem,
    this.error,
  });

  static NodeExecutionData fromMap(Map<String, dynamic> data) {
    return NodeExecutionData(
      json: data,
    );
  }

  Map<String, dynamic> toJson() => json;
}

/// 节点执行结果
class NodeExecutionResult {
  final String nodeId;
  final NodeExecutionStatus status;
  final List<NodeExecutionData>? output;
  final String? error;
  final int durationMs;
  final int retryCount;

  const NodeExecutionResult({
    required this.nodeId,
    this.status = NodeExecutionStatus.pending,
    this.output,
    this.error,
    this.durationMs = 0,
    this.retryCount = 0,
  });
}

/// 工作流执行结果
class ExecutionResult {
  final String executionId;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final Map<String, NodeExecutionResult> nodeResults;
  final String? error;
  final List<NodeExecutionData>? finalOutput;

  const ExecutionResult({
    required this.executionId,
    required this.status,
    required this.startedAt,
    this.stoppedAt,
    this.nodeResults = const {},
    this.error,
    this.finalOutput,
  });

  int get durationMs =>
      stoppedAt != null
          ? stoppedAt!.difference(startedAt).inMilliseconds
          : DateTime.now().difference(startedAt).inMilliseconds;
}
