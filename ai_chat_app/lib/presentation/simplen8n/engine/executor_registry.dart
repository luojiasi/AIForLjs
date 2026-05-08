import 'node_executor.dart';

/// Singleton registry mapping node type strings to their executors.
///
/// Usage:
/// ```dart
/// ExecutorRegistry.instance.register(ManualTriggerExecutor());
/// final executor = ExecutorRegistry.instance.get('manual_trigger');
/// ```
class ExecutorRegistry {
  ExecutorRegistry._();

  static final ExecutorRegistry instance = ExecutorRegistry._();

  final Map<String, INodeExecutor> _executors = {};

  /// Register an executor for its declared [INodeExecutor.nodeType].
  void register(INodeExecutor executor) {
    _executors[executor.nodeType] = executor;
  }

  /// Register multiple executors at once.
  void registerAll(Iterable<INodeExecutor> executors) {
    for (final e in executors) {
      register(e);
    }
  }

  /// Get the executor for [nodeType], or null if not registered.
  INodeExecutor? get(String nodeType) => _executors[nodeType];

  /// Whether a node type has a registered executor.
  bool has(String nodeType) => _executors.containsKey(nodeType);

  /// All registered node types.
  Iterable<String> get registeredTypes => _executors.keys;

  /// Remove all registered executors (useful for testing).
  void clear() {
    _executors.clear();
  }
}
