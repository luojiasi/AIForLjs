import 'dart:io';

import 'package:ai_chat_app/core/services/haptics.dart';
import 'package:ai_chat_app/core/services/logging/flutter_logging.dart';
import 'package:ai_chat_app/core/services/network/request_logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局设置管理，后续逐步扩展
class SettingsProvider extends ChangeNotifier {


  ///==============
  /// 主题与外观设置
  static const String _themeModeKey = 'theme_mode-v1';
  static const String _themePaletteKey ='theme_palette_v1';
  static const String _useDynamicColorKey = 'use_dynamic_color_v1';
  static const String _displayUsePureBackgroundKey ='display_use_pure_background_v1';
  ///==============
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  String _themePaletteId = 'default';
  String get themePaletteId => _themePaletteId;
  bool _useDynamicColor = true;
  bool get useDynamicColor => _useDynamicColor;
  bool _dynamicColorSupported = false;
  bool get dynamicColorSupported => _dynamicColorSupported;
  bool _usePureBackground = false;
  bool get usePureBackground => _usePureBackground;

  ///设置主题模式  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode =mode;
     notifyListeners();
     final prefs = await SharedPreferences.getInstance();
     final v = mode ==ThemeMode.light?'light':mode == ThemeMode.dark?'dark':'system';
     await prefs.setString(_themeModeKey, v);
  }
  ///设置主题色板 
  Future<void> setThemePalette(String id) async {
    if (_themePaletteId == id) return;
    _themePaletteId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePaletteKey, id);
  }
  ///启用/禁用动态取色 
  Future<void> setUseDynamicColor(bool v) async {
    if (_useDynamicColor == v) return;
    _useDynamicColor = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDynamicColorKey, v);
  }
  ///标记设备是否支持动态取色
  Future<void> setUsePureBackground(bool v) async {
    if (_usePureBackground == v) return;
    _usePureBackground = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayUsePureBackgroundKey, v);
  }
  ///纯色背景模式 
  void setDynamicColorSupported(bool v) {
    if (_dynamicColorSupported == v) return;
    _dynamicColorSupported = v;
    notifyListeners();
  }
  ///切换深色/浅色 
  void toggleTheme() => setThemeMode(
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );
  ///跟随系统主题 
  void followSystem() => setThemeMode(ThemeMode.system);




  ///=========
  ///地区与语言
  static const String _appLocaleKey = 'app_locale_v1';
  ///=========
  String? _appLocaleTag;
  Locale get appLocale => _parseLocaleTag(_appLocaleTag ?? 'en_US');
  bool get isFollowingSystemLocale =>(_appLocaleTag == null) || (_appLocaleTag == 'system');
  Locale? get appLocaleForMaterialApp =>isFollowingSystemLocale ? null : appLocale;
  ///设置应用语言
  Future<void> setAppLocale(Locale locale) async {
    final tag = _localeToTag(locale);
    if (_appLocaleTag == tag) return;
    _appLocaleTag = tag;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appLocaleKey, _appLocaleTag!);
  }
  ///跟随系统语言
  Future<void> setAppLocaleFollowSystem() async {
    if (_appLocaleTag == 'system') return;
    _appLocaleTag = 'system';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appLocaleKey, 'system');
  }
   String _localeToTag(Locale l) {
    final lc = l.languageCode.toLowerCase();
    if (lc == 'zh') {
      final script = (l.scriptCode ?? '').toLowerCase();
      if (script == 'hant') return 'zh_Hant';
      return 'zh_CN';
    }
    return 'en_US';
  }
  Locale _parseLocaleTag(String tag) {
    switch (tag) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'zh_Hant':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      case 'en_US':
      default:
        return const Locale('en', 'US');
    }
  }



  ///=======
  ///日志配置
  static const String _requestLogEnabledKey = 'request_log_enabled_v1';
  static const String _flutterLogEnabledKey = 'flutter_log_enabled_v1';
  static const String _logSaveOutputKey = 'log_save_output_v1';
  static const String _logAutoDeleteDaysKey = 'log_auto_delete_days_v1';
  static const String _logMaxSizeMBKey = 'log_max_size_mb_v1';
  ///=======
  bool _requestLogEnabled = false;
  bool get requestLogEnabled => _requestLogEnabled;
  bool _flutterLogEnabled = false;
  bool get flutterLogEnabled => _flutterLogEnabled;
  bool _logSaveOutput = true;
  bool get logSaveOutput => _logSaveOutput;
  int _logAutoDeleteDays = 0;
  int get logAutoDeleteDays => _logAutoDeleteDays;
  int _logMaxSizeMB = 0;
  int get logMaxSizeMB => _logMaxSizeMB;

  ///请求日志开关
  Future<void> setRequestLogEnabled(bool v) async {
    if (_requestLogEnabled == v) return;
    _requestLogEnabled = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requestLogEnabledKey, v);
    await RequestLogger.setEnabled(v);
  }
  ///Flutter日志开关
  Future<void> setFlutterLogEnabled(bool v) async {
    if (_flutterLogEnabled == v) return;
    _flutterLogEnabled = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_flutterLogEnabledKey, v);
    await FlutterLogger.setEnabled(v);
  }
  ///保存响应输出
  Future<void> setLogSaveOutput(bool v) async {
    if (_logSaveOutput == v) return;
    _logSaveOutput = v;
    RequestLogger.saveOutput = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_logSaveOutputKey, v);
  }
  ///自动删除天数
  Future<void> setLogAutoDeleteDays(int v) async {
    if (_logAutoDeleteDays == v) return;
    _logAutoDeleteDays = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_logAutoDeleteDaysKey, v);
    RequestLogger.cleanupLogs(autoDeleteDays: v, maxSizeMB: _logMaxSizeMB);
  }
  ///日志最大MB数
  Future<void> setLogMaxSizeMB(int v) async {
    if (_logMaxSizeMB == v) return;
    _logMaxSizeMB = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_logMaxSizeMBKey, v);
    RequestLogger.cleanupLogs(autoDeleteDays: _logAutoDeleteDays, maxSizeMB: v);
  }

  /// =======
  /// 触感反馈
  static const _displayHapticsOnListItemTapKey ='display_haptics_on_list_item_tap_v1';
  static const String _displayHapticsIosSwitchKey ='display_haptics_ios_switch_v1';
  static const String _displayHapticsGlobalEnabledKey ='display_haptics_global_enabled_v1';
  static const String _displayHapticsOnCardTapKey ='display_haptics_on_card_tap_v1';
  /// ======= 
  bool _hapticsOnListItemTap = true;
  bool get hapticsOnListItemTap => _hapticsOnListItemTap;
  Future<void> setHapticsOnListItemTap(bool v) async {
    if (_hapticsOnListItemTap == v) return;
    _hapticsOnListItemTap = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayHapticsOnListItemTapKey, v);
  }
  bool _hapticsIosSwitch = true;
  bool get hapticsIosSwitch => _hapticsIosSwitch;
  Future<void> setHapticsIosSwitch(bool v) async {
    if (_hapticsIosSwitch == v) return;
    _hapticsIosSwitch = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayHapticsIosSwitchKey, v);
  }
  bool _hapticsGlobalEnabled = true;
  bool get hapticsGlobalEnabled => _hapticsGlobalEnabled;
  Future<void> setHapticsGlobalEnabled(bool v) async {
    if (_hapticsGlobalEnabled == v) return;
    _hapticsGlobalEnabled = v;
    Haptics.setEnabled(v);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayHapticsGlobalEnabledKey, v);
  }
  bool _hapticsOnCardTap = true;
  bool get hapticsOnCardTap => _hapticsOnCardTap;
  Future<void> setHapticsOnCardTap(bool v) async {
    if (_hapticsOnCardTap == v) return;
    _hapticsOnCardTap = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayHapticsOnCardTapKey, v);
  }

  ///============
  ///Android 后台
  static const String _androidBackgroundChatModeKey ='android_background_chat_mode_v1';
  ///============
  AndroidBackgroundChatMode _androidBackgroundChatMode = AndroidBackgroundChatMode.off;
  AndroidBackgroundChatMode get androidBackgroundChatMode =>_androidBackgroundChatMode;
  Future<void> setAndroidBackgroundChatMode(AndroidBackgroundChatMode mode,)async{
    if (_androidBackgroundChatMode == mode) return;
    _androidBackgroundChatMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final v = switch (mode) {
      AndroidBackgroundChatMode.onNotify => 'on_notify',
      AndroidBackgroundChatMode.on => 'on',
      AndroidBackgroundChatMode.off => 'off',
    };
    await prefs.setString(_androidBackgroundChatModeKey, v);
    try {
      if (Platform.isAndroid) {
        // Direct call; file is present in project and guards by Platform
        // ignore: depend_on_referenced_packages
        // ignore_for_file: unnecessary_import
        // ignore: avoid_print
        // Defer import here is not possible; rely on main.dart sync. This is a no-op placeholder.
      }
    } catch (_) {}
  }
  ///================
  ///桌面专有
  static const String _displayDesktopShowTrayKey ='display_desktop_show_tray_v1';
  static const String _displayDesktopMinimizeToTrayOnCloseKey ='display_desktop_minimize_to_tray_on_close_v1';
  ///================
  bool _desktopShowTray = false;
  bool get desktopShowTray => _desktopShowTray;
  bool _desktopMinimizeToTrayOnClose = false;
  bool get desktopMinimizeToTrayOnClose => _desktopMinimizeToTrayOnClose;
  Future<void> setDesktopShowTray(bool v) async {
    if (_desktopShowTray == v) return;
    _desktopShowTray = v;
    if (!_desktopShowTray && _desktopMinimizeToTrayOnClose) {
      _desktopMinimizeToTrayOnClose = false;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayDesktopShowTrayKey, _desktopShowTray);
    await prefs.setBool(
      _displayDesktopMinimizeToTrayOnCloseKey,
      _desktopMinimizeToTrayOnClose,
    );
  }
  Future<void> setDesktopMinimizeToTrayOnClose(bool v) async {
    final next = _desktopShowTray ? v : false;
    if (_desktopMinimizeToTrayOnClose == next) return;
    _desktopMinimizeToTrayOnClose = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _displayDesktopMinimizeToTrayOnCloseKey,
      _desktopMinimizeToTrayOnClose,
    );
  }

  ///================
  ///侧边栏行为 & 更新
  static const String _displayShowAppUpdatesKey = 'display_show_app_updates_v1';
  ///================
  bool _showAppUpdates = true;
  bool get showAppUpdates => _showAppUpdates;
  Future<void> setShowAppUpdates(bool v) async {
    if (_showAppUpdates == v) return;
    _showAppUpdates = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayShowAppUpdatesKey, v);
  }



  ///====
  ///字体
  ///====
  String? _appFontLocalAlias;
  String? _appFontFamily;
  String? _codeFontFamily;
  bool _appFontIsGoogle = false;
  bool _codeFontIsGoogle = false;
  String? _codeFontLocalAlias;

  String? get appFontFamily => _effectiveAppFontAlias ?? _appFontFamily;
  String? get appFontLocalAlias => _appFontLocalAlias;
  String? get codeFontLocalAlias => _codeFontLocalAlias;
  String? get _effectiveAppFontAlias =>(_appFontLocalAlias?.isNotEmpty == true) ? _appFontLocalAlias : null;
  bool get appFontIsGoogle => _appFontIsGoogle;
  String? get codeFontFamily => _effectiveCodeFontAlias ?? _codeFontFamily;
  String? get _effectiveCodeFontAlias => (_codeFontLocalAlias?.isNotEmpty == true) ? _codeFontLocalAlias : null;
  bool get codeFontIsGoogle => _codeFontIsGoogle;

  ///=======
  ///消息显示设置
  static const String _displayShowMessageNavKey = 'display_show_message_nav_v1';
  static const String _displayChatBackgroundMaskStrengthKey ='display_chat_background_mask_strength_v1';
  ///=======
  bool _showMessageNavButtons = true;
  bool get showMessageNavButtons => _showMessageNavButtons;
  Future<void> setShowMessageNavButtons(bool v) async {
    if (_showMessageNavButtons == v) return;
    _showMessageNavButtons = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayShowMessageNavKey, v);
  }

  double _chatBackgroundMaskStrength = 1.0;
  double get chatBackgroundMaskStrength => _chatBackgroundMaskStrength;
  Future<void> setChatBackgroundMaskStrength(double strength) async {
    final s = strength.clamp(0.0, 2.0);
    if (_chatBackgroundMaskStrength == s) return;
    _chatBackgroundMaskStrength = s;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_displayChatBackgroundMaskStrengthKey,_chatBackgroundMaskStrength,);
  }

  ///================
  ///Markdown/数学渲染
  static const String _displayEnableMathRenderingKey = 'display_enable_math_rendering_v1';
  static const String _displayEnableDollarLatexKey = 'display_enable_dollar_latex_v1';
  static const String _displayEnableUserMarkdownKey = 'display_enable_user_markdown_v1';
  static const String _displayEnableReasoningMarkdownKey = 'display_enable_reasoning_markdown_v1';
  static const String _displayEnableAssistantMarkdownKey = 'display_enable_assistant_markdown_v1';
  ///================
  // LaTeX 数学公式渲染
  bool _enableMathRendering = true;
  bool get enableMathRendering => _enableMathRendering;
  Future<void> setEnableMathRendering(bool v) async {
    if (_enableMathRendering == v) return;
    _enableMathRendering = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayEnableMathRenderingKey, v);
  }

  // `$...$` 行内 LaTeX
  bool _enableDollarLatex = true;
  bool get enableDollarLatex => _enableDollarLatex;
  Future<void> setEnableDollarLatex(bool v) async {
    if (_enableDollarLatex == v) return;
    _enableDollarLatex = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayEnableDollarLatexKey, v);
  }
  // 用户消息的MarkDown
  bool _enableUserMarkdown = true;
  bool get enableUserMarkdown => _enableUserMarkdown;
  Future<void> setEnableUserMarkdown(bool v) async {
    if (_enableUserMarkdown == v) return;
    _enableUserMarkdown = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayEnableUserMarkdownKey, v);
  }
  // 推理过程的MarkDown
  bool _enableReasoningMarkdown = true;
  bool get enableReasoningMarkdown => _enableReasoningMarkdown;
  Future<void> setEnableReasoningMarkdown(bool v) async {
    if (_enableReasoningMarkdown == v) return;
    _enableReasoningMarkdown = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayEnableReasoningMarkdownKey, v);
  }
  // 助手消息的MarkDown
  bool _enableAssistantMarkdown = true;
  bool get enableAssistantMarkdown => _enableAssistantMarkdown;
  Future<void> setEnableAssistantMarkdown(bool v) async {
    if (_enableAssistantMarkdown == v) return;
    _enableAssistantMarkdown = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayEnableAssistantMarkdownKey, v);
  }

  ///=========
  ///代码块设置
  static const String _displayAutoCollapseCodeBlockKey = 'display_auto_collapse_code_block_v1';
  static const String _displayAutoCollapseCodeBlockLinesKey = 'display_auto_collapse_code_block_lines_v1';
  static const String _displayMobileCodeBlockWrapKey = 'display_mobile_code_block_wrap_v1';
  ///=========
  //自动折叠过长代码块
  bool _autoCollapseCodeBlock = false;
  bool get autoCollapseCodeBlock => _autoCollapseCodeBlock;
  Future<void> setAutoCollapseCodeBlock(bool v) async {
    if (_autoCollapseCodeBlock == v) return;
    _autoCollapseCodeBlock = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayAutoCollapseCodeBlockKey, v);
  }
  //折叠阈值（行数，默认2）
  int _autoCollapseCodeBlockLines = 2;
  int get autoCollapseCodeBlockLines => _autoCollapseCodeBlockLines;
  Future<void> setAutoCollapseCodeBlockLines(int lines) async {
    final nextLines = lines.clamp(1, 100);
    if (_autoCollapseCodeBlockLines == nextLines) return;
    _autoCollapseCodeBlockLines = nextLines;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_displayAutoCollapseCodeBlockLinesKey, nextLines);
  }
  // 移动端代码块自动换行
  bool _mobileCodeBlockWrap = false;
  bool get mobileCodeBlockWrap => _mobileCodeBlockWrap;
  Future<void> setMobileCodeBlockWrap(bool v) async {
    if (_mobileCodeBlockWrap == v) return;
    _mobileCodeBlockWrap = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayMobileCodeBlockWrapKey, v);
  }

}
enum AndroidBackgroundChatMode { off, on, onNotify }
