import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// SharedPreferences 模拟演示：可视化 K-V 存储的读写删操作
class _SharedPrefsSimDemo extends StatefulWidget {
  const _SharedPrefsSimDemo();
  @override
  State<_SharedPrefsSimDemo> createState() => _SharedPrefsSimDemoState();
}

class _SharedPrefsSimDemoState extends State<_SharedPrefsSimDemo> {
  final Map<String, dynamic> _store = {'isDarkMode': false, 'username': '张三', 'loginCount': 3};
  String _key = 'username';
  String _value = '';
  String _type = 'String';
  String _lastOp = '';

  static const _typeOptions = ['String', 'int', 'bool', 'double'];

  dynamic get _parsedValue {
    switch (_type) {
      case 'int': return int.tryParse(_value) ?? 0;
      case 'bool': return _value.toLowerCase() == 'true';
      case 'double': return double.tryParse(_value) ?? 0.0;
      default: return _value;
    }
  }

  void _write() {
    if (_key.isEmpty) return;
    setState(() {
      _store[_key] = _parsedValue;
      _lastOp = '✅ set$_type("$_key", ${_parsedValue.toString()})';
    });
  }

  void _read() {
    if (!_store.containsKey(_key)) {
      setState(() => _lastOp = '⚠️ "$_key" 不存在，返回 null');
      return;
    }
    final v = _store[_key];
    setState(() => _lastOp = '📖 get${v.runtimeType}("$_key") = $v');
  }

  void _delete() {
    if (_store.containsKey(_key)) {
      setState(() {
        _store.remove(_key);
        _lastOp = '🗑️ remove("$_key") 成功';
      });
    } else {
      setState(() => _lastOp = '⚠️ "$_key" 不存在');
    }
  }

  Color _typeColor(dynamic v) {
    if (v is bool) return Colors.orange;
    if (v is int) return Colors.blue;
    if (v is double) return Colors.teal;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🗄️ SharedPreferences 模拟演示',
      subtitle: '模拟 SharedPreferences 的读写删操作，观察 Key-Value 存储的实时变化',
      children: [
        // 当前存储内容
        const Text('当前存储内容:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        if (_store.isEmpty)
          const Center(child: Text('（空）', style: TextStyle(color: Colors.grey)))
        else
          Wrap(spacing: 6, runSpacing: 6, children: _store.entries.map((e) {
            final color = _typeColor(e.value);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.3))),
              child: Text('"${e.key}": ${e.value} (${e.value.runtimeType})',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: color)),
            );
          }).toList()),
        const SizedBox(height: 10),
        // 操作区域
        Row(children: [
          Expanded(child: TextField(
            decoration: const InputDecoration(labelText: 'Key', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)),
            onChanged: (v) => setState(() => _key = v),
            controller: TextEditingController(text: _key)..selection = TextSelection.fromPosition(TextPosition(offset: _key.length)),
          )),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)),
            onChanged: (v) => setState(() => _value = v),
          )),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _type, items: _typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            isDense: true,
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton(onPressed: _write, child: const Text('set (写入)')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: _read, child: const Text('get (读取)')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: _delete,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('remove (删除)')),
        ]),
        if (_lastOp.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
            child: Text(_lastOp, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
          ),
        ],
        LiveOutputBox('存储条目数: ${_store.length}\n键: ${_store.keys.join(', ')}\n上次操作: ${_lastOp.isEmpty ? '(无)' : _lastOp}'),
      ],
    );
  }
}

/// ============================================================
/// Flutter 教程 · 第七章：数据存储完全指南
/// 从简单的 Key-Value 到关系型数据库的完整存储方案
/// 涵盖：SharedPreferences、Hive、sqflite、SecureStorage、
///       File I/O、文件选择器、缓存策略、存储安全
/// ============================================================

class StorageDemo extends StatefulWidget {
  const StorageDemo({super.key});
  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  String _name = '';
  int _age = 0;
  final _nameCtl = TextEditingController();
  final _ageCtl = TextEditingController();

  @override
  void dispose() { _nameCtl.dispose(); _ageCtl.dispose(); super.dispose(); }

  void _save() {
    setState(() { _name = _nameCtl.text; _age = int.tryParse(_ageCtl.text) ?? 0; });
    _snack('数据已保存！');
  }

  void _load() {
    if (_name.isEmpty && _age == 0) { _snack('暂无数据'); return; }
    _nameCtl.text = _name; _ageCtl.text = _age.toString();
    _snack('数据已加载！');
  }

  void _delete() {
    setState(() { _name = ''; _age = 0; _nameCtl.clear(); _ageCtl.clear(); });
    _snack('数据已清除！');
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第7章 · 数据存储'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 存储方案全景对比\n'
            '② SharedPreferences —— 轻量键值存储\n'
            '③ flutter_secure_storage —— 加密存储\n'
            '④ Hive —— 高性能 NoSQL 数据库\n'
            '⑤ sqflite —— SQL 关系型数据库\n'
            '⑥ File I/O —— 文件读写\n'
            '⑦ 文件选择器：image_picker / file_picker\n'
            '⑧ 存储方案决策树\n'
            '⑨ 多级缓存架构\n'
            '⑩ 数据迁移与版本管理',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. 存储方案全景对比
          // ════════════════════════════════════════════════
          const SectionHeader('1. 六大存储方案全景对比', icon: Icons.compare),
          const Paragraph(
            'Flutter 提供多种数据存储方案，每种方案各有所长。选择合适的存储方案是 App 架构的关键决策。\n\n'
            '三大维度对比：\n'
            '① 数据类型：简单值 vs 结构化对象 vs 文件/二进制\n'
            '② 安全性：明文 vs 加密\n'
            '③ 查询能力：键值查询 vs 条件查询 vs 无查询',
          ),
          const CodeBlock(
            '┌──────────────────────┬──────────┬──────────┬───────────┬────────────┐\n'
            '│      方案            │  类型    │  速度     │  安全性   │  适合场景   │\n'
            '├──────────────────────┼──────────┼──────────┼───────────┼────────────┤\n'
            '│ SharedPreferences    │ 键值对   │  ★★★★    │ 明文      │ 配置项      │\n'
            '│ flutter_sec_storage  │ 加密KV   │  ★★★     │ 加密      │ 令牌/密码   │\n'
            '│ Hive                │ NoSQL    │  ★★★★★   │ 可选加密   │ 结构化数据  │\n'
            '│ sqflite             │ SQL      │  ★★★     │ 明文      │ 复杂关系    │\n'
            '│ File I/O            │ 二进制   │  ★★      │ 可选加密   │ 大文件      │\n'
            '│ image/file_picker   │ 文件选择 │  N/A     │ N/A       │ 图片/文档   │\n'
            '└──────────────────────┴──────────┴──────────┴───────────┴────────────┘',
            language: 'Text',
          ),
          const TipBox('没有"最好"的存储方案。生产项目通常混合使用多个方案：SP 存配置、Hive 存缓存、sqflite 存数据、SecureStorage 存令牌。', type: TipType.info),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 2. SharedPreferences
          // ════════════════════════════════════════════════
          const SectionHeader('2. SharedPreferences（SP）', icon: Icons.vpn_key),
          const Paragraph(
            'SharedPreferences 是最简单的本地存储方案。类似浏览器的 localStorage，以 Key-Value 方式存储简单类型。\n\n'
            '支持的数据类型：String、int、double、bool、List<String>\n'
            '不支持的类型：Map、自定义对象（需序列化为 String）\n\n'
            '底层原理：\n'
            '• Android：存储在 /data/data/包名/shared_prefs/ 下的 XML 文件\n'
            '• iOS：存储在 NSUserDefaults\n'
            '• 所有数据在初始化时加载到内存 → 读取很快\n'
            '• 每次 set 立即写回磁盘 → 频繁写入影响性能',
          ),
          const CodeBlock(
            r'''final prefs = await SharedPreferences.getInstance();

// ─ 写入 ─
await prefs.setString('username', '张三');
await prefs.setInt('age', 25);
await prefs.setBool('isFirstLaunch', false);
await prefs.setDouble('score', 98.5);
await prefs.setStringList('tags', ['flutter', 'dart']);

// ─ 读取 ─
final name = prefs.getString('username') ?? '';     // 必须加默认值！
final age = prefs.getInt('age') ?? 0;
final isFirst = prefs.getBool('isFirstLaunch') ?? false;
final score = prefs.getDouble('score') ?? 0.0;
final tags = prefs.getStringList('tags') ?? [];

// ─ 删除 ─
await prefs.remove('username');              // 删除单个
await prefs.clear();                         // 清空所有
final exists = prefs.containsKey('age');     // 检查是否存在

// ─ 批量操作（减少磁盘写入次数）──
final keysToRemove = {'temp1', 'temp2'};
// 没有原生的批量删除，需逐一 remove''',
            language: 'Dart',
          ),
          const Paragraph(
            'SharedPreferences 的最佳实践：\n'
            '① 始终提供默认值（?? defaultValue）—— 首次运行时值为 null\n'
            '② 用常量管理 key 名——避免拼写错误\n'
            '③ 不要存大量数据——每次启动全部加载到内存\n'
            '④ 不要存敏感信息——存储是明文的！',
          ),
          const TipBox('重要：SharedPreferences 的 set 方法是同步写入磁盘的（Android 9+ 例外）。频繁调用 set 会卡 UI。建议用批量写入或在后台线程操作。', type: TipType.caution),
          // ─ 交互演示 ─
          const SectionHeader('🧪 模拟 SharedPreferences 操作', icon: Icons.touch_app),
          const SizedBox(height: 8),
          TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 12),
          TextField(controller: _ageCtl, decoration: const InputDecoration(labelText: '年龄', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('保存')),
            const SizedBox(width: 8),
            ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.download), label: const Text('加载')),
            const SizedBox(width: 8),
            ElevatedButton.icon(onPressed: _delete, icon: const Icon(Icons.delete), label: const Text('删除'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
          ]),
          const SizedBox(height: 8),
          Container(width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: Text("用户名: ${_name.isEmpty ? "(空)" : _name}\n年龄: ${_age == 0 ? "(空)" : _age}",
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.greenAccent, height: 1.5)),
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 3. flutter_secure_storage
          // ════════════════════════════════════════════════
          const SectionHeader('3. flutter_secure_storage —— 加密存储', icon: Icons.lock),
          const Paragraph(
            '用于存储 JWT 令牌、密码、API Key 等敏感信息。\n\n'
            '底层原理：\n'
            '• Android：EncryptedSharedPreferences（AES-256 加密）或用 Android Keystore\n'
            '• iOS：Keychain（系统级安全存储，硬件安全模块）\n'
            '• macOS：Keychain\n'
            '• Windows：DPAPI\n'
            '• Web：Credential Management API\n\n'
            '重要限制：\n'
            '• 仅支持 String 类型（其他类型需序列化）\n'
            '• 写入比 SharedPreferences 慢（加密开销）\n'
            '• iOS Keychain 卸载 App 后可能残留数据',
          ),
          const CodeBlock(
            r'''final storage = const FlutterSecureStorage();

// ─ 写入 ─
await storage.write(key: 'jwt_token', value: 'eyJhbGciOiJIUzI1NiIs...');
await storage.write(key: 'api_key', value: 'sk_live_abc123...');

// ─ 读取 ─
final token = await storage.read(key: 'jwt_token') ?? '';
final apiKey = await storage.read(key: 'api_key') ?? '';

// ─ 读取所有 ─
final all = await storage.readAll();  // Map<String, String>

// ─ 删除 ─
await storage.delete(key: 'jwt_token');
await storage.deleteAll();

// ─ 检查 ─
final hasToken = await storage.containsKey(key: 'jwt_token');

// ─ iOS 高级配置 ─
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,  // 使用加密 SP，非必需
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    // 首次解锁后可访问。其他选项：
    // first_unlock — 重启后首次解锁
    // when_unlocked — 仅解锁时
    // always — 始终可访问（最不安全）
  ),
);''',
            language: 'Dart',
          ),
          const TipBox('绝对不要用 SharedPreferences 存密码或令牌！root/越狱设备可直接读取 XML 文件。SecureStorage 虽然保安全但仍有被破解风险——生产环境最好配合后端加密。', type: TipType.caution),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 4. Hive
          // ════════════════════════════════════════════════
          const SectionHeader('4. Hive —— 高性能 NoSQL 数据库', icon: Icons.storage),
          const Paragraph(
            'Hive 是纯 Dart 实现的轻量级数据库，专为 Flutter 优化。无需原生配置，读写在内存中完成。\n\n'
            '核心概念：\n'
            '• Box —— 类似"文件夹"或"表"，存一组键值对\n'
            '• TypeAdapter —— 自定义对象的序列化/反序列化器\n'
            '• HiveObject —— 内置 isInBox 等便捷方法的对象基类\n'
            '• LazyBox —— 大数据集的按需加载版本\n\n'
            'Hive 的优势：\n'
            '① 极快——所有数据在内存中，写入性能远超 sqflite\n'
            '② 纯 Dart——无需任何原生依赖，跨平台统一\n'
            '③ 内置加密——AES-256 CBC 模式\n'
            '④ 支持流式监听——box.listenable()\n'
            '⑤ 支持索引和复合键',
          ),
          const CodeBlock(
            r'''// ─ 初始化 ─
await Hive.initFlutter();  // 或 Hive.init(path) 自定义路径
await Hive.openBox('settings');

// ─ 基础 CRUD ─
final box = Hive.box('settings');
await box.put('theme', 'dark');           // 创建/更新
final theme = box.get('theme');           // 读取
await box.putAt(0, 'theme', 'light');    // 按索引更新
await box.delete('theme');                // 删除
await box.clear();                        // 清空

// ─ 批量操作 ─
await box.putAll({'name': '张三', 'age': 25});

// ─ 监听 ─
box.listenable().addListener(() {
  print('Box 数据变化！');
});

// ─ TypeAdapter（自定义对象）──
@HiveType(typeId: 0)
class Person {
  @HiveField(0) String name;
  @HiveField(1) int age;
  Person({required this.name, required this.age});
}

// 注册 Adapter（在 main 中，打开 Box 之前）
Hive.registerAdapter(PersonAdapter());
final personBox = await Hive.openBox<Person>('people');
await personBox.put('me', Person(name: '张三', age: 25));
final me = personBox.get('me');  // Person 类型

// ─ 加密 Box ─
final encryptionKey = Hive.generateSecureKey();
final encryptedBox = await Hive.openBox('secrets',
  encryptionCipher: HiveAesCipher(encryptionKey),
);''',
            language: 'Dart',
          ),
          const TipBox('Hive 数据在内存中。大量数据用 LazyBox（openLazyBox）避免 OOM。TypeAdapter 的类型 ID 一旦发布不可修改。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 5. sqflite
          // ════════════════════════════════════════════════
          const SectionHeader('5. sqflite —— SQL 关系型数据库', icon: Icons.table_chart),
          const Paragraph(
            '当数据需要复杂查询、关联、排序、分页时，关系型数据库是最佳选择。sqflite 是 Flutter 中最常用的 SQLite 封装。\n\n'
            '适用场景：\n'
            '• 通讯录（条件搜索 + 排序 + 分页）\n'
            '• 聊天记录（按时间查询 + 关联用户表）\n'
            '• 商品列表（多条件筛选 + 分类分组）\n'
            '• 任何需要 WHERE / JOIN / ORDER BY / LIMIT 的场景\n\n'
            '约束与限制：\n'
            '• 需要写 SQL 语句\n'
            '• 数据库迁移需要手动管理版本号\n'
            '• 性能劣于 Hive（磁盘读取）\n'
            '• 不支持 Web 平台（Web 用 drift 或 sqflite_common_ffi_web）',
          ),
          const CodeBlock(
            r"""// ─ 打开数据库 ─
final dbPath = join(await getDatabasesPath(), 'app.db');
final db = await openDatabase(
  dbPath,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        age INTEGER,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');
    // 初始数据
    await db.insert('users', {'name': 'Admin', 'email': 'admin@test.com', 'age': 30});
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion == 1) {
      await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
    }
    if (oldVersion == 2) {
      await db.execute('CREATE TABLE posts(id INTEGER PRIMARY KEY, title TEXT, user_id INTEGER, FOREIGN KEY(user_id) REFERENCES users(id))');
    }
  },
  version: 3,
);

// ─ CRUD ─
// Create
int id = await db.insert('users', {'name': '张三', 'age': 25});

// Read
List<Map> users = await db.query('users',
  where: 'age > ? AND name LIKE ?',
  whereArgs: [18, '%张%'],
  orderBy: 'age DESC',
  limit: 10,
  offset: 0,
);

// Update
await db.update('users', {'age': 26}, where: 'id = ?', whereArgs: [id]);

// Delete
await db.delete('users', where: 'id = ?', whereArgs: [id]);

// ─ 事务 ─
await db.transaction((txn) async {
  await txn.insert('users', {...});
  await txn.insert('profiles', {'user_id': id, ...});
});

// ─ 原始 SQL ─
final result = await db.rawQuery('SELECT * FROM users WHERE age > ?', [18]);
await db.rawInsert('INSERT INTO users(name, age) VALUES(?, ?)', ['李四', 30]);

// ─ 关闭 ─
await db.close();""",
            language: 'Dart',
          ),
          const TipBox('whereArgs 使用 ? 占位符防 SQL 注入，切忌字符串拼接。数据库迁移时 version 只能增加不能减少。改表结构 = version+1 + onUpgrade。', type: TipType.warning),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 6. File I/O
          // ════════════════════════════════════════════════
          const SectionHeader('6. File I/O —— 文件读写', icon: Icons.description),
          const Paragraph(
            'dart:io 的 File 类 + path_provider 包提供了完整的文件操作能力。\n\n'
            '关键目录（通过 path_provider 获取）：\n'
            '• getApplicationDocumentsDirectory() —— 用户文档目录（重要数据，iCloud 同步）\n'
            '• getApplicationSupportDirectory() —— 应用支持目录（数据不 iCloud 同步）\n'
            '• getTemporaryDirectory() —— 临时目录（系统可能随时清理）\n'
            '• getExternalStorageDirectory() —— 外部存储（Android 专有）\n\n'
            'File I/O 的特点：\n'
            '• 可以存任意格式：文本、JSON、二进制（图片/视频）\n'
            '• 需要手动管理序列化/反序列化\n'
            '• 无查询功能——不适合需要搜索的场景',
          ),
          const CodeBlock(
            r'''// ─ 文本读写 ─
final docDir = await getApplicationDocumentsDirectory();
final file = File('${docDir.path}/notes.txt');

// 覆盖写入
await file.writeAsString('Hello Flutter!');
// 追加写入
await file.writeAsString('\n第二行', mode: FileMode.append);
// 读取
final content = await file.readAsString();
// 按行读取
final lines = await file.readAsLines();

// ─ 二进制读写（图片/视频）──
final imageFile = File('${docDir.path}/photo.jpg');
await imageFile.writeAsBytes(imageBytes);
final bytes = await imageFile.readAsBytes();

// ─ 文件信息 ─
final exists = await file.exists();     // 是否存在
final size = await file.length();       // 文件大小（字节）
final modified = await file.lastModified(); // 最后修改时间

// ─ 目录操作 ─
final dir = Directory('${docDir.path}/data');
await dir.create(recursive: true);       // 创建目录（含父目录）
final files = dir.listSync();            // 列出内容
await dir.exists();                      // 目录是否存在

// ─ 删除 ─
await file.delete();
await dir.delete(recursive: true);       // 递归删除

// ─ 流式操作（大文件）──
final sink = file.openWrite(mode: FileMode.append);
sink.write('第一行\n');
sink.writeln('第二行');
await sink.close();''',
            language: 'Dart',
          ),
          const TipBox('getApplicationDocumentsDirectory 的数据在卸载 App 时删除。Android 11+ 注意 Scoped Storage 限制。', type: TipType.info),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 7. 文件选择器
          // ════════════════════════════════════════════════
          const SectionHeader('7. image_picker / file_picker', icon: Icons.photo_library),
          const Paragraph('用户选择文件或拍照后，获取文件路径再用 File I/O 读写。'),
          const CodeBlock(
            r'''// ─ image_picker ─
final picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,      // 或 ImageSource.camera
  maxWidth: 1080,                   // 限制最大宽度（压缩）
  maxHeight: 1080,
  imageQuality: 85,                 // 0-100
);
if (image != null) {
  final bytes = await image.readAsBytes();
  final path = image.path;
}

// ─ file_picker ─
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'png'],
  allowMultiple: true,              // 多选
);
if (result != null) {
  for (final file in result.files) {
    print('${file.name} — ${file.size} bytes');
    final path = file.path;         // 本地路径
    final bytes = file.bytes;       // 或直接读字节
  }
}''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 8. 决策树 + 综合示例
          // ════════════════════════════════════════════════
          const SectionHeader('8. 存储方案决策树', icon: Icons.help_outline),
          const Paragraph(
            '按以下决策树选择最合适的存储方案：\n\n'
            '是敏感信息（Token/密码）？→ flutter_secure_storage\n'
            '否 → 是简单配置（几个键值对）？→ SharedPreferences\n'
            '否 → 需要复杂查询（WHERE/JOIN/ORDER）？→ sqflite\n'
            '否 → 结构化数据但不需要查询？→ Hive\n'
            '否 → 文件/图片/大二进制？→ File I/O\n\n'
            '生产项目常见"多级缓存"架构：\n'
            '内存缓存（最快，自动过期）→ Hive/sqflite（本地持久化）→ 后端 API（云端数据源）',
          ),
          const CodeBlock(
            r'''// ─ 综合示例：混合使用多种存储 ─
class AppStorage {
  /// 配置项 → SharedPreferences
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  /// 令牌 → SecureStorage
  static Future<String?> getToken() async {
    return await const FlutterSecureStorage().read(key: 'jwt');
  }

  /// 缓存 → Hive（快速读写）
  static Future<void> cachePosts(List<Post> posts) async {
    final box = await Hive.openBox<Post>('cache');
    await box.putAll({for (final p in posts) p.id.toString(): p});
  }

  /// 聊天记录 → sqflite（复杂查询）
  static Future<List<Message>> searchMessages(String keyword) async {
    final db = await openDatabase(...);
    return (await db.rawQuery(
      'SELECT * FROM messages WHERE content LIKE ? ORDER BY created_at DESC',
      ['%$keyword%'],
    )).map((m) => Message.fromMap(m)).toList();
  }
}''',
            language: 'Dart',
          ),

          const _SharedPrefsSimDemo(),
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 SharedPreferences 实现"记住登录状态"——启动时检查 isLogin\n'
            '2. 用 Hive 存待办事项列表（ToDo 模型 + TypeAdapter，支持增删改）\n'
            '3. 用 sqflite 创建通讯录（按姓名模糊搜索、按年龄排序、分页加载）\n'
            '4. 用 flutter_secure_storage 存 API Key，请求时自动附加到 Header\n'
            '5. 用 path_provider + File I/O 实现日志记录器，每次运行追加一行\n'
            '6. 实现多级缓存：先从 Hive 读 → 展示 → 网络更新 → 写回 Hive',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
