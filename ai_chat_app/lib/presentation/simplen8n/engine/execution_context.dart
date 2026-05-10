import 'expression_engine.dart';

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
  })  : _variables = initialVariables ?? {},
        _nodeOutputs = {},
        _credentials = credentials ?? {};

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
  /// 上下文内置变量：
  ///   $json → 当前输入数据
  ///   $workflow → {id, name}
  ///   $node → 按名称查询的节点输出
  ///   $vars → 全局变量
  ///   $now(), $randomInt(), ... → 内置函数
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

    // $json.*
    ctx['json'] = _currentInput;

    // $node [by ID and by name lookup]
    final nodeMap = <String, Map<String, dynamic>>{};
    for (final entry in _nodeOutputs.entries) {
      nodeMap[entry.key] = entry.value;
    }
    ctx['node'] = nodeMap;

    // $vars.*
    ctx['vars'] = _variables;

    // $workflow
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
    // Support both {{ $credential.name }} (uses 'value' field) and {{ $credential.name.field }}
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
