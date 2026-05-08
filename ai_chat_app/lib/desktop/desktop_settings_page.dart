import 'package:ai_chat_app/desktop/setting/about_pane.dart';
import 'package:ai_chat_app/icons/lucide_adapter.dart' as lucide;
import 'package:ai_chat_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DesktopSettingsPage extends StatefulWidget {
  const DesktopSettingsPage({
    super.key,
    this.initialProviderKey
  });

  final String? initialProviderKey;

  @override
  State<DesktopSettingsPage> createState()=>_DesktopSettingsPageState();
}
enum _SettingsMenuItem {
  display,
  about,
}
class _DesktopSettingsPageState extends State<DesktopSettingsPage>{
  _SettingsMenuItem _selected = _SettingsMenuItem.display;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    const double menuWidth = 250;
    final topBar = SizedBox(
      height: 36,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Text(
            l10n.settingsPageTitle, // 固定显示“设置”
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar,
          Expanded(
            child: Row(
              children: [
                // 左侧菜单
                _SettingsMenu(
                  width: menuWidth,
                  selected: _selected,
                  onSelect: (it) => setState(() => _selected = it),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 0.5,
                  color: cs.outlineVariant.withValues(alpha: 0.12),
                ),
                // 右侧内容
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutCubic,
                    child:(){
                      switch(_selected){
                        case _SettingsMenuItem.display:
                          return const SizedBox.shrink(); // TODO: 显示显示设置界面
                        case _SettingsMenuItem.about:
                           return const DesktopAboutPane(key: ValueKey('about')); // TODO: 显示关于界面
                      }
                    }()
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({
    required this.width,
    required this.selected,
    required this.onSelect,
  });
  final double width;
  final _SettingsMenuItem selected;
  final ValueChanged<_SettingsMenuItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (
        _SettingsMenuItem.display,
        lucide.Lucide.Monitor,
        l10n.settingsPageDisplay,
      ),
      // (
      //   _SettingsMenuItem.providers,
      //   lucide.Lucide.Boxes,
      //   l10n.settingsPageProviders,
      // ),
      // (
      //   _SettingsMenuItem.assistant,
      //   lucide.Lucide.Bot,
      //   l10n.settingsPageAssistant,
      // ),
      // (
      //   _SettingsMenuItem.defaultModel,
      //   lucide.Lucide.Heart,
      //   l10n.settingsPageDefaultModel,
      // ),
      // (_SettingsMenuItem.search, lucide.Lucide.Earth, l10n.settingsPageSearch),
      // (_SettingsMenuItem.mcp, lucide.Lucide.Terminal, l10n.settingsPageMcp),
      // (
      //   _SettingsMenuItem.quickPhrases,
      //   lucide.Lucide.Zap,
      //   l10n.settingsPageQuickPhrase,
      // ),
      // (
      //   _SettingsMenuItem.instructionInjection,
      //   lucide.Lucide.Layers,
      //   l10n.settingsPageInstructionInjection,
      // ),
      // (
      //   _SettingsMenuItem.worldBook,
      //   lucide.Lucide.BookOpen,
      //   l10n.settingsPageWorldBook,
      // ),
      // (_SettingsMenuItem.tts, lucide.Lucide.Volume2, l10n.settingsPageTts),
      // (
      //   _SettingsMenuItem.networkProxy,
      //   lucide.Lucide.EthernetPort,
      //   l10n.settingsPageNetworkProxy,
      // ),
      // (
      //   _SettingsMenuItem.backup,
      //   lucide.Lucide.Database,
      //   l10n.settingsPageBackup,
      // ),
      // (
      //   _SettingsMenuItem.hotkeys,
      //   lucide.Lucide.Keyboard,
      //   l10n.settingsPageHotkeys,
      // ),
      (
        _SettingsMenuItem.about,
        lucide.Lucide.BadgeInfo,
        l10n.settingsPageAbout,
      ),
    ];
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuItem(
              icon: items[i].$2,
              label: items[i].$3,
              selected: selected == items[i].$1,
              onTap: () => onSelect(items[i].$1),
              color: cs.onSurface.withValues(alpha: 0.9),
              selectedColor: cs.primary,
              hoverBg: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            if (i != items.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.selectedColor,
    required this.hoverBg,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final Color selectedColor;
  final Color hoverBg;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.selected
        ? cs.primary.withValues(alpha: 0.10)
        : _hover
        ? widget.hoverBg
        : Colors.transparent;
    final fg = widget.selected ? widget.selectedColor : widget.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: fg,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
