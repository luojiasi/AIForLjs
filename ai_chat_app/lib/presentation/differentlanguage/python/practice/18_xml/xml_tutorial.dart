import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// XML 文档构建演示
class _XmlBuilderDemo extends StatefulWidget {
  const _XmlBuilderDemo();
  @override
  State<_XmlBuilderDemo> createState() => _XmlBuilderDemoState();
}

class _XmlBuilderDemoState extends State<_XmlBuilderDemo> {
  String _rootTag = 'bookstore';
  List<Map<String, String>> _books = [
    {'title': 'Python编程', 'author': '张三', 'price': '59.9'},
    {'title': 'Flutter实战', 'author': '李四', 'price': '79.9'},
  ];
  String _title = '';
  String _author = '';
  String _price = '29.9';

  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '29.9');

  String get _xml {
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buf.writeln('<$_rootTag>');
    for (final b in _books) {
      buf.writeln('  <book>');
      buf.writeln('    <title>${b['title']}</title>');
      buf.writeln('    <author>${b['author']}</author>');
      buf.writeln('    <price>${b['price']}</price>');
      buf.writeln('  </book>');
    }
    buf.write('</$_rootTag>');
    return buf.toString();
  }

  void _addBook() {
    if (_title.isEmpty || _author.isEmpty) return;
    setState(() {
      _books = [
        ..._books,
        {'title': _title, 'author': _author, 'price': _price.isEmpty ? '0.0' : _price},
      ];
      _title = '';
      _author = '';
      _price = '29.9';
      _titleCtrl.clear();
      _authorCtrl.clear();
      _priceCtrl.text = '29.9';
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '📄 XML 文档构建器',
      subtitle: '添加书籍记录，实时生成 XML 文档',
      children: [
        ParamTextField(
          label: '根标签',
          value: _rootTag,
          onChanged: (v) => setState(() => _rootTag = v.isEmpty ? 'bookstore' : v),
          hint: 'bookstore',
          maxLength: 20,
        ),
        const SizedBox(height: 8),
        Text('添加书籍:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _titleCtrl,
              onChanged: (v) => _title = v,
              maxLength: 20,
              decoration: InputDecoration(
                labelText: '书名',
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _authorCtrl,
              onChanged: (v) => _author = v,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: '作者',
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _priceCtrl,
              onChanged: (v) => _price = v,
              maxLength: 8,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '价格',
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: _addBook,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('添加书籍'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => setState(() => _books = []),
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('清空'),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              _xml,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.greenAccent,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(
          'import xml.etree.ElementTree as ET\n\n'
          '# 创建根元素\n'
          'root = ET.Element("$_rootTag")\n\n'
          '# 添加子元素\n'
          'book = ET.SubElement(root, "book")\n'
          'ET.SubElement(book, "title").text = "Python编程"\n'
          'ET.SubElement(book, "author").text = "张三"\n'
          'ET.SubElement(book, "price").text = "59.9"\n\n'
          '# 格式化输出\n'
          'ET.indent(root)\n'
          'tree = ET.ElementTree(root)\n'
          'tree.write("books.xml", encoding="utf-8", xml_declaration=True)',
          language: 'Python',
        ),
        LiveOutputBox('${_books.length} 本书', label: '▶ 书籍数量'),
      ],
    );
  }
}

/// Python 第18章：XML 处理教程
/// 涵盖：XML 基础、SAX/DOM/ElementTree 对比、读取/修改/构建 XML、
/// XPath、命名空间、lxml、验证、安全、流式解析、实战项目
class PythonXMLTutorial extends StatelessWidget {
  const PythonXMLTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第18章 XML处理'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① XML 基础入门\n'
            '② SAX vs DOM vs ElementTree  ③ 解析 XML\n'
            '④ 查找元素\n'
            '⑤ 遍历树\n'
            '⑥ XPath 支持\n'
            '⑦ 修改 XML\n'
            '⑧ 构建 XML\n'
            '⑨ 写入文件\n'
            '⑩ 属性与命名空间\n'
            '⑪ CDATA 节\n'
            '⑫ xml.dom.minidom\n'
            '⑬ xml.sax\n'
            '⑭ lxml 第三方库 \n'
            '⑮ DTD/Schema 验证\n'
            '⑯ XML 转 Dict/JSON\n'
            '⑰ 命名空间进阶 \n'
            '⑱ 大文件流式解析\n'
            '⑲ XXE 安全防护\n'
            '⑳ 实战项目',
          ),
          const TipBox(
            'XML 虽然不如 JSON 流行，但在配置文件、Web Services (SOAP)、'
            'Office 文档格式、Android 开发等领域仍是核心技术。掌握 XML 处理是合格 Python 开发者的必备技能。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 1. XML 基础入门
          // ═══════════════════════════════════════════════════
          const SectionHeader('1. XML 基础入门', icon: Icons.description),
          const Paragraph(
            'XML（eXtensible Markup Language）是一种可扩展标记语言，用于存储和传输数据。'
            '它使用标签（Tag）来定义数据的结构和含义，类似 HTML，但标签完全由用户自定义。',
          ),
          const CodeBlock(r'''
<!-- XML 文档的基本结构 -->
<?xml version="1.0" encoding="UTF-8"?>
<bookstore>
    <book category="programming">
        <title lang="en">Python Crash Course</title>
        <author>Eric Matthes</author>
        <price currency="USD">39.99</price>
        <stock>150</stock>
    </book>
    <book category="data-science">
        <title lang="en">Hands-On ML</title>
        <author>Aurélien Géron</author>
        <price currency="USD">54.99</price>
        <stock>85</stock>
    </book>
</bookstore>
''', language: 'XML'),
          const Paragraph(
            'XML 的核心概念包括：元素（Element）—— 由开始标签和结束标签组成的结构；'
            '属性（Attribute）—— 标签内的键值对，如 category="programming"；'
            '文本内容（Text Content）—— 标签之间的文字；'
            '良好格式（Well-formed）—— 满足 XML 基本语法规则；'
            '有效（Valid）—— 满足 DTD 或 Schema 定义的约束。',
          ),

          const SectionHeader('1.1 良好格式 vs 有效', icon: Icons.check_circle_outline),
          const Paragraph(
            '良好格式的 XML 必须满足：有且只有一个根元素、所有标签正确闭合、'
            '标签正确嵌套、属性值用引号括起。有效 XML 则在此之上进一步满足 DTD 或 XML Schema 的定义约束。',
          ),
          const TipBox(
            'Python 的标准 XML 库只能检查"良好格式"，无法自动验证"有效性"。'
            '如需验证 DTD/Schema，需要使用 lxml 或手动加载 DTD 验证。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 2. SAX vs DOM vs ElementTree
          // ═══════════════════════════════════════════════════
          const SectionHeader('2. SAX vs DOM vs ElementTree', icon: Icons.compare_arrows),
          const Paragraph(
            'Python 提供多种 XML 解析方式，选择合适的解析器取决于数据规模和操作需求：',
          ),
          const CodeBlock(r'''
# ========== 三种解析方式对比 ==========

# 【DOM】将整个 XML 加载到内存，构建树结构
#  优点：任意读取、修改、随机访问
#  缺点：内存占用高，大文件性能差
#  适用：小型 XML 文件（< 10MB）
#  Python 库：xml.dom.minidom

# 【SAX】事件驱动、流式解析，顺序读取
#  优点：内存占用极低，适合超大文件
#  缺点：只能顺序读取，不能回头访问
#  适用：超大文件、只需要提取部分数据
#  Python 库：xml.sax

# 【ElementTree】Python 推荐的标准方式
#  优点：API 简洁、性能优秀、内存适中
#  缺点：XPath 支持有限，不支持 DTD 验证
#  适用：大多数日常场景（推荐首选）
#  Python 库：xml.etree.ElementTree
''', language: 'Python'),
          const TipBox(
            '日常开发优先使用 xml.etree.ElementTree。它结合了 DOM 的便利性'
            '和 SAX 的性能优势，是 Python 官方推荐的 XML 处理方案。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 3. ElementTree 基础
          // ═══════════════════════════════════════════════════
          const SectionHeader('3. xml.etree.ElementTree 基础', icon: Icons.account_tree),
          const Paragraph(
            'xml.etree.ElementTree 是 Python 标准库中最常用的 XML 处理模块。'
            '它提供了 Element 和 ElementTree 两个核心类，以及 parse、fromstring、tostring 等便捷函数。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

# ========== 从文件解析 ==========
tree = ET.parse('books.xml')       # 解析文件 -> ElementTree 对象
root = tree.getroot()              # 获取根元素
print(root.tag)                    # 根标签名: bookstore

# ========== 从字符串解析 ==========
xml_str = '''<?xml version="1.0"?>
<note>
    <to>Alice</to>
    <from>Bob</from>
    <body>Hello!</body>
</note>'''
root2 = ET.fromstring(xml_str)     # 直接解析字符串 -> 根 Element
print(root2.tag)                   # note
print(root2[0].tag)                # to
print(root2[0].text)               # Alice

# ========== 转换为字符串 ==========
xml_bytes = ET.tostring(root2, encoding='utf-8')
print(xml_bytes.decode('utf-8'))   # 输出: <note><to>Alice</to>...
""", language: 'Python'),
          const OutputBox(
            'bookstore\n'
            'note\n'
            'to\n'
            'Alice\n'
            '<note><to>Alice</to><from>Bob</from><body>Hello!</body></note>'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 4. 查找元素
          // ═══════════════════════════════════════════════════
          const SectionHeader('4. 查找元素', icon: Icons.search),
          const Paragraph(
            'ElementTree 提供 find()、findall()、iter() 和 get() 四种查找方式。'
            '其中 find/findall 支持简单的 XPath 表达式，iter() 可以深度遍历所有子元素。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

xml_data = '''<library>
    <book id="1" genre="fiction">
        <title>1984</title>
        <author>George Orwell</author>
        <year>1949</year>
    </book>
    <book id="2" genre="non-fiction">
        <title>Sapiens</title>
        <author>Yuval Noah Harari</author>
        <year>2011</year>
    </book>
    <book id="3" genre="fiction">
        <title>Brave New World</title>
        <author>Aldous Huxley</author>
        <year>1932</year>
    </book>
</library>'''

root = ET.fromstring(xml_data)

# ---------- find() 返回第一个匹配的子元素 ----------
first_title = root.find('book/title')
print(first_title.text)            # 1984

# ---------- findall() 返回所有匹配的子元素 ----------
all_titles = root.findall('book/title')
for t in all_titles:
    print(t.text)                  # 1984, Sapiens, Brave New World

# ---------- iter() 深度遍历所有后代 ----------
for elem in root.iter('author'):
    print(elem.text)               # George Orwell, Yuval Noah Harari, Aldous Huxley

# ---------- get() 获取元素属性 ----------
first_book = root.find('book')
book_id = first_book.get('id')     # 1
genre = first_book.get('genre')    # fiction

# 为不存在的属性设置默认值
isbn = first_book.get('isbn', 'N/A')  # N/A
""", language: 'Python'),
          const OutputBox(
            '1984\n'
            '1984\n'
            'Sapiens\n'
            'Brave New World\n'
            'George Orwell\n'
            'Yuval Noah Harari\n'
            'Aldous Huxley'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 5. 遍历树
          // ═══════════════════════════════════════════════════
          const SectionHeader('5. 遍历 XML 树', icon: Icons.account_tree),
          const Paragraph(
            'Element 对象的关键属性包括：tag（标签名）、text（文本内容）、'
            'attrib（属性字典）、tail（尾部文本）。子元素可以通过列表索引或 for 循环访问。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET

root = ET.fromstring('<root><item id="1">Value 1</item><!-- comment --></root>')

# ---------- 核心属性 ----------
elem = root[0]
print(elem.tag)                  # item
print(elem.text)                 # Value 1
print(elem.attrib)               # {'id': '1'}
print(elem.attrib['id'])         # 1

# ---------- 遍历所有子元素 ----------
for child in root:
    print(f'{child.tag}: {child.text}')  # item: Value 1

# ---------- 深度优先递归遍历 ----------
def print_tree(node, indent=0):
    """递归打印 XML 树结构"""
    print(' ' * indent + f'<{node.tag}>', end='')
    if node.text and node.text.strip():
        print(f' {node.text.strip()}', end='')
    print()
    for child in node:
        print_tree(child, indent + 2)
    if node.attrib:
        print(' ' * indent + f'  attrib: {node.attrib}')

print_tree(root)
# 输出:
# <root>
#   <item> Value 1
#     attrib: {'id': '1'}
''', language: 'Python'),
          const TipBox(
            'tail 属性保存标签之后直到下一个标签之前的文本。这在解析混合内容的 XML 时非常重要，'
            '但大多数结构化数据场景中用不到它。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 6. XPath 支持
          // ═══════════════════════════════════════════════════
          const SectionHeader('6. ElementTree XPath 支持', icon: Icons.near_me),
          const Paragraph(
            'ElementTree 提供了有限但实用的 XPath 支持。完整的 XPath 表达式需要使用 lxml 库。'
            '支持以下常用语法：',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

xml_str = '''<catalog>
    <book id="b1" lang="en" price="29.99">
        <title>Learning Python</title>
    </book>
    <book id="b2" lang="en" price="39.99">
        <title>Fluent Python</title>
    </book>
    <book id="b3" lang="zh" price="49.99">
        <title>Python 实战</title>
    </book>
    <magazine id="m1" lang="en" price="9.99">
        <title>Python Weekly</title>
    </magazine>
</catalog>'''

root = ET.fromstring(xml_str)

# ---------- 常用 XPath 语法 ----------

# 1. 路径选择
books = root.findall('book')            # 所有 book 子元素
titles = root.findall('book/title')     # book 下的 title

# 2. // 后代选择（任意层级）
all_elements = root.findall('.//title') # 所有 title 后代
print([e.text for e in all_elements])

# 3. [@attr] 按属性筛选
en_books = root.findall('book[@lang]')           # 有 lang 属性的 book
en_books2 = root.findall("book[@lang='en']")     # lang="en" 的 book
print([e.find('title').text for e in en_books2])  # Learning Python, Fluent Python

# 4. [position] 按位置筛选
first_book = root.find('book[1]')                # 第一个 book
last_book = root.find('book[last()]')            # 最后一个 book

# 5. 组合查询
en_titles = root.findall("book[@lang='en']/title")
for t in en_titles:
    print(t.text)  # Learning Python, Fluent Python
""", language: 'Python'),
          const OutputBox(
            "['Learning Python', 'Fluent Python', 'Python 实战', 'Python Weekly']\n"
            'Learning Python\n'
            'Fluent Python\n'
            'Learning Python\n'
            'Fluent Python'
          ),
          const TipBox(
            'ElementTree 的 XPath 仅支持部分语法：不支持 // 前导（需用 .//）、'
            '不支持 | 运算符、不支持函数如 contains()、not()。'
            '如果依赖这些功能，请使用 lxml。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 7. 修改 XML
          // ═══════════════════════════════════════════════════
          const SectionHeader('7. 修改 XML 文档', icon: Icons.edit),
          const Paragraph(
            'ElementTree 支持在内存中修改 XML 树结构：可以修改文本、设置属性、'
            '添加/删除子元素。所有操作在内存中进行，最后通过 write() 持久化。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET

root = ET.fromstring('<library><book><title>Old Title</title></book></library>')
book = root.find('book')

# ---------- 修改文本 ----------
title = book.find('title')
title.text = 'New Title'            # 更新文本内容

# ---------- 修改/添加属性 ----------
book.set('id', '001')               # 添加 id 属性
book.set('status', 'available')     # 添加 status 属性
print(book.attrib)                  # {'id': '001', 'status': 'available'}

# ---------- 删除属性 ----------
del book.attrib['status']           # 删除 status 属性

# ---------- 添加子元素 ----------
author = ET.SubElement(book, 'author')
author.text = 'John Smith'

year = ET.SubElement(book, 'year')
year.text = '2024'

# ---------- 插入到指定位置 ----------
price = ET.Element('price')
price.text = '29.99'
# 在 year 之前插入 price
book.insert(list(book).index(book.find('year')), price)

# ---------- 删除子元素 ----------
book.remove(book.find('year'))      # 删除 year 元素

# 查看修改结果
ET.dump(root)
# <library><book id="001"><title>New Title</title><author>John Smith</author><price>29.99</price></book></library>
''', language: 'Python'),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 8. 构建 XML
          // ═══════════════════════════════════════════════════
          const SectionHeader('8. 从零构建 XML', icon: Icons.build),
          const Paragraph(
            '使用 Element() 和 SubElement() 可以从头创建 XML 文档。'
            '这是一种比字符串拼接更安全、更优雅的方式。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET
from xml.dom import minidom

# ---------- 方法1：Element + SubElement ----------
root = ET.Element('bookstore')

# 添加第一个 book
book1 = ET.SubElement(root, 'book')
book1.set('category', 'programming')

title1 = ET.SubElement(book1, 'title')
title1.text = 'Python Crash Course'
title1.set('lang', 'en')

author1 = ET.SubElement(book1, 'author')
author1.text = 'Eric Matthes'

price1 = ET.SubElement(book1, 'price')
price1.text = '39.99'

# 添加第二个 book
book2 = ET.SubElement(root, 'book')
book2.set('category', 'web')

ET.SubElement(book2, 'title').text = 'Flask Web Development'
ET.SubElement(book2, 'author').text = 'Miguel Grinberg'
ET.SubElement(book2, 'price').text = '34.99'

# ---------- 方法2：辅助函数（推荐） ----------
def make_book(category, title, author, price):
    """创建 book 元素的工厂函数"""
    book = ET.Element('book', attrib={'category': category})
    ET.SubElement(book, 'title').text = title
    ET.SubElement(book, 'author').text = author
    ET.SubElement(book, 'price').text = str(price)
    return book

root2 = ET.Element('bookstore')
root2.append(make_book('database', 'SQL Alchemy', 'John Smith', 49.99))
root2.append(make_book('devops', 'Docker Deep Dive', 'Jane Doe', 44.99))

# ---------- 格式化为美观输出 ----------
def pretty_print(element):
    """使用 minidom 美化 XML 输出"""
    rough_string = ET.tostring(element, encoding='unicode')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent='  ')

print(pretty_print(root))
''', language: 'Python'),
          const OutputBox(
            '<?xml version="1.0" ?>\n'
            '<bookstore>\n'
            '  <book category="programming">\n'
            '    <title lang="en">Python Crash Course</title>\n'
            '    <author>Eric Matthes</author>\n'
            '    <price>39.99</price>\n'
            '  </book>\n'
            '  <book category="web">\n'
            '    <title>Flask Web Development</title>\n'
            '    <author>Miguel Grinberg</author>\n'
            '    <price>34.99</price>\n'
            '  </book>\n'
            '</bookstore>'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 9. 写入 XML 文件
          // ═══════════════════════════════════════════════════
          const SectionHeader('9. 写入 XML 文件', icon: Icons.save),
          const Paragraph(
            '修改或构建完 XML 后，使用 ElementTree.write() 写入文件。'
            '默认输出是紧凑的（无缩进），需要借助 minidom 或自定义函数来美化。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET

# ---------- 基本写入 ----------
root = ET.Element('config')
ET.SubElement(root, 'mode').text = 'production'
ET.SubElement(root, 'debug').text = 'false'

tree = ET.ElementTree(root)
tree.write('config.xml',
           encoding='utf-8',
           xml_declaration=True)    # 包含 <?xml version="1.0"?>

# ---------- 美化写入（自定义缩进） ----------
def indent(elem, level=0):
    """为 Element 树添加缩进（Python 3.9+ 可直接用 ET.indent）"""
    i = '\n' + level * '  '
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + '  '
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for child in elem:
            indent(child, level + 1)
        if not child.tail or not child.tail.strip():
            child.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

indent(root)
tree.write('config_pretty.xml', encoding='utf-8', xml_declaration=True)

# ---------- Python 3.9+ 内置缩进 ----------
# 如果你用 Python 3.9+，可以直接：
# ET.indent(root, space='  ', level=0)
# tree.write('config_indent.xml', encoding='utf-8', xml_declaration=True)
''', language: 'Python'),
          const TipBox(
            'Python 3.9 引入了 ET.indent() 函数，可以直接对 Element 树进行格式化缩进。'
            '如果版本低于 3.9，可以使用 minidom 的 toprettyxml() 来美化输出。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 10. 属性与命名空间
          // 10. 属性与命名空间
          const SectionHeader('10. 属性与命名空间', icon: Icons.label),
          const Paragraph(
            'XML 属性位于开始标签内，以键值对形式存在。命名空间（xmlns）用于避免元素名冲突，'
            '在 ElementTree 中使用 {uri}tag 的 Clark 标记法表示。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

# ========== 属性操作 ==========
root = ET.Element('root')
root.set('version', '1.0')
root.set('xmlns', 'http://example.com/ns')

print(root.attrib)                     # {'version': '1.0', 'xmlns': '...'}
print(root.get('version'))             # 1.0
print(root.get('lang', 'en'))          # 带默认值: en

# 批量设置属性
root.attrib.update({'id': 'x001', 'status': 'active'})
del root.attrib['status']              # 删除属性

# ========== 命名空间处理 ==========
# 带命名空间的 XML
ns_xml = '''<root xmlns:h="http://www.w3.org/TR/html4/"
                xmlns:f="http://www.w3.org/TR/furniture/">
    <h:table>
        <h:tr><h:td>Apple</h:td><h:td>30</h:td></h:tr>
    </h:table>
    <f:table>
        <f:name>Coffee Table</f:name>
        <f:width>80</f:width>
    </f:table>
</root>'''

root_ns = ET.fromstring(ns_xml)

# 使用 {uri}tag 语法查找命名空间元素
ns = {
    'h': 'http://www.w3.org/TR/html4/',
    'f': 'http://www.w3.org/TR/furniture/',
}

# 完整的 tag 名称
for elem in root_ns.iter(f'{{{ns["h"]}}}td'):
    print(elem.text)  # Apple, 30

for elem in root_ns.iter(f'{{{ns["f"]}}}name'):
    print(elem.text)  # Coffee Table

# 简化的 findall（支持前缀映射）
# 注意：ElementTree 的 find/findall 不支持带前缀的路径
# 正确方式：
for table in root_ns.findall(f'{{{ns["h"]}}}table'):
    print(ET.tostring(table, encoding='unicode'))
""", language: 'Python'),
          const OutputBox(
            "{'version': '1.0', 'xmlns': 'http://example.com/ns'}\n"
            'Apple\n'
            '30\n'
            'Coffee Table'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 11. CDATA 节
          // ═══════════════════════════════════════════════════
          const SectionHeader('11. CDATA 节', icon: Icons.code),
          const Paragraph(
            'CDATA 节用于在 XML 中包含不应被解析的文本块，比如 JavaScript 代码或包含大量 '
            '特殊字符（<, >, &）的文本。ElementTree 默认不会保留 CDATA 标记。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET
import re

# ========== 手动构建包含 CDATA 的 XML ==========
# ElementTree 没有内置 CDATA 支持，需要使用文本拼接
root = ET.Element('script')

# 方法1：用 text 包含 CDATA 标记（不是真正的 CDATA）
script_elem = ET.SubElement(root, 'code')
script_elem.text = '<![CDATA[ console.log("hello & world"); ]]>'

# 方法2：序列化后替换（推荐）
def cdata_wrap(text):
    """将文本包装为 CDATA 节"""
    return f'<![CDATA[{text}]]>'

code_block = ET.SubElement(root, 'javascript')
code_block.text = cdata_wrap('if (x < 5 && y > 2) { alert("OK"); }')

# ========== 使用 lxml 处理 CDATA（推荐） ==========
try:
    from lxml import etree
    root_lxml = etree.Element('data')
    content = etree.SubElement(root_lxml, 'content')
    content.text = etree.CDATA('<special>characters & stuff</special>>')
    print(etree.tostring(root_lxml, pretty_print=True).decode())
except ImportError:
    print('lxml 未安装，请执行: pip install lxml')
''', language: 'Python'),
          const TipBox(
            '如果项目需要频繁处理 CDATA，强烈推荐使用 lxml。标准库 ElementTree 不直接支持 CDATA，'
            'hack 方式可能导致序列化问题。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 12. xml.dom.minidom
          // ═══════════════════════════════════════════════════
          const SectionHeader('12. xml.dom.minidom —— DOM 解析', icon: Icons.dns),
          const Paragraph(
            'xml.dom.minidom 是 Python 标准库中的最小化 DOM 实现。它将整个 XML 文档加载到内存中，'
            '构建完整的 DOM 树，支持任意方向的导航和修改。特别适合美化 XML 输出。',
          ),
          const CodeBlock(r"""
from xml.dom import minidom

# ========== 解析 XML ==========
doc = minidom.parse('books.xml')
# 或从字符串解析
# doc = minidom.parseString('<root><item>text</item></root>')

# ========== 访问元素 ==========
root = doc.documentElement              # 根元素
print(root.tagName)                     # bookstore

# getElementsByTagName 返回所有匹配标签
books = doc.getElementsByTagName('book')
for book in books:
    title = book.getElementsByTagName('title')[0]
    author = book.getElementsByTagName('author')[0]
    print(f'{title.firstChild.data} by {author.firstChild.data}')

# ========== 访问属性 ==========
for book in books:
    category = book.getAttribute('category')
    print(f'Category: {category}')

# ========== 美化 XML 输出 ==========
ugly_xml = '''<root><item><name>test</name><value>42</value></item></root>'''
dom = minidom.parseString(ugly_xml)
pretty = dom.toprettyxml(indent='  ')
print(pretty)
""", language: 'Python'),
          const OutputBox(
            '<?xml version="1.0" ?>\n'
            '<root>\n'
            '  <item>\n'
            '    <name>test</name>\n'
            '    <value>42</value>\n'
            '  </item>\n'
            '</root>'
          ),
          const TipBox(
            'minidom 的功能比 ElementTree 更丰富（如 DTD 加载、命名空间处理），'
            '但 API 更冗长，性能更差。建议只在需要 DOM 标准 API 或美化输出时使用。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 13. xml.sax
          // ═══════════════════════════════════════════════════
          const SectionHeader('13. xml.sax —— SAX 事件驱动解析', icon: Icons.speed),
          const Paragraph(
            'SAX（Simple API for XML）是一种事件驱动的流式解析方式。它顺序读取 XML 文档，'
            '遇到开始标签、结束标签、文本等事件时调用回调函数。内存占用极低，适合处理超大文件。',
          ),
          const CodeBlock(r'''
import xml.sax

# ========== 自定义 ContentHandler ==========
class BookHandler(xml.sax.ContentHandler):
    """自定义 SAX 处理器：提取书名和作者"""

    def __init__(self):
        super().__init__()
        self.current_tag = ''
        self.current_data = {}
        self.books = []

    def startElement(self, tag, attrs):
        """遇到开始标签时调用"""
        self.current_tag = tag
        if tag == 'book':
            self.current_data = {'category': attrs.get('category', '')}
            self.current_data['id'] = attrs.get('id', '')

    def endElement(self, tag):
        """遇到结束标签时调用"""
        if tag == 'book':
            # 收集完一本书的数据
            self.books.append(self.current_data.copy())
            self.current_data = {}
        self.current_tag = ''

    def characters(self, content):
        """遇到文本内容时调用"""
        if self.current_tag in ('title', 'author', 'year', 'price'):
            stripped = content.strip()
            if stripped:
                self.current_data[self.current_tag] = stripped

# ========== 使用 SAX 解析 ==========
handler = BookHandler()
xml.sax.parse('books.xml', handler)

# 输出提取的数据
for book in handler.books:
    print(f"{book.get('title', 'N/A')} - {book.get('author', 'N/A')}")

# ========== 流式解析大文件 ==========
# 对于超大 XML 文件（几百 MB），SAX 是唯一可行的方案
# 因为它不需要将整个文档加载到内存
class FastParser(xml.sax.ContentHandler):
    def __init__(self, target_tag):
        self.target_tag = target_tag
        self.in_target = False

    def startElement(self, tag, attrs):
        if tag == self.target_tag:
            self.in_target = True
            print(f'Found {tag}: {attrs.items()}')

    def endElement(self, tag):
        if tag == self.target_tag:
            self.in_target = False

# 用 SAX 从超大 XML 中快速提取指定标签
parser = xml.sax.make_parser()
parser.setContentHandler(FastParser('book'))
parser.parse('huge_books.xml')  # 即使文件 1GB 也没问题
''', language: 'Python'),
          const TipBox(
            'SAX 的核心优势是内存效率。处理超大文件（> 500MB）时，DOM 和 ElementTree 都可能 Out of Memory，'
            '只有 SAX 可以胜任。缺点是代码较复杂，且不能随机访问。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 14. lxml 第三方库
          // ═══════════════════════════════════════════════════
          const SectionHeader('14. lxml —— 强大的第三方 XML 库', icon: Icons.extension),
          const Paragraph(
            'lxml 是 Python 最强大的 XML/HTML 处理库。它基于 C 语言 libxml2 和 libxslt，'
            '性能极佳，功能远超标准库。支持完整 XPath 1.0、XSLT、Schema 验证、HTML 解析等。',
          ),
          const CodeBlock(r"""
# lxml 是第三方库，需要安装：
# pip install lxml

# ========== 核心 API（类似 ElementTree）==========
from lxml import etree

# 解析
root = etree.parse('books.xml').getroot()
root2 = etree.fromstring('<root><item>text</item></root>')

# ========== 完整 XPath 1.0 支持 ==========
xml_str = '''<books>
    <book lang="en" price="29.99">
        <title>Python 101</title>
        <author>John</author>
    </book>
    <book lang="en" price="49.99">
        <title>Advanced Python</title>
        <author>Jane</author>
    </book>
    <book lang="zh" price="39.99">
        <title>Python 从入门到精通</title>
        <author>Wang</author>
    </book>
</books>'''
root = etree.fromstring(xml_str)

# 标准库做不到的 XPath：
result = root.xpath('//book[price > 30]')
print(len(result))                      # 2

# contains() 函数
result = root.xpath("//book[contains(title, 'Python')]")
print(len(result))                      # 3

# 多个条件组合
result = root.xpath("//book[@lang='en' and price > 35]/title/text()")
print(result)                           # ['Advanced Python']

# ========== XSLT 转换 ==========
xslt_str = '''<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html><body>
        <xsl:for-each select="books/book">
            <p><xsl:value-of select="title"/></p>
        </xsl:for-each>
        </body></html>
    </xsl:template>
</xsl:stylesheet>'''
xslt_root = etree.fromstring(xslt_str)
transform = etree.XSLT(xslt_root)
html_result = transform(root)
print(str(html_result)[:200])           # <html><body><p>Python 101</p>...
""", language: 'Python'),
          const OutputBox(
            '2\n'
            '3\n'
            "['Advanced Python']\n"
            '<html><body><p>Python 101</p><p>Advanced Python</p><p>Python '
            '从入门到精通</p></body></html>'
          ),
          const TipBox(
            'lxml 在性能、功能和易用性上全面超越标准库。如果你的项目需要频繁处理 XML，'
            '强烈建议使用 lxml。它也是 BeautifulSoup 的底层 HTML 解析器之一。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 15. XML 验证
          // ═══════════════════════════════════════════════════
          const SectionHeader('15. XML 验证 —— DTD 与 Schema', icon: Icons.verified),
          const Paragraph(
            'XML 验证确保文档符合预定义的结构规则。DTD（Document Type Definition）语法较老但广泛使用；'
            'XML Schema（XSD）更为强大，支持数据类型和命名空间。两者都需要 lxml 支持。',
          ),
          const CodeBlock(r"""
# ========== DTD 验证（lxml）==========
from lxml import etree

dtd_text = '''
<!ELEMENT bookstore (book+)>
<!ELEMENT book (title, author, price, year)>
<!ELEMENT title (#PCDATA)>
<!ELEMENT author (#PCDATA)>
<!ELEMENT price (#PCDATA)>
<!ELEMENT year (#PCDATA)>
<!ATTLIST book category CDATA #REQUIRED>
'''

valid_xml = '''<bookstore>
    <book category="programming">
        <title>Python</title>
        <author>Guido</author>
        <price>29.99</price>
        <year>2023</year>
    </book>
</bookstore>'''

# 创建 DTD 并验证
dtd = etree.DTD(etree.fromstring(dtd_text))
doc = etree.fromstring(valid_xml)
print(dtd.validate(doc))                # True

# 如果验证失败，查看错误
invalid_xml = valid_xml.replace('<price>', '<invalid>')
doc2 = etree.fromstring(invalid_xml)
if not dtd.validate(doc2):
    print(dtd.error_log)                # 错误详情

# ========== XML Schema (XSD) 验证 ==========
xsd_text = '''<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="bookstore">
        <xs:complexType>
            <xs:sequence>
                <xs:element name="book" maxOccurs="unbounded">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="title" type="xs:string"/>
                            <xs:element name="author" type="xs:string"/>
                            <xs:element name="price" type="xs:decimal"/>
                            <xs:element name="year" type="xs:integer"/>
                        </xs:sequence>
                        <xs:attribute name="category" type="xs:string" use="required"/>
                    </xs:complexType>
                </xs:element>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
</xs:schema>'''

xsd_doc = etree.fromstring(xsd_text)
schema = etree.XMLSchema(xsd_doc)

doc3 = etree.fromstring(valid_xml)
print(schema.validate(doc3))            # True
""", language: 'Python'),
          const OutputBox('True\nTrue'),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 16. XML 转 Dict/JSON/DataFrame
          // ═══════════════════════════════════════════════════
          const SectionHeader('16. XML 转换：Dict / JSON / DataFrame', icon: Icons.transform),
          const Paragraph(
            '在实际项目中，经常需要将 XML 转换为更易处理的格式。Python 社区有许多工具可以完成转换，'
            '下面介绍最常用的几种方式。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET
import json

# ========== XML 转 Dict ==========
xml_data = '''<person>
    <name>Alice</name>
    <age>30</age>
    <skills>
        <skill>Python</skill>
        <skill>Java</skill>
        <skill>Docker</skill>
    </skills>
    <address>
        <city>Beijing</city>
        <zip>100000</zip>
    </address>
</person>'''

def xml_to_dict(element):
    '''递归将 Element 转换为字典'''
    result = {}
    # 处理子元素
    for child in element:
        child_dict = xml_to_dict(child)
        if child.tag in result:
            # 处理同名标签（转为列表）
            if not isinstance(result[child.tag], list):
                result[child.tag] = [result[child.tag]]
            result[child.tag].append(child_dict)
        else:
            result[child.tag] = child_dict
    # 处理文本内容
    if result:
        if element.text and element.text.strip():
            result['#text'] = element.text.strip()
        return result
    return element.text.strip() if element.text else ''

root = ET.fromstring(xml_data)
person_dict = xml_to_dict(root)
print(person_dict)
# {'name': 'Alice', 'age': '30',
#  'skills': {'skill': ['Python', 'Java', 'Docker']},
#  'address': {'city': 'Beijing', 'zip': '100000'}}

# ========== Dict 转 JSON ==========
person_json = json.dumps(person_dict, indent=2, ensure_ascii=False)
print(person_json)

# ========== XML 转 pandas DataFrame ==========
import pandas as pd

xml_flat = '''<records>
    <record><name>Alice</name><age>30</age><city>Beijing</city></record>
    <record><name>Bob</name><age>25</age><city>Shanghai</city></record>
    <record><name>Charlie</name><age>35</age><city>Shenzhen</city></record>
</records>'''

root2 = ET.fromstring(xml_flat)

# 提取为列表的列表
data = []
for record in root2.findall('record'):
    row = {}
    for child in record:
        row[child.tag] = child.text
    data.append(row)

df = pd.DataFrame(data)
print(df)
#       name age      city
# 0    Alice  30   Beijing
# 1      Bob  25  Shanghai
# 2  Charlie  35  Shenzhen
""", language: 'Python'),
          const OutputBox(
            "{'name': 'Alice', 'age': '30', 'skills': {'skill': ['Python', 'Java', 'Docker']}, "
            "'address': {'city': 'Beijing', 'zip': '100000'}}\n"
            '{\n'
            '  "name": "Alice",\n'
            '  "age": "30",\n'
            '  ...\n'
            '}'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 17. 命名空间进阶
          // ═══════════════════════════════════════════════════
          const SectionHeader('17. 命名空间进阶处理', icon: Icons.layers),
          const Paragraph(
            '复杂 XML 文档通常包含多个命名空间。ElementTree 使用完整的命名空间 URI 来匹配元素，'
            '而 lxml 支持更方便的命名空间前缀映射。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

# ========== 复杂的多命名空间 XML ==========
xml_str = '''<?xml version="1.0"?>
<root xmlns:ns1="http://example.com/ns1"
      xmlns:ns2="http://example.com/ns2">
    <ns1:item id="1">
        <ns1:name>Item A</ns1:name>
        <ns2:price currency="USD">10.99</ns2:price>
    </ns1:item>
    <ns1:item id="2">
        <ns1:name>Item B</ns1:name>
        <ns2:price currency="EUR">12.50</ns2:price>
    </ns1:item>
    <ns2:discount>5%</ns2:discount>
</root>'''

root = ET.fromstring(xml_str)

# ---------- 定义命名空间映射 ----------
ns = {
    'ns1': 'http://example.com/ns1',
    'ns2': 'http://example.com/ns2',
}

# ---------- 使用完整 URI 查找 ----------
# 正确写法：{uri}tag
for item in root.findall(f'{{{ns["ns1"]}}}item'):
    name = item.find(f'{{{ns["ns1"]}}}name')
    price = item.find(f'{{{ns["ns2"]}}}price')
    print(f'{name.text}: {price.text} {price.get("currency")}')

# ---------- 使用 lxml 的 nsmap（推荐）----------
from lxml import etree

root_lxml = etree.fromstring(xml_str.encode())
# lxml 自动识别命名空间
print(root_lxml.nsmap)
# {'ns1': 'http://example.com/ns1', 'ns2': 'http://example.com/ns2'}

# 使用命名空间前缀
items = root_lxml.xpath('//ns1:item',
                        namespaces={'ns1': 'http://example.com/ns1'})
for item in items:
    name = item.find('ns1:name', root_lxml.nsmap)
    print(name.text)  # Item A, Item B
""", language: 'Python'),
          const OutputBox(
            'Item A: 10.99 USD\n'
            'Item B: 12.50 EUR\n'
            "Item A\n"
            'Item B'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 18. 大文件流式解析
          // ═══════════════════════════════════════════════════
          const SectionHeader('18. 大文件流式解析：iterparse()', icon: Icons.stream),
          const Paragraph(
            '对于超大型 XML 文件（几百 MB 到 GB 级别），使用 iterparse() 进行增量式解析是推荐方案。'
            '它在读取文档的同时处理数据，不会将整个文档加载到内存。',
          ),
          const CodeBlock(r'''
import xml.etree.ElementTree as ET

# ========== iterparse 流式处理 ==========
# 假设有一个巨大的 XML 文件，包含数百万条记录
# 例如维基百科数据导出文件（可达数十 GB）

def process_huge_xml(file_path, target_tag='record'):
    """
    流式处理超大 XML 文件
    - 每次只处理一个 target_tag 元素
    - 处理完后立即释放内存
    """
    count = 0
    total_value = 0.0

    # iterparse 返回 (event, elem) 对
    # event 可以是 'start'（遇到开始标签）或 'end'（遇到结束标签）
    for event, elem in ET.iterparse(file_path, events=('end',)):
        # 只处理目标元素
        if elem.tag == target_tag:
            # 提取数据
            name = elem.find('name')
            value = elem.find('value')

            if name is not None and value is not None:
                count += 1
                total_value += float(value.text)

                # 每处理 10000 条记录，输出进度
                if count % 10000 == 0:
                    print(f'已处理 {count} 条记录...')

            # 关键步骤：清除已处理的元素，释放内存
            elem.clear()

            # 可选：清理父元素的废弃子节点
            # 找到根元素并清理
            if count % 1000 == 0:
                root = elem.getparent()
                if root is not None:
                    while root.getchildren():
                        root.remove(root[0])

    print(f'处理完成！共 {count} 条记录，总值: {total_value}')

# ========== 选择性解析（只提取需要的数据）==========
def extract_specific_tags(file_path, tags_to_extract):
    """
    只提取指定标签中的数据，跳过不需要的部分
    适合从巨型 XML 中提取少量字段
    """
    results = {tag: [] for tag in tags_to_extract}

    for event, elem in ET.iterparse(file_path, events=('end',)):
        if elem.tag in tags_to_extract:
            results[elem.tag].append(elem.text)
        elem.clear()

    return results
''', language: 'Python'),
          const TipBox(
            '使用 iterparse 时，一定要调用 elem.clear() 释放内存！'
            '如果不清理，iterparse 会保留所有已处理的元素引用，内存占用和 DOM 解析一样高，'
            '失去流式处理的意义。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 19. XXE 安全防护
          // ═══════════════════════════════════════════════════
          const SectionHeader('19. XXE 安全防护', icon: Icons.security),
          const Paragraph(
            'XXE（XML External Entity）是一种严重的安全漏洞。攻击者通过在 XML 中嵌入外部实体，'
            '可以读取服务器文件、发起 SSRF 攻击、甚至执行拒绝服务攻击（如 Billion Laughs 攻击）。',
          ),
          const CodeBlock(r"""
# ========== 什么是 XXE 攻击 ==========
# 攻击者构造如下 XML，expands 到内存耗尽（Billion Laughs 攻击）：
xxe_payload = '''<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
]>
<root>&lol3;</root>'''

# ========== 安全防护方案 ==========

# 方案1：使用 defusedxml（推荐）
# pip install defusedxml
from defusedxml import ElementTree as safe_ET

try:
    # defusedxml 会自动阻止 XXE 攻击
    safe_ET.fromstring(xxe_payload)
    print('解析成功（不应该发生）')
except Exception as e:
    print(f'已阻止 XXE 攻击: {e}')
    # 输出: Entities are not allowed

# 方案2：手动禁用实体解析（标准库）
from xml.etree.ElementTree import XMLParser, ParseError

parser = XMLParser()
# 注意：标准库 ElementTree 默认就禁止了实体解析
# 但为了兼容性，建议明确处理
try:
    root = ET.fromstring(xxe_payload)
except ParseError as e:
    print(f'标准库默认阻止: {e}')

# 方案3：lxml 的安全解析
from lxml import etree

# lxml 默认也禁止外部实体
parser_lxml = etree.XMLParser(
    resolve_entities=False,    # 禁止实体解析
    no_network=True,           # 禁止网络访问
    dtd_validation=False       # 禁止 DTD 验证
)
try:
    root_lxml = etree.fromstring(xxe_payload, parser_lxml)
except etree.XMLSyntaxError as e:
    print(f'lxml 已阻止: {e}')
""", language: 'Python'),
          const OutputBox(
            '已阻止 XXE 攻击: Entities are not allowed\n'
            '标准库默认阻止: undefined entity &lol;\n'
            "lxml 已阻止: Entity 'lol' not defined"
          ),
          const TipBox(
            '生产环境中解析用户提供的 XML 时，务必使用 defusedxml 库！'
            '这是 Python 安全指南中明确推荐的方案，可以防御 XXE、Billion Laughs 等攻击。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 20. 实战项目
          // ═══════════════════════════════════════════════════
          const SectionHeader('20. 实战项目', icon: Icons.rocket_launch),
          const Paragraph(
            '下面展示两个实用项目：RSS 阅读器和 XML 配置文件解析器。'
            '它们综合运用了本章讲解的绝大部分技术。',
          ),
          const SectionHeader('20.1 RSS 阅读器', icon: Icons.rss_feed),
          const Paragraph(
            'RSS（Really Simple Syndication）使用 XML 格式发布内容更新。'
            '下面实现一个简单的 RSS 阅读器，提取博客文章标题和链接。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET
import urllib.request
from datetime import datetime

def fetch_rss(url):
    '''
    获取 RSS 订阅源，提取最新文章
    实际使用时替换 url 为真实 RSS 地址
    '''
    # 模拟 RSS XML 数据
    sample_rss = '''<?xml version="1.0"?>
    <rss version="2.0">
        <channel>
            <title>Python Tech Blog</title>
            <link>https://python.example.com</link>
            <description>Latest Python articles</description>
            <item>
                <title>Python 3.12 New Features</title>
                <link>https://python.example.com/312</link>
                <pubDate>Mon, 15 Apr 2024 10:00:00 GMT</pubDate>
                <category>python</category>
            </item>
            <item>
                <title>Understanding Async/Await</title>
                <link>https://python.example.com/async</link>
                <pubDate>Fri, 12 Apr 2024 14:30:00 GMT</pubDate>
                <category>async</category>
            </item>
            <item>
                <title>FastAPI Best Practices</title>
                <link>https://python.example.com/fastapi</link>
                <pubDate>Wed, 10 Apr 2024 09:00:00 GMT</pubDate>
                <category>web</category>
            </item>
        </channel>
    </rss>'''

    root = ET.fromstring(sample_rss)
    channel = root.find('channel')

    blog_title = channel.findtext('title')
    print(f'=== {blog_title} ===')
    print()

    for item in channel.findall('item'):
        title = item.findtext('title', 'N/A')
        link = item.findtext('link', '#')
        pub_date = item.findtext('pubDate', 'Unknown')
        category = item.findtext('category', 'general')

        print(f'  [{category.upper()}]')
        print(f'  {title}')
        print(f'  {link}')
        print(f'  Published: {pub_date}')
        print()

fetch_rss('https://python.example.com/rss')
""", language: 'Python'),
          const OutputBox(
            '=== Python Tech Blog ===\n\n'
            '  [PYTHON]\n'
            '  Python 3.12 New Features\n'
            '  https://python.example.com/312\n'
            '  Published: Mon, 15 Apr 2024 10:00:00 GMT\n\n'
            '  [ASYNC]\n'
            '  Understanding Async/Await\n'
            '  https://python.example.com/async\n'
            '  Published: Fri, 12 Apr 2024 14:30:00 GMT\n\n'
            '  [WEB]\n'
            '  FastAPI Best Practices\n'
            '  https://python.example.com/fastapi\n'
            '  Published: Wed, 10 Apr 2024 09:00:00 GMT'
          ),
          const DividerLine(),

          const SectionHeader('20.2 XML 配置解析器', icon: Icons.settings),
          const Paragraph(
            '很多应用使用 XML 作为配置文件格式。下面实现一个健壮的配置解析器，'
            '支持嵌套结构、类型转换和默认值。',
          ),
          const CodeBlock(r"""
import xml.etree.ElementTree as ET

class XMLConfigParser:
    '''XML 配置文件解析器'''

    def __init__(self, file_path=None):
        self.data = {}
        if file_path:
            self.load(file_path)

    def load(self, file_path):
        '''从 XML 文件加载配置'''
        tree = ET.parse(file_path)
        root = tree.getroot()
        self.data = self._parse_element(root)

    def load_string(self, xml_string):
        '''从 XML 字符串加载配置'''
        root = ET.fromstring(xml_string)
        self.data = self._parse_element(root)

    def _parse_element(self, elem):
        '''递归解析元素'''
        result = {}

        # 处理属性
        for key, value in elem.attrib.items():
            result[f'@{key}'] = value

        # 处理子元素
        children_text = {}
        children_objects = {}

        for child in elem:
            if len(child) > 0 or child.attrib:
                # 有子元素或属性 -> 递归
                child_data = self._parse_element(child)
                children_objects.setdefault(child.tag, [])
                children_objects[child.tag].append(child_data)
            else:
                # 纯文本元素
                children_text[child.tag] = child.text

        # 合并纯文本子元素
        result.update(children_text)

        # 处理重复标签（转为列表）
        for tag, items in children_objects.items():
            if len(items) == 1:
                result[tag] = items[0]
            else:
                result[tag] = items

        # 如果只有文本内容
        if not result and elem.text:
            return elem.text

        return result

    def get(self, key, default=None):
        '''获取配置值'''
        keys = key.split('.')
        value = self.data
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default

    def __repr__(self):
        return f'XMLConfig({self.data})'

# ========== 使用示例 ==========
config_xml = '''<config>
    <app>
        <name>MyApp</name>
        <version>2.0.1</version>
        <debug>true</debug>
    </app>
    <database>
        <host>localhost</host>
        <port>5432</port>
        <pool>
            <min>5</min>
            <max>20</max>
        </pool>
    </database>
    <feature>
        <item name="auth">enabled</item>
        <item name="logging">enabled</item>
        <item name="caching">disabled</item>
    </feature>
</config>'''

parser = XMLConfigParser()
parser.load_string(config_xml)

print(parser.get('app.name'))            # MyApp
print(parser.get('database.host'))       # localhost
print(parser.get('database.pool.max'))   # 20
print(parser.get('app.nonexistent', 'N/A'))  # N/A
print(parser.get('feature.item.0.@name'))    # auth
print(parser.get('feature.item.1'))          # enabled
""", language: 'Python'),
          const OutputBox(
            'MyApp\n'
            'localhost\n'
            '20\n'
            'N/A\n'
            'auth\n'
            'enabled'
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════════════
          // 总结
          // ═══════════════════════════════════════════════════
          const SectionHeader('总结', icon: Icons.summarize),
          const Paragraph(
            '本章全面介绍了 Python 处理 XML 的方方面面：从标准库的 xml.etree.ElementTree 到 '
            '第三方库 lxml，从 SAX/DOM/ElementTree 的架构对比到 XXE 安全防护。选择什么工具取决于场景：'
            '日常使用 ElementTree，需要完整 XPath 和验证时用 lxml，处理超大文件时用 SAX 或 iterparse。'
            '无论使用哪种库，安全始终是第一位的——务必使用 defusedxml 防御 XXE 攻击。',
          ),
          const TipBox(
            '下一步推荐学习：JSON/YAML/TOML 等序列化格式与 XML 的对比。'
            '在大多数 Web API 场景中，JSON 更为简洁；而 XML 在文档标记、'
            '混合内容和强验证场景中仍有不可替代的优势。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
