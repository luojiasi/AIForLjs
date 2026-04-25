import 'dart:async';
import 'package:ai_chat_app/desktop/desktop_window_controller.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import 'package:ai_chat_app/core/services/logging/flutter_logging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ai_chat_app/desktop/widgets/desktop_home_page.dart';
import 'package:ai_chat_app/features/home/pages/home_page.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'providers/settings_provider.dart';

import 'presentation/page/practice/01_state_management/counter_demo.dart';
import 'presentation/page/practice/04_lifecycle/lifecycle.dart';
import 'presentation/page/practice/05_layout/widgetlayout.dart';


// 全局路由观察者，用于监听页面跳转/返回事件
final RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();
bool _didCheckUpdates = false;//确保更新检查只执行一次（首次构建）
// bool _didEnsureAssistants = false; //确保默认助手/会话/用户名只初始化一次（等本地化就绪后）

void main() async {
  await runZoned(
    ()async{
      WidgetsFlutterBinding.ensureInitialized();
      FlutterLogger.installGlobalHandlers();
      try{
        //拿到 SharedPreferences（Flutter 的本地键值对存储，类似浏览器的 localStorage）
        final prefs = await SharedPreferences.getInstance();
        final enabled = prefs.getBool('flutter_log_enabled_v1') ?? false;
        await FlutterLogger.setEnabled(enabled);
      }catch(_){}
      try{
        // 限制 Flutter 图片缓存的内存用量，防止 App 加载太多图片撑爆内存
        PaintingBinding.instance.imageCache.maximumSize=200;
        PaintingBinding.instance.imageCache.maximumSizeBytes=48<<20;//~48MB
      }catch(_){}
      await _initDesktopWindow();
      // iOS 沙盒路径解析，修正绝对路径问题
      // await SandboxPathResolver.init();
      // Android 启用边到边显示，内容延伸到系统栏下方
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      runApp(const AiChatApp());
    },zoneSpecification: ZoneSpecification(
      print: (self,parent,zone,line){
        FlutterLogger.logPrint(line);// 写日志文件
        parent.print(zone, line);// 继续输出到控制台
      }
    )
  );
  // runApp(const MaterialApp(
  //   home: Scaffold(body: Center(child: LifecycleDemo(),),),
  // ));
}

Future<void> _initDesktopWindow() async{
  if (kIsWeb) return;
  try {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      // ↑ Windows 隐藏原生标题栏，用自绘的标题栏替代（lib/desktop/window_title_bar.dart）
    }
    await DesktopWindowController.instance.initializeAndShow(title: 'SYCTB');
    // ↑ 恢复上次关闭时的窗口位置和大小，然后显示窗口
  }catch(_){}
}

class AiChatApp extends StatelessWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Builder(
        builder: (context) {
          final settings = context.watch<SettingsProvider>();
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MaterialApp(
                title: 'SYCTB',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.themeMode,
                locale: settings.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: _selectHome(),
              );
            },
          );
        },
      ),
    );
  }
}


Widget _selectHome(){
  if(kIsWeb) return const HomePage();
  final isDesktop =
    defaultTargetPlatform == TargetPlatform.windows||
    defaultTargetPlatform == TargetPlatform.macOS||
    defaultTargetPlatform == TargetPlatform.linux;
  return isDesktop? const DesktopHomePage():const HomePage();

}