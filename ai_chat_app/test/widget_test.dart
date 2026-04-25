import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chat_app/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const AiChatApp());
    await tester.pump();

    // Verify the app renders with the title
    expect(find.text('AI Chat'), findsWidgets);
  });
}
