import 'dart:async';
import 'dart:io';
import 'package:ai_chat_app/core/providers/hotkey_provider.dart';
import 'package:ai_chat_app/core/providers/update_provider.dart';
import 'package:ai_chat_app/core/providers/user_provider.dart';
import 'package:ai_chat_app/core/services/android_background.dart';
import 'package:ai_chat_app/core/services/notification_service.dart';
import 'package:ai_chat_app/core/services/system_fonts.dart';
import 'package:ai_chat_app/desktop/desktop_tray_controller.dart';
import 'package:ai_chat_app/desktop/desktop_window_controller.dart';
import 'package:ai_chat_app/features/settings/pages/snackbar.dart';
import 'package:ai_chat_app/utils/sandbox_path_resolver.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
bool _didCheckUpdates = false;
bool _didEnsureAssistants = false; 
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
      await SandboxPathResolver.init();
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Builder(
        builder: (context) {
          final settings = context.watch<SettingsProvider>();
          
          
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final isDesktop =
                  !kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.windows ||
                      defaultTargetPlatform == TargetPlatform.macOS ||
                      defaultTargetPlatform == TargetPlatform.linux);
              if (!isDesktop) return;
              // Selected system app/code fonts (not Google, not local alias)
              final wantsAppSystem =
                  (settings.appFontFamily?.isNotEmpty == true) &&
                  !settings.appFontIsGoogle &&
                  (settings.appFontLocalAlias == null ||
                      settings.appFontLocalAlias!.isEmpty);
              final wantsCodeSystem =
                  (settings.codeFontFamily?.isNotEmpty == true) &&
                  !settings.codeFontIsGoogle &&
                  (settings.codeFontLocalAlias == null ||
                      settings.codeFontLocalAlias!.isEmpty);
              if (wantsAppSystem || wantsCodeSystem) {
                final sf = SystemFonts();
                if (wantsAppSystem) {
                  final fam = settings.appFontFamily!;
                  try {
                    await sf.loadFont(fam);
                  } catch (_) {}
                }
                if (wantsCodeSystem) {
                  final fam = settings.codeFontFamily!;
                  try {
                    if (fam != settings.appFontFamily) await sf.loadFont(fam);
                  } catch (_) {}
                }
              }
            } catch (_) {}
          });
          //添加自动跟新的方法
          if (settings.showAppUpdates && !_didCheckUpdates) {
            _didCheckUpdates = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                context.read<UpdateProvider>().checkForUpdates();
              } catch (_) {}
            });
          }

          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final isAndroid = Theme.of(context).platform == TargetPlatform.android;
              final dynSupported = isAndroid &&(lightDynamic!=null||darkDynamic!=null);
              ///将 DynamicColorBuilder 检测到的"系统是否支持动态取色"结果（dynSupported）写回 SettingsProvider。这样其他页面（如主题设置页）就能知道当前设备是否支持 Android Material You 动态色彩，不支持时该选项置灰 
              WidgetsBinding.instance.addPostFrameCallback((_){
                try{
                  settings.setDynamicColorSupported(dynSupported);
                }catch(_){}
              });
              ///桌面端热键初始化
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  final isDesktop =
                      !kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.macOS ||
                          defaultTargetPlatform == TargetPlatform.linux);
                  if (isDesktop) {
                    await context.read<HotkeyProvider>().initialize();
                  }
                } catch (_) {}
              });
              WidgetsBinding.instance.addPostFrameCallback((_)async{
                try {
                  if(Platform.isAndroid){
                    final mode = settings.androidBackgroundChatMode;
                    if (mode != AndroidBackgroundChatMode.off) {
                      final l10n = AppLocalizations.of(context);
                      if (l10n == null) return;
                    try {
                      // 检查后台服务是否已启用。如果已经启用了，跳过初始化。原因是 Android ROM（特别是国产系统）每次调用 ensureInitialized 都可能弹出系统授权弹窗，重复弹会严重影响体验
                      final already = await AndroidBackgroundManager.isEnabled();
                      if (!already) {
                        // 初始化后台服务-----系统通知栏-----用户可见，不可划掉
                        ///配置通知渠道、标题、内容
                        await AndroidBackgroundManager.ensureInitialized(
                          notificationTitle:l10n.androidBackgroundNotificationTitle,
                          notificationText:l10n.androidBackgroundNotificationText,
                        );
                        // 启动前台服务，把通知挂到系统栏
                        await AndroidBackgroundManager.setEnabled(true);
                      }
                    } catch (_) {}
                      if (mode == AndroidBackgroundChatMode.onNotify) {
                        //  创建通知渠道、监听模型回复完成事件、准备通知模板
                        await NotificationService.ensureInitialized();
                        // Android 13+ 需要用户授予 POST_NOTIFICATIONS 权限，否则通知发不出去
                        await NotificationService.ensureAndroidNotificationsPermission();
                      }
                    }
                  }
                } catch (_) {}
              });



              final palette = ThemePalettes.byId(settings.themePaletteId);// 选中某套色板
              final useDyn = settings.useDynamicColor && isAndroid;
              // 传入色板的 light ColorScheme
              final light = buildLightThemeForScheme(
                palette.light,
                dynamicScheme: useDyn ? lightDynamic : null,// 可选：用系统动态取色覆盖
                pureBackground: settings.usePureBackground,// 可选：强制纯色背景
              );
              final dark = buildDarkThemeForScheme(
                palette.dark,
                dynamicScheme: useDyn ? darkDynamic : null,
                pureBackground: settings.usePureBackground,
              );
              String? effectiveAppFontFamily() {
                final fam = settings.appFontFamily;
                if (fam == null || fam.isEmpty) return null;
                if (settings.appFontIsGoogle) {
                  try {
                    final s = GoogleFonts.getFont(fam);
                    return s.fontFamily ?? fam;
                  } catch (_) {
                    return fam;
                  }
                }
                return fam;
              }
              final effectiveAppFont = effectiveAppFontFamily();
              ThemeData applyAppFont(ThemeData base) {
                if (effectiveAppFont == null || effectiveAppFont.isEmpty) {
                  return base;
                }
                TextStyle? withFamily(TextStyle? s) =>s?.copyWith(fontFamily: effectiveAppFont);
                TextTheme apply(TextTheme t) => t.copyWith(
                  displayLarge: withFamily(t.displayLarge),
                  displayMedium: withFamily(t.displayMedium),
                  displaySmall: withFamily(t.displaySmall),
                  headlineLarge: withFamily(t.headlineLarge),
                  headlineMedium: withFamily(t.headlineMedium),
                  headlineSmall: withFamily(t.headlineSmall),
                  titleLarge: withFamily(t.titleLarge),
                  titleMedium: withFamily(t.titleMedium),
                  titleSmall: withFamily(t.titleSmall),
                  bodyLarge: withFamily(t.bodyLarge),
                  bodyMedium: withFamily(t.bodyMedium),
                  bodySmall: withFamily(t.bodySmall),
                  labelLarge: withFamily(t.labelLarge),
                  labelMedium: withFamily(t.labelMedium),
                  labelSmall: withFamily(t.labelSmall),
                );
                final bar = base.appBarTheme;
                final appBar = bar.copyWith(
                  titleTextStyle: (bar.titleTextStyle ?? const TextStyle())
                      .copyWith(fontFamily: effectiveAppFont),
                  toolbarTextStyle: (bar.toolbarTextStyle ?? const TextStyle())
                      .copyWith(fontFamily: effectiveAppFont),
                );
                return base.copyWith(
                  textTheme: apply(base.textTheme),
                  primaryTextTheme: apply(base.primaryTextTheme),
                  appBarTheme: appBar,
                );
              }
              final themedLight = applyAppFont(light);
              final themedDark = applyAppFont(dark);


              return MaterialApp.router(
                title: 'SYCTB',
                debugShowCheckedModeBanner: false,
                theme: themedLight,
                darkTheme: themedDark,
                themeMode: settings.themeMode,// 主题模式（浅色/深色/跟随系统）
                locale: settings.appLocaleForMaterialApp,// 用户选择的语言（null = 跟随系统）
                routerConfig: appRouter,// GoRouter 路由配置
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (ctx, child){
                  final bright = Theme.of(ctx).brightness;
                  ///根据当前主题的亮度（dark/light），动态设置系统状态栏和导航栏的图标颜色，确保浅背景配深色图标、深背景配浅色图标，背景始终透明让内容延伸到系统栏下方
                  final overlay = bright == Brightness.dark
                      ? const SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,// 状态栏背景透明
                          statusBarIconBrightness: Brightness.light,  // 状态栏图标亮色（白色）
                          statusBarBrightness: Brightness.dark,// iOS 状态栏文字亮色
                          systemNavigationBarColor: Colors.transparent,// 底部导航栏透明
                          systemNavigationBarIconBrightness: Brightness.light,
                          systemNavigationBarDividerColor: Colors.transparent,
                          systemNavigationBarContrastEnforced: false,
                        )
                      : const SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: Brightness.dark, // 浅色主题用深色图标
                          statusBarBrightness: Brightness.light,
                          systemNavigationBarColor: Colors.transparent,
                          systemNavigationBarIconBrightness: Brightness.dark,
                          systemNavigationBarDividerColor: Colors.transparent,
                          systemNavigationBarContrastEnforced: false,
                        );
                  
                  // 应用启动后的第一帧，执行一次性的初始化——创建默认助手、设置默认对话标题、设置默认用户名。_didEnsureAssistants 确保只执行一次。addPostFrameCallback 确保在首帧渲染完成后才执行（此时 Context 可用，且不会阻塞首帧）
                  // if (!_didEnsureAssistants) {
                  //   _didEnsureAssistants = true;
                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                  //     try {
                  //       ctx.read<AssistantProvider>().ensureDefaults(ctx);
                  //     } catch (_) {}
                  //     try {
                  //       ctx.read<ChatService>().setDefaultConversationTitle(
                  //         AppLocalizations.of(
                  //           ctx,
                  //         )!.chatServiceDefaultConversationTitle,
                  //       );
                  //     } catch (_) {}
                  //     try {
                  //       ctx.read<UserProvider>().setDefaultNameIfUnset(
                  //         AppLocalizations.of(ctx)!.userProviderDefaultUserName,
                  //       );
                  //     } catch (_) {}
                  //   });
                  // }
                  //桌面端首帧后，根据用户设置同步系统托盘行为——是否显示托盘图标、点击关闭是退出还是最小化到托盘。只在桌面平台执行
                  final l10n = AppLocalizations.of(ctx);
                  if (l10n != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      try {
                        final isDesktop =
                            !kIsWeb &&
                            (defaultTargetPlatform == TargetPlatform.windows ||
                                defaultTargetPlatform == TargetPlatform.macOS ||
                                defaultTargetPlatform == TargetPlatform.linux);
                        if (!isDesktop) return;
                        final sp = ctx.read<SettingsProvider>();
                        await DesktopTrayController.instance.syncFromSettings(
                          l10n,
                          showTray: sp.desktopShowTray,
                          minimizeToTrayOnClose:sp.desktopMinimizeToTrayOnClose,
                        );
                      } catch (_) {}
                    });
                  }
                  // return AppSnackBarOverlay(child: child!);
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: overlay,// 把上面设置好的系统栏样式应用到整个子树
                    child: effectiveAppFont==null
                          ? AppSnackBarOverlay( // 无自定义字体：只包裹 Toast 层
                            child: child ?? const SizedBox.shrink(),
                          )
                          : DefaultTextStyle.merge(// 有自定义字体：先合并字体样式
                            style: TextStyle(fontFamily: effectiveAppFont),
                            child: AppSnackBarOverlay( // 再包裹 Toast 层
                              child: child??const SizedBox.shrink(),
                              ),
                            ),

                  );
                },
                // builder: (ctx,child){...},// 全局 builder
              );
            },
          );
        },
      ),
    );
  }
}


