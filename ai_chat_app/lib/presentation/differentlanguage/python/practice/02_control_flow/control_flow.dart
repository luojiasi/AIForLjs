import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// if/elif/else 分支可视化
class _IfElseDemo extends StatefulWidget {
  const _IfElseDemo();
  @override
  State<_IfElseDemo> createState() => _IfElseDemoState();
}

class _IfElseDemoState extends State<_IfElseDemo> {
  int _score = 85;
  int _age = 20;
  bool _hasId = true;

  String get _grade {
    if (_score >= 90) return 'A（优秀）';
    if (_score >= 75) return 'B（良好）';
    if (_score >= 60) return 'C（及格）';
    return 'D（不及格）';
  }

  Color get _gradeColor {
    if (_score >= 90) return Colors.green;
    if (_score >= 75) return Colors.blue;
    if (_score >= 60) return Colors.orange;
    return Colors.red;
  }

  String get _ageResult {
    if (_age >= 18) {
      return _hasId ? '可以进入 ✅' : '请出示身份证 ⚠️';
    }
    return '未成年禁止进入 ❌';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('🎯 交互式演示', icon: Icons.play_circle),
        InteractivePlayground(
          title: '📊 成绩等级分支可视化',
          subtitle: '拖动滑块，实时看到哪个 if/elif 分支被执行',
          children: [
            ParamIntSlider(label: '分数', value: _score, min: 0, max: 100, onChanged: (v) => setState(() => _score = v), unit: '分'),
            // 分支高亮展示
            ...[
              ('score >= 90', 'A（优秀）', _score >= 90),
              ('score >= 75', 'B（良好）', _score >= 75 && _score < 90),
              ('score >= 60', 'C（及格）', _score >= 60 && _score < 75),
              ('else', 'D（不及格）', _score < 60),
            ].map((item) {
              final (cond, result, active) = item;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _gradeColor.withOpacity(0.15) : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active ? _gradeColor : Colors.grey.withOpacity(0.2),
                    width: active ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(active ? Icons.arrow_right : Icons.remove, size: 20, color: active ? _gradeColor : Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cond == 'else' ? 'else:' : 'elif $cond:', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal))),
                  if (active) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _gradeColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(result, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
              );
            }),
            const SizedBox(height: 8),
            LiveCodeBlock(
              'score = $_score\n'
              'if score >= 90:      ${_score >= 90 ? "← 执行此分支" : ""}\n'
              '    grade = "A（优秀）"\n'
              'elif score >= 75:    ${_score >= 75 && _score < 90 ? "← 执行此分支" : ""}\n'
              '    grade = "B（良好）"\n'
              'elif score >= 60:    ${_score >= 60 && _score < 75 ? "← 执行此分支" : ""}\n'
              '    grade = "C（及格）"\n'
              'else:                ${_score < 60 ? "← 执行此分支" : ""}\n'
              '    grade = "D（不及格）"\n'
              'print(grade)',
            ),
            LiveOutputBox('grade = $_grade'),
          ],
        ),
        const SizedBox(height: 12),
        InteractivePlayground(
          title: '🚪 嵌套条件：年龄 + 证件检查',
          subtitle: '模拟多层嵌套 if 的执行路径',
          children: [
            ParamIntSlider(label: '年龄', value: _age, min: 1, max: 60, onChanged: (v) => setState(() => _age = v), unit: '岁'),
            ParamSwitch(label: '有身份证', value: _hasId, onChanged: (v) => setState(() => _hasId = v), trueLabel: '有', falseLabel: '没有'),
            const SizedBox(height: 8),
            ProgressSteps(
              steps: ['年龄检查', '证件检查', '结果'],
              activeStep: _age >= 18 ? (_hasId ? 2 : 1) : 0,
            ),
            const SizedBox(height: 8),
            LiveCodeBlock(
              'age, has_id = $_age, ${_hasId ? 'True' : 'False'}\n\n'
              'if age >= 18:      ${_age >= 18 ? "← True，进入" : "← False，跳过"}\n'
              '    if has_id:    ${_age >= 18 ? (_hasId ? "← True，进入" : "← False，跳过") : ""}\n'
              '        print("可以进入")\n'
              '    else:\n'
              '        print("请出示身份证")\n'
              'else:\n'
              '    print("未成年禁止进入")',
            ),
            LiveOutputBox(_ageResult),
          ],
        ),
      ],
    );
  }
}

/// 循环演示
class _LoopDemo extends StatefulWidget {
  const _LoopDemo();
  @override
  State<_LoopDemo> createState() => _LoopDemoState();
}

class _LoopDemoState extends State<_LoopDemo> {
  int _start = 1;
  int _end = 10;
  int _step = 1;
  String _filter = '全部';

  List<int> get _range {
    final result = <int>[];
    for (int i = _start; i <= _end; i += _step) {
      result.add(i);
    }
    return result;
  }

  List<int> get _filtered {
    return _range.where((n) {
      switch (_filter) {
        case '偶数': return n % 2 == 0;
        case '奇数': return n % 2 != 0;
        case '3的倍数': return n % 3 == 0;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final filtered = _filtered;

    return InteractivePlayground(
      title: '🔁 循环演示：range() 可视化',
      subtitle: '调整 start/end/step，实时查看循环执行情况',
      children: [
        ParamIntSlider(label: 'start（起始）', value: _start, min: 0, max: 10, onChanged: (v) => setState(() { _start = v; if (_start > _end) _end = _start; })),
        ParamIntSlider(label: 'end（结束）', value: _end, min: 1, max: 20, onChanged: (v) => setState(() { _end = v; if (_end < _start) _start = _end; })),
        ParamIntSlider(label: 'step（步长）', value: _step, min: 1, max: 5, onChanged: (v) => setState(() => _step = v)),
        ParamChoiceChips(
          label: '过滤条件',
          value: _filter,
          options: [('全部', '全部'), ('偶数', '偶数'), ('奇数', '奇数'), ('3的倍数', '3的倍数')],
          onChanged: (v) => setState(() => _filter = v),
        ),
        // 数字格子可视化
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: range.map((n) {
            final inFilter = filtered.contains(n);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: inFilter ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$n',
                  style: TextStyle(
                    color: inFilter ? Colors.white : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(
          '# range($_start, ${_end + 1}, $_step)\n'
          'for n in range($_start, ${_end + 1}, $_step):\n'
          '    ${_filter == '全部' ? '' : 'if n % ${_filter == '偶数' ? '2 == 0' : _filter == '奇数' ? '2 != 0' : '3 == 0'}:\n    '}'
          'print(n, end=" ")\n'
          '\n'
          '# 结果：${filtered.join(', ')}',
        ),
        LiveOutputBox(filtered.isEmpty ? '（无输出）' : filtered.join('  ') + '\n\n共 ${filtered.length} 个数字，'
            'range: [$_start, ${_end + 1}) step=$_step'),
      ],
    );
  }
}

/// 列表推导式演示
class _ListComprehensionDemo extends StatefulWidget {
  const _ListComprehensionDemo();
  @override
  State<_ListComprehensionDemo> createState() => _ListComprehensionDemoState();
}

class _ListComprehensionDemoState extends State<_ListComprehensionDemo> {
  int _end = 10;
  String _expr = 'n * n';
  bool _hasCondition = false;
  String _condition = 'n % 2 == 0';

  List<int> _eval(int n) {
    switch (_expr) {
      case 'n * n': return [n * n];
      case 'n * 2': return [n * 2];
      case 'n + 10': return [n + 10];
      case 'n ** 3': return [n * n * n];
      default: return [n];
    }
  }

  bool _evalCond(int n) {
    switch (_condition) {
      case 'n % 2 == 0': return n % 2 == 0;
      case 'n % 2 != 0': return n % 2 != 0;
      case 'n > 5': return n > 5;
      case 'n % 3 == 0': return n % 3 == 0;
      default: return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(_end, (i) => i + 1)
        .where((n) => !_hasCondition || _evalCond(n))
        .map((n) => _eval(n).first)
        .toList();

    return InteractivePlayground(
      title: '⚡ 列表推导式生成器',
      subtitle: '选择表达式和条件，生成不同的列表',
      children: [
        ParamIntSlider(label: '范围 1~n', value: _end, min: 3, max: 15, onChanged: (v) => setState(() => _end = v)),
        ParamChoiceChips(
          label: '表达式',
          value: _expr,
          options: [('n * n', 'n²'), ('n * 2', 'n×2'), ('n + 10', 'n+10'), ('n ** 3', 'n³')],
          onChanged: (v) => setState(() => _expr = v),
        ),
        ParamSwitch(label: '添加过滤条件', value: _hasCondition, onChanged: (v) => setState(() => _hasCondition = v), trueLabel: '开启', falseLabel: '关闭'),
        if (_hasCondition)
          ParamChoiceChips(
            label: '过滤条件',
            value: _condition,
            options: [('n % 2 == 0', '偶数'), ('n % 2 != 0', '奇数'), ('n > 5', 'n>5'), ('n % 3 == 0', '3倍数')],
            onChanged: (v) => setState(() => _condition = v),
          ),
        LiveCodeBlock(
          _hasCondition
              ? '[${_expr} for n in range(1, ${_end + 1}) if $_condition]'
              : '[${_expr} for n in range(1, ${_end + 1})]',
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$v', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          )).toList(),
        ),
        const SizedBox(height: 6),
        LiveOutputBox('[${items.join(', ')}]\n共 ${items.length} 个元素'),
      ],
    );
  }
}

/// Python 控制流程 —— 第二课（扩展版）
/// 涵盖：缩进规则、if/elif/else、match-case(3.10+)、
/// for循环、while循环、break/continue/else、条件表达式、pass
class PythonControlFlow extends StatelessWidget {
  const PythonControlFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第2章 控制流程'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('本章内容', icon: Icons.list),
            Paragraph(
              '① 缩进原则\n'
              '② if/elif/else 条件判断\n'
              '③ match-case（3.10+）\n'
              '④ 条件表达式（三元）\n'
              '⑤ for 循环进阶\n'
              '⑥ while 循环\n'
              '⑦ break/continue/for-else\n'
              '⑧ pass 语句\n'
              '⑨ 布尔真值',
            ),
            TipBox(
              'Python 的控制流程语法简洁而强大。掌握这些后，你已经能用 Python '
              '解决大部分编程问题了。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 1. 缩进规则 =====
            SectionHeader('1. 缩进 —— Python 的灵魂', icon: Icons.space_bar),
            Paragraph(
              '在其他语言中，缩进只是"好看"。但在 Python 中，缩进是语法！'
              '同一代码块必须使用相同数量的空格。这强迫你写出整洁的代码。',
            ),
            CodeBlock(
              '# 正确的缩进：同一代码块用相同缩进\n'
              'if True:\n'
              '    print("这是 if 代码块")          # 4个空格\n'
              '    if True:\n'
              '        print("这是嵌套代码块")       # 8个空格\n'
              '    print("仍在第一个 if 内")\n'
              'print("在 if 外面")                  # 0个缩进\n'
              '\n'
              '# ❌ 错误的缩进\n'
              '# if True:\n'
              '# print("没缩进")    # IndentationError!\n'
              '#     print("缩进不一致")  # IndentationError!\n'
              '\n'
              '# 规则：\n'
              '# 1. 默认用 4 个空格（PEP 8 推荐）\n'
              '# 2. 不要混用 Tab 和空格\n'
              '# 3. 冒号 : 后面必须换行缩进\n'
              '# 4. 空行不影响缩进层级',
              language: 'Python',
            ),
            TipBox(
              '几乎所有 Python IDE 都会自动处理缩进。用 VS Code 写 Python，'
              '按 Tab 会自动变成 4 个空格。设置 "editor.insertSpaces": true。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 2. if/elif/else =====
            SectionHeader('2. if/elif/else —— 条件判断', icon: Icons.call_split),
            Paragraph(
              '条件判断让程序根据不同情况执行不同代码。'
              'if → elif（多个条件）→ else（兜底），顺序很重要——第一个匹配的条件执行后，后面的就不会执行了。',
            ),
            CodeBlock(
              '# ===== 基本语法 =====\n'
              'score = 85\n'
              '\n'
              'if score >= 90:\n'
              '    grade = "A"\n'
              'elif score >= 75:\n'
              '    grade = "B"\n'
              'elif score >= 60:\n'
              '    grade = "C"\n'
              'else:\n'
              '    grade = "D"\n'
              'print(f"等级：{grade}")  # 等级：B\n'
              '\n'
              '# ===== 嵌套条件 =====\n'
              'age = 20\n'
              'has_id = True\n'
              '\n'
              'if age >= 18:\n'
              '    if has_id:\n'
              '        print("可以进入")\n'
              '    else:\n'
              '        print("请出示身份证")\n'
              'else:\n'
              '    print("未成年禁止进入")\n'
              '\n'
              '# ===== 多个条件合并 =====\n'
              'if age >= 18 and has_id:\n'
              '    print("欢迎光临")\n'
              '\n'
              '# ===== 短路求值 =====\n'
              '# and：左边为 False 就不判断右边\n'
              '# or：左边为 True 就不判断右边\n'
              'def check():\n'
              '    print("check 被调用")\n'
              '    return True\n'
              '\n'
              'False and check()  # check() 不会执行（短路）\n'
              'True or check()    # check() 不会执行（短路）',
              language: 'Python',
            ),
            OutputBox(
              '等级：B\n'
              '未成年禁止进入\n'
              '欢迎光临',
            ),
            Paragraph(
              '在 Python 中，以下值被视为 False（称为"假值"）：\n'
              '• False、None、0、0.0\n'
              '• 空字符串 ""、空列表 []、空字典 {}、空集合 set()\n'
              '• 所有其他值都被视为 True',
            ),
            CodeBlock(
              '# 利用真值简化代码\n'
              'name = input("请输入名字：") or "匿名用户"\n'
              '# 如果 input 返回空字符串（假），就使用"匿名用户"\n'
              'print(f"你好，{name}")',
              language: 'Python',
            ),
            DividerLine(),

            // ===== 3. match-case =====
            SectionHeader('3. match-case（Python 3.10+）', icon: Icons.switch_access_shortcut),
            Paragraph(
              'Python 3.10 引入了 match-case 语句（结构化模式匹配），'
              '类似其他语言的 switch，但更强大——可以匹配类型、解包数据结构。',
            ),
            CodeBlock(
              '# ===== 基础用法：替代 if/elif =====\n'
              'status = 404\n'
              '\n'
              'match status:\n'
              '    case 200:\n'
              '        print("请求成功")\n'
              '    case 404:\n'
              '        print("资源未找到")\n'
              '    case 500:\n'
              '        print("服务器内部错误")\n'
              '    case _:                # _ 是通配符，匹配所有\n'
              '        print("未知状态码")\n'
              '\n'
              '# ===== 匹配类型 =====\n'
              'value = 42\n'
              'match value:\n'
              '    case int():            # 匹配整数\n'
              '        print(f"整数：{value}")\n'
              '    case str():            # 匹配字符串\n'
              '        print(f"字符串：{value}")\n'
              '    case _:\n'
              '        print("其他类型")\n'
              '\n'
              '# ===== 解包匹配 =====\n'
              'point = (3, 4)\n'
              'match point:\n'
              '    case (0, 0):\n'
              '        print("原点")\n'
              '    case (x, 0):\n'
              '        print(f"在X轴上，x={x}")\n'
              '    case (0, y):\n'
              '        print(f"在Y轴上，y={y}")\n'
              '    case (x, y):\n'
              '        print(f"坐标：({x}, {y})")',
              language: 'Python',
            ),
            TipBox(
              'match-case 是 Python 3.10 的新特性！如果你用的是更早的版本，'
              '请使用 if/elif/else 代替。可以用 python --version 查看版本。',
              type: TipType.caution,
            ),
            OutputBox(
              '资源未找到\n整数：42\n坐标：(3, 4)',
            ),
            DividerLine(),

            // ===== 4. 条件表达式 =====
            SectionHeader('4. 条件表达式（三元运算符）', icon: Icons.merge_type),
            Paragraph(
              'Python 的"三元运算符"语法：x if 条件 else y。'
              '当条件为 True 时取 x，否则取 y。适合简单的二选一场景。',
            ),
            CodeBlock(
              '# 基本语法：值1 if 条件 else 值2\n'
              '\n'
              'age = 20\n'
              'status = "成年" if age >= 18 else "未成年"\n'
              'print(status)  # 成年\n'
              '\n'
              '# 相当于：\n'
              'if age >= 18:\n'
              '    status = "成年"\n'
              'else:\n'
              '    status = "未成年"\n'
              '\n'
              '# 嵌套使用（不推荐，可读性差）\n'
              'score = 85\n'
              'grade = "优秀" if score >= 90 else "良好" if score >= 75 else "及格"\n'
              '# 上面的代码等价于：\n'
              '# if score >= 90: grade = "优秀"\n'
              '# elif score >= 75: grade = "良好"\n'
              '# else: grade = "及格"\n'
              '\n'
              '# 在列表推导式中特别有用\n'
              'numbers = [1, 2, 3, 4, 5]\n'
              'labels = ["偶数" if n % 2 == 0 else "奇数" for n in numbers]\n'
              'print(labels)  # [\'奇数\', \'偶数\', \'奇数\', \'偶数\', \'奇数\']',
              language: 'Python',
            ),
            TipBox(
              '三元运算符适合"一行就能写完"的简单条件。'
              '如果条件复杂或分支里有多个操作，还是用 if/else 更清晰。',
              type: TipType.tip,
            ),
            OutputBox(
              '成年\n'
              "['奇数', '偶数', '奇数', '偶数', '奇数']",
            ),
            DividerLine(),

            // ===== 5. for 循环 =====
            SectionHeader('5. for 循环进阶', icon: Icons.loop),
            Paragraph(
              'for 循环用于遍历任何可迭代对象（Iterable）。'
              'Python 的 for 和其他语言的 foreach 类似，而不是传统的"初始化-判断-递增"。',
            ),
            CodeBlock(
              '# ===== range() 详解 =====\n'
              '# range(stop)      -> 0 到 stop-1\n'
              '# range(start, stop) -> start 到 stop-1\n'
              '# range(start, stop, step) -> 带步长\n'
              'for i in range(1, 10, 2):\n'
              '    print(i, end=" ")    # 1 3 5 7 9\n'
              'print()\n'
              '\n'
              '# ===== enumerate —— 获取索引 =====\n'
              'fruits = ["苹果", "香蕉", "橘子"]\n'
              'for i, fruit in enumerate(fruits):\n'
              '    print(f"第{i+1}个水果是{fruit}")\n'
              '# 第1个水果是苹果\n'
              '# 第2个水果是香蕉\n'
              '# 第3个水果是橘子\n'
              '\n'
              '# ===== zip —— 并行遍历 =====\n'
              'names = ["小明", "小红", "小刚"]\n'
              'scores = [85, 92, 78]\n'
              'for name, score in zip(names, scores):\n'
              '    print(f"{name}: {score}分")\n'
              '\n'
              '# ===== reversed —— 反向遍历 =====\n'
              'for x in reversed(range(5)):\n'
              '    print(x, end=" ")    # 4 3 2 1 0\n'
              'print()\n'
              '\n'
              '# ===== sorted —— 排序遍历 =====\n'
              'for x in sorted([3, 1, 4, 1, 5]):\n'
              '    print(x, end=" ")    # 1 1 3 4 5\n'
              'print()\n'
              '\n'
              '# ===== 遍历字典的多种方式 =====\n'
              'd = {"a": 1, "b": 2, "c": 3}\n'
              'for key in d:                    # 遍历键\n'
              '    print(key, end=" ")          # a b c\n'
              'for val in d.values():           # 遍历值\n'
              '    print(val, end=" ")           # 1 2 3\n'
              'for k, v in d.items():           # 遍历键值对\n'
              '    print(f"{k}={v}", end=" ")    # a=1 b=2 c=3',
              language: 'Python',
            ),
            OutputBox(
              '1 3 5 7 9\n'
              '第1个水果是苹果\n第2个水果是香蕉\n第3个水果是橘子\n'
              '小明: 85分\n小红: 92分\n小刚: 78分\n'
              '4 3 2 1 0\n1 1 3 4 5\n'
              'a b c\n1 2 3\na=1 b=2 c=3',
            ),
            DividerLine(),

            // ===== 6. while 循环 =====
            SectionHeader('6. while 循环', icon: Icons.repeat),
            Paragraph(
              'while 循环在条件为 True 时一直执行。必须确保条件最终会变为 False，'
              '否则就是无限循环。',
            ),
            CodeBlock(
              '# ===== 基本 while 循环 =====\n'
              'count = 0\n'
              'while count < 5:\n'
              '    print(count, end=" ")\n'
              '    count += 1  # ← 别忘了更新条件！\n'
              '# 输出：0 1 2 3 4\n'
              'print()\n'
              '\n'
              '# ===== while-else 模式 =====\n'
              '# else 在 while 条件变为 False 时执行\n'
              '# 如果被 break 中断，else 不执行\n'
              'n = 0\n'
              'while n < 3:\n'
              '    print(n)\n'
              '    n += 1\n'
              'else:\n'
              '    print("循环正常结束")\n'
              '# 输出：0 1 2 循环正常结束\n'
              '\n'
              '# ===== 带 break 的 while-else =====\n'
              'n = 0\n'
              'while n < 3:\n'
              '    if n == 1:\n'
              '        break\n'
              '    print(n)\n'
              '    n += 1\n'
              'else:\n'
              '    print("这行不会执行")\n'
              '# 输出：0（被 break 中断，else 不执行）\n'
              '\n'
              '# ===== while True + break 模式 =====\n'
              '# 常用于"先执行再判断"的场景\n'
              'while True:\n'
              '    cmd = input("输入命令(q退出)：")\n'
              '    if cmd == "q":\n'
              '        break\n'
              '    print(f"执行命令：{cmd}")',
              language: 'Python',
            ),
            TipBox(
              'while True + break 模式比普通 while 更常用，'
              '因为很多场景下你需要"至少执行一次"或"在中间位置判断退出"。',
              type: TipType.tip,
            ),
            OutputBox(
              '0 1 2 3 4\n0\n1\n2\n循环正常结束\n0',
            ),
            DividerLine(),

            // ===== 7. break/continue/for-else =====
            SectionHeader('7. 循环控制：break / continue / else', icon: Icons.traffic),
            Paragraph(
              'break 中断整个循环，continue 跳过本次循环。'
              'for-else 和 while-else 是 Python 独有的特性——'
              '循环正常结束（没有被 break）时执行 else。',
            ),
            CodeBlock(
              '# ===== break 示例：查找第一个偶数 =====\n'
              'numbers = [1, 3, 5, 8, 9, 10]\n'
              'for n in numbers:\n'
              '    if n % 2 == 0:\n'
              '        print(f"找到第一个偶数：{n}")\n'
              '        break\n'
              '\n'
              '# ===== continue 示例：跳过周末 =====\n'
              'days = ["周一","周二","周三","周四","周五","周六","周日"]\n'
              'for day in days:\n'
              '    if day in ["周六", "周日"]:\n'
              '        continue  # 跳过周末\n'
              '    print(f"{day}上班")\n'
              '\n'
              '# ===== for-else 实用场景：搜索 =====\n'
              '# 在列表中查找目标，找到就中断，没找到执行 else\n'
              'target = 7\n'
              'for n in [1, 2, 3, 4, 5]:\n'
              '    if n == target:\n'
              '        print(f"找到了 {target}")\n'
              '        break\n'
              'else:\n'
              '    print(f"没找到 {target}")  # 会执行这一行\n'
              '\n'
              '# ===== pass 占位符 =====\n'
              '# pass 什么都不做，作为语法占位\n'
              'if True:\n'
              '    pass  # 以后再来实现\n'
              '\n'
              'for i in range(5):\n'
              '    pass  # 循环体不能为空，用 pass 占位',
              language: 'Python',
            ),
            OutputBox(
              '找到第一个偶数：8\n'
              '周一上班\n周二上班\n周三上班\n周四上班\n周五上班\n'
              '没找到 7',
            ),
            TipBox(
              'for-else 的 else 容易让人困惑。记住：else = "没被 break 中断"。'
              '几乎只有搜索类的场景会用到 for-else，日常编码很少用。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 8. pass / del / 空语句 =====
            SectionHeader('8. pass、del 与其他控制', icon: Icons.more_horiz),
            Paragraph(
              'pass 是空语句，用作语法占位。常用于还没实现的函数、类、条件分支。'
              'del 用于删除变量或容器中的元素。',
            ),
            CodeBlock(
              '# ===== pass 的常见用途 =====\n'
              '\n'
              '# 1. 还没想好怎么写的函数\n'
              'def future_function():\n'
              '    pass  # TODO: 以后再实现\n'
              '\n'
              '# 2. 空的类定义\n'
              'class MyException(Exception):\n'
              '    pass  # 自定义异常类，暂时不需要额外方法\n'
              '\n'
              '# 3. 条件分支占位\n'
              'if condition1:\n'
              '    do_something()\n'
              'elif condition2:\n'
              '    pass  # 这个分支暂时不处理\n'
              'else:\n'
              '    print("默认处理")\n'
              '\n'
              '# ===== del 删除 =====\n'
              'x = 10\n'
              'del x  # 删除变量，之后 x 不再存在\n'
              '\n'
              'my_list = [1, 2, 3, 4, 5]\n'
              'del my_list[1]    # 删除索引1的元素 -> [1, 3, 4, 5]\n'
              'del my_list[1:3]  # 删除切片 -> [1, 5]\n'
              'print(my_list)  # [1, 5]',
              language: 'Python',
            ),
            OutputBox('[1, 5]'),
            DividerLine(),

            // ===== 交互式演示 =====
            const _IfElseDemo(),
            const _LoopDemo(),
            const _ListComprehensionDemo(),
            DividerLine(),

            // ===== 小练习 =====
            SectionHeader('✏️ 小练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: '猜数字游戏',
              description: '程序生成 1~100 的随机数，用户猜，提示"大了/小了"，猜中退出。用 while True + break 实现。',
            ),
            StepItem(
              step: 2,
              title: 'FizzBuzz 经典题',
              description: '遍历 1~50，3 的倍数打印 Fizz，5 的倍数打印 Buzz，同时是 3 和 5 的倍数打印 FizzBuzz，其他打印数字。',
            ),
            StepItem(
              step: 3,
              title: '成绩等级系统',
              description: '输入分数，用 if/elif/else 输出等级（90+ 优秀、75+ 良好、60+ 及格、<60 不及格）。处理无效输入。',
            ),
            StepItem(
              step: 4,
              title: 'enumerate + zip',
              description: '有 names=["张三","李四","王五"] 和 scores=[88, 95, 70]，用 zip 遍历并输出排名（用 enumerate 加序号）。',
            ),
            StepItem(
              step: 5,
              title: 'match-case 练习',
              description: '用 match-case 写一个"命令解析器"：输入 "add" 执行加法，"quit" 退出，其他输出"未知命令"。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
