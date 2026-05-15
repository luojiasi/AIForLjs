import 'expression_engine.dart';

/// Snapshot of execution context state, serializable for isolate transfer
/// or for cloning contexts during parallel execution.
class ContextSnapshot {
  final Map<String, dynamic> variables;
  final Map<String, Map<String, dynamic>> nodeOutputs;
  final Map<String, Map<String, dynamic>> credentials;
  final Map<String, dynamic>? currentInput;

  const ContextSnapshot({
    this.variables = const {},
    this.nodeOutputs = const {},
    this.credentials = const {},
    this.currentInput,
  });

  Map<String, dynamic> toJson() => {
        'variables': variables,
        'nodeOutputs': nodeOutputs,
        'credentials': credentials,
        'currentInput': currentInput,
      };

  factory ContextSnapshot.fromJson(Map<String, dynamic> json) =>
      ContextSnapshot(
        variables: json['variables'] as Map<String, dynamic>? ?? {},
        nodeOutputs:
            (json['nodeOutputs'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, v as Map<String, dynamic>),
                ) ??
                {},
        credentials: (json['credentials'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as Map<String, dynamic>),
            ) ??
            {},
        currentInput: json['currentInput'] as Map<String, dynamic>?,
      );
}

/// 执行上下文 — 工作流运行时环境
/// 承载全局变量、所有节点输出、凭据、表达式求值器
class ExecutionContext {
  /// 全局变量（Set 节点可写入）
  final Map<String, dynamic> _variables;

  /// 所有节点的输出数据（用于 $node['NodeName'].json.field 跨节点引用）
  final Map<String, Map<String, dynamic>> _nodeOutputs;

  /// 当前节点输入数据缓存
  Map<String, dynamic> _currentInput = {};

  /// 请求凭据缓存
  final Map<String, Map<String, dynamic>> _credentials;

  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  ExecutionContext({
    Map<String, dynamic>? initialVariables,
    Map<String, Map<String, dynamic>>? credentials,
    Map<String, Map<String, dynamic>>? nodeOutputs,
    Map<String, dynamic>? currentInput,
    ContextSnapshot? snapshot,
  })  : _variables = snapshot?.variables ?? initialVariables ?? {},
        _nodeOutputs = snapshot?.nodeOutputs ?? nodeOutputs ?? {},
        _currentInput = snapshot?.currentInput ?? currentInput ?? {},
        _credentials = snapshot?.credentials ?? credentials ?? {};

  /// Create an independent copy for parallel execution.
  /// Each parallel node gets its own context to avoid race conditions.
  ExecutionContext copy() => ExecutionContext(
        initialVariables: Map.from(_variables),
        credentials: Map.from(_credentials),
        nodeOutputs: _nodeOutputs.map((k, v) => MapEntry(k, Map.from(v))),
        currentInput: Map.from(_currentInput),
      );

  /// Export a serializable snapshot for isolate transfer.
  ContextSnapshot toSnapshot() => ContextSnapshot(
        variables: Map.from(_variables),
        nodeOutputs: _nodeOutputs.map((k, v) => MapEntry(k, Map.from(v))),
        credentials: _credentials.map((k, v) => MapEntry(k, Map.from(v))),
        currentInput: Map.from(_currentInput),
      );

  // ===========================================================================
  // 变量存取
  // ===========================================================================

  void setVariable(String key, dynamic value) => _variables[key] = value;
  dynamic getVariable(String key) => _variables[key];
  Map<String, dynamic> get variables => Map.unmodifiable(_variables);

  // ===========================================================================
  // 节点输出存取
  // ===========================================================================

  void setNodeOutput(String nodeId, Map<String, dynamic> json) {
    _nodeOutputs[nodeId] = json;
  }

  Map<String, dynamic>? getNodeOutput(String nodeId) {
    return _nodeOutputs[nodeId];
  }

  // ===========================================================================
  // 当前输入
  // ===========================================================================

  void setCurrentInput(Map<String, dynamic> json) {
    _currentInput = json;
  }

  Map<String, dynamic> get currentInput => _currentInput;

  // ===========================================================================
  // 表达式求值（对外统一入口）
  // ===========================================================================

  /// 求值模板字符串，替换所有 {{ ... }} 占位符。
  String evaluateTemplate(String template) {
    return _evaluator.evaluateTemplate(template, _buildContext());
  }

  /// 求值单个表达式（返回动态值，保留类型）
  dynamic evaluate(String expression) {
    return _evaluator.evaluate(expression, _buildContext());
  }

  /// 构建求值上下文 —— 扁平化所有可访问变量到 key → value
  Map<String, dynamic> _buildContext() {
    final ctx = <String, dynamic>{};
    ctx['json'] = _currentInput;

    final nodeMap = <String, Map<String, dynamic>>{};
    for (final entry in _nodeOutputs.entries) {
      nodeMap[entry.key] = entry.value;
    }
    ctx['node'] = nodeMap;
    ctx['vars'] = _variables;
    ctx['workflow'] = {};
    return ctx;
  }

  // ===========================================================================
  // 凭据
  // ===========================================================================

  void setCredential(String key, Map<String, dynamic> value) {
    _credentials[key] = value;
  }

  Map<String, dynamic>? getCredential(String key) => _credentials[key];

  /// 注入凭据到节点参数（将 {{ $credential.xxx.field }} 替换为实际值）
  void injectCredentials(Map<String, dynamic> parameters) {
    for (final entry in parameters.entries) {
      if (entry.value is String) {
        parameters[entry.key] =
            _resolveCredentialTemplate(entry.value as String);
      }
    }
  }

  String _resolveCredentialTemplate(String value) {
    final regex =
        RegExp(r'\{\{\s*\$credential\.(\w+)(?:\.(\w+))?\s*\}\}');
    return value.replaceAllMapped(regex, (match) {
      final name = match.group(1)!;
      final field = match.group(2) ?? 'value';
      final cred = _credentials[name];
      if (cred != null) {
        return cred[field]?.toString() ?? match.group(0)!;
      }
      return match.group(0)!;
    });
  }
}
