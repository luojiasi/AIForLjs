import 'dart:async';

import 'package:ai_chat_app/desktop/window_size_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class DesktopWindowController with WindowListener {
  DesktopWindowController._();
  static final DesktopWindowController instance = DesktopWindowController._();
  final WindowSizeManager _sizeMgr = const WindowSizeManager();
  bool _attached =false;
  Timer? _moveDebounce;
  Timer? _resizeDebounce;
  static const _debounceDuration = Duration(milliseconds: 400);
  Future<void> initializeAndShow({String? title}) async{
    if (kIsWeb) return;
    if (!(defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux)) {
      return;
    }
    await windowManager.ensureInitialized();
    _attachListeners();
    final initialSize = await _sizeMgr.getInitialSize();
    const minSize = Size(
      WindowSizeManager.minWindowWidth,
      WindowSizeManager.minWindowHeight,
    );
    const maxSize = Size(
      WindowSizeManager.maxWindowWidth,
      WindowSizeManager.maxWindowHeight,
    );
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final options = WindowOptions(
      size: isMac ? null : initialSize,
      minimumSize: isMac ? null : minSize,
      maximumSize: isMac ? null : maxSize,
      title: title,
    );
    final savedPos = await _sizeMgr.getPosition();
    final wasMax = await _sizeMgr.getWindowMaximized();
    if (defaultTargetPlatform == TargetPlatform.windows){
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      doWhenWindowReady(() async {
        appWindow.minSize = options.minimumSize;
        appWindow.maxSize = options.maximumSize;
        appWindow.size = initialSize;
        if (savedPos != null) {
          appWindow.position = savedPos;
        }
        if (wasMax) {
          appWindow.maximize();
        }
      });
    } else {
      await windowManager.waitUntilReadyToShow(options, () async {
        // Show first, then restore position to avoid macOS jump/flicker.
        await windowManager.show();
        await windowManager.focus();
        // On macOS rely on native autosave. Do not set position from Dart.
        final shouldRestorePos = savedPos != null && !isMac;
        if (shouldRestorePos) {
          try {
            await windowManager.setPosition(savedPos);
          } catch (_) {}
        }
      });      
    }
  }
  void _attachListeners() {
    if (_attached) return;
    windowManager.addListener(this);
    _attached = true;
  }
  @override
  void onWindowResize() async {
    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(_debounceDuration, () async {
      try {
        final isMax = await windowManager.isMaximized();
        if (!isMax) {
          final s = await windowManager.getSize();
          await _sizeMgr.setSize(s);
        }
      } catch (_) {}
    });
  }
  
  @override
  void onWindowMove() async {
    _moveDebounce?.cancel();
    _moveDebounce = Timer(_debounceDuration, () async {
      try {
        final offset = await windowManager.getPosition();
        await _sizeMgr.setPosition(offset);
      } catch (_) {}
    });
  }

  @override
  void onWindowMaximize() async {
    try {
      await _sizeMgr.setWindowMaximized(true);
      await _sizeMgr.setPosition(const Offset(0, 0));
    } catch (_) {}
  }

  @override
  void onWindowUnmaximize() async {
    try {
      await _sizeMgr.setWindowMaximized(false);
      final offset = await windowManager.getPosition();
      await _sizeMgr.setPosition(offset);
    } catch (_) {}
  }

  @override
  void onWindowEnterFullScreen() async {
    try {
      await _sizeMgr.setWindowMaximized(true);
      await _sizeMgr.setPosition(const Offset(0, 0));
    } catch (_) {}
  }

  @override
  void onWindowLeaveFullScreen() async {
    try {
      await _sizeMgr.setWindowMaximized(false);
      final offset = await windowManager.getPosition();
      await _sizeMgr.setPosition(offset);
    } catch (_) {}
  }

}