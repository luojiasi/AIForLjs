import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pinenacl/signing.dart';

/// QomoTech 授权密钥解码验证页面。
///
/// 输入由 generate-license.js 生成的 base64url 编码授权密钥，
/// 解码 JSON 信封并验证 Ed25519 签名，展示许可详情。
class QomoLicensePage extends StatefulWidget {
  const QomoLicensePage({super.key});

  @override
  State<QomoLicensePage> createState() => _QomoLicensePageState();
}

class _QomoLicensePageState extends State<QomoLicensePage> {
  final _controller = TextEditingController();

  Map<String, dynamic>? _payload;
  bool? _signatureValid;
  String? _error;
  bool _decoding = false;

  /// Ed25519 公钥（从 generate-license.js 的 PUBLIC KEY 中提取的原始 32 字节）。
  static const String _publicKeyBase64 =
      'dxADOg64EXyCwv3KF4lHPi19VRYhQEDqVwrcmcld8eU=';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decodeLicense() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() {
        _error = '请输入授权密钥';
        _payload = null;
        _signatureValid = null;
      });
      return;
    }

    setState(() {
      _decoding = true;
      _error = null;
      _payload = null;
      _signatureValid = null;
    });

    try {
      // 1. Base64url → 标准 Base64（替换 URL-safe 字符，补齐 padding）
      String normalized = key.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) normalized += '=';

      // 2. 解码 → JSON
      final decoded = base64Decode(normalized);
      final envelopeJson = utf8.decode(decoded);
      final envelope = jsonDecode(envelopeJson) as Map<String, dynamic>;

      final payload = envelope['payload'] as Map<String, dynamic>;
      final signatureBase64 = envelope['signature'] as String;

      // 3. 验证 Ed25519 签名
      final serialized = jsonEncode(payload);
      final verifyKey = VerifyKey.fromBase64(_publicKeyBase64);
      final sigBytes = base64Decode(signatureBase64);

      try {
        verifyKey.verify(
          signature: sigBytes,
          message: utf8.encode(serialized),
        );
        _signatureValid = true;
      } catch (_) {
        _signatureValid = false;
      }

      setState(() {
        _payload = payload;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '密钥格式无效：${e.toString()}';
        _payload = null;
        _signatureValid = null;
      });
    } finally {
      setState(() => _decoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qomo 许可证管理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_error != null) _buildErrorCard(theme),
            if (_payload != null) ...[
              _buildSignatureCard(),
              const SizedBox(height: 8),
              _buildLicenseInfoCard(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('授权密钥', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '请粘贴授权密钥...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _decoding ? null : _decodeLicense,
              icon: _decoding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.key),
              label: Text(_decoding ? '解码中...' : '解码验证'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureCard() {
    final valid = _signatureValid == true;
    return Card(
      color: valid ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              valid ? Icons.check_circle : Icons.cancel,
              color: valid ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              valid ? '签名验证通过' : '签名验证失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: valid ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfoCard(ThemeData theme) {
    final p = _payload!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('许可证信息', style: theme.textTheme.titleMedium),
            const Divider(),
            _detailRow('许可证 ID', p['licenseId']?.toString() ?? '-'),
            _detailRow('设备指纹', p['deviceFingerprint']?.toString() ?? '-'),
            _detailRow('有效天数', '${p['validDays']} 天'),
            _detailRow('签发时间', _formatTimestamp(p['issuedAt'])),
            _detailRow('到期时间', _formatExpiry(p['issuedAt'], p['validDays'])),
            _detailRow(
              '当前状态',
              _isExpired(p['issuedAt'], p['validDays']) ? '已过期' : '有效',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 辅助方法 ----

  static String _formatTimestamp(dynamic ts) {
    if (ts == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(_parseInt(ts));
    return _fmt(date);
  }

  static String _formatExpiry(dynamic issuedAt, dynamic validDays) {
    if (issuedAt == null || validDays == null) return '-';
    final date =
        DateTime.fromMillisecondsSinceEpoch(_parseInt(issuedAt))
            .add(Duration(days: _parseInt(validDays)));
    return _fmt(date);
  }

  static bool _isExpired(dynamic issuedAt, dynamic validDays) {
    if (issuedAt == null || validDays == null) return true;
    final expire =
        DateTime.fromMillisecondsSinceEpoch(_parseInt(issuedAt))
            .add(Duration(days: _parseInt(validDays)));
    return DateTime.now().isAfter(expire);
  }

  static int _parseInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  static String _fmt(DateTime d) =>
      '${d.year}-${_pad(d.month)}-${_pad(d.day)} '
      '${_pad(d.hour)}:${_pad(d.minute)}:${_pad(d.second)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
