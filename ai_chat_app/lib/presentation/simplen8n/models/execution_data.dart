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

  Map<String, dynamic> toJson() => {
        'nodeId': nodeId,
        'status': status.name,
        'output': output?.map((e) => e.toJson()).toList(),
        'error': error,
        'durationMs': durationMs,
        'retryCount': retryCount,
      };

  factory NodeExecutionResult.fromJson(Map<String, dynamic> json) {
    return NodeExecutionResult(
      nodeId: json['nodeId'] as String,
      status: NodeExecutionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => NodeExecutionStatus.pending,
      ),
      output: (json['output'] as List<dynamic>?)
          ?.map((e) => NodeExecutionData.fromMap(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
      durationMs: json['durationMs'] as int? ?? 0,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// 工作流执行结果
class ExecutionResult {
  final String executionId;
  final String? workflowId;
  final String? workflowName;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final Map<String, NodeExecutionResult> nodeResults;
  final String? error;
  final List<NodeExecutionData>? finalOutput;

  const ExecutionResult({
    required this.executionId,
    this.workflowId,
    this.workflowName,
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

  Map<String, dynamic> toJson({String? workflowId}) => {
        'executionId': executionId,
        'workflowId': workflowId ?? this.workflowId,
        'workflowName': workflowName,
        'status': status.name,
        'startedAt': startedAt.toIso8601String(),
        'stoppedAt': stoppedAt?.toIso8601String(),
        'nodeResults':
            nodeResults.map((k, v) => MapEntry(k, v.toJson())),
        'error': error,
        'finalOutput': finalOutput?.map((e) => e.toJson()).toList(),
        'durationMs': durationMs,
        'nodeCount': nodeResults.length,
      };

  factory ExecutionResult.fromJson(Map<String, dynamic> json) {
    return ExecutionResult(
      executionId: json['executionId'] as String,
      workflowId: json['workflowId'] as String?,
      workflowName: json['workflowName'] as String?,
      status: ExecutionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ExecutionStatus.error,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      stoppedAt: json['stoppedAt'] != null
          ? DateTime.parse(json['stoppedAt'] as String)
          : null,
      nodeResults: (json['nodeResults'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              NodeExecutionResult.fromJson(v as Map<String, dynamic>),
            ),
          ) ??
          {},
      error: json['error'] as String?,
      finalOutput: (json['finalOutput'] as List<dynamic>?)
          ?.map((e) => NodeExecutionData.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
