import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:ai_chat_app/l10n/app_localizations.dart';

/// 纯 UI 示例：复刻 SideDrawer 的所有视觉技巧，不包含任何业务逻辑。
///
/// 涵盖的技巧：
/// 1. 毛玻璃嵌入式侧边栏 (ClipRect + BackdropFilter + Material)
/// 2. 移动端 Drawer 全宽模式
/// 3. 无边框搜索框 + AnimatedSwitcher 切换提示文字
/// 4. 自定义分段 Tab 控件 (AnimatedPositioned 滑块)
/// 5. 可折叠分组标题 (AnimatedRotation 箭头 + AnimatedSize)
/// 6. 无涟漪按压卡片 (IosCardPress 的简化版：颜色渐变 + 悬停)
/// 7. 底部渐变遮罩 (LinearGradient overlay)
/// 8. 列表项入场动画 (fadeIn + moveY)
/// 9. 日期分组标签
/// 10. 置顶区 + 普通区布局
class SideDrawer extends StatefulWidget {
  const SideDrawer({
    super.key,
    this.embedded = false, // 是否嵌入式（毛玻璃背景）模式
    this.embeddedWidth,
  });
  final bool embedded;
  final double? embeddedWidth;

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> with TickerProviderStateMixin {
  // ── 搜索 ──
  final _searchController = TextEditingController();
  String _query = '';

  // ── 助手展开 ──
  bool _assistantsExpanded = false;
  bool _assistantHeaderHovered = false;

  // ── 桌面 Tab ──
  late final TabController _tabController;

  // ── 模拟数据 ──
  static final _assistantNames = <String>['通用助手', '代码助手', '翻译助手', '创意助手'];
  static final _conversations = <_FakeConversation>[
    _FakeConversation(id: 'c1', title: 'React 性能优化讨论', date: DateTime(2026, 5, 6)),
    _FakeConversation(id: 'c2', title: 'Flutter 布局问题', date: DateTime(2026, 5, 6)),
    _FakeConversation(id: 'c3', title: 'API 接口设计评审', date: DateTime(2026, 5, 5)),
    _FakeConversation(id: 'c4', title: '数据库迁移方案', date: DateTime(2026, 5, 4)),
    _FakeConversation(id: 'c5', title: '单元测试编写规范', date: DateTime(2026, 5, 3)),
    _FakeConversation(id: 'c6', title: 'Docker 部署配置', date: DateTime(2026, 4, 28)),
    _FakeConversation(id: 'c7', title: 'CI/CD 流水线优化', date: DateTime(2026, 4, 15)),
  ];
  static const _pinnedIds = <String>{'c1', 'c3'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── 工具函数：平台判断 ──
  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  // ── 工具函数：日期标签 ──
  String _dateLabel(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return l10n.sideDrawerToday;
    if (diff == 1) return l10n.sideDrawerYesterday;
    if (diff < 7) return l10n.sideDrawerDaysAgo(diff);
    return '${date.year}/${date.month}/${date.day}';
  }

  // ── 工具函数：按日期分组 ──
  List<_Group> _groupByDate(List<_FakeConversation> items, AppLocalizations l10n) {
    final map = <DateTime, List<_FakeConversation>>{};
    for (final c in items) {
      final d = DateTime(c.date.year, c.date.month, c.date.day);
      map.putIfAbsent(d, () => []).add(c);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final k in keys)
        _Group(label: _dateLabel(k, l10n), items: map[k]!..sort((a, b) => b.date.compareTo(a.date))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textBase = isDark ? Colors.white : Colors.black;
    final l10n = AppLocalizations.of(context)!;

    // 过滤 + 分组
    final filtered = _query.trim().isEmpty
        ? _conversations.toList()
        : _conversations.where((c) => c.title.toLowerCase().contains(_query.toLowerCase())).toList();

    final pinned = filtered
        .where((c) => _pinnedIds.contains(c.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final rest = filtered.where((c) => !_pinnedIds.contains(c.id)).toList();
    final groups = _groupByDate(rest, l10n);

    // ═══════════════════════════════════════════════
    // 核心内容区域
    // ═══════════════════════════════════════════════
    final inner = SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // ── 固定头部区 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ──── 技巧 2：搜索框 (透明边框 + 填充背景) ────
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchPlaceholder,
                        filled: true,
                        fillColor: isDark
                            ? Colors.white10
                            : Colors.grey.shade200.withValues(alpha: 0.80),
                        isDense: true,
                        isCollapsed: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 4),
                          child: Icon(Icons.search, size: 16,
                              color: textBase.withValues(alpha: 0.6)),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        // 关键：三态边框全透明，只靠 fillColor 区分
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: textBase, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // ──── 技巧 3：自定义分段 Tab ────
                    if (_isDesktop)
                      _SegmentedTab(
                        controller: _tabController,
                        textColor: textBase,
                        isDark: isDark,
                        primaryColor: cs.primary,
                      )
                    else ...[
                      const SizedBox(height: 4),
                      // ──── 技巧 4：可折叠助手标题 ────
                      _AssistantHeader(
                        name: _assistantNames[0],
                        isDark: isDark,
                        primaryColor: cs.primary,
                        surfaceColor: cs.surface,
                        expanded: _assistantsExpanded,
                        hovered: _assistantHeaderHovered,
                        onTap: () =>
                            setState(() => _assistantsExpanded = !_assistantsExpanded),
                        onHoverChange: (v) =>
                            setState(() => _assistantHeaderHovered = v),
                      ),
                    ],
                  ],
                ),
              ),

              // ── 可滚动列表区 ──
              Expanded(
                child: _isDesktop
                    ? _buildTabViews(cs, textBase, pinned, groups, l10n)
                    : _buildLegacyList(cs, textBase, pinned, groups, l10n),
              ),

              // ── 底部用户栏 ──
              if (!widget.embedded || !_isDesktop)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: widget.embedded ? Colors.transparent : cs.surface,
                  ),
                  child: Row(
                    children: [
                      // 头像
                      _AvatarWidget(name: l10n.sideDrawerDefaultUser, primaryColor: cs.primary, size: 40),
                      const SizedBox(width: 20),
                      // 用户名
                      Expanded(
                        child: Text(
                          l10n.sideDrawerUserName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textBase,
                          ),
                        ),
                      ),
                      // 设置按钮
                      _PressIcon(icon: Icons.settings, color: textBase),
                    ],
                  ),
                ),
            ],
          ),

          // ── 技巧 9：底部渐变遮罩 ──
          if (!widget.embedded)
            const Positioned(
              left: 0, right: 0, bottom: 62,
              child: IgnorePointer(
                child: _GradientFadeOverlay(),
              ),
            ),
        ],
      ),
    );

    // ═══════════════════════════════════════════════
    // 技巧 1：毛玻璃 vs Drawer 外壳
    // ═══════════════════════════════════════════════
    if (widget.embedded) {
      return ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: cs.surface.withValues(alpha: 0.60),
            child: SizedBox(
              width: widget.embeddedWidth ?? 300,
              child: inner,
            ),
          ),
        ),
      );
    }
    // 移动端：全宽 Drawer
    return Drawer(
      backgroundColor: cs.surface,
      width: MediaQuery.sizeOf(context).width,
      child: inner,
    );
  }

  // ── 技巧 8：列表项入场动画包装 ──
  Widget animateItem(Widget child, {required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 220 + index * 16),
      curve: Curves.easeOutCubic,
      builder: (ctx, v, _) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 6 * (1 - v)),
            child: child,
          ),
        );
      },
    );
  }

  // ── 桌面 Tab 视图 ──
  Widget _buildTabViews(ColorScheme cs, Color textBase,
      List<_FakeConversation> pinned, List<_Group> groups, AppLocalizations l10n) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 0: 助手列表
        ListView(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 16),
          children: [
            for (int i = 0; i < _assistantNames.length; i++)
              _AssistantTile(
                name: _assistantNames[i],
                selected: i == 0,
                isDark: cs.brightness == Brightness.dark,
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
              ),
          ],
        ),
        // Tab 1: 对话列表
        _buildConversationList(cs, textBase, pinned, groups, l10n),
      ],
    );
  }

  // ── 传统布局 (移动端) ──
  Widget _buildLegacyList(ColorScheme cs, Color textBase,
      List<_FakeConversation> pinned, List<_Group> groups, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      children: [
        // ──── 技巧 5：可折叠区域 (AnimatedSize + AnimatedSwitcher) ────
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: !_assistantsExpanded
                ? const SizedBox.shrink()
                : Column(
                    key: const ValueKey('inline-assistants'),
                    children: [
                      for (int i = 0; i < _assistantNames.length; i++)
                        _AssistantTile(
                          name: _assistantNames[i],
                          selected: i == 0,
                          isDark: cs.brightness == Brightness.dark,
                          primaryColor: cs.primary,
                          surfaceColor: cs.surface,
                        ),
                    ],
                  ),
          ),
        ),
        // 对话列表
        _buildConversationList(cs, textBase, pinned, groups, l10n),
      ],
    );
  }

  // ── 对话列表公共组件 ──
  Widget _buildConversationList(ColorScheme cs, Color textBase,
      List<_FakeConversation> pinned, List<_Group> groups, AppLocalizations l10n) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // ──── 技巧 10：置顶区 ────
        if (pinned.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 0, 6),
            child: Text(
              l10n.sideDrawerPinnedLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
          for (int i = 0; i < pinned.length; i++)
            animateItem(
              _ConversationTile(
                title: pinned[i].title,
                active: false,
                textColor: textBase,
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: cs.brightness == Brightness.dark,
                embedded: widget.embedded,
              ),
              index: i,
            ),
          const SizedBox(height: 8),
        ],
        // ──── 技巧 6：日期分组 ────
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 0, 6),
            child: Text(
              group.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
          for (int j = 0; j < group.items.length; j++)
            animateItem(
              _ConversationTile(
                title: group.items[j].title,
                active: false,
                textColor: textBase,
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: cs.brightness == Brightness.dark,
                embedded: widget.embedded,
              ),
              index: j,
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// 技巧 1：毛玻璃底 (BackdropFilter) — 用于嵌入式侧边栏
//   ClipRect + BackdropFilter(imageFilter: blur) + Material(半透明)
//   见 build() 中外层 if (widget.embedded) 分支
// ═══════════════════════════════════════════════════

// ═══════════════════════════════════════════════════
// 技巧 2：无边框搜索框 — 只靠 fillColor 做视觉区分
//   TextField 的三态 Border 全部设为 transparent
//   fillColor 用白色/灰色半透明
//   见 build() 中的 TextField
// ═══════════════════════════════════════════════════

// ═══════════════════════════════════════════════════
// 技巧 3：自定义分段 Tab — AnimatedPositioned 滑块
// ═══════════════════════════════════════════════════
class _SegmentedTab extends StatefulWidget {
  const _SegmentedTab({
    required this.controller,
    required this.textColor,
    required this.isDark,
    required this.primaryColor,
  });
  final TabController controller;
  final Color textColor;
  final bool isDark;
  final Color primaryColor;

  @override
  State<_SegmentedTab> createState() => _SegmentedTabState();
}

class _SegmentedTabState extends State<_SegmentedTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final idx = widget.controller.index;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: LayoutBuilder(builder: (ctx, constraints) {
          const pad = 4.0;
          final segW = (constraints.maxWidth - pad * 2) / 2;
          return Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white10
                  : Colors.grey.shade200.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // ══ 核心：AnimatedPositioned 滑块 ══
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutCubic,
                  left: pad + (idx == 0 ? 0 : segW),
                  top: pad,
                  bottom: pad,
                  width: segW,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(
                          alpha: widget.isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                // ══ 两个 Tab 项 ══
                Row(
                  children: [
                    _TabSegment(
                      label: l10n.sideDrawerAssistantsTab,
                      selected: idx == 0,
                      textColor: widget.textColor,
                      primaryColor: widget.primaryColor,
                      onTap: () => widget.controller.animateTo(0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic),
                    ),
                    _TabSegment(
                      label: l10n.sideDrawerTopicsTab,
                      selected: idx == 1,
                      textColor: widget.textColor,
                      primaryColor: widget.primaryColor,
                      onTap: () => widget.controller.animateTo(1,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TabSegment extends StatefulWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.textColor,
    required this.primaryColor,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color textColor;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  State<_TabSegment> createState() => _TabSegmentState();
}

class _TabSegmentState extends State<_TabSegment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Stack(
            children: [
              // 悬停高亮
              AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                opacity: _hovered && !widget.selected ? 1 : 0,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
              // 文字
              Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: widget.selected
                        ? widget.primaryColor
                        : widget.textColor.withValues(alpha: 0.78),
                  ),
                  child: Text(widget.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 技巧 4：可折叠助手标题 — AnimatedRotation 箭头
// ═══════════════════════════════════════════════════
class _AssistantHeader extends StatefulWidget {
  const _AssistantHeader({
    required this.name,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
    required this.expanded,
    required this.hovered,
    required this.onTap,
    required this.onHoverChange,
  });
  final String name;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;
  final bool expanded;
  final bool hovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChange;

  @override
  State<_AssistantHeader> createState() => _AssistantHeaderState();
}

class _AssistantHeaderState extends State<_AssistantHeader> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textBase = widget.isDark ? Colors.white : Colors.black;

    // 计算背景色：悬停/按压时变暗 (模拟 IosCardPress)
    Color bgColor;
    if (_pressed) {
      bgColor = Color.lerp(Colors.transparent,
          widget.isDark ? Colors.white : Colors.black, 0.12)!;
    } else if (widget.hovered) {
      bgColor = Color.lerp(Colors.transparent,
          widget.isDark ? Colors.white : Colors.black, 0.08)!;
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => widget.onHoverChange(true),
      onExit: (_) => widget.onHoverChange(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
          child: Row(
            children: [
              // 头像
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.name.characters.first,
                  style: TextStyle(
                    color: widget.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textBase,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ══ 核心：AnimatedRotation 箭头 ══
              AnimatedRotation(
                turns: widget.expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: textBase.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 技巧 5：可折叠分组标题 — AnimatedRotation + AnimatedSize
// ═══════════════════════════════════════════════════
class _CollapsibleGroupHeader extends StatelessWidget {
  const _CollapsibleGroupHeader({
    required this.title,
    required this.collapsed,
    required this.onToggle,
  });
  final String title;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            AnimatedRotation(
              turns: collapsed ? 0.0 : 0.25,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 技巧 6：无涟漪按压卡片 (简化版 IosCardPress)
//   核心：AnimatedContainer 背景色渐变 + 无 Ripple
//   RawGestureDetector > TapGestureRecognizer (不产生水波纹)
//   + 按压/悬停/常态 三态颜色插值
// ═══════════════════════════════════════════════════
class _PressCard extends StatefulWidget {
  const _PressCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.baseColor,
    this.selected = false,
    this.embedded = false,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
  });
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? baseColor;
  final bool selected;
  final bool embedded;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 三态颜色计算
    final k = widget.isDark ? 0.14 : 0.12;
    final Color base;
    if (widget.embedded && !widget.selected) {
      base = widget.selected
          ? widget.primaryColor.withValues(alpha: 0.16)
          : Colors.transparent;
    } else {
      base = widget.selected
          ? widget.primaryColor.withValues(alpha: 0.12)
          : widget.surfaceColor;
    }

    Color target;
    if (_pressed) {
      target = Color.lerp(base, widget.isDark ? Colors.white : Colors.black, k)!;
    } else if (_hovered) {
      target = Color.lerp(base, widget.isDark ? Colors.white : Colors.black, k * 0.7)!;
    } else {
      target = base;
    }

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: target,
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 技巧 7：对话列表项 — 复用 _PressCard
// ═══════════════════════════════════════════════════
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.active,
    required this.textColor,
    required this.primaryColor,
    required this.surfaceColor,
    required this.isDark,
    required this.embedded,
  });
  final String title;
  final bool active;
  final Color textColor;
  final Color primaryColor;
  final Color surfaceColor;
  final bool isDark;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: _PressCard(
        selected: active,
        embedded: embedded,
        isDark: isDark,
        primaryColor: primaryColor,
        surfaceColor: surfaceColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w400,
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

// ═══════════════════════════════════════════════════
// 技巧 8：助手列表项
// ═══════════════════════════════════════════════════
class _AssistantTile extends StatelessWidget {
  const _AssistantTile({
    required this.name,
    required this.selected,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
  });
  final String name;
  final bool selected;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: _PressCard(
        selected: selected,
        embedded: false,
        isDark: isDark,
        primaryColor: primaryColor,
        surfaceColor: surfaceColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
          child: Row(
            children: [
              // 头像
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.characters.first,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
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

// ═══════════════════════════════════════════════════
// 技巧 9：渐变遮罩 — 列表底部渐变消失效果
// ═══════════════════════════════════════════════════
class _GradientFadeOverlay extends StatelessWidget {
  const _GradientFadeOverlay();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surface.withValues(alpha: 0.0),
            cs.surface.withValues(alpha: 0.8),
            cs.surface.withValues(alpha: 1.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 辅助组件：无涟漪图标按钮
// ═══════════════════════════════════════════════════
class _PressIcon extends StatefulWidget {
  const _PressIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  State<_PressIcon> createState() => _PressIconState();
}

class _PressIconState extends State<_PressIcon> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color target;
    if (_pressed) {
      target = Color.lerp(widget.color, isDark ? Colors.black : Colors.white, 0.35)!;
    } else if (_hovered) {
      target = Color.lerp(widget.color, isDark ? Colors.black : Colors.white, 0.20)!;
    } else {
      target = widget.color;
    }

    final bgTarget = _pressed
        ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
        : (_hovered
            ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06))
            : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bgTarget,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(10),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: target),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            builder: (ctx, color, _) =>
                Icon(widget.icon, size: 22, color: color ?? widget.color),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 辅助组件：用户头像
// ═══════════════════════════════════════════════════
class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.name,
    required this.primaryColor,
    required this.size,
  });
  final String name;
  final Color primaryColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: primaryColor,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// 数据模型
// ═══════════════════════════════════════════════════
class _FakeConversation {
  final String id;
  final String title;
  final DateTime date;
  const _FakeConversation({required this.id, required this.title, required this.date});
}

class _Group {
  final String label;
  final List<_FakeConversation> items;
  const _Group({required this.label, required this.items});
}
