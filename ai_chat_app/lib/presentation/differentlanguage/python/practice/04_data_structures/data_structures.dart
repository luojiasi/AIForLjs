import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 数据结构 —— 第四课（扩展版）
/// 覆盖列表、元组、字典、集合、推导式、collections 模块、排序与切片
class PythonDataStructures extends StatelessWidget {
  const PythonDataStructures({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第4章 数据结构')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Paragraph(
              '数据结构是组织和管理数据的核心工具。Python 提供了丰富而强大的内置数据结构，'
              '本章将深入讲解它们的各种进阶用法以及相关实用工具。',
            ),
            const SizedBox(height: 8),

            // ===== 本章导览 =====
            SectionHeader('本章内容', icon: Icons.list),
            Paragraph(
              '① 列表详解    ② 元组与命名元组\n'
              '③ 字典进阶    ④ 集合详解\n'
              '⑤ 列表推导式深入  ⑥ 生成器表达式\n'
              '⑦ 常用 collections 工具  ⑧ 排序与切片',
            ),
            DividerLine(),

            // ================================================================
            // ① 列表详解
            // ================================================================
            SectionHeader('① 列表详解', icon: Icons.list),
            Paragraph(
              '列表（list）是 Python 中最灵活、最常用的数据结构。它是一个有序、可变的容器，'
              '可以存放任意类型的元素。掌握列表的各种用法，是学好 Python 的关键一步。',
            ),

            // 1.1 创建方式
            Paragraph('【创建方式】'),
            CodeBlock(
              '# 多种创建列表的方式\n'
              'empty1 = []                     # 最常用的空列表\n'
              'empty2 = list()                 # 使用 list() 构造函数\n'
              'numbers = [1, 2, 3, 4, 5]       # 字面量创建\n'
              'mixed = [1, "hello", 3.14, True]  # 可存放不同类型\n'
              'nested = [[1, 2], [3, 4], [5]]  # 嵌套列表（矩阵/二维）\n'
              '\n'
              '# 从其他可迭代对象转换\n'
              'from_range = list(range(5))     # range → [0, 1, 2, 3, 4]\n'
              'from_string = list("Python")    # 字符串 → [P, y, t, h, o, n]\n'
              'print(from_range)\n'
              'print(from_string)',
              language: 'Python',
            ),
            OutputBox(
              '[0, 1, 2, 3, 4]\n'
              "['P', 'y', 't', 'h', 'o', 'n']",
            ),

            // 1.2 索引与切片
            Paragraph('【索引与切片】'),
            CodeBlock(
              'fruits = ["苹果", "香蕉", "橘子", "葡萄", "西瓜"]\n'
              '\n'
              '# 正索引（从 0 开始）\n'
              'print(fruits[0])     # 苹果\n'
              'print(fruits[2])     # 橘子\n'
              '\n'
              '# 负索引（从 -1 开始倒数）\n'
              'print(fruits[-1])    # 西瓜（最后一个）\n'
              'print(fruits[-2])    # 葡萄（倒数第二个）\n'
              '\n'
              '# 切片 [start:stop:step] — 含头不含尾\n'
              'print(fruits[1:4])   # [香蕉, 橘子, 葡萄]\n'
              'print(fruits[:3])    # [苹果, 香蕉, 橘子] — 从头开始\n'
              'print(fruits[2:])    # [橘子, 葡萄, 西瓜] — 到末尾\n'
              'print(fruits[::2])   # [苹果, 橘子, 西瓜] — 步长为2\n'
              'print(fruits[::-1])  # [西瓜, 葡萄, 橘子, 香蕉, 苹果] — 反转！',
              language: 'Python',
            ),
            OutputBox(
              '苹果\n'
              '橘子\n'
              '西瓜\n'
              '葡萄\n'
              "[香蕉, 橘子, 葡萄]\n"
              "[苹果, 香蕉, 橘子]\n"
              "[橘子, 葡萄, 西瓜]\n"
              "[苹果, 橘子, 西瓜]\n"
              "[西瓜, 葡萄, 橘子, 香蕉, 苹果]",
            ),
            TipBox(
              '切片语法 [start:stop:step] 是 Python 的独特优势，三个参数都可省略：'
              '[:] 复制整个列表，[::-1] 反转列表。记住"含头不含尾"原则。',
              type: TipType.tip,
            ),

            // 1.3 常用方法
            Paragraph('【常用方法一览】'),
            CodeBlock(
              '# ===== 增加元素 =====\n'
              'nums = [1, 2, 3]\n'
              'nums.append(4)           # 末尾追加一个元素\n'
              'print(nums)              # [1, 2, 3, 4]\n'
              '\n'
              'nums.extend([5, 6])      # 扩展多个元素\n'
              'print(nums)              # [1, 2, 3, 4, 5, 6]\n'
              '\n'
              'nums.insert(0, 100)      # 在索引 0 处插入\n'
              'print(nums[0])           # 100\n'
              '\n'
              '# ===== 删除元素 =====\n'
              'nums.remove(100)         # 删除第一个匹配的元素\n'
              'last = nums.pop()        # 删除并返回最后一个\n'
              'print(last)              # 6\n'
              '\n'
              'first = nums.pop(0)      # 删除并返回指定位置\n'
              'print(first)             # 1\n'
              '\n'
              '# ===== 查找与统计 =====\n'
              'nums2 = [3, 1, 4, 1, 5]\n'
              'print(nums2.index(4))    # 2 — 元素 4 的索引\n'
              'print(nums2.count(1))    # 2 — 元素 1 出现 2 次\n'
              '\n'
              '# ===== 排序与反转 =====\n'
              'nums2.sort()             # 就地升序\n'
              'print(nums2)             # [1, 1, 3, 4, 5]\n'
              'nums2.reverse()          # 就地反转\n'
              'print(nums2)             # [5, 4, 3, 1, 1]\n'
              '\n'
              '# ===== 复制与清空 =====\n'
              'copy_nums = nums2.copy() # 浅拷贝\n'
              'nums2.clear()\n'
              'print(nums2)             # []',
              language: 'Python',
            ),
            OutputBox(
              '[1, 2, 3, 4]\n'
              '[1, 2, 3, 4, 5, 6]\n'
              '100\n'
              '6\n'
              '1\n'
              '2\n'
              '2\n'
              '[1, 1, 3, 4, 5]\n'
              '[5, 4, 3, 1, 1]\n'
              '[]',
            ),
            TipBox(
              'append / pop 组合实现栈（后进先出），效率为 O(1)。'
              '但不要用 pop(0) 或 insert(0, x) 模拟队列——那是 O(n) 操作，'
              '大数据量时请用 collections.deque。',
              type: TipType.caution,
            ),

            // 1.4 栈和队列
            Paragraph('【列表作为栈和队列】'),
            CodeBlock(
              '# ===== 栈（Stack）后进先出 =====\n'
              'stack = []\n'
              'stack.append("第1页")\n'
              'stack.append("第2页")\n'
              'stack.append("第3页")\n'
              'print(stack.pop())   # 第3页 — 后进先出\n'
              'print(stack)         # [第1页, 第2页]\n'
              '\n'
              '# ===== 队列（Queue）先进先出 → 用 deque =====\n'
              'from collections import deque\n'
              'queue = deque(["小明", "小红"])\n'
              'queue.append("小刚")       # 从右入队\n'
              'queue.append("小丽")\n'
              'print(queue.popleft())     # 小明 — 从左出队\n'
              'print(queue)               # deque([小红, 小刚, 小丽])',
              language: 'Python',
            ),
            OutputBox(
              '第3页\n'
              "[第1页, 第2页]\n"
              '小明\n'
              "deque(['小红', '小刚', '小丽'])",
            ),

            // 1.5 深浅拷贝
            Paragraph('【深浅拷贝】'),
            CodeBlock(
              'import copy\n'
              '\n'
              'original = [1, 2, [3, 4]]\n'
              '\n'
              '# 直接赋值 — 只是别名\n'
              'ref = original\n'
              'ref[0] = 99\n'
              'print(original[0])   # 99（改了！指向同一对象）\n'
              '\n'
              '# 浅拷贝 — 第一层独立，内层仍共享引用\n'
              'shallow = copy.copy(original)\n'
              'shallow[2][0] = 999\n'
              'print(original[2][0])  # 999（内层被改了！）\n'
              '\n'
              '# 深拷贝 — 完全独立\n'
              'deep = copy.deepcopy(original)\n'
              'deep[2][0] = 777\n'
              'print(original[2][0])  # 999（没受影响）\n'
              'print(deep[2][0])      # 777',
              language: 'Python',
            ),
            OutputBox(
              '99\n999\n999\n777',
            ),
            TipBox(
              '浅拷贝只复制一层，内部对象仍共享引用；深拷贝递归复制全部内容，'
              '生成完全独立的对象。对于嵌套的可变容器，务必用 deepcopy 才能彻底隔离。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ================================================================
            // ② 元组与命名元组
            // ================================================================
            SectionHeader('② 元组与命名元组', icon: Icons.lock_outline),
            Paragraph(
              '元组（tuple）是不可变的序列——一旦创建就不能修改。这种"只读"特性让元组'
              '更安全、更高效，适合存储固定不变的数据，也常作为字典的键使用。',
            ),

            // 2.1 创建与特性
            CodeBlock(
              '# ===== 创建元组 =====\n'
              'empty = ()                    # 空元组\n'
              'point = (3, 5)                # 二维坐标\n'
              'rgb = (255, 0, 0)             # 红色 RGB\n'
              'mixed = (1, "hello", 3.14)    # 混合类型\n'
              'nested = (1, (2, 3), 4)       # 嵌套\n'
              'no_parens = 1, 2, 3           # 省略括号也可以（逗号是关键）\n'
              '\n'
              '# ===== 单元素元组的陷阱 =====\n'
              'not_tuple = (1)               # 整数 1！不是元组！\n'
              'print(type(not_tuple))        # <class \'int\'>\n'
              'real_tuple = (1,)             # 加逗号才是元组\n'
              'print(type(real_tuple))       # <class \'tuple\'>\n'
              '\n'
              '# ===== 不可变性 =====\n'
              't = (1, 2, 3)\n'
              '# t[0] = 100  # TypeError! 元组不可修改\n'
              '\n'
              '# 但如果元组里包含可变对象…\n'
              't2 = ([1, 2], 3)\n'
              't2[0].append(999)             # 列表本身可以修改\n'
              'print(t2)                     # ([1, 2, 999], 3)',
              language: 'Python',
            ),
            OutputBox(
              "<class 'int'>\n"
              "<class 'tuple'>\n"
              "([1, 2, 999], 3)",
            ),
            TipBox(
              '单元素元组必须加逗号 (1,)，这是 Python 新手最常犯的错误之一。'
              '记住：决定元组的是逗号，不是括号。',
              type: TipType.warning,
            ),

            // 2.2 元组解包
            Paragraph('【元组解包】'),
            CodeBlock(
              '# ===== 基本解包 =====\n'
              'point = (10, 20)\n'
              'x, y = point\n'
              'print(f"x={x}, y={y}")   # x=10, y=20\n'
              '\n'
              '# ===== 交换变量的秘密 =====\n'
              'a, b = 1, 2\n'
              'a, b = b, a              # 本质就是元组打包再解包\n'
              'print(f"a={a}, b={b}")   # a=2, b=1\n'
              '\n'
              '# ===== 星号解包（Python 3）=====\n'
              'first, *middle, last = [1, 2, 3, 4, 5]\n'
              'print(first)    # 1\n'
              'print(middle)   # [2, 3, 4]\n'
              'print(last)     # 5\n'
              '\n'
              '# ===== 函数返回多个值 =====\n'
              'def min_max(lst):\n'
              '    return min(lst), max(lst)\n'
              '\n'
              'low, high = min_max([3, 1, 4, 1, 5])\n'
              'print(f"low={low}, high={high}")  # low=1, high=5',
              language: 'Python',
            ),
            OutputBox(
              'x=10, y=20\n'
              'a=2, b=1\n'
              '1\n'
              '[2, 3, 4]\n'
              '5\n'
              'low=1, high=5',
            ),

            // 2.3 namedtuple
            Paragraph('【namedtuple —— 带名字的元组】'),
            CodeBlock(
              'from collections import namedtuple\n'
              '\n'
              '# 定义一种轻量级"数据记录类型"\n'
              'Point = namedtuple("Point", ["x", "y"])\n'
              'Student = namedtuple("Student", ["name", "age", "grade"])\n'
              '\n'
              '# 创建记录\n'
              'p = Point(10, 20)\n'
              's = Student("小明", 18, "高三")\n'
              '\n'
              '# 通过属性名访问（比下标清晰多了！）\n'
              'print(p.x, p.y)              # 10 20\n'
              'print(s.name, s.grade)       # 小明 高三\n'
              '\n'
              '# 仍然支持元组的全部特性\n'
              'print(p[0], p[1])            # 10 20（下标访问）\n'
              'x, y = p                     # 解包\n'
              '\n'
              '# _replace() 创建新实例（因为元组不可变）\n'
              's2 = s._replace(grade="大一")\n'
              'print(s2)',
              language: 'Python',
            ),
            OutputBox(
              '10 20\n'
              '小明 高三\n'
              '10 20\n'
              "Student(name='小明', age=18, grade='大一')",
            ),
            TipBox(
              'namedtuple 完美结合了元组的轻量和类的可读性。当你需要一个简单的'
              '"数据容器"又不想写完整类定义时，它就是最佳选择。',
              type: TipType.info,
            ),
            DividerLine(),

            // ================================================================
            // ③ 字典进阶
            // ================================================================
            SectionHeader('③ 字典进阶', icon: Icons.menu_book),
            Paragraph(
              '字典（dict）以键值对（key-value）方式存储数据，是 Python 最强大的'
              '内置数据结构之一。Python 3.7+ 的字典会保持插入顺序，这使字典更加实用。',
            ),

            // 3.1 多种创建方式
            Paragraph('【多种创建方式】'),
            CodeBlock(
              '# 字面量\n'
              'd1 = {"name": "小明", "age": 18}\n'
              '\n'
              '# dict() 构造函数\n'
              'd2 = dict(name="小红", age=17)\n'
              '\n'
              '# 从键值对序列构建\n'
              'd3 = dict([("a", 1), ("b", 2)])\n'
              '\n'
              '# fromkeys — 批量创建键，统一默认值\n'
              'keys = ["name", "age", "gender"]\n'
              'd4 = dict.fromkeys(keys)          # 值默认 None\n'
              'print(d4)\n'
              'd5 = dict.fromkeys(keys, "未知")   # 指定默认值\n'
              'print(d5)',
              language: 'Python',
            ),
            OutputBox(
              "{'name': None, 'age': None, 'gender': None}\n"
              "{'name': '未知', 'age': '未知', 'gender': '未知'}",
            ),

            // 3.2 常用操作
            Paragraph('【常用操作】'),
            CodeBlock(
              'student = {"name": "小明", "age": 18, "score": 95}\n'
              '\n'
              '# get(key, default) — 安全取值，不存在返回默认值\n'
              'print(student.get("name"))            # 小明\n'
              'print(student.get("gender"))           # None（不报错）\n'
              'print(student.get("gender", "未知"))   # 未知\n'
              '\n'
              '# setdefault(key, default) — 取不到就设默认值\n'
              'city = student.setdefault("city", "北京")\n'
              'print(city)   # 北京\n'
              'print(student["city"])   # 北京\n'
              '\n'
              '# update() — 更新 / 合并字典\n'
              'student.update({"score": 98, "gender": "男"})\n'
              'print(student["score"])   # 98\n'
              '\n'
              '# pop(key) — 删除并返回值\n'
              'score = student.pop("score")\n'
              'print(score)              # 98\n'
              '\n'
              '# popitem() — 删除并返回最后插入的键值对\n'
              'item = student.popitem()\n'
              'print(item)               # (gender, 男) 可能\n'
              '\n'
              '# del — 删除指定键\n'
              'del student["city"]',
              language: 'Python',
            ),
            OutputBox(
              '小明\n'
              'None\n'
              '未知\n'
              '北京\n'
              '北京\n'
              '98\n'
              '98\n'
              "('gender', '男')",
            ),

            // 3.3 遍历
            Paragraph('【字典遍历】'),
            CodeBlock(
              'scores = {"语文": 90, "数学": 95, "英语": 88}\n'
              '\n'
              '# 遍历键\n'
              'for k in scores:\n'
              '    print(k, end=" ")\n'
              'print()  # 语文 数学 英语\n'
              '\n'
              '# 遍历值\n'
              'for v in scores.values():\n'
              '    print(v, end=" ")\n'
              'print()  # 90 95 88\n'
              '\n'
              '# 遍历键值对（最推荐）\n'
              'for k, v in scores.items():\n'
              '    print(f"{k}: {v}分")\n'
              '\n'
              '# 字典解包展开\n'
              'd = {"x": 1, "y": 2}\n'
              'print({**d, "z": 3})  # {x: 1, y: 2, z: 3}',
              language: 'Python',
            ),
            OutputBox(
              '语文 数学 英语\n'
              '90 95 88\n'
              '语文: 90分\n'
              '数学: 95分\n'
              '英语: 88分\n'
              "{'x': 1, 'y': 2, 'z': 3}",
            ),

            // 3.4 defaultdict 和 OrderedDict
            Paragraph('【defaultdict 自动处理缺失键】'),
            CodeBlock(
              'from collections import defaultdict\n'
              '\n'
              '# 统计字符出现次数 — 经典场景\n'
              'text = "hello world"\n'
              'count = defaultdict(int)        # 默认值为 int() = 0\n'
              'for ch in text:\n'
              '    count[ch] += 1              # 首次访问自动初始化为 0\n'
              'print(dict(count))\n'
              "# → {'h':1, 'e':1, 'l':3, 'o':2, ' ':1, 'w':1, 'r':1, 'd':1}\n"
              '\n'
              '# 分组场景\n'
              'students = [("男", "小明"), ("女", "小红"), ("男", "小刚")]\n'
              'groups = defaultdict(list)      # 默认值为 []\n'
              'for gender, name in students:\n'
              '    groups[gender].append(name)\n'
              'print(dict(groups))\n'
              "# → {'男': ['小明', '小刚'], '女': ['小红']}",
              language: 'Python',
            ),
            OutputBox(
              "{'h': 1, 'e': 1, 'l': 3, 'o': 2, ' ': 1, 'w': 1, 'r': 1, 'd': 1}\n"
              "{'男': ['小明', '小刚'], '女': ['小红']}",
            ),
            Paragraph('【OrderedDict —— 记住插入顺序】'),
            CodeBlock(
              'from collections import OrderedDict\n'
              '\n'
              'od = OrderedDict()\n'
              'od["z"] = 1\n'
              'od["a"] = 2\n'
              'od["m"] = 3\n'
              'for k, v in od.items():\n'
              '    print(k, v)     # 保持插入顺序：z a m\n'
              '\n'
              '# move_to_end — 把指定键移到末尾\n'
              'od.move_to_end("z")\n'
              'print(list(od.keys()))  # [a, m, z]\n'
              '\n'
              '# Python 3.7+ 普通字典也保持顺序，\n'
              '# 但 OrderedDict 提供 move_to_end 等额外方法',
              language: 'Python',
            ),
            OutputBox(
              'z 1\n'
              'a 2\n'
              'm 3\n'
              "['a', 'm', 'z']",
            ),

            // 3.5 字典合并
            Paragraph('【字典合并（Python 3.9+）】'),
            CodeBlock(
              'd1 = {"a": 1, "b": 2}\n'
              'd2 = {"b": 3, "c": 4}\n'
              '\n'
              '# 传统方式\n'
              'merged = d1.copy()\n'
              'merged.update(d2)\n'
              'print(merged)           # {a: 1, b: 3, c: 4}\n'
              '\n'
              '# Python 3.9+ — 简洁的 | 运算符\n'
              'merged2 = d1 | d2\n'
              'print(merged2)          # {a: 1, b: 3, c: 4}\n'
              '\n'
              '# 就地合并（类似 update）\n'
              'd1 |= d2\n'
              'print(d1)              # {a: 1, b: 3, c: 4}',
              language: 'Python',
            ),
            OutputBox(
              "{'a': 1, 'b': 3, 'c': 4}\n"
              "{'a': 1, 'b': 3, 'c': 4}\n"
              "{'a': 1, 'b': 3, 'c': 4}",
            ),
            DividerLine(),

            // ================================================================
            // ④ 集合详解
            // ================================================================
            SectionHeader('④ 集合详解', icon: Icons.filter_none),
            Paragraph(
              '集合（set）是无序、不重复的元素集，源自数学中的集合论。'
              '它最擅长去重和集合运算（交集、并集、差集等）。',
            ),

            // 4.1 创建与基本操作
            CodeBlock(
              '# ===== 创建集合 =====\n'
              'empty_set = set()            # 空集合（不能用 {}，那是空字典！）\n'
              'numbers = {1, 2, 3, 2, 1}    # 重复元素自动去重\n'
              'print(numbers)               # {1, 2, 3}\n'
              '\n'
              '# 从列表去重\n'
              'unique = set([1, 2, 2, 3, 3, 3])\n'
              'print(unique)                # {1, 2, 3}\n'
              '\n'
              '# ===== 添加和删除 =====\n'
              'fruits = {"苹果", "香蕉"}\n'
              'fruits.add("橘子")           # 添加元素\n'
              'print(fruits)                # 顺序不定\n'
              '\n'
              'fruits.remove("香蕉")        # 删除（不存在会 KeyError）\n'
              'fruits.discard("西瓜")       # 安全删除（不存在不报错）\n'
              'popped = fruits.pop()        # 删除并返回一个随机元素\n'
              'print(popped)\n'
              '\n'
              'fruits.clear()               # 清空所有元素\n'
              'print(fruits)                # set()',
              language: 'Python',
            ),
            OutputBox(
              '{1, 2, 3}\n'
              '{1, 2, 3}\n'
              "{'苹果', '橘子', '香蕉'}\n"
              '苹果\n'
              'set()',
            ),

            // 4.2 集合运算
            Paragraph('【集合运算】'),
            CodeBlock(
              'a = {1, 2, 3, 4, 5}\n'
              'b = {4, 5, 6, 7, 8}\n'
              '\n'
              '# 交集 &  — 同时在 A 和 B 中\n'
              'print(a & b)                     # {4, 5}\n'
              'print(a.intersection(b))         # 同上\n'
              '\n'
              '# 并集 |  — 所有元素（去重）\n'
              'print(a | b)                     # {1,2,3,4,5,6,7,8}\n'
              'print(a.union(b))\n'
              '\n'
              '# 差集 -  — 在 A 不在 B\n'
              'print(a - b)                     # {1, 2, 3}\n'
              'print(a.difference(b))\n'
              '\n'
              '# 对称差 ^  — A 和 B 不同时有的\n'
              'print(a ^ b)                     # {1,2,3,6,7,8}\n'
              'print(a.symmetric_difference(b))\n'
              '\n'
              '# 实用：列表去重并保留顺序\n'
              'nums = [3, 1, 2, 3, 2, 1, 4]\n'
              'ordered = list(dict.fromkeys(nums))\n'
              'print(ordered)  # [3, 1, 2, 4]',
              language: 'Python',
            ),
            OutputBox(
              '{4, 5}\n'
              '{1, 2, 3, 4, 5, 6, 7, 8}\n'
              '{1, 2, 3}\n'
              '{1, 2, 3, 6, 7, 8}\n'
              '[3, 1, 2, 4]',
            ),

            // 4.3 子集/超集 和 frozenset
            Paragraph('【子集、超集、frozenset】'),
            CodeBlock(
              '# ===== 子集 / 超集判断 =====\n'
              'a = {1, 2, 3}\n'
              'b = {1, 2, 3, 4, 5}\n'
              'c = {1, 2, 3}\n'
              '\n'
              'print(a.issubset(b))       # True — a 是 b 的子集\n'
              'print(b.issuperset(a))     # True — b 是 a 的超集\n'
              'print(a == c)              # True — 相等判断\n'
              'print(a.isdisjoint({4,5})) # True — 完全没有交集\n'
              '\n'
              '# ===== frozenset — 不可变集合 =====\n'
              'fs = frozenset([1, 2, 3])\n'
              '# fs.add(4)  # 报错！frozenset 不可变\n'
              '\n'
              '# frozenset 可用作字典键（普通 set 不行）\n'
              'd = {frozenset([1, 2]): "hello"}\n'
              'print(d)',
              language: 'Python',
            ),
            OutputBox(
              'True\n'
              'True\n'
              'True\n'
              'True\n'
              "{frozenset({1, 2}): 'hello'}",
            ),
            TipBox(
              '需要去重时首先想到 set。注意 set 是无序的，如需保留原顺序，'
              '可以用 dict.fromkeys() 手法或手动遍历。'
              'frozenset 可哈希，能作字典键或放进另一个集合。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ================================================================
            // ⑤ 列表推导式深入
            // ================================================================
            SectionHeader('⑤ 列表推导式深入', icon: Icons.calculate),
            Paragraph(
              '列表推导式（list comprehension）是 Python 最优雅的特性之一，'
              '用一行表达式替代多行循环代码，让代码更简洁、更可读。',
            ),

            // 5.1 基本语法
            Paragraph('【基本语法】'),
            CodeBlock(
              '# 传统写法 vs 列表推导式\n'
              'squares = []\n'
              'for x in range(10):\n'
              '    squares.append(x ** 2)\n'
              '# 一行搞定！\n'
              'squares2 = [x ** 2 for x in range(10)]\n'
              'print(squares2)  # [0, 1, 4, 9, ..., 81]\n'
              '\n'
              '# 实际应用：批量字符串处理\n'
              'words = ["hello", "world", "python"]\n'
              'upper = [w.upper() for w in words]\n'
              'print(upper)  # [HELLO, WORLD, PYTHON]',
              language: 'Python',
            ),
            OutputBox(
              '[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]\n'
              "['HELLO', 'WORLD', 'PYTHON']",
            ),

            // 5.2 带条件
            Paragraph('【带条件的推导式】'),
            CodeBlock(
              '# 语法：[expr for item in iterable if condition]\n'
              '\n'
              '# 0-19 之间的偶数\n'
              'evens = [x for x in range(20) if x % 2 == 0]\n'
              'print(evens)\n'
              '# [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]\n'
              '\n'
              '# 同时被 2 和 3 整除\n'
              'nums = [x for x in range(20) if x % 2 == 0 and x % 3 == 0]\n'
              'print(nums)  # [0, 6, 12, 18]\n'
              '\n'
              '# if-else 条件表达式（放在前面做值变换）\n'
              'labels = ["偶数" if x % 2 == 0 else "奇数" for x in range(5)]\n'
              'print(labels)  # [偶数, 奇数, 偶数, 奇数, 偶数]',
              language: 'Python',
            ),
            OutputBox(
              '[0, 2, 4, 6, 8, 10, 12, 14, 16, 18]\n'
              '[0, 6, 12, 18]\n'
              "['偶数', '奇数', '偶数', '奇数', '偶数']",
            ),
            TipBox(
              'if 放在后面只做筛选（不能改变元素值）；if-else 放在前面可以做值变换。'
              '两者的位置和语义截然不同，注意区分！',
              type: TipType.caution,
            ),

            // 5.3 嵌套循环
            Paragraph('【嵌套循环】'),
            CodeBlock(
              '# 语法：[expr for a in A for b in B]\n'
              '# 执行顺序等同于普通嵌套 for 循环\n'
              '\n'
              '# 生成所有坐标组合\n'
              'pairs = [(x, y) for x in range(3) for y in range(3)]\n'
              'print(pairs)\n'
              '# [(0,0), (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)]\n'
              '\n'
              '# 展平二维列表\n'
              'matrix = [[1, 2], [3, 4], [5, 6]]\n'
              'flat = [num for row in matrix for num in row]\n'
              'print(flat)  # [1, 2, 3, 4, 5, 6]\n'
              '\n'
              '# 带条件的嵌套\n'
              'result = [x * y for x in range(1, 4) for y in range(1, 4) if x != y]\n'
              'print(result)  # [2, 3, 2, 6, 3, 6]',
              language: 'Python',
            ),
            OutputBox(
              '[(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (2, 0), (2, 1), (2, 2)]\n'
              '[1, 2, 3, 4, 5, 6]\n'
              '[2, 3, 2, 6, 3, 6]',
            ),

            // 5.4 字典和集合推导式
            Paragraph('【字典推导式和集合推导式】'),
            CodeBlock(
              '# ===== 字典推导式 {k: v for ...} =====\n'
              'squares = {x: x ** 2 for x in range(5)}\n'
              'print(squares)  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}\n'
              '\n'
              '# 反转字典：键值互换\n'
              'original = {"a": 1, "b": 2, "c": 3}\n'
              'reversed_d = {v: k for k, v in original.items()}\n'
              'print(reversed_d)  # {1: a, 2: b, 3: c}\n'
              '\n'
              '# 带条件过滤\n'
              'even_sq = {x: x**2 for x in range(10) if x % 2 == 0}\n'
              'print(even_sq)  # {0:0, 2:4, 4:16, 6:36, 8:64}\n'
              '\n'
              '# ===== 集合推导式 {expr for ...} =====\n'
              'lengths = {len(w) for w in ["hello", "world", "python", "hi"]}\n'
              'print(lengths)  # {2, 5, 6}',
              language: 'Python',
            ),
            OutputBox(
              '{0: 0, 1: 1, 2: 4, 3: 9, 4: 16}\n'
              "{1: 'a', 2: 'b', 3: 'c'}\n"
              '{0: 0, 2: 4, 4: 16, 6: 36, 8: 64}\n'
              '{2, 5, 6}',
            ),

            // ⑤ → ⑥ 生成器表达式（作为子节）
            SectionHeader('⑥ 生成器表达式', icon: Icons.play_circle_outline),
            Paragraph(
              '生成器表达式（generator expression）在语法上和列表推导式几乎一样，'
              '只是把方括号换成圆括号。但它的核心区别是"惰性求值"——不一次性算出全部结果，'
              '而是按需逐个生成，因此极大节省内存。',
            ),

            CodeBlock(
              '# ===== 语法对比 =====\n'
              '# 列表推导式 — 全部算好，存入内存\n'
              'list_comp = [x ** 2 for x in range(10)]\n'
              'print(type(list_comp))  # <class \'list\'>\n'
              'print(list_comp)        # 立刻看到全部结果\n'
              '\n'
              '# 生成器表达式 — 惰性求值，按需生成\n'
              'gen_expr = (x ** 2 for x in range(10))\n'
              'print(type(gen_expr))   # <class \'generator\'>\n'
              'print(gen_expr)         # 不输出值，只输出 generator 对象\n'
              '\n'
              '# 逐个获取值\n'
              'for val in gen_expr:\n'
              '    print(val, end=" ")  # 0 1 4 9 16 25 36 49 64 81\n'
              'print()\n'
              '\n'
              '# ===== 内存对比 =====\n'
              'import sys\n'
              'big_list = [x for x in range(100000)]\n'
              'big_gen  = (x for x in range(100000))\n'
              'print(f"列表占用: {sys.getsizeof(big_list)} bytes")\n'
              'print(f"生成器占用: {sys.getsizeof(big_gen)} bytes")\n'
              '# 生成器几乎不占内存！\n'
              '\n'
              '# ===== 实用场景：无需全部保存 =====\n'
              '# 计算 1 到 1 亿的和 — 生成器节省大量内存\n'
              'total = sum(x for x in range(100_000_000))\n'
              'print(total)  # 499999995000000',
              language: 'Python',
            ),
            OutputBox(
              "<class 'list'>\n"
              '[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]\n'
              "<class 'generator'>\n"
              '<generator object <genexpr> at 0x...>\n'
              '0 1 4 9 16 25 36 49 64 81\n'
              '列表占用: 824456 bytes\n'
              '生成器占用: 112 bytes',
            ),
            TipBox(
              '处理大量数据时优先用生成器表达式：内存占用极少。'
              '但如果你需要反复遍历或随机访问，还是要转成列表。'
              'sum()、min()、max() 等函数配合生成器尤其高效。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ================================================================
            // ⑦ 常用 collections 工具
            // ================================================================
            SectionHeader('⑦ 常用 collections 工具', icon: Icons.handyman),
            Paragraph(
              'collections 模块提供了许多强大的数据结构扩展，能大幅简化日常编程中的常见任务。',
            ),

            // Counter
            Paragraph('【Counter — 计数器】'),
            CodeBlock(
              'from collections import Counter\n'
              '\n'
              '# 统计元素出现次数\n'
              'words = ["apple", "banana", "apple", "orange", "banana", "apple"]\n'
              'cnt = Counter(words)\n'
              'print(cnt)  # Counter({apple: 3, banana: 2, orange: 1})\n'
              '\n'
              '# 访问次数\n'
              'print(cnt["apple"])      # 3\n'
              '\n'
              '# 出现最多的 N 个\n'
              'print(cnt.most_common(2))  # [(apple, 3), (banana, 2)]\n'
              '\n'
              '# 字符串字母统计\n'
              'chars = Counter("hello world")\n'
              'print(chars["l"])        # 3\n'
              '\n'
              '# Counter 运算\n'
              'c1 = Counter(a=3, b=1)\n'
              'c2 = Counter(a=1, b=2)\n'
              'print(c1 + c2)  # Counter({a: 4, b: 3})\n'
              'print(c1 - c2)  # Counter({a: 2}) 不会减到负数',
              language: 'Python',
            ),
            OutputBox(
              "Counter({'apple': 3, 'banana': 2, 'orange': 1})\n"
              "[('apple', 3), ('banana', 2)]\n"
              '3\n'
              '3\n'
              "Counter({'a': 4, 'b': 3})\n"
              "Counter({'a': 2})",
            ),

            // deque
            Paragraph('【deque — 双端队列】'),
            CodeBlock(
              'from collections import deque\n'
              '\n'
              '# 创建\n'
              'dq = deque([1, 2, 3])\n'
              'dq.append(4)            # 右侧追加\n'
              'dq.appendleft(0)        # 左侧追加\n'
              'print(dq)               # deque([0, 1, 2, 3, 4])\n'
              '\n'
              '# 两端弹出\n'
              'right = dq.pop()        # 右侧弹出 → 4\n'
              'left = dq.popleft()     # 左侧弹出 → 0\n'
              'print(right, left)      # 4 0\n'
              '\n'
              '# 旋转\n'
              'dq2 = deque([1, 2, 3, 4, 5])\n'
              'dq2.rotate(2)           # 向右旋转 2 步\n'
              'print(dq2)              # deque([4, 5, 1, 2, 3])\n'
              'dq2.rotate(-1)          # 向左旋转 1 步\n'
              'print(dq2)              # deque([5, 1, 2, 3, 4])\n'
              '\n'
              '# 限制长度 — 自动丢弃另一端的元素\n'
              'dq3 = deque(maxlen=3)\n'
              'for i in range(5):\n'
              '    dq3.append(i)\n'
              'print(dq3)  # deque([2, 3, 4], maxlen=3)',
              language: 'Python',
            ),
            OutputBox(
              'deque([0, 1, 2, 3, 4])\n'
              '4 0\n'
              'deque([4, 5, 1, 2, 3])\n'
              'deque([5, 1, 2, 3, 4])\n'
              'deque([2, 3, 4], maxlen=3)',
            ),

            // namedtuple 与 OrderedDict 回顾
            Paragraph('【namedtuple / OrderedDict 回顾】'),
            Paragraph(
              'namedtuple 和 OrderedDict 已在前面小节详细介绍过。'
              'namedtuple 创建轻量级数据类，兼具元组的性能和类的可读性；'
              'OrderedDict 在需要 move_to_end 等额外方法时仍不可替代。'
              '这些工具组合使用能应对绝大多数数据结构的编程需求。',
            ),
            DividerLine(),

            // ================================================================
            // ⑧ 排序与切片
            // ================================================================
            SectionHeader('⑧ 排序与切片', icon: Icons.sort),
            Paragraph(
              '排序和切片是日常编程中使用频率最高的操作之一。'
              'Python 提供了灵活而强大的排序机制和极具表现力的切片语法。',
            ),

            // 8.1 sorted() vs .sort()
            Paragraph('【sorted() 与 .sort() 的区别】'),
            CodeBlock(
              '# sort() — 就地排序，修改原列表\n'
              'nums = [3, 1, 4, 1, 5]\n'
              'nums.sort()\n'
              'print(nums)  # [1, 1, 3, 4, 5]（原列表变了）\n'
              '\n'
              '# sorted() — 返回新列表，原列表不变\n'
              'nums2 = [3, 1, 4, 1, 5]\n'
              'sorted_nums = sorted(nums2)\n'
              'print(nums2)        # [3, 1, 4, 1, 5]（没变）\n'
              'print(sorted_nums)  # [1, 1, 3, 4, 5]（新列表）\n'
              '\n'
              '# sorted() 可对任何可迭代对象排序\n'
              'text = "python"\n'
              'print(sorted(text))  # [h, n, o, p, t, y]\n'
              '\n'
              '# reverse=True 降序\n'
              'print(sorted(nums2, reverse=True))  # [5, 4, 3, 1, 1]',
              language: 'Python',
            ),
            OutputBox(
              '[1, 1, 3, 4, 5]\n'
              '[3, 1, 4, 1, 5]\n'
              '[1, 1, 3, 4, 5]\n'
              "['h', 'n', 'o', 'p', 't', 'y']\n"
              '[5, 4, 3, 1, 1]',
            ),

            // 8.2 key 参数
            Paragraph('【key 参数 — 自定义排序规则】'),
            CodeBlock(
              '# 按字符串长度排序\n'
              'words = ["python", "java", "c", "javascript", "go"]\n'
              'print(sorted(words, key=len))\n'
              "# ['c', 'go', 'java', 'python', 'javascript']\n"
              '\n'
              '# 按绝对值排序\n'
              'numbers = [-5, 3, -2, 8, -1]\n'
              'print(sorted(numbers, key=abs))\n'
              '# [-1, -2, 3, -5, 8]\n'
              '\n'
              '# 按元组第二个元素排序\n'
              'pairs = [(1, "banana"), (2, "apple"), (3, "cherry")]\n'
              'print(sorted(pairs, key=lambda x: x[1]))\n'
              "# [(2, 'apple'), (1, 'banana'), (3, 'cherry')]\n"
              '\n'
              '# 多层排序：先按分数降序，再按年龄升序\n'
              'students = [\n'
              '    ("小明", 18, 95),\n'
              '    ("小红", 17, 95),\n'
              '    ("小刚", 18, 90),\n'
              ']\n'
              'sorted_students = sorted(students, key=lambda s: (-s[2], s[1]))\n'
              'print(sorted_students)',
              language: 'Python',
            ),
            OutputBox(
              "['c', 'go', 'java', 'python', 'javascript']\n"
              '[-1, -2, 3, -5, 8]\n'
              "[(2, 'apple'), (1, 'banana'), (3, 'cherry')]\n"
              "[('小红', 17, 95), ('小明', 18, 95), ('小刚', 18, 90)]",
            ),
            TipBox(
              'sorted() 的 key 参数极其灵活，可传入任意单参函数。'
              'lambda 表达式是最常用的方式。对于多层排序，用元组返回多个维度，'
              '负数前缀表示该维度降序。',
              type: TipType.tip,
            ),

            // 8.3 切片进阶
            Paragraph('【切片进阶操作】'),
            CodeBlock(
              '# ===== 切片赋值 =====\n'
              'a = [1, 2, 3, 4, 5]\n'
              'a[1:3] = [10, 20]        # 替换切片范围\n'
              'print(a)                  # [1, 10, 20, 4, 5]\n'
              '\n'
              '# 插入（赋值给空切片）\n'
              'b = [1, 2, 5]\n'
              'b[2:2] = [3, 4]          # 在索引 2 处插入\n'
              'print(b)                  # [1, 2, 3, 4, 5]\n'
              '\n'
              '# 删除（赋值为空列表）\n'
              'c = [1, 2, 3, 4, 5]\n'
              'c[1:4] = []              # 删除索引 1 到 3\n'
              'print(c)                  # [1, 5]\n'
              '\n'
              '# ===== 步长切片 =====\n'
              'd = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]\n'
              'print(d[::2])            # 偶数位：[0, 2, 4, 6, 8]\n'
              'print(d[1::2])           # 奇数位：[1, 3, 5, 7, 9]\n'
              'print(d[::-1])           # 反转：[9, 8, ..., 0]\n'
              'print(d[5:0:-1])         # 从 5 到 1（不含0）\n'
              '\n'
              '# ===== 命名切片（slice 对象）=====\n'
              'record = "2024-01-15 Python 教程"\n'
              'DATE = slice(0, 10)\n'
              'print(record[DATE])       # 2024-01-15',
              language: 'Python',
            ),
            OutputBox(
              '[1, 10, 20, 4, 5]\n'
              '[1, 2, 3, 4, 5]\n'
              '[1, 5]\n'
              '[0, 2, 4, 6, 8]\n'
              '[1, 3, 5, 7, 9]\n'
              '[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]\n'
              '[5, 4, 3, 2, 1]\n'
              '2024-01-15',
            ),
            TipBox(
              '切片赋值是 Python 的独有特性，可以直接替换、插入、删除列表片段。'
              'a[::-1] 反转、a[::2] 取偶数位，这些技巧在算法题中经常用到。'
              '命名切片（slice 对象）能让复杂切片逻辑更可读。',
              type: TipType.info,
            ),
            DividerLine(),

            // ================================================================
            // 小练习
            // ================================================================
            SectionHeader('小练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: '列表排序',
              description: '有列表 [("Tom", 88), ("Jerry", 75), ("Spike", 95), ("Tyke", 82)]，按分数从高到低排序。',
            ),
            StepItem(
              step: 2,
              title: '单词统计',
              description: '用 Counter 统计 "the quick brown fox jumps over the lazy dog the quick" 中每个单词的出现次数，并找出出现最多的 3 个。',
            ),
            StepItem(
              step: 3,
              title: '集合运算',
              description: '有 list_a = [1,2,3,4,5,6] 和 list_b = [4,5,6,7,8,9]，找出只在 list_a 中出现的元素（差集）。',
            ),
            StepItem(
              step: 4,
              title: '推导式练习',
              description: '用一行列表推导式生成 1 到 50 之间所有能被 3 或 5 整除的数。',
            ),
            StepItem(
              step: 5,
              title: '深浅拷贝理解',
              description: '解释为什么 nested = [[1,2], [3,4]]; copy = nested.copy(); copy[0][0] = 99 会影响 nested。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
