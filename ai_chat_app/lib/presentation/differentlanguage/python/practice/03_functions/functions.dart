import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 函数 —— 第三课（扩展版）
/// 涵盖：定义/调用、参数类型详解、类型注解、作用域、闭包、
/// lambda、装饰器深入、partial、递归
class PythonFunctions extends StatelessWidget {
  const PythonFunctions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第3章 函数'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('本章内容', icon: Icons.list),
            Paragraph(
              '① 函数定义与调用  ② 参数类型（5种）  ③ 类型注解\n'
              '④ 作用域与闭包  ⑤ lambda 表达式  ⑥ 装饰器深入\n'
              '⑦ functools 工具  ⑧ 递归',
            ),
            TipBox(
              '函数是 Python 中最重要的"一等公民"——你可以把函数像普通变量一样传递。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 1. 定义和调用 =====
            SectionHeader('1. 定义与调用', icon: Icons.functions),
            Paragraph(
              '用 def 关键字定义函数。函数名后的冒号 : 和缩进不能少。'
              'return 返回结果，没有 return 的函数返回 None。',
            ),
            CodeBlock(
              '# ===== 基本定义 =====\n'
              'def greet():\n'
              '    """打印问候语（这是文档字符串）"""\n'
              '    print("你好！")\n'
              '\n'
              'greet()  # 调用函数\n'
              '\n'
              '# ===== 带参数和返回值 =====\n'
              'def add(a, b):\n'
              '    """返回 a 和 b 的和"""\n'
              '    return a + b\n'
              '\n'
              'result = add(3, 5)\n'
              'print(result)  # 8\n'
              '\n'
              '# ===== return 之后不执行 =====\n'
              'def check(num):\n'
              '    if num < 0:\n'
              '        return "负数"\n'
              '    return "非负数"\n'
              '    print("这行不会执行")  # 不可达\n'
              '\n'
              '# ===== 返回多个值（实际是元组） =====\n'
              'def min_max(nums):\n'
              '    return min(nums), max(nums)\n'
              '\n'
              'low, high = min_max([3, 1, 4, 1, 5])\n'
              'print(low, high)  # 1 5\n'
              '\n'
              '# ===== 没有 return =====\n'
              'def nothing():\n'
              '    pass\n'
              '\n'
              'print(nothing())  # None',
              language: 'Python',
            ),
            OutputBox('你好！\n8\n1 5\nNone'),
            DividerLine(),

            // ===== 2. 参数类型 =====
            SectionHeader('2. 五种参数类型', icon: Icons.tune),
            Paragraph(
              'Python 函数的参数极其灵活。理解这 5 种参数类型及其顺序是掌握函数的关键。'
            ),
            CodeBlock(
              '# ===== 参数顺序（必须遵守！） =====\n'
              '# 位置参数 > 默认参数 > *args > 关键字参数 > **kwargs\n'
              '\n'
              '# 1. 位置参数 —— 按位置传入\n'
              'def info(name, age, city):\n'
              '    print(f"{name} {age}岁 来自{city}")\n'
              'info("小明", 18, "北京")  # 对应位置\n'
              '\n'
              '# 2. 默认参数 —— 不给就用默认值\n'
              'def info2(name, age, city="未知"):\n'
              '    print(f"{name} {age}岁 来自{city}")\n'
              'info2("小红", 20)           # 使用默认 city\n'
              'info2("小刚", 22, "上海")    # 覆盖默认值\n'
              '\n'
              '# ⚠️ 默认参数的陷阱：不要用可变对象！\n'
              'def bad_append(item, lst=[]):  # ❌ 默认列表只创建一次\n'
              '    lst.append(item)\n'
              '    return lst\n'
              'print(bad_append(1))  # [1]\n'
              'print(bad_append(2))  # [1, 2]  ← 保留了上次结果！\n'
              '\n'
              'def good_append(item, lst=None):  # ✅ 用 None 代替\n'
              '    if lst is None:\n'
              '        lst = []\n'
              '    lst.append(item)\n'
              '    return lst\n'
              '\n'
              '# 3. 关键字参数 —— 指定参数名\n'
              'info(city="广州", name="小美", age=25)  # 顺序可以变\n'
              '\n'
              '# 4. *args —— 任意多个位置参数\n'
              'def sum_all(*args):\n'
              '    """接收任意多个参数，打包成元组"""\n'
              '    return sum(args)\n'
              'print(sum_all(1, 2, 3, 4, 5))  # 15\n'
              '\n'
              '# 5. **kwargs —— 任意多个关键字参数\n'
              'def show_info(**kwargs):\n'
              '    """接收任意多个键值对，打包成字典"""\n'
              '    for key, value in kwargs.items():\n'
              '        print(f"{key}: {value}")\n'
              'show_info(name="小明", age=18, city="北京")',
              language: 'Python',
            ),
            TipBox(
              '默认参数的陷阱很经典！函数定义时就创建了默认值对象，'
              '如果默认值是列表或字典，多次调用会共享同一个对象。'
              '解决办法：用 None 做默认值，函数内部再创建。',
              type: TipType.caution,
            ),
            OutputBox(
              '小明 18岁 来自北京\n小红 20岁 来自未知\n'
              '小刚 22岁 来自上海\n[1]\n[1, 2]\n'
              '广州 25岁 来自小美\n15\n'
              'name: 小明\nage: 18\ncity: 北京',
            ),
            DividerLine(),

            // ===== 3. 类型注解 =====
            SectionHeader('3. 类型注解（Type Hints）', icon: Icons.label_outline),
            Paragraph(
              'Python 3.5+ 支持类型注解。它不会影响运行，但能让代码更清晰，'
              '配合 IDE 实现智能提示和静态检查（mypy）。',
            ),
            CodeBlock(
              '# ===== 函数参数和返回值注解 =====\n'
              'def greet(name: str, age: int) -> str:\n'
              '    """name: 名字, age: 年龄, 返回格式化字符串"""\n'
              '    return f"{name}今年{age}岁"\n'
              '\n'
              'print(greet("小明", 18))  # 正常运行\n'
              '# greet(123, "abc")  # mypy 会警告类型不匹配\n'
              '\n'
              '# ===== 变量注解 =====\n'
              'name: str = "Python"\n'
              'count: int = 42\n'
              'pi: float = 3.14159\n'
              'is_ok: bool = True\n'
              '\n'
              '# ===== 容器类型注解 =====\n'
              'from typing import List, Dict, Tuple, Optional\n'
              '\n'
              'numbers: List[int] = [1, 2, 3]\n'
              'scores: Dict[str, int] = {"小明": 95}\n'
              'point: Tuple[int, int] = (3, 4)\n'
              '\n'
              '# Optional：可能为 None\n'
              'def find_user(id: int) -> Optional[str]:\n'
              '    if id == 1:\n'
              '        return "管理员"\n'
              '    return None  # 找不到返回 None\n'
              '\n'
              '# ===== 联合类型（Python 3.10+） =====\n'
              '# 更简洁的写法\n'
              'def double(x: int | float | str) -> str:\n'
              '    return str(x) + " 的两倍是 " + str(x * 2)',
              language: 'Python',
            ),
            TipBox(
              '类型注解的三大好处：IDE 自动补全、静态检查提前发现 bug、'
              '代码即文档。大型项目强烈建议使用 mypy + 类型注解。',
              type: TipType.tip,
            ),
            OutputBox('小明今年18岁'),
            DividerLine(),

            // ===== 4. 作用域与闭包 =====
            SectionHeader('4. 作用域与闭包', icon: Icons.visibility),
            Paragraph(
              'Python 的变量作用域遵循 LEGB 规则：Local → Enclosing → Global → Built-in。'
              '闭包（Closure）是"记住外部变量的函数"。',
            ),
            CodeBlock(
              '# ===== LEGB 作用域规则 =====\n'
              'x = "全局变量"  # Global\n'
              '\n'
              'def outer():\n'
              '    x = "外部变量"  # Enclosing\n'
              '\n'
              '    def inner():\n'
              '        x = "内部变量"  # Local\n'
              '        print(x)\n'
              '\n'
              '    inner()\n'
              '    print(x)\n'
              '\n'
              'outer()\n'
              'print(x)\n'
              '# 输出：内部变量 / 外部变量 / 全局变量\n'
              '\n'
              '# ===== global 关键字 =====\n'
              'count = 0\n'
              '\n'
              'def increment():\n'
              '    global count  # 声明要修改全局变量\n'
              '    count += 1\n'
              '\n'
              'increment()\n'
              'print(count)  # 1\n'
              '\n'
              '# ===== nonlocal 关键字 =====\n'
              'def counter():\n'
              '    count = 0\n'
              '\n'
              '    def increment():\n'
              '        nonlocal count  # 修改外层变量\n'
              '        count += 1\n'
              '        return count\n'
              '\n'
              '    return increment\n'
              '\n'
              '# ===== 闭包 =====\n'
              'my_counter = counter()\n'
              'print(my_counter())  # 1\n'
              'print(my_counter())  # 2\n'
              'print(my_counter())  # 3\n'
              '# 闭包记住了 count 的值！',
              language: 'Python',
            ),
            OutputBox('内部变量\n外部变量\n全局变量\n1\n1\n2\n3'),
            DividerLine(),

            // ===== 5. lambda =====
            SectionHeader('5. lambda 表达式', icon: Icons.bolt),
            Paragraph(
              'lambda 创建"匿名函数"——只有一行、没有名字的函数。'
              '适合作为参数传递给高阶函数（map/filter/sorted）。',
            ),
            CodeBlock(
              '# ===== lambda 语法：lambda 参数: 表达式 =====\n'
              '\n'
              '# 基本 lambda\n'
              'square = lambda x: x * x\n'
              'print(square(5))  # 25\n'
              '\n'
              '# 多参数 lambda\n'
              'add = lambda a, b: a + b\n'
              'print(add(3, 7))  # 10\n'
              '\n'
              '# lambda 配合 sorted\n'
              'students = [("小明", 85), ("小红", 92), ("小刚", 78)]\n'
              '# 按成绩升序\n'
              'students.sort(key=lambda s: s[1])\n'
              'print(students)\n'
              "# [('小刚', 78), ('小明', 85), ('小红', 92)]\n"
              '\n'
              '# lambda 配合 map\n'
              'numbers = [1, 2, 3, 4, 5]\n'
              'doubled = list(map(lambda x: x * 2, numbers))\n'
              'print(doubled)  # [2, 4, 6, 8, 10]\n'
              '\n'
              '# lambda 配合 filter\n'
              'evens = list(filter(lambda x: x % 2 == 0, numbers))\n'
              'print(evens)  # [2, 4]\n'
              '\n'
              '# ⚠️ lambda 的限制：\n'
              '# 1. 只能写一个表达式，不能写语句\n'
              '# 2. 不能写赋值 = （但可以用 := 海象运算符）\n'
              '# 3. 不能写多行\n'
              '# 4. 不要写太复杂的逻辑！复杂逻辑用 def',
              language: 'Python',
            ),
            TipBox(
              'lambda 适合一行搞定的简单逻辑。如果超过一行，'
              '就用 def 定义普通函数——可读性比"短"更重要。',
              type: TipType.tip,
            ),
            OutputBox(
              '25\n10\n'
              "[('小刚', 78), ('小明', 85), ('小红', 92)]\n"
              '[2, 4, 6, 8, 10]\n[2, 4]',
            ),
            DividerLine(),

            // ===== 6. 装饰器深入 =====
            SectionHeader('6. 装饰器', icon: Icons.card_giftcard),
            Paragraph(
              '装饰器是"给函数增加额外功能"的语法糖。'
              '核心思想：函数可以作为参数传给另一个函数，并返回增强版。',
            ),
            CodeBlock(
              '# ===== 基础装饰器 =====\n'
              'def log_decorator(func):\n'
              '    """打印函数调用日志"""\n'
              '    def wrapper(*args, **kwargs):\n'
              '        print(f"[LOG] 调用 {func.__name__}()")\n'
              '        result = func(*args, **kwargs)\n'
              '        print(f"[LOG] {func.__name__}() 返回 {result}")\n'
              '        return result\n'
              '    return wrapper\n'
              '\n'
              '@log_decorator\n'
              'def add(a, b):\n'
              '    return a + b\n'
              '\n'
              'add(3, 5)\n'
              '# 输出：\n'
              '# [LOG] 调用 add()\n'
              '# [LOG] add() 返回 8\n'
              '\n'
              '# ===== 带参数的装饰器 =====\n'
              'def repeat(n):\n'
              '    """重复执行 n 次的装饰器"""\n'
              '    def decorator(func):\n'
              '        def wrapper(*args, **kwargs):\n'
              '            for _ in range(n):\n'
              '                result = func(*args, **kwargs)\n'
              '            return result\n'
              '        return wrapper\n'
              '    return decorator\n'
              '\n'
              '@repeat(3)\n'
              'def say_hello():\n'
              '    print("你好！")\n'
              '\n'
              'say_hello()  # 打印 3 次 "你好！"\n'
              '\n'
              '# ===== @wraps 保护元数据 =====\n'
              'from functools import wraps\n'
              '\n'
              'def log_decorator(func):\n'
              '    @wraps(func)  # 保留原函数的 __name__ 等属性\n'
              '    def wrapper(*args, **kwargs):\n'
              '        print(f"调用 {func.__name__}")\n'
              '        return func(*args, **kwargs)\n'
              '    return wrapper',
              language: 'Python',
            ),
            OutputBox(
              '[LOG] 调用 add()\n[LOG] add() 返回 8\n'
              '你好！\n你好！\n你好！',
            ),
            DividerLine(),

            // ===== 7. functools 工具 =====
            SectionHeader('7. functools —— 函数式工具', icon: Icons.build),
            Paragraph(
              'functools 模块提供高阶函数工具，最常用的有 partial（偏函数）和 lru_cache（缓存）。',
            ),
            CodeBlock(
              'from functools import partial\n'
              '\n'
              '# partial：固定某些参数，创建新函数\n'
              'def power(base, exp):\n'
              '    return base ** exp\n'
              '\n'
              'square = partial(power, exp=2)  # 固定指数为2\n'
              'cube = partial(power, exp=3)    # 固定指数为3\n'
              '\n'
              'print(square(5))  # 25\n'
              'print(cube(5))    # 125\n'
              '\n'
              '# 实际应用：简化 sorted 排序\n'
              'data = [("a", 3), ("b", 1), ("c", 2)]\n'
              'get_second = partial(lambda i, x: x[i], 1)\n'
              '# 等价于：sorted(data, key=lambda x: x[1])\n'
              'print(sorted(data, key=get_second))\n'
              '\n'
              '# ===== lru_cache：自动缓存计算结果 =====\n'
              'from functools import lru_cache\n'
              '\n'
              '@lru_cache(maxsize=128)\n'
              'def fibonacci(n):\n'
              '    """带缓存的斐波那契数列"""\n'
              '    if n < 2:\n'
              '        return n\n'
              '    return fibonacci(n-1) + fibonacci(n-2)\n'
              '\n'
              'print(fibonacci(100))  # 即使 n=100 也很快！',
              language: 'Python',
            ),
            OutputBox(
              '25\n125\n[(\'b\', 1), (\'c\', 2), (\'a\', 3)]\n'
              '354224848179261915075',
            ),
            DividerLine(),

            // ===== 8. 递归 =====
            SectionHeader('8. 递归', icon: Icons.repeat),
            Paragraph(
              '递归就是函数调用自己。必须有两个要素：终止条件和递归调用。'
              'Python 默认递归深度约 1000，超出会 RecursionError。',
            ),
            CodeBlock(
              '# ===== 阶乘 =====\n'
              'def factorial(n):\n'
              '    """n! = n * (n-1) * (n-2) * ... * 1"""\n'
              '    if n <= 1:          # 终止条件\n'
              '        return 1\n'
              '    return n * factorial(n - 1)  # 递归调用\n'
              '\n'
              'print(factorial(5))  # 120\n'
              '# 执行过程：\n'
              '# factorial(5)\n'
              '# = 5 * factorial(4)\n'
              '# = 5 * 4 * factorial(3)\n'
              '# = 5 * 4 * 3 * factorial(2)\n'
              '# = 5 * 4 * 3 * 2 * factorial(1)\n'
              '# = 5 * 4 * 3 * 2 * 1 = 120\n'
              '\n'
              '# ===== 斐波那契（无缓存 vs 有缓存） =====\n'
              'def fib_slow(n):\n'
              '    """慢速版：指数级复杂度"""\n'
              '    if n < 2:\n'
              '        return n\n'
              '    return fib_slow(n-1) + fib_slow(n-2)\n'
              '# fib_slow(40) 就要等很久！\n'
              '\n'
              'from functools import lru_cache\n'
              '\n'
              '@lru_cache(maxsize=None)\n'
              'def fib_fast(n):\n'
              '    """快速版：线性复杂度"""\n'
              '    if n < 2:\n'
              '        return n\n'
              '    return fib_fast(n-1) + fib_fast(n-2)\n'
              '\n'
              'print(fib_fast(100))  # 瞬间出结果\n'
              '\n'
              '# ===== 递归深度限制 =====\n'
              'import sys\n'
              'print(sys.getrecursionlimit())  # 默认约 1000\n'
              '# sys.setrecursionlimit(2000)  # 可以调大（不推荐）',
              language: 'Python',
            ),
            TipBox(
              '递归优雅但低效。能用循环解决的问题尽量用循环。'
              '递归深度超过 1000 层会报 RecursionError。'
              '需要深递归时用 sys.setrecursionlimit()。',
              type: TipType.warning,
            ),
            OutputBox(
              '120\n354224848179261915075\n1000',
            ),
            DividerLine(),

            // ===== 小练习 =====
            SectionHeader('✏️ 小练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: '计算器函数',
              description: '写 calculator(a, b, op)，支持 "add"/"sub"/"mul"/"div"，用类型注解标明参数和返回类型。',
            ),
            StepItem(
              step: 2,
              title: '带缓存的斐波那契',
              description: '用 lru_cache 装饰器实现高效的斐波那契数列生成器。',
            ),
            StepItem(
              step: 3,
              title: '计时装饰器',
              description: '写一个 @timer 装饰器，打印函数的执行时间（用 time.time()）。',
            ),
            StepItem(
              step: 4,
              title: '偏函数实践',
              description: '用 partial 从 int() 创建 binary_to_int，固定 base=2。',
            ),
            StepItem(
              step: 5,
              title: '闭包计数器',
              description: '写一个 create_counter() 函数，返回的闭包每次调用返回递增的数字。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
