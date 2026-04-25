import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_app/main.dart';

void main() {
  testWidgets('HomePage 显示标题和新对话提示', (tester) async {
    await tester.pumpWidget(const AiChatApp());
    await tester.pump();

    // AppBar 标题是 "AI Chat"
    expect(find.text('AI Chat'), findsOneWidget);

    // 页面中间显示 "New conversation"
    expect(find.text('New conversation'), findsOneWidget);
  });
}
