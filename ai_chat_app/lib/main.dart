// import 'package:ai_chat_app/presentation/page/practice/01_state_management/counter_demo.dart';
import 'package:ai_chat_app/presentation/page/practice/04_lifecycle/lifecycle.dart';
// import 'package:ai_chat_app/presentation/page/practice/05_layout/widgetlayout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ai_chat_app/app.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ai_chat_app/core/utils/app_logger.dart';
import 'package:ai_chat_app/core/utils/monitoring.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志与监控
  await AppLogger().init();
  Monitoring.init();

  // 桌面端配置窗口（Windows/macOS/Linux），Web 和 Android 跳过
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.center();
    await windowManager.show();
  }

  runZonedGuarded(() {
    // runApp(ProviderScope(
    //   observers: [Monitoring.providerObserver],
    //   child: const AiChatApp(),
    // ));
    runApp(const MaterialApp(
        home: Scaffold(body: Center(child: LifecycleDemo()))));
  }, (error, stack) {
    AppLogger().error('未捕获的 Zone 异常', error, stack);
  });
}
