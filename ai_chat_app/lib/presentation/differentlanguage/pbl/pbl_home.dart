import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pbl_data.dart';

/// ============================================================
/// Project-Based Learning 主入口页面
/// 展示所有语言分类卡片，支持搜索过滤、收藏、排序切换
/// ============================================================

class PBLHome extends StatefulWidget {
  const PBLHome({super.key});

  @override
  State<PBLHome> createState() => _PBLHomeState();
}

enum _SortMode { byCount, byName }

class _PBLHomeState extends State<PBLHome> {
  String _query = '';
  _SortMode _sortMode = _SortMode.byCount;
  int _favCount = 0;

  static const _favPrefix = 'pbl_fav_';

  @override
  void initState() {
    super.initState();
    _loadFavCount();
  }

  Future<void> _loadFavCount() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_favPrefix) && !k.endsWith('_title') && !k.endsWith('_lang'));
    if (mounted) setState(() => _favCount = keys.length);
  }

  List<PBLLanguage> get _filtered {
    var list = pblAllLanguages;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((lang) {
        if (lang.name.toLowerCase().contains(q)) return true;
        for (final sc in lang.subCategories) {
          for (final t in sc.tutorials) {
            if (t.title.toLowerCase().contains(q)) return true;
          }
        }
        return false;
      }).toList();
    }
    // Sort
    if (_sortMode == _SortMode.byCount) {
      list = List.of(list)..sort((a, b) => b.tutorialCount.compareTo(a.tutorialCount));
    } else {
      list = List.of(list)..sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  int get _totalTutorials =>
      pblAllLanguages.fold(0, (sum, lang) => sum + lang.tutorialCount);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('项目实战教程库'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索语言或教程名称...',
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
                // ── 统计仪表盘 ──
                SliverToBoxAdapter(
                  child: _StatsDashboard(
                    languageCount: pblAllLanguages.length,
                    tutorialCount: _totalTutorials,
                    favCount: _favCount,
                    sortMode: _sortMode,
                    onToggleSort: () {
                      setState(() {
                        _sortMode = _sortMode == _SortMode.byCount
                            ? _SortMode.byName
                            : _SortMode.byCount;
                      });
                    },
                    onViewFavs: () => context.push('/pbl/favorites').then((_) => _loadFavCount()),
                  ),
                ),

                // ── 语言网格 ──
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lang = filtered[index];
                        return _LanguageGridCard(
                          language: lang,
                          onTap: () => context.push('/pbl/${Uri.encodeComponent(lang.name)}').then((_) => _loadFavCount()),
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

// ────────────────── 统计仪表盘 ──────────────────

class _StatsDashboard extends StatelessWidget {
  final int languageCount;
  final int tutorialCount;
  final int favCount;
  final _SortMode sortMode;
  final VoidCallback onToggleSort;
  final VoidCallback onViewFavs;

  const _StatsDashboard({
    required this.languageCount,
    required this.tutorialCount,
    required this.favCount,
    required this.sortMode,
    required this.onToggleSort,
    required this.onViewFavs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatChip(icon: Icons.language, label: '$languageCount 种语言', color: Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _StatChip(icon: Icons.menu_book, label: '$tutorialCount 个教程', color: Colors.green)),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onViewFavs,
                  child: _StatChip(
                    icon: Icons.star,
                    label: '$favCount 收藏',
                    color: favCount > 0 ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 排序切换
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
                        sortMode == _SortMode.byCount ? '按教程数排序' : '按名称排序',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.swap_vert, size: 14, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (sortMode == _SortMode.byCount)
                Text('共 ${languageCount - (languageCount > 0 ? 0 : 0)} 种语言', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ────────────────── 语言网格卡片 ──────────────────

class _LanguageGridCard extends StatelessWidget {
  final PBLLanguage language;
  final VoidCallback onTap;

  const _LanguageGridCard({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: language.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(language.icon, color: language.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                language.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${language.tutorialCount} 个教程',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (language.subCategories.length > 1)
                Text(
                  '${language.subCategories.length} 个分类',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              const SizedBox(height: 4),
              // 进度条指示器
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: language.tutorialCount / 70),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 3,
                      backgroundColor: language.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(language.color.withValues(alpha: 0.5)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
