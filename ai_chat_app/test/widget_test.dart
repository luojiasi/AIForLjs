import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_chat_app/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AiChatApp()));
    await tester.pump();

    // Verify the app renders
    expect(find.text('AI Chat'), findsWidgets);
  });
}
