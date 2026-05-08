/// Base exception for all simplen8n errors.
class Simplen8nException implements Exception {
  final String message;
  final String? executionId;

  const Simplen8nException(this.message, {this.executionId});

  @override
  String toString() => 'Simplen8nException: $message';
}

/// Thrown when the workflow graph is invalid (cycles, missing start node, etc.).
class WorkflowValidationException extends Simplen8nException {
  const WorkflowValidationException(super.message, {super.executionId});

  @override
  String toString() => 'WorkflowValidationException: $message';
}

/// Thrown when a node fails during execution.
class NodeExecutionException extends Simplen8nException {
  final String nodeId;
  final String nodeType;

  const NodeExecutionException(
    super.message, {
    required this.nodeId,
    required this.nodeType,
    super.executionId,
  });

  @override
  String toString() => 'NodeExecutionException[$nodeType:$nodeId]: $message';
}

/// Thrown when an HTTP request node fails.
class HttpRequestException extends NodeExecutionException {
  final int? statusCode;

  const HttpRequestException(
    super.message, {
    required super.nodeId,
    required super.nodeType,
    this.statusCode,
    super.executionId,
  });

  @override
  String toString() {
    final sc = statusCode != null ? ' (status=$statusCode)' : '';
    return 'HttpRequestException[$nodeType:$nodeId]$sc: $message';
  }
}

/// Thrown when expression evaluation fails.
class ExpressionException extends Simplen8nException {
  final String expression;

  const ExpressionException(
    super.message, {
    required this.expression,
    super.executionId,
  });

  @override
  String toString() => 'ExpressionException: $message (expr: $expression)';
}

/// Control-flow signal: workflow was paused (not an error).
class WorkflowPausedException extends Simplen8nException {
  final String pausedAtNodeId;

  const WorkflowPausedException({
    required this.pausedAtNodeId,
    super.executionId,
  }) : super('Workflow paused at node $pausedAtNodeId');

  @override
  String toString() => 'WorkflowPausedException: paused at $pausedAtNodeId';
}
