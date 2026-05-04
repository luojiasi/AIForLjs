import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'public_apis_data.dart';

/// ============================================================
/// Public APIs 分类详情页面
/// 展示某个分类下所有 API，支持搜索和详情跳转
/// ============================================================

class PublicApisCategoryPage extends StatefulWidget {
  final int categoryIndex;
  const PublicApisCategoryPage({super.key, required this.categoryIndex});

  @override
  State<PublicApisCategoryPage> createState() => _PublicApisCategoryPageState();
}

class _PublicApisCategoryPageState extends State<PublicApisCategoryPage> {
  String _query = '';

  PublicApisCategory? get _category {
    final idx = widget.categoryIndex;
    if (idx >= 0 && idx < publicApisCategories.length) return publicApisCategories[idx];
    return null;
  }

  List<PublicApi> get _filtered {
    final cat = _category;
    if (cat == null) return [];
    if (_query.isEmpty) return cat.apis;
    final q = _query.toLowerCase();
    return cat.apis.where((api) =>
      api.name.toLowerCase().contains(q) || api.description.toLowerCase().contains(q)
    ).toList();
  }

  void _openDetail(PublicApi api) {
    context.push(
      '/public_apis/detail',
      extra: {
        'name': api.name,
        'url': api.url,
        'description': api.description,
        'auth': api.auth,
        'https': api.https,
        'cors': api.cors,
        'categoryName': _category?.name ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = _category;
    if (cat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('未找到')),
        body: const Center(child: Text('未找到该分类数据')),
      );
    }

    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        centerTitle: true,
        bottom: cat.apis.length > 15
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '在当前分类中搜索...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _query = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: cat.color.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cat.color)),
                      const SizedBox(height: 4),
                      Text(cat.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${filtered.length} 个 API', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${filtered.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('无匹配结果', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final api = filtered[index];
                      return _ApiTile(
                        api: api,
                        color: cat.color,
                        onTap: () => _openDetail(api),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApiTile extends StatelessWidget {
  final PublicApi api;
  final Color color;
  final VoidCallback onTap;

  const _ApiTile({required this.api, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: api.authColor.withValues(alpha: 0.15),
          child: Icon(api.authIcon, color: api.authColor, size: 20),
        ),
        title: Text(api.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(api.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: [
                _Badge(label: api.authLabel, color: api.authColor),
                const SizedBox(width: 6),
                _Badge(label: api.https ? 'HTTPS' : 'HTTP', color: api.https ? Colors.green : Colors.red.shade300),
                const SizedBox(width: 6),
                _Badge(label: 'CORS: ${api.cors}', color: api.cors == 'Yes' ? Colors.blue : Colors.grey),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.open_in_new, size: 16),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
