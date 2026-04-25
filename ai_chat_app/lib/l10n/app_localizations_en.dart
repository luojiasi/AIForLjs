// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Chat';

  @override
  String get newConversation => 'New conversation';

  @override
  String get sendMessage => 'Send';

  @override
  String get inputHint => 'Type a message...';

  @override
  String get settings => 'Settings';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get apiKey => 'API Key';

  @override
  String get model => 'Model';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get noMessages => 'No messages yet. Start a conversation!';

  @override
  String get deleteConversation => 'Delete this conversation?';

  @override
  String get searchPlaceholder => 'Search conversations...';
}
