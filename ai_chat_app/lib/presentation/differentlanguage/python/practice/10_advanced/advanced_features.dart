import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// 列表推导式演示
class _ListComprehensionAdvDemo extends StatefulWidget {
  const _ListComprehensionAdvDemo();
  @override
  State<_ListComprehensionAdvDemo> createState() => _ListComprehensionAdvDemoState();
}

class _ListComprehensionAdvDemoState extends State<_ListComprehensionAdvDemo> {
  int _n = 10;
  String _expr = 'x*x';
  bool _hasCondition = true;
  String _condition = 'x % 2 == 0';

  List<int> get _input => List.generate(_n, (i) => i + 1);

  List<int> get _output {
    final items = _input;
    List<int> filtered = _hasCondition ? items.where((x) => x % 2 == 0).toList() : items;
    return switch (_expr) {
      'x*x' => filtered.map((x) => x * x).toList(),
      'x*2' => filtered.map((x) => x * 2).toList(),
      'x+10' => filtered.map((x) => x + 10).toList(),
      _ => filtered,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '⚡ 列表推导式演示',
      subtitle: '修改范围、表达式和条件，观察推导式生成的列表',
      children: [
        ParamIntSlider(label: '范围 n', value: _n, min: 3, max: 15, onChanged: (v) => setState(() => _n = v)),
        ParamChoiceChips<String>(
          label: '表达式',
          value: _expr,
          options: [('x*x', 'x²'), ('x*2', 'x×2'), ('x+10', 'x+10')],
          onChanged: (v) => setState(() => _expr = v),
        ),
        ParamSwitch(label: '添加条件', value: _hasCondition, onChanged: (v) => setState(() => _hasCondition = v),
          trueLabel: 'x % 2 == 0（偶数）', falseLabel: '无'),
        const SizedBox(height: 8),
        Row(children: [
          const Text('输入: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Expanded(child: Text(_input.join(', '), style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.grey))),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Text('输出: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          Expanded(child: Text(_output.join(', '), style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Theme.of(context).colorScheme.primary))),
        ]),
        LiveCodeBlock(
          '# 列表推导式\n'
          '[${_expr.replaceAll('x', 'x')} for x in range(1, ${_n + 1})${_hasCondition ? ' if $_condition' : ''}]\n\n'
          '# 等价的 for 循环\n'
          'result = []\n'
          'for x in range(1, ${_n + 1}):\n'
          '${_hasCondition ? '    if $_condition:\n        result.append($_expr)\n' : '    result.append($_expr)\n'}',
        ),
        LiveOutputBox('输入: ${_input.join(', ')}\n输出: ${_output.join(', ')}\n元素数量: ${_output.length}'),
      ],
    );
  }
}

/// 装饰器概念演示
class _DecoratorDemo extends StatefulWidget {
  const _DecoratorDemo();
  @override
  State<_DecoratorDemo> createState() => _DecoratorDemoState();
}

class _DecoratorDemoState extends State<_DecoratorDemo> {
  String _funcName = 'say_hello';
  bool _useLogger = true;
  bool _useTimer = false;
  bool _useCache = false;
  String _arg = 'World';

  String get _decorators {
    final decs = <String>[];
    if (_useCache) decs.add('@functools.cache');
    if (_useTimer) decs.add('@timer');
    if (_useLogger) decs.add('@logger');
    return decs.join('\n');
  }

  String get _output {
    final parts = <String>[];
    if (_useLogger) parts.add('[LOG] 调用 $_funcName("$_arg")');
    if (_useTimer) parts.add('[TIMER] 开始计时...');
    parts.add('你好, $_arg!');
    if (_useTimer) parts.add('[TIMER] 耗时: 0.0001s');
    if (_useLogger) parts.add('[LOG] 返回: "你好, $_arg!"');
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🎨 装饰器（Decorator）演示',
      subtitle: '叠加不同装饰器，观察函数调用时被增强的行为',
      children: [
        ParamTextField(label: '函数名', value: _funcName, onChanged: (v) => setState(() => _funcName = v.isEmpty ? 'say_hello' : v), maxLength: 15),
        ParamTextField(label: '参数', value: _arg, onChanged: (v) => setState(() => _arg = v.isEmpty ? 'World' : v), maxLength: 10),
        ParamSwitch(label: '@logger（日志记录）', value: _useLogger, onChanged: (v) => setState(() => _useLogger = v), trueLabel: '开', falseLabel: '关'),
        ParamSwitch(label: '@timer（计时器）', value: _useTimer, onChanged: (v) => setState(() => _useTimer = v), trueLabel: '开', falseLabel: '关'),
        ParamSwitch(label: '@functools.cache（缓存）', value: _useCache, onChanged: (v) => setState(() => _useCache = v), trueLabel: '开', falseLabel: '关'),
        const SizedBox(height: 8),
        LiveCodeBlock(
          '${_decorators.isNotEmpty ? '$_decorators\n' : ''}'
          'def $_funcName(name):\n'
          '    return f"你好, {name}!"\n\n'
          '# 调用\n'
          '$_funcName("$_arg")',
        ),
        LiveOutputBox(_decorators.isEmpty ? '你好, $_arg!' : _output),
      ],
    );
  }
}

/// Python 第10章：高级特性 (Advanced Features)
///
/// 涵盖内容：
/// 1. 列表推导式深入（嵌套、字典/集合推导式、条件推导式、海象运算符）
/// 2. 生成器（yield、生成器表达式、yield from、内存效率对比）
/// 3. 迭代器（iter/next、自定义迭代器、Iterable vs Iterator、itertools 模块）
/// 4. 装饰器深入（@wraps、带参数装饰器、类装饰器、多装饰器堆叠、实用示例）
/// 5. 上下文管理器深入（contextmanager、closing、suppress、ExitStack）
/// 6. 海象运算符 :=（赋值表达式、while 循环优化、推导式优化）
class PythonAdvancedFeatures extends StatelessWidget {
  const PythonAdvancedFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第10章 高级特性')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // 章节介绍
          // ============================================================
          Paragraph(
            '本章深入探讨 Python 中真正体现其强大之处的高级特性。'
            '掌握这些特性能够让你写出更简洁、更高效、更 Pythonic 的代码。'
            '我们将从列表推导式开始，逐步深入到生成器、迭代器、装饰器、'
            '上下文管理器以及海象运算符等核心概念。',
          ),
          const SizedBox(height: 8),

          // ============================================================
          // 1. 列表推导式深入
          // ============================================================
          SectionHeader('1. 列表推导式深入', icon: Icons.list_alt),

          Paragraph(
            '列表推导式（List Comprehension）是 Python 最受欢迎的特性之一。'
            '除了基本的用法，它还支持嵌套、条件过滤、以及与其他数据结构的结合。'
            '从 Python 3.8 开始，海象运算符也可以用在推导式中，进一步提升了表达能力。',
          ),

          const SizedBox(height: 8),
          Paragraph('1.1 嵌套列表推导式'),
          Paragraph(
            '嵌套列表推导式用于展平多维列表或生成多层循环的结果。'
            '外层循环写在前面，内层循环写在后面，与普通 for 循环的顺序一致。',
          ),
          CodeBlock(
            r'''matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [num for row in matrix for num in row]
print(f"展平结果: {flattened}")

# 嵌套推导式生成乘法表
multiplication = [[i * j for j in range(1, 6)] for i in range(1, 6)]
print("5x5 乘法表:")
for row in multiplication:
    print(row)''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '展平结果: [1, 2, 3, 4, 5, 6, 7, 8, 9]\n'
            '5x5 乘法表:\n'
            '[1, 2, 3, 4, 5]\n'
            '[2, 4, 6, 8, 10]\n'
            '[3, 6, 9, 12, 15]\n'
            '[4, 8, 12, 16, 20]\n'
            '[5, 10, 15, 20, 25]',
          ),
          const SizedBox(height: 8),

          Paragraph('1.2 字典推导式与集合推导式'),
          Paragraph(
            '使用花括号 {} 可以创建字典推导式和集合推导式。'
            '字典推导式使用 key: value 语法，集合推导式则类似列表推导式但返回集合。',
          ),
          CodeBlock(
            r'''# 字典推导式: 将列表转换为字典
words = ["apple", "banana", "cherry"]
word_lengths = {word: len(word) for word in words}
print(f"单词长度: {word_lengths}")

# 条件字典推导式
squares_dict = {x: x ** 2 for x in range(10) if x % 2 == 0}
print(f"偶数平方: {squares_dict}")

# 集合推导式: 自动去重
numbers = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
unique_squares = {x ** 2 for x in numbers}
print(f"唯一平方值: {unique_squares}")

# 反转字典
original = {"a": 1, "b": 2, "c": 3}
reversed_dict = {value: key for key, value in original.items()}
print(f"反转字典: {reversed_dict}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '单词长度: {\'apple\': 5, \'banana\': 6, \'cherry\': 6}\n'
            '偶数平方: {0: 0, 2: 4, 4: 16, 6: 36, 8: 64}\n'
            '唯一平方值: {16, 1, 4, 9}\n'
            '反转字典: {1: \'a\', 2: \'b\', 3: \'c\'}',
          ),
          const SizedBox(height: 8),

          Paragraph('1.3 条件推导式（多条件过滤）'),
          Paragraph(
            '可以在推导式中使用多个 if 条件，实现复杂的过滤逻辑。'
            '多个 if 条件之间是 AND 关系。',
          ),
          CodeBlock(
            r'''# 多个条件过滤
numbers = range(1, 31)

# 能被 3 整除且能被 5 整除的数
filtered = [n for n in numbers if n % 3 == 0 if n % 5 == 0]
print(f"3和5的公倍数: {filtered}")

# 带 if-else 的三元表达式推导式
labels = ["偶数" if n % 2 == 0 else "奇数" for n in range(1, 11)]
print(f"奇偶标记: {labels}")

# 同时过滤和转换
scores = [85, 92, 47, 73, 88, 55, 91]
passed = [f"通过: {s}" for s in scores if s >= 60]
failed = [f"未通过: {s}" for s in scores if s < 60]
print(f"及格: {passed}")
print(f"不及格: {failed}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '3和5的公倍数: [15, 30]\n'
            '奇偶标记: [\'奇数\', \'偶数\', \'奇数\', \'偶数\', \'奇数\', \'偶数\', \'奇数\', \'偶数\', \'奇数\', \'偶数\']\n'
            '及格: [\'通过: 85\', \'通过: 92\', \'通过: 73\', \'通过: 88\', \'通过: 91\']\n'
            '不及格: [\'未通过: 47\', \'未通过: 55\']',
          ),
          const SizedBox(height: 8),

          Paragraph('1.4 海象运算符 := 在推导式中的应用'),
          Paragraph(
            'Python 3.8 引入的海象运算符允许在推导式中进行赋值，'
            '从而避免重复计算表达式。这在需要同时使用计算结果和条件判断时非常有用。',
          ),
          CodeBlock(
            r'''# 传统方式: 需要重复计算 x ** 2
nums = [1, 2, 3, 4, 5, 6]
result_old = [x ** 2 for x in nums if x ** 2 > 10]
print(f"传统方式: {result_old}")

# 海象运算符: 避免重复计算
result_new = [sq for x in nums if (sq := x ** 2) > 10]
print(f"海象运算符: {result_new}")

# 更实际的例子: 处理字符串列表时同时获取长度和内容
texts = ["hello", "a", "world", "python", "ai"]
long_texts = [t for t in texts if (length := len(t)) > 3]
print(f"长单词: {long_texts}")

# 注意: 海象运算符赋值变量在推导式外也可用
_ = [length for t in texts if (length := len(t)) > 3]
print(f"最后一个长度值: {length}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '传统方式: [16, 25, 36]\n'
            '海象运算符: [16, 25, 36]\n'
            '长单词: [\'hello\', \'world\', \'python\']\n'
            '最后一个长度值: 2',
          ),
          const SizedBox(height: 8),

          TipBox(
            '建议：列表推导式虽强大，但嵌套超过两层或条件过于复杂时，'
            '请改用普通 for 循环以提高代码可读性。代码的读者可能不熟悉高级推导式语法。',
            type: TipType.tip,
          ),

          const DividerLine(),

          // ============================================================
          // 2. 生成器
          // ============================================================
          SectionHeader('2. 生成器 (Generator)', icon: Icons.play_circle_outline),

          Paragraph(
            '生成器是 Python 中实现惰性求值（Lazy Evaluation）的核心机制。'
            '它们不会一次性将所有数据加载到内存中，而是在需要时才生成值。'
            '这使得生成器非常适合处理大数据集或无限序列。',
          ),

          const SizedBox(height: 8),
          Paragraph('2.1 生成器函数与 yield 关键字'),
          Paragraph(
            '使用 yield 关键字的函数是生成器函数。每次调用 yield 会暂停函数执行'
            '并返回一个值，下次调用时从暂停处继续执行。',
          ),
          CodeBlock(
            r'''def fibonacci(n):
    """生成前 n 个斐波那契数列"""
    a, b = 0, 1
    count = 0
    while count < n:
        yield a
        a, b = b, a + b
        count += 1

# 使用生成器
fib = fibonacci(10)
print("斐波那契数列前10项:")
for i, num in enumerate(fib):
    print(f"  F({i}) = {num}")

# 生成器只能迭代一次
print(f"再次迭代: {list(fib)}")  # 空列表，已耗尽''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '斐波那契数列前10项:\n'
            '  F(0) = 0\n'
            '  F(1) = 1\n'
            '  F(2) = 1\n'
            '  F(3) = 2\n'
            '  F(4) = 3\n'
            '  F(5) = 5\n'
            '  F(6) = 8\n'
            '  F(7) = 13\n'
            '  F(8) = 21\n'
            '  F(9) = 34\n'
            '再次迭代: []',
          ),
          const SizedBox(height: 8),

          Paragraph('2.2 生成器表达式 vs 列表推导式'),
          Paragraph(
            '生成器表达式使用圆括号 ()，列表推导式使用方括号 []。'
            '两者语法相似但行为完全不同：列表推导式立即创建完整列表，'
            '而生成器表达式返回一个生成器对象，按需生成值。',
          ),
          CodeBlock(
            r'''import sys

# 列表推导式 - 立即计算所有值
list_comp = [x ** 2 for x in range(1000000)]
print(f"列表推导式类型: {type(list_comp)}")
print(f"列表推导式占用内存: {sys.getsizeof(list_comp) / 1024 / 1024:.2f} MB")

# 生成器表达式 - 惰性求值
gen_expr = (x ** 2 for x in range(1000000))
print(f"生成器表达式类型: {type(gen_expr)}")
print(f"生成器表达式占用内存: {sys.getsizeof(gen_expr)} bytes")

# 数据量较小时性能对比
import timeit
small_range = 1000
list_time = timeit.timeit('[x ** 2 for x in range(1000)]', number=10000)
gen_time = timeit.timeit('(x ** 2 for x in range(1000))', number=10000)
print(f"列表推导式 10000次: {list_time:.4f}秒")
print(f"生成器表达式 10000次: {gen_time:.4f}秒")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '列表推导式类型: <class \'list\'>\n'
            '列表推导式占用内存: 34.97 MB\n'
            '生成器表达式类型: <class \'generator\'>\n'
            '生成器表达式占用内存: 192 bytes\n'
            '列表推导式 10000次: 1.2345秒\n'
            '生成器表达式 10000次: 0.0012秒',
          ),
          const SizedBox(height: 8),

          Paragraph('2.3 使用 yield from 委托生成器'),
          Paragraph(
            'yield from 表达式可以将一个生成器的产出委托给另一个生成器。'
            '它简化了在生成器中遍历另一个可迭代对象的操作，'
            '特别适合实现生成器组合和递归遍历。',
          ),
          CodeBlock(
            r'''def flatten(nested_list):
    """递归展平嵌套列表"""
    for item in nested_list:
        if isinstance(item, list):
            yield from flatten(item)
        else:
            yield item

def chain_generators(*iterables):
    """串联多个可迭代对象"""
    for it in iterables:
        yield from it

# 测试 flatten
nested = [1, [2, [3, 4], 5], [6, 7], 8]
print(f"展平结果: {list(flatten(nested))}")

# 测试 chain
print(f"串联结果: {list(chain_generators([1, 2], (3, 4), "ab"))}")

# 实际应用: 遍历目录树
def walk_directory(path, prefix=""):
    import os
    entries = os.listdir(path)
    for entry in entries:
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            yield f"{prefix}{entry}/"
            yield from walk_directory(full_path, prefix + "  ")
        else:
            yield f"{prefix}{entry}"''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '展平结果: [1, 2, 3, 4, 5, 6, 7, 8]\n'
            '串联结果: [1, 2, 3, 4, \'a\', \'b\']',
          ),
          const SizedBox(height: 8),

          Paragraph('2.4 生成器的内存效率演示'),
          Paragraph(
            '以下演示生成器在处理大数据时的优势，'
            '通过逐行读取大文件来展示内存效率的差异。',
          ),
          CodeBlock(
            r'''# 模拟逐行读取大文件的生成器
def read_large_file(file_path):
    """逐行读取文件，不将整个文件加载到内存"""
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            yield line.strip()

def search_in_file(file_path, keyword):
    """在文件中搜索关键字，使用生成器逐行处理"""
    for line_num, line in enumerate(read_large_file(file_path), 1):
        if keyword in line:
            yield line_num, line

# 模拟数据处理管道
def clean_data(iterator):
    for item in iterator:
        yield item.strip().lower()

def filter_data(iterator, min_length=3):
    for item in iterator:
        if len(item) >= min_length:
            yield item

def transform_data(iterator):
    for item in iterator:
        yield f"处理结果: {item}"

# 链式处理 - 无中间列表
data = ["  Apple  ", "", "Banana", "  ", "Cherry", "A", "  Date  "]
pipeline = transform_data(
    filter_data(
        clean_data(iter(data))
    )
)
print("数据处理管道结果:")
for result in pipeline:
    print(result)''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '数据处理管道结果:\n'
            '处理结果: apple\n'
            '处理结果: banana\n'
            '处理结果: cherry\n'
            '处理结果: date',
          ),
          const SizedBox(height: 8),

          TipBox(
            '使用场景总结：当数据量很大或数据集无限时使用生成器；'
            '当需要随机访问、多次遍历或数据量很小时使用列表。'
            '生成器也适合构建数据处理管道。',
            type: TipType.info,
          ),

          const DividerLine(),

          // ============================================================
          // 3. 迭代器
          // ============================================================
          SectionHeader('3. 迭代器 (Iterator)', icon: Icons.repeat),

          Paragraph(
            '迭代器是 Python 中遍历数据的统一接口。任何实现了 __iter__ 和 __next__ 方法'
            '的对象都是迭代器。理解迭代器是掌握 Python 数据处理的基础。',
          ),

          const SizedBox(height: 8),
          Paragraph('3.1 iter() 与 next() 基本使用'),
          Paragraph(
            'iter() 将可迭代对象转换为迭代器，next() 逐个获取元素。'
            '当迭代器耗尽时，会抛出 StopIteration 异常。',
          ),
          CodeBlock(
            r'''# iter() 和 next() 基本使用
fruits = ["苹果", "香蕉", "樱桃"]
iterator = iter(fruits)

print(f"第一个: {next(iterator)}")
print(f"第二个: {next(iterator)}")
print(f"第三个: {next(iterator)}")

# 再次调用 next() 会抛出 StopIteration
try:
    next(iterator)
except StopIteration:
    print("迭代器已耗尽!")

# next() 可以设置默认值
iterator2 = iter([1, 2, 3])
print(next(iterator2, "结束"))
print(next(iterator2, "结束"))
print(next(iterator2, "结束"))
print(next(iterator2, "结束"))  # 返回默认值，不抛异常

# 反转字符串
text = "Python"
reversed_iter = reversed(text)
print(f"反转结果: {"".join(reversed_iter)}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '第一个: 苹果\n'
            '第二个: 香蕉\n'
            '第三个: 樱桃\n'
            '迭代器已耗尽!\n'
            '1\n'
            '2\n'
            '3\n'
            '结束\n'
            '反转结果: nohtyP',
          ),
          const SizedBox(height: 8),

          Paragraph('3.2 自定义迭代器'),
          Paragraph(
            '实现 __iter__ 和 __next__ 方法可以创建自定义迭代器。'
            '__iter__ 返回迭代器对象本身，__next__ 返回下一个值或抛出 StopIteration。',
          ),
          CodeBlock(
            r'''class RangeIterator:
    """自定义范围迭代器，类似内置 range"""

    def __init__(self, start, end, step=1):
        self.current = start
        self.end = end
        self.step = step

    def __iter__(self):
        return self

    def __next__(self):
        if self.current >= self.end:
            raise StopIteration
        value = self.current
        self.current += self.step
        return value


class StepHistory:
    """模拟步数记录器，可迭代"""

    def __init__(self):
        self._steps = []

    def add_step(self, step_name):
        self._steps.append(step_name)

    def __iter__(self):
        return StepIterator(self._steps)


class StepIterator:
    """步骤迭代器"""

    def __init__(self, steps):
        self._steps = steps
        self._index = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self._index >= len(self._steps):
            raise StopIteration
        value = self._steps[self._index]
        self._index += 1
        return f"步骤 {self._index}: {value}"


# 测试自定义迭代器
print("自定义 RangeIterator:")
for num in RangeIterator(1, 6, 2):
    print(f"  {num}")

print("自定义 StepHistory:")
history = StepHistory()
history.add_step("起床")
history.add_step("刷牙")
history.add_step("吃早餐")
for step in history:
    print(f"  {step}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '自定义 RangeIterator:\n'
            '  1\n'
            '  3\n'
            '  5\n'
            '自定义 StepHistory:\n'
            '  步骤 1: 起床\n'
            '  步骤 2: 刷牙\n'
            '  步骤 3: 吃早餐',
          ),
          const SizedBox(height: 8),

          Paragraph('3.3 Iterable 与 Iterator 的区别'),
          Paragraph(
            'Iterable（可迭代对象）实现了 __iter__ 方法，返回一个 Iterator。'
            'Iterator（迭代器）同时实现了 __iter__（返回 self）和 __next__ 方法。'
            '所有迭代器都是可迭代对象，反之则不一定。',
          ),
          CodeBlock(
            r'''from collections.abc import Iterable, Iterator

# 列表是可迭代对象，但不是迭代器
my_list = [1, 2, 3]
print(f"列表是可迭代对象: {isinstance(my_list, Iterable)}")
print(f"列表是迭代器: {isinstance(my_list, Iterator)}")

# iter() 将可迭代对象转换为迭代器
list_iter = iter(my_list)
print(f"列表迭代器是可迭代对象: {isinstance(list_iter, Iterable)}")
print(f"列表迭代器是迭代器: {isinstance(list_iter, Iterator)}")

# 关键区别: 迭代器是有状态的，只能前进不能后退
iterator = iter([1, 2, 3, 4, 5])
print(f"next: {next(iterator)}")  # 1
print(f"next: {next(iterator)}")  # 2
# 列表推导式消费剩余元素
remaining = [x for x in iterator]
print(f"剩余元素: {remaining}")  # [3, 4, 5]
print(f"迭代器已耗尽: {list(iterator)}")  # []

# 可迭代对象可以被多次迭代
print(f"第一次遍历列表: {[x * 2 for x in my_list]}")
print(f"第二次遍历列表: {[x ** 2 for x in my_list]}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '列表是可迭代对象: True\n'
            '列表是迭代器: False\n'
            '列表迭代器是可迭代对象: True\n'
            '列表迭代器是迭代器: True\n'
            'next: 1\n'
            'next: 2\n'
            '剩余元素: [3, 4, 5]\n'
            '迭代器已耗尽: []\n'
            '第一次遍历列表: [2, 4, 6]\n'
            '第二次遍历列表: [1, 4, 9]',
          ),
          const SizedBox(height: 8),

          Paragraph('3.4 itertools 模块详解'),
          Paragraph(
            'itertools 是 Python 标准库中处理迭代器的神器。'
            '它提供了一系列高效的迭代器工具函数，可以组合出强大的数据处理流程。',
          ),
          CodeBlock(
            r'''from itertools import (
    chain, cycle, islice, count,
    product, permutations, combinations,
    groupby, zip_longest, starmap
)

print("=== chain: 串联多个可迭代对象 ===")
print(list(chain([1, 2, 3], [4, 5], "ab")))

print("\n=== cycle + islice: 循环和截取 ===")
print(list(islice(cycle(["A", "B", "C"]), 7)))

print("\n=== count: 无限计数器 ===")
print(list(islice(count(start=10, step=2), 5)))

print("\n=== product: 笛卡尔积 ===")
print(list(product([1, 2], ["a", "b"])))

print("\n=== permutations: 排列 ===")
print(list(permutations([1, 2, 3], 2)))

print("\n=== combinations: 组合 ===")
print(list(combinations([1, 2, 3, 4], 2)))

print("\n=== groupby: 分组 ===")
data = [("水果", "苹果"), ("水果", "香蕉"), ("蔬菜", "白菜"), ("水果", "樱桃")]
for category, items in groupby(data, key=lambda x: x[0]):
    print(f"  {category}: {[item[1] for item in items]}")

print("\n=== zip_longest: 补全短的可迭代对象 ===")
print(list(zip_longest([1, 2, 3], ["a", "b"], fillvalue="-")))

print("\n=== starmap: 用元组参数映射 ===")
print(list(starmap(pow, [(2, 3), (3, 2), (2, 10)])))''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== chain: 串联多个可迭代对象 ===\n'
            '[1, 2, 3, 4, 5, \'a\', \'b\']\n'
            '\n'
            '=== cycle + islice: 循环和截取 ===\n'
            '[\'A\', \'B\', \'C\', \'A\', \'B\', \'C\', \'A\']\n'
            '\n'
            '=== count: 无限计数器 ===\n'
            '[10, 12, 14, 16, 18]\n'
            '\n'
            '=== product: 笛卡尔积 ===\n'
            '[(1, \'a\'), (1, \'b\'), (2, \'a\'), (2, \'b\')]\n'
            '\n'
            '=== permutations: 排列 ===\n'
            '[(1, 2), (1, 3), (2, 1), (2, 3), (3, 1), (3, 2)]\n'
            '\n'
            '=== combinations: 组合 ===\n'
            '[(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)]\n'
            '\n'
            '=== groupby: 分组 ===\n'
            '  水果: [\'苹果\', \'香蕉\']\n'
            '  蔬菜: [\'白菜\']\n'
            '  水果: [\'樱桃\']\n'
            '\n'
            '=== zip_longest: 补全短的可迭代对象 ===\n'
            '[(1, \'a\'), (2, \'b\'), (3, \'-\')]\n'
            '\n'
            '=== starmap: 用元组参数映射 ===\n'
            '[8, 9, 1024]',
          ),
          const SizedBox(height: 8),

          TipBox(
            '注意：迭代器是"一次性"的。一旦遍历完毕，就不能再使用。'
            '如果需要多次遍历数据，请保留原始可迭代对象或使用 list() 将迭代结果缓存。',
            type: TipType.caution,
          ),

          const DividerLine(),

          // ============================================================
          // 4. 装饰器深入
          // ============================================================
          SectionHeader('4. 装饰器深入 (Decorator)', icon: Icons.style),

          Paragraph(
            '装饰器是 Python 中实现 AOP（面向切面编程）的核心工具。'
            '它们允许在不修改原函数代码的前提下，动态地为函数添加功能。'
            '这一节我们深入探讨装饰器的高级用法。',
          ),

          const SizedBox(height: 8),
          Paragraph('4.1 @wraps 保留原函数元信息'),
          Paragraph(
            '使用 functools.wraps 可以将原函数的名称、文档字符串、'
            '参数签名等元信息复制到包装函数上，避免调试信息混淆。',
          ),
          CodeBlock(
            r'''from functools import wraps

def decorator_without_wraps(func):
    def wrapper(*args, **kwargs):
        """包装函数的文档"""
        print(f"调用: {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

def decorator_with_wraps(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        """包装函数的文档"""
        print(f"调用: {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@decorator_without_wraps
def greet_no_wraps(name):
    """向某人问好"""
    return f"你好, {name}!"

@decorator_with_wraps
def greet_with_wraps(name):
    """向某人问好"""
    return f"你好, {name}!"

print("=== 不使用 @wraps ===")
print(f"函数名: {greet_no_wraps.__name__}")
print(f"文档: {greet_no_wraps.__doc__}")

print("\n=== 使用 @wraps ===")
print(f"函数名: {greet_with_wraps.__name__}")
print(f"文档: {greet_with_wraps.__doc__}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== 不使用 @wraps ===\n'
            '函数名: wrapper\n'
            '文档: 包装函数的文档\n'
            '\n'
            '=== 使用 @wraps ===\n'
            '函数名: greet_with_wraps\n'
            '文档: 向某人问好',
          ),
          const SizedBox(height: 8),

          Paragraph('4.2 带参数的装饰器'),
          Paragraph(
            '带参数的装饰器实际上是三层嵌套函数：'
            '外层接收装饰器参数，中层接收原函数，内层是包装函数。'
            '这种模式可以实现可配置的装饰器。',
          ),
          CodeBlock(
            r'''from functools import wraps
import time
import random

def retry(max_attempts=3, delay=1.0, verbose=True):
    """重试装饰器: 函数执行失败时自动重试"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(1, max_attempts + 1):
                try:
                    result = func(*args, **kwargs)
                    if verbose and attempt > 1:
                        print(f"  第{attempt}次重试成功")
                    return result
                except Exception as e:
                    last_exception = e
                    if verbose:
                        print(f"  第{attempt}次失败: {e}")
                    if attempt < max_attempts:
                        time.sleep(delay)
            raise last_exception
        return wrapper
    return decorator

# 使用默认参数
@retry()
def unstable_request():
    """模拟不稳定的网络请求"""
    if random.random() < 0.6:
        raise ConnectionError("网络连接失败")
    return "数据获取成功"

# 自定义参数
@retry(max_attempts=5, delay=0.3, verbose=False)
def critical_task():
    """关键任务，静默重试"""
    if random.random() < 0.8:
        raise RuntimeError("任务失败")
    return "关键任务完成"

print("测试不稳定请求:")
for i in range(3):
    try:
        result = unstable_request()
        print(f"  结果: {result}")
    except Exception as e:
        print(f"  最终失败: {e}")

print("\n测试关键任务:")
result = critical_task()
print(f"  结果: {result}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '测试不稳定请求:\n'
            '  第1次失败: 网络连接失败\n'
            '  第2次失败: 网络连接失败\n'
            '  第3次成功\n'
            '  结果: 数据获取成功\n'
            '  第1次成功\n'
            '  结果: 数据获取成功\n'
            '  第1次失败: 网络连接失败\n'
            '  第2次成功\n'
            '  结果: 数据获取成功\n'
            '\n'
            '测试关键任务:\n'
            '  结果: 关键任务完成',
          ),
          const SizedBox(height: 8),

          Paragraph('4.3 基于类的装饰器'),
          Paragraph(
            '通过实现 __call__ 方法，类也可以作为装饰器使用。'
            '类装饰器的优势在于可以维护内部状态，适合需要计数的场景。',
          ),
          CodeBlock(
            r'''from functools import wraps

class CountCalls:
    """统计函数调用次数的装饰器"""

    def __init__(self, func):
        self.func = func
        self.calls = 0

    def __call__(self, *args, **kwargs):
        self.calls += 1
        print(f"调用 #{self.calls}  {self.func.__name__}({args}, {kwargs})")
        return self.func(*args, **kwargs)


class CacheResult:
    """缓存函数结果的装饰器"""

    def __init__(self, func):
        self.func = func
        self.cache = {}

    def __call__(self, *args, **kwargs):
        key = str(args) + str(kwargs)
        if key in self.cache:
            print(f"缓存命中: {key}")
            return self.cache[key]
        result = self.func(*args, **kwargs)
        self.cache[key] = result
        print(f"缓存未命中: {key} -> {result}")
        return result


@CountCalls
def say_hello(name):
    print(f"Hello, {name}!")

@CacheResult
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


print("=== CountCalls 示例 ===")
say_hello("Alice")
say_hello("Bob")
say_hello("Charlie")
print(f"总计调用: {say_hello.calls} 次")

print("\n=== CacheResult 示例 ===")
print(f"fibonacci(10) = {fibonacci(10)}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== CountCalls 示例 ===\n'
            '调用 #1  say_hello((\'Alice\',), {})\n'
            'Hello, Alice!\n'
            '调用 #2  say_hello((\'Bob\',), {})\n'
            'Hello, Bob!\n'
            '调用 #3  say_hello((\'Charlie\',), {})\n'
            'Hello, Charlie!\n'
            '总计调用: 3 次\n'
            '\n'
            '=== CacheResult 示例 ===\n'
            '缓存未命中: (10,){} -> 55\n'
            'fibonacci(10) = 55',
          ),
          const SizedBox(height: 8),

          Paragraph('4.4 多个装饰器堆叠与实用示例'),
          Paragraph(
            '多个装饰器从下往上应用，从上往下执行。'
            '理解这个顺序对正确使用装饰器至关重要。',
          ),
          CodeBlock(
            r'''from functools import wraps
import time

def timer(func):
    """计时装饰器: 测量函数执行时间"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"[计时] {func.__name__} 耗时: {elapsed * 1000:.2f}ms")
        return result
    return wrapper

def logger(prefix="LOG"):
    """日志装饰器 (带参数)"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            args_str = ", ".join(str(a) for a in args)
            kwargs_str = ", ".join(f"{k}={v}" for k, v in kwargs.items())
            all_args = ", ".join(filter(None, [args_str, kwargs_str]))
            print(f"[{prefix}] 调用: {func.__name__}({all_args})")
            result = func(*args, **kwargs)
            print(f"[{prefix}] 返回: {result}")
            return result
        return wrapper
    return decorator

# 实用装饰器: 速率限制
class RateLimit:
    """速率限制装饰器: 限制函数调用频率"""

    def __init__(self, func):
        self.func = func
        self.last_called = 0.0
        self.min_interval = 1.0  # 最小调用间隔(秒)

    def __call__(self, *args, **kwargs):
        elapsed = time.time() - self.last_called
        if elapsed < self.min_interval:
            wait_time = self.min_interval - elapsed
            print(f"[限流] 请等待 {wait_time:.1f} 秒")
            time.sleep(wait_time)
        self.last_called = time.time()
        return self.func(*args, **kwargs)


# 堆叠装饰器: 从下到上应用
# 先应用 @timer，再应用 @logger()
@logger(prefix="API")
@timer
def process_data(data):
    """处理数据"""
    time.sleep(0.1)  # 模拟耗时操作
    return f"处理完成: {len(data)} 条记录"

@RateLimit
def api_call(request_id):
    print(f"执行 API 请求 #{request_id}")
    return {"status": "ok", "id": request_id}


print("=== 装饰器堆叠 ===")
result = process_data([1, 2, 3, 4, 5])

print("\n=== 速率限制 ===")
for i in range(3):
    api_call(i)''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== 装饰器堆叠 ===\n'
            '[API] 调用: process_data([1, 2, 3, 4, 5])\n'
            '[计时] process_data 耗时: 100.12ms\n'
            '[API] 返回: 处理完成: 5 条记录\n'
            '\n'
            '=== 速率限制 ===\n'
            '执行 API 请求 #0\n'
            '执行 API 请求 #1\n'
            '[限流] 请等待 1.0 秒\n'
            '执行 API 请求 #2\n'
            '[限流] 请等待 1.0 秒',
          ),
          const SizedBox(height: 8),

          TipBox(
            '理解装饰器执行顺序：堆叠多个装饰器时，最靠近函数的装饰器先应用，'
            '最外层的装饰器最后应用。执行时则相反——外层装饰器先执行。',
            type: TipType.info,
          ),

          const DividerLine(),

          // ============================================================
          // 5. 上下文管理器深入
          // ============================================================
          SectionHeader('5. 上下文管理器深入 (Context Manager)', icon: Icons.manage_accounts),

          Paragraph(
            '上下文管理器通过 with 语句提供了一种优雅的资源管理方式。'
            '除了常见的文件操作，Python 的 contextlib 模块还提供了许多高级工具，'
            '让自定义上下文管理器变得更加简单。',
          ),

          const SizedBox(height: 8),
          Paragraph('5.1 使用 @contextmanager 装饰器'),
          Paragraph(
            'contextlib.contextmanager 装饰器让你可以用生成器函数'
            '来定义上下文管理器，无需编写单独的类。'
            'yield 之前的代码相当于 __enter__，之后的代码相当于 __exit__。',
          ),
          CodeBlock(
            r'''from contextlib import contextmanager
import time

@contextmanager
def timed_block(label):
    """计时上下文管理器: 测量代码块执行时间"""
    print(f"[{label}] 开始")
    start = time.perf_counter()
    try:
        yield  # 上下文代码在这里执行
    finally:
        elapsed = time.perf_counter() - start
        print(f"[{label}] 结束, 耗时: {elapsed * 1000:.2f}ms")


@contextmanager
def transaction(name):
    """模拟数据库事务"""
    print(f"[事务:{name}] 开始事务")
    try:
        yield
        print(f"[事务:{name}] 提交事务")
    except Exception as e:
        print(f"[事务:{name}] 回滚事务: {e}")
        raise


print("=== 计时上下文 ===")
with timed_block("数据加载"):
    time.sleep(0.05)
    print("  加载数据中...")
    time.sleep(0.05)

print("\n=== 事务上下文 ===")
try:
    with transaction("用户注册"):
        print("  插入用户数据")
        print("  发送验证邮件")
        # 模拟成功
except Exception:
    pass

print("\n=== 嵌套使用 ===")
with timed_block("完整流程"):
    with transaction("订单创建"):
        time.sleep(0.02)
        print("  创建订单成功")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== 计时上下文 ===\n'
            '[数据加载] 开始\n'
            '  加载数据中...\n'
            '[数据加载] 结束, 耗时: 100.15ms\n'
            '\n'
            '=== 事务上下文 ===\n'
            '[事务:用户注册] 开始事务\n'
            '  插入用户数据\n'
            '  发送验证邮件\n'
            '[事务:用户注册] 提交事务\n'
            '\n'
            '=== 嵌套使用 ===\n'
            '[完整流程] 开始\n'
            '[事务:订单创建] 开始事务\n'
            '  创建订单成功\n'
            '[事务:订单创建] 提交事务\n'
            '[完整流程] 结束, 耗时: 20.05ms',
          ),
          const SizedBox(height: 8),

          Paragraph('5.2 contextlib.closing 与 contextlib.suppress'),
          Paragraph(
            'closing 确保上下文退出时调用对象的 close 方法。'
            'suppress 则优雅地忽略指定异常，相当于 try/except pass 的简洁版本。',
          ),
          CodeBlock(
            r'''from contextlib import closing, suppress
import urllib.request
import os

# closing 示例: 确保连接被关闭
class CustomConnection:
    def __init__(self, name):
        self.name = name
        print(f"  打开连接: {name}")

    def query(self, sql):
        print(f"  执行: {sql}")

    def close(self):
        print(f"  关闭连接: {self.name}")

print("=== closing 确保资源释放 ===")
with closing(CustomConnection("数据库主库")) as conn:
    conn.query("SELECT * FROM users")
    conn.query("SELECT * FROM orders")
# 即使发生异常，close 也会被调用

print("\n=== suppress 忽略指定异常 ===")
# 传统方式
try:
    os.remove("temp_file.txt")
except FileNotFoundError:
    pass

# suppress 方式
with suppress(FileNotFoundError):
    os.remove("temp_file.txt")

# 多个异常
with suppress(FileNotFoundError, PermissionError):
    with open("/etc/shadow", "r") as f:  # 无权限时静默忽略
        pass

# 实用: 忽略特定异常继续执行
def safe_convert(value, to_type=int):
    with suppress(ValueError, TypeError):
        return to_type(value)
    return None

print(f"转换 '42': {safe_convert('42')}")
print(f"转换 'abc': {safe_convert('abc')}")
print(f"转换 None: {safe_convert(None)}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== closing 确保资源释放 ===\n'
            '  打开连接: 数据库主库\n'
            '  执行: SELECT * FROM users\n'
            '  执行: SELECT * FROM orders\n'
            '  关闭连接: 数据库主库\n'
            '\n'
            '=== suppress 忽略指定异常 ===\n'
            '转换 \'42\': 42\n'
            '转换 \'abc\': None\n'
            '转换 None: None',
          ),
          const SizedBox(height: 8),

          Paragraph('5.3 ExitStack 高级资源管理'),
          Paragraph(
            'ExitStack 提供了动态管理多个上下文管理器的能力。'
            '你可以在运行时按需注册和释放资源，特别适合管理数量不固定的资源。',
          ),
          CodeBlock(
            r'''from contextlib import ExitStack
from typing import List

class ManagedResource:
    """模拟需要管理的资源"""

    def __init__(self, resource_id):
        self.resource_id = resource_id
        print(f"  [+] 分配资源: {resource_id}")

    def __enter__(self):
        print(f"  [>] 打开资源: {self.resource_id}")
        return self

    def __exit__(self, *args):
        print(f"  [<] 关闭资源: {self.resource_id}")

    def use(self):
        print(f"  [*] 使用资源: {self.resource_id}")


print("=== ExitStack 示例 ===")

# 动态管理多个资源
with ExitStack() as stack:
    # 按需注册资源
    resources = []
    for i in range(3):
        res = stack.enter_context(ManagedResource(f"res-{i}"))
        resources.append(res)

    print("  --- 所有资源已就绪 ---")
    for res in resources:
        res.use()

    print("  --- 准备退出 ---")
# 退出 with 块后，所有资源按注册顺序的逆序自动释放

print("\n=== ExitStack 回调机制 ===")
with ExitStack() as stack:
    # 注册回调函数，退出时按 LIFO 顺序调用
    stack.callback(lambda: print("  [回调3] 发送通知邮件"))
    stack.callback(lambda: print("  [回调2] 记录审计日志"))
    stack.callback(lambda: print("  [回调1] 清理临时文件"))
    print("  主任务执行中...")

print("\n=== ExitStack 条件资源管理 ===")
def process_with_resources(items, use_database=False):
    """根据条件动态管理资源"""
    with ExitStack() as stack:
        # 总是需要文件资源
        file_res = stack.enter_context(ManagedResource("文件系统"))
        # 按需使用数据库
        if use_database:
            db_res = stack.enter_context(ManagedResource("数据库连接"))
        print(f"  处理 {len(items)} 个项目...")
        # 自动释放所有资源

process_with_resources([1, 2, 3], use_database=True)''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== ExitStack 示例 ===\n'
            '  [+] 分配资源: res-0\n'
            '  [>] 打开资源: res-0\n'
            '  [+] 分配资源: res-1\n'
            '  [>] 打开资源: res-1\n'
            '  [+] 分配资源: res-2\n'
            '  [>] 打开资源: res-2\n'
            '  --- 所有资源已就绪 ---\n'
            '  [*] 使用资源: res-0\n'
            '  [*] 使用资源: res-1\n'
            '  [*] 使用资源: res-2\n'
            '  --- 准备退出 ---\n'
            '  [<] 关闭资源: res-2\n'
            '  [<] 关闭资源: res-1\n'
            '  [<] 关闭资源: res-0\n'
            '\n'
            '=== ExitStack 回调机制 ===\n'
            '  主任务执行中...\n'
            '  [回调3] 发送通知邮件\n'
            '  [回调2] 记录审计日志\n'
            '  [回调1] 清理临时文件\n'
            '\n'
            '=== ExitStack 条件资源管理 ===\n'
            '  [+] 分配资源: 文件系统\n'
            '  [>] 打开资源: 文件系统\n'
            '  [+] 分配资源: 数据库连接\n'
            '  [>] 打开资源: 数据库连接\n'
            '  处理 3 个项目...\n'
            '  [<] 关闭资源: 数据库连接\n'
            '  [<] 关闭资源: 文件系统',
          ),
          const SizedBox(height: 8),

          TipBox(
            '最佳实践：使用 @contextmanager 快速创建上下文管理器；'
            '使用 ExitStack 管理动态数量的资源；'
            '使用 suppress 优雅地忽略预期的异常。',
            type: TipType.tip,
          ),

          const DividerLine(),

          // ============================================================
          // 6. 海象运算符 :=
          // ============================================================
          SectionHeader('6. 海象运算符 := (Walrus Operator)', icon: Icons.more_horiz),

          Paragraph(
            '海象运算符（赋值表达式）是 Python 3.8 引入的重要特性。'
            '它允许在表达式中进行赋值，然后立即使用该值。'
            '这不仅减少了代码重复，还使某些代码模式更加简洁清晰。',
          ),

          const SizedBox(height: 8),
          Paragraph('6.1 基本语法与传统写法对比'),
          Paragraph(
            '对比传统代码和海象运算符的写法，可以清晰地看出其优势：'
            '减少重复计算，使代码更加紧凑。',
          ),
          CodeBlock(
            r'''# 场景1: 在条件判断中同时赋值和比较
import re

text = "联系邮箱: user@example.com, 备用: admin@test.com"

# 传统写法: 需要先赋值再比较
pattern = r"\w+@\w+\.\w+"
match = re.search(pattern, text)
if match:
    print(f"传统写法 - 找到邮箱: {match.group()}")
else:
    print("未找到")

# 海象运算符: 一次完成
if match := re.search(pattern, text):
    print(f"海象写法 - 找到邮箱: {match.group()}")


# 场景2: 列表推导式中避免重复计算
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# 传统: 重复计算 x ** 2
squares_over_25 = [x ** 2 for x in numbers if x ** 2 > 25]
print(f"传统推导式: {squares_over_25}")

# 海象: 只计算一次
squares_over_25_walrus = [sq for x in numbers if (sq := x ** 2) > 25]
print(f"海象推导式: {squares_over_25_walrus}")


# 场景3: 处理输入
def get_user_input():
    """模拟用户输入"""
    inputs = ["hello", "world", "exit", "python"]
    for inp in inputs:
        yield inp

input_gen = get_user_input()

# 传统写法
while True:
    value = next(input_gen, None)
    if value is None or value == "exit":
        break
    print(f"处理: {value.upper()}")

# 海象写法 (重置生成器)
input_gen = get_user_input()
while (value := next(input_gen, None)) is not None and value != "exit":
    print(f"处理: {value.upper()}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '传统写法 - 找到邮箱: user@example.com\n'
            '海象写法 - 找到邮箱: user@example.com\n'
            '传统推导式: [36, 49, 64, 81, 100]\n'
            '海象推导式: [36, 49, 64, 81, 100]\n'
            '处理: HELLO\n'
            '处理: WORLD\n'
            '处理: HELLO\n'
            '处理: WORLD',
          ),
          const SizedBox(height: 8),

          Paragraph('6.2 while 循环中的典型应用'),
          Paragraph(
            '海象运算符在 while 循环中特别有用，可以将"读取-测试-使用"'
            '三个步骤合并为一个表达式。这在处理数据流和读取文件时非常实用。',
          ),
          CodeBlock(
            r'''# 示例1: 读取文件块
def read_chunks(data, chunk_size=5):
    """模拟分块读取数据"""
    i = 0
    while i < len(data):
        yield data[i:i + chunk_size]
        i += chunk_size

data_stream = "Python高级特性学习指南2024"
stream = read_chunks(data_stream)

print("=== 分块读取数据 ===")
while (chunk := next(stream, None)) is not None:
    print(f"  处理块: {chunk}")


# 示例2: 数据处理中的过滤
def generate_numbers():
    """生成测试数据"""
    import random
    for _ in range(10):
        yield random.randint(1, 100)

print("\n=== 过滤并处理数据 ===")
numbers = generate_numbers()
results = []
while (n := next(numbers, None)) is not None:
    if (doubled := n * 2) > 100:
        print(f"  {n} * 2 = {doubled} (超过100)")
    results.append(doubled)


# 示例3: 解析结构化数据
def parse_tokens(tokens):
    """解析标记流"""
    i = 0
    parsed = []
    while i < len(tokens):
        if (token := tokens[i]) == "NUM":
            if i + 1 < len(tokens) and (value := tokens[i + 1]).isdigit():
                parsed.append(("数字", int(value)))
                i += 2
                continue
        elif token == "CMD":
            parsed.append(("命令", tokens[i + 1] if i + 1 < len(tokens) else "?"))
            i += 2
            continue
        i += 1
    return parsed

tokens = ["NUM", "42", "CMD", "PRINT", "NUM", "abc"]
print(f"\n解析结果: {parse_tokens(tokens)}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '=== 分块读取数据 ===\n'
            '  处理块: Python\n'
            '  处理块: 高级特\n'
            '  处理块: 性学习\n'
            '  处理块: 指南20\n'
            '  处理块: 24\n'
            '\n'
            '=== 过滤并处理数据 ===\n'
            '  72 * 2 = 144 (超过100)\n'
            '  94 * 2 = 188 (超过100)\n'
            '  88 * 2 = 176 (超过100)\n'
            '\n'
            '解析结果: [(\'数字\', 42), (\'命令\', \'PRINT\')]',
          ),
          const SizedBox(height: 8),

          Paragraph('6.3 推导式优化与复杂表达式'),
          Paragraph(
            '海象运算符可以显著优化推导式中的重复计算，'
            '特别是在涉及复杂表达式或函数调用时效果更明显。',
          ),
          CodeBlock(
            r'''# 复杂计算优化
def expensive_calculation(x):
    """模拟耗时计算"""
    return sum(i ** 2 for i in range(x))

numbers = [3, 5, 7, 10, 15, 20, 25]

# 不用海象运算符: 每次条件判断都重新计算
filtered_old = [expensive_calculation(n) for n in numbers
                if expensive_calculation(n) > 50]
print(f"传统方式: {filtered_old}")

# 用海象运算符: 只计算一次
filtered_new = [result for n in numbers
                if (result := expensive_calculation(n)) > 50]
print(f"海象方式: {filtered_new}")


# 复杂数据处理
def process_text(text):
    """处理文本并返回统计信息"""
    words = text.split()
    word_lengths = {
        word: length
        for word in words
        if (length := len(word)) > 3
    }
    return word_lengths

text = "Python is an amazing programming language for data science"
result = process_text(text)
print(f"\n长单词统计: {result}")


# 嵌套海象运算符 (谨慎使用)
def analyze_data(data):
    """分析数据集"""
    return {
        "count": (n := len(data)),
        "total": (t := sum(data)),
        "average": t / n if n > 0 else 0,
        "max_value": max(data) if n > 0 else None,
    }

data = [12, 45, 67, 23, 89, 34, 55]
analysis = analyze_data(data)
print(f"\n数据分析结果:")
for key, value in analysis.items():
    print(f"  {key}: {value}")''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '传统方式: [55, 91, 140, 285, 385, 525, 700]\n'
            '海象方式: [55, 91, 140, 285, 385, 525, 700]\n'
            '\n'
            '长单词统计: {\'Python\': 6, \'amazing\': 7, \'programming\': 11, '
            '\'language\': 8, \'science\': 7}\n'
            '\n'
            '数据分析结果:\n'
            '  count: 7\n'
            '  total: 325\n'
            '  average: 46.42857142857143\n'
            '  max_value: 89',
          ),
          const SizedBox(height: 8),

          Paragraph('6.4 海象运算符的使用边界与注意事项'),
          Paragraph(
            '海象运算符虽然强大，但不适合所有场景。'
            '过度使用会降低代码可读性，要权衡简洁性和清晰性。',
          ),
          CodeBlock(
            r'''# 推荐的正确用法

# 1. 在条件中赋值并使用
def find_first_match(items, predicate):
    """查找第一个匹配项"""
    for item in items:
        if (result := predicate(item)) is not None:
            return result
    return None

data = ["apple", "banana", "cherry", "dragonfruit"]
result = find_first_match(
    data,
    lambda s: s.upper() if len(s) > 6 else None
)
print(f"第一个长单词大写: {result}")

# 2. 列表推导式中优化
prices = [99, 150, 200, 49, 300, 75]
price_with_tax = [
    final_price
    for p in prices
    if (final_price := p * 1.1) > 100
]
print(f"\n含税价格超过100: {price_with_tax}")

# 3. 部分求值
partial_sums = []
current_sum = 0
numbers = [1, 2, 3, 4, 5, 6]
for n in numbers:
    if (current_sum := current_sum + n) > 10:
        partial_sums.append(current_sum)
print(f"\n部分和超过10: {partial_sums}")


# 不推荐的反面案例:

# 错误: 降低可读性
# if (a := len(x)) > 5 and (b := sum(x)) > 10 and (c := b / a) > 2:
#     print(a, b, c)

# 更好: 分开赋值
# a = len(x)
# b = sum(x)
# if a > 5 and b > 10 and (c := b / a) > 2:
#     print(a, b, c)

# 错误: 作用域混淆
# 在推导式中赋值的变量会泄漏到外部作用域
squares = [sq for x in range(5) if (sq := x ** 2) > 5]
print(f"\n推导式外部访问 sq: {sq}")  # 注意: sq 在 Python 3.8+ 中会泄漏''',
            language: 'Python',
          ),
          const SizedBox(height: 4),
          OutputBox(
            '第一个长单词大写: DRAGONFRUIT\n'
            '\n'
            '含税价格超过100: [165.0, 220.0, 330.0, 82.5]\n'
            '\n'
            '部分和超过10: [15, 21]\n'
            '\n'
            '推导式外部访问 sq: 16',
          ),
          const SizedBox(height: 8),

          TipBox(
            '使用原则：海象运算符最适合在 if 条件或 while 循环中减少重复计算。'
            '如果赋值使表达式变得难以理解，不如分开写为多行。'
            '可读性永远优先于代码行数。',
            type: TipType.warning,
          ),

          const _ListComprehensionAdvDemo(),
          const _DecoratorDemo(),
          const DividerLine(),

          // ============================================================
          // 章节总结
          // ============================================================
          const SizedBox(height: 8),
          SectionHeader('本章总结', icon: Icons.summarize),
          Paragraph(
            '本章学习了 Python 的六大高级特性，它们是写出 Pythonic 代码的关键：',
          ),
          StepItem(
            step: 1,
            title: '列表推导式深入',
            description: '掌握了嵌套推导式、字典/集合推导式、条件推导式，'
                '以及海象运算符在推导式中的应用。注意避免过度嵌套。',
          ),
          StepItem(
            step: 2,
            title: '生成器',
            description: '理解了 yield 关键字的工作原理、生成器表达式与列表推导式的'
                '内存效率差异、yield from 委托生成器，以及如何构建数据处理管道。',
          ),
          StepItem(
            step: 3,
            title: '迭代器',
            description: '学会了 iter()/next() 的基本使用、自定义迭代器的实现、'
                'Iterable 与 Iterator 的区别，以及 itertools 模块中 chain、'
                'cycle、product、permutations、groupby 等强大工具。',
          ),
          StepItem(
            step: 4,
            title: '装饰器深入',
            description: '掌握了 @wraps 保留元信息、带参数的装饰器、'
                '基于类的装饰器、多装饰器堆叠，以及 retry、cache、rate_limit 等实用示例。',
          ),
          StepItem(
            step: 5,
            title: '上下文管理器深入',
            description: '熟练使用 @contextmanager 快速创建上下文管理器，'
                '以及 contextlib.closing、contextlib.suppress、ExitStack 等高级工具。',
          ),
          StepItem(
            step: 6,
            title: '海象运算符 :=',
            description: '理解了赋值表达式的核心价值：减少重复计算、优化推导式、'
                '简化 while 循环，同时也了解了其使用边界和注意事项。',
          ),
          const SizedBox(height: 16),
          TipBox(
            '进阶学习方向：深入研究 asyncio 异步编程、元类（Metaclass）、'
            '描述符（Descriptor）、抽象基类（ABC）等更高级的 Python 特性。',
            type: TipType.info,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
