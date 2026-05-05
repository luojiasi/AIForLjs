import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'python_crawler_data.dart';

class PythonCrawlerHome extends StatefulWidget {
  const PythonCrawlerHome({super.key});

  @override
  State<PythonCrawlerHome> createState() => _PythonCrawlerHomeState();
}

class _PythonCrawlerHomeState extends State<PythonCrawlerHome> {
  String _query = '';
  String _filterDifficulty = '全部';

  List<CrawlerProject> get _filtered {
    var list = crawlerProjects;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) {
        if (p.name.toLowerCase().contains(q)) return true;
        if (p.description.toLowerCase().contains(q)) return true;
        if (p.tags.any((t) => t.contains(q))) return true;
        return false;
      }).toList();
    }
    if (_filterDifficulty != '全部') {
      list = list.where((p) => p.difficulty == _filterDifficulty).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Python 爬虫教程'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索项目名称、标签...',
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
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('未找到匹配内容', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(theme)),
                SliverToBoxAdapter(child: _buildFilterChips()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '学习项目',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = filtered[index];
                        return _ProjectCard(
                          project: project,
                          onTap: () {
                            final idx = crawlerProjects.indexOf(project);
                            context.push('/python_crawler/$idx');
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bug_report, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                '从零开始学 Python 爬虫',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '精选 4 个 GitHub 热门爬虫项目，从入门到进阶，手把手带你掌握网页数据采集技术',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(icon: Icons.code, label: '${crawlerProjects.length} 个项目', color: Colors.white),
              _StatItem(icon: Icons.menu_book, label: '${crawlerProjects.fold<int>(0, (s, p) => s + p.sections.length)} 个章节', color: Colors.white70),
              _StatItem(icon: Icons.school, label: '零基础可学', color: Colors.white60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final difficulties = ['全部', '入门', '中级', '进阶'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: difficulties.map((d) {
                  final selected = _filterDifficulty == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
                      selected: selected,
                      selectedColor: Colors.teal,
                      onSelected: (_) => setState(() => _filterDifficulty = d),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final CrawlerProject project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = project.difficulty == '入门'
        ? Colors.green
        : project.difficulty == '中级'
            ? Colors.orange
            : Colors.red;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: project.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(project.icon, color: project.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project.difficulty,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: difficultyColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: project.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: project.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(t, style: TextStyle(fontSize: 11, color: project.color)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
