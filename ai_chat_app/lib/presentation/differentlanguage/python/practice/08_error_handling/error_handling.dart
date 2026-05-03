import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// 异常模拟器：触发并捕获各种异常
class _ExceptionSimDemo extends StatefulWidget {
  const _ExceptionSimDemo();
  @override
  State<_ExceptionSimDemo> createState() => _ExceptionSimDemoState();
}

class _ExceptionSimDemoState extends State<_ExceptionSimDemo> {
  String _operation = 'divide';
  int _a = 10;
  int _b = 0;
  String _input = '123';
  bool _useFinally = true;

  String get _exceptionResult {
    switch (_operation) {
      case 'divide':
        if (_b == 0) return 'ZeroDivisionError: division by zero';
        return '结果 = ${_a ~/ _b}';
      case 'index':
        final list = [1, 2, 3];
        if (_a >= list.length || _a < 0) return 'IndexError: list index out of range';
        return '结果 = ${list[_a]}';
      case 'parse':
        final n = int.tryParse(_input);
        if (n == null) return "ValueError: invalid literal for int() with base 10: '$_input'";
        return '结果 = $n';
      case 'custom':
        if (_a < 0) return "ValueError: 自定义错误";
        return '结果 = $_a（无异常）';
      default:
        return '';
    }
  }

  bool get _hasError {
    switch (_operation) {
      case 'divide': return _b == 0;
      case 'index': return _a >= 3 || _a < 0;
      case 'parse': return int.tryParse(_input) == null;
      case 'custom': return _a < 0;
      default: return false;
    }
  }

  String get _liveCode {
    switch (_operation) {
      case 'divide':
        return 'a = $_a\nb = $_b\ntry:\n    result = a / b\n    print(f"结果 = {result}")\nexcept ZeroDivisionError as e:\n    print(f"捕获异常: {e}")${_useFinally ? '\nfinally:\n    print("finally 总会执行")' : ''}';
      case 'index':
        return 'lst = [1, 2, 3]\na = $_a\ntry:\n    result = lst[a]\n    print(f"结果 = {result}")\nexcept IndexError as e:\n    print(f"捕获异常: {e}")${_useFinally ? '\nfinally:\n    print("finally 总会执行")' : ''}';
      case 'parse':
        return 'input_str = "$_input"\ntry:\n    result = int(input_str)\n    print(f"结果 = {result}")\nexcept ValueError as e:\n    print(f"捕获异常: {e}")${_useFinally ? '\nfinally:\n    print("finally 总会执行")' : ''}';
      case 'custom':
        return 'a = $_a\ntry:\n    if a < 0:\n        raise ValueError("自定义错误")\n    print(f"结果 = {a}")\nexcept ValueError as e:\n    print(f"捕获异常: {e}")${_useFinally ? '\nfinally:\n    print("finally 总会执行")' : ''}';
      default:
        return '';
    }
  }

  String get _liveOutput {
    final result = _exceptionResult;
    final hasErr = _hasError;
    final lines = <String>[];
    if (hasErr) {
      lines.add('捕获异常: $result');
    } else {
      lines.add(result);
    }
    if (_useFinally) lines.add('finally 总会执行');
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final hasErr = _hasError;
    final tryColor = Colors.blue.shade700;
    final catchColor = Colors.red.shade700;
    final successColor = Colors.green.shade700;
    final finallyColor = Colors.orange.shade700;

    return InteractivePlayground(
      title: '🔥 异常模拟器',
      subtitle: '选择操作和参数，观察 try/except/finally 的执行流程',
      children: [
        ParamChoiceChips<String>(
          label: '操作类型',
          value: _operation,
          options: const [
            ('divide', '除法'),
            ('index', '索引'),
            ('parse', '解析'),
            ('custom', '自定义'),
          ],
          onChanged: (v) => setState(() => _operation = v),
        ),
        if (_operation == 'divide' || _operation == 'index' || _operation == 'custom')
          ParamIntSlider(
            label: 'a 的值',
            value: _a,
            min: -5,
            max: 20,
            onChanged: (v) => setState(() => _a = v),
          ),
        if (_operation == 'divide')
          ParamIntSlider(
            label: 'b 的值',
            value: _b,
            min: 0,
            max: 10,
            onChanged: (v) => setState(() => _b = v),
          ),
        if (_operation == 'parse')
          ParamTextField(
            label: 'input',
            value: _input,
            hint: '输入要解析的字符串',
            onChanged: (v) => setState(() => _input = v.isEmpty ? '' : v),
            maxLength: 10,
          ),
        ParamSwitch(
          label: '使用 finally',
          value: _useFinally,
          onChanged: (v) => setState(() => _useFinally = v),
          trueLabel: '开',
          falseLabel: '关',
        ),
        const SizedBox(height: 8),
        // 执行流程可视化
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _FlowBlock(label: 'try 块', color: tryColor, active: true),
                  const SizedBox(height: 4),
                  Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
                  const SizedBox(height: 4),
                  _FlowBlock(
                    label: hasErr ? 'except 块（捕获异常）' : '✅ 执行成功',
                    color: hasErr ? catchColor : successColor,
                    active: true,
                  ),
                  if (_useFinally) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
                    const SizedBox(height: 4),
                    _FlowBlock(label: 'finally 块（总是执行）', color: finallyColor, active: true),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_liveCode),
        LiveOutputBox(_liveOutput),
      ],
    );
  }
}

class _FlowBlock extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _FlowBlock({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? color : Colors.grey,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// 异常处理控制流演示
class _TryExceptFlowDemo extends StatefulWidget {
  const _TryExceptFlowDemo();
  @override
  State<_TryExceptFlowDemo> createState() => _TryExceptFlowDemoState();
}

class _TryExceptFlowDemoState extends State<_TryExceptFlowDemo> {
  int _scenario = 0;
  String _catchType = 'ValueError';

  bool get _isCaught {
    switch (_scenario) {
      case 0: return false; // no error
      case 1: // ValueError
        return _catchType == 'ValueError' || _catchType == 'Exception' || _catchType == 'BaseException';
      case 2: // TypeError
        return _catchType == 'TypeError' || _catchType == 'Exception' || _catchType == 'BaseException';
      case 3: // custom exception (inherits Exception)
        return _catchType == 'Exception' || _catchType == 'BaseException';
      default: return false;
    }
  }

  bool get _hasError => _scenario > 0;

  String get _scenarioName {
    switch (_scenario) {
      case 0: return '无错误';
      case 1: return 'ValueError';
      case 2: return 'TypeError';
      case 3: return '自定义异常';
      default: return '';
    }
  }

  String get _liveCode {
    final exceptionLine = _scenario == 0
        ? '    result = 10 / 2  # 正常执行'
        : _scenario == 1
            ? '    int("abc")  # 触发 ValueError'
            : _scenario == 2
                ? '    1 + "2"   # 触发 TypeError'
                : '    raise MyError("自定义错误")  # 触发自定义异常';
    return 'class MyError(Exception):\n    pass\n\ntry:\n$exceptionLine\nexcept $_catchType as e:\n    print(f"捕获: {e}")\nelse:\n    print("无异常，执行 else")\nfinally:\n    print("finally 总会执行")';
  }

  String get _liveOutput {
    final lines = <String>[];
    if (_scenario == 0) {
      lines.add('无异常，执行 else');
    } else if (_isCaught) {
      lines.add('捕获: ${_scenarioName}');
    } else {
      lines.add('未被捕获！异常向上传播...');
      lines.add('$_scenarioName: 未被 $_catchType 捕获');
    }
    lines.add('finally 总会执行');
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final haserr = _hasError;
    final caught = _isCaught;

    return InteractivePlayground(
      title: '🔀 异常处理控制流',
      subtitle: '选择场景和捕获类型，观察异常在继承体系中的传播',
      children: [
        ParamChoiceChips<int>(
          label: '场景',
          value: _scenario,
          options: const [
            (0, '无错误'),
            (1, 'ValueError'),
            (2, 'TypeError'),
            (3, '自定义错误'),
          ],
          onChanged: (v) => setState(() => _scenario = v),
        ),
        ParamChoiceChips<String>(
          label: '捕获类型',
          value: _catchType,
          options: const [
            ('ValueError', 'ValueError'),
            ('TypeError', 'TypeError'),
            ('Exception', 'Exception'),
            ('BaseException', 'BaseException'),
          ],
          onChanged: (v) => setState(() => _catchType = v),
        ),
        const SizedBox(height: 8),
        // 流程图
        Column(
          children: [
            _FlowBlock(label: 'try 块执行', color: Colors.blue.shade700, active: true),
            const SizedBox(height: 4),
            Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
            const SizedBox(height: 4),
            _FlowBlock(
              label: haserr ? '⚡ 触发 $_scenarioName' : '✅ 无异常',
              color: haserr ? Colors.red.shade700 : Colors.green.shade700,
              active: true,
            ),
            if (haserr) ...[
              const SizedBox(height: 4),
              Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
              const SizedBox(height: 4),
              _FlowBlock(
                label: caught
                    ? '✅ except $_catchType 捕获成功'
                    : '❌ $_catchType 无法捕获，异常传播',
                color: caught ? Colors.green.shade700 : Colors.red.shade700,
                active: true,
              ),
            ],
            if (!haserr) ...[
              const SizedBox(height: 4),
              Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
              const SizedBox(height: 4),
              _FlowBlock(label: 'else 块执行（仅无异常时）', color: Colors.teal.shade700, active: true),
            ],
            const SizedBox(height: 4),
            Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade500),
            const SizedBox(height: 4),
            _FlowBlock(label: 'finally 块（总是执行）', color: Colors.orange.shade700, active: true),
          ],
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_liveCode),
        LiveOutputBox(_liveOutput),
      ],
    );
  }
}

/// Python 第8章：错误、调试和测试（扩展版）
/// 涵盖：语法错误vs异常、try/except/else/finally、异常层级、
/// 自定义异常、异常链、断言、logging、上下文管理器、pdb调试、unittest测试、doctest测试
class PythonErrorHandling extends StatelessWidget {
  const PythonErrorHandling({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第8章 错误、调试和测试'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 错误分类\n'
            '② try/except 详解\n'
            '③ 多个异常捕获\n'
            '④ else 和 finally\n'
            '⑤ 异常层级体系\n'
            '⑥ 自定义异常\n'
            '⑦ 异常链（raise ... from）\n'
            '⑧ assert 断言\n'
            '⑨ logging 日志\n'
            '⑩ 上下文管理器\n'
            '⑪ pdb 调试 \n'
            '⑫ unittest 测试\n'
            '⑬ doctest 测试',
          ),
          const TipBox(
            '异常处理不是"逃避错误"，而是"优雅地处理错误"。'
            '好的程序不是不出错，而是出错时不崩溃。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 1. 错误分类 ──
          const SectionHeader('1. 语法错误 vs 运行时异常', icon: Icons.compare_arrows),
          const Paragraph(
            'Python 错误分为两大类：语法错误（SyntaxError）和运行时异常（Exception）。'
            '语法错误在代码运行前就会被 Python 发现，运行时异常在程序执行时发生。',
          ),
          const CodeBlock(
            '# ===== 语法错误 SyntaxError =====\n'
            '# 代码根本跑不了，解释器直接报错\n'
            '# print("Hello)       # ❌ 引号没配对\n'
            '# if True             # ❌ 缺少冒号\n'
            '#     print("hi")     # ❌ 缩进错误\n\n'
            '# ===== 运行时异常 Exception =====\n'
            '# 语法正确，运行时出错\n'
            'x = 10 / 0            # ZeroDivisionError\n'
            'y = int("abc")        # ValueError\n'
            'z = [1,2,3][99]       # IndexError\n'
            'd = {"a": 1}["b"]     # KeyError\n'
            'import nonexist       # ModuleNotFoundError\n\n'
            '# ===== 逻辑错误（最难找） =====\n'
            '# 代码正常运行，但结果不对\n'
            'def avg(nums):\n'
            '    return sum(nums) / len(nums)  # 如果 nums=[] 会崩溃\n'
            '# 逻辑错误靠测试和调试来发现',
            language: 'Python',
          ),
          const TipBox(
            '语法错误 IDE 会直接标红，运行前就能发现。'
            '运行时异常需要 try/except 处理。逻辑错误最难抓——需要写测试。',
            type: TipType.tip,
          ),

          // ── 2. try/except ──
          const DividerLine(),
          const SectionHeader('2. try/except —— 捕获异常', icon: Icons.network_check),
          const Paragraph(
            '把可能出错的代码放在 try 块中，在 except 块中处理错误。'
            '多个 except 可以捕获不同类型的异常。',
          ),
          const CodeBlock(
            '# ===== 基本语法 =====\n'
            'try:\n'
            '    num = int(input("请输入数字: "))\n'
            '    result = 100 / num\n'
            '    print(f"结果是: {result}")\n'
            'except ValueError:\n'
            '    print("输入的不是有效数字！")\n'
            'except ZeroDivisionError:\n'
            '    print("不能除以零！")\n\n'
            '# ===== 在一个 except 中捕获多个类型 =====\n'
            'try:\n'
            '    data = open("config.json").read()\n'
            '    config = json.loads(data)\n'
            'except (FileNotFoundError, json.JSONDecodeError) as e:\n'
            '    print(f"配置文件错误: {e}")\n\n'
            '# ===== 获取异常信息 =====\n'
            'try:\n'
            '    1 / 0\n'
            'except ZeroDivisionError as e:\n'
            '    print(f"错误类型: {type(e).__name__}")\n'
            '    print(f"错误信息: {e}")\n'
            '    print(f"错误详情: {e.args}")\n\n'
            '# ===== 捕获所有异常 =====\n'
            'try:\n'
            '    risky_operation()\n'
            'except Exception as e:          # 捕获所有 Exception 子类\n'
            '    print(f"发生了错误: {e}")\n'
            '    # 记录日志、回滚操作等',
            language: 'Python',
          ),
          const TipBox(
            '不要用裸 except:！它会捕获 SystemExit 和 KeyboardInterrupt，'
            '导致 Ctrl+C 无法停止程序。始终用 except Exception as e。',
            type: TipType.caution,
          ),

          // ── 3. else 和 finally ──
          const DividerLine(),
          const SectionHeader('3. else 和 finally', icon: Icons.more_horiz),
          const Paragraph(
            '完整的 try 结构：try → except → else → finally。'
            'else 在没有异常时执行，finally 无论如何都会执行。',
          ),
          const CodeBlock(
            '# ===== 完整结构 =====\n'
            'try:\n'
            '    file = open("data.txt", "r")\n'
            '    data = file.read()\n'
            'except FileNotFoundError:\n'
            '    print("文件不存在！")\n'
            'except PermissionError:\n'
            '    print("没有权限读取！")\n'
            'else:\n'
            '    # ✅ 没有异常时执行\n'
            '    print(f"成功读取 {len(data)} 个字符")\n'
            'finally:\n'
            '    # ✅ 总是执行（清理资源）\n'
            '    file.close()\n'
            '    print("资源已清理")\n\n'
            '# ===== finally 的重要性 =====\n'
            '# 即使 try 中有 return，finally 也会执行！\n'
            'def example():\n'
            '    try:\n'
            '        return "try"\n'
            '    finally:\n'
            '        print("finally 在 return 之前执行")\n'
            'print(example())  # finally → try\n\n'
            '# ===== 实际应用：数据库操作 =====\n'
            'cursor = db.cursor()\n'
            'try:\n'
            '    cursor.execute("SELECT ...")\n'
            '    result = cursor.fetchall()\n'
            'except DatabaseError as e:\n'
            '    db.rollback()\n'
            '    print(f"查询失败: {e}")\n'
            'else:\n'
            '    db.commit()    # 成功后提交\n'
            'finally:\n'
            '    cursor.close()  # 总是关闭游标',
            language: 'Python',
          ),
          const TipBox(
            'finally 通常用于释放资源（关闭文件、关闭数据库连接、释放锁）。'
            '有了 with 语句后，大多数 finally 可以被 with 替代。',
            type: TipType.tip,
          ),

          // ── 4. 异常层级 ──
          const DividerLine(),
          const SectionHeader('4. Python 异常层级体系', icon: Icons.account_tree),
          const Paragraph(
            'Python 的所有异常都继承自 BaseException。'
            'Exception 是所有"程序可处理错误"的基类。理解层级能帮你精确捕获。',
          ),
          const CodeBlock(
            '# Python 异常层级（部分）\n'
            '#\n'
            '# BaseException\n'
            '#  ├── SystemExit          # sys.exit() 触发\n'
            '#  ├── KeyboardInterrupt   # Ctrl+C 触发\n'
            '#  └── Exception           # 所有可处理的异常\n'
            '#       ├── ValueError     # 值错误\n'
            '#       ├── TypeError      # 类型错误\n'
            '#       ├── IndexError     # 索引越界\n'
            '#       ├── KeyError       # 字典键不存在\n'
            '#       ├── FileNotFoundError  # 文件不存在\n'
            '#       ├── ZeroDivisionError  # 除零\n'
            '#       ├── AttributeError     # 属性不存在\n'
            '#       ├── ImportError        # 导入失败\n'
            '#       ├── ModuleNotFoundError # 模块不存在\n'
            '#       └── OSError       # 操作系统错误\n'
            '#            ├── FileNotFoundError\n'
            '#            └── PermissionError\n\n'
            '# ===== 捕获子类也会捕获父类 =====\n'
            'try:\n'
            '    open("noexist.txt")\n'
            'except OSError:       # 会捕获 FileNotFoundError\n'
            '    print("文件操作失败")\n\n'
            '# ⚠️ 顺序重要：子类在前，父类在后\n'
            'try:\n'
            '    open("noexist.txt")\n'
            'except FileNotFoundError:  # ✅ 先捕获具体的\n'
            '    print("文件不存在")\n'
            'except OSError:            # ✅ 再捕获通用的\n'
            '    print("其他文件错误")',
            language: 'Python',
          ),

          // ── 5. 自定义异常 ──
          const DividerLine(),
          const SectionHeader('5. 自定义异常', icon: Icons.build),
          const Paragraph(
            '当内置异常不够用时，创建自己的异常类。只需继承 Exception，'
            '就可以像内置异常一样使用 raise、except。',
          ),
          const CodeBlock(
            '# ===== 简单的自定义异常 =====\n'
            'class BalanceError(Exception):\n'
            '    """余额不足异常"""\n'
            '    pass\n\n'
            'def withdraw(balance, amount):\n'
            '    if amount > balance:\n'
            '        raise BalanceError(f"余额不足！余额: {balance}, 需要: {amount}")\n'
            '    return balance - amount\n\n'
            'try:\n'
            '    withdraw(100, 200)\n'
            'except BalanceError as e:\n'
            '    print(e)  # 余额不足！余额: 100, 需要: 200\n\n'
            '# ===== 带属性的自定义异常 =====\n'
            'class ValidationError(Exception):\n'
            '    """数据验证错误"""\n'
            '    def __init__(self, field: str, message: str):\n'
            '        self.field = field\n'
            '        self.message = message\n'
            '        super().__init__(f"[{field}] {message}")\n\n'
            'def validate_age(age: int):\n'
            '    if age < 0:\n'
            '        raise ValidationError("age", "年龄不能为负数")\n'
            '    if age > 150:\n'
            '        raise ValidationError("age", "年龄超出合理范围")\n\n'
            'try:\n'
            '    validate_age(-5)\n'
            'except ValidationError as e:\n'
            '    print(f"字段 {e.field}: {e.message}")\n'
            '    # 字段 age: 年龄不能为负数',
            language: 'Python',
          ),
          const TipBox(
            '自定义异常的命名建议：以 Error 结尾（如 ValidationError）。'
            '只捕获你能处理的异常，其他让它继续往上抛。',
            type: TipType.tip,
          ),

          // ── 6. 异常链 ──
          const DividerLine(),
          const SectionHeader('6. 异常链（raise ... from）', icon: Icons.link),
          const Paragraph(
            '异常链保留了异常发生的完整上下文。'
            'raise ... from ... 可以把一个异常包装成另一个异常，同时保留原始异常信息。',
          ),
          const CodeBlock(
            '# ===== raise ... from 保留异常链 =====\n'
            'def process_data(filename):\n'
            '    try:\n'
            '        with open(filename) as f:\n'
            '            return parse(f.read())\n'
            '    except FileNotFoundError as e:\n'
            '        raise ValueError(f"数据处理失败: {filename}") from e\n'
            '        # ↑ 原始 FileNotFoundError 被保留为 __cause__\n\n'
            '# 异常链让调试更方便：\n'
            '# ValueError: 数据处理失败: data.txt\n'
            '#  └─ FileNotFoundError: [Errno 2] No such file or directory\n\n'
            '# ===== raise ... from None 禁用链 =====\n'
            'def safe_convert(value):\n'
            '    try:\n'
            '        return int(value)\n'
            '    except (ValueError, TypeError):\n'
            '        raise ValueError(f"无法转为整数: {value}") from None\n'
            '        # from None 隐藏内部实现细节\n\n'
            '# ===== 自动异常链 =====\n'
            '# 在 except 块中直接 raise 另一个异常会自动建立链\n'
            'try:\n'
            '    1 / 0\n'
            'except ZeroDivisionError:\n'
            '    raise RuntimeError("计算失败")  # 自动链接原始异常',
            language: 'Python',
          ),

          // ── 7. assert ──
          const DividerLine(),
          const SectionHeader('7. assert 断言', icon: Icons.verified),
          const Paragraph(
            'assert 用于调试阶段检查"不可能发生"的条件。'
            '条件为 False 时抛出 AssertionError。生产环境可以用 -O 参数关闭 assert。',
          ),
          const CodeBlock(
            '# ===== 基本语法 =====\n'
            'x = 10\n'
            'assert x > 0, f"x 应该大于0，实际是 {x}"\n\n'
            '# ===== 守卫条件 =====\n'
            'def set_age(age):\n'
            '    assert 0 <= age <= 150, f"年龄不合法: {age}"\n'
            '    print(f"年龄设置成功: {age}")\n\n'
            'set_age(25)   # ✅\n'
            '# set_age(200)  # ❌ AssertionError\n\n'
            '# ===== 函数前置条件 =====\n'
            'def divide(a, b):\n'
            '    assert b != 0, "除数不能为0"\n'
            '    return a / b\n\n'
            '# ===== assert 不是错误处理！ =====\n'
            '# ❌ 不要用 assert 检查用户输入\n'
            '# ❌ 不要用 assert 做数据验证\n'
            '# ❌ 不要用 assert 代替 if/raise\n\n'
            '# ✅ assert 的正确用途：\n'
            '# 1. 检查函数内部约束\n'
            '# 2. 测试中验证结果\n'
            '# 3. 检查"不应该发生"的条件\n\n'
            '# ===== assert vs if/raise =====\n'
            '# assert 可以关闭，if/raise 不能\n'
            '# 生产环境用 if/raise，调试用 assert',
            language: 'Python',
          ),
          const TipBox(
            '重要：assert 不是安全机制！python -O 会移除所有 assert。'
            '验证用户输入请用 if/raise，而不是 assert。',
            type: TipType.caution,
          ),

          // ── 8. logging ──
          const DividerLine(),
          const SectionHeader('8. logging —— 专业日志', icon: Icons.list_alt),
          const Paragraph(
            'print() 只适合调试，生产环境应该用 logging 模块。'
            '它支持日志级别、文件输出、格式化、按大小轮转等专业功能。',
          ),
          const CodeBlock(
            'import logging\n\n'
            '# ===== 基本配置 =====\n'
            'logging.basicConfig(\n'
            '    level=logging.INFO,           # 日志级别\n'
            '    format="%(asctime)s [%(levelname)s] %(message)s",\n'
            '    datefmt="%Y-%m-%d %H:%M:%S",\n'
            '    filename="app.log",           # 输出到文件\n'
            '    encoding="utf-8",\n'
            ')\n\n'
            '# ===== 五种日志级别 =====\n'
            'logging.debug("调试信息")      # 最详细，开发用\n'
            'logging.info("程序启动")        # 常规信息\n'
            'logging.warning("磁盘空间不足")  # 警告，不影响运行\n'
            'logging.error("数据库连接失败")  # 错误，功能受影响\n'
            'logging.critical("系统崩溃")    # 严重错误，需立即处理\n\n'
            '# ===== 捕获异常堆栈 =====\n'
            'try:\n'
            '    1 / 0\n'
            'except ZeroDivisionError:\n'
            '    logging.exception("发生除零错误")\n'
            '    # 自动记录完整的 traceback\n\n'
            '# ===== print vs logging =====\n'
            '# print: 输出到控制台，不能分级，不能持久化\n'
            '# logging: 分级控制、输出到文件/控制台、格式化、轮转',
            language: 'Python',
          ),
          const TipBox(
            '养成好习惯：用 logging 代替 print。开发时设 level=DEBUG，'
            '生产环境设 level=WARNING。错误用 logging.exception() 记录完整堆栈。',
            type: TipType.tip,
          ),

          // ── 9. 上下文管理器 ──
          const DividerLine(),
          const SectionHeader('9. 上下文管理器（__enter__/__exit__）', icon: Icons.auto_fix_high),
          const Paragraph(
            'with 语句的背后是上下文管理器协议（__enter__ 和 __exit__ 方法）。'
            '任何实现了这两个方法的对象都可以用 with 管理。',
          ),
          const CodeBlock(
            '# ===== 自定义上下文管理器 =====\n'
            'class Timer:\n'
            '    """计时器上下文管理器"""\n'
            '    def __enter__(self):\n'
            '        import time\n'
            '        self.start = time.time()\n'
            '        return self  # as 后面的变量\n\n'
            '    def __exit__(self, exc_type, exc_val, exc_tb):\n'
            '        import time\n'
            '        elapsed = time.time() - self.start\n'
            '        print(f"耗时: {elapsed:.3f}秒")\n'
            '        # 返回 False 表示不抑制异常\n'
            '        return False\n\n'
            'with Timer() as t:\n'
            '    sum(range(1000000))\n'
            '# 输出: 耗时: 0.023秒\n\n'
            '# ===== contextlib 简化 =====\n'
            'from contextlib import contextmanager\n\n'
            '@contextmanager\n'
            'def timer():\n'
            '    import time\n'
            '    start = time.time()\n'
            '    try:\n'
            '        yield          # with 块中的代码在这执行\n'
            '    finally:\n'
            '        elapsed = time.time() - start\n'
            '        print(f"耗时: {elapsed:.3f}秒")\n\n'
            'with timer():\n'
            '    sum(range(1000000))',
            language: 'Python',
          ),
          const TipBox(
            '@contextmanager 装饰器配合 yield 可以轻松创建上下文管理器。'
            'yield 前面的代码在进入 with 时执行，后面的在退出 with 时执行。',
            type: TipType.tip,
          ),

          // ── 10. pdb 调试 ──
          const DividerLine(),
          const SectionHeader('10. 调试（pdb）', icon: Icons.bug_report),
          const Paragraph(
            'pdb（Python Debugger）是 Python 内置的调试器。'
            '它可以让你在程序运行时暂停、检查变量、逐步执行代码，'
            '是排查逻辑错误的神器。',
          ),
          const CodeBlock(
            r'''# ===== pdb.set_trace() — 传统断点 =====
def divide(a, b):
    import pdb; pdb.set_trace()  # 程序运行到这行暂停
    return a / b

result = divide(10, 2)
print(result)

# 运行后在终端进入交互式调试：
# > debug_demo.py(4)divide()
# -> return a / b
# (Pdb) p a
# 10
# (Pdb) p b
# 2
# (Pdb) c
# 5.0''',
            language: 'Python',
          ),
          const TipBox(
            'pdb.set_trace() 需要在代码中 import pdb。'
            'Python 3.7+ 推荐用内置函数 breakpoint()，无需 import。',
            type: TipType.info,
          ),
          const CodeBlock(
            r'''# ===== python -m pdb — 命令行启动 =====
# 从第一行开始逐行调试
# $ python -m pdb my_script.py
# (Pdb) l      → 查看当前代码位置
# (Pdb) b 10   → 在第10行设置断点
# (Pdb) c      → 运行到断点
# (Pdb) p x    → 打印变量 x 的值

# ===== breakpoint() — Python 3.7+ =====
# 不用 import，直接调用
def calculate(values):
    total = 0
    for i, v in enumerate(values):
        breakpoint()  # 自动进入 pdb
        total += v
    return total

# 环境变量控制：
# $ PYTHONBREAKPOINT=0  → 禁用所有 breakpoint()
# $ PYTHONBREAKPOINT=ipdb.set_trace → 使用 ipdb''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''# ===== pdb 常用命令一览 =====
#
# 基本命令：
#   n (next)      → 执行下一行，不进入函数
#   s (step)      → 进入函数内部
#   c (continue)  → 继续执行到下一个断点
#   r (return)    → 执行到当前函数返回
#
# 查看信息：
#   p (print)     → 打印表达式值
#   pp            → 漂亮打印（格式化输出）
#   l (list)      → 查看当前行附近的11行代码
#   ll            → 查看当前函数的全部代码
#   w (where)     → 查看调用栈
#
# 断点管理：
#   b (break)     → 设置断点（b 10 或 b func_name）
#   b             → 列出所有断点
#   cl (clear)    → 清除断点
#
# 控制命令：
#   q (quit)      → 退出调试器
#   j (jump)      → 跳到指定行
#   ! statement   → 执行 Python 语句
#
# 帮助：
#   h (help)      → 查看帮助
#   h pdb         → pdb 完整文档''',
            language: 'Python',
          ),
          const Paragraph(
            '下面是一个完整的调试实战。假设我们需要调试一个'
            '计算平均值的函数，用 breakpoint() 在循环中暂停观察。',
          ),
          const CodeBlock(
            r'''# ===== 实战：调试平均值函数 =====
def calculate_average(numbers):
    """计算数字列表的平均值"""
    total = 0
    count = 0
    for n in numbers:
        breakpoint()  # 每轮暂停
        total += n
        count += 1
    return total / count

result = calculate_average([10, 20, 30])
print(f"平均值: {result}")

# 调试过程：
# (Pdb) p n       → 10（第一轮）
# (Pdb) p total   → 0
# (Pdb) n
# (Pdb) p total   → 10
# (Pdb) c
# (Pdb) p n       → 20（第二轮）
# (Pdb) p total   → 10
# (Pdb) n
# (Pdb) p total   → 30
# (Pdb) c''',
            language: 'Python',
          ),
          const OutputBox(
            r'''$ python average_demo.py
> average_demo.py(7)calculate_average()
-> total += n
(Pdb) p n
10
(Pdb) c
> average_demo.py(7)calculate_average()
-> total += n
(Pdb) p n
20
(Pdb) c
> average_demo.py(7)calculate_average()
-> total += n
(Pdb) p n
30
(Pdb) c
平均值: 20.0''',
          ),
          const TipBox(
            '熟练使用 pdb 可以大幅提升调试效率。记住最常用的三个命令：'
            'n（下一行）、p（打印变量）、c（继续运行）。',
            type: TipType.tip,
          ),

          // ── 11. unittest 测试 ──
          const DividerLine(),
          const SectionHeader('11. 单元测试（unittest）', icon: Icons.check_circle),
          const Paragraph(
            '单元测试是保证代码质量的核心手段。Python 内置的 unittest 模块提供了'
            '完整的测试框架：测试用例、测试套件、断言方法、测试夹具等。',
          ),
          const CodeBlock(
            r'''import unittest

# ===== 基本的测试用例 =====
def add(a, b):
    """两数相加"""
    return a + b

class TestMathFunctions(unittest.TestCase):
    """数学函数测试"""

    def test_add_positive(self):
        """测试正数相加"""
        self.assertEqual(add(1, 2), 3)
        self.assertEqual(add(10, 20), 30)

    def test_add_negative(self):
        """测试负数相加"""
        self.assertEqual(add(-1, 1), 0)
        self.assertEqual(add(-1, -1), -2)

    def test_add_zero(self):
        """测试与零相加"""
        self.assertEqual(add(0, 0), 0)
        self.assertEqual(add(5, 0), 5)

if __name__ == "__main__":
    unittest.main()''',
            language: 'Python',
          ),
          const TipBox(
            '测试方法名必须以 test_ 开头，unittest 会自动发现并运行。'
            '每个 test_ 方法之间相互独立，互不影响。',
            type: TipType.info,
          ),
          const Paragraph(
            'unittest 提供了丰富的断言方法，用于验证各种条件。'
            '选择合适的断言方法能让测试失败时提供更清晰的错误信息。',
          ),
          const CodeBlock(
            r'''# ===== 常用断言方法一览 =====
class TestAssertMethods(unittest.TestCase):
    """断言方法演示"""

    def test_equality(self):
        """相等性断言"""
        self.assertEqual(2 + 2, 4)
        self.assertNotEqual(2 + 2, 5)

    def test_boolean(self):
        """布尔值断言"""
        self.assertTrue(True)
        self.assertFalse(False)
        self.assertTrue(1)         # 非零为真
        self.assertFalse(0)        # 零为假
        self.assertTrue("hello")   # 非空为真
        self.assertFalse("")       # 空为假

    def test_collection(self):
        """集合断言"""
        self.assertIn(3, [1, 2, 3, 4])
        self.assertNotIn(10, [1, 2, 3])
        self.assertIsInstance("hello", str)
        self.assertIsNone(None)
        self.assertIsNotNone(42)

    def test_identity(self):
        """对象身份断言"""
        a = [1, 2, 3]
        b = a
        c = [1, 2, 3]
        self.assertIs(a, b)        # a is b
        self.assertIsNot(a, c)     # a is not c''',
            language: 'Python',
          ),
          const Paragraph(
            '使用 assertRaises 可以验证代码是否抛出预期异常。'
            'setUp 和 tearDown 用于在每个测试前后执行准备和清理工作。',
          ),
          const CodeBlock(
            r'''# ===== 测试异常 =====
def divide(a, b):
    """安全除法"""
    if b == 0:
        raise ValueError("除数不能为0")
    if not isinstance(a, (int, float)):
        raise TypeError("参数必须是数字")
    return a / b

class TestDivision(unittest.TestCase):
    """除法函数测试"""

    def test_normal(self):
        """正常除法"""
        self.assertEqual(divide(10, 2), 5)
        self.assertAlmostEqual(divide(7, 3), 2.333, places=3)

    def test_divide_by_zero(self):
        """除零异常"""
        with self.assertRaises(ValueError):
            divide(10, 0)
        # 也可以检查异常消息
        with self.assertRaises(ValueError) as ctx:
            divide(10, 0)
        self.assertEqual(str(ctx.exception), "除数不能为0")

    def test_wrong_type(self):
        """类型错误"""
        with self.assertRaises(TypeError):
            divide("abc", 2)''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''# ===== setUp / tearDown =====
# 每个测试方法前执行 setUp，之后执行 tearDown
import tempfile
import os

class TestFileOperations(unittest.TestCase):
    """文件操作测试"""

    def setUp(self):
        """每个测试前创建临时文件"""
        self.temp_file = tempfile.NamedTemporaryFile(
            mode="w", delete=False, suffix=".txt"
        )
        self.temp_file.write("Hello, World!")
        self.temp_file.close()

    def tearDown(self):
        """每个测试后删除临时文件"""
        os.unlink(self.temp_file.name)

    def test_read_file(self):
        """测试读取文件"""
        with open(self.temp_file.name, "r") as f:
            content = f.read()
        self.assertEqual(content, "Hello, World!")

    def test_file_exists(self):
        """测试文件存在"""
        self.assertTrue(os.path.exists(self.temp_file.name))

# ===== setUpClass / tearDownClass =====
# 在整个类运行前/后各执行一次
class TestDatabase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """所有测试前连接数据库"""
        cls.connection = {"connected": True}

    @classmethod
    def tearDownClass(cls):
        """所有测试后关闭连接"""
        cls.connection = None

    def test_connection(self):
        """测试连接状态"""
        self.assertTrue(self.connection["connected"])''',
            language: 'Python',
          ),
          const Paragraph(
            'unittest 支持多种运行方式，方便集成到不同开发流程中。'
            '最常用的是自动发现模式，它会递归查找项目中所有测试文件。',
          ),
          const CodeBlock(
            r'''# ===== 运行测试的多种方式 =====
# 1. 直接运行（需要 if __name__ == "__main__"）
#    python test_math.py

# 2. 使用 unittest 模块运行
#    python -m unittest test_math
#    python -m unittest -v test_math     # 详细输出

# 3. 运行特定的测试类或方法
#    python -m unittest test_math.TestMathFunctions
#    python -m unittest test_math.TestMathFunctions.test_add

# 4. 自动发现测试（最常用）
#    python -m unittest discover
#    python -m unittest discover -v
#    python -m unittest discover -p "test_*.py"
#    python -m unittest discover -s tests

# 5. 测试结果示例
# $ python -m unittest -v test_math.py
# test_add_positive (test_math.TestMathFunctions) ... ok
# test_add_negative (test_math.TestMathFunctions) ... ok
# ----------------------------------------------------------------
# Ran 2 tests in 0.002s
# OK''',
            language: 'Python',
          ),
          const OutputBox(
            r'''$ python -m unittest -v test_math.py
test_add_negative (test_math.TestMathFunctions) ... ok
test_add_positive (test_math.TestMathFunctions) ... ok
test_add_zero (test_math.TestMathFunctions) ... ok
test_normal (test_math.TestDivision) ... ok
test_divide_by_zero (test_math.TestDivision) ... ok
test_wrong_type (test_math.TestDivision) ... ok
test_read_file (test_math.TestFileOperations) ... ok
test_file_exists (test_math.TestFileOperations) ... ok
test_connection (test_math.TestDatabase) ... ok
------------------------------------------------------------------
Ran 9 tests in 0.004s

OK''',
          ),
          const TipBox(
            '推荐的项目结构：tests/ 目录下放所有测试文件，'
            '文件名以 test_ 开头。运行 python -m unittest discover 即可自动运行。',
            type: TipType.tip,
          ),

          // ── 12. doctest 测试 ──
          const DividerLine(),
          const SectionHeader('12. 文档测试（doctest）', icon: Icons.description),
          const Paragraph(
            'doctest 是 Python 内置的轻量级测试工具。它允许在 docstring 中'
            '编写示例代码，并把这些示例当作测试用例运行。一举两得：既是文档又是测试。',
          ),
          const CodeBlock(
            r'''# ===== doctest 基本语法 =====
def add(a, b):
    """返回两个数的和。

    >>> add(1, 2)
    3
    >>> add(-1, 1)
    0
    >>> add(0, 0)
    0
    >>> add(2.5, 3.5)
    6.0
    """
    return a + b

def multiply(a, b):
    """返回两数乘积。

    >>> multiply(3, 4)
    12
    >>> multiply(-2, 3)
    -6
    >>> multiply(0, 100)
    0
    """
    return a * b''',
            language: 'Python',
          ),
          const Paragraph(
            '运行 doctest 非常简单。只需在文件末尾添加两行代码，'
            '或者通过命令行执行。默认无输出表示全部通过。',
          ),
          const CodeBlock(
            r'''# ===== 运行 doctest =====
# 方式一：文件末尾添加（推荐）
if __name__ == "__main__":
    import doctest
    doctest.testmod()         # 无输出 = 全部通过
    # doctest.testmod(verbose=True)  # 显示详细信息

# 方式二：命令行运行
# $ python -m doctest example.py       # 无输出 = 通过
# $ python -m doctest -v example.py    # 详细输出

# 方式三：测试其他模块或文档文件
# import doctest
# import mymodule
# doctest.testmod(mymodule)           # 测试指定模块
# doctest.testfile("README.rst")      # 测试文档文件

# ===== 详细输出示例 =====
# $ python -m doctest -v example.py
# Trying:
#     add(1, 2)
# Expecting:
#     3
# ok
# 2 passed and 0 failed.
# Test passed.''',
            language: 'Python',
          ),
          const Paragraph(
            'doctest 也能测试异常抛出。只需在 docstring 中写出期望的异常信息，'
            '它就会自动验证是否抛出了对应的异常。',
          ),
          const CodeBlock(
            r'''# ===== 测试异常 =====
def divide(a, b):
    """安全的除法函数。

    >>> divide(10, 2)
    5.0
    >>> divide(7, 2)
    3.5
    >>> divide(10, 0)
    Traceback (most recent call last):
    ValueError: 除数不能为0
    """
    if b == 0:
        raise ValueError("除数不能为0")
    return a / b

# 异常格式说明：
# 第一行必须写 Traceback (most recent call last):
# 最后一行写 异常类型: 消息
# 中间内容可以用 ... 省略

# ===== 可选配置：ELLIPSIS =====
# 使用 ELLIPSIS 标志后，... 可以匹配任意内容
"""
    >>> import doctest
    >>> doctest.ELLIPSIS  # doctest: +ELLIPSIS
    <doctest.EL...S 1>
"""''',
            language: 'Python',
          ),
          const TipBox(
            'doctest 适合简单函数的文档示例。'
            '复杂逻辑或需要 setUp/tearDown 的场景请用 unittest 或 pytest。',
            type: TipType.info,
          ),
          const Paragraph(
            '使用 doctest 时需要注意一些常见陷阱，'
            '避免因为格式问题导致测试意外失败。',
          ),
          const CodeBlock(
            r'''# ===== doctest 常见陷阱 =====
# 1. 浮点数精度问题
#    >>> 0.1 + 0.2
#    0.30000000000000004  # ❌ 不精确
#    >>> round(0.1 + 0.2, 1)
#    0.3  # ✅ 手动舍入

# 2. 字典/集合顺序不确定
#    >>> {"b": 1, "a": 2}        # ❌ 顺序可能不同
#    >>> sorted({"b": 1, "a": 2}.items())
#    [('a', 2), ('b', 1)]        # ✅ 排序后比较

# 3. 空白字符敏感
#    >>> print("hello")
#    hello
#    >>> print("hi")
#    hi

# ===== 最佳实践 =====
# ✅ 适合：纯函数、数学计算、字符串处理
# ✅ 适合：作为 API 文档中的示例
# ❌ 不适合：依赖外部状态（文件、网络、数据库）
# ❌ 不适合：有随机输出的函数
# ❌ 不适合：需要复杂 fixture 的场景

# ===== 三种测试工具的选择 =====
# unittest  → 正式、全面的测试（最常用）
# doctest   → 轻量、文档即测试（适合简单函数）
# pytest    → 第三方库，功能最强大''',
            language: 'Python',
          ),
          const OutputBox(
            r'''$ python -m doctest -v example.py
Trying:
    add(1, 2)
Expecting:
    3
ok
Trying:
    add(-1, 1)
Expecting:
    0
ok
Trying:
    divide(10, 0)
Expecting:
    Traceback (most recent call last):
    ValueError: 除数不能为0
ok
4 passed and 0 failed.
Test passed.''',
          ),

          const _ExceptionSimDemo(),
          const _TryExceptFlowDemo(),
          const DividerLine(),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const StepItem(step: 1, title: '安全除法', description: '写一个 safe_divide(a, b) 函数，捕获除零异常并返回友好的错误提示。'),
          const StepItem(step: 2, title: '自定义异常', description: '创建 TooYoungError 和 TooOldError，在 set_age() 中根据年龄抛出相应异常。'),
          const StepItem(step: 3, title: '异常链', description: '读取文件时捕获 FileNotFoundError，包装为 DataLoadError（自定义），用 raise ... from 保留链。'),
          const StepItem(step: 4, title: 'Logger 封装', description: '配置一个 logging 记录器，同时输出到控制台和文件，支持不同级别。'),
          const StepItem(step: 5, title: '上下文管理器', description: '用 @contextmanager 创建一个 open_file 上下文管理器，打开文件并在退出时自动关闭。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
