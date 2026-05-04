import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================
/// Public API 详情页面
/// 展示单个 API 的详细信息、认证方式、HTTPS/CORS支持
/// 支持一键跳转到官方文档
/// ============================================================

class PublicApisDetailPage extends StatelessWidget {
  final String name;
  final String url;
  final String description;
  final String auth;
  final bool https;
  final String cors;
  final String categoryName;

  const PublicApisDetailPage({
    super.key,
    required this.name,
    required this.url,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    required this.categoryName,
  });

  String get _authLabel {
    switch (auth) {
      case 'apiKey': return 'API Key';
      case 'OAuth': return 'OAuth';
      default: return '无需认证';
    }
  }

  Color get _authColor {
    switch (auth) {
      case 'apiKey': return Colors.orange;
      case 'OAuth': return Colors.red;
      default: return Colors.green;
    }
  }

  IconData get _authIcon {
    switch (auth) {
      case 'apiKey': return Icons.vpn_key;
      case 'OAuth': return Icons.lock;
      default: return Icons.public;
    }
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无效的URL')),
        );
      }
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法打开此链接')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: '在浏览器中打开',
            onPressed: () => _openUrl(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              children: [
                Icon(_authIcon, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(categoryName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('简介', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(description, style: const TextStyle(fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tech details
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('接口信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: '认证方式', child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_authIcon, color: _authColor, size: 18),
                      const SizedBox(width: 6),
                      Text(_authLabel, style: TextStyle(color: _authColor, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  )),
                  const Divider(height: 24),
                  _InfoRow(label: 'HTTPS', child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(https ? Icons.check_circle : Icons.warning, color: https ? Colors.green : Colors.red, size: 18),
                      const SizedBox(width: 6),
                      Text(https ? '支持 HTTPS' : '仅 HTTP', style: TextStyle(color: https ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  )),
                  const Divider(height: 24),
                  _InfoRow(label: 'CORS', child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cors == 'Yes' ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cors == 'Yes' ? '支持跨域' : cors == 'No' ? '不支持跨域' : '未确认',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cors == 'Yes' ? Colors.blue : Colors.grey),
                    ),
                  )),
                  const Divider(height: 24),
                  _InfoRow(label: '文档地址', child: InkWell(
                    onTap: () => _openUrl(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(url, style: TextStyle(fontSize: 13, color: Colors.blue.shade700, decoration: TextDecoration.underline), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick start guide
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.play_circle, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('快速开始', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(context, '1', '访问官方文档', '点击下方按钮跳转到 API 官方文档页面，了解完整的接口规范和使用说明。'),
                  _buildStep(context, '2', '获取认证凭证', _authLabel == '无需认证' ? '此 API 无需认证，可以直接调用。' : '根据文档指引注册账号并获取 $_authLabel。'),
                  _buildStep(context, '3', '阅读 API 文档', '了解可用的端点（Endpoint）、请求参数和响应格式。'),
                  _buildStep(context, '4', '编写请求代码', '使用你熟悉的编程语言发送 HTTP 请求调用 API。'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Open docs button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openUrl(context),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('打开官方文档', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Code example
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('示例代码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildCodeExample(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExample() {
    final authHeader = auth == 'apiKey'
        ? "    -H 'Authorization: Bearer YOUR_API_KEY' \\\n"
        : auth == 'OAuth'
            ? "    -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \\\n"
            : '';

    return SelectableText(
      'curl -X GET \\\n'
      '  "${_escapeCode(url)}/endpoint" \\\n'
      '$authHeader'
      '  -H "Accept: application/json"',
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Color(0xFFD4D4D4),
        height: 1.6,
      ),
    );
  }

  String _escapeCode(String s) => s.replaceAll('\$', '\\\$');
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ),
        Expanded(child: child),
      ],
    );
  }
}
