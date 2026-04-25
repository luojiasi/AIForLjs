import 'package:ai_chat_app/desktop/window_size_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WindowSizeManager constants', () {
    test('min window size is 960x640', () {
      expect(WindowSizeManager.minWindowWidth, equals(960.0));
      expect(WindowSizeManager.minWindowHeight, equals(640.0));
    });

    test('default window size is 1280x860', () {
      expect(WindowSizeManager.defaultWindowWidth, equals(1280.0));
      expect(WindowSizeManager.defaultWindowHeight, equals(860.0));
    });
  });

  group('WindowSizeManager size persistence', () {
    // _clamp is private, but we can test its behavior through setSize/getInitialSize.
    // SharedPreferences must be initialized with mock values before each test.

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('setSize clamps very large values', () async {
      final mgr = const WindowSizeManager();
      await mgr.setSize(const Size(99999, 99999));
      final result = await mgr.getInitialSize();
      expect(result.width, lessThanOrEqualTo(WindowSizeManager.maxWindowWidth));
      expect(result.height, lessThanOrEqualTo(WindowSizeManager.maxWindowHeight));
    });

    test('setSize clamps very small values to min', () async {
      final mgr = const WindowSizeManager();
      await mgr.setSize(const Size(1, 1));
      final result = await mgr.getInitialSize();
      expect(result.width, greaterThanOrEqualTo(WindowSizeManager.minWindowWidth));
      expect(result.height, greaterThanOrEqualTo(WindowSizeManager.minWindowHeight));
    });

    test('setSize with normal size keeps value', () async {
      final mgr = const WindowSizeManager();
      const normal = Size(1200, 800);
      await mgr.setSize(normal);
      final result = await mgr.getInitialSize();
      expect(result.width, equals(1200));
      // Height 800 is below min (640→960 clamped up), actually minHeight is 640 so 800 should stay
      expect(result.height, equals(800));
    });
  });
}
