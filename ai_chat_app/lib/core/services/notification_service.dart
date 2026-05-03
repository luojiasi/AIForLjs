import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _inited = false;
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'SYCTB always running',// 渠道 ID（唯一标识）
    'Chat Background',// 渠道名称（设置页可见）
    description: 'Notifications for chat generation status',
    importance: Importance.high,// 重要性：高（会发出提示音）
    playSound: true,// 播放声音
  );

  static Future<void> ensureInitialized() async {
    if (!Platform.isAndroid) return;
    if (_inited) return;

    //Android 初始化，指定通知图标
    const AndroidInitializationSettings androidInit =AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings init = InitializationSettings(
      android: androidInit,
    );
    await _plugin.initialize(settings: init); 

    // Create channel
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.createNotificationChannel(_channel);
    }
    _inited = true;
  }
  ///申请通知权限----Android 13+ 的通知权限需要动态申请，逻辑是先检查已授权则跳过，未授权则弹系统授权弹窗
  static Future<bool> ensureAndroidNotificationsPermission() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    try {
      final enabled = await android.areNotificationsEnabled();
      if (enabled == true) return true;
    } catch (_) {}
    try {
      final ok = await android.requestNotificationsPermission();
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> showChatCompleted({String? title, String? body}) async {
    if (!Platform.isAndroid) return;
    await ensureInitialized();
    await _plugin.show(
      id:2001,  // 通知 ID（相同 ID 会覆盖旧通知）
      title:title ?? 'Generation complete',
      body:body ?? 'Assistant reply has been generated',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,// 最高优先级
          priority: Priority.max,
          playSound: true,// 有声音
          enableVibration: true,// 有震动
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          ticker: 'SYCTB',
          styleInformation: const DefaultStyleInformation(true, true),
        ),
      ),
    );
  }
}
