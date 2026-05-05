// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Welcome To SYCTB';

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

  @override
  String get settingsPageBackButton => 'Back';

  @override
  String get settingsPageAbout => 'About';

  @override
  String get aboutPageAppDescription => 'Shan Yi Chat To Ai ';

  @override
  String get aboutPageVersion => 'Version';

  @override
  String get aboutPageSystem => 'System';

  @override
  String get aboutPageWebsite => 'Website';

  @override
  String get aboutPageGithub => 'GitHub';

  @override
  String get aboutPageLicense => 'License';

  @override
  String get aboutPageJoinQQGroup => 'Join our QQ Group';

  @override
  String get aboutPageJoinDiscord => 'Join us on Discord';

  @override
  String get aboutPageStudyLearning => 'Study Learning';

  @override
  String get aboutPageEasterEggButton => 'Nice!';

  @override
  String get aboutPageAppName => 'SYCTB';

  @override
  String get requestLogSettingTitle => 'Request Logging';

  @override
  String get requestLogSettingSubtitle =>
      'When enabled, request/response details are written to logs/logs.txt (rotated daily).';

  @override
  String get flutterLogSettingTitle => 'Flutter Logging';

  @override
  String get flutterLogSettingSubtitle =>
      'When enabled, Flutter errors and print output are written to logs/flutter_logs.txt (rotated daily).';

  @override
  String get logViewerCurrentLog => 'Current Log';

  @override
  String get logViewerExport => 'Export';

  @override
  String get logViewerEmpty => 'No logs yet';

  @override
  String get logSettingsTitle => 'Log Settings';

  @override
  String get logSettingsSaveOutput => 'Save Response Output';

  @override
  String get logSettingsSaveOutputSubtitle =>
      'Log response body content (may use significant storage)';

  @override
  String get logSettingsAutoDelete => 'Auto-delete';

  @override
  String get logSettingsAutoDeleteSubtitle =>
      'Delete logs older than specified days';

  @override
  String get logSettingsAutoDeleteDisabled => 'Disabled';

  @override
  String logSettingsAutoDeleteDays(int count) {
    return '$count days';
  }

  @override
  String get logSettingsMaxSize => 'Max Log Size';

  @override
  String get logSettingsMaxSizeSubtitle => 'Oldest logs deleted when exceeded';

  @override
  String get logSettingsMaxSizeUnlimited => 'Unlimited';

  @override
  String get storageSpaceSubLogsFlutter => 'Flutter logs';

  @override
  String get storageSpaceSubLogsRequests => 'Network logs';

  @override
  String get storageSpaceSubLogsOther => 'Other logs';

  @override
  String get storageSpaceCategoryLogs => 'Logs';

  @override
  String get logViewerTitle => 'Request Logs';

  @override
  String logViewerRequestsCount(int count) {
    return '$count requests';
  }

  @override
  String get chatMessageWidgetCopiedToClipboard => 'Copied to clipboard';

  @override
  String get logViewerFieldId => 'ID';

  @override
  String get logViewerFieldMethod => 'Method';

  @override
  String get logViewerFieldStatus => 'Status';

  @override
  String get logViewerFieldStarted => 'Started';

  @override
  String get logViewerFieldEnded => 'Ended';

  @override
  String get logViewerFieldDuration => 'Duration';

  @override
  String get logViewerSectionSummary => 'Summary';

  @override
  String get logViewerSectionParameters => 'Parameters';

  @override
  String get logViewerSectionRequestHeaders => 'Request Headers';

  @override
  String get logViewerSectionRequestBody => 'Request Body';

  @override
  String get logViewerSectionResponseHeaders => 'Response Headers';

  @override
  String get logViewerSectionResponseBody => 'Response Body';

  @override
  String get logViewerSectionWarnings => 'Warnings';

  @override
  String get logViewerErrorTitle => 'Error';

  @override
  String logViewerMoreCount(int count) {
    return '+$count more';
  }

  @override
  String get hotkeyToggleAppVisibility => 'Show/Hide App';

  @override
  String get hotkeyCloseWindow => 'Close Window';

  @override
  String get hotkeyOpenSettings => 'Open Settings';

  @override
  String get hotkeyNewTopic => 'New Topic';

  @override
  String get hotkeySwitchModel => 'Switch Model';

  @override
  String get hotkeyToggleAssistantPanel => 'Toggle Assistants';

  @override
  String get hotkeyToggleTopicPanel => 'Toggle Topics';

  @override
  String get hotkeysPressShortcut => 'Press a shortcut';

  @override
  String get hotkeysResetDefault => 'Reset to default';

  @override
  String get hotkeysClearShortcut => 'Clear shortcut';

  @override
  String get hotkeysResetAll => 'Reset all to defaults';

  @override
  String get androidBackgroundNotificationTitle => 'SYCTB is running';

  @override
  String get androidBackgroundNotificationText =>
      'Keeping App alive in background';

  @override
  String get desktopTrayMenuShowWindow => 'Show Window';

  @override
  String get desktopTrayMenuExit => 'Exit';

  @override
  String get desktopNavChatTooltip => 'Chat';

  @override
  String get desktopNavTranslateTooltip => 'Translate';

  @override
  String get desktopNavStorageTooltip => 'Storage';

  @override
  String get desktopNavGlobalSearchTooltip => 'Global Search';

  @override
  String get desktopNavThemeToggleTooltip => 'Theme';

  @override
  String get desktopNavSettingsTooltip => 'Settings';

  @override
  String get desktopAvatarMenuUseEmoji => 'Use emoji';

  @override
  String get backupPageUsername => 'Username';

  @override
  String get backupPagePassword => 'Password';

  @override
  String get sideDrawerNicknameHint => 'Enter new nickname';

  @override
  String get sideDrawerRename => 'Rename';

  @override
  String get sideDrawerEnterLink => 'Enter Link';

  @override
  String get sideDrawerImportFromQQ => 'Import from QQ';

  @override
  String get sideDrawerReset => 'Reset';

  @override
  String get sideDrawerEmojiDialogTitle => 'Choose Emoji';

  @override
  String get sideDrawerEmojiDialogHint => 'Type or paste any emoji';

  @override
  String get sideDrawerImageUrlDialogTitle => 'Enter Image URL';

  @override
  String get sideDrawerImageUrlDialogHint =>
      'e.g. https://example.com/avatar.png';

  @override
  String get sideDrawerQQAvatarDialogTitle => 'Import from QQ';

  @override
  String get sideDrawerQQAvatarInputHint => 'Enter QQ number (5-12 digits)';

  @override
  String get sideDrawerQQAvatarFetchFailed =>
      'Failed to fetch random QQ avatar. Please try again.';

  @override
  String get sideDrawerRandomQQ => 'Random QQ';

  @override
  String get sideDrawerGalleryOpenError =>
      'Unable to open gallery. Try entering an image URL.';

  @override
  String get sideDrawerGeneralImageError =>
      'Something went wrong. Try entering an image URL.';

  @override
  String get sideDrawerSetNicknameTitle => 'Set Nickname';

  @override
  String get sideDrawerNicknameLabel => 'Nickname';

  @override
  String get desktopAvatarMenuReset => 'Reset avatar';

  @override
  String get sideDrawerCancel => 'Cancel';

  @override
  String get sideDrawerOK => 'OK';

  @override
  String get sideDrawerSave => 'Save';

  @override
  String get assistantEditEmojiDialogTitle => 'Choose Emoji';

  @override
  String get assistantEditEmojiDialogHint => 'Type or paste any emoji';

  @override
  String get assistantEditEmojiDialogCancel => 'Cancel';

  @override
  String get assistantEditEmojiDialogSave => 'Save';

  @override
  String get desktopAvatarMenuChangeFromImage => 'Change from image…';

  @override
  String get homePageCancel => 'Cancel';

  @override
  String get homePageDelete => 'Delete';

  @override
  String get homePageDone => 'Done';

  @override
  String get assistantProviderDefaultAssistantName => 'Default Assistant';

  @override
  String get assistantProviderSampleAssistantName => 'Sample Assistant';

  @override
  String get assistantProviderNewAssistantName => 'New Assistant';

  @override
  String assistantProviderSampleAssistantSystemPrompt(
    String model_name,
    String cur_datetime,
    String locale,
    String timezone,
    String device_info,
    String system_version,
  ) {
    return 'You are $model_name, an AI assistant who gladly provides accurate and helpful assistance. The current time is $cur_datetime, the device language is $locale, timezone is $timezone, the user is using $device_info, version $system_version. If the user does not explicitly specify otherwise, please use the user\'s device language when replying.';
  }

  @override
  String get assistantSettingsCopySuffix => 'Copy';

  @override
  String get homePageDefaultAssistant => 'Default Assistant';
}
