import 'dart:async';
import 'package:ai_chat_app/desktop/desktop_window_controller.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'theme/theme_factory.dart';
import 'theme/palettes.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import 'package:ai_chat_app/core/services/logging/flutter_logging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';

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


              final isAndroid = Theme.of(context).platform == TargetPlatform.android;
              final dynSupport = isAndroid &&(lightDynamic!=null||darkDynamic!=null);
              final palette = ThemePalettes.byId(settings.themePaletteId);// 选中某套色板
              final useDyn = settings.useDynamicColor && isAndroid;
              // 传入色板的 light ColorScheme
              final light = buildLightThemeForScheme(
                palette.light,
                dynamicScheme: useDyn ? lightDynamic : null,
                pureBackground: settings.usePureBackground,
              );
              final dark = buildDarkThemeForScheme(
                palette.dark,
                dynamicScheme: useDyn ? darkDynamic : null,
                pureBackground: settings.usePureBackground,
              );
              return MaterialApp.router(
                title: 'SYCTB',
                debugShowCheckedModeBanner: false,
                theme: light,
                darkTheme: dark,
                themeMode: settings.themeMode,// 主题模式（浅色/深色/跟随系统）
                locale: settings.locale,// 用户选择的语言（null = 跟随系统）
                routerConfig: appRouter,// GoRouter 路由配置
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],// 本地化委托
                // builder: (ctx,child){...},// 全局 builder
              );
            },
          );
        },
      ),
    );
  }
}


