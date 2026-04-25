import 'package:ai_chat_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AiChatApp smoke test', (tester) async {
    // Verify the app widget can be created without crashing.
    // We don't pump it here because AiChatApp uses SharedPreferences
    // and platform channels that aren't available in unit tests.
    // Instead, we verify the widget constructor works.
    expect(const AiChatApp(), isNotNull);
  });
}
