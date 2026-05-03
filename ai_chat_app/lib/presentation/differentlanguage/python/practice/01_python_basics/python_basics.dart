import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 基础入门 —— 第一课（含完整交互式演示）
/// 涵盖：简介、环境、语法基础、变量、数据类型、运算符、字符串、输入输出、编码规范
class PythonBasics extends StatelessWidget {
  const PythonBasics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第1章 Python 基础入门'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① Python 简介与哲学\n'
            '② 安装与环境\n'
            '③ 第一个程序\n'
            '④ 注释与文档字符串\n'
            '⑤ PEP 8 编码规范\n'
            '⑥ 变量与赋值\n'
            '⑦ 基本数据类型（含 None/bytes）\n'
            '⑧ 运算符大全与优先级\n'
            '⑨ 字符串进阶（f-string/转义/原始字符串）\n'
            '⑩ 输入输出\n'
            '⑪ 类型转换与类型检查',
          ),
          const TipBox(
            'Python 是一门"优雅"的语言。它的设计哲学是"用一种方法，最好是只有一种方法来做一件事"。\n'
            '—— Tim Peters（Python 之禅）',
            type: TipType.info,
          ),
          const DividerLine(),

          // ===== 1. Python 简介 =====
          SectionHeader('1. Python 简介', icon: Icons.info_outline),
          const Paragraph(
            'Python 由 Guido van Rossum 于 1991 年发布，是一种解释型、面向对象、'
            '动态数据类型的高级编程语言。它的语法极其简洁，用缩进来表示代码块，'
            '没有繁琐的花括号和分号。',
          ),
          const Paragraph(
            '应用领域：\n'
            '  • 数据科学 & AI：NumPy、Pandas、TensorFlow、PyTorch\n'
            '  • Web 开发：Django、Flask、FastAPI\n'
            '  • 自动化运维：Ansible、Selenium\n'
            '  • 爬虫：Scrapy、BeautifulSoup\n'
            '  • 桌面应用：PyQt、Tkinter\n'
            '  • 游戏开发：Pygame',
          ),
          const TipBox(
            'Python 的名字来源于英国喜剧团体 Monty Python 的飞行马戏团，而不是蟒蛇。'
            '但官方 Logo 确实是两条蟒蛇！',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== 2. 第一个程序 =====
          SectionHeader('2. 第一个程序', icon: Icons.play_arrow),
          const Paragraph('按照编程界的传统，让计算机说 "Hello, World!"。print() 是 Python 最常用的内置函数。'),
          const CodeBlock(
            '# 第一个 Python 程序\n'
            'print("Hello, World!")    # 输出英文\n'
            'print("你好，世界！")      # 支持中文\n'
            'print(42)                 # 直接输出数字\n'
            'print(3.14)               # 输出小数\n'
            'print(True)               # 输出布尔值',
            language: 'Python',
          ),
          const OutputBox('Hello, World!\n你好，世界！\n42\n3.14\nTrue'),
          // 交互演示
          const _HelloWorldDemo(),
          const DividerLine(),

          // ===== 3. 注释 =====
          SectionHeader('3. 注释与文档字符串', icon: Icons.comment),
          const Paragraph(
            '注释是写给程序员看的，计算机会完全忽略。好的注释让代码更容易理解。'
            'Python 有单行注释、多行注释和文档字符串三种形式。',
          ),
          const CodeBlock(
            '# ===== 单行注释 =====\n'
            '# 这是单行注释，以 # 开头\n'
            'print("这行会执行")      # 行尾也可以加注释\n'
            '\n'
            '# ===== 多行注释 =====\n'
            '\'\'\'\n'
            '这是多行注释\n'
            '三个单引号或双引号都可以\n'
            '\'\'\'\n'
            '\n'
            '# ===== 文档字符串 DocString =====\n'
            'def add(a, b):\n'
            '    """返回两个数的和\n'
            '    \n'
            '    Args:\n'
            '        a: 第一个数\n'
            '        b: 第二个数\n'
            '    Returns:\n'
            '        两数之和\n'
            '    """\n'
            '    return a + b\n'
            '\n'
            'print(add.__doc__)  # 输出文档字符串',
            language: 'Python',
          ),
          const OutputBox('这行会执行\n返回两个数的和\n\nArgs:\n    a: 第一个数\n    b: 第二个数\nReturns:\n    两数之和'),
          const DividerLine(),

          // ===== 4. PEP 8 =====
          SectionHeader('4. PEP 8 —— Python 编码规范', icon: Icons.rule),
          const Paragraph(
            'PEP 8 是 Python 的官方编码风格指南。遵循 PEP 8 能让你的代码看起来像"真正的 Python 代码"。',
          ),
          const CompareBox(
            leftTitle: '❌ 不推荐写法',
            leftCode: 'x=1+2*3\n'
                'studentName="小明"\n'
                'def myFunc( a,b ) :\n'
                '  return a+b\n'
                'class myclass:\n'
                '  pass',
            rightTitle: '✅ PEP 8 推荐',
            rightCode: 'x = 1 + 2 * 3\n'
                'student_name = "小明"\n'
                'def my_func(a, b):\n'
                '    return a + b\n'
                'class MyClass:\n'
                '    pass',
          ),
          const DividerLine(),

          // ===== 5. 变量和赋值 =====
          SectionHeader('5. 变量与赋值', icon: Icons.label),
          const Paragraph(
            '变量就像带标签的盒子。Python 是动态类型语言——变量没有类型，值才有。',
          ),
          const CodeBlock(
            '# 基础赋值\n'
            'name = "小明"              # 字符串\n'
            'age = 18                   # 整数\n'
            'height = 1.75              # 浮点数\n'
            '\n'
            '# 多重赋值\n'
            'a, b, c = 1, 2, 3\n'
            'print(a, b, c)            # 1 2 3\n'
            '\n'
            '# 交换变量（Python 特色）\n'
            'x, y = 10, 20\n'
            'x, y = y, x              # 一行交换！\n'
            'print(x, y)              # 20 10\n'
            '\n'
            '# 增量赋值\n'
            'n = 10\n'
            'n += 5   # n = n + 5 = 15\n'
            'n -= 3   # n = n - 3 = 12\n'
            'n *= 2   # n = n * 2 = 24\n'
            'n //= 4  # n = n // 4 = 6\n'
            'print(n)  # 6',
            language: 'Python',
          ),
          const OutputBox('1 2 3\n20 10\n6'),
          // 交互演示
          const _VariableSwapDemo(),
          const DividerLine(),

          // ===== 6. 基本数据类型 =====
          SectionHeader('6. 基本数据类型', icon: Icons.category),
          const Paragraph(
            'Python 有 7 种基本数据类型。用 type() 可以查看任何数据的类型。一切皆对象。',
          ),
          const CodeBlock(
            '# 1. int 整数\n'
            'a = 42           # 十进制\n'
            'b = 0b1010       # 二进制 -> 10\n'
            'c = 0xFF         # 十六进制 -> 255\n'
            '\n'
            '# 2. float 浮点数\n'
            'pi = 3.14159\n'
            'e = 1.5e-4       # 科学计数法 -> 0.00015\n'
            '\n'
            '# 3. str 字符串\n'
            's = "Hello Python"\n'
            '\n'
            '# 4. bool 布尔值\n'
            't, f = True, False\n'
            '\n'
            '# 5. None 空值\n'
            'nothing = None\n'
            '\n'
            '# 6. bytes 字节串\n'
            'b = b"hello"\n'
            '\n'
            '# 7. complex 复数\n'
            'c = 3 + 4j\n'
            'print(c.real, c.imag)  # 3.0  4.0',
            language: 'Python',
          ),
          const OutputBox('3.0 4.0'),
          // 交互演示：类型检查器
          const _TypeCheckerDemo(),
          const DividerLine(),

          // ===== 7. 运算符大全 =====
          SectionHeader('7. 运算符大全', icon: Icons.calculate),
          const Paragraph(
            'Python 的运算符分为 7 大类。运算符优先级记不住就用括号 ()，括号的优先级最高。',
          ),
          const CodeBlock(
            '# 1. 算术运算符\n'
            'a, b = 10, 3\n'
            'print(a + b)    # 加 -> 13\n'
            'print(a - b)    # 减 -> 7\n'
            'print(a * b)    # 乘 -> 30\n'
            'print(a / b)    # 除 -> 3.333\n'
            'print(a // b)   # 整除 -> 3\n'
            'print(a % b)    # 取余 -> 1\n'
            'print(a ** b)   # 幂运算 -> 1000\n'
            '\n'
            '# 2. 比较运算符（返回 bool）\n'
            'print(5 == 5)   # True\n'
            'print(5 != 3)   # True\n'
            'print(5 > 3)    # True\n'
            '\n'
            '# 3. 逻辑运算符\n'
            'print(True and False)  # False\n'
            'print(True or False)   # True\n'
            'print(not True)        # False\n'
            '\n'
            '# 4. Python 特色：链式比较\n'
            'age = 25\n'
            'print(18 < age < 60)  # True\n'
            '\n'
            '# 5. 运算符优先级（高→低）\n'
            '# ** > +x -x > * / // % > + - > 比较 > not > and > or',
            language: 'Python',
          ),
          // 交互演示：运算符计算器
          const _OperatorCalculator(),
          const DividerLine(),

          // ===== 8. 字符串进阶 =====
          SectionHeader('8. 字符串进阶', icon: Icons.text_fields),
          const Paragraph(
            '字符串是 Python 中最常用的数据类型。重点掌握 f-string 的高级格式化用法。',
          ),
          const CodeBlock(
            '# f-string 格式化（Python 3.6+）\n'
            'name = "小明"; score = 95.5; rank = 3\n'
            '\n'
            '# 基础用法\n'
            'print(f"{name} 考了 {score} 分")\n'
            '\n'
            '# 数字格式化\n'
            'print(f"保留两位小数：{score:.2f}")   # 95.50\n'
            'print(f"百分比：{0.856:.1%}")          # 85.6%\n'
            'print(f"补零：{rank:03d}")              # 003\n'
            'print(f"千分位：{1234567:,}")           # 1,234,567\n'
            '\n'
            '# 对齐（宽度10）\n'
            'print(f"左对齐：{\"文本\":<10}|")     # 左对齐\n'
            'print(f"右对齐：{\"文本\":>10}|")     # 右对齐\n'
            'print(f"居中：{\"文本\":^10}|")       # 居中\n'
            '\n'
            '# 原始字符串（r-string）\n'
            r'path = r"C:\Users\name"   # \ 不转义',
            language: 'Python',
          ),
          // 交互演示：f-string 格式化游乐场
          const _FStringPlayground(),
          const DividerLine(),

          // ===== 9. 输入输出 =====
          SectionHeader('9. 输入与输出', icon: Icons.keyboard),
          const Paragraph(
            'input() 从键盘获取用户输入（总是返回字符串），print() 输出到屏幕。',
          ),
          const CodeBlock(
            '# input() 获取输入\n'
            'name = input("请输入你的名字：")    # 阻塞等待\n'
            'age = int(input("请输入年龄："))    # 转为整数\n'
            '\n'
            '# print() 高级用法\n'
            'print(1, 2, 3, sep="-")       # 1-2-3（自定义分隔符）\n'
            'print(2025, 1, 15, sep="/")   # 2025/1/15\n'
            'print("加载中", end="")        # 不换行\n'
            'print("...完成")               # 接着打印\n'
            '\n'
            '# 格式化输出\n'
            'print(f"你好 {name}，今年 {age} 岁")',
            language: 'Python',
          ),
          // 交互演示
          const _InputOutputDemo(),
          const DividerLine(),

          // ===== 10. 类型转换 =====
          SectionHeader('10. 类型转换与检查', icon: Icons.swap_horiz),
          const Paragraph(
            '类型转换分为隐式（自动）和显式（手动）两种。'
            '用 isinstance() 进行类型检查更安全。',
          ),
          const CodeBlock(
            '# 显式类型转换\n'
            'int("42")       # "42" -> 42\n'
            'float("3.14")   # "3.14" -> 3.14\n'
            'str(42)         # 42 -> "42"\n'
            'bool(0)         # 0 -> False\n'
            'bool("")        # "" -> False（空为假）\n'
            'bool("abc")     # "abc" -> True（非空为真）\n'
            '\n'
            '# int 截断 vs round 四舍五入\n'
            'int(3.9)    # 3（截断，不是四舍五入！）\n'
            'int(-3.9)   # -3\n'
            'round(3.9)  # 4\n'
            'round(3.5)  # 4\n'
            '\n'
            '# 类型检查\n'
            'isinstance(42, int)           # True\n'
            'isinstance(42, (int, float))  # True（多类型检查）',
            language: 'Python',
          ),
          // 交互演示：类型转换计算器
          const _TypeConversionDemo(),
          const DividerLine(),

          // ===== 11. Python 之禅 =====
          SectionHeader('11. Python 之禅', icon: Icons.auto_awesome),
          const CodeBlock(
            '>>> import this\n'
            'Beautiful is better than ugly.       # 优美胜于丑陋\n'
            'Explicit is better than implicit.    # 明了胜于晦涩\n'
            'Simple is better than complex.       # 简单胜于复杂\n'
            'Complex is better than complicated.  # 复杂胜于凌乱\n'
            'Flat is better than nested.          # 扁平胜于嵌套\n'
            'Readability counts.                  # 可读性很重要\n'
            'There should be one obvious way...   # 一种最优方式',
            language: 'Python',
          ),
          const DividerLine(),

          // ===== 练习题 =====
          SectionHeader('✏️ 练习题', icon: Icons.edit_note),
          const StepItem(step: 1, title: '个人信息卡', description: '用变量存储姓名、年龄、身高，用 f-string 格式化输出 "我叫XX，今年XX岁，身高XX米"。'),
          const StepItem(step: 2, title: '温度转换器', description: '输入摄氏温度，转换为华氏温度。公式：F = C * 9 / 5 + 32。'),
          const StepItem(step: 3, title: '运算符挑战', description: '计算 (2 + 3) * 4 ** 2 / 8 % 3 的结果，尝试不同括号组合改变结果。'),
          const StepItem(step: 4, title: 'f-string 格式化', description: '定义 price=12.5, count=3，输出 "总价：37.50 元"（两位小数）。'),
          const StepItem(step: 5, title: '类型侦探', description: '分别用 type() 和 isinstance() 检查 10、3.14、"Python"、True、None 的类型。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// Hello World 自定义演示
class _HelloWorldDemo extends StatefulWidget {
  const _HelloWorldDemo();
  @override
  State<_HelloWorldDemo> createState() => _HelloWorldDemoState();
}

class _HelloWorldDemoState extends State<_HelloWorldDemo> {
  String _name = '世界';
  int _times = 3;
  bool _showNumber = true;

  @override
  Widget build(BuildContext context) {
    final lines = List.generate(_times, (i) => _showNumber ? '${i + 1}. 你好，$_name！' : '你好，$_name！');
    final code = 'for i in range(1, ${_times + 1}):\n'
        '    ${_showNumber ? 'print(f"{i}. 你好，$_name！")' : 'print(f"你好，$_name！")'}';

    return InteractivePlayground(
      title: '🎉 Hello World 个性化',
      subtitle: '修改参数，实时看到 print() 输出变化',
      children: [
        ParamTextField(label: '名字', value: _name, onChanged: (v) => setState(() => _name = v.isEmpty ? '世界' : v), hint: '输入任意名字', maxLength: 10),
        ParamIntSlider(label: '打印次数', value: _times, min: 1, max: 8, onChanged: (v) => setState(() => _times = v)),
        ParamSwitch(label: '显示行号', value: _showNumber, onChanged: (v) => setState(() => _showNumber = v), trueLabel: '开', falseLabel: '关'),
        LiveCodeBlock(code),
        LiveOutputBox(lines.join('\n')),
      ],
    );
  }
}

/// 变量交换演示
class _VariableSwapDemo extends StatefulWidget {
  const _VariableSwapDemo();
  @override
  State<_VariableSwapDemo> createState() => _VariableSwapDemoState();
}

class _VariableSwapDemoState extends State<_VariableSwapDemo> {
  int _x = 10;
  int _y = 20;
  bool _swapped = false;

  @override
  Widget build(BuildContext context) {
    final cx = _swapped ? _y : _x;
    final cy = _swapped ? _x : _y;

    return InteractivePlayground(
      title: '🔄 变量交换演示',
      subtitle: '设置 x 和 y 的值，观察 Python 一行交换的神奇效果',
      children: [
        ParamIntSlider(label: 'x 的值', value: _x, min: 1, max: 50, onChanged: (v) => setState(() { _x = v; _swapped = false; })),
        ParamIntSlider(label: 'y 的值', value: _y, min: 1, max: 50, onChanged: (v) => setState(() { _y = v; _swapped = false; })),
        const SizedBox(height: 8),
        // 可视化状态
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _VarBox('x', cx, Colors.blue),
            const Icon(Icons.swap_horiz, size: 32, color: Colors.grey),
            _VarBox('y', cy, Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => setState(() => _swapped = !_swapped),
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: Text(_swapped ? '恢复原值' : '执行 x, y = y, x'),
        ),
        LiveCodeBlock(
          _swapped
              ? 'x, y = $_x, $_y\nx, y = y, x\nprint(x, y)  # x=${cy}, y=${cx}'
              : 'x, y = $_x, $_y\n# 执行前：x=$_x, y=$_y',
        ),
        LiveOutputBox(_swapped ? '交换后：x = $cy, y = $cx' : '交换前：x = $_x, y = $_y'),
      ],
    );
  }
}

class _VarBox extends StatelessWidget {
  final String name;
  final int value;
  final Color color;
  const _VarBox(this.name, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// 类型检查器
class _TypeCheckerDemo extends StatefulWidget {
  const _TypeCheckerDemo();
  @override
  State<_TypeCheckerDemo> createState() => _TypeCheckerDemoState();
}

class _TypeCheckerDemoState extends State<_TypeCheckerDemo> {
  final List<(String, String, Color)> _types = [
    ('42', "int（整数）", Colors.blue),
    ('3.14', "float（浮点数）", Colors.green),
    ('"Python"', "str（字符串）", Colors.purple),
    ('True', "bool（布尔值）", Colors.orange),
    ('None', "NoneType（空值）", Colors.grey),
    ('[1,2,3]', "list（列表）", Colors.red),
    ("{'a':1}", "dict（字典）", Colors.teal),
    ('(1,2)', "tuple（元组）", Colors.pink),
  ];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final (val, typeName, color) = _types[_selected];

    return InteractivePlayground(
      title: '🔍 Python 类型检查器',
      subtitle: '点击不同的值，查看 type() 的返回结果',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_types.length, (i) {
            final (v, _, c) = _types[i];
            return ChoiceChip(
              label: Text(v, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              selected: _selected == i,
              selectedColor: c.withOpacity(0.2),
              onSelected: (_) => setState(() => _selected = i),
            );
          }),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('type($val)', style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.arrow_forward, size: 16, color: color),
              const SizedBox(width: 8),
              Text("<class '$typeName'>", style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: color, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
        LiveCodeBlock('>>> type($val)\n<class \'${typeName.split('（').first}\'>'),
        LiveOutputBox("<class '${typeName.split('（').first}'>"),
      ],
    );
  }
}

/// 运算符计算器
class _OperatorCalculator extends StatefulWidget {
  const _OperatorCalculator();
  @override
  State<_OperatorCalculator> createState() => _OperatorCalculatorState();
}

class _OperatorCalculatorState extends State<_OperatorCalculator> {
  double _a = 10;
  double _b = 3;
  String _op = '+';

  static const _ops = ['+', '-', '*', '/', '//', '%', '**'];

  String get _result {
    final a = _a;
    final b = _b;
    if (b == 0 && (_op == '/' || _op == '//' || _op == '%')) return 'ZeroDivisionError！';
    switch (_op) {
      case '+': return _fmt(a + b);
      case '-': return _fmt(a - b);
      case '*': return _fmt(a * b);
      case '/': return _fmt(a / b);
      case '//': return _fmt((a / b).floorToDouble());
      case '%': return _fmt(a % b);
      case '**': return _fmt(a < 100 ? _pow(a, b) : double.infinity);
      default: return '?';
    }
  }

  double _pow(double base, double exp) {
    if (exp == 0) return 1;
    if (exp < 0) return 1 / _pow(base, -exp);
    double result = 1;
    for (int i = 0; i < exp.round(); i++) result *= base;
    return result;
  }

  String _fmt(double v) {
    if (v.isInfinite) return '数字太大了！';
    if (v == v.floorToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String get _opName {
    switch (_op) {
      case '+': return '加法';
      case '-': return '减法';
      case '*': return '乘法';
      case '/': return '真除法（返回 float）';
      case '//': return '整除（floor division）';
      case '%': return '取余（模运算）';
      case '**': return '幂运算';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final aInt = _a.toInt();
    final bInt = _b.toInt();

    return InteractivePlayground(
      title: '🧮 运算符计算器',
      subtitle: '拖动滑块并选择运算符，实时查看计算结果',
      children: [
        ParamIntSlider(label: 'a 的值', value: aInt, min: 1, max: 20, onChanged: (v) => setState(() => _a = v.toDouble())),
        ParamIntSlider(label: 'b 的值', value: bInt, min: 1, max: 10, onChanged: (v) => setState(() => _b = v.toDouble())),
        const Text('选择运算符：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _ops.map((op) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(op, style: const TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                selected: _op == op,
                onSelected: (_) => setState(() => _op = op),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '$aInt $_op $bInt = $_result',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(_opName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
        LiveCodeBlock('a, b = $aInt, $bInt\nprint(a $_op b)  # $_result'),
        LiveOutputBox('>>> $aInt $_op $bInt\n$_result'),
      ],
    );
  }
}

/// f-string 格式化游乐场
class _FStringPlayground extends StatefulWidget {
  const _FStringPlayground();
  @override
  State<_FStringPlayground> createState() => _FStringPlaygroundState();
}

class _FStringPlaygroundState extends State<_FStringPlayground> {
  String _name = '小明';
  double _score = 95.5;
  int _rank = 3;
  int _decimals = 2;
  bool _showPercent = false;
  String _align = '左对齐';
  int _width = 10;

  String get _formattedScore {
    if (_showPercent) {
      return '${(_score / 100 * 100).toStringAsFixed(_decimals)}%';
    }
    return _score.toStringAsFixed(_decimals);
  }

  String get _alignedName {
    final w = _width;
    switch (_align) {
      case '左对齐': return _name.padRight(w);
      case '右对齐': return _name.padLeft(w);
      case '居中':
        final total = w - _name.length;
        final left = total ~/ 2;
        final right = total - left;
        return ' ' * left + _name + ' ' * right;
      default: return _name;
    }
  }

  String get _rankStr => _rank.toString().padLeft(3, '0');

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '✏️ f-string 格式化游乐场',
      subtitle: '调整参数，实时看到 f-string 输出变化',
      children: [
        ParamTextField(label: '名字', value: _name, onChanged: (v) => setState(() => _name = v.isEmpty ? '？' : v), maxLength: 8),
        ParamSlider(label: '分数', value: _score, min: 0, max: 100, divisions: 200, onChanged: (v) => setState(() => _score = v), displayValue: (v) => v.toStringAsFixed(1)),
        ParamIntSlider(label: '排名', value: _rank, min: 1, max: 100, onChanged: (v) => setState(() => _rank = v)),
        ParamIntSlider(label: '小数位数', value: _decimals, min: 0, max: 4, onChanged: (v) => setState(() => _decimals = v)),
        ParamSwitch(label: '显示百分比', value: _showPercent, onChanged: (v) => setState(() => _showPercent = v)),
        ParamChoiceChips(label: '名字对齐', value: _align, options: [('左对齐', '左对齐'), ('右对齐', '右对齐'), ('居中', '居中')], onChanged: (v) => setState(() => _align = v)),
        ParamIntSlider(label: '对齐宽度', value: _width, min: 5, max: 20, onChanged: (v) => setState(() => _width = v)),
        LiveCodeBlock(
          'name, score, rank = "$_name", $_score, $_rank\n'
          '\n'
          '# 基础格式化\n'
          'print(f"{name} 考了 {score:.${_decimals}f} 分，排名第 {rank:03d}")\n'
          '\n'
          '# 对齐（宽度 $_width）\n'
          'print(f"姓名：{name:${_align == '左对齐' ? '<' : _align == '右对齐' ? '>' : '^'}$_width}")',
        ),
        LiveOutputBox(
          '$_name 考了 $_formattedScore 分，排名第 $_rankStr\n'
          '姓名：|$_alignedName|',
        ),
      ],
    );
  }
}

/// 输入输出演示
class _InputOutputDemo extends StatefulWidget {
  const _InputOutputDemo();
  @override
  State<_InputOutputDemo> createState() => _InputOutputDemoState();
}

class _InputOutputDemoState extends State<_InputOutputDemo> {
  String _name = '小红';
  int _age = 18;
  String _sep = '-';
  bool _noNewline = false;

  @override
  Widget build(BuildContext context) {
    final sep = _sep.isEmpty ? ' ' : _sep;
    return InteractivePlayground(
      title: '⌨️ print() 参数演示',
      subtitle: '调整 print() 的 sep 和 end 参数，看输出的变化',
      children: [
        ParamTextField(label: '名字', value: _name, onChanged: (v) => setState(() => _name = v.isEmpty ? '？' : v), maxLength: 8),
        ParamIntSlider(label: '年龄', value: _age, min: 1, max: 100, onChanged: (v) => setState(() => _age = v)),
        ParamTextField(label: 'sep 分隔符', value: _sep, onChanged: (v) => setState(() => _sep = v), hint: '空格/逗号//', maxLength: 3),
        ParamSwitch(label: 'end="" 不换行', value: _noNewline, onChanged: (v) => setState(() => _noNewline = v), trueLabel: '不换行', falseLabel: '换行'),
        LiveCodeBlock(
          'name, age = "$_name", $_age\n\n'
          '# sep 参数：改变多值之间的分隔符\n'
          'print("姓名", "年龄", sep="$sep")\n'
          'print(name, age, sep="$sep")\n'
          '\n'
          '# end 参数：改变结尾字符\n'
          'print("正在加载", end="${_noNewline ? '' : '\\n'}")\n'
          '${_noNewline ? 'print("完成！")  # 接在同一行' : 'print("完成！")  # 在新行'}',
        ),
        LiveOutputBox(
          '姓名${sep}年龄\n$_name${sep}$_age\n'
          '${_noNewline ? '正在加载完成！' : '正在加载\n完成！'}',
        ),
      ],
    );
  }
}

/// 类型转换演示
class _TypeConversionDemo extends StatefulWidget {
  const _TypeConversionDemo();
  @override
  State<_TypeConversionDemo> createState() => _TypeConversionDemoState();
}

class _TypeConversionDemoState extends State<_TypeConversionDemo> {
  double _value = 3.7;
  String _convType = 'int()';

  String get _result {
    switch (_convType) {
      case 'int()': return _value.truncate().toString();
      case 'round()': return _value.round().toString();
      case 'float()': return _value.toString();
      case 'str()': return '"${_value.toStringAsFixed(1)}"';
      case 'bool()': return _value != 0 ? 'True' : 'False';
      case 'abs()': return _value.abs().toStringAsFixed(1);
      default: return '?';
    }
  }

  String get _desc {
    switch (_convType) {
      case 'int()': return '截断小数部分（不四舍五入）';
      case 'round()': return '四舍五入到最近的整数';
      case 'float()': return '转为浮点数';
      case 'str()': return '转为字符串';
      case 'bool()': return '非零为 True，0 为 False';
      case 'abs()': return '取绝对值';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🔄 类型转换演示',
      subtitle: '拖动滑块，选择转换函数，观察结果差异',
      children: [
        ParamSlider(label: '输入值', value: _value, min: -10, max: 10, divisions: 200, onChanged: (v) => setState(() => _value = v), displayValue: (v) => v.toStringAsFixed(1)),
        ParamChoiceChips(
          label: '转换函数',
          value: _convType,
          options: [
            ('int()', 'int()'),
            ('round()', 'round()'),
            ('float()', 'float()'),
            ('str()', 'str()'),
            ('bool()', 'bool()'),
            ('abs()', 'abs()'),
          ],
          onChanged: (v) => setState(() => _convType = v),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text('$_convType(${_value.toStringAsFixed(1)}) = $_result',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(_desc, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ]),
        ),
        if (_convType == 'int()')
          const TipBox('int() 不是四舍五入！它直接截断小数部分。3.9 → 3，-3.9 → -3。要四舍五入用 round()。', type: TipType.caution),
        LiveCodeBlock('x = ${_value.toStringAsFixed(1)}\nprint($_convType(x))  # $_result'),
        LiveOutputBox('$_result\n# $_desc'),
      ],
    );
  }
}
