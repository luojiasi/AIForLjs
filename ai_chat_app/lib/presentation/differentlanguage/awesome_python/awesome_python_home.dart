import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'awesome_python_data.dart';

/// ============================================================
/// Awesome Python 主入口页面
/// 展示所有14大分类卡片，支持搜索和统计仪表盘
/// ============================================================

class AwesomePythonHome extends StatefulWidget {
  const AwesomePythonHome({super.key});

  @override
  State<AwesomePythonHome> createState() => _AwesomePythonHomeState();
}

enum _SortMode { byCount, byName }

class _AwesomePythonHomeState extends State<AwesomePythonHome> {
  String _query = '';
  _SortMode _sortMode = _SortMode.byCount;

  List<AwesomePythonCategory> get _filtered {
    var list = awesomePythonCategories;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((cat) {
        if (cat.name.toLowerCase().contains(q)) return true;
        if (cat.description.toLowerCase().contains(q)) return true;
        for (final sc in cat.subCategories) {
          if (sc.name.toLowerCase().contains(q)) return true;
          for (final lib in sc.libraries) {
            if (lib.name.toLowerCase().contains(q)) return true;
            if (lib.description.toLowerCase().contains(q)) return true;
          }
        }
        return false;
      }).toList();
    }
    if (_sortMode == _SortMode.byCount) {
      list = List.of(list)..sort((a, b) => b.libraryCount.compareTo(a.libraryCount));
    } else {
      list = List.of(list)..sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  int get _totalLibraries =>
      awesomePythonCategories.fold(0, (sum, cat) => sum + cat.libraryCount);

  int get _totalSubCategories =>
      awesomePythonCategories.fold(0, (sum, cat) => sum + cat.subCategories.length);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Python'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索分类、子分类或库名称...',
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
                SliverToBoxAdapter(
                  child: _StatsDashboard(
                    categoryCount: awesomePythonCategories.length,
                    libraryCount: _totalLibraries,
                    subCategoryCount: _totalSubCategories,
                    sortMode: _sortMode,
                    onToggleSort: () {
                      setState(() {
                        _sortMode = _sortMode == _SortMode.byCount
                            ? _SortMode.byName
                            : _SortMode.byCount;
                      });
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '分类浏览',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = filtered[index];
                        return _CategoryCard(
                          category: cat,
                          onTap: () => context.push(
                            '/awesome_python/${Uri.encodeComponent(cat.name)}',
                          ),
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
}

class _StatsDashboard extends StatelessWidget {
  final int categoryCount;
  final int libraryCount;
  final int subCategoryCount;
  final _SortMode sortMode;
  final VoidCallback onToggleSort;

  const _StatsDashboard({
    required this.categoryCount,
    required this.libraryCount,
    required this.subCategoryCount,
    required this.sortMode,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
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
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Python 最佳框架、库、工具和资源权威指南',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(icon: Icons.category, label: '$categoryCount 分类', color: Colors.white),
                    _StatItem(icon: Icons.folder, label: '$subCategoryCount 子分类', color: Colors.white70),
                    _StatItem(icon: Icons.code, label: '$libraryCount 库/工具', color: Colors.white60),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sort, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              InkWell(
                onTap: onToggleSort,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sortMode == _SortMode.byCount ? '按库数量排序' : '按名称排序',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ],
                  ),
                ),
              ),
            ],
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AwesomePythonCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

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
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, color: category.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoChip(Icons.folder, '${category.subCategories.length} 子分类', category.color),
                        const SizedBox(width: 12),
                        _InfoChip(Icons.code, '${category.libraryCount} 库', category.color),
                      ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}
