import 'package:ai_chat_app/features/settings/pages/about_page.dart';





import 'package:ai_chat_app/presentation/studyhome.dart';
import 'package:ai_chat_app/presentation/commonproblems/commonproblems_home.dart';
import 'package:ai_chat_app/presentation/commonproblems/brand_device_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_language_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_tutorial_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_favorites_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_category_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_detail_page.dart';

import 'package:ai_chat_app/desktop/widgets/desktop_home_page.dart';
import 'package:ai_chat_app/features/home/pages/home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    // GoRoute(path: '/', builder: (context, state) => _homePage()),
    GoRoute(path: '/',builder: (context, state) => const AboutPage()),
    GoRoute(path: '/study', builder: (context, state) => const StudyHome()),

    

    // 项目实战教程库 (Project-Based Learning)
    GoRoute(path: '/pbl', builder: (context, state) => const PBLHome()),
    // 精确路由必须放在 :languageName 之前，否则会被通配符匹配吃掉
    GoRoute(path: '/pbl/tutorial', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return PBLTutorialPage(
        title: extra['title'] as String? ?? '',
        url: extra['url'] as String? ?? '',
        languageName: extra['languageName'] as String? ?? '',
      );
    }),
    GoRoute(path: '/pbl/favorites', builder: (context, state) => const PBLFavoritesPage()),
    GoRoute(path: '/pbl/:languageName', builder: (context, state) =>
      PBLLanguagePage(languageName: state.pathParameters['languageName'] ?? ''),
    ),

    // Awesome Python — Python 最佳框架/库/工具权威指南
    GoRoute(path: '/awesome_python', builder: (context, state) => const AwesomePythonHome()),
    GoRoute(path: '/awesome_python/detail', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return AwesomePythonDetailPage(
        name: extra['name'] as String? ?? '',
        url: extra['url'] as String? ?? '',
        description: extra['description'] as String? ?? '',
        features: (extra['features'] as List<dynamic>?)?.cast<String>() ?? [],
        useCase: extra['useCase'] as String? ?? '',
        categoryName: extra['categoryName'] as String? ?? '',
      );
    }),
    GoRoute(path: '/awesome_python/:categoryName', builder: (context, state) =>
      AwesomePythonCategoryPage(categoryName: state.pathParameters['categoryName'] ?? ''),
    ),

    // 常见问题（设备参数与故障）
    GoRoute(path: '/commonproblems', builder: (context, state) => const CommonProblemsHome()),
    GoRoute(path: '/commonproblems/:brand/:device', builder: (context, state) =>
      BrandDevicePage(
        brand: state.pathParameters['brand'] ?? '',
        device: state.pathParameters['device'] ?? '',
      )),
  ],
);
