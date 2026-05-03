import 'package:ai_chat_app/features/home/pages/home_page.dart';
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomePage displays app title and new conversation text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the AppBar title is present (l10n.appTitle = 'AI Chat')
    expect(find.text('AI Chat'), findsOneWidget);

    // Verify the body text is present (l10n.newConversation = 'New conversation')
    expect(find.text('New conversation'), findsOneWidget);
  });

  testWidgets('HomePage displays Chinese localization', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('zh'),
        home: HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    // Chinese: 新建对话
    expect(find.text('AI 聊天'), findsOneWidget);
    expect(find.text('新建对话'), findsOneWidget);
  });
}
