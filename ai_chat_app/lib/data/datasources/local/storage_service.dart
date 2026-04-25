import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Local JSON file-based storage for conversations and messages.
class StorageService {
  Directory? _dataDir;

  Future<Directory> get dataDir async {
    _dataDir ??= await _initDataDir();
    return _dataDir!;
  }

  Future<Directory> _initDataDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'ai_chat_data'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<Map<String, dynamic>>> readAll(String fileName) async {
    final dir = await dataDir;
    final file = File(p.join(dir.path, fileName));
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final json = jsonDecode(content);
    return (json as List).cast<Map<String, dynamic>>();
  }

  Future<void> writeAll(String fileName, List<Map<String, dynamic>> data) async {
    final dir = await dataDir;
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> readOne(String fileName, String id) async {
    final all = await readAll(fileName);
    try {
      return all.firstWhere((item) => item['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insertOne(String fileName, Map<String, dynamic> item) async {
    final all = await readAll(fileName);
    all.add(item);
    await writeAll(fileName, all);
  }

  Future<void> updateOne(String fileName, String id, Map<String, dynamic> updates) async {
    final all = await readAll(fileName);
    final index = all.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      all[index] = {...all[index], ...updates};
      await writeAll(fileName, all);
    }
  }

  Future<void> deleteOne(String fileName, String id) async {
    final all = await readAll(fileName);
    all.removeWhere((item) => item['id'] == id);
    await writeAll(fileName, all);
  }
}
