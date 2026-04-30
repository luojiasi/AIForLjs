import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get appTitle;

  /// Button to create a new chat conversation
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// Send button tooltip
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// Placeholder text in message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get inputHint;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Theme mode setting label
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Follow system theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// API key setting label
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// AI model selection label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm action label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Shown when there are no messages
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start a conversation!'**
  String get noMessages;

  /// Confirmation dialog for deleting a conversation
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get deleteConversation;

  /// SettingsPageAbout
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchPlaceholder;

  /// No description provided for @settingsPageBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get settingsPageBackButton;

  /// No description provided for @settingsPageAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsPageAbout;

  /// No description provided for @aboutPageAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Shan Yi Chat To Ai '**
  String get aboutPageAppDescription;

  /// No description provided for @aboutPageVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutPageVersion;

  /// No description provided for @aboutPageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get aboutPageSystem;

  /// No description provided for @aboutPageWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutPageWebsite;

  /// No description provided for @aboutPageGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutPageGithub;

  /// No description provided for @aboutPageLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutPageLicense;

  /// No description provided for @aboutPageJoinQQGroup.
  ///
  /// In en, this message translates to:
  /// **'Join our QQ Group'**
  String get aboutPageJoinQQGroup;

  /// No description provided for @aboutPageJoinDiscord.
  ///
  /// In en, this message translates to:
  /// **'Join us on Discord'**
  String get aboutPageJoinDiscord;

  /// No description provided for @aboutPageStudyLearning.
  ///
  /// In en, this message translates to:
  /// **'Study Learning'**
  String get aboutPageStudyLearning;

  /// No description provided for @aboutPageEasterEggButton.
  ///
  /// In en, this message translates to:
  /// **'Nice!'**
  String get aboutPageEasterEggButton;

  /// No description provided for @aboutPageAppName.
  ///
  /// In en, this message translates to:
  /// **'SYCTB'**
  String get aboutPageAppName;

  /// No description provided for @requestLogSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Logging'**
  String get requestLogSettingTitle;

  /// No description provided for @requestLogSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, request/response details are written to logs/logs.txt (rotated daily).'**
  String get requestLogSettingSubtitle;

  /// No description provided for @flutterLogSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Logging'**
  String get flutterLogSettingTitle;

  /// No description provided for @flutterLogSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, Flutter errors and print output are written to logs/flutter_logs.txt (rotated daily).'**
  String get flutterLogSettingSubtitle;

  /// No description provided for @logViewerCurrentLog.
  ///
  /// In en, this message translates to:
  /// **'Current Log'**
  String get logViewerCurrentLog;

  /// No description provided for @logViewerExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get logViewerExport;

  /// No description provided for @logViewerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get logViewerEmpty;

  /// No description provided for @logSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Settings'**
  String get logSettingsTitle;

  /// No description provided for @logSettingsSaveOutput.
  ///
  /// In en, this message translates to:
  /// **'Save Response Output'**
  String get logSettingsSaveOutput;

  /// No description provided for @logSettingsSaveOutputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log response body content (may use significant storage)'**
  String get logSettingsSaveOutputSubtitle;

  /// No description provided for @logSettingsAutoDelete.
  ///
  /// In en, this message translates to:
  /// **'Auto-delete'**
  String get logSettingsAutoDelete;

  /// No description provided for @logSettingsAutoDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete logs older than specified days'**
  String get logSettingsAutoDeleteSubtitle;

  /// No description provided for @logSettingsAutoDeleteDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get logSettingsAutoDeleteDisabled;

  /// No description provided for @logSettingsAutoDeleteDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String logSettingsAutoDeleteDays(int count);

  /// No description provided for @logSettingsMaxSize.
  ///
  /// In en, this message translates to:
  /// **'Max Log Size'**
  String get logSettingsMaxSize;

  /// No description provided for @logSettingsMaxSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Oldest logs deleted when exceeded'**
  String get logSettingsMaxSizeSubtitle;

  /// No description provided for @logSettingsMaxSizeUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get logSettingsMaxSizeUnlimited;

  /// No description provided for @storageSpaceSubLogsFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter logs'**
  String get storageSpaceSubLogsFlutter;

  /// No description provided for @storageSpaceSubLogsRequests.
  ///
  /// In en, this message translates to:
  /// **'Network logs'**
  String get storageSpaceSubLogsRequests;

  /// No description provided for @storageSpaceSubLogsOther.
  ///
  /// In en, this message translates to:
  /// **'Other logs'**
  String get storageSpaceSubLogsOther;

  /// No description provided for @storageSpaceCategoryLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get storageSpaceCategoryLogs;

  /// No description provided for @logViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Logs'**
  String get logViewerTitle;

  /// No description provided for @logViewerRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} requests'**
  String logViewerRequestsCount(int count);

  /// No description provided for @chatMessageWidgetCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get chatMessageWidgetCopiedToClipboard;

  /// No description provided for @logViewerFieldId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get logViewerFieldId;

  /// No description provided for @logViewerFieldMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get logViewerFieldMethod;

  /// No description provided for @logViewerFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get logViewerFieldStatus;

  /// No description provided for @logViewerFieldStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get logViewerFieldStarted;

  /// No description provided for @logViewerFieldEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get logViewerFieldEnded;

  /// No description provided for @logViewerFieldDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get logViewerFieldDuration;

  /// No description provided for @logViewerSectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get logViewerSectionSummary;

  /// No description provided for @logViewerSectionParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get logViewerSectionParameters;

  /// No description provided for @logViewerSectionRequestHeaders.
  ///
  /// In en, this message translates to:
  /// **'Request Headers'**
  String get logViewerSectionRequestHeaders;

  /// No description provided for @logViewerSectionRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Request Body'**
  String get logViewerSectionRequestBody;

  /// No description provided for @logViewerSectionResponseHeaders.
  ///
  /// In en, this message translates to:
  /// **'Response Headers'**
  String get logViewerSectionResponseHeaders;

  /// No description provided for @logViewerSectionResponseBody.
  ///
  /// In en, this message translates to:
  /// **'Response Body'**
  String get logViewerSectionResponseBody;

  /// No description provided for @logViewerSectionWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get logViewerSectionWarnings;

  /// No description provided for @logViewerErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logViewerErrorTitle;

  /// No description provided for @logViewerMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String logViewerMoreCount(int count);

  /// No description provided for @hotkeyToggleAppVisibility.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide App'**
  String get hotkeyToggleAppVisibility;

  /// No description provided for @hotkeyCloseWindow.
  ///
  /// In en, this message translates to:
  /// **'Close Window'**
  String get hotkeyCloseWindow;

  /// No description provided for @hotkeyOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get hotkeyOpenSettings;

  /// No description provided for @hotkeyNewTopic.
  ///
  /// In en, this message translates to:
  /// **'New Topic'**
  String get hotkeyNewTopic;

  /// No description provided for @hotkeySwitchModel.
  ///
  /// In en, this message translates to:
  /// **'Switch Model'**
  String get hotkeySwitchModel;

  /// No description provided for @hotkeyToggleAssistantPanel.
  ///
  /// In en, this message translates to:
  /// **'Toggle Assistants'**
  String get hotkeyToggleAssistantPanel;

  /// No description provided for @hotkeyToggleTopicPanel.
  ///
  /// In en, this message translates to:
  /// **'Toggle Topics'**
  String get hotkeyToggleTopicPanel;

  /// No description provided for @hotkeysPressShortcut.
  ///
  /// In en, this message translates to:
  /// **'Press a shortcut'**
  String get hotkeysPressShortcut;

  /// No description provided for @hotkeysResetDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get hotkeysResetDefault;

  /// No description provided for @hotkeysClearShortcut.
  ///
  /// In en, this message translates to:
  /// **'Clear shortcut'**
  String get hotkeysClearShortcut;

  /// No description provided for @hotkeysResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all to defaults'**
  String get hotkeysResetAll;

  /// No description provided for @androidBackgroundNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'SYCTB is running'**
  String get androidBackgroundNotificationTitle;

  /// No description provided for @androidBackgroundNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Keeping App alive in background'**
  String get androidBackgroundNotificationText;

  /// No description provided for @desktopTrayMenuShowWindow.
  ///
  /// In en, this message translates to:
  /// **'Show Window'**
  String get desktopTrayMenuShowWindow;

  /// No description provided for @desktopTrayMenuExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get desktopTrayMenuExit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
