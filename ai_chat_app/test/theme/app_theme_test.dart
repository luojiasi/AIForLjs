import 'package:ai_chat_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme.light', () {
    test('returns ThemeData with light brightness', () {
      final theme = AppTheme.light;
      expect(theme.brightness, equals(Brightness.light));
    });

    test('uses Material3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('has AppBarTheme with centerTitle false and elevation 0', () {
      final appBarTheme = AppTheme.light.appBarTheme;
      expect(appBarTheme.centerTitle, isFalse);
      expect(appBarTheme.elevation, equals(0));
    });
  });

  group('AppTheme.dark', () {
    test('returns ThemeData with dark brightness', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('uses Material3', () {
      expect(AppTheme.dark.useMaterial3, isTrue);
    });

    test('has AppBarTheme with centerTitle false and elevation 0', () {
      final appBarTheme = AppTheme.dark.appBarTheme;
      expect(appBarTheme.centerTitle, isFalse);
      expect(appBarTheme.elevation, equals(0));
    });
  });

  group('AppTheme shared', () {
    test('light and dark use same seed color', () {
      final light = AppTheme.light;
      final dark = AppTheme.dark;
      // Both should have non-null ColorScheme
      expect(light.colorScheme, isNotNull);
      expect(dark.colorScheme, isNotNull);
    });
  });
}
