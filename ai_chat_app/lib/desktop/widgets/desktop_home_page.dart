import 'dart:async';

import 'package:ai_chat_app/desktop/desktop_chat_page.dart';
import 'package:ai_chat_app/desktop/desktop_nav_rail.dart';
import 'package:ai_chat_app/desktop/desktop_settings_page.dart';
import 'package:ai_chat_app/desktop/hotkeys/chat_action_bus.dart';
import 'package:ai_chat_app/desktop/hotkeys/hotkey_event_bus.dart';
import 'package:ai_chat_app/desktop/window_title_bar.dart';
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({
    super.key,
    this.initialTabIndex,
    this.initialProviderKey
    });

  final int? initialTabIndex; 
  final String? initialProviderKey;
  @override
  State<DesktopHomePage> createState()=>_DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage>{
  // // 0=Chat, 1=Translate, 2=Storage, 3=Settings
  int _tabIndex = 0; 
  bool _storageVisited = false;
  bool _globalSearchActive = false;
  StreamSubscription<HotkeyAction>? _hotkeySub;
  StreamSubscription<ChatAction>? _chatActionSub;

  @override
  void initState(){
    super.initState();
    if (widget.initialTabIndex != null) {
      _tabIndex = widget.initialTabIndex!.clamp(0, 3);
    }
    _storageVisited = _tabIndex == 2;
    // 初始进入时如果就是聊天页，则聚焦聊天输入框
    if (_tabIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatActionBus.instance.fire(ChatAction.focusInput);
      });
    }
    _hotkeySub = HotkeyEventBus.instance.stream.listen((action) async {
      switch (action) {
        case HotkeyAction.openSettings:
          if (mounted) {
            setState(() {
              _tabIndex = 3;
              _globalSearchActive = false;
            });
            ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
          }
          break;
        case HotkeyAction.closeWindow:
          try {
            await windowManager.close();
          } catch (_) {}
          break;
        case HotkeyAction.toggleAppVisibility:
          try {
            final visible = await windowManager.isVisible();
            final minimized = await windowManager.isMinimized();
            final focused = await windowManager.isFocused();

            // 优先级：
            // 1. 如果窗口不可见或最小化，则显示并聚焦
            // 2. 如果窗口可见但未聚焦，则聚焦
            // 3. 如果窗口可见且已聚焦，则隐藏
            if (!visible || minimized) {
              await windowManager.show();
              await windowManager.focus();
              // 如果当前是聊天页，显示窗口时聚焦输入框
              if (_tabIndex == 0) {
                ChatActionBus.instance.fire(ChatAction.focusInput);
              }
            } else if (!focused) {
              await windowManager.focus();
              // 如果当前是聊天页，聚焦窗口时也聚焦输入框
              if (_tabIndex == 0) {
                ChatActionBus.instance.fire(ChatAction.focusInput);
              }
            } else {
              await windowManager.hide();
            }
          } catch (_) {}
          break;
        case HotkeyAction.newTopic:
          if (_tabIndex == 0) {
            ChatActionBus.instance.fire(ChatAction.newTopic);
          }
          break;
        case HotkeyAction.switchModel:
          if (_tabIndex == 0) {
            ChatActionBus.instance.fire(ChatAction.switchModel);
          }
          break;
        case HotkeyAction.toggleLeftPanelAssistants:
          if (_tabIndex == 0) {
            ChatActionBus.instance.fire(ChatAction.toggleLeftPanelAssistants);
          }
          break;
        case HotkeyAction.toggleLeftPanelTopics:
          if (_tabIndex == 0) {
            ChatActionBus.instance.fire(ChatAction.toggleLeftPanelTopics);
          }
          break;
      }
    });
    _chatActionSub = ChatActionBus.instance.stream.listen((action) {
      if (!mounted) return;
      switch (action) {
        case ChatAction.enterGlobalSearch:
          setState(() {
            _tabIndex = 0;
            _globalSearchActive = true;
          });
          break;
        case ChatAction.exitGlobalSearch:
          setState(() {
            _globalSearchActive = false;
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    const minWidth = 960.0;
    const minHeight = 640.0;
    final isWindows = defaultTargetPlatform == TargetPlatform.windows;

    return LayoutBuilder(
      builder: (context,constraints){
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final needsWidthPad = w < minWidth;
        final needsHeightPad = h < minHeight;
        Widget body =Row(
          children: [
            // 左侧导航栏
            DesktopNavRail(
              activeIndex: _tabIndex,
              globalSearchActive: _globalSearchActive,
              onTapChat: () {
                setState(() {
                  _tabIndex = 0;
                  _globalSearchActive = false;
                });
                // 发送事件（在任何地方）
                ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
                // 切换到聊天页时聚焦输入框
                ChatActionBus.instance.fire(ChatAction.focusInput);
              },
              onTapGlobalSearch: () {
                setState(() {
                  _tabIndex = 0;
                  _globalSearchActive = true;
                });
                ChatActionBus.instance.fire(ChatAction.enterGlobalSearch);
              },
              onTapTranslate: () {
                setState(() {
                  _tabIndex = 1;
                  _globalSearchActive = false;
                });
                ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
              },
              onTapStorage: () => setState(() {
                _tabIndex = 2;
                _globalSearchActive = false;
                _storageVisited = true;
                ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
              }),
              onTapSettings: () {
                setState(() {
                  _tabIndex = 3;
                  _globalSearchActive = false;
                });
                ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
              },
            ),
            // 右侧内容区，保持所有页面存活
            Expanded(
              // IndexedStack 而非 switch/if：切换 Tab 时所有子页面保持挂载状态，聊天流不会因切到设置页而被取消
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  const DesktopChatPage(),                             // index 0
                  const SizedBox.shrink(),                             // index 1: translate (TODO)
                  const SizedBox.shrink(),                             // index 2: storage (TODO)
                  DesktopSettingsPage(                                 // index 3
                    key: const ValueKey('settings_page'),
                    initialProviderKey: widget.initialProviderKey,
                  ),
                ],
              ),
            ),
          ],
        );

        final content = 
          isWindows
            ? Column(
                children: [
                  WindowTitleBar(
                    leftChildren: [
                      SizedBox(width: DesktopNavRail.width / 2 - 8 - 6 - 12),
                      const _TitleBarLeading(),
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        body,
                        // Inject the lazily-built settings page into the IndexedStack when needed
                        // to pass initialProviderKey without dropping chat state.
                        if (_tabIndex == 3) const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              )
            : body;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: minWidth,
              minHeight: minHeight,
            ),
            child: SizedBox(
              width: needsWidthPad ? minWidth : w,
              height: needsHeightPad ? minHeight : h,
              child: content,
            ),
          ),
        );
      }
    );
  }


  @override
  void dispose() {
    try {
      _hotkeySub?.cancel();
    } catch (_) {}
    try {
      _chatActionSub?.cancel();
    } catch (_) {}
    super.dispose();
  }
}
class _TitleBarLeading extends StatelessWidget{
  const _TitleBarLeading();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //图标
        Image.asset(
          'assets/app_icon.png',
          width: 32,
          height: 32,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 8,),
        Text(
          l10n.aboutPageAppName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.8),
            decoration: TextDecoration.none,
          ),
        )
      ],
    );
  }
}
