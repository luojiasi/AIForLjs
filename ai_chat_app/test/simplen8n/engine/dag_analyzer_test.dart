import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_app/presentation/simplen8n/engine/dag_analyzer.dart';
import 'package:ai_chat_app/presentation/simplen8n/models/workflow_model.dart';

import '../test_utils.dart';

void main() {
  group('DagAnalyzer single node', () {
    test('has no cycles', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.hasCycle(), false);
    });

    test('sourceNodes returns the only node', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.sourceNodes, ['A']);
    });

    test('sinkNodes returns the only node', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.sinkNodes, ['A']);
    });

    test('inDegree is 0 for isolated node', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.inDegree['A'], 0);
    });

    test('topologicalLevels returns single level', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      final levels = dag.topologicalLevels();
      expect(levels.length, 1);
      expect(levels[0], {'A'});
    });

    test('topologicalOrder returns single node', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.topologicalOrder(), ['A']);
    });

    test('reachableFrom returns only itself', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.reachableFrom('A'), {'A'});
    });

    test('isMultiInput is false for degree 0', () {
      final wf = createLinearWorkflow(nodeIds: ['A']);
      final dag = DagAnalyzer(wf);
      expect(dag.isMultiInput('A'), false);
    });
  });

  group('DagAnalyzer linear chain A→B→C', () {
    late DagAnalyzer dag;

    setUp(() {
      final wf = createLinearWorkflow(nodeIds: ['A', 'B', 'C']);
      dag = DagAnalyzer(wf);
    });

    test('has no cycles', () {
      expect(dag.hasCycle(), false);
    });

    test('sourceNodes returns first node', () {
      expect(dag.sourceNodes, ['A']);
    });

    test('sinkNodes returns last node', () {
      expect(dag.sinkNodes, ['C']);
    });

    test('inDegree counts correctly', () {
      expect(dag.inDegree['A'], 0);
      expect(dag.inDegree['B'], 1);
      expect(dag.inDegree['C'], 1);
    });

    test('topologicalLevels produces 3 sequential levels', () {
      final levels = dag.topologicalLevels();
      expect(levels.length, 3);
      expect(levels[0], {'A'});
      expect(levels[1], {'B'});
      expect(levels[2], {'C'});
    });

    test('topologicalOrder returns correct order', () {
      expect(dag.topologicalOrder(), ['A', 'B', 'C']);
    });

    test('successorsOf returns next node', () {
      expect(dag.successorsOf('A'), ['B']);
      expect(dag.successorsOf('B'), ['C']);
      expect(dag.successorsOf('C'), []);
    });

    test('predecessorsOf returns previous node', () {
      expect(dag.predecessorsOf('A'), []);
      expect(dag.predecessorsOf('B'), ['A']);
      expect(dag.predecessorsOf('C'), ['B']);
    });

    test('reachableFrom A reaches all nodes', () {
      expect(dag.reachableFrom('A'), {'A', 'B', 'C'});
    });

    test('reachableFrom B reaches B and C', () {
      expect(dag.reachableFrom('B'), {'B', 'C'});
    });
  });

  group('DagAnalyzer diamond A→B,C→D', () {
    late DagAnalyzer dag;

    setUp(() {
      final wf = createDiamondWorkflow();
      dag = DagAnalyzer(wf);
    });

    test('has no cycles', () {
      expect(dag.hasCycle(), false);
    });

    test('topologicalLevels: A → B,C parallel → D', () {
      final levels = dag.topologicalLevels();
      expect(levels.length, 3);
      expect(levels[0], {'A'});
      expect(levels[1], containsAll(['B', 'C']));
      expect(levels[1].length, 2); // B and C in same level (parallel)
      expect(levels[2], {'D'});
    });

    test('D (merge) has inDegree 2', () {
      expect(dag.inDegree['D'], 2);
    });

    test('D is multi-input', () {
      expect(dag.isMultiInput('D'), true);
    });

    test('B and C are not multi-input', () {
      expect(dag.isMultiInput('B'), false);
      expect(dag.isMultiInput('C'), false);
    });

    test('sourceNodes is A', () {
      expect(dag.sourceNodes, ['A']);
    });

    test('sinkNodes is D', () {
      expect(dag.sinkNodes, ['D']);
    });

    test('reachableFrom A reaches all', () {
      expect(dag.reachableFrom('A'), {'A', 'B', 'C', 'D'});
    });

    test('reachableFrom B reaches B and D only', () {
      expect(dag.reachableFrom('B'), {'B', 'D'});
    });
  });

  group('DagAnalyzer cycle detection', () {
    test('detects simple 2-node cycle', () {
      final wf = createTestWorkflow(
        nodes: [
          createTestNode(id: 'A', type: 'set'),
          createTestNode(id: 'B', type: 'set'),
        ],
        connections: {
          'A': {
            'output': [ConnectionRule(node: 'B', index: 0)],
          },
          'B': {
            'output': [ConnectionRule(node: 'A', index: 0)],
          },
        },
      );
      final dag = DagAnalyzer(wf);
      expect(dag.hasCycle(), true);
    });

    test('detects 3-node cycle', () {
      final wf = createTestWorkflow(
        nodes: [
          createTestNode(id: 'A', type: 'set'),
          createTestNode(id: 'B', type: 'set'),
          createTestNode(id: 'C', type: 'set'),
        ],
        connections: {
          'A': {
            'output': [ConnectionRule(node: 'B', index: 0)],
          },
          'B': {
            'output': [ConnectionRule(node: 'C', index: 0)],
          },
          'C': {
            'output': [ConnectionRule(node: 'A', index: 0)],
          },
        },
      );
      final dag = DagAnalyzer(wf);
      expect(dag.hasCycle(), true);
    });

    test('detects self-loop', () {
      final wf = createTestWorkflow(
        nodes: [createTestNode(id: 'A', type: 'set')],
        connections: {
          'A': {
            'output': [ConnectionRule(node: 'A', index: 0)],
          },
        },
      );
      final dag = DagAnalyzer(wf);
      expect(dag.hasCycle(), true);
    });

    test('findAllCycles enumerates cycles', () {
      final wf = createTestWorkflow(
        nodes: [
          createTestNode(id: 'A', type: 'set'),
          createTestNode(id: 'B', type: 'set'),
        ],
        connections: {
          'A': {
            'output': [ConnectionRule(node: 'B', index: 0)],
          },
          'B': {
            'output': [ConnectionRule(node: 'A', index: 0)],
          },
        },
      );
      final dag = DagAnalyzer(wf);
      final cycles = dag.findAllCycles();
      expect(cycles.isNotEmpty, true);
    });

    test('no cycles in disconnected graph', () {
      final wf = createTestWorkflow(
        nodes: [
          createTestNode(id: 'A', type: 'set'),
          createTestNode(id: 'B', type: 'set'),
        ],
      );
      final dag = DagAnalyzer(wf);
      expect(dag.hasCycle(), false);
    });
  });

  group('DagAnalyzer disconnected graph', () {
    late DagAnalyzer dag;

    setUp(() {
      final wf = createTestWorkflow(
        nodes: [
          createTestNode(id: 'A', type: 'set'),
          createTestNode(id: 'B', type: 'set'),
        ],
        connections: {},
      );
      dag = DagAnalyzer(wf);
    });

    test('both nodes are sources and sinks', () {
      expect(dag.sourceNodes, containsAll(['A', 'B']));
      expect(dag.sourceNodes.length, 2);
      expect(dag.sinkNodes, containsAll(['A', 'B']));
    });

    test('topologicalLevels puts both in level 0', () {
      final levels = dag.topologicalLevels();
      expect(levels.length, 1);
      expect(levels[0], containsAll(['A', 'B']));
    });

    test('no predecessors or successors', () {
      expect(dag.predecessorsOf('A'), []);
      expect(dag.successorsOf('A'), []);
    });
  });
}
