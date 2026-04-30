import 'package:ai_chat_app/features/settings/pages/about_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/01_state_management/counter_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/02_animation/animation_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/03_framework_classes/framework_classes.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/04_lifecycle/lifecycle.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/05_layout/widgetlayout.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/06_networking/networking_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/07_storage/storage_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/08_navigation/navigation_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/09_advanced_widgets/advanced_widgets_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/10_widget_basics/widget_basics.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/11_provider/provider_demo.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/practice/12_theme/theme_demo.dart';

import 'package:ai_chat_app/presentation/differentlanguage/python/practice/01_python_basics/python_basics.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/02_control_flow/control_flow.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/03_functions/functions.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/04_data_structures/data_structures.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/05_oop/oop.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/06_modules/modules.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/07_file_io/file_io.dart' as py_io;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/08_error_handling/error_handling.dart' as py_err;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/09_datetime_regex/datetime_regex.dart' as py_dt;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/10_advanced/advanced_features.dart' as py_adv;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/11_stdlib/stdlib_modules.dart' as py_stdlib;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/12_project/project_practice.dart' as py_project;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/13_cgi/cgi_tutorial.dart' as py_cgi;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/14_mysql/mysql_tutorial.dart' as py_mysql;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/15_networking/networking_tutorial.dart' as py_net;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/16_smtp/smtp_tutorial.dart' as py_smtp;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/17_multithreading/multithreading_tutorial.dart' as py_thread;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/18_xml/xml_tutorial.dart' as py_xml;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/19_gui/gui_tutorial.dart' as py_gui;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/20_async_io/async_io_tutorial.dart' as py_async;
import 'package:ai_chat_app/presentation/differentlanguage/python/practice/21_third_party/third_party_tutorial.dart' as py_third;

import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/01_dart_basics/dart_basics.dart';
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/02_control_flow/control_flow.dart' as dart_cf;
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/03_functions/functions.dart' as dart_fn;
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/04_collections/collections.dart';
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/05_oop/oop.dart' as dart_oop;
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/06_async/async.dart';
import 'package:ai_chat_app/presentation/differentlanguage/dart/practice/07_dart3/dart3_features.dart' as dart3;

import 'package:ai_chat_app/presentation/differentlanguage/python/practice/22_web_dev/web_dev_tutorial.dart' as py_web;

import 'package:ai_chat_app/presentation/studyhome.dart';
import 'package:ai_chat_app/presentation/commonproblems/commonproblems_home.dart';
import 'package:ai_chat_app/presentation/commonproblems/brand_device_page.dart';
import 'package:ai_chat_app/presentation/differentlanguage/flutter/flutter_hub.dart';
import 'package:ai_chat_app/presentation/differentlanguage/python/python_hub.dart';
import 'package:ai_chat_app/presentation/differentlanguage/dart/dart_hub.dart';

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
    // GoRoute(path: '/', builder: (context, state) => _homePage()),
    GoRoute(path: '/',builder: (context, state) => const AboutPage()),
    GoRoute(path: '/study', builder: (context, state) => const StudyHome()),

    // Flutter 教程
    GoRoute(path: '/flutter', builder: (context, state) => const FlutterHub()),
    GoRoute(path: '/flutter/01', builder: (context, state) => const CounterDemo()),
    GoRoute(path: '/flutter/02', builder: (context, state) => const AnimationDemo()),
    GoRoute(path: '/flutter/03', builder: (context, state) => const FrameworkClassesDemo()),
    GoRoute(path: '/flutter/04', builder: (context, state) => const LifecycleDemo()),
    GoRoute(path: '/flutter/05', builder: (context, state) => const WidgetLayoutDemo()),
    GoRoute(path: '/flutter/06', builder: (context, state) => const NetworkingDemo()),
    GoRoute(path: '/flutter/07', builder: (context, state) => const StorageDemo()),
    GoRoute(path: '/flutter/08', builder: (context, state) => const NavigationDemo()),
    GoRoute(path: '/flutter/09', builder: (context, state) => const AdvancedWidgetsDemo()),
    GoRoute(path: '/flutter/10', builder: (context, state) => const FlutterWidgetBasics()),
    GoRoute(path: '/flutter/11', builder: (context, state) => const ProviderDemo()),
    GoRoute(path: '/flutter/12', builder: (context, state) => const ThemeDemo()),
    GoRoute(path: '/flutter/08/profile/:id', builder: (context, state) =>ProfilePage(userId: state.pathParameters['id'] ?? '')),
    GoRoute(path: '/flutter/08/search', builder: (context, state) =>SearchPage(query: state.uri.queryParameters['q'] ?? '', page: state.uri.queryParameters['page'] ?? '1')),

    // Python 教程
    GoRoute(path: '/python', builder: (context, state) => const PythonHub()),
    GoRoute(path: '/python/01', builder: (context, state) => const PythonBasics()),
    GoRoute(path: '/python/02', builder: (context, state) => const PythonControlFlow()),
    GoRoute(path: '/python/03', builder: (context, state) => const PythonFunctions()),
    GoRoute(path: '/python/04', builder: (context, state) => const PythonDataStructures()),
    GoRoute(path: '/python/05', builder: (context, state) => const PythonOOP()),
    GoRoute(path: '/python/06', builder: (context, state) => const PythonModules()),
    GoRoute(path: '/python/07', builder: (context, state) => const py_io.PythonFileIO()),
    GoRoute(path: '/python/08', builder: (context, state) => const py_err.PythonErrorHandling()),
    GoRoute(path: '/python/09', builder: (context, state) => const py_dt.PythonDateTimeRegex()),
    GoRoute(path: '/python/10', builder: (context, state) => const py_adv.PythonAdvancedFeatures()),
    GoRoute(path: '/python/11', builder: (context, state) => const py_stdlib.PythonStdlibModules()),
    GoRoute(path: '/python/12', builder: (context, state) => const py_project.PythonProjectPractice()),

    // Python 专题扩展篇
    GoRoute(path: '/python/13', builder: (context, state) => const py_cgi.PythonCGITutorial()),
    GoRoute(path: '/python/14', builder: (context, state) => const py_mysql.PythonMySQLTutorial()),
    GoRoute(path: '/python/15', builder: (context, state) => const py_net.PythonNetworkingTutorial()),
    GoRoute(path: '/python/16', builder: (context, state) => const py_smtp.PythonSMTpTutorial()),
    GoRoute(path: '/python/17', builder: (context, state) => const py_thread.PythonMultithreadingTutorial()),
    GoRoute(path: '/python/18', builder: (context, state) => const py_xml.PythonXMLTutorial()),
    GoRoute(path: '/python/19', builder: (context, state) => const py_gui.PythonGUITutorial()),
    GoRoute(path: '/python/20', builder: (context, state) => const py_async.PythonAsyncIOTutorial()),
    GoRoute(path: '/python/21', builder: (context, state) => const py_third.PythonThirdPartyTutorial()),
    GoRoute(path: '/python/22', builder: (context, state) => const py_web.PythonWebDevTutorial()),

    // Dart 教程
    GoRoute(path: '/dart', builder: (context, state) => const DartHub()),
    GoRoute(path: '/dart/01', builder: (context, state) => const DartBasics()),
    GoRoute(path: '/dart/02', builder: (context, state) => const dart_cf.DartControlFlow()),
    GoRoute(path: '/dart/03', builder: (context, state) => const dart_fn.DartFunctions()),
    GoRoute(path: '/dart/04', builder: (context, state) => const DartCollections()),
    GoRoute(path: '/dart/05', builder: (context, state) => const dart_oop.DartOOP()),
    GoRoute(path: '/dart/06', builder: (context, state) => const DartAsync()),
    GoRoute(path: '/dart/07', builder: (context, state) => const dart3.Dart3Features()),

    // 常见问题（设备参数与故障）
    GoRoute(path: '/commonproblems', builder: (context, state) => const CommonProblemsHome()),
    GoRoute(path: '/commonproblems/:brand/:device', builder: (context, state) =>
      BrandDevicePage(
        brand: state.pathParameters['brand'] ?? '',
        device: state.pathParameters['device'] ?? '',
      )),
  ],
);
