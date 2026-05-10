import 'package:ai_chat_app/features/settings/pages/about_page.dart';





import 'package:ai_chat_app/presentation/studyhome.dart';
import 'package:ai_chat_app/presentation/commonproblems/commonproblems_home.dart';
import 'package:ai_chat_app/presentation/simplen8n/simplen8n_init.dart';
import 'package:ai_chat_app/presentation/simplen8n/ui/simplen8n_home_page.dart';
import 'package:ai_chat_app/presentation/commonproblems/brand_device_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_language_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_tutorial_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/pbl/pbl_favorites_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_category_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/awesome_python/awesome_python_detail_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/public_apis/public_apis_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/public_apis/public_apis_category_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/public_apis/public_apis_detail_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/agent_architectures/agent_architectures_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/agent_architectures/agent_architectures_detail_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/agent_architectures/agent_architectures_data.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python_crawler/python_crawler_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python_crawler/python_crawler_detail_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/api_token_platform/api_token_platform_home.dart';
import 'package:ai_chat_app/presentation/differentlanguage/api_token_platform/api_token_platform_detail_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/api_token_platform/api_token_platform_data.dart';

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
    GoRoute(path: '/', builder: (context, state) => _homePage()),
    // GoRoute(path: '/',builder: (context, state) => const AboutPage()),
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
        tutorialCode: extra['tutorialCode'] as String?,
      );
    }),
    GoRoute(path: '/awesome_python/:categoryIndex', builder: (context, state) {
      final idx = int.tryParse(state.pathParameters['categoryIndex'] ?? '') ?? 0;
      return AwesomePythonCategoryPage(categoryIndex: idx);
    }),

    // Public APIs — 公共 API 权威合集
    GoRoute(path: '/public_apis', builder: (context, state) => const PublicApisHome()),
    GoRoute(path: '/public_apis/detail', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return PublicApisDetailPage(
        name: extra['name'] as String? ?? '',
        url: extra['url'] as String? ?? '',
        description: extra['description'] as String? ?? '',
        auth: extra['auth'] as String? ?? 'No',
        https: extra['https'] as bool? ?? true,
        cors: extra['cors'] as String? ?? 'Unknown',
        categoryName: extra['categoryName'] as String? ?? '',
      );
    }),
    GoRoute(path: '/public_apis/:categoryIndex', builder: (context, state) {
      final idx = int.tryParse(state.pathParameters['categoryIndex'] ?? '') ?? 0;
      return PublicApisCategoryPage(categoryIndex: idx);
    }),

    // AI Agent 架构大全 — 12种主流架构详解
    GoRoute(path: '/agent_architectures', builder: (context, state) => const AgentArchitecturesHome()),
    GoRoute(path: '/agent_architectures/detail', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final arch = extra['arch'] as AgentArchitecture?;
      if (arch == null) return const AgentArchitecturesHome();
      return AgentArchitecturesDetailPage(arch: arch);
    }),

    // Python 爬虫教程 — 4大热门项目从零到精通
    GoRoute(path: '/python_crawler', builder: (context, state) => const PythonCrawlerHome()),
    GoRoute(path: '/python_crawler/:projectIndex', builder: (context, state) {
      final idx = int.tryParse(state.pathParameters['projectIndex'] ?? '') ?? 0;
      return PythonCrawlerDetailPage(projectIndex: idx);
    }),

    // API Token 中转平台 — 统一多厂商AI API网关
    GoRoute(path: '/api_token_platform', builder: (context, state) => const ApiTokenPlatformHome()),
    GoRoute(path: '/api_token_platform/detail', builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final topic = extra['topic'] as ApiTokenPlatformTopic?;
      if (topic == null) return const ApiTokenPlatformHome();
      return ApiTokenPlatformDetailPage(topic: topic);
    }),

    // simplen8n — 可视化工作流自动化引擎
    GoRoute(
      path: '/simplen8n',
      builder: (context, state) {
        initSimplen8n();
        return const Simplen8nHomePage();
      },
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
