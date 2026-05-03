import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Demo: collections 模块
// ─────────────────────────────────────────────────────────────────────────────
class _CollectionsModuleDemo extends StatefulWidget {
  const _CollectionsModuleDemo();

  @override
  State<_CollectionsModuleDemo> createState() => _CollectionsModuleDemoState();
}

class _CollectionsModuleDemoState extends State<_CollectionsModuleDemo> {
  String _collectionType = 'Counter';
  String _text = 'hello world python';

  String _buildCode() {
    switch (_collectionType) {
      case 'Counter':
        return '''from collections import Counter

text = "$_text"
words = text.split()
counter = Counter(words)

# 最常见的前5个词
most_common = counter.most_common(5)
for word, count in most_common:
    print(f"{word}: {count}")''';
      case 'defaultdict':
        return '''from collections import defaultdict

# defaultdict(int) 缺失键自动返回 0
dd = defaultdict(int)
words = "$_text".split()
for word in words:
    dd[word] += 1

print(dict(dd))

# defaultdict(list) 缺失键自动返回 []
dd2 = defaultdict(list)
dd2['fruits'].append('apple')
dd2['fruits'].append('banana')
dd2['vegs'].append('carrot')
print(dict(dd2))''';
      case 'deque':
        return '''from collections import deque

# maxlen=3 的双端队列
dq = deque([1, 2, 3], maxlen=3)
print("初始:", list(dq))      # [1, 2, 3]

dq.append(4)                  # 右侧追加，左侧 1 被移除
print("append(4):", list(dq)) # [2, 3, 4]

dq.appendleft(0)              # 左侧追加，右侧 4 被移除
print("appendleft(0):", list(dq)) # [0, 2, 3]

dq.pop()                      # 移除右侧
print("pop():", list(dq))     # [0, 2]

dq.popleft()                  # 移除左侧
print("popleft():", list(dq)) # [2]''';
      case 'OrderedDict':
        return '''from collections import OrderedDict

# OrderedDict 记住插入顺序
od = OrderedDict()
od['banana'] = 3
od['apple'] = 4
od['pear'] = 1
od['orange'] = 2

for key, value in od.items():
    print(f"{key}: {value}")

# 移动到末尾
od.move_to_end('banana')
print("\\n移动 banana 到末尾:")
for key, value in od.items():
    print(f"{key}: {value}")''';
      default:
        return '';
    }
  }

  String _buildOutput() {
    switch (_collectionType) {
      case 'Counter':
        final words = _text.trim().isEmpty ? <String>[] : _text.trim().split(RegExp(r'\s+'));
        final freq = <String, int>{};
        for (final w in words) {
          freq[w] = (freq[w] ?? 0) + 1;
        }
        final sorted = freq.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top5 = sorted.take(5);
        if (top5.isEmpty) return '(无输入文本)';
        return top5.map((e) => '${e.key}: ${e.value}').join('\n');
      case 'defaultdict':
        final words = _text.trim().isEmpty ? <String>[] : _text.trim().split(RegExp(r'\s+'));
        final freq = <String, int>{};
        for (final w in words) {
          freq[w] = (freq[w] ?? 0) + 1;
        }
        final buf = StringBuffer();
        buf.writeln('defaultdict(int) 词频:');
        buf.writeln(freq.toString());
        buf.writeln();
        buf.writeln("defaultdict(list) 示例:");
        buf.writeln("{'fruits': ['apple', 'banana'], 'vegs': ['carrot']}");
        return buf.toString().trimRight();
      case 'deque':
        return '初始:       [1, 2, 3]\n'
            'append(4):  [2, 3, 4]\n'
            'appendleft(0): [0, 2, 3]\n'
            'pop():      [0, 2]\n'
            'popleft():  [2]';
      case 'OrderedDict':
        return 'banana: 3\napple: 4\npear: 1\norange: 2\n\n'
            '移动 banana 到末尾:\n'
            'apple: 4\npear: 1\norange: 2\nbanana: 3';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: 'collections 模块演示',
      children: [
        ParamChoiceChips<String>(
          label: '集合类型',
          value: _collectionType,
          options: const [
            ('Counter', 'Counter 计数器'),
            ('defaultdict', 'defaultdict'),
            ('deque', 'deque 双端队列'),
            ('OrderedDict', 'OrderedDict 有序字典'),
          ],
          onChanged: (v) => setState(() => _collectionType = v),
        ),
        if (_collectionType == 'Counter' || _collectionType == 'defaultdict')
          ParamTextField(
            label: '输入文本',
            value: _text,
            onChanged: (v) => setState(() => _text = v),
          ),
        LiveCodeBlock(_buildCode(), language: 'python'),
        LiveOutputBox(_buildOutput()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo: itertools 模块
// ─────────────────────────────────────────────────────────────────────────────
class _ItertoolsDemo extends StatefulWidget {
  const _ItertoolsDemo();

  @override
  State<_ItertoolsDemo> createState() => _ItertoolsDemoState();
}

class _ItertoolsDemoState extends State<_ItertoolsDemo> {
  String _function = 'combinations';
  int _n = 3;
  int _r = 2;

  static const _allItems = ['A', 'B', 'C', 'D'];

  List<String> get _items => _allItems.take(_n).toList();

  // Simple combinations implementation (no repetition)
  List<List<T>> _combinations<T>(List<T> pool, int r) {
    final result = <List<T>>[];
    if (r > pool.length || r <= 0) return result;
    final indices = List<int>.generate(r, (i) => i);
    result.add([for (final i in indices) pool[i]]);
    while (true) {
      int i = r - 1;
      while (i >= 0 && indices[i] == i + pool.length - r) {
        i--;
      }
      if (i < 0) break;
      indices[i]++;
      for (int j = i + 1; j < r; j++) {
        indices[j] = indices[j - 1] + 1;
      }
      result.add([for (final idx in indices) pool[idx]]);
    }
    return result;
  }

  // Simple permutations implementation
  List<List<T>> _permutations<T>(List<T> pool, int r) {
    final result = <List<T>>[];
    if (r > pool.length || r <= 0) return result;
    final indices = List<int>.generate(pool.length, (i) => i);
    final cycles = List<int>.generate(r, (i) => pool.length - i);
    result.add([for (int i = 0; i < r; i++) pool[indices[i]]]);
    while (true) {
      bool found = false;
      for (int i = r - 1; i >= 0; i--) {
        cycles[i]--;
        if (cycles[i] == 0) {
          final tmp = indices[i];
          for (int j = i; j < indices.length - 1; j++) {
            indices[j] = indices[j + 1];
          }
          indices[indices.length - 1] = tmp;
          cycles[i] = pool.length - i;
        } else {
          final j = indices.length - cycles[i];
          final tmp = indices[i];
          indices[i] = indices[j];
          indices[j] = tmp;
          result.add([for (int k = 0; k < r; k++) pool[indices[k]]]);
          found = true;
          break;
        }
      }
      if (!found) break;
    }
    return result;
  }

  String _buildCode() {
    final itemsStr = _items.map((e) => "'$e'").join(', ');
    switch (_function) {
      case 'combinations':
        return '''import itertools

items = [$itemsStr]
result = list(itertools.combinations(items, $_r))
print(f"C({_n},{_r}) = {len(result)} 种")
for combo in result:
    print(combo)''';
      case 'permutations':
        return '''import itertools

items = [$itemsStr]
result = list(itertools.permutations(items, $_r))
print(f"P({_n},{_r}) = {len(result)} 种")
for perm in result:
    print(perm)''';
      case 'chain':
        return '''import itertools

list1 = [1, 2, 3]
list2 = ['a', 'b', 'c']
list3 = [True, False]

# chain 将多个可迭代对象串联成一个
chained = list(itertools.chain(list1, list2, list3))
print(chained)
# [1, 2, 3, 'a', 'b', 'c', True, False]

# chain.from_iterable 从嵌套结构展开
nested = [[1, 2], [3, 4], [5, 6]]
flat = list(itertools.chain.from_iterable(nested))
print(flat)
# [1, 2, 3, 4, 5, 6]''';
      case 'groupby':
        return '''import itertools

# groupby 对连续相同值分组（需预先排序）
data = [1, 1, 2, 2, 3, 3, 3, 1]
data.sort()  # 先排序
for key, group in itertools.groupby(data):
    print(f"{key}: {list(group)}")

# 按字符串首字母分组
words = ['apple', 'ant', 'banana', 'bear', 'cat']
words.sort()
for letter, grp in itertools.groupby(words, key=lambda w: w[0]):
    print(f"{letter}: {list(grp)}")''';
      default:
        return '';
    }
  }

  String _buildOutput() {
    switch (_function) {
      case 'combinations':
        final combos = _combinations(_items, _r);
        final buf = StringBuffer();
        buf.writeln('C($_n,$_r) = ${combos.length} 种');
        for (final c in combos) {
          buf.writeln("(${c.map((e) => "'$e'").join(', ')})");
        }
        return buf.toString().trimRight();
      case 'permutations':
        final perms = _permutations(_items, _r);
        final buf = StringBuffer();
        buf.writeln('P($_n,$_r) = ${perms.length} 种');
        for (final p in perms) {
          buf.writeln("(${p.map((e) => "'$e'").join(', ')})");
        }
        return buf.toString().trimRight();
      case 'chain':
        return "[1, 2, 3, 'a', 'b', 'c', True, False]\n[1, 2, 3, 4, 5, 6]";
      case 'groupby':
        return '1: [1, 1]\n2: [2, 2]\n3: [3, 3, 3]\na: [\'apple\', \'ant\']\nb: [\'banana\', \'bear\']\nc: [\'cat\']';
      default:
        return '';
    }
  }

  bool get _showNR =>
      _function == 'combinations' || _function == 'permutations';

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: 'itertools 模块演示',
      children: [
        ParamChoiceChips<String>(
          label: '函数',
          value: _function,
          options: const [
            ('combinations', 'combinations 组合'),
            ('permutations', 'permutations 排列'),
            ('chain', 'chain 串联'),
            ('groupby', 'groupby 分组'),
          ],
          onChanged: (v) => setState(() => _function = v),
        ),
        if (_showNR)
          ParamIntSlider(
            label: '元素数量 n',
            value: _n,
            min: 2,
            max: 4,
            onChanged: (v) => setState(() {
              _n = v;
              if (_r > _n) _r = _n;
            }),
          ),
        if (_showNR)
          ParamIntSlider(
            label: '选取数量 r',
            value: _r,
            min: 1,
            max: 3,
            onChanged: (v) => setState(() => _r = v > _n ? _n : v),
          ),
        LiveCodeBlock(_buildCode(), language: 'python'),
        LiveOutputBox(_buildOutput()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Python 第11章：常用内建模块
/// 涵盖 datetime、collections、base64、struct、hashlib、hmac
/// itertools、contextlib、urllib、HTMLParser、json
class PythonStdlibModules extends StatelessWidget {
  const PythonStdlibModules({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第11章 常用内建模块'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① datetime（时间处理）\n'
            '② collections（扩展集合）\n'
            '③ base64（Base64编码）\n'
            '④ struct（二进制打包）\n'
            '⑤ hashlib（哈希算法） \n'
            '⑥ hmac（消息认证）\n'
            '⑦ itertools（迭代器） \n'
            '⑧ contextlib（上下文管理） \n'
            '⑨ urllib（网络请求）\n'
            '⑩ HTMLParser（HTML解析）\n'
            '⑪ json（JSON处理）',
          ),
          const TipBox(
            'Python 内置了丰富的标准库模块，日常开发中高频使用。'
            '掌握这些模块能让你事半功倍。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 1. datetime ──
          const SectionHeader('1. datetime —— 日期时间处理', icon: Icons.calendar_month),
          const Paragraph(
            'datetime 是 Python 最常用的日期时间模块。'
            '它提供 date、time、datetime、timedelta、timezone 等核心类。',
          ),
          const CodeBlock(r'''
from datetime import datetime, date, time, timedelta, timezone

# 获取当前时间
now = datetime.now()
print(f'当前时间: {now}')

# 构造指定日期
dt = datetime(2025, 12, 25, 10, 30, 0)
print(dt)  # 2025-12-25 10:30:00

# 时间戳转换
ts = dt.timestamp()
print(f'时间戳: {ts}')
print(f'从时间戳恢复: {datetime.fromtimestamp(ts)}')
''', language: 'python'),
          const Paragraph(
            'timedelta 用于时间算术运算，支持天、秒、微秒、毫秒、分钟、小时、周。',
          ),
          const CodeBlock(r'''
from datetime import datetime, timedelta

now = datetime.now()
print(f'三天后: {now + timedelta(days=3)}')
print(f'两小时前: {now - timedelta(hours=2)}')
print(f'一周后的同一时间: {now + timedelta(weeks=1)}')

# 两个日期差值
d1 = datetime(2025, 1, 1)
d2 = datetime(2025, 12, 31)
delta = d2 - d1
print(f'相差 {delta.days} 天')  # 相差 364 天
''', language: 'python'),
          const Paragraph(
            '时区处理：Python 3.9+ 推荐使用 zoneinfo 模块，'
            'Python 3.6+ 可通过 datetime.timezone 处理固定偏移。',
          ),
          const CodeBlock(r'''
from datetime import datetime, timedelta, timezone

# 创建带时区的时间
utc_dt = datetime.now(timezone.utc)
print(f'UTC 时间: {utc_dt}')

# 转换为东八区
beijing = utc_dt.astimezone(timezone(timedelta(hours=8)))
print(f'北京时间: {beijing}')

# 字符串格式化
print(beijing.strftime('%Y-%m-%d %H:%M:%S %Z'))

# 字符串解析
dt = datetime.strptime('2025-08-15 14:30:00', '%Y-%m-%d %H:%M:%S')
print(dt)
''', language: 'python'),
          const TipBox(
            'strftime/strptime 的格式详见 Ch09。'
            '建议在项目中统一使用 ISO 8601 格式存储时间字符串。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 2. collections ──
          const SectionHeader('2. collections —— 扩展集合类型', icon: Icons.collections),
          const Paragraph(
            'collections 模块提供了 Python 内置容器（dict、list、set、tuple）的替代方案，'
            '在特定场景下更高效、更易用。',
          ),
          const Paragraph(
            'namedtuple —— 具名元组：为元组中的每个位置赋予含义。',
          ),
          const CodeBlock(r'''
from collections import namedtuple

# 定义一种新的数据类型
Point = namedtuple('Point', ['x', 'y'])
p = Point(10, y=20)
print(p)          # Point(x=10, y=20)
print(p.x, p.y)   # 10 20
print(p[0])       # 10（支持下标访问）

# 适用场景：代替简单的类定义
Student = namedtuple('Student', 'name age score')
s = Student('Alice', 18, 95)
print(f'{s.name}: age={s.age}, score={s.score}')
''', language: 'python'),
          const Paragraph(
            'deque —— 双端队列：两端都支持 O(1) 的插入和删除。',
          ),
          const CodeBlock(r'''
from collections import deque

q = deque(['a', 'b', 'c'])
q.append('d')       # 右侧入队
q.appendleft('z')   # 左侧入队
print(q)            # deque(['z', 'a', 'b', 'c', 'd'])

q.pop()             # 右侧出队
q.popleft()         # 左侧出队
print(q)            # deque(['a', 'b', 'c'])

# 限制最大长度（自动丢弃最早元素）
buf = deque(maxlen=3)
for i in range(5):
    buf.append(i)
    print(buf)  # 始终只保留最近 3 个
''', language: 'python'),
          const Paragraph(
            'defaultdict —— 默认值字典：访问不存在的 key 时自动生成默认值。',
          ),
          const CodeBlock(r'''
from collections import defaultdict

# 按首字母分组
words = ['apple', 'banana', 'avocado', 'blueberry', 'cherry']
groups = defaultdict(list)
for w in words:
    groups[w[0]].append(w)
print(dict(groups))
# {'a': ['apple', 'avocado'], 'b': ['banana', 'blueberry'], 'c': ['cherry']}

# 计数统计
s = 'abracadabra'
count = defaultdict(int)
for ch in s:
    count[ch] += 1
print(dict(count))  # {'a': 5, 'b': 2, 'r': 2, 'c': 1, 'd': 1}
''', language: 'python'),
          const Paragraph(
            'Counter —— 计数器：专门用于计数的字典子类。',
          ),
          const CodeBlock(r'''
from collections import Counter

c = Counter('abracadabra')
print(c)                    # Counter({'a': 5, 'b': 2, 'r': 2, 'c': 1, 'd': 1})
print(c.most_common(3))     # [('a', 5), ('b', 2), ('r', 2)]

# 算术运算
c1 = Counter('aabbc')
c2 = Counter('abccc')
print(c1 + c2)  # Counter({'a': 3, 'b': 3, 'c': 4})
print(c1 - c2)  # Counter({'a': 1, 'b': 1})  # 只保留正数
''', language: 'python'),
          const Paragraph(
            'OrderedDict —— 有序字典：记录键的插入顺序。'
            'Python 3.7+ 普通 dict 已保留插入顺序，但仍有一些方法差异。',
          ),
          const CodeBlock(r'''
from collections import OrderedDict

od = OrderedDict()
od['z'] = 1
od['a'] = 2
od['b'] = 3
for k, v in od.items():
    print(k, v)
# 按插入顺序输出: z a b

# popitem(last=True) 默认 LIFO，last=False 则 FIFO
od.popitem(last=False)  # 移除最早插入的 ('z', 1)
print(od)  # OrderedDict([('a', 2), ('b', 3)])
''', language: 'python'),
          const DividerLine(),

          // ── 3. base64 ──
          const SectionHeader('3. base64 —— Base64 编码', icon: Icons.lock_outline),
          const Paragraph(
            'Base64 是一种用 64 个可打印字符表示二进制数据的编码方式，'
            '常用于在 URL、邮件、JSON 中传输二进制数据。',
          ),
          const CodeBlock(r'''
import base64

# 基本编码解码
data = b'Hello, Python!'
encoded = base64.b64encode(data)
print(encoded)              # b'SGVsbG8sIFB5dGhvbiE='
decoded = base64.b64decode(encoded)
print(decoded)              # b'Hello, Python!'

# URL Safe 模式（将 +/ 替换为 -_）
url_safe = base64.urlsafe_b64encode(b'\xfb\xff\xff\xff')
print(url_safe)             # b'--__'（而非 /v///w==）
decoded = base64.urlsafe_b64decode(url_safe)
print(decoded.hex())        # fbffffff
''', language: 'python'),
          const Paragraph(
            'Base64 编码后长度约为原来的 4/3 倍，末尾的 = 用于补齐。'
            '常用于图片的 DataURL、Token 编码等场景。',
          ),
          const TipBox(
            'Base64 不是加密算法！它只是一种编码方式，任何人都可以解码。'
            '不要用 base64 保护敏感数据。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ── 4. struct ──
          const SectionHeader('4. struct —— 二进制数据打包', icon: Icons.memory),
          const Paragraph(
            'struct 模块在 Python 值和 C 结构体之间转换，'
            '用于处理二进制文件、网络协议等底层数据。',
          ),
          const CodeBlock(r'''
import struct

# pack: 将 Python 值打包为字节
# > 表示大端序，I 表示无符号 int (4字节)，f 表示 float (4字节)
data = struct.pack('>If', 42, 3.14)
print(data.hex())  # 0000002a4048f5c3

# unpack: 从字节解析出 Python 值
values = struct.unpack('>If', data)
print(values)  # (42, 3.140000104904175)

# 常用格式:
# B - unsigned char (1字节)
# H - unsigned short (2字节)
# I - unsigned int (4字节)
# f - float (4字节)
# d - double (8字节)
# s - 字节串
''', language: 'python'),
          const CodeBlock(r'''
# BMP 文件头解析示例
import struct

def parse_bmp_header(data):
    """解析 BMP 文件头部"""
    # BMP 文件头共 14 字节
    header = struct.unpack('<2sIHHI', data[:14])
    print(f'文件类型: {header[0].decode()}')  # BM
    print(f'文件大小: {header[1]} 字节')
    print(f'数据偏移: {header[4]} 字节')

# 模拟 BMP 头数据（实际可从文件读取）
with open('example.bmp', 'rb') as f:
    parse_bmp_header(f.read())
''', language: 'python'),
          const DividerLine(),

          // ── 5. hashlib ──
          const SectionHeader('5. hashlib —— 哈希算法', icon: Icons.fingerprint),
          const Paragraph(
            'hashlib 提供了常见摘要算法：MD5、SHA1、SHA256、SHA512 等。'
            '哈希算法是单向的，无法从摘要反推原文。',
          ),
          const CodeBlock(r'''
import hashlib

# MD5（128位，32位16进制）
md5 = hashlib.md5()
md5.update('Hello, Python!'.encode('utf-8'))
print(md5.hexdigest())  # 7b7a8e7a9b3d7a3b...

# 分块更新（对大文件有用）
md5 = hashlib.md5()
md5.update('Hello, '.encode())
md5.update('Python!'.encode())
print(md5.hexdigest())  # 同上

# SHA256（256位，更安全）
sha = hashlib.sha256('Hello, Python!'.encode())
print(sha.hexdigest())
print(f'摘要长度: {sha.digest_size} 字节')
''', language: 'python'),
          const Paragraph(
            '加盐哈希：在原文后添加随机字符串，防止彩虹表破解。',
          ),
          const CodeBlock(r'''
import hashlib, random, string

def salt_hash(password: str) -> str:
    """生成加盐哈希"""
    salt = ''.join(random.choices(
        string.ascii_letters + string.digits, k=8))
    h = hashlib.sha256((password + salt).encode())
    return f'{salt}${h.hexdigest()}'

def verify(password: str, hashed: str) -> bool:
    """验证加盐哈希"""
    salt, h = hashed.split('$')
    new_h = hashlib.sha256((password + salt).encode()).hexdigest()
    return new_h == h

# 使用示例
h = salt_hash('mypassword123')
print(f'哈希值: {h}')
print(f'验证: {verify("mypassword123", h)}')
print(f'错误密码: {verify("wrong", h)}')
''', language: 'python'),
          const TipBox(
            'MD5/SHA1 已不再安全，推荐使用 SHA256 或 SHA512。'
            '实际项目中密码存储应使用 bcrypt、argon2 等专用算法。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ── 6. hmac ──
          const SectionHeader('6. hmac —— 消息认证码', icon: Icons.verified_user),
          const Paragraph(
            'HMAC 是一种基于哈希的消息认证码，使用密钥对消息进行签名，'
            '同时验证消息完整性和来源真实性。',
          ),
          const CodeBlock(r'''
import hmac
import hashlib

# 生成 HMAC 签名
key = b'secret_key'
message = b'Hello, Python!'
h = hmac.new(key, message, hashlib.sha256)
print(h.hexdigest())  # 64 位十六进制签名

# 验证 HMAC 签名
def verify_signature(key: bytes, message: bytes,
                     signature: str) -> bool:
    expected = hmac.new(key, message, hashlib.sha256)
    # compare_digest 防止时序攻击
    return hmac.compare_digest(expected.hexdigest(), signature)

sig = h.hexdigest()
print(f'验证通过: {verify_signature(key, message, sig)}')
print(f'篡改检测: {verify_signature(key, b"tampered", sig)}')
''', language: 'python'),
          const Paragraph(
            'HMAC 常用于 API 签名认证。客户端用密钥对请求参数计算 HMAC，'
            '服务端用相同密钥验证，确保请求未被篡改。',
          ),
          const CodeBlock(r'''
import hmac, hashlib, json

def sign_request(params: dict, secret: str) -> str:
    """对 API 请求参数签名"""
    # 按 key 排序后拼接
    sorted_keys = sorted(params.keys())
    message = '&'.join(
        f'{k}={params[k]}' for k in sorted_keys)
    h = hmac.new(
        secret.encode(),
        message.encode(),
        hashlib.sha256)
    return h.hexdigest()

# 客户端签名示例
params = {'name': 'Alice', 'age': 25, 'timestamp': '1700000000'}
secret = 'my_api_secret'
signature = sign_request(params, secret)
print(f'签名: {signature}')
''', language: 'python'),
          const DividerLine(),

          // ── 7. itertools ──
          const SectionHeader('7. itertools —— 迭代器工具', icon: Icons.repeat),
          const Paragraph(
            'itertools 提供了高效的迭代器函数，用于构建复杂的数据处理管道。'
            '它们返回迭代器（惰性求值），内存占用极低。',
          ),
          const Paragraph(
            '无限迭代器：count、cycle、repeat',
          ),
          const CodeBlock(r'''
from itertools import count, cycle, repeat

# count(start=0, step=1): 无限递增
for i in count(10, 2):
    if i > 20: break
    print(i, end=' ')  # 10 12 14 16 18 20

print()

# cycle(iterable): 无限循环
colors = cycle(['red', 'green', 'blue'])
for _ in range(6):
    print(next(colors), end=' ')  # red green blue red green blue

print()

# repeat(obj, times=None): 重复生成
for x in repeat('A', 3):
    print(x, end=' ')  # A A A
''', language: 'python'),
          const Paragraph(
            '常用迭代器函数：chain、groupby、product、permutations',
          ),
          const CodeBlock(r'''
from itertools import chain, groupby, product, permutations

# chain: 串联多个可迭代对象
print(list(chain([1, 2], ['a', 'b'], 'xyz')))
# [1, 2, 'a', 'b', 'x', 'y', 'z']

# groupby: 相邻元素分组
items = [('A', 1), ('A', 2), ('B', 3), ('B', 4)]
for key, group in groupby(items, lambda x: x[0]):
    print(key, [v for _, v in group])
# A [1, 2]    B [3, 4]

# product: 笛卡尔积
print(list(product('AB', '12')))
# [('A', '1'), ('A', '2'), ('B', '1'), ('B', '2')]

# permutations: 排列
print(list(permutations('ABC', 2)))
# [('A', 'B'), ('A', 'C'), ('B', 'A'), ('B', 'C'), ('C', 'A'), ('C', 'B')]
''', language: 'python'),
          const Paragraph(
            'takewhile、dropwhile、filterfalse —— 条件筛选迭代器。',
          ),
          const CodeBlock(r'''
from itertools import takewhile, dropwhile, filterfalse

# takewhile: 取满足条件的元素（遇到 False 即停）
nums = [1, 3, 5, 7, 2, 4, 6]
odd_head = list(takewhile(lambda x: x % 2 == 1, nums))
print(odd_head)  # [1, 3, 5, 7]

# dropwhile: 丢弃满足条件的元素（遇到 False 开始保留）
rest = list(dropwhile(lambda x: x % 2 == 1, nums))
print(rest)      # [2, 4, 6]

# filterfalse: 过滤掉满足条件的元素（保留 False）
print(list(filterfalse(lambda x: x % 2 == 1, nums)))
# [2, 4, 6]
''', language: 'python'),
          const TipBox(
            'itertools 的函数返回迭代器而非列表，可通过 list() 转换为列表查看结果。'
            '对大型数据集，迭代器能节省大量内存。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 8. contextlib ──
          const SectionHeader('8. contextlib —— 上下文管理工具', icon: Icons.swap_horiz),
          const Paragraph(
            'contextlib 提供了简化上下文管理器编写的工具，'
            '包括 @contextmanager 装饰器和 closing 等辅助函数。',
          ),
          const CodeBlock(r'''
from contextlib import contextmanager

# 用生成器实现上下文管理器
@contextmanager
def timer(name: str):
    """计时器上下文管理器"""
    import time
    start = time.time()
    print(f'{name}... 开始')
    yield  # 在这里执行 with 块内的代码
    elapsed = time.time() - start
    print(f'{name}... 完成 ({elapsed:.3f}s)')

# 使用自定义上下文管理器
with timer('数据处理'):
    total = sum(range(10**6))
    print(f'总和: {total}')

# 输出:
# 数据处理... 开始
# 总和: 499999500000
# 数据处理... 完成 (0.XXXs)
''', language: 'python'),
          const Paragraph(
            'closing —— 自动调用 close 方法的上下文管理器。',
          ),
          const CodeBlock(r'''
from contextlib import closing
from urllib.request import urlopen

# 自动关闭连接
with closing(urlopen('https://httpbin.org/get')) as resp:
    data = resp.read()
    print(f'状态码: {resp.status}')
    print(f'收到 {len(data)} 字节')
# 即使异常也会自动关闭

# @contextmanager + 异常处理
@contextmanager
def safe_open(filename: str, mode: str = 'r'):
    """安全的文件打开，自动处理异常"""
    f = None
    try:
        f = open(filename, mode, encoding='utf-8')
        yield f
    except FileNotFoundError:
        print(f'文件不存在: {filename}')
        yield None
    finally:
        if f:
            f.close()
''', language: 'python'),
          const Paragraph(
            'ExitStack —— 动态管理多个上下文管理器。',
          ),
          const CodeBlock(r'''
from contextlib import ExitStack

# 动态管理多个资源
def process_files(filenames: list[str]):
    """同时打开多个文件"""
    with ExitStack() as stack:
        files = [
            stack.enter_context(open(f, 'r', encoding='utf-8'))
            for f in filenames
        ]
        # 所有文件会在 with 结束时自动关闭
        for f in files:
            print(f.readline().strip())

# suppress —— 忽略指定异常
from contextlib import suppress
with suppress(FileNotFoundError):
    # 文件不存在也不会报错
    with open('not_exists.txt') as f:
        print(f.read())
print('程序继续执行...')
''', language: 'python'),
          const DividerLine(),

          // ── 9. urllib ──
          const SectionHeader('9. urllib —— 网络请求', icon: Icons.cloud_download),
          const Paragraph(
            'urllib 是 Python 内置的 HTTP 请求库，'
            '包含 request（请求）、parse（URL 解析）、error（异常处理）等子模块。',
          ),
          const CodeBlock(r'''
from urllib.request import urlopen, Request
from urllib.parse import urlencode, quote
from urllib.error import HTTPError, URLError

# GET 请求
with urlopen('https://httpbin.org/get') as resp:
    print(f'状态码: {resp.status}')
    print(f'内容类型: {resp.headers["Content-Type"]}')
    data = resp.read().decode('utf-8')
    print(data[:200])

# 带参数的 GET 请求
params = urlencode({'name': 'Alice', 'age': 25})
with urlopen(f'https://httpbin.org/get?{params}') as resp:
    print(resp.read().decode('utf-8')[:200])
''', language: 'python'),
          const CodeBlock(r'''
from urllib.request import Request, urlopen
from urllib.parse import urlencode

# POST 请求
data = urlencode({'username': 'admin', 'password': '123456'}).encode()
req = Request('https://httpbin.org/post', data=data, method='POST')
req.add_header('User-Agent', 'Mozilla/5.0')

with urlopen(req) as resp:
    print(f'状态码: {resp.status}')
    print(resp.read().decode('utf-8')[:300])

# URL 编解码
from urllib.parse import quote, unquote, urlparse

print(quote('中文测试'))            # %E4%B8%AD%E6%96%87%E6%B5%8B%E8%AF%95
print(unquote('%E4%B8%AD%E6%96%87'))  # 中文

# 解析 URL
parsed = urlparse('https://example.com/path?a=1&b=2#frag')
print(f'scheme={parsed.scheme}, host={parsed.hostname}, '
      f'path={parsed.path}, query={parsed.query}')
''', language: 'python'),
          const Paragraph(
            '错误处理：捕获 HTTP 错误和网络异常。',
          ),
          const CodeBlock(r'''
from urllib.request import urlopen
from urllib.error import HTTPError, URLError

def safe_request(url: str) -> str | None:
    """安全发起 HTTP 请求"""
    try:
        with urlopen(url, timeout=10) as resp:
            return resp.read().decode('utf-8')
    except HTTPError as e:
        print(f'HTTP 错误: {e.code} {e.reason}')
    except URLError as e:
        print(f'网络错误: {e.reason}')
    except TimeoutError:
        print('请求超时')
    return None

# 测试
result = safe_request('https://httpbin.org/status/404')
print(f'结果: {result}')
''', language: 'python'),
          const TipBox(
            'urllib 适合简单场景。实际项目中推荐使用第三方库 requests，'
            '它提供了更友好的 API 和更丰富的功能。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 10. HTMLParser ──
          const SectionHeader('10. HTMLParser —— HTML 解析', icon: Icons.html),
          const Paragraph(
            'HTMLParser 是 Python 内置的 HTML/XML 解析工具，'
            '通过回调方式处理 HTML 标签、属性、文本等。',
          ),
          const CodeBlock(r"""
from html.parser import HTMLParser

class MyHTMLParser(HTMLParser):
    '''自定义 HTML 解析器'''
    def handle_starttag(self, tag, attrs):
        print(f'开始标签: <{tag}>')
        for attr in attrs:
            print(f'  属性: {attr[0]} = {attr[1]}')

    def handle_endtag(self, tag):
        print(f'结束标签: </{tag}>')

    def handle_data(self, data):
        if data.strip():
            print(f'文本: {data.strip()}')

    def handle_comment(self, data):
        print(f'注释: <!-- {data} -->')

html = '''<html>
<head><title>测试页面</title></head>
<body><!-- 主要内容 -->
    <h1 id="title">Hello</h1>
    <a href="https://example.com">链接</a>
</body></html>'''

parser = MyHTMLParser()
parser.feed(html)
""", language: 'python'),
          const Paragraph(
            '实战：提取网页中所有链接。',
          ),
          const CodeBlock(r"""
from html.parser import HTMLParser
from urllib.request import urlopen

class LinkExtractor(HTMLParser):
    '''提取网页中所有链接'''
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for attr in attrs:
                if attr[0] == 'href':
                    self.links.append(attr[1])

# 使用示例
extractor = LinkExtractor()
with urlopen('https://httpbin.org/links/10') as resp:
    html = resp.read().decode('utf-8')
    extractor.feed(html)

print(f'共找到 {len(extractor.links)} 个链接')
for link in extractor.links[:5]:
    print(f'  - {link}')
""", language: 'python'),
          const TipBox(
            'HTMLParser 适合简单的 HTML 解析。'
            '复杂 HTML 推荐使用第三方库 BeautifulSoup（详见 Ch21）。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 11. json ──
          const SectionHeader('11. json —— JSON 数据处理', icon: Icons.data_object),
          const Paragraph(
            'json 模块提供了 JSON 与 Python 数据类型之间的转换，'
            '支持任意嵌套的 dict/list 结构。',
          ),
          const CodeBlock(r'''
import json

# Python → JSON（序列化）
data = {
    'name': 'Alice',
    'age': 25,
    'scores': [95, 87, 92],
    'active': True,
    'address': None
}

json_str = json.dumps(data, ensure_ascii=False, indent=2)
print(json_str)

# JSON → Python（反序列化）
parsed = json.loads(json_str)
print(parsed['name'])    # Alice
print(parsed['scores'])  # [95, 87, 92]
''', language: 'python'),
          const Paragraph(
            '文件读写：直接对文件进行 JSON 序列化/反序列化。',
          ),
          const CodeBlock(r'''
import json

# 写入 JSON 文件
data = {'name': 'Alice', 'age': 25}
with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# 读取 JSON 文件
with open('data.json', 'r', encoding='utf-8') as f:
    loaded = json.load(f)
print(loaded)  # {'name': 'Alice', 'age': 25}

# JSON Lines 格式（每行一个 JSON 对象）
with open('data.jsonl', 'w', encoding='utf-8') as f:
    for i in range(3):
        f.write(json.dumps({'id': i, 'value': f'item_{i}'}) + '\n')
''', language: 'python'),
          const Paragraph(
            '自定义 JSON 编码：处理 datetime、自定义对象等特殊类型。',
          ),
          const CodeBlock(r"""
import json
from datetime import datetime

class CustomEncoder(json.JSONEncoder):
    '''自定义 JSON 编码器'''
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.strftime('%Y-%m-%d %H:%M:%S')
        if isinstance(obj, bytes):
            return obj.hex()
        return super().default(obj)

data = {
    'time': datetime.now(),
    'data': b'\x00\x01\x02',
    'name': 'test'
}

print(json.dumps(data, cls=CustomEncoder, indent=2))
# {
#   "time": "2025-12-25 10:30:00",
#   "data": "000102",
#   "name": "test"
# }
""", language: 'python'),
          const Paragraph(
            '排序与压缩：sort_keys 对键排序，separators 去除空格以压缩。',
          ),
          const CodeBlock(r'''
import json

data = {'name': 'Alice', 'age': 25, 'scores': [95, 87]}

# 排序输出
print(json.dumps(data, sort_keys=True, indent=2))

# 压缩输出（去除空格）
print(json.dumps(data, separators=(',', ':')))
# {"name":"Alice","age":25,"scores":[95,87]}

# 忽略 None 字段（需自定义）
def clean_none(obj):
    if isinstance(obj, dict):
        return {k: clean_none(v)
                for k, v in obj.items() if v is not None}
    return obj

data_with_none = {'a': 1, 'b': None, 'c': {'d': None, 'e': 2}}
print(json.dumps(clean_none(data_with_none)))
# {"a": 1, "c": {"e": 2}}
''', language: 'python'),
          const DividerLine(),

          // ── 交互演示：collections ──
          const _CollectionsModuleDemo(),
          const DividerLine(),

          // ── 交互演示：itertools ──
          const _ItertoolsDemo(),
          const DividerLine(),

          // ── 总结 ──
          const SectionHeader('本章总结', icon: Icons.summarize),
          const Paragraph(
            'Python 标准库内建模块是日常开发的基础工具：\n'
            '- datetime：日期时间处理，与 time 模块互补\n'
            '- collections：扩展数据结构，让代码更简洁高效\n'
            '- base64/struct：二进制数据编码与打包\n'
            '- hashlib/hmac：数据完整性验证与消息认证\n'
            '- itertools：懒加载迭代器，高效处理数据流\n'
            '- contextlib：简化上下文管理器编写\n'
            '- urllib：纯内置 HTTP 请求方案\n'
            '- HTMLParser：轻量级 HTML 解析\n'
            '- json：通用数据交换格式处理',
          ),
          const TipBox(
            '熟练掌握标准库能显著减少第三方依赖。'
            '在添加第三方包之前，先检查标准库是否已有解决方案。',
            type: TipType.info,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
