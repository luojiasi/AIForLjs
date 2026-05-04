import 'package:flutter/material.dart';
import 'agent_architectures_data.dart';

/// ============================================================
/// AI Agent 架构 — 详情页面
/// 展示单个架构的完整详解内容
/// ============================================================

class AgentArchitecturesDetailPage extends StatefulWidget {
  final AgentArchitecture arch;
  const AgentArchitecturesDetailPage({super.key, required this.arch});

  @override
  State<AgentArchitecturesDetailPage> createState() =>
      _AgentArchitecturesDetailPageState();
}

class _AgentArchitecturesDetailPageState
    extends State<AgentArchitecturesDetailPage> {
  int _selectedSection = 0;

  static const _sections = [
    '概述',
    '核心原理',
    '执行流程',
    '详细内容',
    '优势',
    '局限',
    '适用场景',
    '框架实现',
    '相关论文',
    '演进路径',
  ];

  final List<GlobalKey> _sectionKeys =
      List.generate(_sections.length, (_) => GlobalKey());
  final ScrollController _scrollController = ScrollController();

  void _scrollToSection(int index) {
    setState(() => _selectedSection = index);
    final key = _sectionKeys[index];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arch = widget.arch;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── 顶部横幅 ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: arch.color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
              title: Text(
                arch.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [arch.color, arch.color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 50),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(arch.icon, color: Colors.white.withValues(alpha: 0.6), size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          arch.englishName,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // // ── 标签行 ──
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          //     child: Wrap(
          //       spacing: 8,
          //       runSpacing: 6,
          //       children: arch.tags.map((tag) => Chip(
          //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //         visualDensity: VisualDensity.compact,
          //         label: Text(tag, style: const TextStyle(fontSize: 12)),
          //         backgroundColor: arch.color.withValues(alpha: 0.1),
          //         side: BorderSide(color: arch.color.withValues(alpha: 0.3)),
          //       )).toList(),
          //     ),
          //   ),
          // ),

          // ── 副标题 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                arch.subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // ── 分段导航栏 ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedSection == index;
                  return GestureDetector(
                    onTap: () => _scrollToSection(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? arch.color
                            : arch.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _sections[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : arch.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── 分段内容 ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(0, '📖 概述', arch.overview, arch.color, theme),
                _sectionCard(1, '🧠 核心原理', arch.corePrinciple, arch.color, theme),
                _sectionCard(2, '🔄 执行流程', arch.workflow, arch.color, theme, isCode: true),
                _sectionCard(3, '📚 详细内容', arch.detailedContent, arch.color, theme),
                _sectionCard(4, '✅ 优势', arch.pros, arch.color, theme),
                _sectionCard(5, '⚠️ 局限性', arch.cons, arch.color, theme),
                _sectionCard(6, '🎯 适用场景', arch.useCases, arch.color, theme),
                _sectionCard(7, '🔧 框架实现', arch.implementations, arch.color, theme),
                _sectionCard(8, '📝 相关论文', arch.papers, arch.color, theme),
                _sectionCard(9, '🚀 演进路径', arch.evolutionPath, arch.color, theme),
              ],
            ),
          ),

          // ── 底部间距 ──
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _sectionCard(
    int index,
    String title,
    String content,
    Color accentColor,
    ThemeData theme, {
    bool isCode = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isCode
                ? Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                    ),
                  )
                : Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
