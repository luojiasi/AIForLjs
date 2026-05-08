import 'dart:async';
import 'dart:developer' as developer;

import '../../models/workflow_model.dart';
import '../../models/execution_data.dart';
import 'webhook_trigger.dart';
import 'cron_trigger.dart';

/// Manages lifecycle of active workflow triggers (webhook + cron).
class TriggerManager {
  static final TriggerManager instance = TriggerManager._();

  TriggerManager._();

  /// {workflowId: [trigger instances]}
  final Map<String, List<dynamic>> _active = {};

  bool isActive(String workflowId) => _active.containsKey(workflowId);
  List<String> get activeWorkflowIds => _active.keys.toList();
  int? webhookPort(String workflowId) {
    final triggers = _active[workflowId];
    if (triggers == null) return null;
    for (final t in triggers) {
      if (t is WebhookTrigger) return t.port;
    }
    return null;
  }

  /// Start all trigger nodes (webhook + cron) in a workflow.
  /// [onFire] is called whenever any trigger fires, with the trigger's output data.
  Future<void> activateWorkflow(
    Workflow workflow, {
    required Future<void> Function(List<NodeExecutionData> data) onFire,
  }) async {
    // Deactivate first if already active
    if (_active.containsKey(workflow.id)) {
      await deactivateWorkflow(workflow.id);
    }

    final triggers = <dynamic>[];

    for (final node in workflow.nodes) {
      switch (node.type) {
        case 'webhook_trigger':
          final trigger = WebhookTrigger(
            id: '${workflow.id}_${node.id}',
            node: node,
            workflow: workflow,
            onFire: onFire,
          );
          try {
            await trigger.start();
            triggers.add(trigger);
            developer
                .log('[TriggerManager] Webhook active on port ${trigger.port}');
          } catch (e) {
            developer
                .log('[TriggerManager] Failed to start webhook trigger: $e');
          }
          break;

        case 'cron_trigger':
          final trigger = CronTrigger(
            id: '${workflow.id}_${node.id}',
            node: node,
            workflow: workflow,
            onFire: onFire,
          );
          await trigger.start();
          triggers.add(trigger);
          developer
              .log('[TriggerManager] Cron active: ${trigger.cronExpression}');
          break;
      }
    }

    if (triggers.isNotEmpty) {
      _active[workflow.id] = triggers;
    }
  }

  /// Stop all triggers for a workflow.
  Future<void> deactivateWorkflow(String workflowId) async {
    final triggers = _active.remove(workflowId);
    if (triggers == null) return;

    for (final trigger in triggers) {
      try {
        if (trigger is WebhookTrigger) {
          await trigger.stop();
        } else if (trigger is CronTrigger) {
          await trigger.stop();
        }
      } catch (e) {
        developer.log('[TriggerManager] Error stopping trigger: $e');
      }
    }

    developer.log('[TriggerManager] Deactivated $workflowId');
  }

  /// Stop all active triggers.
  Future<void> deactivateAll() async {
    final ids = _active.keys.toList();
    for (final id in ids) {
      await deactivateWorkflow(id);
    }
  }
}
