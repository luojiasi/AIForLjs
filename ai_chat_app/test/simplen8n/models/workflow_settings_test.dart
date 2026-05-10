import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_app/presentation/simplen8n/models/workflow_model.dart';

void main() {
  group('WorkflowSettings', () {
    test('defaults are correct', () {
      final s = WorkflowSettings();
      expect(s.executionTimeoutMs, 0);
      expect(s.maxConcurrency, 0);
      expect(s.saveExecutionProgress, false);
      expect(s.allowCallerPolicy, true);
      expect(s.timezone, isNull);
    });

    test('fromJson with null returns defaults', () {
      final s = WorkflowSettings.fromJson(null);
      expect(s.executionTimeoutMs, 0);
    });

    test('fromJson with empty map returns defaults', () {
      final s = WorkflowSettings.fromJson({});
      expect(s.executionTimeoutMs, 0);
    });

    test('toJson and fromJson round-trip', () {
      final s = WorkflowSettings(
        timezone: 'Asia/Shanghai',
        executionTimeoutMs: 30000,
        maxConcurrency: 5,
        saveExecutionProgress: true,
        allowCallerPolicy: false,
      );
      final json = s.toJson();
      final s2 = WorkflowSettings.fromJson(json);
      expect(s2.timezone, 'Asia/Shanghai');
      expect(s2.executionTimeoutMs, 30000);
      expect(s2.maxConcurrency, 5);
      expect(s2.saveExecutionProgress, true);
      expect(s2.allowCallerPolicy, false);
    });
  });

  group('Workflow with settings', () {
    test('Workflow constructs with settings', () {
      final wf = Workflow(
        id: 'wf_test',
        settings: WorkflowSettings(executionTimeoutMs: 10000),
        errorWorkflowId: 'wf_error_handler',
      );
      expect(wf.settings.executionTimeoutMs, 10000);
      expect(wf.errorWorkflowId, 'wf_error_handler');
    });

    test('Workflow fromJson reads settings and errorWorkflowId', () {
      final json = {
        'id': 'wf_test',
        'settings': {
          'executionTimeoutMs': 15000,
          'maxConcurrency': 3,
        },
        'errorWorkflowId': 'wf_on_error',
      };
      final wf = Workflow.fromJson(json);
      expect(wf.settings.executionTimeoutMs, 15000);
      expect(wf.settings.maxConcurrency, 3);
      expect(wf.errorWorkflowId, 'wf_on_error');
    });

    test('Workflow toJson includes settings and errorWorkflowId', () {
      final wf = Workflow(
        id: 'wf_test',
        settings: WorkflowSettings(executionTimeoutMs: 20000),
        errorWorkflowId: 'wf_err',
      );
      final json = wf.toJson();
      expect(json['settings'], isA<Map>());
      expect((json['settings'] as Map)['executionTimeoutMs'], 20000);
      expect(json['errorWorkflowId'], 'wf_err');
    });

    test('Workflow toJson omits null errorWorkflowId', () {
      final wf = Workflow(id: 'wf_test');
      final json = wf.toJson();
      expect(json.containsKey('errorWorkflowId'), false);
    });

    test('WorkflowNode alwaysOutputData defaults to false', () {
      final node = WorkflowNode(id: 'n1', type: 'set');
      expect(node.alwaysOutputData, false);
    });

    test('WorkflowNode alwaysOutputData round-trip', () {
      final node = WorkflowNode(id: 'n1', type: 'set', alwaysOutputData: true);
      final json = node.toJson();
      final restored = WorkflowNode.fromJson(json);
      expect(restored.alwaysOutputData, true);
    });

    test('copyWith preserves settings and errorWorkflowId', () {
      final wf = Workflow(
        id: 'wf_test',
        settings: WorkflowSettings(executionTimeoutMs: 5000),
        errorWorkflowId: 'wf_error',
      );
      final copy = wf.copyWith(name: 'Renamed');
      expect(copy.settings.executionTimeoutMs, 5000);
      expect(copy.errorWorkflowId, 'wf_error');
    });

    test('copyWith can change settings', () {
      final wf = Workflow(id: 'wf_test');
      final copy = wf.copyWith(
        settings: WorkflowSettings(executionTimeoutMs: 9999),
        errorWorkflowId: 'wf_new_error',
      );
      expect(copy.settings.executionTimeoutMs, 9999);
      expect(copy.errorWorkflowId, 'wf_new_error');
    });
  });
}
