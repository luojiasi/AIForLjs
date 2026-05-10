import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// A stored credential (API key, password, etc.).
class Credential {
  final String id;
  final String name;
  final String type; // 'apiKey', 'basicAuth', 'oauth2', 'custom'
  final Map<String, dynamic> data; // keys vary by type, e.g. {apiKey, username, password, token}

  Credential({
    required this.id,
    required this.name,
    required this.type,
    Map<String, dynamic>? data,
  }) : data = data ?? {};

  factory Credential.fromJson(Map<String, dynamic> json) => Credential(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'apiKey',
        data: json['data'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'data': data,
      };
}

/// Lightweight index entry for listing credentials.
class CredentialSummary {
  final String id;
  final String name;
  final String type;

  CredentialSummary({required this.id, required this.name, required this.type});

  factory CredentialSummary.fromJson(Map<String, dynamic> json) =>
      CredentialSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'apiKey',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type};
}

/// Encrypted persistence for credentials.
/// Uses XOR cipher + base64 — not military grade, but keeps plaintext off disk.
class CredentialService {
  static final CredentialService instance = CredentialService._();
  CredentialService._();

  String? _dir;
  List<CredentialSummary>? _indexCache;

  Future<String> get _baseDir async {
    if (_dir != null) return _dir!;
    final appDir = await getApplicationDocumentsDirectory();
    _dir = '${appDir.path}/simplen8n/credentials';
    await Directory(_dir!).create(recursive: true);
    return _dir!;
  }

  Future<String> get _indexPath async => '${await _baseDir}/index.json';

  // ---- Encryption helpers ----

  static const _key = 's8n';

  String _encrypt(String plain) {
    final bytes = utf8.encode(plain);
    final keyBytes = utf8.encode(_key);
    final encoded = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      encoded.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64.encode(encoded);
  }

  String _decrypt(String encoded) {
    final bytes = base64.decode(encoded);
    final keyBytes = utf8.encode(_key);
    final decoded = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      decoded.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return utf8.decode(decoded);
  }

  // ---- Index ----

  Future<List<CredentialSummary>> _loadIndex() async {
    try {
      final file = File(await _indexPath);
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CredentialSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveIndex(List<CredentialSummary> index) async {
    final file = File(await _indexPath);
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(index.map((e) => e.toJson()).toList()));
    _indexCache = index;
  }

  // ---- CRUD ----

  Future<List<CredentialSummary>> listSummaries() async {
    if (_indexCache != null) return _indexCache!;
    _indexCache = await _loadIndex();
    return _indexCache!;
  }

  Future<void> save(Credential cred) async {
    final dir = await _baseDir;
    final plain = const JsonEncoder.withIndent('  ').convert(cred.toJson());
    final encrypted = _encrypt(plain);
    await File('$dir/${cred.id}.json').writeAsString(encrypted);

    final index = await _loadIndex();
    index.removeWhere((e) => e.id == cred.id);
    index.add(CredentialSummary(id: cred.id, name: cred.name, type: cred.type));
    await _saveIndex(index);
  }

  Future<Credential?> load(String id) async {
    try {
      final file = File('${await _baseDir}/$id.json');
      if (!await file.exists()) return null;
      final encrypted = await file.readAsString();
      final plain = _decrypt(encrypted);
      return Credential.fromJson(jsonDecode(plain) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    final file = File('${await _baseDir}/$id.json');
    if (await file.exists()) await file.delete();
    final index = await _loadIndex();
    index.removeWhere((e) => e.id == id);
    await _saveIndex(index);
  }

  /// Pre-resolve all credential references and return a populated credential map.
  /// Call this once before execution.
  Future<Map<String, Map<String, dynamic>>> resolveAll(
      List<Map<String, dynamic>> nodeParametersList) async {
    final summaries = await listSummaries();
    final regex = RegExp(r'\{\{\s*\$credential\.(\w+)\.(\w+)\s*\}\}');
    final neededCreds = <String>{};

    for (final params in nodeParametersList) {
      for (final entry in params.entries) {
        if (entry.value is String) {
          for (final match in regex.allMatches(entry.value as String)) {
            neededCreds.add(match.group(1)!);
          }
        }
      }
    }

    final result = <String, Map<String, dynamic>>{};
    for (final name in neededCreds) {
      final summary = summaries.cast<CredentialSummary?>().firstWhere(
            (s) => s?.name == name,
            orElse: () => null,
          );
      if (summary != null) {
        final cred = await load(summary.id);
        if (cred != null) {
          result[name] = {'value': cred.data['apiKey'] ?? cred.data['token'] ?? cred.data['password'] ?? '', ...cred.data};
        }
      }
    }
    return result;
  }

  static String generateId() {
    final r = Random();
    return 'cred_${DateTime.now().millisecondsSinceEpoch}_${r.nextInt(9999)}';
  }
}
