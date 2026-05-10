import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'api_token_platform_data.dart';

class ApiTokenPlatformHome extends StatefulWidget {
  const ApiTokenPlatformHome({super.key});

  @override
  State<ApiTokenPlatformHome> createState() => _ApiTokenPlatformHomeState();
}

class _ApiTokenPlatformHomeState extends State<ApiTokenPlatformHome> {
  String _query = '';
  String? _selectedTag;
  String _filterDifficulty = '全部';

  List<ApiTokenPlatformTopic> get _filtered {
    var list = apiTokenPlatformTopics.toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) {
        return t.name.toLowerCase().contains(q) ||
            t.englishName.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }
    if (_filterDifficulty != '全部') {
      list = list.where((t) => t.difficulty == _filterDifficulty).toList();
    }
    if (_selectedTag != null) {
      list = list.where((t) => t.tags.contains(_selectedTag)).toList();
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
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('API Token 中转平台'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.hub, size: 64, color: Colors.white38),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索主题或标签...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: ['全部', '基础', '中级', '进阶'].map((d) {
                  final selected = _filterDifficulty == d;
                  return ChoiceChip(
                    label: Text(d),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterDifficulty = d),
                    selectedColor: const Color(0xFF0D47A1),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.bold : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '共 ${filtered.length} 个主题',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ),
          ),
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('未找到匹配内容', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TopicCard(
                        topic: filtered[index],
                        onTap: () => context.push(
                          '/api_token_platform/detail',
                          extra: {'id': filtered[index].id, 'topic': filtered[index]},
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ApiTokenPlatformTopic topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  Color get _difficultyColor {
    switch (topic.difficulty) {
      case '基础':
        return Colors.green;
      case '中级':
        return Colors.orange;
      case '进阶':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: topic.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(topic.icon, color: topic.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(topic.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(topic.difficulty, style: TextStyle(fontSize: 10, color: _difficultyColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(topic.englishName, style: TextStyle(fontSize: 12, color: topic.color.withValues(alpha: 0.8))),
                    const SizedBox(height: 6),
                    Text(topic.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: topic.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: topic.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag, style: TextStyle(fontSize: 10, color: topic.color.withValues(alpha: 0.8))),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
