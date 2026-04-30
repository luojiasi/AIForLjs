import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第一章：状态管理
/// 适合零基础小白，从 StatefulWidget 入手理解 Flutter 状态
/// ============================================================

// ─── 全局状态提升演示 ────────────────────────────────────────
// 父组件持有数据，通过回调传递给子组件修改 —— 状态提升
class _SharedCounterParent extends StatefulWidget {
  final Widget Function(int count, VoidCallback onIncrement, VoidCallback onDecrement, VoidCallback onReset) builder;

  const _SharedCounterParent({required this.builder});

  @override
  State<_SharedCounterParent> createState() => _SharedCounterParentState();
}

class _SharedCounterParentState extends State<_SharedCounterParent> {
  int _sharedCount = 0;

  void _increment() => setState(() => _sharedCount++);
  void _decrement() => setState(() => _sharedCount--);
  void _reset() => setState(() => _sharedCount = 0);

  @override
  Widget build(BuildContext context) {
    return widget.builder(_sharedCount, _increment, _decrement, _reset);
  }
}

// ─── Keys 演示：使用 ValueKey 区分列表项 ─────────────────────
class _KeyedItem extends StatelessWidget {
  final String label;
  final Color color;

  const _KeyedItem({required this.label, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 14, color: color)),
    );
  }
}

// ─── 主页面 ──────────────────────────────────────────────────

class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  int _count = 0;
  bool _showLifecycleTip = false;

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count--);
  void _reset() => setState(() => _count = 0);

  // ── State 生命周期演示 ──
  @override
  void initState() {
    super.initState();
    // initState: State 对象创建后调用，仅一次
    // 适合初始化控制器、监听器、动画等
    debugPrint('>> initState: State 创建，_count = $_count');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依赖的 InheritedWidget 变化时调用
    // 比如 Theme、MediaQuery 发生变化时触发
    debugPrint('>> didChangeDependencies');
  }

  @override
  void didUpdateWidget(CounterDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 父组件重建导致当前 Widget 配置更新时调用
    debugPrint('>> didUpdateWidget: 配置更新');
  }

  @override
  void dispose() {
    // dispose: State 销毁前调用，清理所有资源
    debugPrint('>> dispose: State 销毁');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第1章 · 状态管理'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 章节目录 ──
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 什么是状态（State）\n'
            '② StatefulWidget vs StatelessWidget 深度对比\n'
            '③ State 生命周期：七大阶段\n'
            '④ setState 的正确用法与常见陷阱\n'
            '⑤ 状态提升（State Lifting）模式\n'
            '⑥ Key 的作用：ValueKey / ObjectKey / UniqueKey / GlobalKey\n'
            '⑦ 计数器实战（可交互）\n'
            '⑧ 兄弟组件共享状态',
          ),
          const DividerLine(),

          // ── 1. 什么是状态 ──
          const SectionHeader('1. 什么是状态？', icon: Icons.help_outline),
          const Paragraph(
            '在 Flutter 中，「状态」就是「会变化的数据」。\n\n'
            '比如：\n'
            '• 开关是否打开 -> isSwitched: bool\n'
            '• 用户输入的文字 -> text: String\n'
            '• 下载进度 -> progress: double\n'
            '• 列表数据 -> items: List<Item>\n\n'
            '当这些数据变化时，界面需要跟着变——这就是状态管理的价值。',
          ),
          const TipBox('简单理解：状态 = 数据，状态管理 = 数据变了界面也跟着变。', type: TipType.tip),

          // ── 2. StatefulWidget vs StatelessWidget ──
          const SectionHeader('2. 两种 Widget 深度对比', icon: Icons.compare_arrows),
          const Paragraph(
            'StatelessWidget（无状态）：界面一旦创建就不会自己变化。\n'
            '适用于纯展示性组件，数据通过构造参数传入，组件自身不能修改。\n\n'
            'StatefulWidget（有状态）：界面可以随着数据变化而刷新。\n'
            '适用于交互性组件，内部维护可变状态，通过 setState 触发重绘。',
          ),
          const Paragraph('核心代码对比：'),
          const CodeBlock(
            r'''// StatelessWidget —— 静态界面，不可变
class MyText extends StatelessWidget {
  final String text;  // 数据从外面传入
  const MyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// StatefulWidget —— 动态界面，可变化
class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int count = 0;  // 内部可变数据

  void addOne() {
    setState(() => count++);  // 修改数据 + 刷新界面
  }

  @override
  Widget build(BuildContext context) { ... }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '关键区别：StatefulWidget 有 createState() 方法创建状态对象。\n'
            '数据会变 -> 用 StatefulWidget；数据不变 -> 用 StatelessWidget。',
            type: TipType.info,
          ),

          // ── 3. State 生命周期 ──
          const SectionHeader('3. State 生命周期', icon: Icons.timeline),
          const Paragraph(
            'State 对象从创建到销毁会经历一系列方法调用，理解它们至关重要：\n\n'
            '1. initState() —— State 创建后调用，仅一次。\n'
            '   适合：初始化变量、创建 AnimationController、添加监听器。\n\n'
            '2. didChangeDependencies() —— 依赖变化时调用。\n'
            '   适合：获取 InheritedWidget 中的数据（如 Theme.of(context)）。\n\n'
            '3. didUpdateWidget(oldWidget) —— 父组件重建导致配置更新时调用。\n'
            '   适合：对比新旧配置，做出响应。\n\n'
            '4. setState() —— 手动触发重建。\n'
            '   告诉 Flutter：「数据变了，请重新 build」。\n\n'
            '5. build() —— 构建界面，可被多次调用。\n'
            '   必须返回一个 Widget。不要在这里做耗时操作或调用 setState。\n\n'
            '6. deactivate() —— State 从树中移除时调用。\n\n'
            '7. dispose() —— State 永久销毁前调用。\n'
            '   必须在这里释放资源（controller、stream 等）。',
          ),
          const CodeBlock(
            r'''@override
void initState() {
  super.initState();
  // 1. 初始化数据
  _controller = AnimationController(vsync: this, duration: ...);
  // 2. 添加监听
  _controller.addListener(() { ... });
}

@override
void dispose() {
  // 必须释放资源！
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}''',
            language: 'Dart',
          ),
          const TipBox(
            '重要规则：\n'
            '• initState 中不能调用 BuildContext.dependOnInheritedWidgetOfExactType\n'
            '  （但可以在 didChangeDependencies 中调用）\n'
            '• dispose 中必须调用 super.dispose()\n'
            '• build 方法中不要调用 setState（会产生无限循环）',
            type: TipType.caution,
          ),
          // 生命周期交互提示
          GestureDetector(
            onTap: () => setState(() => _showLifecycleTip = !_showLifecycleTip),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _showLifecycleTip ? '收起生命周期调用顺序' : '点击查看生命周期调用顺序',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          if (_showLifecycleTip)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '执行顺序：\n'
                '1. Constructor (构造方法)\n'
                '2. createState()\n'
                '3. initState()\n'
                '4. didChangeDependencies()\n'
                '5. build()  ← 首次绘制\n'
                '6. [用户交互] -> setState() -> build()  ← 重绘\n'
                '7. [父组件更新] -> didUpdateWidget() -> build()\n'
                '8. dispose()  ← 销毁',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ),

          // ── 4. setState 深度剖析 ──
          const DividerLine(),
          const SectionHeader('4. setState 的正确用法', icon: Icons.refresh),
          const Paragraph(
            'setState 是 StatefulWidget 的「心脏」。它的本质是：\n'
            '「标记当前 State 为 dirty（脏），通知 Flutter 在下一次帧绘制时重新 build」。\n\n'
            '✅ 可以在 setState 中做的事：\n'
            '• 修改普通字段（int、String、bool）\n'
            '• 修改 List、Map 的引用（重新赋值）\n'
            '• 切换布尔标记\n\n'
            '❌ 不可以在 setState 中做的事：\n'
            '• 调用异步方法（setState 回调应该是同步的）\n'
            '• 触发另一个 setState（不要嵌套）\n'
            '• 在 build 方法中调用 setState（死循环）\n'
            '• 在 dispose 之后调用 setState（内存泄漏）',
          ),
          const CodeBlock(
            r'''// ✅ 正确
setState(() {
  _count = _count + 5;
});

// ✅ 正确：修改列表引用
setState(() {
  _items = List.from(_items)..add(newItem);
});

// ❌ 错误：异步操作
setState(() async {  // 不要用 async！
  _data = await fetchData();
});

// ❌ 错误：直接修改不通知
_count = 10;  // 界面不会更新！

// ✅ 正确：用 mouted 检查避免内存泄漏
if (mounted) {
  setState(() => _count = 10);
}''',
            language: 'Dart',
          ),
          const TipBox(
            '关于 mounted 属性：mounted 表示 State 对象是否还在 Widget 树中。\n'
            '在异步回调中调用 setState 之前，务必检查 mounted，否则可能报错。',
            type: TipType.warning,
          ),

          // ── 5. 状态提升 ──
          const DividerLine(),
          const SectionHeader('5. 状态提升（State Lifting）', icon: Icons.arrow_upward),
          const Paragraph(
            '当多个组件需要共享同一份状态时，把状态「提升」到它们最近的共同父组件中。\n\n'
            '模式：\n'
            '• 父组件持有状态（StatefulWidget）\n'
            '• 通过构造参数把数据传给子组件\n'
            '• 通过回调函数让子组件通知父组件修改状态\n\n'
            '这是 Flutter 中最基础、最核心的共享状态模式。',
          ),
          const CodeBlock(
            r'''// 父组件持有状态
class Parent extends StatefulWidget { ... }

class _ParentState extends State<Parent> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 通过参数传递数据
        DisplayWidget(count: _count),
        // 通过回调传递修改能力
        ControlWidget(onIncrement: _increment),
      ],
    );
  }
}

// 子组件只负责展示
class DisplayWidget extends StatelessWidget {
  final int count;
  const DisplayWidget({required this.count});
  // ...
}

// 子组件只负责触发
class ControlWidget extends StatelessWidget {
  final VoidCallback onIncrement;
  const ControlWidget({required this.onIncrement});
  // ...
}''',
            language: 'Dart',
          ),
          const TipBox(
            '状态提升的优点：数据单向流动，逻辑清晰，易于调试。\n'
            '缺点：层级过深时需要逐层传递（可用 Provider/Riverpod 解决）。',
            type: TipType.info,
          ),

          // ── 6. Key 的作用 ──
          const DividerLine(),
          const SectionHeader('6. Key —— 识别 Widget 的身份', icon: Icons.vpn_key),
          const Paragraph(
            'Key 帮助 Flutter 区分同一个位置上的不同 Widget。\n'
            '当 Widget 在同一位置重建时，Flutter 通过 key 判断是复用还是重新创建。',
          ),
          const Paragraph('四种常用 Key：'),
          const CodeBlock(
            r'''// 1. ValueKey —— 基于唯一值
ListView(
  children: items.map((item) =>
    ListTile(key: ValueKey(item.id), title: Text(item.name))
  ).toList(),
)

// 2. ObjectKey —— 基于对象
ListTile(key: ObjectKey(item), title: Text(item.name))

// 3. UniqueKey —— 每次都不同（强制重建）
AnimatedContainer(key: UniqueKey(), ...)

// 4. GlobalKey —— 全局访问 State 或元素
final globalKey = GlobalKey<FormState>();
Form(key: globalKey, ...)
// 其他地方：globalKey.currentState?.validate()''',
            language: 'Dart',
          ),
          const Paragraph('什么时候必须用 Key？'),
          const CodeBlock(
            r'''// ❌ 没有 Key：当列表顺序变化时，Flutter 会误判
Row(children: [
  _Tile(color: Colors.red, word: 'A'),
  _Tile(color: Colors.blue, word: 'B'),
  // 交换顺序后，Flutter 复用错误的对象
])

// ✅ 有 Key：Flutter 根据 key 正确匹配
Row(children: [
  _Tile(key: ValueKey('A'), color: Colors.red, word: 'A'),
  _Tile(key: ValueKey('B'), color: Colors.blue, word: 'B'),
  // 交换顺序后，元素正确对应
])''',
            language: 'Dart',
          ),
          // Key 演示示例
          const Paragraph('下面是用 ValueKey 标记的列表项，可以看到每个项都有唯一标识：'),
          _KeyedItem(label: '第 1 项：ValueKey("item_1")', color: Colors.blue),
          _KeyedItem(label: '第 2 项：ValueKey("item_2")', color: Colors.green),
          _KeyedItem(label: '第 3 项：ValueKey("item_3")', color: Colors.orange),

          // ── 7. 计数器实战 ──
          const DividerLine(),
          const SectionHeader('7. 计数器实战 —— 动手试试！', icon: Icons.build),
          const Paragraph('下面就是一个完整的计数器应用。点击按钮，数字会跟着变化。这是 Flutter 入门的第一道菜！'),
          const SizedBox(height: 8),

          // 实际运行的计数器
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('当前计数值', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '$_count',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _count > 0 ? Colors.green : (_count < 0 ? Colors.red : Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CountButton(icon: Icons.remove, onTap: _decrement, color: Colors.red),
                      const SizedBox(width: 20),
                      _CountButton(icon: Icons.refresh, onTap: _reset, color: Colors.grey),
                      const SizedBox(width: 20),
                      _CountButton(icon: Icons.add, onTap: _increment, color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutputBox(
            '当前状态: count = $_count\n'
            'count > 0 -> 绿色\n'
            'count < 0 -> 红色\n'
            '点击 + 或 - 试试效果！',
          ),

          // ── 8. 兄弟组件共享状态（状态提升实战）──
          const DividerLine(),
          const SectionHeader('8. 兄弟组件共享状态', icon: Icons.share),
          const Paragraph(
            '下面演示状态提升模式：两个子组件共享同一个计数状态。\n'
            '一个控制增减，一个显示当前值。状态由父组件统一管理。',
          ),
          _SharedCounterParent(
            builder: (count, onIncrement, onDecrement, onReset) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 显示组件 —— 纯展示
                    const Text('共享计数器', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 12),
                    // 控制组件 —— 只负责触发
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountButton(icon: Icons.remove, onTap: onDecrement, color: Colors.orange),
                        const SizedBox(width: 16),
                        _CountButton(icon: Icons.refresh, onTap: onReset, color: Colors.grey),
                        const SizedBox(width: 16),
                        _CountButton(icon: Icons.add, onTap: onIncrement, color: Colors.indigo),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Paragraph(
            '上面的代码中，_SharedCounterParent 持有 _sharedCount 状态，\n'
            '通过 builder 参数同时传给显示组件和控制组件。这就是状态提升的实战应用。',
          ),

          // ── 完整代码 ──
          const DividerLine(),
          const SectionHeader('完整代码参考', icon: Icons.code),
          const CodeBlock(
            r'''import 'package:flutter/material.dart';

class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  int _count = 0;

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count--);
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计数器')),
      body: Center(
        child: Column(
          children: [
            Text('$_count',
              style: TextStyle(fontSize: 48,
                color: _count > 0 ? Colors.green :
                       _count < 0 ? Colors.red : Colors.grey)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: _decrement, icon: Icon(Icons.remove)),
              IconButton(onPressed: _reset, icon: Icon(Icons.refresh)),
              IconButton(onPressed: _increment, icon: Icon(Icons.add)),
            ]),
          ],
        ),
      ),
    );
  }
}''',
            language: 'Dart',
          ),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('小练习', icon: Icons.edit),
          const Paragraph(
            '1. 给计数器加一个「增加 5」的按钮\n'
            '2. 让计数到 10 时显示「到达 10 啦！」\n'
            '3. 把最大值限制在 100\n'
            '4. 用状态提升实现一个「加减控制 + 百分比进度条」的组件\n'
            '5. 理解 mounted 的作用：在异步回调前检查 mounted',
          ),
          const SizedBox(height: 8),
          const TipBox('提示：可以用 if 判断来控制 _count 的值。', type: TipType.tip),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── 可复用按钮组件 ──────────────────────────────────────────

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CountButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
