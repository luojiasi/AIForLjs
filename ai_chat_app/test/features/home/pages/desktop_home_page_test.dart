import 'package:ai_chat_app/desktop/widgets/desktop_home_page.dart';
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DesktopHomePage displays app title and new conversation text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DesktopHomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.text('New conversation'), findsOneWidget);
  });

  testWidgets('DesktopHomePage displays Chinese localization',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('zh'),
        home: DesktopHomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 聊天'), findsOneWidget);
    expect(find.text('新建对话'), findsOneWidget);
  });
}
