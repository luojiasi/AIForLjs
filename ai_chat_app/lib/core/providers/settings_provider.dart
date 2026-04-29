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




}
enum AndroidBackgroundChatMode { off, on, onNotify }
