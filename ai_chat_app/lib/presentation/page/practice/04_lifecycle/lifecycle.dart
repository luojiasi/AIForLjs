import 'package:flutter/material.dart';

/// ============================================================
/// 04_生命周期大全
/// 本文件演示 Flutter 中所有生命周期相关概念
/// 包含：App 生命周期、Widget 生命周期、交互式演示
/// ============================================================

/// 全局日志列表，用于跨 Widget 共享生命周期事件记录
final List<_LifecycleEvent> _globalLog = [];

/// 添加一条日志
void _addLog(String source, String event, {String? detail}) {
  _globalLog.insert(0, _LifecycleEvent(
    source: source,
    event: event,
    detail: detail,
    time: DateTime.now(),
  ));
  // 保留最近 100 条
  if (_globalLog.length > 100) {
    _globalLog.removeLast();
  }
}

class _LifecycleEvent {
  final String source;
  final String event;
  final String? detail;
  final DateTime time;

  const _LifecycleEvent({
    required this.source,
    required this.event,
    this.detail,
    required this.time,
  });
}

class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => LifecycleDemoState();
}

class LifecycleDemoState extends State<LifecycleDemo>
    with WidgetsBindingObserver {
  int _buildCount = 0;
  bool _showChild = true;
  bool _showGrandchild = true;
  Key _childKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addLog('LifecycleDemo', 'initState() 调用',
        detail: 'State 对象已创建，可以在这里初始化数据、订阅Stream');
    _addLog('LifecycleDemo', 'didChangeDependencies() 即将触发');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addLog('LifecycleDemo', 'didChangeDependencies() 调用',
        detail: '依赖的 InheritedWidget 发生变化时触发');
  }

  @override
  void didUpdateWidget(LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addLog('LifecycleDemo', 'didUpdateWidget() 调用',
        detail: '父 Widget 重建导致当前 Widget 配置更新');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final names = {
      AppLifecycleState.resumed: 'resumed（应用可见且可交互）',
      AppLifecycleState.inactive: 'inactive（应用可见但不可交互）',
      AppLifecycleState.paused: 'paused（应用不可见）',
      AppLifecycleState.detached: 'detached（应用已分离）',
      AppLifecycleState.hidden: 'hidden（应用隐藏）',
    };
    _addLog('AppLifecycle', 'didChangeAppLifecycleState(${names[state] ?? state})',
        detail: 'App 生命周期发生变化');
  }

  @override
  void deactivate() {
    super.deactivate();
    _addLog('LifecycleDemo', 'deactivate() 调用',
        detail: 'State 对象从 Widget 树移除前调用');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _addLog('LifecycleDemo', 'dispose() 调用',
        detail: 'State 对象永久销毁，在这里释放Controller、取消订阅');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    _addLog('LifecycleDemo', 'build() 第 $_buildCount 次调用');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 生命周期大全'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重建当前页面（触发 didUpdateWidget）',
            onPressed: () {
              setState(() {});
              _addLog('LifecycleDemo', 'setState() 调用',
                  detail: '手动触发重建，build() 将再次执行');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 一、什么是生命周期 ====================
          _SectionTitle(title: '一、什么是生命周期'),
          _Explainer(
            text: '生命周期是 Flutter Widget 从"出生"到"销毁"过程中经历的一系列阶段。'
                '了解生命周期对正确管理资源、避免内存泄漏至关重要。\n\n'
                'Flutter 中有两类生命周期：\n'
                '1️⃣ App 生命周期 — 整个应用的前后台切换\n'
                '2️⃣ Widget 生命周期 — 单个 Widget 的创建到销毁\n\n'
                '⭐ 下方演示可以交互操作，实时查看每个阶段触发的回调！',
          ),
          _DividerLine(),

          // ==================== 二、App 生命周期 ====================
          _SectionTitle(title: '二、App 生命周期（整个应用）'),
          _Explainer(
            text: 'App 生命周期监听应用的前后台切换，通过 WidgetsBindingObserver 实现。\n\n'
                'resumed     → 应用可见且可交互（回到前台）\n'
                'hidden      → 应用不可见（被其他应用覆盖）\n'
                'inactive    → 应用可见但不可交互（如来电）\n'
                'paused      → 应用不可见（进入后台）\n'
                'detached    → 应用引擎已分离（即将被销毁）\n\n'
                '💡 提示：在 Web 端部分状态不会触发，移动端效果最明显。',
          ),
          _CodeBlock(code: '''// 1. 添加混入
class MyPage extends StatefulWidget { ... }

class _MyPageState extends State<MyPage>
    with WidgetsBindingObserver {  // ← 加入观察者

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 处理前后台切换
    if (state == AppLifecycleState.paused) {
      // 保存草稿、暂停动画
    } else if (state == AppLifecycleState.resumed) {
      // 刷新数据、恢复动画
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 注销
    super.dispose();
  }
}'''),
          const SizedBox(height: 8),
          // 可视化 App 生命周期状态
          const _AppLifecycleMonitor(),
          _DividerLine(),

          // ==================== 三、Widget 生命周期总览 ====================
          _SectionTitle(title: '三、Widget 生命周期图解'),
          _Explainer(
            text: '一个 StatefulWidget 从创建到销毁的完整流程：',
          ),
          // 生命周期流程图
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF263238),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _FlowStep(step: '①', title: 'createState()', desc: 'Flutter 调用此方法创建 State 对象', color: Color(0xFF4CAF50)),
                _FlowArrow(),
                _FlowStep(step: '②', title: 'initState()', desc: 'State 对象已创建，只调用一次。初始化数据、订阅 Stream', color: Color(0xFF2196F3)),
                _FlowArrow(),
                _FlowStep(step: '③', title: 'didChangeDependencies()', desc: '依赖的 InheritedWidget 变化时触发。Theme、MediaQuery 等', color: Color(0xFF2196F3)),
                _FlowArrow(),
                _FlowStep(step: '④', title: 'build()', desc: '构建 UI，可反复调用。每次 setState 或父 Widget 重建时触发', color: Color(0xFFFF9800)),
                _FlowArrow(),
                _FlowStep(step: '⑤', title: 'didUpdateWidget()', desc: '父 Widget 重建导致当前 Widget 配置更新时触发', color: Color(0xFF9C27B0)),
                _FlowArrow(),
                _FlowStep(step: '⑥', title: 'setState()', desc: '手动标记状态变化，触发 build() 重新执行', color: Color(0xFFFF9800)),
                _FlowArrow(),
                _FlowStep(step: '⑦', title: 'deactivate()', desc: 'State 从 Widget 树移除前调用（可能重新插入）', color: Color(0xFFE91E63)),
                _FlowArrow(),
                _FlowStep(step: '⑧', title: 'dispose()', desc: 'State 永久销毁。释放 Controller、取消订阅、清理资源', color: Color(0xFFF44336)),
              ],
            ),
          ),
          _DividerLine(),

          // ==================== 四、各阶段详解 ====================
          _SectionTitle(title: '四、各生命周期阶段详解'),

          // ---------- 1. createState ----------
          _WidgetTitle(title: '1️⃣ createState() —— 创建状态对象'),
          _Explainer(
            text: '这是 Flutter 创建 StatefulWidget 的 State 对象时调用的第一个方法。\n'
                '⭐ 每个 StatefulWidget 必须实现此方法。\n'
                '⭐ 只调用一次。\n'
                '⭐ 通常不需要在此做额外工作。',
          ),
          _CodeBlock(code: '''class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
  //                     ↑
  //        这是生命周期的起点
}'''),
          _DividerLine(),

          // ---------- 2. initState ----------
          _WidgetTitle(title: '2️⃣ initState() —— 初始化'),
          _Explainer(
            text: 'State 对象创建后第一个被调用的方法。\n'
                '⭐ 只调用一次，必须调用 super.initState()。\n'
                '⭐ 适合做：初始化数据、订阅 Stream、添加监听器。\n'
                '⭐ ❌ 不能在此方法中使用 BuildContext 做跨 Widget 操作。\n'
                '⭐ ❌ 不能在此调用 setState()。',
          ),
          _CodeBlock(code: '''@override
void initState() {
  super.initState();          // ← 必须调用
  _controller = TextEditingController();
  _scrollController = ScrollController();
  _subscription = someStream.listen((data) {
    setState(() => _data = data);
  });
  // ❌ 不能调用 setState()
  // ❌ 不能做 BuildContext 相关操作
}'''),
          const SizedBox(height: 8),
          // 交互演示：initState
          _InteractiveCard(
            title: '演示：initState',
            subtitle: '每次创建实例时触发',
            color: const Color(0xFF2196F3),
            child: _InitStateDemo(),
          ),
          _DividerLine(),

          // ---------- 3. didChangeDependencies ----------
          _WidgetTitle(title: '3️⃣ didChangeDependencies() —— 依赖变化'),
          _Explainer(
            text: '当 State 的依赖发生变化时调用。\n'
                '⭐ 在 initState() 之后立即调用一次。\n'
                '⭐ 之后每当 InheritedWidget 变化时再次触发。\n'
                '⭐ 典型场景：Theme.of(context)、MediaQuery.of(context)。\n'
                '⭐ 适合：在依赖变化时加载数据。',
          ),
          _CodeBlock(code: '''@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final theme = Theme.of(context);      // 获取主题
  final media = MediaQuery.of(context); // 获取屏幕信息
  // 依赖变化时重新加载数据
  _loadData();
}'''),
          const SizedBox(height: 8),
          // 交互演示：didChangeDependencies
          _InteractiveCard(
            title: '演示：didChangeDependencies',
            subtitle: '点击按钮切换依赖，观察回调触发',
            color: const Color(0xFF2196F3),
            child: _DependenciesDemo(),
          ),
          _DividerLine(),

          // ---------- 4. build ----------
          _WidgetTitle(title: '4️⃣ build() —— 构建 UI'),
          _Explainer(
            text: '构建 Widget 的核心方法。\n'
                '⭐ 最频繁调用的方法，可以是几十上百次。\n'
                '⭐ 每次 setState()、didChangeDependencies() 或父 Widget 重建时触发。\n'
                '⭐ ⚠️ 不要在 build 中做耗时操作（网络请求、数据库查询）。\n'
                '⭐ ⚠️ 不要在 build 中创建新对象（会导致子 Widget 频繁重建）。',
          ),
          _CodeBlock(code: '''@override
Widget build(BuildContext context) {
  // ✅ 可以：构建 UI、读取 Provider
  final theme = Theme.of(context);
  final count = ref.watch(counterProvider);

  // ❌ 不要：耗时操作
  // final data = await api.fetchData();

  // ❌ 不要：创建新对象（每次 rebuild 都创建）
  // return Text(DateTime.now().toString());

  return Text('\$count');
}'''),
          const SizedBox(height: 8),
          // build 计数演示
          _InteractiveCard(
            title: '演示：build() 计数',
            subtitle: '每次重建 UI 时 build 被调用一次',
            color: const Color(0xFFFF9800),
            child: _BuildCountDemo(),
          ),
          _DividerLine(),

          // ---------- 5. didUpdateWidget ----------
          _WidgetTitle(title: '5️⃣ didUpdateWidget() —— Widget 更新'),
          _Explainer(
            text: '当父 Widget 重建导致当前 Widget 的配置发生变化时调用。\n'
                '⭐ 不会在 setState() 时触发。\n'
                '⭐ 提供 oldWidget 参数，可对比新旧配置。\n'
                '⭐ 典型场景：父 Widget 传入了新参数。',
          ),
          _CodeBlock(code: '''@override
void didUpdateWidget(MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.userId != oldWidget.userId) {
    // userId 变了，重新加载数据
    _loadUser(widget.userId);
  }
}'''),
          const SizedBox(height: 8),
          // 交互演示：didUpdateWidget
          _InteractiveCard(
            title: '演示：didUpdateWidget',
            subtitle: '点击按钮向子 Widget 传入新值',
            color: const Color(0xFF9C27B0),
            child: _DidUpdateWidgetDemo(),
          ),
          _DividerLine(),

          // ---------- 6. setState ----------
          _WidgetTitle(title: '6️⃣ setState() —— 标记重建'),
          _Explainer(
            text: '手动告诉 Flutter "状态变了，请重建 UI"。\n'
                '⭐ 调用后会重新执行 build() 方法。\n'
                '⭐ Flutter 会智能地只重建受影响的 Widget。\n'
                '⭐ 不要随意调用 setState() — 不必要的重建会降低性能。\n'
                '⭐ 不要在 initState() 或 dispose() 中调用 setState()。',
          ),
          _CodeBlock(code: '''// ✅ 正确用法：状态变化后才调用
void _increment() {
  setState(() {
    _count++;  // 在回调中修改状态
  });
}

// ❌ 错误用法：不必要的重建
void _onTap() {
  setState(() {});  // 什么都没变，却重建了整个子树
}

// ❌ 错误用法：dispose 后调用
@override
void dispose() {
  setState(() {});  // 已销毁的 State 不能 setState
  super.dispose();
}'''),
          _DividerLine(),

          // ---------- 7. deactivate ----------
          _WidgetTitle(title: '7️⃣ deactivate() —— 即将移除'),
          _Explainer(
            text: 'State 对象从 Widget 树中移除前调用。\n'
                '⭐ State 可能被重新插入到树中（比如在 Widget 树中移动位置）。\n'
                '⭐ 通常不需要重写此方法，特殊情况可在此做一些清理。\n'
                '⭐ dispose() 前一定会调用 deactivate()。',
          ),
          _CodeBlock(code: '''@override
void deactivate() {
  super.deactivate();
  // State 即将从树中移除
  // 注意：此时 State 可能还会被重新插入
}'''),
          _DividerLine(),

          // ---------- 8. dispose ----------
          _WidgetTitle(title: '8️⃣ dispose() —— 永久销毁'),
          _Explainer(
            text: 'State 对象被永久销毁时调用。\n'
                '⭐ ⚠️ 这是最重要的生命周期方法！\n'
                '⭐ 必须释放所有占用的资源，防止内存泄漏。\n'
                '⭐ 调用后不能再使用 State。\n'
                '⭐ 必须调用 super.dispose()（在方法的最后）。\n\n'
                '需要释放的常见资源：\n'
                '• TextEditingController.dispose()\n'
                '• AnimationController.dispose()\n'
                '• StreamSubscription.cancel()\n'
                '• TabController.dispose()\n'
                '• FocusNode.dispose()',
          ),
          _CodeBlock(code: '''// ✅ 正确做法：完整释放
@override
void dispose() {
  _controller.dispose();          // 释放 TextEditingController
  _animationController.dispose();  // 释放 AnimationController
  _subscription.cancel();          // 取消 Stream 订阅
  WidgetsBinding.instance
      .removeObserver(this);       // 注销 App 生命周期监听
  super.dispose();                 // ← 必须最后调用
}

// ❌ 错误做法：忘记释放
@override
void dispose() {
  // _controller.dispose(); ← 漏掉了！内存泄漏！
  super.dispose();
}'''),
          _DividerLine(),

          // ==================== 五、交互式综合演示 ====================
          _SectionTitle(title: '五、交互式综合演示'),
          _Explainer(
            text: '下面是一个可交互的子 Widget，你可以通过按钮控制它的创建和销毁，'
                '实时观察每个生命周期回调的触发顺序。',
          ),
          // 交互控制区
          _ControlPanel(
            showChild: _showChild,
            showGrandchild: _showGrandchild,
            childKey: _childKey,
            onToggleChild: (v) {
              setState(() => _showChild = v);
            },
            onToggleGrandchild: (v) {
              setState(() => _showGrandchild = v);
            },
            onResetKey: () {
              setState(() => _childKey = UniqueKey());
            },
          ),
          const SizedBox(height: 8),
          // 子 Widget 展示区
          if (_showChild)
            _LifecycleChild(
              key: _childKey,
              showGrandchild: _showGrandchild,
            ),
          _DividerLine(),

          // ==================== 六、实时日志 ====================
          _SectionTitle(title: '六、实时生命周期日志'),
          _Explainer(
            text: '以下是所有生命周期事件的实时记录，按时间倒序排列。\n'
                '进行操作后观察日志的变化，理解每个回调触发的时机。',
          ),
          // 清空日志按钮
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('清空日志'),
              onPressed: () {
                _globalLog.clear();
                (context as Element).markNeedsBuild();
              },
            ),
          ),
          const SizedBox(height: 4),
          // 日志列表
          _LifecycleLogView(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================================
// 子 Widget：交互式生命周期演示
// ============================================================

class _LifecycleChild extends StatefulWidget {
  final bool showGrandchild;
  const _LifecycleChild({
    super.key,
    required this.showGrandchild,
  });

  @override
  State<_LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<_LifecycleChild> {
  int _localCount = 0;

  @override
  void initState() {
    super.initState();
    _addLog('子Widget', 'initState() — 子 Widget 已创建');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addLog('子Widget', 'didChangeDependencies() — 依赖变化');
  }

  @override
  void didUpdateWidget(_LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showGrandchild != oldWidget.showGrandchild) {
      _addLog('子Widget', 'didUpdateWidget() — showGrandchild 参数变化',
          detail: '从 ${oldWidget.showGrandchild} → ${widget.showGrandchild}');
    } else {
      _addLog('子Widget', 'didUpdateWidget() — 父 Widget 重建');
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _addLog('子Widget', 'deactivate() — 即将从 Widget 树移除');
  }

  @override
  void dispose() {
    _addLog('子Widget', 'dispose() — 子 Widget 永久销毁');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _addLog('子Widget', 'build() — 重新构建 UI');
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('子 Widget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('_LifecycleChild 实例', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 12),
          const Text('这个子 Widget 会记录自己的生命周期事件，'
              '观察右侧的日志面板了解每个回调触发的时机。'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => _localCount++);
                  _addLog('子Widget', 'setState() — 本地计数: $_localCount');
                },
                child: const Text('触发子 Widget 重建'),
              ),
              const SizedBox(width: 12),
              Text('本地计数: $_localCount',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          // 孙 Widget
          if (widget.showGrandchild)
            const _LifecycleGrandchild(),
        ],
      ),
    );
  }
}

// ============================================================
// 孙 Widget：进一步展示嵌套生命周期
// ============================================================

class _LifecycleGrandchild extends StatefulWidget {
  const _LifecycleGrandchild();

  @override
  State<_LifecycleGrandchild> createState() => _LifecycleGrandchildState();
}

class _LifecycleGrandchildState extends State<_LifecycleGrandchild> {
  @override
  void initState() {
    super.initState();
    _addLog('孙Widget', 'initState() — 孙 Widget 已创建');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addLog('孙Widget', 'didChangeDependencies()');
  }

  @override
  void didUpdateWidget(_LifecycleGrandchild oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addLog('孙Widget', 'didUpdateWidget()');
  }

  @override
  void deactivate() {
    super.deactivate();
    _addLog('孙Widget', 'deactivate()');
  }

  @override
  void dispose() {
    _addLog('孙Widget', 'dispose() — 孙 Widget 销毁');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _addLog('孙Widget', 'build()');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('孙 Widget', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const Text('_LifecycleGrandchild 实例'),
        ],
      ),
    );
  }
}

// ============================================================
// initState 交互演示
// ============================================================

class _InitStateDemo extends StatefulWidget {
  @override
  State<_InitStateDemo> createState() => _InitStateDemoState();
}

class _InitStateDemoState extends State<_InitStateDemo> {
  int _instanceId = 0;

  @override
  void initState() {
    super.initState();
    _instanceId = DateTime.now().millisecondsSinceEpoch % 10000;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _IncentiveText(text: '当前实例 ID: $_instanceId'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('重新创建实例（触发 initState）'),
          onPressed: () {
            _addLog('initState演示', '点击了重新创建');
            setState(() => _instanceId = DateTime.now().millisecondsSinceEpoch % 10000);
          },
        ),
        const SizedBox(height: 8),
        const _TipText(text: '每次点击按钮都会创建一个新 State 实例，initState 会重新执行。'),
      ],
    );
  }
}

// ============================================================
// didChangeDependencies 交互演示
// ============================================================

class _DependenciesDemo extends StatefulWidget {
  @override
  State<_DependenciesDemo> createState() => _DependenciesDemoState();
}

class _DependenciesDemoState extends State<_DependenciesDemo> {
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _IncentiveText(text: '此演示借助 InheritedWidget 触发 didChangeDependencies'),
        const SizedBox(height: 8),
        // 用 key 变化模拟 InheritedWidget 变化
        _DependencyContainer(
          key: ValueKey(_refreshKey),
          child: const _DependencyConsumer(),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('模拟 InheritedWidget 变化'),
          onPressed: () {
            setState(() => _refreshKey++);
          },
        ),
      ],
    );
  }
}

class _DependencyContainer extends InheritedWidget {
  const _DependencyContainer({super.key, required super.child});

  @override
  bool updateShouldNotify(_DependencyContainer oldWidget) => true;
}

class _DependencyConsumer extends StatefulWidget {
  const _DependencyConsumer();

  @override
  State<_DependencyConsumer> createState() => _DependencyConsumerState();
}

class _DependencyConsumerState extends State<_DependencyConsumer> {
  int _dependencyCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dependencyCount++;
    _addLog('依赖演示', 'didChangeDependencies() 触发 #$_dependencyCount');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('didChangeDependencies 触发了 $_dependencyCount 次',
          style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

// ============================================================
// build 计数交互演示
// ============================================================

class _BuildCountDemo extends StatefulWidget {
  @override
  State<_BuildCountDemo> createState() => _BuildCountDemoState();
}

class _BuildCountDemoState extends State<_BuildCountDemo> {
  int _count = 0;
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // 用后置递增避免 build 次数在日志中多显示 1
    _buildCount++;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _IncentiveText(text: '状态值: $_count'),
            ),
            Expanded(
              child: _IncentiveText(text: 'build 已调用: $_buildCount 次'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _count++),
                child: const Text('+1（setState 触发 build）'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addLog('build示例', '只是加一行日志，不触发 build'),
                child: const Text('加日志（不触发 build）'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _TipText(text: '每次 setState 都触发 build() 重新执行。'
            'Flutter 会智能地只重建实际变化的部分。'),
      ],
    );
  }
}

// ============================================================
// didUpdateWidget 交互演示
// ============================================================

class _DidUpdateWidgetDemo extends StatefulWidget {
  @override
  State<_DidUpdateWidgetDemo> createState() => _DidUpdateWidgetDemoState();
}

class _DidUpdateWidgetDemoState extends State<_DidUpdateWidgetDemo> {
  String _name = '张三';
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _IncentiveText(text: '父 Widget 向子 Widget 传递参数，观察子 Widget 的 didUpdateWidget'),
        const SizedBox(height: 8),
        _UpdatableChild(name: _name, counter: _counter),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _name = _name == '张三' ? '李四' : '张三'),
                child: const Text('切换姓名'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _counter++),
                child: Text('计数 +1（当前: $_counter）'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _TipText(text: '只有传给子 Widget 的参数实际变化时，didUpdateWidget 才会触发。'
            '单纯计数变化不会影响 UpdatableChild 因为没传 counter 给它。'),
      ],
    );
  }
}

class _UpdatableChild extends StatefulWidget {
  final String name;
  final int counter;

  const _UpdatableChild({required this.name, required this.counter});

  @override
  State<_UpdatableChild> createState() => _UpdatableChildState();
}

class _UpdatableChildState extends State<_UpdatableChild> {
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_UpdatableChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCount++;
    if (widget.name != oldWidget.name) {
      _addLog('didUpdateWidget', 'name 变化: ${oldWidget.name} → ${widget.name}',
          detail: '这正是 didUpdateWidget 的典型用途：对比新旧参数，做相应处理');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9C27B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Label(text: '姓名:', color: Color(0xFF9C27B0)),
              const SizedBox(width: 8),
              Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const _Label(text: 'didUpdateWidget 触发次数:', color: Color(0xFF9C27B0)),
              const SizedBox(width: 8),
              Text('$_updateCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// App 生命周期监视器
// ============================================================

class _AppLifecycleMonitor extends StatefulWidget {
  const _AppLifecycleMonitor();

  @override
  State<_AppLifecycleMonitor> createState() => _AppLifecycleMonitorState();
}

class _AppLifecycleMonitorState extends State<_AppLifecycleMonitor>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() => _lastState = state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📱 App 当前状态:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _lastState == AppLifecycleState.resumed
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lastState == AppLifecycleState.resumed
                        ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _lastState?.name ?? 'resumed（应用初始状态）',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _lastState == AppLifecycleState.resumed
                        ? const Color(0xFF2E7D32) : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const _TipText(text: '切换到其他应用再回来，观察状态变化。'
              '如果是模拟器，可以用 Cmd+Shift+H（Mac）或 Win+D（Windows）测试。'),
        ],
      ),
    );
  }
}

// ============================================================
// 控制面板
// ============================================================

class _ControlPanel extends StatelessWidget {
  final bool showChild;
  final bool showGrandchild;
  final Key childKey;
  final ValueChanged<bool> onToggleChild;
  final ValueChanged<bool> onToggleGrandchild;
  final VoidCallback onResetKey;

  const _ControlPanel({
    required this.showChild,
    required this.showGrandchild,
    required this.childKey,
    required this.onToggleChild,
    required this.onToggleGrandchild,
    required this.onResetKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎮 控制面板', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // 开关：显示/隐藏子 Widget
          _SwitchRow(
            label: '显示子 Widget',
            value: showChild,
            onChanged: (v) {
              if (!v) {
                _addLog('控制面板', '即将移除子 Widget → deactivate/dispose');
              } else {
                _addLog('控制面板', '即将创建子 Widget → createState/initState');
              }
              onToggleChild(v);
            },
            description: showChild ? '关闭将触发子 Widget 的 deactivate → dispose' : '开启将触发 createState → initState → build',
          ),
          const Divider(height: 20),
          // 开关：显示/隐藏孙 Widget
          _SwitchRow(
            label: '显示孙 Widget',
            value: showGrandchild,
            onChanged: (v) {
              if (!v) {
                _addLog('控制面板', '即将移除孙 Widget');
              } else {
                _addLog('控制面板', '即将创建孙 Widget');
              }
              onToggleGrandchild(v);
            },
            description: showGrandchild ? '关闭将触发孙 Widget 的 dispose' : '开启将触发孙 Widget 的 initState',
          ),
          const Divider(height: 20),
          // 重置 Key
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('重置 Key', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    _TipText(text: '改变 Key 会强制 Flutter 创建全新的 State 实例'),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重置'),
                onPressed: onResetKey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String description;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              _TipText(text: description),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

// ============================================================
// 生命周期日志视图
// ============================================================

class _LifecycleLogView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (_globalLog.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Center(
          child: Text('暂无日志，请进行操作',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 日志统计
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF37474F),
            child: Row(
              children: [
                const Icon(Icons.list, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text('共 ${_globalLog.length} 条事件记录',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          // 日志列表
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: _globalLog.length,
              itemBuilder: (context, index) {
                final event = _globalLog[index];
                final isBuild = event.event.startsWith('build');
                final isInit = event.event.startsWith('initState');
                final isDispose = event.event.startsWith('dispose');
                final isDeactivate = event.event.startsWith('deactivate');

                Color dotColor;
                if (isInit) {
                  dotColor = const Color(0xFF4CAF50);
                } else if (isDispose) {
                  dotColor = const Color(0xFFF44336);
                } else if (isDeactivate) {
                  dotColor = const Color(0xFFFF9800);
                } else if (isBuild) {
                  dotColor = const Color(0xFF2196F3);
                } else {
                  dotColor = Colors.grey;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '[${event.source}]',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.cyan[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.event,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (event.detail != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  event.detail!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${event.time.hour.toString().padLeft(2, '0')}:'
                        '${event.time.minute.toString().padLeft(2, '0')}:'
                        '${event.time.second.toString().padLeft(2, '0')}.'
                        '${event.time.millisecond.toString().padLeft(3, '0')}',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 辅助组件
// ============================================================

/// 节标题
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1565C0),
        ),
      ),
    );
  }
}

/// Widget 名称标题
class _WidgetTitle extends StatelessWidget {
  final String title;
  const _WidgetTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(title, style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      )),
    );
  }
}

/// 解释文本
class _Explainer extends StatelessWidget {
  final String text;
  const _Explainer({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A237E), height: 1.5),
      ),
    );
  }
}

/// 代码块
class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF80CBC4),
          height: 1.5,
        ),
      ),
    );
  }
}

/// 分割线
class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
    );
  }
}

/// 交互演示卡片
class _InteractiveCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  const _InteractiveCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// 流程步骤
class _FlowStep extends StatelessWidget {
  final String step;
  final String title;
  final String desc;
  final Color color;

  const _FlowStep({
    required this.step,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(step,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    )),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 流程箭头
class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward, color: Colors.white38, size: 20),
    );
  }
}

/// 提示文本（灰色小字）
class _TipText extends StatelessWidget {
  final String text;
  const _TipText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4));
  }
}

/// 强调文本
class _IncentiveText extends StatelessWidget {
  final String text;
  const _IncentiveText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
  }
}

/// 带颜色的标签
class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600));
  }
}
