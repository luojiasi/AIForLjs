import 'dart:async';

import '../../models/execution_data.dart';
import '../../models/workflow_model.dart';

/// Parses standard 5-field cron expressions and calculates next fire time.
class CronParser {
  final String expression;

  CronParser(this.expression);

  /// Returns the next [DateTime] after [after] that matches the cron expression.
  /// Returns null if no valid time is found within 2 years.
  DateTime? nextAfter(DateTime after) {
    final fields = _parseFields();
    if (fields == null) return null;

    var candidate = DateTime(after.year, after.month, after.day, after.hour, after.minute)
        .add(const Duration(minutes: 1));
    candidate = DateTime(candidate.year, candidate.month, candidate.day, candidate.hour, candidate.minute);

    final maxIter = 525600; // 1 year of minutes
    for (var i = 0; i < maxIter; i++) {
      if (_matches(candidate, fields)) return candidate;
      candidate = candidate.add(const Duration(minutes: 1));
    }
    return null;
  }

  bool _matches(DateTime dt, List<Set<int>> fields) {
    final vals = [dt.minute, dt.hour, dt.day, dt.month, dt.weekday % 7];
    for (var i = 0; i < 5; i++) {
      if (!fields[i].contains(vals[i])) return false;
    }
    return true;
  }

  List<Set<int>>? _parseFields() {
    final parts = expression.trim().split(RegExp(r'\s+'));
    if (parts.length != 5) return null;

    final result = <Set<int>>[];
    final ranges = [
      [0, 59], [0, 23], [1, 31], [1, 12], [0, 6]
    ];

    for (var i = 0; i < 5; i++) {
      try {
        final values = _parseField(parts[i], ranges[i][0], ranges[i][1]);
        if (values.isEmpty) return null;
        result.add(values);
      } catch (_) {
        return null;
      }
    }
    return result;
  }

  Set<int> _parseField(String field, int min, int max) {
    final values = <int>{};

    for (final part in field.split(',')) {
      if (part == '*') {
        for (var v = min; v <= max; v++) {
          values.add(v);
        }
      } else if (part.startsWith('*/')) {
        final step = int.parse(part.substring(2));
        for (var v = min; v <= max; v += step) {
          values.add(v);
        }
      } else if (part.contains('-')) {
        final rangeParts = part.split('-');
        final start = int.parse(rangeParts[0]);
        final end = int.parse(rangeParts[1]);
        for (var v = start; v <= end; v++) {
          if (v >= min && v <= max) values.add(v);
        }
      } else {
        final v = int.parse(part);
        if (v >= min && v <= max) values.add(v);
      }
    }
    return values;
  }
}

/// Cron-based workflow trigger using a periodic Timer.
class CronTrigger {
  final String id;
  final WorkflowNode node;
  final Workflow workflow;
  final Future<void> Function(List<NodeExecutionData>) onFire;

  CronParser? _parser;
  Timer? _timer;

  CronTrigger({
    required this.id,
    required this.node,
    required this.workflow,
    required this.onFire,
  });

  String? get cronExpression => node.parameters['cronExpression'] as String?;

  Future<void> start() async {
    final expr = cronExpression;
    if (expr == null || expr.isEmpty) return;

    _parser = CronParser(expr);
    _scheduleNext();
  }

  void _scheduleNext() {
    if (_parser == null) return;

    final next = _parser!.nextAfter(DateTime.now());
    if (next == null) return;

    final delay = next.difference(DateTime.now());
    if (delay.inMilliseconds <= 0) {
      _fire();
      return;
    }

    _timer = Timer(delay, _fire);
  }

  void _fire() {
    final data = NodeExecutionData(json: {
      'trigger': 'cron',
      'cronExpression': cronExpression ?? '',
      'firedAt': DateTime.now().toIso8601String(),
    });

    onFire([data]);

    // Schedule next fire after current one completes
    _scheduleNext();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _parser = null;
  }
}
