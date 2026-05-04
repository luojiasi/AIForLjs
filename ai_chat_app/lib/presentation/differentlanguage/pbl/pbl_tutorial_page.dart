import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// 教程详情页 — 内置预览 + 收藏系统 + 外部浏览器跳转
/// 支持：收藏/取消收藏/外部浏览器打开
/// ============================================================

class PBLTutorialPage extends StatefulWidget {
  final String title;
  final String url;
  final String languageName;

  const PBLTutorialPage({
    super.key,
    required this.title,
    required this.url,
    required this.languageName,
  });

  @override
  State<PBLTutorialPage> createState() => _PBLTutorialPageState();
}

class _PBLTutorialPageState extends State<PBLTutorialPage> {
  bool _isFavorited = false;
  String? _error;

  static const _favPrefix = 'pbl_fav_';

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isFavorited = prefs.getBool('$_favPrefix${widget.url}') ?? false);
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_favPrefix${widget.url}';
    final newState = !_isFavorited;
    if (newState) {
      await prefs.setBool(key, true);
      await prefs.setString('${key}_title', widget.title);
      await prefs.setString('${key}_lang', widget.languageName);
    } else {
      await prefs.remove(key);
      await prefs.remove('${key}_title');
      await prefs.remove('${key}_lang');
    }
    setState(() => _isFavorited = newState);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? '已添加到收藏' : '已取消收藏'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开外部浏览器')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.star : Icons.star_border,
              color: _isFavorited ? Colors.amber : null,
            ),
            tooltip: _isFavorited ? '取消收藏' : '收藏',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: '在浏览器中打开',
            onPressed: _openExternally,
          ),
        ],
      ),
      body: _error != null ? _buildErrorView() : _buildPreviewView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '无法加载页面',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                  onPressed: () => setState(() => _error = null),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('浏览器打开'),
                  onPressed: _openExternally,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.menu_book,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.languageName,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // URL 预览
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(
                widget.url,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '来自 GitHub 项目实战教程合集',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('在浏览器中打开教程'),
              onPressed: _openExternally,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: Icon(_isFavorited ? Icons.star : Icons.star_border),
              label: Text(_isFavorited ? '已收藏' : '收藏此教程'),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
