import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第七章：数据存储 (Storage)
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
          const Paragraph('① SharedPreferences  ② flutter_secure_storage  ③ Hive  ④ sqflite  ⑤ File I/O  ⑥ 如何选择'),
          const DividerLine(),

          // ── 1. 概览 ──
          const SectionHeader('1. 六种存储方式概览', icon: Icons.compare),
          const Paragraph('🔹 SharedPreferences：键值对，适合配置项（主题、语言、登录状态）\n'
              '🔸 flutter_secure_storage：加密键值对，适合令牌、密码\n'
              '🔹 Hive：NoSQL 纯 Dart，适合结构化数据（购物车、收藏、草稿）\n'
              '🔸 sqflite：SQL 关系型，适合复杂查询（通讯录、聊天记录）\n'
              '🔹 File I/O：文件读写，适合大文件（图片、日志、导出数据）\n'
              '🔸 image_picker / file_picker：选择文件/拍照入库'),
          const Paragraph(
            '┌──────────────────────┬──────────┬──────────┬───────────┐\n'
            '│      方案           │   类型   │  速度    │  适合场景  │\n'
            '├──────────────────────┼──────────┼──────────┼───────────┤\n'
            '│ SharedPreferences   │ 键值对   │ ★★★★    │ 配置项     │\n'
            '│ flutter_sec_storage │ 加密KV   │ ★★★     │ 令牌/密码  │\n'
            '│ Hive                │ NoSQL    │ ★★★★★   │ 结构化数据 │\n'
            '│ sqflite             │ SQL      │ ★★★     │ 复杂关系   │\n'
            '│ File I/O            │ 二进制   │ ★★      │ 大文件     │\n'
            '└──────────────────────┴──────────┴──────────┴───────────┘',
          ),
          const TipBox('没有"最好"的存储方式。生产项目经常混合使用多种方案，根据数据类型选择最合适的工具。', type: TipType.info),

          const DividerLine(),

          // ── 2. SharedPreferences ──
          const SectionHeader('2. SharedPreferences', icon: Icons.vpn_key),
          const Paragraph('Key-Value 存储，类似浏览器 localStorage。支持 String/int/double/bool/List<String>。'),
          const CodeBlock(
            r'''final prefs = await SharedPreferences.getInstance();

// 写入
await prefs.setString('name', '张三');
await prefs.setInt('age', 18);
await prefs.setBool('isLogin', true);

// 读取（注意可空，加??默认值）
final name = prefs.getString('name') ?? '';
final age = prefs.getInt('age') ?? 0;
final isLogin = prefs.getBool('isLogin') ?? false;

// 删除与检查
await prefs.remove('name');
await prefs.clear();
final hasKey = prefs.containsKey('age');''',
            language: 'Dart'),
          const Paragraph('✅ API 极简 ❌ 仅支持简单类型，不适合大量数据。set 会同步写磁盘，频繁调用影响性能。'),
          const Paragraph('💡 监听变化：SharedPreferences 本身不提供流式监听，但可配合 ValueNotifier 包装后监听：\n'
              "final notifier = ValueNotifier(prefs.getString('key'));\n"
              '使用 notifier.addListener(...) 在值变化时刷新 UI。或使用 rx_shared_preferences 包。'),
          const TipBox('取值一定要加 ?? 默认值！否则第一次运行时返回 null。建议为每个 key 定义常量防拼写错误。', type: TipType.caution),

          // 交互演示
          const SectionHeader('🧪 模拟 SharedPreferences', icon: Icons.touch_app),
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

          // ── 3. flutter_secure_storage ──
          const SectionHeader('3. flutter_secure_storage —— 加密存储', icon: Icons.lock),
          const Paragraph('用于 JWT 令牌、密码、API Key 等敏感信息。底层使用 Android EncryptedSharedPreferences 和 iOS Keychain，'
              '数据写入时自动加密，读取时自动解密。仅支持 String 类型。'),
          const CodeBlock(
            r'''final storage = const FlutterSecureStorage();

await storage.write(key: 'jwt_token', value: 'eyJhbGci...');
final token = await storage.read(key: 'jwt_token') ?? '';
await storage.delete(key: 'jwt_token');
await storage.deleteAll();

// iOS 可选配置
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);''',
            language: 'Dart'),
          const Paragraph('✅ 数据自动加密 ❌ 仅支持 String，写入比 SP 稍慢（加解密开销）。'),
          const TipBox('不要用 SharedPreferences 存密码或令牌！root/越狱设备可读取明文 XML。', type: TipType.caution),

          const DividerLine(),

          // ── 4. Hive ──
          const SectionHeader('4. Hive —— NoSQL 数据库', icon: Icons.storage),
          const Paragraph('纯 Dart 实现，超快（内存缓存），无需原生配置。支持自定义对象（TypeAdapter）。'
              '适合：购物车、收藏、草稿等不需要复杂查询的结构化数据。'),
          const CodeBlock(
            r'''// 初始化 + 打开 Box
await Hive.initFlutter();
final box = await Hive.openBox('settings');

// CRUD
await box.put('name', '张三');       // 写入
final name = box.get('name');        // 读取
await box.putAt(0, '新值');          // 索引更新
await box.delete('name');            // 删除
await box.clear();                   // 清空

// 监听变化
box.listenable().addListener(() => print('数据变化'));

// ── TypeAdapter（自定义对象）──
@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0) late String name;
  @HiveField(1) late int age;
}
// 运行 build_runner 生成 adapter''',
            language: 'Dart'),
          const Paragraph('✅ 纯 Dart、速度快 ❌ 不支持复杂查询（无 WHERE/JOIN）。大数据集用 LazyBox 按需加载。'),
          const TipBox('Hive 的 Box 打开后加载到内存。大数据集用 LazyBox（openLazyBox）避免 OOM。', type: TipType.tip),

          const DividerLine(),

          // ── 5. sqflite ──
          const SectionHeader('5. sqflite —— SQL 关系型数据库', icon: Icons.table_chart),
          const Paragraph('需要按条件查询、关联表、排序分页时用 sqflite。基于 SQLite，一个 .db 文件包含多张表，支持外键、事务、迁移。'),
          const CodeBlock(
            r"""final db = await openDatabase(
  join(await getDatabasesPath(), 'app.db'),
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, age INTEGER
      )
    ''');
  },
  version: 1,
);

// CRUD
await db.insert('users', {'name': '张三', 'age': 18});
final users = await db.query('users',
  where: 'age > ? AND name LIKE ?',
  whereArgs: [18, '%张%'],
  orderBy: 'age DESC', limit: 10,
);
await db.update('users', {'age': 19}, where: 'id = ?', whereArgs: [1]);
await db.delete('users', where: 'id = ?', whereArgs: [1]);

// 事务
await db.transaction((txn) async { ... });

// 原始 SQL
final result = await db.rawQuery('SELECT * FROM users');
db.close();""",
            language: 'Dart'),
          const Paragraph('✅ 功能最强，支持复杂查询、事务、外键、索引、迁移 ❌ 需写 SQL，学习曲线稍陡。可用 floor/drift ORM 简化。'),
          const Paragraph('💡 数据库迁移：修改表结构时必须升级 version 并在 onUpgrade 中执行 ALTER TABLE。'
              '建议将每个版本的迁移语句写在版本号分支中，确保从任意旧版本升级路径正确。'),
          const TipBox('whereArgs 使用 ? 占位符防 SQL 注入，切忌用 where: age = \$age 拼接字符串。同时注意 db.close() 释放资源。', type: TipType.warning),

          const DividerLine(),

          // ── 6. File I/O ──
          const SectionHeader('6. File I/O —— 文件读写', icon: Icons.description),
          const Paragraph('dart:io File + path_provider 获取正确目录。适合：图片、日志、JSON/CSV 导出。'),
          const CodeBlock(
            r'''final docDir = await getApplicationDocumentsDirectory();
final tempDir = await getTemporaryDirectory();

// 文本读写
final file = File('${docDir.path}/notes.txt');
await file.writeAsString('你好');                  // 覆盖写入
await file.writeAsString('追加', mode: FileMode.append); // 追加
final content = await file.readAsString();          // 读取

// 二进制（图片等）
final bytes = await file.readAsBytes();
await file.writeAsBytes(bytes);

// 文件信息
final exists = await file.exists();
final size = await file.length();

// 目录操作
final dir = Directory('${docDir.path}/data');
await dir.create(recursive: true);
await dir.list().forEach((e) => print(e.path));

await file.delete();''',
            language: 'Dart'),
          const Paragraph('✅ 通用性强，适合任意数据类型 ❌ 需自行管理序列化，无查询功能。Android 11+ 注意 Scoped Storage。'),
          const TipBox('getApplicationDocumentsDirectory() 的数据在卸载 App 时删除。需备份的话使用外部存储或云服务。', type: TipType.info),

          const DividerLine(),

          // ── 7. 文件选择器 ──
          const SectionHeader('7. image_picker / file_picker', icon: Icons.photo_library),
          const Paragraph('image_picker：从相册选择或拍照。file_picker：选择任意类型文件。两者返回路径后可用 File I/O 读写。'),
          const CodeBlock(
            r'''// image_picker
final picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1080, imageQuality: 85,
);
final XFile? photo = await picker.pickImage(source: ImageSource.camera);
if (image != null) {
  final bytes = await image.readAsBytes();
  final path = image.path;
}

// file_picker
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'png'],
);
if (result != null) {
  for (final file in result.files) {
    print('${file.name} (${file.size} bytes)');
  }
}''',
            language: 'Dart'),
          const TipBox('选择图片后建议压缩：使用 imageQuality 参数或 flutter_image_compress 包，12MP 原图可压至 < 300KB。', type: TipType.tip),

          const DividerLine(),

          // ── 8. 决策指南 ──
          const SectionHeader('8. 存储方案决策指南', icon: Icons.help_outline),
          const Paragraph('几个配置项（主题、语言）→ SharedPreferences\n'
              'JWT Token / 密码 / 密钥 → flutter_secure_storage\n'
              '用户信息 / 购物车 / 收藏 → Hive（简单）或 sqflite（需要搜索）\n'
              '大量结构化数据 / 通讯录 / 聊天记录 → sqflite\n'
              '图片 / 文件 / 日志导出 → File I/O\n'
              '选择文件 / 拍照 → image_picker 或 file_picker + 上述存储\n'
              '需要云同步 / 多人协作 → Firebase Firestore / 后端 API + 本地缓存'),
          const Paragraph('💡 存储生命周期与清理：\n'
              '• SharedPreferences / Hive：随 App 卸载删除，无需手动清理\n'
              '• sqflite：数据库文件在 documents 目录，卸载时删除\n'
              '• File I/O 文件：需自行管理，定期清理缓存目录（getTemporaryDirectory()）\n'
              '• flutter_secure_storage：iOS 在 Keychain，卸载 App 后可能残留（需代码清除）\n'
              '建议在设置页提供「清除缓存」功能，删除临时文件和非必要数据。'),
          const TipBox('生产项目常见"多级缓存"策略：内存缓存（快速响应） + Hive/sqflite（本地持久化） + 后端 API（云端同步）。每层各司其职。', type: TipType.info),

          const DividerLine(),

          // ── 9. 综合示例 ──
          const SectionHeader('🛠️ 综合示例：多存储混合使用', icon: Icons.build),
          const Paragraph('实际项目中通常组合多种存储方式。下面展示一个混合使用的 SettingsManager：'),
          const CodeBlock(
            r'''class SettingsManager {
  /// 主题（纯配置 → SharedPreferences）
  static Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeMode.values[prefs.getInt('theme') ?? 0];
  }

  /// JWT 令牌（敏感 → flutter_secure_storage）
  static Future<String?> getToken() async {
    return await const FlutterSecureStorage().read(key: 'jwt');
  }

  /// 用户草稿（结构化 → Hive）
  static Future<void> saveDraft(Draft draft) async {
    final box = await Hive.openBox<Draft>('drafts');
    await box.put('current', draft);
  }

  /// 聊天记录（复杂查询 → sqflite）
  static Future<List<Message>> getMessages(String chatId) async {
    final db = await openDatabase(/*...*/);
    final maps = await db.query('messages',
      where: 'chat_id = ?', whereArgs: [chatId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Message.fromMap(m)).toList();
  }
}''',
            language: 'Dart'),
          const Paragraph('注意每种存储的使用场景：SP 存简单配置、Secure Storage 存敏感数据、'
              'Hive 存需要快速读写的结构化数据、sqflite 存需要复杂查询的关系数据。'),
          const TipBox('混合使用时注意初始化顺序：path_provider → Hive.initFlutter → 打开数据库 → 读取配置。main.dart 中做好初始化。', type: TipType.info),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph('1. 用 SharedPreferences 实现「记住登录状态」—— 启动时检查 isLogin 跳过登录页\n'
              '2. 用 Hive 存待办事项列表（ToDo 模型：id, title, isDone, createdAt + TypeAdapter）\n'
              '3. 用 sqflite 创建通讯录（增删改查 + 按姓名模糊搜索）\n'
              '4. 用 flutter_secure_storage 存 API Key，登录时读取并附加到请求头\n'
              '5. 用 path_provider + File I/O 实现日志记录器，每次运行追加一行时间戳'),
          const TipBox('sqflite 练习注意数据库版本管理——改表结构必须升级 version 并在 onUpgrade 中执行迁移 SQL。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
