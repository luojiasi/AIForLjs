import 'dart:io' show Platform;
import 'package:flutter_background/flutter_background.dart';
//  封装了一层，统一管理初始化和状态检查，避免直接在各页面散落 flutter_background 的调用

class AndroidBackgroundManager {
  static bool _initialized = false;
  ///构建 FlutterBackgroundAndroidConfig，配置前台通知的标题/内容/图标，调用 FlutterBackground.initialize()
  static Future<bool> ensureInitialized({
    String? notificationTitle,
    String? notificationText,
  }) async {
    if (!Platform.isAndroid) return false;
    if (_initialized) return true;
    try {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: notificationTitle ?? 'SYCTB is running',
        notificationText:notificationText ?? '人不会一直倒霉，除非你还不够努力',
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: const AndroidResource(
          name: 'ic_launcher', // 用 App 启动图标
          defType: 'mipmap',   // 从 mipmap 资源目录取（Android 标准做法）
        ),
      );
      final ok = await FlutterBackground.initialize(
        androidConfig: androidConfig,
      );
      _initialized = ok;
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// setEnabled(false) 不会触发 ensureInitialized()，因为关闭后台不需要弹初始化权限弹窗；而 setEnabled(true) 才会补初始化
  static Future<void> setEnabled(bool enable) async {
    if (!Platform.isAndroid) return;
    try {
      try {
        final current = FlutterBackground.isBackgroundExecutionEnabled;
        if (current == enable) return;
      } catch (_) {}

      if (enable) {
        if (!_initialized) {
          await ensureInitialized();
        }
        await FlutterBackground.enableBackgroundExecution();
      } else {
        try {
          await FlutterBackground.disableBackgroundExecution();
        } catch (_) {}
      }
    } catch (_) {
    }
  }

  ///  display_settings_page.dart 设置页 │ 用户切换后台模式开关 → setEnabled(true/false) 
  static Future<bool> isEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      return FlutterBackground.isBackgroundExecutionEnabled;
    } catch (_) {
      return false;
    }
  }
}
