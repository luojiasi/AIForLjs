// Message types for Isolate-based node execution.
// All data is serializable — no live object references cross the isolate boundary.

/// Request sent from main isolate to worker isolate.
class IsolateExecuteRequest {
  final Map<String, dynamic> nodeJson;
  final String nodeType;
  final Map<String, dynamic> nodeParameters;
  final int retryOnFail;
  final int waitBetweenTries;
  final bool continueOnFail;
  final bool alwaysOutputData;
  final List<Map<String, dynamic>> inputDataJson;
  final Map<String, dynamic> contextSnapshot;

  const IsolateExecuteRequest({
    required this.nodeJson,
    required this.nodeType,
    required this.nodeParameters,
    this.retryOnFail = 0,
    this.waitBetweenTries = 0,
    this.continueOnFail = false,
    this.alwaysOutputData = false,
    this.inputDataJson = const [],
    this.contextSnapshot = const {},
  });

  Map<String, dynamic> toJson() => {
        'nodeJson': nodeJson,
        'nodeType': nodeType,
        'nodeParameters': nodeParameters,
        'retryOnFail': retryOnFail,
        'waitBetweenTries': waitBetweenTries,
        'continueOnFail': continueOnFail,
        'alwaysOutputData': alwaysOutputData,
        'inputDataJson': inputDataJson,
        'contextSnapshot': contextSnapshot,
      };

  factory IsolateExecuteRequest.fromJson(Map<String, dynamic> json) =>
      IsolateExecuteRequest(
        nodeJson: json['nodeJson'] as Map<String, dynamic>,
        nodeType: json['nodeType'] as String,
        nodeParameters: json['nodeParameters'] as Map<String, dynamic>,
        retryOnFail: json['retryOnFail'] as int? ?? 0,
        waitBetweenTries: json['waitBetweenTries'] as int? ?? 0,
        continueOnFail: json['continueOnFail'] as bool? ?? false,
        alwaysOutputData: json['alwaysOutputData'] as bool? ?? false,
        inputDataJson: (json['inputDataJson'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [],
        contextSnapshot: json['contextSnapshot'] as Map<String, dynamic>? ?? {},
      );
}

/// Response sent from worker isolate back to main isolate.
class IsolateExecuteResponse {
  final bool success;
  final List<Map<String, dynamic>> outputJson;
  final String? error;
  final int durationMs;
  final int attempts;

  const IsolateExecuteResponse({
    required this.success,
    this.outputJson = const [],
    this.error,
    required this.durationMs,
    this.attempts = 1,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'outputJson': outputJson,
        'error': error,
        'durationMs': durationMs,
        'attempts': attempts,
      };

  factory IsolateExecuteResponse.fromJson(Map<String, dynamic> json) =>
      IsolateExecuteResponse(
        success: json['success'] as bool,
        outputJson: (json['outputJson'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [],
        error: json['error'] as String?,
        durationMs: json['durationMs'] as int,
        attempts: json['attempts'] as int? ?? 1,
      );
}

// ContextSnapshot is defined in execution_context.dart to avoid circular imports.
