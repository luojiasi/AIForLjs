import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第四章：生命周期 (Lifecycle)
/// 从创建到销毁，StatefulWidget 的完整生命周期
/// ============================================================

class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo>
    with WidgetsBindingObserver {
  final List<String> _lifecycleLog = [];
  int _counter = 0;
  bool _showChild = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _log('① initState() —— State 创建，只一次');
    _log('   → 初始化数据、控制器、监听器');
    _log('   → 还不能通过 context 获取 InheritedWidget');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _log('② didChangeDependencies()');
    _log('   → initState 后立即执行');
    _log('   → InheritedWidget 变化时也会触发');
  }

  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log('③ didUpdateWidget()');
    _log('   → 父 Widget 重建且当前 Widget 被复用');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _log('📱 App: $state');
  }

  @override
  void deactivate() {
    super.deactivate();
    _log('④ deactivate() —— 从树中移除');
    _log('   → 之后可能被重新插入（GlobalKey）');
  }

  @override
  void dispose() {
    _log('⑤ dispose() —— 永久销毁');
    _log('   → 释放所有资源！');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _log(String msg) {
    _lifecycleLog.insert(0, '${DateTime.now().second}s: $msg');
  }

  @override
  Widget build(BuildContext context) {
    _lifecycleLog.insert(
        0, '▶ build() 第 ${++_counter} 次 | mounted=$mounted');
    if (_lifecycleLog.length > 24) {
      _lifecycleLog.removeRange(24, _lifecycleLog.length);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('第4章 · 生命周期'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 本章内容概览 ──
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 什么是生命周期\n'
            '② 完整生命周期流程图\n'
            '③ 应用生命周期 AppLifecycleState\n'
            '④ 六个核心方法详解\n'
            '⑤ mounted 属性与安全调用\n'
            '⑥ AutomaticKeepAliveClientMixin\n'
            '⑦ 常见错误',
          ),
          const DividerLine(),

          // ── 1. 什么是生命周期 ──
          const SectionHeader('1. 什么是生命周期？', icon: Icons.help_outline),
          const Paragraph(
            '每个 StatefulWidget 从创建到销毁，会经历一系列阶段。\n'
            '这些阶段就叫「生命周期」。\n\n'
            '就像人的一生：出生 → 成长 → 工作 → 退休 → 离世\n\n'
            'StatefulWidget 的过程：\n'
            '构造函数 → createState → initState →\n'
            'didChangeDependencies → build →\n'
            'didUpdateWidget → deactivate → dispose\n\n'
            '理解生命周期让你知道：\n'
            '• 什么时候初始化数据？→ initState\n'
            '• 什么时候释放资源？→ dispose\n'
            '• 什么时候响应父 Widget 变化？→ didUpdateWidget\n'
            '• 什么时候更新界面？→ build',
          ),
          const TipBox(
            '比背流程更重要的是：在正确的阶段做正确的事。',
            type: TipType.info,
          ),

          // ── 2. 完整生命周期流程图 ──
          const DividerLine(),
          const SectionHeader('2. 完整生命周期流程图', icon: Icons.route),
          const CodeBlock(
            'createState → initState → didChangeDependencies\n'
            '                  │\n'
            '                  ↓\n'
            '        build()  ←── setState()\n'
            '          │         触发重建\n'
            '          ├── didUpdateWidget()\n'
            '          │   （父 Widget 重建）\n'
            '          │       ↓\n'
            '          │     build()\n'
            '          │\n'
            '          ↓\n'
            '        deactivate() → dispose()',
            language: 'Text',
          ),
          const Paragraph(
            '顺序：initState → didChangeDependencies → build\n'
            '更新循环：setState → build 或 didUpdateWidget → build\n'
            '销毁：deactivate → dispose',
          ),

          // ── 3. 应用生命周期 ──
          const DividerLine(),
          const SectionHeader('3. 应用生命周期 AppLifecycleState',
              icon: Icons.phone_android),
          const Paragraph(
            '通过混入 WidgetsBindingObserver 可以监听应用生命周期。\n\n'
            '• resumed —— 应用可见可交互（前台活跃）\n'
            '  适合恢复动画、继续数据刷新\n'
            '• paused —— 应用不可见（进入后台）\n'
            '  适合保存草稿、暂停动画、释放不必要资源\n'
            '• inactive —— 非活跃状态（如来电、画中画）\n'
            '• detached —— 应用被宿主分离，即将销毁',
          ),
          const CodeBlock(
            r'''class _MyState extends State<MyWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _saveDraft();
    if (state == AppLifecycleState.resumed) _refresh();
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            'paused 是保存数据的绝佳时机，用户切换应用时数据不会丢失。',
            type: TipType.tip,
          ),

          // ── 4. initState ──
          const DividerLine(),
          const SectionHeader('4. initState —— 出生', icon: Icons.wb_sunny),
          const Paragraph(
            '触发时机：StatefulWidget 第一次插入 Widget 树，只一次。\n\n'
            '✅ 可以做的事：\n'
            '• 初始化成员变量\n'
            '• 创建 AnimationController（vsync: this）\n'
            '• 添加监听器，注册服务\n'
            '• 执行一次性初始化任务\n\n'
            '❌ 禁止做的事：\n'
            '• 调用 Theme.of(context) 等依赖方法（会崩溃）\n'
            '• 调用 setState（State 还没准备好）\n\n'
            '必须调用 super.initState()！',
          ),
          const CodeBlock(
            r'''@override
void initState() {
  super.initState(); // ⚠️ 必须调用！
  _controller = AnimationController(vsync: this, duration: ...);
  _focusNode = FocusNode();
  _editingController = TextEditingController();
  // ❌ 错误：Theme.of(context); // 崩溃！
}''',
            language: 'Dart',
          ),
          const TipBox(
            '忘记 super.initState() 是新手最常见的错误。\n'
            'Flutter 需要它初始化 mounted、_dirty 等内部字段。',
            type: TipType.caution,
          ),

          // ── 5. didChangeDependencies ──
          const DividerLine(),
          const SectionHeader('5. didChangeDependencies —— 依赖就绪',
              icon: Icons.link),
          const Paragraph(
            '触发时机：\n'
            '• initState 之后立即调用\n'
            '• 依赖的 InheritedWidget 发生变化时（如主题切换）\n\n'
            '✅ 可以做的事：\n'
            '• 安全获取 Theme、MediaQuery\n'
            '• 设置基于主题的初始状态\n'
            '• 订阅 Provider 等状态管理\n\n'
            '注意：可能被多次调用，避免重复耗时操作。',
          ),
          const CodeBlock(
            r'''@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final theme = Theme.of(context); // 安全！
  final media = MediaQuery.of(context);
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '大部分初始化放 initState 就够了，只有需要依赖\n'
            'InheritedWidget 时才必须用 didChangeDependencies。',
          ),

          // ── 6. build ──
          const DividerLine(),
          const SectionHeader('6. build —— 核心构建', icon: Icons.build),
          const Paragraph(
            '触发时机：\n'
            '• initState / didChangeDependencies 之后\n'
            '• setState 触发\n'
            '• didUpdateWidget 之后\n'
            '• 依赖的 InheritedWidget 数据变化\n\n'
            '核心规则：\n'
            '• 必须是纯函数 —— 相同状态产生相同 UI\n'
            '• 不能有副作用 —— 禁止 setState、网络请求\n'
            '• 不能耗时操作 —— 可能掉帧\n'
            '• build 可能被频繁调用（60fps）',
          ),
          const CodeBlock(
            r'''// ✅ 正确：只构建 UI
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(child: Text('Count: $_count')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => setState(() => _count++),
      child: const Icon(Icons.add),
    ),
  );
}
// ❌ 错误：setState(() {}); // 无限循环！
// ❌ 错误：_fetchData();    // 每次重建都请求''',
            language: 'Dart',
          ),
          const TipBox(
            '如果需要在 build 后执行操作，用\n'
            'WidgetsBinding.instance.addPostFrameCallback。',
            type: TipType.caution,
          ),

          // ── 7. didUpdateWidget ──
          const DividerLine(),
          const SectionHeader('7. didUpdateWidget —— 响应父 Widget 变化',
              icon: Icons.update),
          const Paragraph(
            '触发时机：父 Widget 重建时，如果当前 Widget 被复用。\n'
            '（类型和 key 没变，canUpdate 返回 true）\n\n'
            '典型用途：\n'
            '• 父 Widget 传入了新参数\n'
            '• 对比新旧参数，选择性响应\n'
            '• 重新加载数据或重置状态\n\n'
            '执行顺序：didUpdateWidget 在 build 之前执行。',
          ),
          const CodeBlock(
            r'''@override
void didUpdateWidget(covariant MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.userId != oldWidget.userId) {
    _loadUserData(widget.userId);
    // 不需要 setState，之后自动 build
  }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '注意：如果类型或 key 变了，旧 Widget 走 deactivate →\n'
            'dispose，新 Widget 走 initState 开始全新生命周期。',
          ),

          // ── 8. setState 与 mounted ──
          const DividerLine(),
          const SectionHeader('8. setState —— 状态更新的契约',
              icon: Icons.change_circle),
          const Paragraph(
            'setState 告诉 Flutter「状态变了，请重建」。\n'
            'Flutter 在下一帧调用 build()，状态修改应在回调中进行。\n\n'
            'mounted 属性：\n'
            '• 表示 State 对象是否还在 Widget 树中\n'
            '• initState 之后、dispose 之前为 true\n'
            '• 异步回调中必须检查 mounted！\n'
            '• mounted 为 false 时调用 setState 会抛出异常',
          ),
          const CodeBlock(
            r'''void _onDataLoaded() async {
  final result = await fetchData();
  if (mounted) { // ⚠️ 必须检查！
    setState(() => _data = result);
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '未检查 mounted 而调用 setState 是 Flutter 崩溃 Top 3。',
            type: TipType.caution,
          ),

          // ── 9. deactivate 与 dispose ──
          const DividerLine(),
          const SectionHeader('9. deactivate 和 dispose —— 销毁阶段',
              icon: Icons.exit_to_app),
          const Paragraph(
            '📌 deactivate()：从树中移除时调用。之后可能被\n'
            '重新插入（GlobalKey 切换位置）。若未重新插入则调用 dispose。\n\n'
            '📌 dispose()：永久销毁，只调用一次。必须释放所有资源！\n\n'
            '释放清单：AnimationController、TextEditingController、\n'
            'FocusNode、StreamSubscription、PageController、\n'
            'TabController、所有 addListener 的回调、removeObserver。\n\n'
            '原则：initState 创建什么，dispose 释放什么。',
          ),
          const CodeBlock(
            r'''@override
void dispose() {
  _textCtrl.dispose();
  _focusNode.dispose();
  _subscription?.cancel();
  WidgetsBinding.instance.removeObserver(this);
  super.dispose(); // 最后调用，此后 mounted = false
}''',
            language: 'Dart',
          ),
          const TipBox(
            'initState 创建什么，dispose 释放什么。super.dispose() 是最后一步。',
            type: TipType.tip,
          ),

          // ── 10. AutomaticKeepAliveClientMixin ──
          const DividerLine(),
          const SectionHeader('10. 页面保活',
              icon: Icons.energy_savings_leaf),
          const Paragraph(
            'TabBarView / PageView 中切换页面时，被切走的页面默认\n'
            '被销毁（dispose）。用 AutomaticKeepAliveClientMixin 保持存活。\n\n'
            '步骤：State 混入 mixin → wantKeepAlive 返回 true\n'
            '→ build 中调用 super.build(context)',
          ),
          const CodeBlock(
            r'''class _PageState extends State<MyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context); // ⚠️ 必须调用！
    return Column(children: [
      const Text('Tab 切换时不被销毁'),
      TextField(/* 表单数据保持 */),
    ]);
  }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '必须 super.build(context)；可运行时修改 wantKeepAlive\n'
            '（调用 updateKeepAlive）。保活页面常驻内存，不要滥用。',
          ),
          const TipBox(
            '每个保活页面都占用内存。超过 5-6 个页面时，\n'
            '只保活必要的页面，或使用缓存策略。',
            type: TipType.warning,
          ),

          // ── 11. 生命周期日志演示 ──
          const DividerLine(),
          const SectionHeader('🧪 实时生命周期日志', icon: Icons.monitor),
          const Paragraph(
            '下面是当前 StatefulWidget 的生命周期调用记录。\n'
            '点击按钮触发 setState，切换显示/隐藏子组件。',
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text('触发 setState'),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showChild = !_showChild),
                icon: Icon(_showChild
                    ? Icons.visibility_off : Icons.visibility),
                label: Text(_showChild ? '隐藏子组件' : '显示子组件'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showChild)
            Container(
              width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Text(
                '子组件已创建。隐藏触发 deactivate → dispose；\n'
                '重新显示触发 initState → didChangeDependencies → build。',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              reverse: true,
              children: _lifecycleLog.map((log) {
                Color c = Colors.white70;
                if (log.contains('▶ build')) c = Colors.greenAccent;
                else if (log.contains('📱')) c = Colors.purpleAccent;
                else if (RegExp(r'[①②③④⑤]').hasMatch(log)) {
                  c = Colors.orangeAccent;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(log, style: TextStyle(
                    fontFamily: 'monospace', fontSize: 12, color: c,
                  )),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const OutputBox('🟢 绿色 = build()   🟠 橙色 = 生命周期方法\n'
              '🟣 紫色 = 应用生命周期   mounted 实时显示'),

          // ── 12. 常见错误总结 ──
          const DividerLine(),
          const SectionHeader('⚠️ 常见错误总结', icon: Icons.error_outline),
          const Paragraph(
            '❌ 忘记 super.initState() → 直接崩溃\n'
            '❌ build 中调用 setState → 无限循环，应用卡死\n'
            '❌ 忘记 dispose 资源 → 内存泄漏，性能下降\n'
            '❌ 异步回调未检查 mounted 就 setState → 崩溃\n'
            '❌ initState 中 Theme.of(context) → 崩溃\n'
            '❌ super.dispose() 之后使用资源 → 未定义行为',
          ),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 创建一个 StatefulWidget，在每个生命周期方法中输出日志\n'
            '2. 尝试在 build 中调用 setState，观察发生了什么\n'
            '3. 创建一个 TextEditingController，忘记 dispose，用 DevTools 检查内存泄漏\n'
            '4. 在 didChangeDependencies 中获取 Theme，切换主题观察触发\n'
            '5. 在 TabBarView 中测试 AutomaticKeepAliveClientMixin 的效果',
          ),
          const SizedBox(height: 8),
          const TipBox(
            'Dart DevTools 的「Memory」标签页可以检测内存泄漏。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
