import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'agent_architectures_data.dart';

/// ============================================================
/// AI Agent 架构大全 — 主入口页面
/// 展示12种主流Agent架构，支持搜索、分类筛选
/// ============================================================

class AgentArchitecturesHome extends StatefulWidget {
  const AgentArchitecturesHome({super.key});

  @override
  State<AgentArchitecturesHome> createState() => _AgentArchitecturesHomeState();
}

class _AgentArchitecturesHomeState extends State<AgentArchitecturesHome> {
  String _query = '';
  String? _selectedTag;

  Set<String> get _allTags {
    final tags = <String>{};
    for (final arch in agentArchitectures) {
      tags.addAll(arch.tags);
    }
    return tags;
  }

  List<AgentArchitecture> get _filtered {
    var list = agentArchitectures;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((a) {
        if (a.name.toLowerCase().contains(q)) return true;
        if (a.englishName.toLowerCase().contains(q)) return true;
        if (a.subtitle.toLowerCase().contains(q)) return true;
        for (final tag in a.tags) {
          if (tag.toLowerCase().contains(q)) return true;
        }
        return false;
      }).toList();
    }
    if (_selectedTag != null) {
      list = list.where((a) => a.tags.contains(_selectedTag)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── 顶部横幅 ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('AI Agent 架构大全'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.psychology, size: 80, color: Colors.white38),
                ),
              ),
            ),
          ),

          // ── 搜索栏 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索架构名称、英文名或标签...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),

          // ── 标签筛选 ──
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _tagChip('全部', null),
                  ..._allTags.map((tag) => _tagChip(tag, tag)),
                ],
              ),
            ),
          ),

          // ── 统计信息 ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '共 ${filtered.length} 种架构',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // ── 架构列表 ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final arch = filtered[index];
                  return _ArchitectureCard(arch: arch);
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label, String? tag) {
    final isSelected = _selectedTag == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedTag = tag),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
}

class _ArchitectureCard extends StatelessWidget {
  final AgentArchitecture arch;
  const _ArchitectureCard({required this.arch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/agent_architectures/detail', extra: {
          'id': arch.id,
          'arch': arch,
        }),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: arch.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(arch.icon, color: arch.color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arch.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          arch.englishName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: arch.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                arch.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: arch.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: arch.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: arch.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
