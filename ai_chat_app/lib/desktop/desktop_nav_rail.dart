import 'dart:io' show File, Platform;
import 'package:ai_chat_app/core/providers/settings_provider.dart';
import 'package:ai_chat_app/core/providers/user_provider.dart';
import 'package:ai_chat_app/desktop/user_profile_dialog.dart';
import 'package:ai_chat_app/icons/lucide_adapter.dart' as lucide;
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:ai_chat_app/shared/widgets/emoji_text.dart';
import 'package:ai_chat_app/utils/sandbox_path_resolver.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A compact left rail for desktop with avatar, primary actions, and bottom system toggles.
class DesktopNavRail extends StatelessWidget {
  const DesktopNavRail({
    super.key,
    required this.activeIndex,
    this.globalSearchActive = false,
    // required this.onTapChat,
    // required this.onTapGlobalSearch,
    // required this.onTapTranslate,
    // required this.onTapStorage,
    required this.onTapSettings,
  });

  final int activeIndex; // 0=Chat, 1=Translate, 2=Storage, 3=Settings
  final bool globalSearchActive;
  // final VoidCallback onTapChat;
  // final VoidCallback onTapGlobalSearch;
  // final VoidCallback onTapTranslate;
  // final VoidCallback onTapStorage;
  final VoidCallback onTapSettings;

  static const double width = 64.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isMac = Platform.isMacOS;
    final double topGap = isMac ? 36.0 : 8.0;
    final isChatActive = activeIndex == 0 && !globalSearchActive;
    final isGlobalSearchActive = globalSearchActive;
    final isTranslateActive = activeIndex == 1;
    final isStorageActive = activeIndex == 2;
    final isSettingsActive = activeIndex == 3;

    return Container(
      width: width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SizedBox(height: topGap),
          _UserAvatarButton(),
          const SizedBox(height: 12),
          // _CircleAction(
          //   tooltip: l10n.desktopNavChatTooltip,
          //   icon: lucide.Lucide.MessageCircle,
          //   onTap: onTapChat,
          //   size: 40,
          //   iconSize: 18,
          //   iconColor: isChatActive ? cs.primary : null,
          // ),
          // const SizedBox(height: 8),
          // _CircleAction(
          //   tooltip: l10n.desktopNavGlobalSearchTooltip,
          //   icon: lucide.Lucide.Search,
          //   onTap: onTapGlobalSearch,
          //   size: 40,
          //   iconSize: 18,
          //   iconColor: isGlobalSearchActive ? cs.primary : null,
          // ),
          // const SizedBox(height: 8),
          // _CircleAction(
          //   tooltip: l10n.desktopNavTranslateTooltip,
          //   icon: lucide.Lucide.Languages,
          //   onTap: onTapTranslate,
          //   size: 40,
          //   iconSize: 18,
          //   iconColor: isTranslateActive ? cs.primary : null,
          // ),
          // const SizedBox(height: 8),
          // _CircleAction(
          //   tooltip: l10n.desktopNavStorageTooltip,
          //   icon: lucide.Lucide.Folder,
          //   onTap: onTapStorage,
          //   size: 40,
          //   iconSize: 18,
          //   iconColor: isStorageActive ? cs.primary : null,
          // ),
          const Spacer(),
          _CircleAction(
            tooltip: 'Workflow (simplen8n)',
            icon: lucide.Lucide.Network,
            onTap: () => GoRouter.of(context).go('/simplen8n'),
            size: 40,
            iconSize: 18,
          ),
          const SizedBox(height: 8),
          _ThemeCycleButton(),
          const SizedBox(height: 8),
          _CircleAction(
            tooltip: l10n.desktopNavSettingsTooltip,
            icon: lucide.Lucide.Settings,
            onTap: onTapSettings,
            size: 40,
            iconSize: 18,
            iconColor: isSettingsActive ? cs.primary : null,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


//  - 监听 UserProvider，根据 avatarType 渲染四种头像：
//     - emoji：圆形背景 + Emoji 文字
//     - url：网络图片（加载失败 fallback 到首字母头像）
//     - file：本地文件（用 SandboxPathResolver.fix 修正沙盒路径，文件不存在也 fallback）
//     - 其他/null：首字母头像（取 name 第一个字符）
//   - 左键/右键点击均弹出 UserProfileDialog
class _UserAvatarButton extends StatefulWidget {
  @override
  State<_UserAvatarButton> createState() => _UserAvatarButtonState();
}

class _UserAvatarButtonState extends State<_UserAvatarButton> {
  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();
    final cs = Theme.of(context).colorScheme;
    Widget avatar;
    final type = up.avatarType;
    final value = up.avatarValue;
    if (type == 'emoji' && value != null && value.isNotEmpty) {
      avatar = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: EmojiText(value, fontSize: 18, optimizeEmojiAlign: true),
      );
    } else if (type == 'url' && value != null && value.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          value,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _initialAvatar(up.name, cs);
          },
        ),
      );
    } else if (type == 'file' && value != null && value.isNotEmpty) {
      // Local file path (gracefully handle missing files from imported backups)
      final fixed = SandboxPathResolver.fix(value);
      final f = File(fixed);
      if (f.existsSync()) {
        avatar = ClipOval(
          child: Image(
            image: FileImage(f),
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        );
      } else {
        avatar = _initialAvatar(up.name, cs);
      }
    } else {
      avatar = _initialAvatar(up.name, cs);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          showUserProfileDialog(context);
        },
        onSecondaryTap: () {
          showUserProfileDialog(context);
        },
        child: _HoverCircle(size: 42, child: avatar),
      ),
    );
  }

  Widget _initialAvatar(String name, ColorScheme cs) {
    final letter = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
          fontSize: 36 * 0.44, // keep initial scaled to avatar size
        ),
      ),
    );
  }
}




// 通用圆形图标按钮：Tooltip + GestureDetector + _HoverCircle
// iconColor 参数：激活态传入 cs.primary，非激活态用 cs.onSurface 0.8 透明度
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.iconColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: onTap,
        child: _HoverCircle(
          size: size,
          child: Icon(
            icon,
            size: iconSize,
            color: (iconColor ?? cs.onSurface.withValues(alpha: 0.8)),
          ),
        ),
      ),
    );
  }
}
  
  
// - 鼠标悬浮交互核心：
//   - 进入 → _hovered = true，背景变为 primary 10% 透明度
//   - 离开 → _hovered = false，背景透明
//   - 过渡用 AnimatedContainer，140ms easeOutCubic 曲线
// - 非 Material ripple，符合 iOS 风格触感反馈
class _HoverCircle extends StatefulWidget {
  const _HoverCircle({required this.child, this.size = 44});
  final Widget child;
  final double size;
  @override
  State<_HoverCircle> createState() => _HoverCircleState();
}

class _HoverCircleState extends State<_HoverCircle> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _hovered
              ? cs.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}



class _ThemeCycleButton extends StatefulWidget {
  @override
  State<_ThemeCycleButton> createState() => _ThemeCycleButtonState();
}

class _ThemeCycleButtonState extends State<_ThemeCycleButton> {
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final icon = _iconFor(sp.themeMode);
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.desktopNavThemeToggleTooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => _cycleTheme(context),
        child: _HoverCircle(
          size: 40,
          child: Icon(
            icon,
            size: 20,
            color: cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lucide.Lucide.Sun;
      case ThemeMode.dark:
        return lucide.Lucide.Moon;
      case ThemeMode.system:
        return lucide.Lucide.Monitor;
    }
  }

  void _cycleTheme(BuildContext context) {
    final sp = context.read<SettingsProvider>();
    final current = sp.themeMode;
    final next = () {
      switch (current) {
        case ThemeMode.system:
          return ThemeMode.light;
        case ThemeMode.light:
          return ThemeMode.dark;
        case ThemeMode.dark:
          return ThemeMode.system;
      }
    }();
    sp.setThemeMode(next);
  }
}
