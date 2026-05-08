import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/execution_data.dart';

/// JSON-file-based persistence for execution history.
///
/// Directory layout:
/// ```
/// {appDocDir}/simplen8n/history/{execution_id}.json
/// ```
class ExecutionStorageService {
  Future<Directory> get _baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/simplen8n/history');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save an execution result.
  Future<void> save(ExecutionResult result, {String? workflowId}) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/${result.executionId}.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(result.toJson(workflowId: workflowId)),
    );
  }

  /// Load a single execution result.
  Future<ExecutionResult?> load(String executionId) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/$executionId.json');
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return ExecutionResult.fromJson(json);
  }

  /// List execution summaries, optionally filtered by workflow ID.
  Future<List<ExecutionSummary>> listSummaries({String? workflowId}) async {
    final dir = await _baseDir;
    if (!await dir.exists()) return [];

    final results = <ExecutionSummary>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final json =
              jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
          final summary = ExecutionSummary.fromJson(json);
          if (workflowId == null || summary.workflowId == workflowId) {
            results.add(summary);
          }
        } catch (_) {
          // skip corrupt files
        }
      }
    }
    results.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return results;
  }

  /// Delete a single execution record.
  Future<void> delete(String executionId) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/$executionId.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Delete all history for a workflow.
  Future<void> deleteByWorkflow(String workflowId) async {
    final summaries = await listSummaries(workflowId: workflowId);
    for (final s in summaries) {
      await delete(s.executionId);
    }
  }
}

/// Lightweight execution summary for listing.
class ExecutionSummary {
  final String executionId;
  final String? workflowId;
  final String? workflowName;
  final String status;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final int durationMs;
  final int nodeCount;

  const ExecutionSummary({
    required this.executionId,
    this.workflowId,
    this.workflowName,
    required this.status,
    required this.startedAt,
    this.stoppedAt,
    this.durationMs = 0,
    this.nodeCount = 0,
  });

  factory ExecutionSummary.fromJson(Map<String, dynamic> json) {
    return ExecutionSummary(
      executionId: json['executionId'] as String,
      workflowId: json['workflowId'] as String?,
      workflowName: json['workflowName'] as String?,
      status: json['status'] as String? ?? 'unknown',
      startedAt: DateTime.parse(json['startedAt'] as String),
      stoppedAt: json['stoppedAt'] != null
          ? DateTime.parse(json['stoppedAt'] as String)
          : null,
      durationMs: json['durationMs'] as int? ?? 0,
      nodeCount: json['nodeCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'executionId': executionId,
        if (workflowId != null) 'workflowId': workflowId,
        if (workflowName != null) 'workflowName': workflowName,
        'status': status,
        'startedAt': startedAt.toIso8601String(),
        if (stoppedAt != null) 'stoppedAt': stoppedAt!.toIso8601String(),
        'durationMs': durationMs,
        'nodeCount': nodeCount,
      };
}
