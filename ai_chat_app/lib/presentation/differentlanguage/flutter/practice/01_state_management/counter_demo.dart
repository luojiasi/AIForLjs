import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第一章：状态管理 (State Management)
/// 从零基础小白到深入理解 Flutter 状态管理的完整教程
/// 涵盖：setState, StatefulWidget, 状态提升, Key, InheritedWidget
/// ============================================================

// ─── 全局状态提升演示 ────────────────────────────────────────
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
  Widget build(BuildContext context) => widget.builder(_sharedCount, _increment, _decrement, _reset);
}

// ─── Keys 演示：使用 ValueKey 区分列表项 ─────────────────────
class _KeyedItem extends StatelessWidget {
  final String label;
  final Color color;
  const _KeyedItem({required this.label, required this.color});
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

// ─── 演示用列表项（带 Key）────────────────────────────────
class _DemoListItem extends StatefulWidget {
  final String id;
  final String title;
  const _DemoListItem({required this.id, required this.title, super.key});
  @override
  State<_DemoListItem> createState() => _DemoListItemState();
}

class _DemoListItemState extends State<_DemoListItem> {
  int _localCount = 0;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(widget.id)),
      title: Text(widget.title),
      subtitle: Text('本地计数: $_localCount (此状态绑定到此 Key)'),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => setState(() => _localCount++),
      ),
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
  // ═══════════════════════════════════════════════════
  // 状态变量声明区域
  // ═══════════════════════════════════════════════════
  int _count = 0;
  bool _showLifecycleTip = false;
  bool _isSwitched = false;
  Color _selectedColor = Colors.blue;
  List<String> _todoItems = ['学Flutter', '写Demo', '理解状态管理'];
  String _newTodoText = '';
  List<_DemoListItemData> _keyDemoItems = [
    _DemoListItemData(id: 'A', title: '苹果'),
    _DemoListItemData(id: 'B', title: '香蕉'),
    _DemoListItemData(id: 'C', title: '橙子'),
  ];
  int _globalKeyDemoCount = 0;
  final GlobalKey<_GlobalKeyChildState> _globalChildKey = GlobalKey();

  // ── 方法定义 ──
  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count--);
  void _reset() => setState(() => _count = 0);
  void _increment5() => setState(() => _count += 5);
  void _toggleSwitch(bool v) => setState(() => _isSwitched = v);
  void _addTodo() {
    if (_newTodoText.trim().isNotEmpty) {
      setState(() {
        _todoItems.add(_newTodoText.trim());
        _newTodoText = '';
      });
    }
  }
  void _removeTodo(int index) => setState(() => _todoItems.removeAt(index));
  void _shuffleKeys() => setState(() { _keyDemoItems.shuffle(); });
  void _callGlobalKeyChild() {
    _globalChildKey.currentState?.increment();
    setState(() { _globalKeyDemoCount = _globalChildKey.currentState?.count ?? 0; });
  }

  // ── State 生命周期演示 ──
  @override
  void initState() {
    super.initState();
    debugPrint('>> initState: State 创建，_count = $_count');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('>> didChangeDependencies');
  }

  @override
  void didUpdateWidget(CounterDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('>> didUpdateWidget: 配置更新');
  }

  @override
  void dispose() {
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
          // ═══════════════════════════════════════════
          // 章节目录
          // ═══════════════════════════════════════════
          const SectionHeader('本章内容导航', icon: Icons.list),
          const Paragraph(
            '① 什么是状态？数据与界面的关系\n'
            '② StatelessWidget vs StatefulWidget 深度对比\n'
            '③ State 生命周期：从出生到销毁的完整流程\n'
            '④ setState 内部原理与正确用法\n'
            '⑤ 状态提升（State Lifting）设计模式\n'
            '⑥ Key 系统完全指南：ValueKey / ObjectKey / UniqueKey / GlobalKey\n'
            '⑦ InheritedWidget：跨层级数据共享\n'
            '⑧ 交互实战：计数器 / 开关 / 列表管理 / 颜色选择器\n'
            '⑨ 常见错误与调试技巧\n'
            '⑩ 从 setState 到 Provider 的进阶之路',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════════
          // 1. 什么是状态？
          // ═══════════════════════════════════════════
          const SectionHeader('1. 什么是状态（State）？', icon: Icons.help_outline),
          const Paragraph(
            '在 Flutter 中，「状态」就是「会随着时间变化的数据」。\n'
            '当数据发生变化时，界面需要跟着更新——这就是状态管理的核心价值。\n\n'
            '📌 重要的认知转变：\n'
            'Flutter 是声明式 UI 框架。你不直接操作 UI（像 jQuery 那样），而是：\n'
            '① 声明界面应该长什么样（build 方法）\n'
            '② 修改数据（状态）\n'
            '③ Flutter 自动比较新旧界面，高效更新差异部分\n\n'
            '这个模式叫：UI = f(state) —— 界面是状态的函数。',
          ),
          const Paragraph(
            '🔹 状态的三种级别：\n\n'
            '① 局部状态（Ephemeral State / UI State）\n'
            '   • 只属于单个 Widget，不需要与其他组件共享\n'
            '   • 例如：当前页面滚动位置、动画进度、Tab 选中索引\n'
            '   • 管理方式：setState + StatefulWidget\n\n'
            '② 共享状态（Shared State / App State）\n'
            '   • 多个 Widget 需要访问和修改同一份数据\n'
            '   • 例如：用户登录信息、购物车数据、主题偏好\n'
            '   • 管理方式：Provider / Riverpod / BLoC\n\n'
            '③ 全局状态（Global State）\n'
            '   • 整个应用生命周期内存在的数据\n'
            '   • 例如：数据库连接、网络客户端实例\n'
            '   • 管理方式：单例模式 + 依赖注入',
          ),
          const Paragraph(
            '🔹 状态的具体例子：\n'
            '• bool isDarkMode —— 当前是否为暗黑模式\n'
            '• String userName —— 当前用户名\n'
            '• int selectedIndex —— BottomNavigationBar 选中的索引\n'
            '• List<Message> messages —— 聊天消息列表\n'
            '• double downloadProgress —— 文件下载进度\n'
            '• Color themeColor —— 主题色\n\n'
            '这些数据的共同特点：会随时间改变，改变后界面需要更新。',
          ),
          const TipBox(
            '简单理解：状态 = 会变的数据，状态管理 = 数据变了界面自动跟着变。\n'
            'Flutter 的核心理念：UI = f(state)，同样的状态永远产生同样的界面。',
            type: TipType.tip,
          ),
          const CodeBlock(
            r'''// 状态 vs 非状态
// 这是「状态」——会变化
int counter = 0;           // 用户点击后改变
bool isLoggedIn = false;   // 登录后变为 true
String searchQuery = '';   // 用户输入后改变

// 这不是「状态」——固定不变（或通过构造参数传入后不变）
const title = '我的应用';     // 常量
final screenWidth = 1920.0;  // 只读（从 MediaQuery 获取后不变）''',
            language: 'Dart',
          ),

          // ═══════════════════════════════════════════
          // 2. StatefulWidget vs StatelessWidget
          // ═══════════════════════════════════════════
          const SectionHeader('2. 两种 Widget 深度对比', icon: Icons.compare_arrows),
          const Paragraph(
            'Flutter 中最核心的两个类：\n\n'
            '🔹 StatelessWidget（无状态组件）\n'
            '   • 没有内部可变状态\n'
            '   • 所有属性通过构造参数传入，使用 final 修饰\n'
            '   • 界面创建后不会自己改变（只能通过父组件重建来更新）\n'
            '   • 适合：纯展示组件、图标、静态文本、固定布局\n\n'
            '🔸 StatefulWidget（有状态组件）\n'
            '   • 拥有内部可变状态（State 对象）\n'
            '   • 通过 setState() 通知 Flutter 重建界面\n'
            '   • 拥有完整的生命周期方法\n'
            '   • 适合：交互组件、表单、动画、需要响应用户操作的组件',
          ),
          const Paragraph(
            '🔹 Widget 的不可变性（Immutability）：\n\n'
            'Flutter 中所有 Widget 都是不可变的（immutable）。这意味着：\n'
            '• Widget 的所有属性必须用 final 声明\n'
            '• 一旦创建就不能修改其属性\n'
            '• 需要改变界面时，是「创建一个新的 Widget 配置」而不是修改旧的\n\n'
            '为什么设计成不可变？\n'
            '① 安全 —— 同样的配置永远产生同样的渲染结果，可预测\n'
            '② 高效 —— Flutter 可以快速比较新旧 Widget（通过 runtimeType + key）\n'
            '③ 可缓存 —— 不可变对象可以被安全地缓存和复用\n'
            '④ 声明式 —— 你只需要声明「我想要什么」，Flutter 处理「怎么做到」',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// StatelessWidget —— 无状态，不可变
// ═══════════════════════════════════════
class GreetingCard extends StatelessWidget {
  // 所有属性都是 final
  final String name;
  final Color color;
  final double fontSize;

  // const 构造函数（编译时常量，性能更好）
  const GreetingCard({
    super.key,           // Key：每个 Widget 都可以接收 key
    required this.name,  // required：必须传入
    this.color = Colors.blue,  // 默认值
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    // build 方法：根据当前属性构建界面
    // 这些属性不会自己改变——只有父组件传入新值时才会更新
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Hello, $name!',
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}
// 使用：const GreetingCard(name: 'Flutter', color: Colors.green)

// ═══════════════════════════════════════
// StatefulWidget —— 有状态，可变
// ═══════════════════════════════════════
class CounterWidget extends StatefulWidget {
  final String label;  // 配置属性（不可变部分）
  final int initialValue;

  const CounterWidget({
    super.key,
    this.label = '计数器',
    this.initialValue = 0,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
  // createState() 在 Widget 插入树时被调用，创建 State 对象
  // 之后 Widget 可能被重建，但 State 对象会被复用
}

class _CounterWidgetState extends State<CounterWidget> {
  // State 对象持有可变数据
  late int _value;  // late：在 initState 中初始化

  @override
  void initState() {
    super.initState();
    // 从 Widget 读取初始值
    _value = widget.initialValue;
    // widget 属性自动指向当前关联的 Widget 实例
  }

  void _increment() {
    setState(() {
      _value++;  // 修改状态
    });
    // setState 做两件事：
    // 1. 执行回调中的代码（修改数据）
    // 2. 标记当前 State 为 dirty，触发 build() 重新执行
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${widget.label}: $_value'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('+1'),
        ),
      ],
    );
  }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '🔹 Widget 和 State 的分离设计：\n\n'
            'Flutter 把「配置」和「状态」分离成两个对象——这是非常精妙的设计：\n'
            '• Widget（配置）：轻量、不可变、可频繁创建销毁、只描述界面\n'
            '• State（状态）：持有可变数据、有生命周期、被框架管理复用\n\n'
            '当父组件重建时：\n'
            '① Flutter 创建新的 Widget 实例（新的配置）\n'
            '② 比较新旧 Widget 的 runtimeType 和 key\n'
            '③ 相同 → 复用旧的 State 对象，调用 didUpdateWidget(newWidget)\n'
            '④ 不同 → 销毁旧 State，创建新 State，调用 initState\n\n'
            '这就是为什么 Widget 可以频繁创建而不会丢失状态——状态存在 State 对象里。',
          ),
          const TipBox(
            '关键区别记忆方法：\n'
            '• StatelessWidget：出生即定型，一生不变（除非父组件给新参数）\n'
            '• StatefulWidget：有内在状态，可以通过 setState 自我更新\n'
            '• 选择法则：数据会不会自己变？不会→Stateless，会→Stateful',
            type: TipType.info,
          ),

          // ═══════════════════════════════════════════
          // 3. State 生命周期
          // ═══════════════════════════════════════════
          const SectionHeader('3. State 生命周期 —— 从出生到销毁', icon: Icons.timeline),
          const Paragraph(
            '每个 StatefulWidget 的 State 对象都会经历一系列生命周期方法。理解它们的调用时机和用途，是 Flutter 开发的基础功。\n\n'
            '🔹 完整生命周期流程：\n'
            '① 构造函数 Constructor —— Widget 实例创建\n'
            '② createState() —— 创建 State 对象\n'
            '③ initState() —— State 初始化（只一次）\n'
            '④ didChangeDependencies() —— 依赖就绪 / 依赖变化\n'
            '⑤ build() —— 构建界面（可多次调用）\n'
            '⑥ didUpdateWidget() —— 父组件更新配置\n'
            '⑦ setState() —— 手动触发重建\n'
            '⑧ deactivate() —— 临时从树中移除\n'
            '⑨ dispose() —— 永久销毁',
          ),
          const Paragraph(
            '🔹 各阶段详解：\n\n'
            '📌 initState() —— 出生时刻\n'
            '  触发：State 对象创建后，仅调用一次\n'
            '  ✅ 可以：初始化变量、创建 AnimationController、添加监听器、\n'
            '           初始化 TextEditingController、订阅 Stream\n'
            '  ❌ 禁止：调用 BuildContext.dependOnInheritedWidgetOfExactType\n'
            '           （此时 context 还没完全就绪）\n'
            '  ❌ 禁止：调用 setState（State 还没准备好）\n'
            '  ⚠️ 必须：调用 super.initState()（否则崩溃！）\n\n'
            '📌 didChangeDependencies() —— 依赖就绪\n'
            '  触发：initState 后立即调用，以及依赖的 InheritedWidget 变化时\n'
            '  ✅ 可以：安全使用 Theme.of(context)、MediaQuery.of(context)\n'
            '  ⚠️ 注意：可能被多次调用，不要放一次性初始化逻辑\n\n'
            '📌 build() —— 界面构建\n'
            '  触发：initState 后、setState 后、didUpdateWidget 后、\n'
            '        依赖的 InheritedWidget 变化时\n'
            '  ✅ 可以：纯构建 Widget 树\n'
            '  ❌ 禁止：调用 setState（死循环！）\n'
            '  ❌ 禁止：网络请求、耗时计算（会掉帧）\n'
            '  ⚠️ 原则：必须是纯函数——相同状态产生相同 UI\n\n'
            '📌 didUpdateWidget(oldWidget) —— 配置更新\n'
            '  触发：父组件重建，当前 Widget 被复用（类型+key 都没变）时\n'
            '  ✅ 可以：比较 widget.xxx 和 oldWidget.xxx，响应参数变化\n'
            '  ⚠️ 注意：执行在 build 之前，不需要手动 setState\n\n'
            '📌 dispose() —— 销毁\n'
            '  触发：State 永久从树中移除时，仅一次\n'
            '  ✅ 必须：释放所有资源！\n'
            '    • AnimationController.dispose()\n'
            '    • TextEditingController.dispose()\n'
            '    • FocusNode.dispose()\n'
            '    • StreamSubscription.cancel()\n'
            '    • Timer.cancel()\n'
            '    • removeListener 清理所有监听\n'
            '  ⚠️ 原则：initState 创建了什么，dispose 就释放什么\n'
            '  ⚠️ 最后一步：super.dispose()',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// 完整的生命周期使用模板
// ═══════════════════════════════════════
class _MyPageState extends State<MyPage> {
  // 1. 声明变量（不需要在 initState 中初始化的）
  int _counter = 0;

  // 2. 声明需要延迟初始化的资源
  late final AnimationController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();  // ⚠️ 必须第一行！

    // 创建需要 vsync 的资源
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // 创建控制器
    _textController = TextEditingController();

    // 添加监听
    _textController.addListener(_onTextChanged);

    // 首次构建后执行的操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 此时 build 已完成，可以安全获取尺寸等信息
      final size = context.size;  // 安全！
    });
  }

  void _onTextChanged() {
    // TextEditingController 的监听回调
    print('文本变化: ${_textController.text}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 安全获取主题、MediaQuery 等
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    // 注意：可能多次调用！
  }

  @override
  void didUpdateWidget(MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 响应父组件传入的新参数
    if (widget.userId != oldWidget.userId) {
      _loadUserData(widget.userId);  // 重新加载数据
    }
  }

  @override
  Widget build(BuildContext context) {
    // 纯函数：只根据当前状态构建 Widget 树
    return Scaffold(
      body: Center(
        child: Text('Count: $_counter'),
      ),
    );
  }

  @override
  void dispose() {
    // 释放所有资源！顺序：先子后父
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _controller.dispose();
    super.dispose();  // ⚠️ 必须最后一行！
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '生命周期记忆口诀：\n'
            '出生(initState) → 依赖就绪(didChangeDependencies) → 盖房子(build)\n'
            '→ 翻新(didUpdateWidget/setState→build) → 搬家(deactivate)\n'
            '→ 拆房子(dispose)。initState 创建什么，dispose 释放什么。',
            type: TipType.info,
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
                '完整执行顺序：\n'
                '1. Constructor (Widget 构造方法)\n'
                '2. createState() → 创建 State 对象\n'
                '3. initState() → State 初始化（仅一次）\n'
                '4. didChangeDependencies() → 依赖就绪\n'
                '5. build() ← 首次绘制界面\n'
                '6. [用户交互] → setState() → build() ← 重绘\n'
                '7. [父组件更新] → didUpdateWidget() → build()\n'
                '8. [InheritedWidget 变化] → didChangeDependencies() → build()\n'
                '9. [热重载] → reassemble() → build()\n'
                '10. deactivate() → 从树中移除（可能重新插入）\n'
                '11. dispose() ← 永久销毁',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ),

          // ═══════════════════════════════════════════
          // 4. setState 深度剖析
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('4. setState 内部原理与正确用法', icon: Icons.refresh),
          const Paragraph(
            'setState 是 StatefulWidget 的「心脏」。每次调用 setState，你都在告诉 Flutter：\n'
            '"我改了一些数据，请重新构建这个 Widget 的界面。"\n\n'
            '🔹 setState 内部做了什么？\n'
            '① 执行你传入的回调函数（修改数据）\n'
            '② 将当前 State 对应的 Element 标记为 "dirty"（需要重建）\n'
            '③ 在下一个 VSync 信号到来时，调用 build() 重建界面\n'
            '④ Flutter 比较新旧 Widget 树（diff），只更新变化的部分\n'
            '⑤ 把变化的部分通过 RenderObject 绘制到屏幕上\n\n'
            '关键理解：setState 不是立即刷新界面！它只是「标记脏」，\n'
            '真正的重绘发生在下一帧（约 16ms 后，60fps）。',
          ),
          const Paragraph(
            '🔹 setState 的回调函数：\n'
            '• 回调函数必须是同步的（不要用 async/await）\n'
            '• 回调函数中只修改数据，不要做耗时操作\n'
            '• 多个 setState 在同一帧内会被合并为一次 build\n'
            '• 如果数据没变，Flutter 不会做无谓的重绘（const 子树不重建）',
          ),
          const Paragraph(
            '🔹 mounted 属性详解：\n\n'
            'mounted 是一个 bool 值，表示 State 对象是否还在 Widget 树中：\n'
            '• initState() 之后 → mounted = true\n'
            '• dispose() 调用之后 → mounted = false\n'
            '• 在异步回调中调用 setState 之前，必须检查 mounted\n'
            '• mounted 为 false 时调用 setState 会抛出异常\n\n'
            '为什么需要 mounted？\n'
            '用户可能在异步操作完成前已经离开了当前页面（比如按了返回键）。\n'
            '此时 State 已经被 dispose，但你异步回调还在尝试 setState——\n'
            '这就是 Flutter 最常见的崩溃原因之一。',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// setState 的正确和错误用法
// ═══════════════════════════════════════

// ✅ 正确：基本用法
void _onPressed() {
  setState(() {
    _count++;
    _name = 'Flutter';
    _isLoading = false;
  });
  // 可以在一次 setState 中修改多个变量
}

// ✅ 正确：条件 setState
void _conditionalUpdate() {
  if (_count < 100) {
    setState(() => _count++);
  }
}

// ✅ 正确：异步回调中检查 mounted
Future<void> _fetchData() async {
  setState(() => _isLoading = true);

  try {
    final data = await api.getData();
    // ⚠️ 必须检查 mounted！
    if (!mounted) return;
    setState(() {
      _data = data;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}

// ✅ 正确：使用 Timer 后检查 mounted
void _startTimer() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) {
      timer.cancel();  // 取消定时器
      return;
    }
    setState(() => _seconds++);
  });
}

// ❌ 错误：异步 setState（回调用了 async）
void _badAsync() {
  setState(() async {  // ❌ 永远不要这样写！
    _data = await fetchData();  // setState 回调应该是同步的
  });
}

// ❌ 错误：在 build 中调用 setState
@override
Widget build(BuildContext context) {
  setState(() => _count++);  // ❌ 死循环！build → setState → build → ...
  return Text('$_count');
}

// ❌ 错误：在 initState 中调用 setState
@override
void initState() {
  super.initState();
  setState(() => _count = 10);  // ❌ State 还没准备好
}

// ❌ 错误：dispose 后调用 setState
@override
void dispose() {
  _controller.dispose();
  super.dispose();
  // 此后 mounted = false，任何 setState 都会崩溃
}

// ❌ 错误：未检查 mounted 的异步回调
void _onComplete() async {
  final result = await heavyComputation();
  setState(() => _result = result);  // ❌ 可能已经 dispose 了！
}

// ═══════════════════════════════════════
// setState 的性能优化技巧
// ═══════════════════════════════════════

// ✅ 技巧 1：缩小 setState 范围
// 把 setState 放在最小的 StatefulWidget 中，
// 而不是整个页面级别的 StatefulWidget

// ✅ 技巧 2：使用 const 构造减小重建范围
// const Text('不变的标题') 在 rebuild 时不会被重建

// ✅ 技巧 3：避免不必要的 setState
// 如果数据没变，不要调用 setState
if (_oldValue != newValue) {
  setState(() => _oldValue = newValue);
}

// ✅ 技巧 4：批量更新
// 同一帧内的多次 setState 会被合并
setState(() => _count++);
setState(() => _name = 'new');  // 两次只触发一次 build''',
            language: 'Dart',
          ),
          const TipBox(
            'setState 安全三原则：\n'
            '1. 回调函数必须是同步的（不能用 async）\n'
            '2. 异步回调中必须检查 mounted\n'
            '3. 绝不在 build/initState/dispose 中调用 setState\n\n'
            '记不住？记这个：setState 只能在「用户交互的回调」和「同步的数据修改」中使用。',
            type: TipType.caution,
          ),

          // ═══════════════════════════════════════════
          // 5. 状态提升
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('5. 状态提升（State Lifting）设计模式', icon: Icons.arrow_upward),
          const Paragraph(
            '状态提升是 Flutter 中最基础、最重要的状态共享模式。\n\n'
            '问题：两个兄弟组件需要共享同一份数据，怎么办？\n'
            '答：把状态「提升」到它们最近的共同父组件中。\n\n'
            '🔹 核心模式：\n'
            '① 父组件是 StatefulWidget，持有共享状态\n'
            '② 父组件通过构造参数把数据传给子组件（数据下行）\n'
            '③ 父组件通过回调函数接收子组件的修改通知（事件上行）\n'
            '④ 父组件调用 setState 更新状态并重建子组件\n\n'
            '这就是著名的「单向数据流」模式。',
          ),
          const Paragraph(
            '🔹 状态提升的优点：\n'
            '• 单一数据源（Single Source of Truth）：数据只存一个地方，不会不一致\n'
            '• 数据流清晰：数据只向下流，事件只向上流\n'
            '• 易于调试：所有状态变化都在父组件中，一目了然\n'
            '• 可预测：给定同样的状态，界面一定一样\n\n'
            '🔹 状态提升的缺点：\n'
            '• 层级过深时需要逐层传递（Props Drilling）\n'
            '• 父组件变得臃肿（持有太多状态和方法）\n'
            '• 不适合跨越多层的数据共享\n\n'
            '🔹 解决 Props Drilling 的方案：\n'
            '• InheritedWidget —— Flutter 自带的跨层级方案\n'
            '• Provider —— 封装 InheritedWidget 的状态管理库\n'
            '• BLoC —— 基于 Stream 的状态管理\n'
            '• Riverpod —— 编译时安全的 Provider 替代品',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// 状态提升 —— 完整示例
// ═══════════════════════════════════════

// 父组件：持有状态，协调子组件
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});
  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  // 共享状态（单一数据源）
  int _counter = 0;
  String _name = 'Flutter';

  // 修改方法（在父组件中定义）
  void _increment() => setState(() => _counter++);
  void _decrement() => setState(() => _counter--);
  void _updateName(String newName) => setState(() => _name = newName);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 子组件 A：展示数据（数据下行）
        DisplayPanel(
          counter: _counter,    // 通过参数传递
          name: _name,
        ),
        const SizedBox(height: 16),
        // 子组件 B：修改数据（回调上行）
        ControlPanel(
          onIncrement: _increment,   // 通过回调传递修改能力
          onDecrement: _decrement,
          onNameChanged: _updateName,
        ),
      ],
    );
  }
}

// 子组件 A：只负责展示（StatelessWidget）
class DisplayPanel extends StatelessWidget {
  final int counter;
  final String name;
  const DisplayPanel({
    super.key,
    required this.counter,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('计数: $counter'),
            Text('名称: $name'),
          ],
        ),
      ),
    );
  }
}

// 子组件 B：只负责触发（StatelessWidget）
class ControlPanel extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onNameChanged;

  const ControlPanel({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onIncrement, icon: const Icon(Icons.add)),
        IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove)),
      ],
    );
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '状态提升口诀：\n'
            '数据向下传（构造参数），事件向上冒（回调函数）。\n'
            '谁持有数据谁负责修改，子组件只做展示和触发。',
            type: TipType.info,
          ),

          // ═══════════════════════════════════════════
          // 6. Key 系统完全指南
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('6. Key —— Widget 的身份标识系统', icon: Icons.vpn_key),
          const Paragraph(
            'Key 是 Flutter 中最容易被误解的概念之一。它的核心作用是：\n'
            '"帮助 Flutter 在 Widget 树重建时，正确匹配新旧 Widget。"\n\n'
            '🔹 为什么需要 Key？\n\n'
            '当 Flutter 重建 Widget 树时，它需要判断：这个位置的新 Widget\n'
            '是原来那个 Widget 的「更新版本」，还是「全新的 Widget」。\n\n'
            '判断依据（canUpdate 方法）：\n'
            '① runtimeType —— Widget 的类型是否相同\n'
            '② key —— Widget 的 Key 是否相同\n\n'
            '如果类型和 Key 都相同 → 复用 Element（保留 State）\n'
            '如果类型或 Key 不同 → 销毁旧 Element，创建新的（丢失 State）\n\n'
            '问题场景：列表重排序时\n'
            '假设有列表 [WidgetA, WidgetB, WidgetC]，删除 WidgetA。\n'
            '• 没有 Key：Flutter 看到位置 0 从 WidgetA 变成 WidgetB，\n'
            '  它们类型相同 → 复用 Element！WidgetB 的 State 被错误地用到了原 WidgetA 的位置\n'
            '• 有 Key：Flutter 发现 Key(A) 消失了，Key(B) 移到了位置 0，\n'
            '  正确追踪每个 Widget 的身份',
          ),
          const Paragraph(
            '🔹 Key 的类型体系：\n\n'
            '📌 LocalKey —— 在同一父组件下唯一\n'
            '  • ValueKey(value) —— 基于值的相等性比较（最常用）\n'
            '    使用 == 运算符比较 value，value 相同则视为同一 Widget\n'
            '    适用场景：列表项有唯一 ID（如数据库 ID、UUID）\n\n'
            '  • ObjectKey(value) —— 基于对象身份的比较\n'
            '    使用 identical() 比较，必须是同一个对象引用才算相同\n'
            '    适用场景：Widget 本身持有复杂对象引用\n\n'
            '  • UniqueKey() —— 每次生成都不同\n'
            '    每次创建都生成新的唯一值，强制 Flutter 不复用 Element\n'
            '    适用场景：需要强制重建某个 Widget（如 AnimatedSwitcher 内）\n\n'
            '📌 GlobalKey —— 整个应用唯一，可跨树访问\n'
            '  • GlobalKey<T extends State>() —— 访问子组件的 State\n'
            '    通过 currentState 获取子组件的 State 对象\n'
            '    通过 currentContext 获取子组件的 BuildContext\n'
            '    通过 currentWidget 获取子组件的 Widget 配置\n'
            '    适用场景：表单验证、从外部控制子组件状态\n'
            '  • LabeledGlobalKey —— 带标签的 GlobalKey（调试用）\n'
            '  • GlobalObjectKey —— 基于对象的 GlobalKey\n\n'
            '⚠️ GlobalKey 代价较高，会触发额外的 Element 移动操作，不要滥用。',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// 各种 Key 的使用场景
// ═══════════════════════════════════════

// 1. ValueKey —— 最常用，基于唯一 ID
ListView(
  children: users.map((user) => UserTile(
    key: ValueKey(user.id),  // user.id 是唯一标识
    user: user,
  )).toList(),
);
// 当 users 列表变化时，Flutter 根据 user.id 追踪每个 UserTile

// 2. ObjectKey —— 基于对象身份
ListView(
  children: items.map((item) => ItemTile(
    key: ObjectKey(item),  // identical(item, item) 比较
    item: item,
  )).toList(),
);

// 3. UniqueKey —— 强制每次重建
AnimatedSwitcher(
  child: Container(
    key: UniqueKey(),  // 确保每次切换都触发动画
    color: _currentColor,
    width: 200, height: 200,
  ),
);

// 4. GlobalKey —— 跨树访问 State
final _formKey = GlobalKey<FormState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(validator: (v) => v?.isEmpty ?? true ? '必填' : null),
    ElevatedButton(
      onPressed: () {
        // 通过 GlobalKey 访问 FormState，触发表单验证
        if (_formKey.currentState!.validate()) {
          // 验证通过
          _formKey.currentState!.save();
        }
      },
      child: const Text('提交'),
    ),
  ]),
);

// 通过 scaffoldKey 显示 SnackBar
_scaffoldKey.currentState?.showSnackBar(
  const SnackBar(content: Text('操作成功')),
);

// 5. PageStorageKey —— 保持滚动位置
ListView(
  key: const PageStorageKey('my_list'),  // 切换页面后保持滚动位置
  children: [...],
);''',
            language: 'Dart',
          ),
          const Paragraph(
            '🔹 Key 的注意事项：\n\n'
            '① Key 应该在「列表的最外层」使用\n'
            '  不是给 ListTile，而是给 ListTile 外面的 Widget\n\n'
            '② 不要在 build 中创建 UniqueKey\n'
            '  每次 build 都生成新的 UniqueKey，导致 Widget 无法复用\n\n'
            '③ GlobalKey 不能重复\n'
            '  同一个 GlobalKey 在 Widget 树中只能出现一次\n'
            '  重复的 GlobalKey 会导致运行时错误\n\n'
            '④ Key 只在「同级 Widget」之间比较\n'
            '  不同父组件下的 Key 不会互相影响\n\n'
            '⑤ 使用 ValueKey 要确保 value 的唯一性\n'
            '  如果两个 Widget 有相同的 ValueKey 值，Flutter 会报错',
          ),
          // Key 演示列表
          const Paragraph('下面是用 ValueKey 标记的列表项，每个项维护自己的本地状态：'),
          _KeyedItem(label: '第 1 项：ValueKey("item_1") — 此 Key 确保排序后状态不错乱', color: Colors.blue),
          _KeyedItem(label: '第 2 项：ValueKey("item_2") — 每项有独立身份', color: Colors.green),
          _KeyedItem(label: '第 3 项：ValueKey("item_3") — Key 是 Widget 的身份证', color: Colors.orange),

          // Key 演示：可交互列表
          const SizedBox(height: 12),
          const SectionHeader('Key 交互演示：排序保留状态', icon: Icons.shuffle),
          const Paragraph(
            '下面的列表中每项有自己的本地计数器。'
            '点击「随机排序」，观察各项的计数器是否跟随自己的数据：\n'
            '(注意各项前面的字母标识会跟着计数走，因为它们用 Key 绑定)',
          ),
          ..._keyDemoItems.map((item) => _DemoListItem(
            key: ValueKey(item.id),
            id: item.id,
            title: item.title,
          )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _shuffleKeys,
            icon: const Icon(Icons.shuffle),
            label: const Text('随机排序（观察 Key 保持状态）'),
          ),
          const OutputBox('ValueKey 确保排序后每项的本地计数器跟随自己的数据。\n没有 Key 的话，计数会停留在原位，跟着新数据一起显示。'),

          // ═══════════════════════════════════════════
          // 7. InheritedWidget
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('7. InheritedWidget —— 跨层级数据共享', icon: Icons.share),
          const Paragraph(
            'InheritedWidget 是 Flutter 框架内部的「数据共享机制」，\n'
            'Theme.of(context) 和 MediaQuery.of(context) 的背后就是它。\n\n'
            '🔹 InheritedWidget 的工作方式：\n'
            '① 祖先 Widget 用 InheritedWidget 包裹子树\n'
            '② 子节点通过「上溯 Element 树」找到最近的 InheritedWidget\n'
            '③ 调用 dependOnInheritedWidgetOfExactType() 注册依赖关系\n'
            '④ 当 InheritedWidget 的 updateShouldNotify 返回 true 时\n'
            '⑤ 所有注册了依赖的子节点自动调用 didChangeDependencies\n\n'
            '这就是「数据变了，用到它的组件自动刷新」的底层实现。',
          ),
          const Paragraph(
            '🔹 两个关键的查找方法：\n\n'
            '① context.dependOnInheritedWidgetOfExactType<T>()\n'
            '   • 注册依赖关系\n'
            '   • InheritedWidget 更新时，调用者自动 rebuild\n'
            '   • 只能在 build() 或 didChangeDependencies() 中调用\n\n'
            '② context.getElementForInheritedWidgetOfExactType<T>()\n'
            '   • 只查找，不注册依赖\n'
            '   • InheritedWidget 更新时，调用者不会 rebuild\n'
            '   • 可以在任何地方调用（如事件回调中）\n\n'
            '区别就是：dependOn... 会建立依赖（数据变我变），\n'
            'getElement... 只是查一次（数据变我不动）。',
          ),
          const CodeBlock(
            r'''// ═══════════════════════════════════════
// 自定义 InheritedWidget
// ═══════════════════════════════════════

// 1. 定义 InheritedWidget
class MyAppTheme extends InheritedWidget {
  final ThemeData themeData;    // 共享的数据
  final VoidCallback onToggle;  // 共享的回调

  const MyAppTheme({
    super.key,
    required this.themeData,
    required this.onToggle,
    required super.child,  // 子 Widget 树
  });

  // 2. 提供静态方法方便子组件访问
  //    dependOnInheritedWidgetOfExactType → 注册依赖
  static MyAppTheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<MyAppTheme>();
    assert(result != null, 'No MyAppTheme found in context');
    return result!;
  }

  // 只读取不依赖的版本
  static MyAppTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyAppTheme>();
  }

  // 3. updateShouldNotify：判断是否需要通知子组件
  //    返回 true → 子组件 rebuild
  //    返回 false → 子组件不 rebuild
  @override
  bool updateShouldNotify(MyAppTheme oldWidget) {
    return themeData != oldWidget.themeData;
    // 只有 themeData 真正变了才通知
  }
}

// 使用 InheritedWidget 包裹子组件
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyAppTheme(
      themeData: ThemeData.light(),
      onToggle: () => print('toggle'),
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

// 子组件中使用
class MyChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取最近的 MyAppTheme 数据
    final appTheme = MyAppTheme.of(context);
    // appTheme.themeData 变化时，当前 Widget 自动 rebuild

    return Container(
      color: appTheme.themeData.colorScheme.primary,
      child: TextButton(
        onPressed: appTheme.onToggle,
        child: const Text('切换主题'),
      ),
    );
  }
}

// ═══════════════════════════════════════
// 进阶：InheritedNotifier（监听 Listenable）
// ═══════════════════════════════════════
class MyCounterScope extends InheritedNotifier<ValueNotifier<int>> {
  const MyCounterScope({
    super.key,
    required ValueNotifier<int> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static int of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MyCounterScope>()!
        .notifier!
        .value;
  }
}
// InheritedNotifier 自动监听 notifier，
// notifier 变化 → updateShouldNotify → 子组件 rebuild''',
            language: 'Dart',
          ),
          const Paragraph(
            '🔹 Flutter 内置的关键 InheritedWidget：\n'
            '• Theme —— 主题数据\n'
            '• MediaQuery —— 屏幕信息（尺寸、方向、安全区）\n'
            '• Navigator —— 路由导航\n'
            '• Directionality —— 文字方向\n'
            '• DefaultTextStyle —— 默认文字样式\n'
            '• ScaffoldMessenger —— SnackBar 管理\n'
            '• Localizations —— 国际化字符串\n\n'
            '它们都遵循同样的模式：用 .of(context) 获取数据。',
          ),
          const TipBox(
            '理解 InheritedWidget 就理解了 Flutter 状态管理的基础。\n'
            'Provider / Riverpod / BLoC 都是对 InheritedWidget 的封装和增强。\n'
            'dependOn... 绑定依赖（数据变我变），getElement... 只查不绑（一次性的）。',
            type: TipType.tip,
          ),

          // ═══════════════════════════════════════════
          // 8. 交互实战区域
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('8. 交互实战 —— 动手试试！', icon: Icons.build),
          const Paragraph(
            '下面的所有示例都可以直接交互。观察每种状态变化如何触发界面更新：',
          ),

          // 8.1 计数器
          const SizedBox(height: 16),
          const SectionHeader('🔢 计数器（int 状态）', icon: Icons.plus_one),
          const Paragraph('这是 Flutter 入门最经典的例子。观察 _count 如何驱动界面更新：'),
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
                  const Text('当前计数值 (状态: _count)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '$_count',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _count > 0 ? Colors.green : (_count < 0 ? Colors.red : Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _count >= 10 ? '🎉 到达 10 啦！' : '',
                    style: const TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _CountButton(icon: Icons.remove, onTap: _decrement, color: Colors.red, tooltip: '-1'),
                      _CountButton(icon: Icons.add, onTap: _increment, color: Colors.green, tooltip: '+1'),
                      _CountButton(icon: Icons.exposure_plus_1, onTap: _increment5, color: Colors.blue, tooltip: '+5'),
                      _CountButton(icon: Icons.refresh, onTap: _reset, color: Colors.grey, tooltip: '归零'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          OutputBox(
            '状态变量: _count = $_count\n'
            '变量类型: int\n'
            '修改方法: setState(() => _count++)\n'
            '数字绿色(>0)/红色(<0)/灰色(=0)\n'
            '达10以上显示庆祝文字',
          ),

          // 8.2 开关
          const SizedBox(height: 24),
          const SectionHeader('🔘 开关切换（bool 状态）', icon: Icons.toggle_on),
          const Paragraph('bool 类型是最简单的状态。观察 Switch 如何绑定状态：'),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSwitched ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSwitched ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSwitched ? Icons.light_mode : Icons.dark_mode,
                    color: _isSwitched ? Colors.orange : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSwitched ? '已开启' : '已关闭',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isSwitched ? Colors.green : Colors.grey,
                        ),
                      ),
                      Text(
                        '状态值: _isSwitched = $_isSwitched',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: _isSwitched,
                    onChanged: _toggleSwitch,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          OutputBox(
            'bool 状态: _isSwitched = $_isSwitched\n'
            '修改: setState(() => _isSwitched = v)\n'
            'Switch.onChanged → 回调传入新值 → setState 刷新',
          ),

          // 8.3 待办列表
          const SizedBox(height: 24),
          const SectionHeader('📝 待办列表（List 状态）', icon: Icons.checklist),
          const Paragraph('List 类型的状态管理。注意：修改 List 后必须调用 setState 才能更新界面：'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '输入新待办事项...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) => _newTodoText = v,
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_todoItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('列表为空，添加一些待办事项吧！', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...List.generate(_todoItems.length, (i) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text('${i + 1}', style: const TextStyle(color: Colors.blue)),
                    ),
                    title: Text(_todoItems[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeTodo(i),
                    ),
                  )),
              ],
            ),
          ),
          OutputBox(
            'List<String> 状态: _todoItems (${_todoItems.length}项)\n'
            '添加: _todoItems.add(v) → setState\n'
            '删除: _todoItems.removeAt(i) → setState\n'
            '⚠️ 只修改 List 不调用 setState → 界面不会更新！',
          ),

          // 8.4 颜色选择器
          const SizedBox(height: 24),
          const SectionHeader('🎨 颜色选择器（Color 状态）', icon: Icons.palette),
          const Paragraph('选择不同颜色，观察 Color 状态如何影响界面。Color 是不可变对象：'),
          Center(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('颜色', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Colors.red, Colors.pink, Colors.purple,
                    Colors.blue, Colors.teal, Colors.green,
                    Colors.orange, Colors.amber, Colors.brown,
                  ].map((color) => GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: _selectedColor == color
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                            : null,
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const OutputBox(
            'Color 状态: _selectedColor\n'
            '修改: setState(() => _selectedColor = 新颜色)\n'
            'Color 是不可变对象，修改=换一个新 Color 对象',
          ),

          // ═══════════════════════════════════════════
          // GlobalKey 交互演示
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('GlobalKey 演示：从外部控制子组件', icon: Icons.key),
          const Paragraph(
            'GlobalKey 允许父组件直接访问子组件的 State。\n'
            '下面例子中，按钮在子组件外部，但通过 GlobalKey 调用子组件的方法：',
          ),
          Center(
            child: Column(
              children: [
                _GlobalKeyChild(key: _globalChildKey),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _callGlobalKeyChild,
                  icon: const Icon(Icons.add),
                  label: const Text('通过 GlobalKey 给子组件 +1'),
                ),
                const SizedBox(height: 4),
                Text(
                  '子组件计数: $_globalKeyDemoCount (通过 GlobalKey 读取)',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          // 兄弟组件共享状态（状态提升实战）
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('状态提升实战：兄弟组件共享状态', icon: Icons.share),
          const Paragraph(
            '下面演示状态提升模式。父组件 _SharedCounterParent 持有状态，\n'
            '两个子组件（展示 + 控制）通过参数和回调共享同一份数据：',
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
                    const Text('共享计数器', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountButton(icon: Icons.remove, onTap: onDecrement, color: Colors.orange, tooltip: '-1'),
                        const SizedBox(width: 16),
                        _CountButton(icon: Icons.refresh, onTap: onReset, color: Colors.grey, tooltip: '归零'),
                        const SizedBox(width: 16),
                        _CountButton(icon: Icons.add, onTap: onIncrement, color: Colors.indigo, tooltip: '+1'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Paragraph(
            '上面代码中，_SharedCounterParent 持有共享状态，'
            '通过 builder 参数同时传给显示部分和控制部分。这就是状态提升。',
          ),

          // ═══════════════════════════════════════════
          // 完整代码参考
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('完整代码参考', icon: Icons.code),
          const CodeBlock(
            r'''import 'package:flutter/material.dart';

// ═══════════════════════════════════════
// 完整的状态管理示例：计数器应用
// ═══════════════════════════════════════

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '状态管理教程',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('你已经点击了这么多次:'),
            Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrement,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _reset,
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _increment,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}''',
            language: 'Dart',
          ),

          // ═══════════════════════════════════════════
          // 常见错误与调试
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('常见错误与调试技巧', icon: Icons.bug_report),
          const Paragraph(
            '🔹 Top 5 初学者错误：\n\n'
            '① 忘记调用 super.initState() / super.dispose()\n'
            '   症状：应用直接崩溃\n'
            '   修复：确保 override 方法中都调用了 super\n\n'
            '② 在 build() 中调用 setState\n'
            '   症状：无限循环，应用卡死\n'
            '   修复：setState 只能在事件回调中使用\n\n'
            '③ 异步回调未检查 mounted 就 setState\n'
            '   症状：setState() called after dispose() 崩溃\n'
            '   修复：if (!mounted) return; 后再 setState\n\n'
            '④ 修改了数据但没调用 setState\n'
            '   症状：界面不更新\n'
            '   修复：数据修改必须包在 setState(() { ... }) 中\n\n'
            '⑤ 在 initState 中使用 BuildContext\n'
            '   症状：dependOnInheritedWidgetOfExactType() called before initState\n'
            '   修复：把 BuildContext 操作移到 didChangeDependencies 中',
          ),
          const TipBox(
            '调试状态问题的利器：\n'
            '• Flutter DevTools → 查看 Widget 树和重建次数\n'
            '• debugPrintRebuildDirtyWidgets = true → 打印每次重建\n'
            '• print(_count) 在 build 中 → 观察重建频率\n'
            '• 使用 const 构造函数 → 防止不必要的重建',
            type: TipType.info,
          ),

          // ═══════════════════════════════════════════
          // 进阶之路
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('从 setState 到 Provider 的进阶之路', icon: Icons.trending_up),
          const Paragraph(
            '学习状态管理的推荐路径：\n\n'
            '第一步：掌握 setState + StatefulWidget（本章）\n'
            '  → 理解什么是状态、状态如何驱动界面\n\n'
            '第二步：掌握状态提升模式（本章）\n'
            '  → 理解数据流、回调模式、单向数据流\n\n'
            '第三步：掌握 InheritedWidget（本章）\n'
            '  → 理解 Flutter 的跨层级数据共享机制\n\n'
            '第四步：学习 Provider（第11章）\n'
            '  → 生产级状态管理方案\n\n'
            '第五步：探索 Riverpod / BLoC（进阶）\n'
            '  → 不同项目规模的方案选择',
          ),
          const TipBox(
            '不要一上来就学 Provider！先用 setState 做几个小项目，\n'
            '遇到状态共享困难时再升级。过度设计比简单方案更可怕。',
            type: TipType.caution,
          ),

          // ═══════════════════════════════════════════
          // 小练习
          // ═══════════════════════════════════════════
          const DividerLine(),
          const SectionHeader('课后练习', icon: Icons.edit),
          const Paragraph(
            '🔹 基础练习：\n'
            '1. 修改计数器，让 _count 到达 20 时自动归零\n'
            '2. 添加一个「减 5」按钮到计数器中\n'
            '3. 给待办列表添加「标记完成」功能（用另一个 List<bool> 状态）\n'
            '4. 用 Switch 切换页面的背景颜色\n\n'
            '🔹 进阶练习：\n'
            '5. 用状态提升实现「用户信息编辑表单 + 信息预览卡片」\n'
            '   └ 表单修改数据，预览实时更新（共享同一份状态）\n'
            '6. 用 Key 实现一个「可排序的计数器列表」\n'
            '   └ 每个计数器保持自己的计数，排序后计数跟着走\n'
            '7. 写一个自定义 InheritedWidget 实现「全局计数器」\n'
            '   └ 任意层级子组件都能读取和修改同一个计数值\n'
            '8. 用 GlobalKey 实现一个「外部重置按钮」\n'
            '   └ 按钮在 AppBar，点击后重置页面内的所有输入框',
          ),
          const SizedBox(height: 8),
          const TipBox(
            '练习原则：先模仿、再修改、最后原创。\n'
            '每做完一个练习，试着解释：\n'
            '① 状态存在哪里？② 谁在修改状态？③ 界面如何响应变化？',
            type: TipType.tip,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// 辅助组件
// ═══════════════════════════════════════════

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;
  const _CountButton({required this.icon, required this.onTap, required this.color, required this.tooltip});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 56, height: 56,
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}

// GlobalKey 演示子组件
class _GlobalKeyChild extends StatefulWidget {
  const _GlobalKeyChild({super.key});
  @override
  State<_GlobalKeyChild> createState() => _GlobalKeyChildState();
}

class _GlobalKeyChildState extends State<_GlobalKeyChild> {
  int count = 0;
  void increment() => setState(() => count++);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('GlobalKey 子组件', style: TextStyle(fontWeight: FontWeight.w600)),
          Text('$count', style: const TextStyle(fontSize: 36, color: Colors.purple)),
          const Text('（不能自己改，只能外部通过 GlobalKey 控制）', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Key 演示的数据类
class _DemoListItemData {
  final String id;
  final String title;
  const _DemoListItemData({required this.id, required this.title});
}
