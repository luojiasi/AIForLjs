import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 基础入门 —— 第一课（扩展版）
/// 涵盖：简介、环境、语法基础、变量、数据类型、运算符、字符串、输入输出、编码规范
class PythonBasics extends StatelessWidget {
  const PythonBasics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第1章 Python 基础入门'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('本章内容', icon: Icons.list),
            Paragraph(
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
            TipBox(
              'Python 是一门"优雅"的语言。它的设计哲学是"用一种方法，最好是只有一种方法来做一件事"。'
              '—— Tim Peters（Python 之禅）',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 1. Python 简介 =====
            SectionHeader('1. Python 简介', icon: Icons.info_outline),
            Paragraph(
              'Python 由 Guido van Rossum 于 1991 年发布，是一种解释型、面向对象、'
              '动态数据类型的高级编程语言。它的语法极其简洁，用缩进来表示代码块，'
              '没有繁琐的花括号和分号。',
            ),
            Paragraph(
              '应用领域：\n'
              '  • 数据科学 & AI：NumPy、Pandas、TensorFlow、PyTorch\n'
              '  • Web 开发：Django、Flask、FastAPI\n'
              '  • 自动化运维：Ansible、Selenium\n'
              '  • 爬虫：Scrapy、BeautifulSoup\n'
              '  • 桌面应用：PyQt、Tkinter\n'
              '  • 游戏开发：Pygame',
            ),
            TipBox(
              'Python 的名字来源于英国喜剧团体 Monty Python 的飞行马戏团，而不是蟒蛇。'
              '但官方 Logo 确实是两条蟒蛇！',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 2. 第一个程序 =====
            SectionHeader('2. 第一个程序', icon: Icons.play_arrow),
            Paragraph(
              '按照编程界的传统，我们让计算机说 "Hello, World!"。'
              'print() 是 Python 内置函数，可以在屏幕上输出文字。',
            ),
            CodeBlock(
              '# 第一个 Python 程序\n'
              'print("Hello, World!")    # 输出英文\n'
              'print("你好，世界！")      # 支持中文\n'
              'print(42)                 # 直接输出数字\n'
              'print(3.14)               # 输出小数',
              language: 'Python',
            ),
            OutputBox('Hello, World!\n你好，世界！\n42\n3.14'),
            Paragraph(
              '你也可以用交互模式（REPL）一行行执行 Python 代码：'
              '在终端输入 python，然后就进入 >>> 提示符，输入代码立即执行。'
              '这是学习和调试 Python 的利器。',
            ),
            CodeBlock(
              '# 终端输入 python 进入交互模式\n'
              '>>> print("Hello")\n'
              'Hello\n'
              '>>> 1 + 2\n'
              '3\n'
              '>>> exit()  # 退出交互模式',
              language: 'Python',
            ),
            DividerLine(),

            // ===== 3. 注释 =====
            SectionHeader('3. 注释与文档字符串', icon: Icons.comment),
            Paragraph(
              '注释是写给程序员看的，计算机会完全忽略。好的注释让代码更容易理解。'
              'Python 有单行注释、多行注释和文档字符串三种形式。',
            ),
            CodeBlock(
              '# ===== 单行注释 =====\n'
              '# 这是单行注释，以 # 开头\n'
              '# print("这行不会执行")  # 注释掉的代码\n'
              'print("这行会执行")      # 行尾也可以加注释\n'
              '\n'
              '# ===== 多行注释（用三个引号） =====\n'
              '\'\'\'\n'
              '这是多行注释\n'
              '三个单引号或双引号都可以\n'
              '常用于文件开头的版权声明\n'
              '\'\'\'\n'
              '\n'
              '# ===== 文档字符串 DocString =====\n'
              'def add(a, b):\n'
              '    """返回两个数的和"""  # 函数说明\n'
              '    return a + b\n'
              '\n'
              'print(add.__doc__)  # 输出: 返回两个数的和',
              language: 'Python',
            ),
            OutputBox('这行会执行\n返回两个数的和'),
            TipBox(
              '文档字符串（DocString）和普通注释不同！DocString 可以被代码访问（通过 .__doc__），'
              '而普通注释完全被忽略。好的习惯：函数和类一定要写 DocString。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 4. PEP 8 编码规范 =====
            SectionHeader('4. PEP 8 —— Python 编码规范', icon: Icons.rule),
            Paragraph(
              'PEP 8 是 Python 的官方编码风格指南。虽然不是语法强制，但遵循 PEP 8 '
              '能让你的代码看起来像"真正的 Python 代码"。核心规则：',
            ),
            CodeBlock(
              '# 1. 缩进：4 个空格，不要用 Tab\n'
              'if True:\n'
              '    print("缩进4个空格")  # ✅ 正确\n'
              '    print(\t"Tab缩进")    # ❌ 不要混用 Tab\n'
              '\n'
              '# 2. 每行不超过 79 个字符\n'
              '# 太长的行可以用反斜杠或括号换行\n'
              'total = (1 + 2 + 3\n'
              '          + 4 + 5)        # 括号内自动续行\n'
              '\n'
              '# 3. 变量和函数命名：snake_case\n'
              'student_name = "小明"     # ✅ 推荐\n'
              'studentName = "小明"      # ⚠️ Python 不用驼峰\n'
              '\n'
              '# 4. 常量命名：全大写\n'
              'MAX_SIZE = 100\n'
              'PI = 3.14159\n'
              '\n'
              '# 5. 运算符两侧各加一个空格\n'
              'x = 1 + 2 * 3           # ✅ 推荐\n'
              'y=1+2*3                 # ❌ 太挤了\n'
              '\n'
              '# 6. 逗号后面加空格\n'
              'fruits = ["苹果", "香蕉", "橘子"]  # ✅',
              language: 'Python',
            ),
            TipBox(
              '遵循 PEP 8 的代码，其他人读起来会感觉很舒服。'
              '可以用 pylint 或 flake8 自动检查代码风格。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 5. 变量和赋值 =====
            SectionHeader('5. 变量与赋值', icon: Icons.label),
            Paragraph(
              '变量就像带标签的盒子。Python 是动态类型语言——变量没有类型，值才有。'
              '你可以随时把变量指向另一个值。',
            ),
            CodeBlock(
              '# ===== 基础赋值 =====\n'
              'name = "小明"              # 字符串\n'
              'age = 18                   # 整数\n'
              'height = 1.75              # 浮点数\n'
              'is_student = True          # 布尔值\n'
              '\n'
              '# Python 动态类型：同一变量可指向不同类型\n'
              'x = 10       # 此时 x 是整数\n'
              'x = "hello"  # 此时 x 变成了字符串\n'
              '\n'
              '# ===== 多重赋值 =====\n'
              'a, b, c = 1, 2, 3\n'
              'print(a, b, c)            # 1 2 3\n'
              '\n'
              '# ===== 交换变量（Python 特色） =====\n'
              'x, y = y, x              # 一行交换，不需要临时变量\n'
              '\n'
              '# ===== 链式赋值 =====\n'
              'a = b = c = 0            # a、b、c 都是 0\n'
              '\n'
              '# ===== 增量赋值 =====\n'
              'n = 10\n'
              'n += 5   # 相当于 n = n + 5\n'
              'n -= 3   # 相当于 n = n - 3\n'
              'n *= 2   # 相当于 n = n * 2\n'
              'n /= 4   # 相当于 n = n / 4\n'
              'print(n)  # 6.0',
              language: 'Python',
            ),
            OutputBox('1 2 3\n6.0'),
            Paragraph(
              '变量名命名规则：\n'
              '• 只能包含字母、数字、下划线\n'
              '• 不能以数字开头\n'
              '• 区分大小写（name != Name）\n'
              '• 不能使用 Python 关键字',
            ),
            CodeBlock(
              '# Python 关键字（不能用作变量名）\n'
              '# False, None, True, and, as, assert, async, await,\n'
              '# break, class, continue, def, del, elif, else, except,\n'
              '# finally, for, from, global, if, import, in, is,\n'
              '# lambda, nonlocal, not, or, pass, raise, return,\n'
              '# try, while, with, yield\n'
              '\n'
              '# 错误示范：\n'
              '# class = "数学"   # ❌ class 是关键字\n'
              '# 2nd_place = "银牌"  # ❌ 数字开头\n'
              '# my-var = 10      # ❌ 不能用连字符\n'
              '\n'
              '# 正确示范：\n'
              'student_class = "数学一班"  # ✅ 用下划线分隔',
              language: 'Python',
            ),
            DividerLine(),

            // ===== 6. 基本数据类型 =====
            SectionHeader('6. 基本数据类型', icon: Icons.category),
            Paragraph(
              'Python 有 7 种基本数据类型。用 type() 可以查看任何数据的类型。'
              '一切皆对象——在 Python 中，即使是数字也是对象。',
            ),
            CodeBlock(
              '# ===== 1. int 整数 =====\n'
              'a = 42           # 十进制\n'
              'b = 0b1010       # 二进制 -> 10\n'
              'c = 0o77         # 八进制 -> 63\n'
              'd = 0xFF         # 十六进制 -> 255\n'
              'print(type(a))   # <class \'int\'>\n'
              '\n'
              '# ===== 2. float 浮点数 =====\n'
              'pi = 3.14159\n'
              'e = 1.5e-4       # 科学计数法 -> 0.00015\n'
              'print(type(pi))  # <class \'float\'>\n'
              '\n'
              '# ===== 3. str 字符串 =====\n'
              's1 = "双引号"\n'
              's2 = \'单引号\'\n'
              's3 = """多行\n'
              '字符串"""          # 三个引号支持换行\n'
              'print(type(s1))  # <class \'str\'>\n'
              '\n'
              '# ===== 4. bool 布尔值 =====\n'
              't = True\n'
              'f = False\n'
              'print(type(t))   # <class \'bool\'>\n'
              '\n'
              '# ===== 5. None 空值 =====\n'
              'nothing = None   # 表示"什么都没有"\n'
              'print(type(nothing))  # <class \'NoneType\'>\n'
              '\n'
              '# ===== 6. bytes 字节串 =====\n'
              'b = b"hello"     # 二进制数据\n'
              'print(type(b))   # <class \'bytes\'>\n'
              '\n'
              '# ===== 7. complex 复数 =====\n'
              'c = 3 + 4j       # 3 是实部，4 是虚部\n'
              'print(c.real)    # 3.0\n'
              'print(c.imag)    # 4.0',
              language: 'Python',
            ),
            TipBox(
              'None 是 Python 中非常重要的概念！它表示"没有值"或"空"。'
              '很多函数的默认返回值就是 None。判断用 is None，不要用 == None。',
              type: TipType.caution,
            ),
            OutputBox(
              "<class 'int'>\n<class 'float'>\n<class 'str'>\n"
              "<class 'bool'>\n<class 'NoneType'>\n"
              "<class 'bytes'>\n3.0\n4.0",
            ),
            DividerLine(),

            // ===== 7. 运算符大全 =====
            SectionHeader('7. 运算符大全', icon: Icons.calculate),
            Paragraph(
              'Python 的运算符分为 7 大类。理解运算符优先级很重要——'
              '记不住就用括号 ()，括号的优先级最高。',
            ),
            CodeBlock(
              '# ===== 1. 算术运算符 =====\n'
              'a, b = 10, 3\n'
              'print(a + b)    # 加 -> 13\n'
              'print(a - b)    # 减 -> 7\n'
              'print(a * b)    # 乘 -> 30\n'
              'print(a / b)    # 除 -> 3.3333\n'
              'print(a // b)   # 整除 -> 3\n'
              'print(a % b)    # 取余 -> 1\n'
              'print(a ** b)   # 幂运算 -> 1000\n'
              '\n'
              '# ===== 2. 比较运算符 =====\n'
              'print(5 == 5)   # 等于\n'
              'print(5 != 3)   # 不等于\n'
              'print(5 > 3)    # 大于\n'
              'print(5 < 3)    # 小于\n'
              'print(5 >= 5)   # 大于等于\n'
              'print(5 <= 3)   # 小于等于\n'
              '\n'
              '# ===== 3. 逻辑运算符 =====\n'
              'x, y = True, False\n'
              'print(x and y)  # False（两者都真才真）\n'
              'print(x or y)   # True（一真即真）\n'
              'print(not x)    # False（取反）\n'
              '\n'
              '# ===== 4. 身份运算符 =====\n'
              'a = [1, 2, 3]\n'
              'b = [1, 2, 3]\n'
              'print(a is b)      # False（不同对象）\n'
              'print(a is not b)  # True\n'
              'print(a == b)      # True（值相等）\n'
              '\n'
              '# ===== 5. 成员运算符 =====\n'
              'fruits = ["苹果", "香蕉"]\n'
              'print("苹果" in fruits)    # True\n'
              'print("西瓜" not in fruits) # True\n'
              '\n'
              '# ===== 6. Python 特色：链式比较 =====\n'
              'age = 25\n'
              'print(18 < age < 60)  # True（连续的比较）\n'
              'print(0 < age < 18)   # False\n'
              '\n'
              '# ===== 7. 运算符优先级（从高到低） =====\n'
              '# **  →  +x -x ~x  →  * / // %  →  + -\n'
              '# << >>  →  &  →  ^  |  →  == != < > in is\n'
              '# not  →  and  →  or\n'
              'result = 2 + 3 * 4 ** 2  # 4**2=16, 3*16=48, 2+48=50\n'
              'print(result)  # 50',
              language: 'Python',
            ),
            TipBox(
              '记住一个原则：拿不准优先级就用括号！\n'
              '(2 + 3) * 4 比 2 + 3 * 4 更清晰，不依赖别人背优先级表。',
              type: TipType.tip,
            ),
            OutputBox(
              '13\n7\n30\n3.3333333333333335\n3\n1\n1000\n'
              'True\nTrue\nTrue\nFalse\nTrue\nFalse\nTrue\n'
              'False\nTrue\nTrue\nTrue\nTrue\nFalse\n50',
            ),
            DividerLine(),

            // ===== 8. 字符串进阶 =====
            SectionHeader('8. 字符串进阶', icon: Icons.text_fields),
            Paragraph(
              '字符串是 Python 中最常用的数据类型。这里深入讲解转义字符、原始字符串和 f-string 的高级用法。',
            ),
            CodeBlock(
              '# ===== 转义字符 =====\n'
              'print("换行符：第一行\\n第二行")    # \\n 换行\n'
              'print("制表符：列1\\t列2")          # \\t 制表\n'
              'print("引号：他说\\"好\\"")         # \\" 转义引号\n'
              'print("反斜杠：C:\\\\\\\\Users")     # \\\\ 输出一个\\\n'
              '\n'
              '# ===== 原始字符串 r"" =====\n'
              'path = r"C:\\Users\\name"      # r 开头，\\ 不转义\n'
              'regex = r"\\d+\\.\\d+"         # 正则表达式用 r 更清晰\n'
              'print(path)   # C:\\Users\\name\n'
              '\n'
              '# ===== f-string 格式化 =====\n'
              'name = "小明"; score = 95.5\n'
              '\n'
              '# 基础用法\n'
              'print(f"{name} 考了 {score} 分")\n'
              '\n'
              '# 数字格式化\n'
              'print(f"保留两位小数：{score:.2f}")   # 95.50\n'
              'print(f"百分比：{0.856:.1%}")          # 85.6%\n'
              'print(f"补零：{42:05d}")               # 00042\n'
              '\n'
              '# 对齐\n'
              'print(f"左对齐：{\"文本\":<10}.")      # < 左对齐\n'
              'print(f"右对齐：{\"文本\":>10}.")      # > 右对齐\n'
              'print(f"居中：{\"文本\":^10}.")        # ^ 居中\n'
              '\n'
              '# 千分位\n'
              'print(f"{1234567:,}")                  # 1,234,567\n'
              '\n'
              '# 字符串拼接\n'
              'words = ["Hello", "World"]\n'
              'print("-".join(words))                # Hello-World',
              language: 'Python',
            ),
            OutputBox(
              '换行符：第一行\n第二行\n'
              '制表符：列1\t列2\n'
              '引号：他说"好"\n'
              '反斜杠：C:\\Users\\name\n'
              'C:\\Users\\name\n'
              '小明 考了 95.5 分\n'
              '保留两位小数：95.50\n'
              '百分比：85.6%\n'
              '补零：00042\n'
              '左对齐：文本        .\n'
              '右对齐：        文本.\n'
              '居中：    文本    .\n'
              '1,234,567\n'
              'Hello-World',
            ),
            DividerLine(),

            // ===== 9. 输入输出 =====
            SectionHeader('9. 输入与输出', icon: Icons.keyboard),
            Paragraph(
              'input() 函数从键盘获取用户输入（总是返回字符串），'
              'print() 函数输出到屏幕。掌握它们就能写出交互式程序。',
            ),
            CodeBlock(
              '# ===== input() 获取输入 =====\n'
              'name = input("请输入你的名字：")    # 阻塞等待输入\n'
              'age = input("请输入年龄：")         # 返回字符串\n'
              '\n'
              '# input 返回字符串，需要数字要转换\n'
              'age_int = int(age)  # 字符串 -> 整数\n'
              '\n'
              '# ===== print() 输出 =====\n'
              '# 1. 多值输出，逗号分隔\n'
              'print("你好", name, "你今年", age, "岁")\n'
              '\n'
              '# 2. f-string 更优雅\n'
              'print(f"你好 {name}，你今年 {age} 岁")\n'
              '\n'
              '# 3. sep 参数：指定分隔符\n'
              'print(1, 2, 3, sep="-")        # 1-2-3\n'
              'print(2025, 1, 15, sep="/")    # 2025/1/15\n'
              '\n'
              '# 4. end 参数：结尾字符（默认 \\n）\n'
              'print("正在加载", end="")\n'
              'print("...完成")                # 不换行，接着打印\n'
              '\n'
              '# 5. 输出到文件\n'
              'with open("output.txt", "w") as f:\n'
              '    print("写入文件的内容", file=f)',
              language: 'Python',
            ),
            OutputBox(
              '请输入你的名字：小明\n'
              '请输入年龄：18\n'
              '你好 小明 你今年 18 岁\n'
              '你好 小明，你今年 18 岁\n'
              '1-2-3\n2025/1/15\n正在加载...完成',
            ),
            DividerLine(),

            // ===== 10. 类型转换与检查 =====
            SectionHeader('10. 类型转换与检查', icon: Icons.swap_horiz),
            Paragraph(
              '类型转换分为隐式转换（自动发生）和显式转换（用函数手动转）。'
              '用 isinstance() 可以安全地检查数据类型。',
            ),
            CodeBlock(
              '# ===== 隐式类型转换 =====\n'
              'result = 5 + 3.14    # int 自动转 float\n'
              'print(result)        # 8.14\n'
              'print(type(result))  # <class \'float\'>\n'
              '\n'
              '# ===== 显式类型转换 =====\n'
              '# 字符串 <-> 数字\n'
              's = "100"\n'
              'n = int(s)           # "100" -> 100\n'
              'print(n + 1)         # 可以运算了：101\n'
              '\n'
              'num = 42\n'
              'text = str(num)      # 42 -> "42"\n'
              'print("数字是" + text)  # 字符串拼接\n'
              '\n'
              '# int/float 互转\n'
              'print(float(5))      # 5 -> 5.0\n'
              'print(int(3.9))      # 3.9 -> 3（向下取整）\n'
              'print(int(-3.9))     # -3.9 -> -3\n'
              'print(round(3.9))    # 4.0（四舍五入）\n'
              '\n'
              '# 转布尔值\n'
              'print(bool(1))       # True（非零为真）\n'
              'print(bool(0))       # False\n'
              'print(bool(""))      # False（空为假）\n'
              'print(bool("abc"))   # True（非空为真）\n'
              'print(bool([]))      # False（空列表为假）\n'
              'print(bool(None))    # False\n'
              '\n'
              '# 安全类型检查\n'
              'def double(x):\n'
              '    if isinstance(x, (int, float)):\n'
              '        return x * 2\n'
              '    return "不支持的类型"',
              language: 'Python',
            ),
            OutputBox(
              '8.14\n'
              "<class 'float'>\n"
              '101\n数字是42\n'
              '5.0\n3\n-3\n4\n'
              'True\nFalse\nFalse\nTrue\nFalse\nFalse',
            ),
            TipBox(
              'int(3.9) 结果是 3，不是 4！int() 直接砍掉小数部分，'
              '不会四舍五入。要四舍五入用 round()。',
              type: TipType.caution,
            ),
            DividerLine(),

            // ===== 11. Python 哲学 =====
            SectionHeader('11. Python 之禅', icon: Icons.auto_awesome),
            Paragraph(
              '在交互模式输入 import this，就能看到 Python 的设计哲学——'
              '"Python 之禅"（The Zen of Python），由 Tim Peters 撰写。'
              '这是理解 Python 设计理念的必读内容。',
            ),
            CodeBlock(
              '>>> import this\n'
              'Beautiful is better than ugly.    # 优美胜于丑陋\n'
              'Explicit is better than implicit.  # 明了胜于晦涩\n'
              'Simple is better than complex.     # 简单胜于复杂\n'
              'Complex is better than complicated. # 复杂胜于凌乱\n'
              'Flat is better than nested.        # 扁平胜于嵌套\n'
              'Sparse is better than dense.       # 间隔胜于紧凑\n'
              'Readability counts.               # 可读性很重要\n'
              '...',
              language: 'Python',
            ),
            Paragraph(
              '这些原则指导着 Python 的设计和社区实践。比如为什么 Python 用缩进而不是花括号？'
              '因为 "Readability counts"。为什么列表推导式这么好用？因为 "Simple is better than complex"。'
            ),
            DividerLine(),

            // ===== 小练习 =====
            SectionHeader('✏️ 小练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: '个人信息卡',
              description: '用变量存储你的姓名、年龄、身高（浮点数），用 f-string 格式化输出 "我叫XX，今年XX岁，身高XX米"。',
            ),
            StepItem(
              step: 2,
              title: '温度转换器',
              description: '输入摄氏温度，转换为华氏温度。公式：F = C * 9 / 5 + 32。用 input() 获取输入，记得转换类型。',
            ),
            StepItem(
              step: 3,
              title: '运算符挑战',
              description: '计算 (2 + 3) * 4 ** 2 / 8 % 3 的结果，再尝试加括号改变运算顺序。',
            ),
            StepItem(
              step: 4,
              title: '类型侦探',
              description: '分别用 type() 检查 10、3.14、"Python"、True、None、b"bytes"、3+4j 的类型并输出。',
            ),
            StepItem(
              step: 5,
              title: 'f-string 格式化',
              description: '定义 price=12.5, count=3，输出 "总价：37.50 元"（保留两位小数）。再用 "," 千分位格式化 1234567。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
