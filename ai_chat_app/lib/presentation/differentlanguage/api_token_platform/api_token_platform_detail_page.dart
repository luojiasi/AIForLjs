import 'package:flutter/material.dart';
import 'api_token_platform_data.dart';
import 'api_token_platform_full_detail_page.dart';

class ApiTokenPlatformDetailPage extends StatefulWidget {
  final ApiTokenPlatformTopic topic;

  const ApiTokenPlatformDetailPage({super.key, required this.topic});

  @override
  State<ApiTokenPlatformDetailPage> createState() => _ApiTokenPlatformDetailPageState();
}

class _ApiTokenPlatformDetailPageState extends State<ApiTokenPlatformDetailPage> {
  int _selectedSection = 0;
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  final ScrollController _scrollController = ScrollController();

  late final List<_SectionDef> _sections;

  @override
  void initState() {
    super.initState();
    final t = widget.topic;
    _sections = [
      _SectionDef('概述', Icons.info_outline, t.overview),
      _SectionDef('核心概念', Icons.lightbulb_outline, t.coreConcept),
      _SectionDef('关键要点', Icons.star_outline, t.keyPoints),
      _SectionDef('详细内容', Icons.article_outlined, t.detailedContent),
      _SectionDef('实践技巧', Icons.build_outlined, t.practicalTips),
      _SectionDef('相关技术', Icons.link, t.relatedTech),
    ];
  }

  void _scrollToSection(int index) {
    setState(() => _selectedSection = index);
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(t.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.color, t.color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(t.icon, size: 56, color: Colors.white30),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(t.englishName, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: t.color)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final selected = _selectedSection == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_sections[index].title, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.bold : null)),
                      selected: selected,
                      onSelected: (_) => _scrollToSection(index),
                      selectedColor: t.color,
                      labelStyle: TextStyle(color: selected ? Colors.white : null),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(_sections.length, (i) {
                  return Padding(
                    key: _sectionKeys[i],
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _sectionCard(context, _sections[i], t),
                  );
                }),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ApiTokenPlatformFullDetailPage(topic: t),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('查看完整详解'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, _SectionDef section, ApiTokenPlatformTopic t) {
    return Card(
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
                  height: 22,
                  decoration: BoxDecoration(
                    color: t.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(section.icon, color: t.color, size: 18),
                const SizedBox(width: 8),
                Text(section.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(section.content, style: const TextStyle(fontSize: 14, height: 1.7)),
          ],
        ),
      ),
    );
  }
}

class _SectionDef {
  final String title;
  final IconData icon;
  final String content;
  const _SectionDef(this.title, this.icon, this.content);
}
