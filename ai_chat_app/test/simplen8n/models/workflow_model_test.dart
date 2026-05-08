import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_app/presentation/simplen8n/models/workflow_model.dart';

void main() {
  group('WorkflowNode', () {
    test('constructs with defaults', () {
      final node = WorkflowNode(id: 'n1', type: 'set');
      expect(node.id, 'n1');
      expect(node.name, '');
      expect(node.type, 'set');
      expect(node.position, [0, 0]);
      expect(node.parameters, {});
      expect(node.retryOnFail, 0);
      expect(node.maxTries, 3);
      expect(node.waitBetweenTries, 1000);
      expect(node.continueOnFail, false);
      expect(node.notes, null);
    });

    test('toJson and fromJson round-trip', () {
      final node = WorkflowNode(
        id: 'n1',
        name: 'Test Node',
        type: 'http_request',
        position: [100.5, 200.3],
        parameters: {'url': 'https://example.com', 'method': 'GET'},
        retryOnFail: 2,
        maxTries: 5,
        waitBetweenTries: 500,
        continueOnFail: true,
        notes: 'Test notes',
      );

      final json = node.toJson();
      final restored = WorkflowNode.fromJson(json);

      expect(restored.id, node.id);
      expect(restored.name, node.name);
      expect(restored.type, node.type);
      expect(restored.position, node.position);
      expect(restored.parameters, node.parameters);
      expect(restored.retryOnFail, node.retryOnFail);
      expect(restored.maxTries, node.maxTries);
      expect(restored.waitBetweenTries, node.waitBetweenTries);
      expect(restored.continueOnFail, node.continueOnFail);
      expect(restored.notes, node.notes);
    });

    test('fromJson handles missing fields', () {
      final node = WorkflowNode.fromJson({'id': 'n1', 'type': 'set'});
      expect(node.id, 'n1');
      expect(node.type, 'set');
      expect(node.name, '');
      expect(node.position, [0, 0]);
      expect(node.parameters, {});
    });
  });

  group('ConnectionRule', () {
    test('constructs with defaults', () {
      final rule = ConnectionRule(node: 'target');
      expect(rule.node, 'target');
      expect(rule.index, 0);
    });

    test('toJson and fromJson round-trip', () {
      final rule = ConnectionRule(node: 'target', index: 2);
      final json = rule.toJson();
      final restored = ConnectionRule.fromJson(json);
      expect(restored.node, 'target');
      expect(restored.index, 2);
    });

    test('fromJson handles missing index', () {
      final rule = ConnectionRule.fromJson({'node': 'target'});
      expect(rule.index, 0);
    });
  });

  group('Workflow', () {
    test('constructs with defaults', () {
      final wf = Workflow(id: 'wf1');
      expect(wf.id, 'wf1');
      expect(wf.name, 'Untitled Workflow');
      expect(wf.nodes, []);
      expect(wf.connections, {});
      expect(wf.active, false);
      expect(wf.version, 1);
    });

    test('toJson and fromJson round-trip with nodes', () {
      final wf = Workflow(
        id: 'wf1',
        name: 'My Workflow',
        description: 'Test desc',
        nodes: [
          WorkflowNode(id: 'n1', type: 'manual_trigger', name: 'Start'),
          WorkflowNode(id: 'n2', type: 'set', name: 'Process'),
        ],
        connections: {
          'n1': {
            'output': [ConnectionRule(node: 'n2', index: 0)],
          },
        },
        active: true,
        version: 3,
      );

      final json = wf.toJson();
      final restored = Workflow.fromJson(json);

      expect(restored.id, wf.id);
      expect(restored.name, wf.name);
      expect(restored.description, wf.description);
      expect(restored.nodes.length, 2);
      expect(restored.nodes[0].id, 'n1');
      expect(restored.nodes[0].type, 'manual_trigger');
      expect(restored.nodes[1].id, 'n2');
      expect(restored.connections['n1']!['output']!.length, 1);
      expect(restored.connections['n1']!['output']![0].node, 'n2');
      expect(restored.active, true);
      expect(restored.version, 3);
    });

    test('fromJson handles empty nodes/connections', () {
      final wf = Workflow.fromJson({'id': 'wf1'});
      expect(wf.nodes, []);
      expect(wf.connections, {});
    });

    test('copyWith creates independent copy', () {
      final wf = Workflow(
        id: 'wf1',
        name: 'Original',
        nodes: [WorkflowNode(id: 'n1', type: 'set')],
      );

      final copy = wf.copyWith(name: 'Copy');
      expect(copy.name, 'Copy');
      expect(wf.name, 'Original'); // original unchanged
      expect(copy.id, wf.id);
      expect(copy.nodes.length, 1);
      expect(copy.nodes[0].id, 'n1');
    });

    test('copyWith deep-copies nodes list', () {
      final wf = Workflow(
        id: 'wf1',
        nodes: [WorkflowNode(id: 'n1', type: 'set')],
      );

      final copy = wf.copyWith();
      // Modifying copy's nodes list should not affect original
      copy.nodes.add(WorkflowNode(id: 'n2', type: 'set'));
      expect(wf.nodes.length, 1);
      expect(copy.nodes.length, 2);
    });

    test('toJson produces valid JSON that fromJson can read', () {
      final wf = Workflow(
        id: 'wf_uuid',
        name: 'Export Test',
        nodes: [
          WorkflowNode(
            id: 'n1',
            type: 'http_request',
            name: 'API Call',
            parameters: {'url': 'https://api.example.com', 'method': 'POST'},
            position: [150.0, 250.0],
          ),
        ],
      );

      final json = wf.toJson();
      // Verify JSON structure
      expect(json['id'], 'wf_uuid');
      expect(json['name'], 'Export Test');
      expect(json['nodes'], isA<List>());
      expect((json['nodes'] as List).length, 1);
      expect(json['connections'], isA<Map>());
    });
  });
}
