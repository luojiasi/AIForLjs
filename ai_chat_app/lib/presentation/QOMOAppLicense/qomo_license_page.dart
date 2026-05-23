import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinenacl/ed25519.dart';

/// QomoTech 授权密钥生成与验证页面。
///
/// 两种模式：
///   1. 生成模式 — 输入设备指纹 → 生成授权密钥
///   2. 验证模式 — 粘贴授权密钥 → 解码并验证 Ed25519 签名
class QomoLicensePage extends StatefulWidget {
  const QomoLicensePage({super.key});

  @override
  State<QomoLicensePage> createState() => _QomoLicensePageState();
}

class _QomoLicensePageState extends State<QomoLicensePage> {
  // ─── 模式切换 ────────────────────────────────────────
  bool _generateMode = true;

  // ─── 生成模式输入 ────────────────────────────────────
  final _fpc = TextEditingController(); // 设备指纹
  final _daysC = TextEditingController(text: '365'); // 有效天数
  final _lidC = TextEditingController(); // 许可证 ID（可选）

  // ─── 验证模式输入 ────────────────────────────────────
  final _keyC = TextEditingController();

  // ─── 结果 ────────────────────────────────────────────
  Map<String, dynamic>? _payload;
  bool? _signatureValid;
  String? _error;
  bool _working = false;
  String? _generatedKey;

  // ─── Ed25519 密钥材料 ────────────────────────────────
  static const String _publicKeyBase64 =
      'dxADOg64EXyCwv3KF4lHPi19VRYhQEDqVwrcmcld8eU=';
  static const String _privateKeySeedBase64 =
      'zu17Aqx32bmmPnXO937F4iKq8RVmkPAQ8qB6lF+bR7o=';

  @override
  void dispose() {
    _fpc.dispose();
    _daysC.dispose();
    _lidC.dispose();
    _keyC.dispose();
    super.dispose();
  }

  // ─── 生成授权密钥 ────────────────────────────────────
  Future<void> _generate() async {
    final fingerprint = _fpc.text.trim();
    if (fingerprint.isEmpty) {
      _setError('请输入设备指纹');
      return;
    }

    setState(() {
      _working = true;
      _error = null;
      _payload = null;
      _signatureValid = null;
      _generatedKey = null;
    });

    try {
      final days = int.tryParse(_daysC.text.trim()) ?? 365;
      final licenseId = _lidC.text.trim().isEmpty
          ? 'LIC-${DateTime.now().millisecondsSinceEpoch}'
          : _lidC.text.trim();

      // 1. 构建 payload
      final payload = <String, dynamic>{
        'licenseId': licenseId,
        'deviceFingerprint': fingerprint,
        'validDays': days,
        'issuedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // 2. 签名
      final serialized = jsonEncode(payload);
      final seed = base64Decode(_privateKeySeedBase64);
      final signingKey = SigningKey.fromSeed(seed);
      final signedMsg = signingKey.sign(utf8.encode(serialized));
      final sigBase64 = base64Encode(signedMsg.signature);

      // 3. 组装信封
      final envelope = <String, dynamic>{
        'payload': payload,
        'signature': sigBase64,
      };
      final envelopeJson = jsonEncode(envelope);
      final licenseKey =
          base64Url.encode(utf8.encode(envelopeJson)).replaceAll('=', '');

      // 4. 自验证
      final rawKey = base64Decode(_publicKeyBase64);
      final verifyKey = VerifyKey(rawKey);
      final sigBytes = base64Decode(sigBase64);
      final signature = Signature(sigBytes);
      final valid = verifyKey.verify(
        signature: signature,
        message: utf8.encode(serialized),
      );

      setState(() {
        _payload = payload;
        _signatureValid = valid;
        _generatedKey = licenseKey;
        _error = null;
      });
    } catch (e) {
      _setError('生成失败：${e.toString()}');
    } finally {
      setState(() => _working = false);
    }
  }

  // ─── 验证授权密钥 ────────────────────────────────────
  Future<void> _verify() async {
    final key = _keyC.text.trim();
    if (key.isEmpty) {
      _setError('请输入授权密钥');
      return;
    }

    setState(() {
      _working = true;
      _error = null;
      _payload = null;
      _signatureValid = null;
      _generatedKey = null;
    });

    try {
      // 1. 清理输入
      final clean = key.replaceAll(RegExp(r'[^A-Za-z0-9\-_+]'), '');
      // 2. Base64url → 标准 Base64
      String normalized = clean.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) normalized += '=';
      // 3. 解码
      final decoded = base64Decode(normalized);
      final envelopeJson = utf8.decode(decoded);
      final envelope = jsonDecode(envelopeJson) as Map<String, dynamic>;
      final payload = envelope['payload'] as Map<String, dynamic>;
      final signatureBase64 = envelope['signature'] as String;

      // 4. 验证签名
      final serialized = jsonEncode(payload);
      final rawKey = base64Decode(_publicKeyBase64);
      final verifyKey = VerifyKey(rawKey);
      final sigBytes = base64Decode(signatureBase64);
      final signature = Signature(sigBytes);
      final valid = verifyKey.verify(
        signature: signature,
        message: utf8.encode(serialized),
      );

      setState(() {
        _payload = payload;
        _signatureValid = valid;
        _error = null;
      });
    } catch (e) {
      _setError('密钥格式无效：${e.toString()}');
    } finally {
      setState(() => _working = false);
    }
  }

  void _setError(String msg) {
    setState(() {
      _error = msg;
      _payload = null;
      _signatureValid = null;
      _generatedKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Qomo 许可证管理')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeToggle(theme),
            const SizedBox(height: 16),
            if (_generateMode) _buildGeneratePanel() else _buildVerifyPanel(),
            const SizedBox(height: 16),
            if (_error != null) _buildErrorCard(theme),
            if (_generatedKey != null) _buildGeneratedResult(theme),
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

  Widget _buildModeToggle(ThemeData theme) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('生成授权密钥'), icon: Icon(Icons.add)),
        ButtonSegment(value: false, label: Text('验证授权密钥'), icon: Icon(Icons.verified)),
      ],
      selected: {_generateMode},
      onSelectionChanged: (v) => setState(() {
        _generateMode = v.first;
        _error = null;
        _payload = null;
        _signatureValid = null;
        _generatedKey = null;
      }),
    );
  }

  // ─── 生成面板 ────────────────────────────────────────
  Widget _buildGeneratePanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fpc,
              decoration: const InputDecoration(
                labelText: '设备指纹',
                hintText: '输入设备指纹（64位十六进制）',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _daysC,
                    decoration: const InputDecoration(
                      labelText: '有效天数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _lidC,
                    decoration: const InputDecoration(
                      labelText: '许可证 ID（可选，自动生成）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _working ? null : _generate,
              icon: _working
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.workspace_premium),
              label: Text(_working ? '生成中...' : '生成授权密钥'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 验证面板 ────────────────────────────────────────
  Widget _buildVerifyPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _keyC,
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
              onPressed: _working ? null : _verify,
              icon: _working
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.key),
              label: Text(_working ? '解码中...' : '解码验证'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 结果卡片 ────────────────────────────────────────
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
              child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedResult(ThemeData theme) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text('授权密钥已生成', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                  fontSize: 15,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedKey!,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: '复制到剪贴板',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedKey!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('密钥已复制到剪贴板'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
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
            _detailRow('当前状态', _isExpired(p['issuedAt'], p['validDays']) ? '已过期' : '有效'),
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
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ─── 辅助方法 ────────────────────────────────────────
  static String _formatTimestamp(dynamic ts) {
    if (ts == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(_parseInt(ts));
    return _fmt(date);
  }

  static String _formatExpiry(dynamic issuedAt, dynamic validDays) {
    if (issuedAt == null || validDays == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(_parseInt(issuedAt))
        .add(Duration(days: _parseInt(validDays)));
    return _fmt(date);
  }

  static bool _isExpired(dynamic issuedAt, dynamic validDays) {
    if (issuedAt == null || validDays == null) return true;
    final expire = DateTime.fromMillisecondsSinceEpoch(_parseInt(issuedAt))
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
