import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ============================================================
/// Awesome Python 库学习页
/// 内置 WebView 查看 GitHub 源码 + 详细学习内容
/// ============================================================

class AwesomePythonDetailPage extends StatefulWidget {
  final String name;
  final String url;
  final String description;
  final List<String> features;
  final String useCase;
  final String categoryName;

  const AwesomePythonDetailPage({
    super.key,
    required this.name,
    required this.url,
    required this.description,
    required this.features,
    required this.useCase,
    required this.categoryName,
  });

  @override
  State<AwesomePythonDetailPage> createState() => _AwesomePythonDetailPageState();
}

class _AwesomePythonDetailPageState extends State<AwesomePythonDetailPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String? _error;
  late TabController _tabController;

  bool get _webViewSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_webViewSupported) _initWebView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _loadingProgress = progress / 100.0);
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() { _isLoading = false; _loadingProgress = 1; });
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: '在浏览器中打开 GitHub',
            onPressed: _openExternally,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '学习内容'),
            Tab(text: 'GitHub 源码'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLearningContent(theme),
          _webViewSupported ? _buildWebView() : _buildDesktopFallback(),
        ],
      ),
    );
  }

  Widget _buildLearningContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.categoryName,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.code, color: Colors.white.withValues(alpha: 0.7), size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Features section
          Text(
            '核心特性',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(f, style: TextStyle(fontSize: 13, color: Colors.blue.shade800)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Use case section
          Text(
            '适用场景',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.green.shade600, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.useCase,
                    style: TextStyle(fontSize: 14, color: Colors.green.shade800, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // GitHub link section
          Text(
            '源码地址',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _openExternally,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.url,
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Learning tips
          Text(
            '学习建议',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LearningTip(
                  icon: Icons.book,
                  text: '阅读官方文档了解基本用法和API',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.code,
                  text: '查看GitHub上的示例代码和测试用例',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.build,
                  text: '动手创建一个小项目来实践核心功能',
                  color: Colors.amber.shade700,
                ),
                _LearningTip(
                  icon: Icons.people,
                  text: '参与社区讨论，阅读Issues和PR了解最佳实践',
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        if (_isLoading)
          LinearProgressIndicator(value: _loadingProgress > 0 ? _loadingProgress : null, minHeight: 2),
        Expanded(
          child: _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('加载失败: $_error', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                        onPressed: () {
                          setState(() { _error = null; _isLoading = true; });
                          _controller.reload();
                        },
                      ),
                    ],
                  ),
                )
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
              child: Icon(Icons.code, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('在桌面端使用系统浏览器查看 GitHub 源码', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(widget.url, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('在浏览器中打开 GitHub'),
              onPressed: _openExternally,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _LearningTip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.9), height: 1.4)),
          ),
        ],
      ),
    );
  }
}
