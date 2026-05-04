import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'public_apis_data.dart';

/// ============================================================
/// Public APIs 主入口页面
/// 展示所有分类卡片，支持搜索
/// ============================================================

class PublicApisHome extends StatefulWidget {
  const PublicApisHome({super.key});

  @override
  State<PublicApisHome> createState() => _PublicApisHomeState();
}

class _PublicApisHomeState extends State<PublicApisHome> {
  String _query = '';

  List<PublicApisCategory> get _filtered {
    if (_query.isEmpty) return publicApisCategories;
    final q = _query.toLowerCase();
    return publicApisCategories.where((cat) {
      if (cat.name.toLowerCase().contains(q)) return true;
      if (cat.description.toLowerCase().contains(q)) return true;
      for (final api in cat.apis) {
        if (api.name.toLowerCase().contains(q)) return true;
        if (api.description.toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }

  int get _totalApis =>
      publicApisCategories.fold(0, (sum, cat) => sum + cat.apis.length);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public APIs'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索分类或API名称...',
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
                SliverToBoxAdapter(child: _StatsDashboard(categoryCount: publicApisCategories.length, apiCount: _totalApis)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '分类浏览',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = filtered[index];
                        final idx = publicApisCategories.indexOf(cat);
                        return _CategoryCard(
                          category: cat,
                          onTap: () => context.push('/public_apis/$idx'),
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
  final int apiCount;
  const _StatsDashboard({required this.categoryCount, required this.apiCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
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
                const Icon(Icons.api, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  '公共 API 权威合集 · 来自 GitHub public-apis',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(icon: Icons.category, label: '$categoryCount 分类', color: Colors.white),
                _StatItem(icon: Icons.link, label: '$apiCount API', color: Colors.white70),
              ],
            ),
          ],
        ),
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
  final PublicApisCategory category;
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
                    Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        _InfoChip(Icons.link, '${category.apis.length} API', category.color),
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
