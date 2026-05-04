import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'awesome_python_data.dart';

/// ============================================================
/// Awesome Python 分类详情页面
/// 展示子分类和所有库，支持搜索、展开/折叠
/// ============================================================

class AwesomePythonCategoryPage extends StatefulWidget {
  final int categoryIndex;

  const AwesomePythonCategoryPage({super.key, required this.categoryIndex});

  @override
  State<AwesomePythonCategoryPage> createState() => _AwesomePythonCategoryPageState();
}

class _AwesomePythonCategoryPageState extends State<AwesomePythonCategoryPage> {
  String _query = '';

  AwesomePythonCategory? get _category {
    final idx = widget.categoryIndex;
    if (idx >= 0 && idx < awesomePythonCategories.length) {
      return awesomePythonCategories[idx];
    }
    return null;
  }

  List<AwesomePythonSubCategory> _filteredSubs(AwesomePythonCategory cat) {
    if (_query.isEmpty) return cat.subCategories;
    final q = _query.toLowerCase();
    return cat.subCategories
        .map((sc) => AwesomePythonSubCategory(
              sc.name,
              sc.libraries
                  .where((l) =>
                      l.name.toLowerCase().contains(q) ||
                      l.description.toLowerCase().contains(q))
                  .toList(),
            ))
        .where((sc) => sc.libraries.isNotEmpty)
        .toList();
  }

  void _openLibrary(AwesomePythonLibrary lib, String categoryName) {
    context.push(
      '/awesome_python/detail',
      extra: {
        'name': lib.name,
        'url': lib.url,
        'description': lib.description,
        'features': lib.features,
        'useCase': lib.useCase,
        'categoryName': categoryName,
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

    final filtered = _filteredSubs(cat);
    final totalVisible = filtered.fold<int>(0, (sum, sc) => sum + sc.libraries.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        centerTitle: true,
        bottom: cat.libraryCount > 20
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
                      Text(
                        cat.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cat.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cat.subCategories.length} 个子分类 · $totalVisible 个库/工具',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalVisible',
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
                      final sub = filtered[index];
                      return _SubCategoryTile(
                        subCategory: sub,
                        color: cat.color,
                        onTapLib: (lib) => _openLibrary(lib, cat.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryTile extends StatelessWidget {
  final AwesomePythonSubCategory subCategory;
  final Color color;
  final void Function(AwesomePythonLibrary lib) onTapLib;

  const _SubCategoryTile({
    required this.subCategory,
    required this.color,
    required this.onTapLib,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            '${subCategory.libraries.length}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        title: Text(
          subCategory.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${subCategory.libraries.length} 个库/工具',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: subCategory.libraries.map((lib) {
          return ListTile(
            leading: const Icon(Icons.link, size: 18, color: Colors.blue),
            title: Text(lib.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(
              lib.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.open_in_new, size: 16),
            dense: true,
            onTap: () => onTapLib(lib),
          );
        }).toList(),
      ),
    );
  }
}
