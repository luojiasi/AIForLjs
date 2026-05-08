import 'package:ai_chat_app/presentation/simplen8n/models/workflow_model.dart';
import 'package:ai_chat_app/presentation/simplen8n/models/execution_data.dart';

/// Creates a minimal test Workflow with the given nodes and connections.
Workflow createTestWorkflow({
  String id = 'test_wf',
  String name = 'Test Workflow',
  List<WorkflowNode>? nodes,
  Map<String, Map<String, List<ConnectionRule>>>? connections,
}) {
  return Workflow(
    id: id,
    name: name,
    nodes: nodes ?? [],
    connections: connections ?? {},
  );
}

/// Creates a test node with minimal required fields.
WorkflowNode createTestNode({
  required String id,
  String name = '',
  String type = 'set',
  List<double> position = const [0, 0],
  Map<String, dynamic>? parameters,
  int retryOnFail = 0,
  int maxTries = 3,
  int waitBetweenTries = 1000,
  bool continueOnFail = false,
}) {
  return WorkflowNode(
    id: id,
    name: name,
    type: type,
    position: position,
    parameters: parameters ?? {},
    retryOnFail: retryOnFail,
    maxTries: maxTries,
    waitBetweenTries: waitBetweenTries,
    continueOnFail: continueOnFail,
  );
}

/// Creates a simple linear workflow: A → B or A → B → C.
/// Nodes are of type 'set' by default.
Workflow createLinearWorkflow({
  required List<String> nodeIds,
  String nodeType = 'set',
}) {
  final nodes = <WorkflowNode>[];
  for (final id in nodeIds) {
    nodes.add(createTestNode(id: id, name: id, type: nodeType));
  }

  final connections = <String, Map<String, List<ConnectionRule>>>{};
  for (var i = 0; i < nodeIds.length - 1; i++) {
    connections[nodeIds[i]] = {
      'output': [ConnectionRule(node: nodeIds[i + 1], index: 0)],
    };
  }

  return createTestWorkflow(nodes: nodes, connections: connections);
}

/// Creates a diamond workflow:
///     A
///    / \
///   B   C
///    \ /
///     D
Workflow createDiamondWorkflow() {
  final nodeA = createTestNode(id: 'A', name: 'Start', type: 'manual_trigger');
  final nodeB = createTestNode(id: 'B', name: 'Branch1', type: 'set');
  final nodeC = createTestNode(id: 'C', name: 'Branch2', type: 'set');
  final nodeD = createTestNode(id: 'D', name: 'Merge', type: 'merge');

  return createTestWorkflow(
    nodes: [nodeA, nodeB, nodeC, nodeD],
    connections: {
      'A': {
        'output': [
          ConnectionRule(node: 'B', index: 0),
          ConnectionRule(node: 'C', index: 0),
        ],
      },
      'B': {
        'output': [ConnectionRule(node: 'D', index: 0)],
      },
      'C': {
        'output': [ConnectionRule(node: 'D', index: 1)],
      },
    },
  );
}
