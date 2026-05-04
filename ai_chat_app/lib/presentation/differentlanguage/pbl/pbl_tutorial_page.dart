import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 教程学习页 — 内置 WebView 直接打开教程内容 + 收藏系统

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
  late final WebViewController _controller;
  bool _isFavorited = false;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String? _error;
  bool _canGoBack = false;
  bool _canGoForward = false;

  static const _favPrefix = 'pbl_fav_';

  bool get _webViewSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _initWebView();
  }

  void _initWebView() {
    if (!_webViewSupported) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress / 100.0);
            }
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 1;
              });
              _updateNavButtons();
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = '${error.description} (code: ${error.errorCode})';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _updateNavButtons() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    if (mounted) setState(() { _canGoBack = back; _canGoForward = forward; });
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
          _webViewSupported
              ? IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  tooltip: '在浏览器中打开',
                  onPressed: _openExternally,
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: _webViewSupported
          ? _buildWebView()
          : _buildDesktopFallback(),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        // 进度条
        if (_isLoading)
          LinearProgressIndicator(value: _loadingProgress > 0 ? _loadingProgress : null, minHeight: 2),
        // 导航按钮栏
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: '后退',
                onPressed: _canGoBack
                    ? () => _controller.goBack().then((_) => _updateNavButtons())
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: '前进',
                onPressed: _canGoForward
                    ? () => _controller.goForward().then((_) => _updateNavButtons())
                    : null,
              ),
              const Spacer(),
              Text(
                widget.languageName,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
                onPressed: () => _controller.reload(),
              ),
            ],
          ),
        ),
        // WebView
        Expanded(
          child: _error != null
              ? _buildErrorView()
              : WebViewWidget(controller: _controller),
        ),
      ],
    );
  }

  Widget _buildDesktopFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.menu_book, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.languageName, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSecondaryContainer)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              width: double.infinity,
              child: Text(widget.url, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 8),
            Text('桌面端使用系统浏览器打开教程', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('在浏览器中打开学习'),
              onPressed: _openExternally,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('无法加载页面', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                  onPressed: () {
                    setState(() { _error = null; _isLoading = true; });
                    _controller.reload();
                  },
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
}
