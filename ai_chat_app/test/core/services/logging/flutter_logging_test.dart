import 'package:ai_chat_app/core/services/logging/flutter_logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterLogger.setEnabled', () {
    setUp(() {
      // Ensure a clean state before each test
      FlutterLogger.setEnabled(false);
    });

    test('default state is disabled', () {
      expect(FlutterLogger.enabled, isFalse);
    });

    test('setEnabled(true) enables logging', () async {
      await FlutterLogger.setEnabled(true);
      expect(FlutterLogger.enabled, isTrue);
    });

    test('setEnabled(false) disables logging', () async {
      await FlutterLogger.setEnabled(true);
      await FlutterLogger.setEnabled(false);
      expect(FlutterLogger.enabled, isFalse);
    });

    test('setEnabled(true) twice does not throw', () async {
      await FlutterLogger.setEnabled(true);
      await FlutterLogger.setEnabled(true);
      expect(FlutterLogger.enabled, isTrue);
    });

    test('log does not throw when disabled', () {
      expect(() => FlutterLogger.log('test'), returnsNormally);
    });

    test('log does not throw when enabled', () async {
      await FlutterLogger.setEnabled(true);
      expect(() => FlutterLogger.log('test message'), returnsNormally);
    });

    test('log with tag does not throw', () async {
      await FlutterLogger.setEnabled(true);
      expect(
        () => FlutterLogger.log('test', tag: 'TestTag'),
        returnsNormally,
      );
    });
  });

  group('FlutterLogger.installGlobalHandlers', () {
    test('installGlobalHandlers does not throw', () {
      expect(() => FlutterLogger.installGlobalHandlers(), returnsNormally);
    });

    test('installGlobalHandlers can be called twice without error', () {
      FlutterLogger.installGlobalHandlers();
      expect(() => FlutterLogger.installGlobalHandlers(), returnsNormally);
    });
  });
}
