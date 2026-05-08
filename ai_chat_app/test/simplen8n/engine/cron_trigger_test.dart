import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_app/presentation/simplen8n/engine/triggers/cron_trigger.dart';

void main() {
  group('CronParser', () {
    test('every minute */1', () {
      final parser = CronParser('* * * * *');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 12, 1));
    });

    test('specific minute', () {
      final parser = CronParser('30 9 * * *');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 2, 9, 30));
    });

    test('every 5 minutes', () {
      final parser = CronParser('*/5 * * * *');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 12, 5));
    });

    test('exact hour', () {
      final parser = CronParser('0 14 * * *');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 14, 0));
    });

    test('weekdays only', () {
      final parser = CronParser('0 9 * * 1-5');
      // Jan 1, 2026 is Thursday (weekday 4)
      final now = DateTime(2026, 1, 1, 8, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 9, 0));
    });

    test('weekday skips weekend', () {
      final parser = CronParser('0 9 * * 1-5');
      // Jan 2, 2026 is Friday, Jan 3 is Saturday
      final friday = DateTime(2026, 1, 2, 10, 0);
      final next = parser.nextAfter(friday);
      // Next weekday 9am should be Jan 5 (Monday)
      expect(next, DateTime(2026, 1, 5, 9, 0));
    });

    test('list of hours', () {
      final parser = CronParser('0 6,12,18 * * *');
      final now = DateTime(2026, 1, 1, 10, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 12, 0));
    });

    test('range of days', () {
      final parser = CronParser('0 0 1-5 * *');
      final now = DateTime(2026, 1, 1, 1, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 2, 0, 0));
    });

    test('invalid expression returns null', () {
      final parser = CronParser('invalid');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, isNull);
    });

    test('empty expression returns null', () {
      final parser = CronParser('');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, isNull);
    });

    test('midnight daily', () {
      final parser = CronParser('0 0 * * *');
      final now = DateTime(2026, 1, 1, 12, 0);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 2, 0, 0));
    });

    test('same minute returns next minute', () {
      final parser = CronParser('30 9 * * *');
      final now = DateTime(2026, 1, 1, 9, 30);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 2, 9, 30));
    });

    test('next minute within same hour', () {
      final parser = CronParser('* * * * *');
      final now = DateTime(2026, 1, 1, 12, 30);
      final next = parser.nextAfter(now);
      expect(next, DateTime(2026, 1, 1, 12, 31));
    });
  });
}
