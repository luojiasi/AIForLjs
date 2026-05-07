import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as flow;

import '../models/workflow_model.dart';
import '../models/node_type.dart';

/// vyuh_node_flow 画布节点数据
class Simplen8nCanvasData {
  final String nodeType;
  final String label;
  final NodeCategory category;
  final Map<String, dynamic> parameters;

  const Simplen8nCanvasData({
    required this.nodeType,
    required this.label,
    required this.category,
    this.parameters = const {},
  });

  String? get parameterSummary {
    if (parameters.isEmpty) return null;
    final entries = parameters.entries.take(2);
    return entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

/// 画布 ↔ Workflow 模型转换器
class CanvasConverter {
  /// 从 WorkflowNode 创建 vyuh_node_flow Node
  /// [typeDef] is used to reconstruct correct ports; falls back to heuristics if null.
  flow.Node<Simplen8nCanvasData> toCanvasNode(WorkflowNode wNode,
      {NodeTypeDefinition? typeDef}) {

    final ports = <flow.Port>[];

    if (typeDef != null) {
      for (final p in typeDef.inputs) {
        ports.add(flow.Port(
          id: p.id,
          name: p.name,
          position: flow.PortPosition.left,
          type: flow.PortType.input,
        ));
      }
      for (final p in typeDef.outputs) {
        ports.add(flow.Port(
          id: p.id,
          name: p.name,
          position: flow.PortPosition.right,
          type: flow.PortType.output,
        ));
      }
    } else {
      // 回退：根据类型名推断端口
      final isTrigger = wNode.type == 'manual_trigger';
      if (isTrigger) {
        ports.add(flow.Port(
          id: 'output',
          name: 'Output',
          position: flow.PortPosition.right,
          type: flow.PortType.output,
        ));
      } else {
        ports.add(flow.Port(
          id: 'input',
          name: 'Input',
          position: flow.PortPosition.left,
          type: flow.PortType.input,
        ));
        ports.add(flow.Port(
          id: 'output',
          name: 'Output',
          position: flow.PortPosition.right,
          type: flow.PortType.output,
        ));
      }
    }

    final category = typeDef?.category ?? _categoryFromType(wNode.type);

    return flow.Node<Simplen8nCanvasData>(
      id: wNode.id,
      type: wNode.type,
      position: Offset(wNode.position[0], wNode.position[1]),
      data: Simplen8nCanvasData(
        nodeType: wNode.type,
        label: wNode.name.isNotEmpty
            ? wNode.name
            : wNode.type.replaceAll('_', ' '),
        category: category,
        parameters: wNode.parameters,
      ),
      ports: ports,
    );
  }

  /// 从 vyuh_node_flow Node 创建 WorkflowNode
  WorkflowNode fromCanvasNode(flow.Node<Simplen8nCanvasData> cNode) {
    return WorkflowNode(
      id: cNode.id,
      name: cNode.data.label,
      type: cNode.data.nodeType,
      position: [cNode.position.value.dx, cNode.position.value.dy],
      parameters: Map.from(cNode.data.parameters),
    );
  }

  /// Workflow connections → vyuh_node_flow Connection 列表
  List<flow.Connection<void>> toCanvasConnections(
    Map<String, Map<String, List<ConnectionRule>>> connections,
  ) {
    final result = <flow.Connection<void>>[];
    for (final fromEntry in connections.entries) {
      for (final portEntry in fromEntry.value.entries) {
        for (final rule in portEntry.value) {
          result.add(flow.Connection<void>(
            id: '${fromEntry.key}_${portEntry.key}_${rule.node}_${rule.index}',
            sourceNodeId: fromEntry.key,
            sourcePortId: portEntry.key,
            targetNodeId: rule.node,
            targetPortId: rule.index.toString(),
          ));
        }
      }
    }
    return result;
  }

  /// vyuh_node_flow Connection 列表 → Workflow connections
  Map<String, Map<String, List<ConnectionRule>>> fromCanvasConnections(
    List<flow.Connection<void>> connections,
  ) {
    final result = <String, Map<String, List<ConnectionRule>>>{};
    for (final c in connections) {
      result.putIfAbsent(c.sourceNodeId, () => {});
      result[c.sourceNodeId]!.putIfAbsent(c.sourcePortId, () => []);
      result[c.sourceNodeId]![c.sourcePortId]!.add(ConnectionRule(
        node: c.targetNodeId,
        index: int.tryParse(c.targetPortId) ?? 0,
      ));
    }
    return result;
  }

  NodeCategory _categoryFromType(String type) {
    switch (type) {
      case 'manual_trigger':
        return NodeCategory.trigger;
      case 'http_request':
        return NodeCategory.action;
      case 'set':
        return NodeCategory.data;
      case 'if':
        return NodeCategory.logic;
      case 'merge':
        return NodeCategory.utility;
      default:
        return NodeCategory.utility;
    }
  }
}
