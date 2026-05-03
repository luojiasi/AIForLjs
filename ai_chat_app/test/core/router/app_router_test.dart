import 'package:ai_chat_app/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appRouter', () {
    test('routeObserver is defined', () {
      expect(routeObserver, isNotNull);
    });

    test('appRouter is defined', () {
      expect(appRouter, isNotNull);
    });

    test('rootNavigatorKey is defined', () {
      expect(rootNavigatorKey, isNotNull);
    });
  });
}
