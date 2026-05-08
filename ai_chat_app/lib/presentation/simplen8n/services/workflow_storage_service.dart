import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/workflow_model.dart';

/// JSON-file-based persistence for workflows.
///
/// Directory layout:
/// ```
/// {appDocDir}/simplen8n/
///   workflows/{id}.json
///   index.json
/// ```
class WorkflowStorageService {
  Future<Directory> get _baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/simplen8n/workflows');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> get _indexFile async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/simplen8n/index.json');
  }

  /// Save a workflow to disk. Updates the index.
  Future<void> save(Workflow workflow) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/${workflow.id}.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(workflow.toJson()),
    );
    await _updateIndex(workflow);
  }

  /// Load a single workflow by ID.
  Future<Workflow?> load(String id) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/$id.json');
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return Workflow.fromJson(json);
  }

  /// Delete a workflow and remove it from the index.
  Future<void> delete(String id) async {
    final dir = await _baseDir;
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
    await _removeFromIndex(id);
  }

  /// List all saved workflow summaries from the index.
  Future<List<WorkflowSummary>> listSummaries() async {
    final index = await _readIndex();
    return index.values
        .map((j) => WorkflowSummary.fromJson(j as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Export a workflow as a JSON string.
  Future<String> exportJson(Workflow workflow) async {
    return const JsonEncoder.withIndent('  ').convert(workflow.toJson());
  }

  /// Import a workflow from a JSON string. Validates before returning.
  Workflow importFromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final wf = Workflow.fromJson(json);
    final errors = wf.validate();
    if (errors.isNotEmpty) {
      throw FormatException('Invalid workflow: ${errors.join(', ')}');
    }
    return wf;
  }

  // -- index management --

  Future<Map<String, dynamic>> _readIndex() async {
    final file = await _indexFile;
    if (!await file.exists()) return {};
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeIndex(Map<String, dynamic> index) async {
    final file = await _indexFile;
    // Ensure parent directory exists
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(index));
  }

  Future<void> _updateIndex(Workflow wf) async {
    final index = await _readIndex();
    index[wf.id] = WorkflowSummary(
      id: wf.id,
      name: wf.name,
      description: wf.description ?? '',
      nodeCount: wf.nodes.length,
      updatedAt: wf.updatedAt,
    ).toJson();
    await _writeIndex(index);
  }

  Future<void> _removeFromIndex(String id) async {
    final index = await _readIndex();
    index.remove(id);
    await _writeIndex(index);
  }
}

/// Lightweight summary stored in the index file.
class WorkflowSummary {
  final String id;
  final String name;
  final String description;
  final int nodeCount;
  final DateTime updatedAt;

  const WorkflowSummary({
    required this.id,
    required this.name,
    this.description = '',
    this.nodeCount = 0,
    required this.updatedAt,
  });

  factory WorkflowSummary.fromJson(Map<String, dynamic> json) {
    return WorkflowSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      nodeCount: json['nodeCount'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'nodeCount': nodeCount,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
