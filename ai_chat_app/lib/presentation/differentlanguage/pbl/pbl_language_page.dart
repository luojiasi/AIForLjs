import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pbl_data.dart';

/// ============================================================
/// 单语言教程详情页面
/// 按子分类列出所有教程，支持展开/折叠和外部链接跳转
/// ============================================================

class PBLLanguagePage extends StatefulWidget {
  final String languageName;

  const PBLLanguagePage({super.key, required this.languageName});

  @override
  State<PBLLanguagePage> createState() => _PBLLanguagePageState();
}

class _PBLLanguagePageState extends State<PBLLanguagePage> {
  String _query = '';

  PBLLanguage? get _language {
    final decoded = Uri.decodeComponent(widget.languageName);
    try {
      return pblAllLanguages.firstWhere((l) => l.name == decoded);
    } catch (_) {
      return null;
    }
  }

  List<PBLSubCategory> _filteredSubs(PBLLanguage lang) {
    if (_query.isEmpty) return lang.subCategories;
    final q = _query.toLowerCase();
    return lang.subCategories
        .map((sc) => PBLSubCategory(
              sc.name,
              sc.tutorials.where((t) => t.title.toLowerCase().contains(q)).toList(),
            ))
        .where((sc) => sc.tutorials.isNotEmpty)
        .toList();
  }

  void _openTutorial(String title, String url, String languageName) {
    context.push(
      '/pbl/tutorial',
      extra: {
        'title': title,
        'url': url,
        'languageName': languageName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    if (lang == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('未找到')),
        body: const Center(child: Text('未找到该语言的教程数据')),
      );
    }

    final filtered = _filteredSubs(lang);
    final totalVisible = filtered.fold<int>(0, (sum, sc) => sum + sc.tutorials.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.name),
        centerTitle: true,
        bottom: lang.tutorialCount > 15
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '在当前语言中搜索...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _query = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha:0.4),
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
          // 统计header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: lang.color.withValues(alpha:0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lang.color.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(lang.icon, color: lang.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lang.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lang.subCategories.length} 个分类 · $totalVisible 个实战项目',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: lang.color,
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

          // 教程列表
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
                        color: lang.color,
                        onTap: (title, url, _) => _openTutorial(title, url, lang.name),
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
  final PBLSubCategory subCategory;
  final Color color;
  final void Function(String title, String url, String languageName) onTap;

  const _SubCategoryTile({
    required this.subCategory,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha:0.15),
          child: Text(
            '${subCategory.tutorials.length}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        title: Text(
          subCategory.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${subCategory.tutorials.length} 个教程',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: subCategory.tutorials.map((tutorial) {
          return ListTile(
            leading: const Icon(Icons.link, size: 18, color: Colors.blue),
            title: Text(
              tutorial.title,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.open_in_new, size: 16),
            dense: true,
            onTap: () => onTap(tutorial.title, tutorial.url, subCategory.name),
          );
        }).toList(),
      ),
    );
  }
}
