import 'package:ai_chat_app/core/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsProvider', () {
    late SettingsProvider provider;

    setUp(() {
      provider = SettingsProvider();
    });

    test('default themeMode is system', () {
      expect(provider.themeMode, equals(ThemeMode.system));
    });
    test('setThemeMode updates themeMode', () {
      provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode with same value does not notify', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      provider.setThemeMode(ThemeMode.system);
      expect(notifyCount, equals(0));
    });


    test('notifies listeners on themeMode change', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      provider.setThemeMode(ThemeMode.dark);
      expect(notifyCount, equals(1));
    });

    test('notifies listeners on locale change', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      expect(notifyCount, equals(1));
    });
  });
}
