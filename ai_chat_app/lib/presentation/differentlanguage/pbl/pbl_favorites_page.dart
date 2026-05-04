import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// 收藏的教程页面 — 从 SharedPreferences 加载收藏列表
/// ============================================================

class PBLFavoritesPage extends StatefulWidget {
  const PBLFavoritesPage({super.key});

  @override
  State<PBLFavoritesPage> createState() => _PBLFavoritesPageState();
}

class _FavoriteEntry {
  final String url;
  final String title;
  final String languageName;
  const _FavoriteEntry(this.url, this.title, this.languageName);
}

class _PBLFavoritesPageState extends State<PBLFavoritesPage> {
  List<_FavoriteEntry> _favorites = [];

  static const _favPrefix = 'pbl_fav_';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_favPrefix) && !k.endsWith('_title') && !k.endsWith('_lang'));
    final entries = <_FavoriteEntry>[];
    for (final key in keys) {
      final title = prefs.getString('${key}_title') ?? 'Unknown';
      final lang = prefs.getString('${key}_lang') ?? '';
      // key is like 'pbl_fav_https://...'
      final url = key.substring(_favPrefix.length);
      entries.add(_FavoriteEntry(url, title, lang));
    }
    if (mounted) setState(() => _favorites = entries);
  }

  Future<void> _removeFavorite(_FavoriteEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_favPrefix${entry.url}';
    await prefs.remove(key);
    await prefs.remove('${key}_title');
    await prefs.remove('${key}_lang');
    setState(() => _favorites.removeWhere((e) => e.url == entry.url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已取消收藏: ${entry.title}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openTutorial(_FavoriteEntry entry) {
    context.push(
      '/pbl/tutorial',
      extra: {
        'title': entry.title,
        'url': entry.url,
        'languageName': entry.languageName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('还没有收藏任何教程', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('在教程详情页点击 ⭐ 即可收藏', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('浏览教程库'),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final entry = _favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withValues(alpha: 0.15),
                      child: const Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                    title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(entry.languageName, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          tooltip: '查看详情',
                          onPressed: () => _openTutorial(entry),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[300]),
                          tooltip: '取消收藏',
                          onPressed: () => _removeFavorite(entry),
                        ),
                      ],
                    ),
                    onTap: () => _openTutorial(entry),
                  ),
                );
              },
            ),
    );
  }
}
