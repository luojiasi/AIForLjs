import 'package:ai_chat_app/features/settings/pages/about_page.dart';
import 'package:ai_chat_app/presentation/page/practice/01_state_management/counter_demo.dart';
import 'package:ai_chat_app/presentation/page/practice/02_animation/animation_demo.dart';
import 'package:ai_chat_app/presentation/page/practice/03_framework_classes/framework_classes.dart';
import 'package:ai_chat_app/presentation/page/practice/04_lifecycle/lifecycle.dart';
import 'package:ai_chat_app/presentation/page/practice/05_layout/widgetlayout.dart';

import 'package:ai_chat_app/desktop/widgets/desktop_home_page.dart';
import 'package:ai_chat_app/features/home/pages/home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

/// 全局路由观察者，用于监听页面跳转/返回事件
final RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();

/// 根据平台选择首页
Widget _homePage() {
  if (kIsWeb) return const HomePage();
  final isDesktop = 
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
  return isDesktop ? const DesktopHomePage() : const HomePage();
}

/// 应用路由表
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  observers: [routeObserver],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AboutPage()),
    GoRoute(path: '/counter', builder: (context, state) => const CounterDemo()),
    GoRoute(path: '/animation', builder: (context, state) => const AnimationDemo()),
    GoRoute(path: '/framework', builder: (context, state) => const FrameworkClassesDemo()),
    GoRoute(path: '/lifecycle', builder: (context, state) => const LifecycleDemo()),
    GoRoute(path: '/layout', builder: (context, state) => const WidgetLayoutDemo()),
  ],
);
  // // 替换当前页面（不会返回）
  // context.go('/home');

  // // 推入新页面（可以返回）
  // context.push('/counter');

  // // 返回上一页
  // context.pop();
