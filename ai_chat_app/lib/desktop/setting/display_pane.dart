part of '../desktop_settings_page.dart';


class _DisplaySettingsBody extends StatelessWidget {
  const _DisplaySettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 对其齐方式
    return Container(
      alignment: Alignment.topCenter,
      // 可滚动
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // 宽度上线
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          // 垂直排布
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingsCard(
                title: l10n.settingsPageDisplay, 
                children: const [
                  _ColorModeRow(),
                  _RowDivider(),
                  _ThemeColorRow(),
                  _RowDivider(),
                  _ToggleRowPureBackground(),
                  _RowDivider(),
                  _ChatMessageBackgroundRow(),
                  _RowDivider(),
                  _TopicPositionRow(),
                ],
              ),
              const SizedBox(height: 16),
              Text("l10n.displaySettings", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text("l10n.displaySettings", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text("l10n.displaySettings", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text("l10n.displaySettings", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text("l10n.displaySettings", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sp = context.watch<SettingsProvider>();
    return Material(
      color: sp.usePureBackground
          ? (isDark ? Colors.black : Colors.white)
          : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          width: 0.5,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : cs.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Text(
                title, 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500, 
                  color: cs.onSurface,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Divider(
        height: 1,
        thickness: 0.5,
        indent: 8,
        endIndent: 8,
        color: cs.outlineVariant.withValues(alpha: 0.12),
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({required this.label, required this.trailing});
  final String label;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Match other settings row labels (14, normal, slightly dimmed)
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: cs.onSurface.withValues(alpha: 0.9),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// 颜色选择器
class _ColorModeRow extends StatelessWidget {
  const _ColorModeRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LabeledRow(
      label: l10n.settingsPageColorMode,
      trailing: const _ThemeModeSegmented(),
    );
  }
}

class _ThemeModeSegmented extends StatefulWidget {
  const _ThemeModeSegmented();
  @override
  State<_ThemeModeSegmented> createState() => _ThemeModeSegmentedState();
}

class _ThemeModeSegmentedState extends State<_ThemeModeSegmented> {
  int _hover = -1;
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final mode = sp.themeMode;
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (ThemeMode.light, l10n.settingsPageLightMode, lucide.Lucide.Sun),
      (ThemeMode.dark, l10n.settingsPageDarkMode, lucide.Lucide.Moon),
      (ThemeMode.system, l10n.settingsPageSystemMode, lucide.Lucide.Monitor),
    ];

    final trackBg = isDark? Colors.white.withValues(alpha: 0.06): Colors.black.withValues(alpha: 0.04);
    return Container(
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            MouseRegion(
              onEnter: (_) => setState(() => _hover = i),
              onExit: (_) => setState(() => _hover = -1),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.read<SettingsProvider>().setThemeMode(items[i].$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: () {
                      final selected = mode == items[i].$1;
                      if (selected) {
                        return cs.primary.withValues(alpha: isDark ? 0.18 : 0.14,);
                      }
                      if (_hover == i) {
                        return isDark? Colors.white.withValues(alpha: 0.10): Colors.black.withValues(alpha: 0.06);
                      }
                      return Colors.transparent;
                    }(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$3,
                        size: 16,
                        color: (mode == items[i].$1)? cs.primary: cs.onSurface.withValues(alpha: 0.74),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        items[i].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Reduce segmented labels to 14 for consistency
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: (mode == items[i].$1)? cs.primary: cs.onSurface.withValues(alpha: 0.82),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i != items.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// 主题颜色选择
class _ThemeColorRow extends StatelessWidget {
  const _ThemeColorRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LabeledRow(
      label: l10n.displaySettingsPageThemeColorTitle,
      trailing: const _ThemeDots(),
    );
  }
}

class _ThemeDots extends StatelessWidget {
  const _ThemeDots();
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final selected = sp.themePaletteId;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final p in ThemePalettes.all)
          _ThemeDot(
            color: p.light.primary,
            selected: selected == p.id,
            onTap: () => context.read<SettingsProvider>().setThemePalette(p.id),
          ),
      ],
    );
  }
}

class _ThemeDot extends StatefulWidget {
  const _ThemeDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<_ThemeDot> createState() => _ThemeDotState();
}

class _ThemeDotState extends State<_ThemeDot> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
            border: Border.all(
              color: widget.selected? cs.onSurface.withValues(alpha: 0.85): Colors.white,
              width: widget.selected ? 2 : 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRowPureBackground extends StatelessWidget {
  const _ToggleRowPureBackground();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sp = context.watch<SettingsProvider>();
    return _ToggleRow(
      label: l10n.themeSettingsPageUsePureBackgroundTitle,
      value: sp.usePureBackground,
      onChanged: (v) =>
          context.read<SettingsProvider>().setUsePureBackground(v),
    );
  }
}

class _ChatMessageBackgroundRow extends StatelessWidget {
  const _ChatMessageBackgroundRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LabeledRow(
      label: l10n.displaySettingsPageChatMessageBackgroundTitle,
      trailing: Text("Comming soon"),
    );
    // return _LabeledRow(
    //   label: l10n.displaySettingsPageChatMessageBackgroundTitle,
    //   trailing: const _BackgroundStyleDropdown(),
    // );
  }
}

// --- Topic position (desktop) ---
class _TopicPositionRow extends StatelessWidget {
  const _TopicPositionRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LabeledRow(
      label: l10n.desktopDisplaySettingsTopicPositionTitle,
      trailing: Text("Comming soon"),
    );
    // return _LabeledRow(
    //   label: l10n.desktopDisplaySettingsTopicPositionTitle,
    //   trailing: const _TopicPositionDropdown(),
    // );
  }
}

// --- Desktop tray settings ---
class _DesktopTrayShowRow extends StatelessWidget {
  const _DesktopTrayShowRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sp = context.watch<SettingsProvider>();
    return _ToggleRow(
      label: l10n.displaySettingsPageTrayShowTrayTitle,
      value: sp.desktopShowTray,
      onChanged: (v) => context.read<SettingsProvider>().setDesktopShowTray(v),
    );
  }
}

class _DesktopTrayMinimizeOnCloseRow extends StatelessWidget {
  const _DesktopTrayMinimizeOnCloseRow();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sp = context.watch<SettingsProvider>();
    final enabled = sp.desktopShowTray;
    return _ToggleRow(
      label: l10n.displaySettingsPageTrayMinimizeOnCloseTitle,
      value: enabled && sp.desktopMinimizeToTrayOnClose,
      onChanged: enabled
          ? (v) => context
                .read<SettingsProvider>()
                .setDesktopMinimizeToTrayOnClose(v)
          : null,
    );
  }
}

// class _TopicPositionDropdown extends StatefulWidget {
//   const _TopicPositionDropdown();
//   @override
//   State<_TopicPositionDropdown> createState() => _TopicPositionDropdownState();
// }

// class _TopicPositionDropdownState extends State<_TopicPositionDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final sp = context.watch<SettingsProvider>();
//     final options = <DesktopSelectOption<DesktopTopicPosition>>[
//       DesktopSelectOption(
//         value: DesktopTopicPosition.left,
//         label: l10n.desktopDisplaySettingsTopicPositionLeft,
//       ),
//       DesktopSelectOption(
//         value: DesktopTopicPosition.right,
//         label: l10n.desktopDisplaySettingsTopicPositionRight,
//       ),
//     ];

//     return DesktopSelectDropdown<DesktopTopicPosition>(
//       value: sp.desktopTopicPosition,
//       options: options,
//       onSelected: (pos) =>
//           context.read<SettingsProvider>().setDesktopTopicPosition(pos),
//     );
//   }
// }

// class _BackgroundStyleDropdown extends StatefulWidget {
//   const _BackgroundStyleDropdown();
//   @override
//   State<_BackgroundStyleDropdown> createState() =>
//       _BackgroundStyleDropdownState();
// }

// class _BackgroundStyleDropdownState extends State<_BackgroundStyleDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final sp = context.watch<SettingsProvider>();
//     final options = <DesktopSelectOption<ChatMessageBackgroundStyle>>[
//       DesktopSelectOption(
//         value: ChatMessageBackgroundStyle.defaultStyle,
//         label: l10n.displaySettingsPageChatMessageBackgroundDefault,
//       ),
//       DesktopSelectOption(
//         value: ChatMessageBackgroundStyle.frosted,
//         label: l10n.displaySettingsPageChatMessageBackgroundFrosted,
//       ),
//       DesktopSelectOption(
//         value: ChatMessageBackgroundStyle.solid,
//         label: l10n.displaySettingsPageChatMessageBackgroundSolid,
//       ),
//     ];

//     return DesktopSelectDropdown<ChatMessageBackgroundStyle>(
//       value: sp.chatMessageBackgroundStyle,
//       options: options,
//       onSelected: (style) =>
//           context.read<SettingsProvider>().setChatMessageBackgroundStyle(style),
//     );
//   }
// }


// 开关组件组
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              // Reduce toggle row label size to 14 to match other panes
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: cs.onSurface.withValues(alpha: 0.9),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          IosSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
