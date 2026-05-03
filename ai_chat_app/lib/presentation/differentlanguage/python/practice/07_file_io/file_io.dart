import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// 文件读写模拟器
class _FileSimulatorDemo extends StatefulWidget {
  const _FileSimulatorDemo();
  @override
  State<_FileSimulatorDemo> createState() => _FileSimulatorDemoState();
}

class _FileSimulatorDemoState extends State<_FileSimulatorDemo> {
  String _mode = 'r';
  String _encoding = 'utf-8';
  String _newLine = 'New line added!';
  final String _originalContent = 'Hello, Python!\nThis is line 2.\nLine 3 here.';
  late String _fileState;

  @override
  void initState() {
    super.initState();
    _fileState = _originalContent;
  }

  void _execute() {
    setState(() {
      if (_mode == 'w') {
        _fileState = _newLine;
      } else if (_mode == 'a') {
        _fileState = '$_fileState\n$_newLine';
      }
      // 'r' mode just reads, no state change needed
    });
  }

  void _reset() {
    setState(() {
      _fileState = _originalContent;
    });
  }

  String get _liveCode {
    final body = _mode == 'r'
        ? 'content = f.read()\nprint(content)'
        : _mode == 'w'
            ? 'f.write("$_newLine")'
            : 'f.write("$_newLine\\n")';
    return "with open('example.txt', '$_mode', encoding='$_encoding') as f:\n    $body";
  }

  String get _displayContent {
    if (_mode == 'r') return _fileState;
    return _fileState;
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '📂 文件读写模拟器',
      subtitle: '选择模式，模拟 open() 的读写行为，观察文件内容变化',
      children: [
        ParamChoiceChips<String>(
          label: '文件模式',
          value: _mode,
          options: const [
            ('r', '读取'),
            ('w', '写入(覆盖)'),
            ('a', '追加'),
          ],
          onChanged: (v) => setState(() => _mode = v),
        ),
        if (_mode == 'w' || _mode == 'a')
          ParamTextField(
            label: '写入内容',
            value: _newLine,
            hint: '输入要写入/追加的内容',
            onChanged: (v) => setState(() => _newLine = v.isEmpty ? '' : v),
            maxLength: 40,
          ),
        const SizedBox(height: 8),
        // 文件内容预览
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📄 example.txt',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _mode == 'r' ? _originalContent : _displayContent,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CDCFE),
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _execute,
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('执行文件操作'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _reset,
              child: const Text('重置'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_liveCode),
        LiveOutputBox(_displayContent),
      ],
    );
  }
}

/// CSV 与 JSON 格式演示
class _CsvJsonDemo extends StatefulWidget {
  const _CsvJsonDemo();
  @override
  State<_CsvJsonDemo> createState() => _CsvJsonDemoState();
}

class _CsvJsonDemoState extends State<_CsvJsonDemo> {
  String _dataType = 'csv';
  String _name = '王五';
  int _age = 28;
  String _city = '广州';

  final List<Map<String, dynamic>> _defaultItems = const [
    {'name': '张三', 'age': 25, 'city': '北京'},
    {'name': '李四', 'age': 30, 'city': '上海'},
  ];

  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.from(_defaultItems);
  }

  void _addItem() {
    setState(() {
      _items.add({'name': _name, 'age': _age, 'city': _city});
    });
  }

  void _clearItems() {
    setState(() {
      _items = List<Map<String, dynamic>>.from(_defaultItems);
    });
  }

  String get _csvDisplay {
    final buf = StringBuffer();
    buf.writeln('name,age,city');
    for (final item in _items) {
      buf.writeln('${item['name']},${item['age']},${item['city']}');
    }
    return buf.toString().trimRight();
  }

  String get _jsonDisplay {
    final buf = StringBuffer();
    buf.writeln('[');
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final comma = i < _items.length - 1 ? ',' : '';
      buf.writeln('  {"name": "${item['name']}", "age": ${item['age']}, "city": "${item['city']}"}$comma');
    }
    buf.write(']');
    return buf.toString();
  }

  String get _liveCode {
    if (_dataType == 'csv') {
      return "import csv\n\n# 写入 CSV\nwith open('data.csv', 'w', newline='', encoding='utf-8') as f:\n    writer = csv.DictWriter(f, fieldnames=['name', 'age', 'city'])\n    writer.writeheader()\n    writer.writerows(data)\n\n# 读取 CSV\nwith open('data.csv', 'r', encoding='utf-8') as f:\n    reader = csv.DictReader(f)\n    for row in reader:\n        print(row)";
    } else {
      return "import json\n\n# 写入 JSON\nwith open('data.json', 'w', encoding='utf-8') as f:\n    json.dump(data, f, ensure_ascii=False, indent=2)\n\n# 读取 JSON\nwith open('data.json', 'r', encoding='utf-8') as f:\n    loaded = json.load(f)\n    for item in loaded:\n        print(item)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = _dataType == 'csv' ? _csvDisplay : _jsonDisplay;
    return InteractivePlayground(
      title: '📊 CSV / JSON 格式演示',
      subtitle: '添加记录，实时预览 CSV 和 JSON 的格式化输出',
      children: [
        ParamChoiceChips<String>(
          label: '数据格式',
          value: _dataType,
          options: const [
            ('csv', 'CSV格式'),
            ('json', 'JSON格式'),
          ],
          onChanged: (v) => setState(() => _dataType = v),
        ),
        ParamTextField(
          label: '姓名',
          value: _name,
          hint: '输入姓名',
          onChanged: (v) => setState(() => _name = v.isEmpty ? '' : v),
          maxLength: 8,
        ),
        ParamIntSlider(
          label: '年龄',
          value: _age,
          min: 1,
          max: 99,
          onChanged: (v) => setState(() => _age = v),
        ),
        ParamTextField(
          label: '城市',
          value: _city,
          hint: '输入城市',
          onChanged: (v) => setState(() => _city = v.isEmpty ? '' : v),
          maxLength: 8,
        ),
        const SizedBox(height: 8),
        // 数据预览
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Text(
            display,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFCE9178),
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('添加记录'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _clearItems,
              child: const Text('清空'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_liveCode),
        LiveOutputBox('${_items.length} 条记录'),
      ],
    );
  }
}

/// Python 第7章：IO编程（完整版）
/// 涵盖：open/文件模式/三种读取方式/写入/with/seek/编码/
/// codecs/BOM/行尾/二进制/内存IO(StringIO/BytesIO)/pickle序列化/
/// 控制台IO(input/print)/os.path/pathlib/shutil/glob/fnmatch/
/// tempfile/CSV/JSON/综合示例
class PythonFileIO extends StatelessWidget {
  const PythonFileIO({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第7章 IO编程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① open() 与文件模式\n'
            '② 读取文件（3种方式）\n'
            '③ 写入文件\n'
            '④ with 语句（上下文管理器）\n'
            '⑤ seek/tell 随机读写\n'
            '⑥ 编码深度解析\n'
            '⑦ 二进制文件\n'
            '⑧ 内存IO：StringIO/BytesIO\n'
            '⑨ pickle 序列化\n'
            '⑩ 控制台IO：input/print\n'
            '⑪ os.path 路径操作\n'
            '⑫ pathlib（现代方案）\n'
            '⑬ shutil 文件管理\n'
            '⑭ glob 与 fnmatch 文件搜索\n'
            '⑮ tempfile 临时文件\n'
            '⑯ CSV与JSON\n'
            '⑰ 综合示例\n'
            '⑱ 小练习',
          ),
          const TipBox(
            '文件操作是 Python 最常用的功能之一。数据处理、日志读写、'
            '配置文件解析都离不开它。本章覆盖了你日常需要的 90% 文件操作。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════════════
          // 第1节：open() 与文件模式
          // ═══════════════════════════════════════════════════════════
          const SectionHeader('1. open() —— 打开文件', icon: Icons.folder_open),
          const Paragraph(
            'open() 返回一个文件对象。第一个参数是文件路径，第二个参数是模式。'
            '处理中文文件一定要指定 encoding="utf-8"！',
          ),
          const CodeBlock(
            'f = open("test.txt", "r", encoding="utf-8")\n'
            '#    ↑文件名       ↑模式    ↑编码\n\n'
            '# ========== 文件模式速查表 ==========\n'
            '# "r"   读取（默认）。文件必须存在\n'
            '# "w"   写入。存在则覆盖，不存在则创建\n'
            '# "a"   追加。在文件末尾写入\n'
            '# "x"   创建。文件存在则报错\n'
            '# "b"   二进制模式（与上面组合使用）\n'
            '# "t"   文本模式（默认）\n'
            '# "r+"  读写（不创建文件）\n'
            '# "w+"  读写（创建/覆盖）\n'
            '# "a+"  读和追加\n\n'
            '# 组合示例：\n'
            '# "rb"   读取二进制（如图片）\n'
            '# "wb"   写入二进制\n'
            '# "r+"   读取并写入',
            language: 'Python',
          ),
          const TipBox(
            '"w" 模式会覆盖已有文件！如果只是想添加内容，用 "a"（追加）模式。'
            '不确定的时候就先用 "r" 试试。',
            type: TipType.caution,
          ),
          const TipBox(
            '"x" 模式适合需要"原子创建"的场景——比如多进程同时写同一个文件时，'
            '"x" 模式可以避免竞态条件。文件已存在会立即报错，不会覆盖。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第2节：读取文件
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('2. 读取文件（三种方式）', icon: Icons.import_contacts),
          const Paragraph(
            '根据文件大小选择合适的读取方式。基本原则：小文件一次性读，大文件逐行读。',
          ),
          const CodeBlock(
            '# ===== 方式1：read() 一次读全部 =====\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    content = f.read()         # 整个文件->字符串\n'
            '    print(len(content))        # 字符数\n'
            '    print(content[:100])       # 前100个字符\n'
            '# 适合小文件（几MB以内）\n\n'
            '# ===== 方式2：readline() 逐行读 =====\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    line = f.readline()\n'
            '    while line:               # 读到文件末尾返回""\n'
            '        print(line.strip())    # strip()去掉换行符\n'
            '        line = f.readline()\n'
            '# 适合超大文件（几百MB+）\n\n'
            '# ===== 方式3：for line in f（推荐！） =====\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    for line in f:             # 直接遍历文件对象\n'
            '        print(line.strip())\n'
            '# Python 内部优化，高效又简洁\n\n'
            '# ===== 方式4：readlines() 全部行到列表 =====\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    lines = f.readlines()      # ["第一行\\n", "第二行\\n"]\n'
            '    print(lines[0].strip())    # 第一行\n'
            '# 注意：小文件才用，大文件会占大量内存',
            language: 'Python',
          ),
          const TipBox(
            '明确区分：read() 返回字符串，readlines() 返回列表。'
            '日常推荐 for line in f: 写法——简单、高效、省内存。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第3节：写入文件
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('3. 写入文件', icon: Icons.edit),
          const Paragraph(
            'write() 写入单行，writelines() 写入多行。注意 writelines() 不会自动加换行！',
          ),
          const CodeBlock(
            '# ===== write() 写入 =====\n'
            'with open("output.txt", "w", encoding="utf-8") as f:\n'
            '    f.write("第一行\\n")        # \\n 换行\n'
            '    f.write("第二行\\n")\n'
            '    f.write(f"当前时间：2025年\\n")  # f-string 也支持\n\n'
            '# ===== writelines() 写入多行 =====\n'
            'lines = ["第1行\\n", "第2行\\n", "第3行\\n"]\n'
            'with open("output.txt", "w", encoding="utf-8") as f:\n'
            '    f.writelines(lines)        # 写入整个列表\n\n'
            '# ===== 追加模式 "a" =====\n'
            'with open("log.txt", "a", encoding="utf-8") as f:\n'
            '    f.write("2025-01-15: 用户登录\\n")  # 追加到末尾\n\n'
            '# ===== 打印到文件 =====\n'
            'with open("output.txt", "w") as f:\n'
            '    print("直接打印到文件", file=f)\n'
            '    print("不需要 write()", file=f)',
            language: 'Python',
          ),

          // ═══════════════════════════════════════════════════════════
          // 第4节：with 语句
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('4. with 语句与上下文管理器', icon: Icons.auto_fix_high),
          const Paragraph(
            'with 语句是 Python 最优雅的特性之一。它确保资源被正确释放——'
            '即使中间抛出异常也会自动关闭文件。这叫做「上下文管理器」（Context Manager）。',
          ),
          const CodeBlock(
            '# ===== with 的工作原理 =====\n'
            '# with 会在进入时调用 __enter__，退出时调用 __exit__\n'
            '# 即使发生异常，__exit__ 也会被调用\n\n'
            '# ✅ 推荐：with 自动管理\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    data = f.read()\n'
            '# 到这里文件已自动关闭\n\n'
            '# ❌ 不推荐：手动管理（容易忘 close）\n'
            'f = open("test.txt", "r")\n'
            'data = f.read()\n'
            'f.close()  # 如果这行之前报错，文件不会关闭！\n\n'
            '# ===== 同时打开多个文件 =====\n'
            'with open("source.txt") as src, open("dst.txt", "w") as dst:\n'
            '    dst.write(src.read())  # 复制文件\n\n'
            '# ===== 自定义上下文管理器 =====\n'
            'class ManagedFile:\n'
            '    def __init__(self, name):\n'
            '        self.name = name\n\n'
            '    def __enter__(self):\n'
            '        self.file = open(self.name, "w")\n'
            '        return self.file\n\n'
            '    def __exit__(self, exc_type, exc_val, exc_tb):\n'
            '        if self.file:\n'
            '            self.file.close()',
            language: 'Python',
          ),
          const TipBox(
            'with 不止用于文件！数据库连接、线程锁、网络连接等资源都可以用 with 管理。'
            '只要对象实现了 __enter__ 和 __exit__ 就能用 with。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第5节：seek/tell 随机读写
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('5. seek/tell —— 随机读写', icon: Icons.touch_app),
          const Paragraph(
            'tell() 返回当前文件指针位置，seek() 移动文件指针。'
            '这在处理大文件时非常有用——可以"跳到"文件的任意位置读取。',
          ),
          const CodeBlock(
            '# ===== tell() 和 seek() =====\n'
            'with open("test.txt", "r", encoding="utf-8") as f:\n'
            '    print(f.tell())       # 0（文件开头）\n'
            '    line = f.readline()\n'
            '    print(f.tell())       # 已经读取的字节数\n\n'
            '    f.seek(0)             # 回到文件开头\n'
            '    line = f.readline()\n\n'
            '    f.seek(10)            # 跳到第10个字节\n'
            '    print(f.read(5))      # 从第10字节读5个字节\n\n'
            '# ===== 读取文件末尾 =====\n'
            '# 常用于读取日志文件的最后几行\n'
            'with open("log.txt", "rb") as f:\n'
            '    f.seek(0, 2)          # 2=从文件末尾开始\n'
            '    pos = f.tell()        # 文件总大小\n'
            '    f.seek(max(0, pos-200), 0)  # 往前200字节\n'
            '    print(f.read())       # 读取最后200字节',
            language: 'Python',
          ),
          const TipBox(
            'seek() 的第二个参数：0=文件开头（默认），1=当前位置，2=文件末尾。'
            '文本模式下 seek(0) 和 seek(0, 2) 可用，其他偏移量在文本模式中不可靠，建议用 "rb"。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第6节：编码深度解析（扩展版）
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('6. 编码深度解析', icon: Icons.text_fields),
          const Paragraph(
            '编码是文件操作中最容易出问题的环节。不同系统默认编码不同：'
            'Windows 用 GBK，Mac/Linux 用 UTF-8。处理中文必须关注编码。',
          ),
          const CodeBlock(
            '# ===== 常见编码 =====\n'
            '# UTF-8：通用编码，支持所有语言（推荐）\n'
            '# GBK/GB2312：中文编码（Windows 旧文件常见）\n'
            '# ASCII：仅英文字符\n'
            '# ISO-8859-1：西欧语言\n\n'
            '# ===== 读取不同编码的文件 =====\n'
            '# UTF-8 文件\n'
            'with open("utf8.txt", "r", encoding="utf-8") as f:\n'
            '    print(f.read())\n\n'
            '# GBK 文件（Windows 常见）\n'
            'with open("gbk.txt", "r", encoding="gbk") as f:\n'
            '    print(f.read())\n\n'
            '# ===== 编码错误处理 =====\n'
            '# errors="ignore"：忽略无法解码的字符\n'
            'with open("file.txt", "r", encoding="utf-8", errors="ignore") as f:\n'
            '    data = f.read()\n\n'
            '# errors="replace"：用 ? 替换无法解码的字符\n'
            'with open("file.txt", "r", encoding="utf-8", errors="replace") as f:\n'
            '    data = f.read()  # 乱码字符变成 ?\n\n'
            '# ===== 检测编码 =====\n'
            'import chardet  # 第三方库，自动检测编码\n'
            'with open("unknown.txt", "rb") as f:\n'
            '    raw = f.read(10000)\n'
            '    result = chardet.detect(raw)\n'
            '    print(result)  # {"encoding": "utf-8", "confidence": 0.99}',
            language: 'Python',
          ),
          const TipBox(
            '不确定编码就用 "rb" 读取二进制，然后用 .decode("utf-8", errors="replace") 尝试解码。'
            'chardet 库可以自动检测编码，但速度较慢。',
            type: TipType.warning,
          ),

          // ── 6.1 codecs 模块 ──
          const Paragraph(
            'codecs 模块提供了比内置 open() 更丰富的编码支持。它注册了所有 Python '
            '支持的编码器，并提供编码查找、BOM 常量等功能。',
          ),
          const CodeBlock(
            r'''import codecs

# codecs.open() 与内置 open() 类似，但更强调编码
with codecs.open('file.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 查看编码器信息
info = codecs.lookup('utf-8')
print(info.name)  # utf-8

# 系统支持的编码器
encodings = ['utf-8', 'gbk', 'shift_jis', 'euc-kr', 'cp1252']
for enc in encodings:
    try:
        codecs.lookup(enc)
        print(f'{enc} is supported')
    except LookupError:
        print(f'{enc} not supported')

# 常用 BOM 常量
print(codecs.BOM_UTF8)      # b'\xef\xbb\xbf'
print(codecs.BOM_UTF16_LE)  # b'\xff\xfe'
print(codecs.BOM_UTF16_BE)  # b'\xfe\xff'

# 编码错误处理（与内置 open() 相同）
with codecs.open('file.txt', 'r', encoding='utf-8',
                 errors='replace') as f:
    data = f.read()
''',
            language: 'Python',
          ),

          // ── 6.2 BOM 处理 ──
          const Paragraph(
            'BOM（Byte Order Mark）是某些编码格式的文件头标记，用于标识字节序。'
            'UTF-16 文件通常带有 BOM，UTF-8 文件可能带 BOM（尤其是 Windows 平台）。'
            'Python 提供了 utf-8-sig 编码自动处理 UTF-8 BOM。',
          ),
          const CodeBlock(
            r'''# BOM（Byte Order Mark）处理

# utf-8-sig 自动识别并去除 BOM
with open('file_with_bom.txt', 'r', encoding='utf-8-sig') as f:
    content = f.read()  # BOM 已经被自动去除

# 手动检测 BOM 类型
with open('unknown.txt', 'rb') as f:
    header = f.read(4)
    f.seek(0)

    if header[:3] == b'\xef\xbb\xbf':
        print('UTF-8 with BOM')
        text = f.read().decode('utf-8-sig')
    elif header[:2] == b'\xff\xfe':
        print('UTF-16 LE (Little Endian)')
        text = f.read().decode('utf-16-le')
    elif header[:2] == b'\xfe\xff':
        print('UTF-16 BE (Big Endian)')
        text = f.read().decode('utf-16-be')
    else:
        print('No BOM detected, assuming UTF-8')
        text = f.read().decode('utf-8')

# 写入带 BOM 的 UTF-8 文件
with open('output_bom.txt', 'w', encoding='utf-8-sig') as f:
    f.write('这段文字带 BOM 头')

# 编码转换：GBK -> UTF-8
with open('gbk_file.txt', 'r', encoding='gbk') as f:
    text = f.read()
with open('output_utf8.txt', 'w', encoding='utf-8') as f:
    f.write(text)
''',
            language: 'Python',
          ),

          // ── 6.3 行尾处理 ──
          const Paragraph(
            '不同操作系统使用不同的换行符：Windows 用 CRLF (\\r\\n)，'
            'Unix/Linux 用 LF (\\n)，旧版 Mac 用 CR (\\r)。'
            'Python 默认启用通用换行模式（Universal Newline），自动将各种换行符统一为 \\n。',
          ),
          const CodeBlock(
            r'''# 行尾处理（Line Endings）

# 检测文件的行尾格式
with open('file.txt', 'rb') as f:
    content = f.read()
    if b'\r\n' in content:
        print('Windows 格式 (CRLF)')
    elif b'\r' in content and not b'\r\n' in content:
        print('旧 Mac 格式 (CR)')
    else:
        print('Unix/Linux 格式 (LF)')

# Python 通用换行模式（默认启用）
# 自动将 \r\n 和 \r 转换为 \n
with open('windows_file.txt', 'r') as f:
    for line in f:
        print(repr(line))  # 行尾统一为 '\n'

# 禁用通用换行模式（保留原始行尾）
with open('windows_file.txt', 'r', newline='') as f:
    for line in f:
        print(repr(line))  # 保留 '\r\n'

# 二进制模式手动处理行尾
with open('mixed.txt', 'rb') as f:
    raw = f.read()
    # 统一为 Unix 格式
    normalized = raw.replace(b'\r\n', b'\n').replace(b'\r', b'\n')
    text = normalized.decode('utf-8')

# 写入时指定行尾
with open('unix.txt', 'w', newline='\n') as f:
    f.write('Unix 行尾\n')
with open('windows.txt', 'w', newline='\r\n') as f:
    f.write('Windows 行尾\r\n')
''',
            language: 'Python',
          ),
          const TipBox(
            'Git 仓库建议设置 core.autocrlf=true，这样 Windows 上检出时自动转为 CRLF，'
            '提交时自动转为 LF。Python 开发建议保持 .py 文件为 LF 格式。',
            type: TipType.info,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第7节：二进制文件
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('7. 二进制文件操作', icon: Icons.memory),
          const Paragraph(
            '图片、视频、音频、压缩包都是二进制文件。用 "rb"/"wb" 模式操作。'
            '二进制文件不能指定 encoding。',
          ),
          const CodeBlock(
            '# ===== 复制图片 =====\n'
            'with open("photo.jpg", "rb") as src:\n'
            '    with open("copy.jpg", "wb") as dst:\n'
            '        dst.write(src.read())\n\n'
            '# ===== 分块读取（适合大文件） =====\n'
            'def copy_large(src_path, dst_path, chunk_size=4096):\n'
            '    """分块复制大文件，避免内存溢出"""\n'
            '    with open(src_path, "rb") as src:\n'
            '        with open(dst_path, "wb") as dst:\n'
            '            while True:\n'
            '                chunk = src.read(chunk_size)\n'
            '                if not chunk:\n'
            '                    break\n'
            '                dst.write(chunk)\n\n'
            '# ===== 查看二进制内容 =====\n'
            'with open("test.jpg", "rb") as f:\n'
            '    header = f.read(16)\n'
            '    print(header.hex())  # 16进制显示前16字节',
            language: 'Python',
          ),
          const TipBox(
            '对于超大文件（几百 MB 以上），务必使用分块读取，避免一次 read() 全部读入内存。'
            'chunk_size 通常设为 4KB ~ 8MB 之间的值。',
            type: TipType.warning,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第8节：内存IO（StringIO / BytesIO）
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('8. 内存IO —— StringIO 与 BytesIO', icon: Icons.memory),
          const Paragraph(
            '内存IO 让你像操作文件一样操作内存中的字符串或字节数据。'
            'StringIO 处理文本，BytesIO 处理二进制。它们遵循相同的文件接口协议，'
            '支持 read() / write() / seek() / tell() 等操作。',
          ),
          const CodeBlock(
            r'''from io import StringIO, BytesIO

# ===== StringIO：在内存中读写字符串 =====
buffer = StringIO()
buffer.write('Hello, ')
buffer.write('World!')
print(buffer.getvalue())  # Hello, World!
print(buffer.tell())      # 13

# 像文件一样使用
buffer.seek(0)
print(buffer.read())      # Hello, World!
buffer.close()  # 释放内存

# 用 with 语句管理（Python 3.6+）
with StringIO() as buf:
    buf.write('在内存中操作文本')
    content = buf.getvalue()
    print(content)
# 自动释放

# 从已有字符串创建
with StringIO('line1\nline2\nline3') as f:
    for line in f:
        print(line.strip())

# ===== BytesIO：处理二进制数据 =====
with BytesIO() as buf:
    buf.write(b'\x00\x01\x02\x03')
    buf.write(bytes(range(4, 8)))
    buf.seek(0)
    data = buf.read()
    print(data.hex())       # 0001020304050607
    print(len(data))        # 8
''',
            language: 'Python',
          ),
          const Paragraph(
            'StringIO 的典型应用场景：作为字符串缓冲区拼接大量文本，比字符串拼接更高效；'
            '用于捕获 print() 输出；用于单元测试中模拟文件对象。'
            'BytesIO 常用于图像处理、协议封包等需要内存中操作二进制数据的场景。',
          ),
          const CodeBlock(
            r'''# 实际应用：捕获 print() 输出
import sys

def capture_print(func, *args, **kwargs):
    """捕获函数中所有 print() 输出的内容"""
    old_stdout = sys.stdout
    sys.stdout = StringIO()

    try:
        func(*args, **kwargs)
        return sys.stdout.getvalue()
    finally:
        sys.stdout = old_stdout

def greet(name):
    print(f'Hello, {name}!')
    print(f'Today is a great day.')

captured = capture_print(greet, 'Alice')
print('=== 捕获的输出 ===')
print(captured)
print('=== 结束 ===')

# StringIO 替代临时文件
import csv

# 将 CSV 数据写入内存而非磁盘
buffer = StringIO()
writer = csv.writer(buffer)
writer.writerow(['Name', 'Score'])
writer.writerow(['Alice', 95])
csv_content = buffer.getvalue()
print(csv_content)
buffer.close()
''',
            language: 'Python',
          ),
          const TipBox(
            'StringIO 和 BytesIO 不会创建实际文件，因此速度更快，且无需清理。'
            '在需要"文件接口"但不想写磁盘时非常有用。不过，超大数据（>1GB）不建议放内存。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第9节：pickle 序列化
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('9. pickle —— 对象序列化', icon: Icons.save),
          const Paragraph(
            'pickle 模块可以将任意 Python 对象序列化为字节流，以便保存到文件或通过网络传输。'
            '序列化过程称为 pickling，反序列化称为 unpickling。'
            '它支持列表、字典、类实例等几乎所有 Python 对象。',
          ),
          const CodeBlock(
            r'''import pickle

# ===== 基本序列化/反序列化 =====
data = {
    'name': 'Alice',
    'age': 28,
    'scores': [95, 87, 92],
    'active': True,
    'tags': ('student', 'python')
}

# dump：序列化到文件
with open('data.pkl', 'wb') as f:
    pickle.dump(data, f)

# load：从文件反序列化
with open('data.pkl', 'rb') as f:
    loaded = pickle.load(f)
print(loaded)
print(loaded == data)  # True

# dumps/loads：序列化到内存字节串
bytes_data = pickle.dumps(data)
print(f'序列化后大小：{len(bytes_data)} 字节')

restored = pickle.loads(bytes_data)
print(restored == data)  # True
''',
            language: 'Python',
          ),
          const Paragraph(
            'pickle 有多个协议版本，从 protocol 0（文本格式）到 protocol 5（Python 3.8+）。'
            '更高版本通常更小、更快。Python 3.8+ 默认使用 protocol 5，支持大数据类型优化。'
            'pickle 也可以序列化自定义类的实例。',
          ),
          const CodeBlock(
            r'''# ===== 协议版本 =====
# 指定协议版本
pickle.dump(data, open('data_v0.pkl', 'wb'), protocol=0)
pickle.dump(data, open('data_v5.pkl', 'wb'), protocol=5)

# 查看各协议大小
import os
for version in range(5):
    data_bytes = pickle.dumps(data, protocol=version)
    print(f'Protocol {version}: {len(data_bytes)} bytes')

# ===== 序列化自定义对象 =====
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def __repr__(self):
        return f'Person({self.name}, {self.age})'

p = Person('Bob', 25)
with open('person.pkl', 'wb') as f:
    pickle.dump(p, f)

with open('person.pkl', 'rb') as f:
    p2 = pickle.load(f)
print(p2)  # Person(Bob, 25)
print(p2.name, p2.age)  # Bob 25
''',
            language: 'Python',
          ),
          const TipBox(
            'pickle 不安全！永远不要 unpickle 来历不明的数据。恶意的 pickle 数据可以执行任意系统命令。'
            '如果需要在不同语言之间交换数据，用 JSON 或 Protocol Buffers 替代 pickle。'
            'pickle 也依赖于类的定义——加载时如果类不存在会报错。',
            type: TipType.caution,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第10节：控制台IO（input / print）
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('10. 控制台IO —— input() 与 print()', icon: Icons.keyboard),
          const Paragraph(
            '控制台IO 是程序与用户交互最基础的方式。input() 从标准输入读取一行，'
            'print() 将输出写入标准输出。两者在底层都操作 sys.stdin 和 sys.stdout 文件对象。',
          ),
          const CodeBlock(
            r'''# ===== input() 基础用法 =====
name = input('请输入你的名字：')
print(f'你好，{name}！')

# input() 始终返回字符串，需要手动转换类型
age_str = input('请输入年龄：')
age = int(age_str)
print(f'明年你 {age + 1} 岁')

# 一行输入多个值
x_str, y_str = input('输入两个数（空格分隔）：').split()
x, y = int(x_str), int(y_str)
print(f'{x} + {y} = {x + y}')

# ===== print() 参数详解 =====
# sep：自定义分隔符（默认是空格）
print('apple', 'banana', 'orange', sep=', ')
print('2025', '01', '15', sep='-')
print('A', 'B', 'C', sep=' | ')

# end：结尾字符（默认是换行）
print('正在加载', end='')
print('.', end='')
print('.', end='')
print('.')
print('完成！')

# file：输出到文件对象
import sys
with open('console.log', 'a', encoding='utf-8') as f:
    print('用户登录系统', file=f)
    print('执行数据分析', file=f)

# 同时输出到屏幕和文件
print('重要信息', file=sys.stdout)
''',
            language: 'Python',
          ),
          const Paragraph(
            'print() 默认启用输出缓冲，这意味着输出不会立即显示。'
            'flush=True 可以强制刷新缓冲区，确保内容立即显示。'
            '这在实现进度条、实时日志等场景中非常重要。',
          ),
          const CodeBlock(
            r'''# ===== flush 缓冲区控制 =====
import time
import sys

# 没有 flush：输出可能被缓冲，不会立即显示
print('开始处理...', end='')
time.sleep(2)  # 模拟耗时操作
print('完成！')
# 上面两行可能同时出现

# 有 flush：立即显示
print('开始处理...', end='', flush=True)
time.sleep(2)
print('完成！')
# 立即显示"开始处理..."，2秒后追加"完成！"

# ===== 进度条效果 =====
for i in range(101):
    print(f'\r进度：{i}%', end='', flush=True)
    time.sleep(0.03)
print('\n处理完毕！')

# ===== sys.stdin/stdout 直接操作 =====
# input() 等价于 sys.stdin.readline().strip()
line = sys.stdin.readline().strip()
print(f'你输入了：{line}')

# 直接写入 stdout
sys.stdout.write('直接写入 stdout\n')
sys.stdout.flush()

# stderr 输出（用于错误信息）
import sys
print('错误信息', file=sys.stderr)
sys.stderr.write('直接写入 stderr\n')
''',
            language: 'Python',
          ),
          const TipBox(
            'flush=True 在实时日志、进度显示、远程调试时非常关键。但频繁 flush 会降低性能——'
            '数据量大时可以每 N 条 flush 一次。print() 默认的缓冲策略在交互式终端是行缓冲，'
            '在重定向到文件时是块缓冲。',
            type: TipType.warning,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第11节：os.path 路径操作
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('11. os.path —— 路径操作', icon: Icons.folder),
          const Paragraph(
            'os.path 自动处理不同操作系统的路径分隔符（Windows 用 \\，Mac/Linux 用 /）。'
            '永远不要用字符串拼接路径！',
          ),
          const CodeBlock(
            'import os\n\n'
            '# ===== 路径拼接 =====\n'
            'path = os.path.join("folder", "sub", "file.txt")\n'
            '# Windows: folder\\sub\\file.txt\n'
            '# Mac/Linux: folder/sub/file.txt\n\n'
            '# ===== 路径信息 =====\n'
            'p = "/home/user/docs/file.txt"\n'
            'print(os.path.basename(p))    # file.txt\n'
            'print(os.path.dirname(p))     # /home/user/docs\n'
            'print(os.path.splitext(p))    # (\'/home/user/docs/file\', \'.txt\')\n\n'
            '# ===== 文件信息 =====\n'
            'print(os.path.exists(p))      # 是否存在\n'
            'print(os.path.isfile(p))      # 是否是文件\n'
            'print(os.path.isdir(p))       # 是否是目录\n'
            'print(os.path.getsize(p))     # 文件大小（字节）\n'
            'print(os.path.getmtime(p))    # 最后修改时间\n\n'
            '# ===== 目录操作 =====\n'
            'os.makedirs("a/b/c", exist_ok=True)  # 递归创建\n'
            'print(os.getcwd())            # 当前工作目录\n'
            'os.chdir("/tmp")              # 切换目录\n\n'
            '# ===== 列出目录 =====\n'
            'for f in os.listdir("."):\n'
            '    print(f)                  # 列出所有文件和目录',
            language: 'Python',
          ),

          // ═══════════════════════════════════════════════════════════
          // 第12节：pathlib 现代路径方案
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('12. pathlib —— 现代路径方案（Python 3.4+）', icon: Icons.new_releases),
          const Paragraph(
            'pathlib 是 Python 3.4 引入的现代路径库，比 os.path 更直观。'
            '它用 Path 对象代替字符串操作路径，支持链式调用和运算符重载。',
          ),
          const CodeBlock(
            'from pathlib import Path\n\n'
            '# 创建 Path 对象\n'
            'p = Path("/home/user/docs/file.txt")\n'
            'home = Path.home()              # 用户主目录\n'
            'cwd = Path.cwd()                # 当前目录\n\n'
            '# 路径操作（比 os.path 更优雅）\n'
            'print(p.name)            # file.txt\n'
            'print(p.stem)            # file（无后缀的文件名）\n'
            'print(p.suffix)          # .txt\n'
            'print(p.parent)          # /home/user/docs\n'
            'print(p.parents[0])      # 父目录\n'
            'print(p.parents[1])      # 祖父目录\n\n'
            '# 路径拼接（/ 运算符）\n'
            'new_path = Path("folder") / "sub" / "file.txt"\n'
            'print(new_path)  # folder/sub/file.txt\n\n'
            '# 文件操作\n'
            'Path("test.txt").write_text("Hello", encoding="utf-8")\n'
            'text = Path("test.txt").read_text(encoding="utf-8")\n\n'
            '# 目录遍历\n'
            'for f in Path(".").glob("*.py"):    # 搜索所有 .py 文件\n'
            '    print(f.name)\n'
            'for f in Path(".").rglob("**/*.py"):  # 递归搜索\n'
            '    print(f)\n\n'
            '# 创建/删除\n'
            'Path("new_dir").mkdir(parents=True, exist_ok=True)\n'
            'Path("old_file.txt").unlink()  # 删除文件',
            language: 'Python',
          ),
          const TipBox(
            'pathlib 是 Python 官方推荐的路径操作方式。新项目建议用 pathlib 代替 os.path。'
            'pathlib 对象可以和字符串互转：str(path_obj) 转为字符串。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第13节：shutil 高级文件操作
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('13. shutil —— 高级文件操作', icon: Icons.content_copy),
          const Paragraph(
            'shutil 模块提供了复制、移动、删除、压缩等高级文件操作。'
            '它是 os 模块的补充，更贴近实际开发需求。',
          ),
          const CodeBlock(
            'import shutil\n\n'
            '# 复制文件\n'
            'shutil.copy("source.txt", "dest.txt")     # 复制文件\n'
            'shutil.copy2("source.txt", "dest.txt")    # 复制文件+元数据\n'
            'shutil.copytree("folder", "backup")       # 复制整个目录\n\n'
            '# 移动/重命名\n'
            'shutil.move("source.txt", "archive/")     # 移动文件\n'
            'shutil.move("old_name.txt", "new_name.txt")  # 重命名\n\n'
            '# 删除目录\n'
            'shutil.rmtree("old_folder")  # 删除整个目录（小心！）\n\n'
            '# 压缩/解压\n'
            'shutil.make_archive("backup", "zip", "my_folder")\n'
            '# 创建 backup.zip\n'
            'shutil.unpack_archive("backup.zip", "extracted")\n'
            '# 解压到 extracted 目录\n\n'
            '# 磁盘空间\n'
            'total, used, free = shutil.disk_usage("/")\n'
            'print(f"剩余空间: {free // (2**30)} GB")',
            language: 'Python',
          ),
          const TipBox(
            'shutil.rmtree() 会直接删除整个目录树，且不可恢复，使用前务必确认路径无误。'
            '一个安全做法：先重命名目录再删除，万一误操作还能恢复。',
            type: TipType.caution,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第14节：glob 与 fnmatch 文件搜索
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('14. glob 与 fnmatch —— 文件搜索', icon: Icons.search),
          const Paragraph(
            'glob 模块提供 Unix shell 风格的通配符匹配，用于快速查找文件和目录。'
            'fnmatch 模块则用于判断文件名是否匹配特定模式。两者都不需要安装任何第三方库。',
          ),
          const CodeBlock(
            r'''import glob

# ===== 基本通配符 =====
# *     匹配任意多个字符（不包括路径分隔符）
# ?     匹配单个字符
# [abc] 匹配集合中的任意一个字符
# [!abc] 匹配不在集合中的字符
# **    递归匹配（需 recursive=True）

# 查找所有 .txt 文件
for f in glob.glob('*.txt'):
    print(f)

# 单字符通配：data_1.csv, data_2.csv, data_a.csv
for f in glob.glob('data_?.csv'):
    print(f)

# 字符范围：数字开头的 .py 文件
for f in glob.glob('[0-9]*.py'):
    print(f)

# 字母开头的 .txt 文件
for f in glob.glob('[a-z]*.txt'):
    print(f)

# 排除模式：不是 .py 的文件
for f in glob.glob('[!a-z]*'):
    print(f)  # 不以字母开头的文件
''',
            language: 'Python',
          ),
          const Paragraph(
            'glob 的递归搜索（**）可以遍历所有子目录，非常适合项目文件检索。'
            '对于超大型目录树，iglob() 返回迭代器而不是列表，避免一次性加载到内存。'
            'fnmatch 提供更灵活的文件名匹配。',
          ),
          const CodeBlock(
            r'''# ===== 递归搜索 =====
# ** 匹配零个或多个目录（Python 3.5+）
for f in glob.glob('**/*.py', recursive=True):
    print(f)  # 所有子目录中的 .py 文件

# 搜索所有图片文件
images = glob.glob('**/*.{[jJ][pP][gG],[pP][nN][gG],[gG][iI][fF]}',
                   recursive=True)
print(f'找到 {len(images)} 张图片')

# ===== iglob()：迭代器版本，适合大量文件 =====
for f in glob.iglob('**/*', recursive=True):
    # 逐个处理，不占用大量内存
    pass

# ===== escape()：转义特殊字符 =====
pattern = glob.escape('file[1].txt')
print(pattern)  # file[[]1].txt
print(glob.glob(pattern))  # 匹配字面文件名 file[1].txt

# ===== fnmatch：文件名模式匹配 =====
from fnmatch import fnmatch, filter, translate

print(fnmatch('data.csv', '*.csv'))       # True
print(fnmatch('data.txt', '*.csv'))       # False
print(fnmatch('file_01.py', 'file_*.py')) # True
print(fnmatch('main.py', '[a-z]*.py'))    # True

# 过滤整个列表
files = ['data.csv', 'data.txt', 'config.json', 'main.py']
csv_files = filter(files, '*.csv')
print(csv_files)  # ['data.csv']

py_files = filter(files, '[a-z]*.py')
print(py_files)  # ['main.py']

# translate()：将 glob 模式转为正则表达式
import re
pattern = fnmatch.translate('*.py')
print(pattern)  # (?s:.*\\.py)\\Z
regex = re.compile(pattern)
print(regex.match('test.py'))  # Match!
''',
            language: 'Python',
          ),
          const TipBox(
            'glob 使用 os.scandir() 实现，性能优于自己写 os.listdir() + fnmatch。'
            '在大型项目中，结合 pathlib.Path().glob() 和 glob 模块各有优势——'
            'pathlib 面向对象风格更现代，glob 模块的函数式风格更传统。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第15节：tempfile 临时文件
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('15. tempfile —— 临时文件', icon: Icons.timer),
          const Paragraph(
            '临时文件用于存储程序运行时产生的中间数据，程序结束后自动清理。'
            '多线程/多进程安全，不会命名冲突。',
          ),
          const CodeBlock(
            'import tempfile\n\n'
            '# ===== 临时文件（自动删除） =====\n'
            'with tempfile.TemporaryFile(mode="w+t") as f:\n'
            '    f.write("临时数据")\n'
            '    f.seek(0)\n'
            '    print(f.read())  # 临时数据\n'
            '# 退出 with 后文件自动删除\n\n'
            '# ===== 临时目录 =====\n'
            'with tempfile.TemporaryDirectory() as tmpdir:\n'
            '    print(tmpdir)  # /tmp/tmpabc123/\n'
            '    # 在 tmpdir 中操作临时文件\n'
            '    tmp_file = Path(tmpdir) / "data.txt"\n'
            '    tmp_file.write_text("hello")\n'
            '# 退出后整个目录自动删除\n\n'
            '# ===== 命名临时文件（不会自动删除） =====\n'
            'tmp = tempfile.NamedTemporaryFile(delete=False)\n'
            'print(tmp.name)  # /tmp/tmpxxx\n'
            'tmp.write(b"data")\n'
            'tmp.close()\n'
            '# 需要手动删除\n'
            'import os; os.unlink(tmp.name)',
            language: 'Python',
          ),
          const TipBox(
            '临时文件默认保存在系统临时目录（Windows: %TEMP%, Linux: /tmp, Mac: /tmp）。'
            '可以设置 TMPDIR 环境变量修改临时目录位置。处理敏感数据时注意及时清理。',
            type: TipType.info,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第16节：结构化文件格式（CSV / JSON）
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('16. 结构化文件格式 —— CSV 与 JSON', icon: Icons.table_chart),
          const Paragraph(
            'CSV（Comma-Separated Values）和 JSON（JavaScript Object Notation）'
            '是两种最常用的数据交换格式。Python 标准库提供了完善的 csv 和 json 模块，'
            '无需安装任何第三方库即可读写这两种格式。',
          ),

          // ── 16.1 CSV ──
          const Paragraph(
            'csv 模块提供了 reader/writer 用于基本读写，以及 DictReader/DictWriter '
            '用于字典风格的读写。注意 CSV 文件必须用 newline="" 打开，'
            '否则可能出现多余的空白行。',
          ),
          const CodeBlock(
            r'''import csv

# ===== 写入 CSV =====
with open('users.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['姓名', '年龄', '城市'])
    writer.writerow(['Alice', 28, '北京'])
    writer.writerow(['Bob', 32, '上海'])
    writer.writerow(['Charlie', 25, '广州'])

# ===== 读取 CSV =====
with open('users.csv', 'r', newline='', encoding='utf-8') as f:
    reader = csv.reader(f)
    for row in reader:
        print(', '.join(row))
# 输出：
# 姓名, 年龄, 城市
# Alice, 28, 北京
# Bob, 32, 上海

# ===== DictReader / DictWriter =====
with open('users.csv', 'w', newline='', encoding='utf-8') as f:
    fieldnames = ['姓名', '年龄', '城市']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerow({'姓名': 'Alice', '年龄': 28, '城市': '北京'})
    writer.writerow({'姓名': 'Bob', '年龄': 32, '城市': '上海'})

# 读取为字典
with open('users.csv', 'r', newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(f"{row['姓名']} is {row['年龄']} from {row['城市']}")

# ===== 自定义分隔符和引号 =====
with open('data.tsv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f, delimiter='\t')
    writer.writerow(['Name', 'Score'])
    writer.writerow(['Alice', 95])

# QUOTE_ALL：所有字段都加引号
with open('data.csv', 'w', newline='') as f:
    writer = csv.writer(f, quoting=csv.QUOTE_ALL)
    writer.writerow(['Name', 'Description'])
    writer.writerow(['Alice', 'Has a "pet" dog'])

# 跳过表头读取
with open('users.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader)  # 跳过第一行（表头）
    for row in reader:
        print(row)
''',
            language: 'Python',
          ),

          // ── 16.2 JSON ──
          const Paragraph(
            'json 模块可以在 Python 对象和 JSON 格式之间相互转换。'
            'json.dump() 直接写入文件，json.dumps() 返回字符串。'
            '注意 ensure_ascii=False 才能正确保存中文。',
          ),
          const CodeBlock(
            r'''import json

# ===== Python 字典 -> JSON 文件 =====
data = {
    'name': 'Alice',
    'age': 28,
    'is_student': False,
    'scores': [95, 87, 92],
    'address': {
        'city': '北京',
        'district': '海淀'
    },
    'tags': None
}

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# ===== JSON 文件 -> Python 字典 =====
with open('data.json', 'r', encoding='utf-8') as f:
    loaded = json.load(f)
print(loaded['name'])       # Alice
print(loaded['address'])    # {'city': '北京', 'district': '海淀'}

# ===== 字符串操作 =====
# Python -> JSON 字符串
json_str = json.dumps(data, ensure_ascii=False, indent=2)
print(json_str)

# JSON 字符串 -> Python
parsed = json.loads(json_str)
print(parsed == data)  # True

# ===== JSON 类型对照表 =====
# Python          JSON
# dict            object
# list, tuple     array
# str             string
# int, float      number
# True            true
# False           false
# None            null
''',
            language: 'Python',
          ),
          const Paragraph(
            'json 模块默认只支持基本数据类型。对于 datetime、Decimal 等类型，'
            '需要自定义编码器（JSONEncoder）。sort_keys 参数可以按 key 排序输出，'
            '在版本控制中很有用。',
          ),
          const CodeBlock(
            r'''# ===== 自定义 JSON 编码器 =====
from datetime import datetime

class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        if isinstance(obj, set):
            return list(obj)
        if isinstance(obj, bytes):
            return obj.hex()
        return super().default(obj)

now = datetime.now()
custom_data = {
    'time': now,
    'tags': {'python', 'json', 'tutorial'},
    'binary': b'\x00\x01\x02'
}

json_str = json.dumps(custom_data, cls=CustomEncoder,
                      ensure_ascii=False, indent=2)
print(json_str)

# ===== 美化输出 =====
# sort_keys：按键名排序输出
data = {'c': 3, 'a': 1, 'b': 2}
print(json.dumps(data, sort_keys=True, indent=2))

# ===== 大文件分块处理 =====
# 对于超大 JSON 数组，用 ijson 代替标准 json
# 此处只演示 json.JSONDecoder 的遍历
def load_json_stream(filepath):
    """逐个读取 JSON 对象"""
    decoder = json.JSONDecoder()
    with open(filepath, 'r', encoding='utf-8') as f:
        data = f.read()
        while data:
            obj, idx = decoder.raw_decode(data)
            yield obj
            data = data[idx:].strip()

# ===== JSON vs pickle 对比 =====
# JSON:  跨语言、可读性好、安全、只支持基本类型
# pickle: Python only、不可读、不安全、支持所有类型
print(json.dumps({'answer': 42}))  # '{"answer": 42}'
''',
            language: 'Python',
          ),
          const TipBox(
            '保存中文时一定要加 ensure_ascii=False，否则中文会变成 \\uXXXX 转义序列。'
            'indent=2 让 JSON 文件可读性更好，但在生产环境中为了节省带宽可以省略 indent。'
            'JSON 不支持 Python 的 tuple、set、datetime 等类型，需要自行转换。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════════════════════
          // 第17节：综合示例
          // ═══════════════════════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('17. 综合示例：日志分析器', icon: Icons.rocket_launch),
          const Paragraph(
            '下面的综合示例展示了一个完整的日志分析工具，它结合了文件读取、'
            'CSV 输出、JSON 序列化、pathlib 路径操作、字符串IO 等多种技术。'
            '这个例子涵盖了本章大部分核心知识点。',
          ),
          const CodeBlock(
            'from pathlib import Path\n'
            'from collections import Counter\n'
            'import csv, json\n'
            'from io import StringIO\n\n'
            'def analyze_log(log_path: str) -> dict:\n'
            '    """分析日志文件，返回统计结果"""\n'
            '    log_path = Path(log_path)\n\n'
            '    if not log_path.exists():\n'
            '        print(f"文件不存在: {log_path}")\n'
            '        return {}\n\n'
            '    levels = Counter()\n\n'
            '    with log_path.open("r", encoding="utf-8") as f:\n'
            '        for line in f:\n'
            '            line = line.strip()\n'
            '            if "ERROR" in line:\n'
            '                levels["ERROR"] += 1\n'
            '            elif "WARN" in line:\n'
            '                levels["WARN"] += 1\n'
            '            elif "INFO" in line:\n'
            '                levels["INFO"] += 1\n\n'
            '    result = {\n'
            '        "filename": log_path.name,\n'
            '        "size_kb": round(log_path.stat().st_size / 1024, 1),\n'
            '        "total_lines": sum(levels.values()),\n'
            '        "levels": dict(levels.most_common()),\n'
            '    }\n'
            '    return result\n\n'
            'def export_report(result: dict, fmt: str = "json"):\n'
            '    """将分析结果导出为 JSON 或 CSV"""\n'
            '    if fmt == "json":\n'
            '        print(json.dumps(result, ensure_ascii=False, indent=2))\n'
            '    elif fmt == "csv":\n'
            '        output = StringIO()\n'
            '        writer = csv.writer(output)\n'
            '        writer.writerow(["文件名", "大小(KB)", "级别", "数量"])\n'
            '        for level, count in result["levels"].items():\n'
            '            writer.writerow([\n'
            '                result["filename"],\n'
            '                result["size_kb"],\n'
            '                level, count\n'
            '            ])\n'
            '        print(output.getvalue())\n\n'
            '# 使用示例\n'
            'report = analyze_log("server.log")\n'
            'export_report(report, "json")\n'
            'export_report(report, "csv")',
            language: 'Python',
          ),

          // ═══════════════════════════════════════════════════════════
          // 交互式演示
          // ═══════════════════════════════════════════════════════════
          const _FileSimulatorDemo(),
          const _CsvJsonDemo(),
          const DividerLine(),

          // ═══════════════════════════════════════════════════════════
          // 第18节：小练习
          // ═══════════════════════════════════════════════════════════
          const SectionHeader('18. 小练习', icon: Icons.edit),
          const StepItem(step: 1, title: '文件复制工具', description: '实现一个 copy_file 函数，支持分块复制大文件，保留进度提示。使用 shutil 验证结果。'),
          const StepItem(step: 2, title: '日志统计', description: '读取一个日志文件，统计其中 ERROR/WARN/INFO 各有多少条。用 JSON 格式导出统计结果。'),
          const StepItem(step: 3, title: '编码转换器', description: '写一个程序，自动检测文件编码（尝试 utf-8/gbk），然后将文件转换为 UTF-8 编码输出。'),
          const StepItem(step: 4, title: '目录树生成器', description: '用 pathlib 递归遍历目录，生成类似 tree 命令的输出格式。排除 __pycache__ 和 .git 目录。'),
          const StepItem(step: 5, title: '配置文件解析', description: '用 with 读取 .env 文件（格式 KEY=VALUE），解析为字典。处理空行和注释行（#）。'),
          const StepItem(step: 6, title: 'CSV 转 JSON', description: '读取一个 CSV 文件，将每行数据转换为字典，最后将所有行导出为 JSON 数组文件。'),
          const StepItem(step: 7, title: '内存日志缓存', description: '用 StringIO 实现一个日志缓存器：程序运行期间日志写入内存，程序结束时根据条件决定是否写入磁盘。'),
          const StepItem(step: 8, title: '文件搜索工具', description: '用 glob 递归搜索指定目录下所有图片文件（jpg/png/gif），按文件大小从大到小排序输出。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
