/// Workflow-level settings.
class WorkflowSettings {
  String? timezone;
  int executionTimeoutMs; // 0 = no timeout
  int maxConcurrency;     // max simultaneous triggered executions, 0 = unlimited
  bool saveExecutionProgress; // save intermediate node results during execution
  bool allowCallerPolicy; // allow other workflows to call this one

  WorkflowSettings({
    this.timezone,
    this.executionTimeoutMs = 0,
    this.maxConcurrency = 0,
    this.saveExecutionProgress = false,
    this.allowCallerPolicy = true,
  });

  factory WorkflowSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WorkflowSettings();
    return WorkflowSettings(
      timezone: json['timezone'] as String?,
      executionTimeoutMs: json['executionTimeoutMs'] as int? ?? 0,
      maxConcurrency: json['maxConcurrency'] as int? ?? 0,
      saveExecutionProgress: json['saveExecutionProgress'] as bool? ?? false,
      allowCallerPolicy: json['allowCallerPolicy'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (timezone != null) 'timezone': timezone,
        'executionTimeoutMs': executionTimeoutMs,
        'maxConcurrency': maxConcurrency,
        'saveExecutionProgress': saveExecutionProgress,
        'allowCallerPolicy': allowCallerPolicy,
      };
}

/// 工作流定义
class Workflow {
  final String id;
  String name;
  String? description;
  final List<WorkflowNode> nodes;
  final Map<String, Map<String, List<ConnectionRule>>> connections;
  bool active;
  int version;
  final DateTime createdAt;
  DateTime updatedAt;
  WorkflowSettings settings;
  String? errorWorkflowId;

  Workflow({
    required this.id,
    this.name = 'Untitled Workflow',
    this.description,
    List<WorkflowNode>? nodes,
    Map<String, Map<String, List<ConnectionRule>>>? connections,
    this.active = false,
    this.version = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    WorkflowSettings? settings,
    this.errorWorkflowId,
  })  : nodes = nodes ?? [],
        connections = connections ?? {},
        settings = settings ?? WorkflowSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled Workflow',
      description: json['description'] as String?,
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((n) => WorkflowNode.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      connections: _parseConnections(json['connections']),
      active: json['active'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      settings: WorkflowSettings.fromJson(json['settings'] as Map<String, dynamic>?),
      errorWorkflowId: json['errorWorkflowId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'connections': _serializeConnections(connections),
        'active': active,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'settings': settings.toJson(),
        if (errorWorkflowId != null) 'errorWorkflowId': errorWorkflowId,
      };

  static Map<String, Map<String, List<ConnectionRule>>> _parseConnections(
      dynamic raw) {
    if (raw == null) return {};
    final map = raw as Map<String, dynamic>;
    final result = <String, Map<String, List<ConnectionRule>>>{};
    for (final fromEntry in map.entries) {
      final inner = <String, List<ConnectionRule>>{};
      for (final portEntry
          in (fromEntry.value as Map<String, dynamic>).entries) {
        final rules = (portEntry.value as List<dynamic>)
            .map((r) => ConnectionRule.fromJson(r as Map<String, dynamic>))
            .toList();
        inner[portEntry.key] = rules;
      }
      result[fromEntry.key] = inner;
    }
    return result;
  }

  static Map<String, Map<String, List<Map<String, dynamic>>>>
      _serializeConnections(
          Map<String, Map<String, List<ConnectionRule>>> connections) {
    final result = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final fromEntry in connections.entries) {
      final inner = <String, List<Map<String, dynamic>>>{};
      for (final portEntry in fromEntry.value.entries) {
        inner[portEntry.key] = portEntry.value.map((r) => r.toJson()).toList();
      }
      result[fromEntry.key] = inner;
    }
    return result;
  }

  /// Validate this workflow. Returns a list of issue descriptions (empty = valid).
  List<String> validate() {
    final issues = <String>[];
    if (id.isEmpty) issues.add('Workflow id is empty');
    if (nodes.isEmpty && connections.isEmpty) return issues; // empty canvas is valid
    // Check for missing connection targets
    final nodeIds = nodes.map((n) => n.id).toSet();
    for (final entry in connections.entries) {
      if (!nodeIds.contains(entry.key)) {
        issues.add('Connection source "${entry.key}" does not exist');
      }
      for (final portEntry in entry.value.entries) {
        for (final rule in portEntry.value) {
          if (!nodeIds.contains(rule.node)) {
            issues.add('Connection target "${rule.node}" does not exist');
          }
        }
      }
    }
    // Check for duplicate node ids
    final seenIds = <String>{};
    for (final n in nodes) {
      if (seenIds.contains(n.id)) {
        issues.add('Duplicate node id: ${n.id}');
      }
      seenIds.add(n.id);
    }
    return issues;
  }

  Workflow copyWith({
    String? name,
    String? description,
    List<WorkflowNode>? nodes,
    Map<String, Map<String, List<ConnectionRule>>>? connections,
    bool? active,
    int? version,
    WorkflowSettings? settings,
    String? errorWorkflowId,
  }) {
    return Workflow(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? List.from(this.nodes),
      connections: connections ??
          Map.from(this.connections.map((k, v) => MapEntry(
              k,
              v.map((k2, v2) =>
                  MapEntry(k2, List<ConnectionRule>.from(v2)))))),
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      settings: settings ?? this.settings,
      errorWorkflowId: errorWorkflowId ?? this.errorWorkflowId,
    );
  }
}

/// 节点定义
class WorkflowNode {
  final String id;
  String name;
  String type;
  List<double> position;
  Map<String, dynamic> parameters;
  String? credentialId;
  int retryOnFail;
  int maxTries;
  int waitBetweenTries;
  bool continueOnFail;
  bool alwaysOutputData;
  String? notes;

  WorkflowNode({
    required this.id,
    this.name = '',
    required this.type,
    this.position = const [0, 0],
    Map<String, dynamic>? parameters,
    this.credentialId,
    this.retryOnFail = 0,
    this.maxTries = 3,
    this.waitBetweenTries = 1000,
    this.continueOnFail = false,
    this.alwaysOutputData = false,
    this.notes,
  }) : parameters = parameters ?? {};

  factory WorkflowNode.fromJson(Map<String, dynamic> json) {
    return WorkflowNode(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      type: json['type'] as String,
      position: (json['position'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0, 0],
      parameters:
          json['parameters'] as Map<String, dynamic>? ?? {},
      credentialId: json['credentialId'] as String?,
      retryOnFail: json['retryOnFail'] as int? ?? 0,
      maxTries: json['maxTries'] as int? ?? 3,
      waitBetweenTries: json['waitBetweenTries'] as int? ?? 1000,
      continueOnFail: json['continueOnFail'] as bool? ?? false,
      alwaysOutputData: json['alwaysOutputData'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'position': position,
        'parameters': parameters,
        'credentialId': credentialId,
        'retryOnFail': retryOnFail,
        'maxTries': maxTries,
        'waitBetweenTries': waitBetweenTries,
        'continueOnFail': continueOnFail,
        'alwaysOutputData': alwaysOutputData,
        'notes': notes,
      };
}

/// 连接规则
class ConnectionRule {
  final String node;
  final int index;

  const ConnectionRule({required this.node, this.index = 0});

  factory ConnectionRule.fromJson(Map<String, dynamic> json) {
    return ConnectionRule(
      node: json['node'] as String,
      index: json['index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'node': node,
        'index': index,
      };
}
