import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局设置管理，后续逐步扩展
class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode-v1';
  static const String _themePaletteKey ='theme_palette_v1';
  static const String _useDynamicColorKey = 'use_dynamic_color_v1';
  static const String _displayUsePureBackgroundKey ='display_use_pure_background_v1';



  // 主题设置
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

  Locale? _locale;
  Locale? get locale => _locale;
  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode =mode;
     notifyListeners();
     final prefs = await SharedPreferences.getInstance();
     final v = mode ==ThemeMode.light?'light':mode == ThemeMode.dark?'dark':'system';
     await prefs.setString(_themeModeKey, v);
  }

  

  Future<void> setThemePalette(String id) async {
    if (_themePaletteId == id) return;
    _themePaletteId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePaletteKey, id);
  }

  Future<void> setUseDynamicColor(bool v) async {
    if (_useDynamicColor == v) return;
    _useDynamicColor = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDynamicColorKey, v);
  }

  Future<void> setUsePureBackground(bool v) async {
    if (_usePureBackground == v) return;
    _usePureBackground = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_displayUsePureBackgroundKey, v);
  }

  void setDynamicColorSupported(bool v) {
    if (_dynamicColorSupported == v) return;
    _dynamicColorSupported = v;
    notifyListeners();
  }

  void toggleTheme() => setThemeMode(
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  void followSystem() => setThemeMode(ThemeMode.system);
}
