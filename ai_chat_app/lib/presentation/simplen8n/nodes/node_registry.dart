import '../models/node_type.dart';

/// 全局节点类型注册表 — 管理所有可用节点类型定义
/// Phase 0: 简化为类型定义注册表，执行逻辑由 ExecutionEngine 直接处理
class NodeRegistry {
  static final NodeRegistry instance = NodeRegistry._();

  NodeRegistry._();

  final Map<String, NodeTypeDefinition> _types = {};

  /// Public accessor for the type map
  Map<String, NodeTypeDefinition> get types => _types;

  void register(NodeTypeDefinition def) {
    _types[def.type] = def;
  }

  void registerAll(List<NodeTypeDefinition> defs) {
    for (final def in defs) {
      register(def);
    }
  }

  NodeTypeDefinition? get(String type) => _types[type];

  List<NodeTypeDefinition> get all => _types.values.toList();

  List<NodeTypeDefinition> getByCategory(NodeCategory category) {
    return _types.values.where((n) => n.category == category).toList();
  }
}
