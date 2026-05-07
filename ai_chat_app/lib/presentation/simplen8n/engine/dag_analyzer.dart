import 'dart:collection';
import '../models/workflow_model.dart';

/// DAG 分析器 — 拓扑分层、循环检测、入度计算
class DagAnalyzer {
  final Workflow workflow;

  DagAnalyzer(this.workflow);

  /// 邻接表：fromNodeId → [toNodeId, ...]
  late final Map<String, List<String>> adjacency = _buildAdjacency();

  /// 反向邻接表：toNodeId → [fromNodeId, ...]
  late final Map<String, List<String>> reverseAdjacency = _buildReverseAdjacency();

  /// 入度表：nodeId → 入边数
  late final Map<String, int> inDegree = _buildInDegree();

  // ===========================================================================
  // 构建图结构
  // ===========================================================================

  Map<String, List<String>> _buildAdjacency() {
    final adj = <String, List<String>>{};
    for (final node in workflow.nodes) {
      adj[node.id] = [];
    }
    for (final entry in workflow.connections.entries) {
      final fromNode = entry.key;
      for (final rules in entry.value.values) {
        for (final rule in rules) {
          adj.putIfAbsent(fromNode, () => []).add(rule.node);
        }
      }
    }
    return adj;
  }

  Map<String, List<String>> _buildReverseAdjacency() {
    final rev = <String, List<String>>{};
    for (final node in workflow.nodes) {
      rev[node.id] = [];
    }
    for (final from in adjacency.keys) {
      for (final to in adjacency[from] ?? <String>[]) {
        rev.putIfAbsent(to, () => []).add(from);
      }
    }
    return rev;
  }

  Map<String, int> _buildInDegree() {
    final degree = <String, int>{};
    for (final node in workflow.nodes) {
      degree[node.id] = 0;
    }
    for (final from in adjacency.keys) {
      for (final to in adjacency[from] ?? <String>[]) {
        degree[to] = (degree[to] ?? 0) + 1;
      }
    }
    return degree;
  }

  // ===========================================================================
  // 拓扑分层（Kahn 算法 BFS 分层变体）
  // ===========================================================================

  /// 返回执行层级列表，同一层内的节点可并行执行。
  ///
  /// ```
  /// Level 0: [A]        ← 触发器
  /// Level 1: [B, C]     ← B 和 C 可并行
  /// Level 2: [D]        ← D 依赖 B 和 C（Merge 节点，入度 > 1）
  /// Level 3: [E]
  /// ```
  List<Set<String>> topologicalLevels() {
    final levels = <Set<String>>[];
    final workingDegree = Map<String, int>.from(inDegree);

    // 初始化：入度为 0 的节点为第 0 层
    var currentLevel = <String>{};
    for (final entry in workingDegree.entries) {
      if (entry.value == 0) {
        currentLevel.add(entry.key);
      }
    }

    // BFS 分层
    while (currentLevel.isNotEmpty) {
      levels.add(currentLevel);
      final nextLevel = <String>{};

      for (final nodeId in currentLevel) {
        for (final neighbor in adjacency[nodeId] ?? <String>[]) {
          final newDegree = (workingDegree[neighbor] ?? 1) - 1;
          workingDegree[neighbor] = newDegree;
          if (newDegree == 0) {
            nextLevel.add(neighbor);
          }
        }
      }

      currentLevel = nextLevel;
    }

    return levels;
  }

  /// 简单拓扑排序列表（BFS）
  List<String> topologicalOrder() {
    final order = <String>[];
    for (final level in topologicalLevels()) {
      order.addAll(level);
    }
    return order;
  }

  // ===========================================================================
  // 循环检测（DFS 三色法）
  // ===========================================================================

  static const int _white = 0;
  static const int _gray = 1;
  static const int _black = 2;

  /// 检测是否有环。返回 true 表示有环。
  bool hasCycle() {
    final color = <String, int>{};
    for (final node in workflow.nodes) {
      color[node.id] = _white;
    }

    for (final node in workflow.nodes) {
      if (color[node.id] == _white) {
        if (_dfsVisit(node.id, color)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 检测并返回所有环（每个环为一个节点列表）
  List<List<String>> findAllCycles() {
    final cycles = <List<String>>[];
    final color = <String, int>{};
    final parent = <String, String>{};

    for (final node in workflow.nodes) {
      color[node.id] = _white;
    }

    for (final node in workflow.nodes) {
      if (color[node.id] == _white) {
        _dfsFindCycles(node.id, color, parent, cycles);
      }
    }
    return cycles;
  }

  bool _dfsVisit(String nodeId, Map<String, int> color) {
    color[nodeId] = _gray;
    for (final neighbor in adjacency[nodeId] ?? <String>[]) {
      if (color[neighbor] == _gray) return true;
      if (color[neighbor] == _white && _dfsVisit(neighbor, color)) {
        return true;
      }
    }
    color[nodeId] = _black;
    return false;
  }

  void _dfsFindCycles(
    String nodeId,
    Map<String, int> color,
    Map<String, String> parent,
    List<List<String>> cycles,
  ) {
    color[nodeId] = _gray;
    for (final neighbor in adjacency[nodeId] ?? <String>[]) {
      if (color[neighbor] == _white) {
        parent[neighbor] = nodeId;
        _dfsFindCycles(neighbor, color, parent, cycles);
      } else if (color[neighbor] == _gray) {
        // 找到环，回溯
        final cycle = <String>[];
        var current = nodeId;
        while (current != neighbor) {
          cycle.add(current);
          current = parent[current] ?? neighbor;
        }
        cycle.add(neighbor);
        cycle.add(nodeId);
        cycles.add(cycle.reversed.toList());
      }
    }
    color[nodeId] = _black;
  }

  // ==========================================================================
  // 查询方法
  // ==========================================================================

  /// 获取所有没有入边的节点（起始节点/触发器）
  List<String> get sourceNodes =>
      inDegree.entries.where((e) => e.value == 0).map((e) => e.key).toList();

  /// 获取所有没有出边的节点（终止节点）
  List<String> get sinkNodes =>
      workflow.nodes
          .where((n) => (adjacency[n.id]?.isEmpty ?? true))
          .map((n) => n.id)
          .toList();

  /// 获取节点的所有前置节点
  List<String> predecessorsOf(String nodeId) =>
      List.from(reverseAdjacency[nodeId] ?? []);

  /// 获取节点的所有后继节点
  List<String> successorsOf(String nodeId) =>
      List.from(adjacency[nodeId] ?? []);

  /// 检查节点是否是多输入节点（入度 > 1）
  bool isMultiInput(String nodeId) => (inDegree[nodeId] ?? 0) > 1;

  /// BFS 从 startId 出发能到达的所有节点
  Set<String> reachableFrom(String startId) {
    final visited = <String>{startId};
    final queue = Queue<String>()..add(startId);
    while (queue.isNotEmpty) {
      final nodeId = queue.removeFirst();
      for (final next in adjacency[nodeId] ?? <String>[]) {
        if (visited.add(next)) {
          queue.add(next);
        }
      }
    }
    return visited;
  }
}
