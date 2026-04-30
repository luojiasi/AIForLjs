import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第四章：生命周期 (Lifecycle)
/// StatefulWidget 从创建到销毁的完整生命周期
/// 涵盖：AppLifecycleState、mounted、KeepAlive、资源管理
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
  late final TextEditingController _textCtrl;
  int _logSeq = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textCtrl = TextEditingController();
    _addLog('① initState()', detail: 'State 对象刚创建并插入树中');
    _addLog('    时机：只调用一次 | mounted 变为 true');
    _addLog('    ✅ 可做：初始化变量、创建 Controller、添加监听');
    _addLog('    ❌ 禁止：Theme.of(context)、setState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addLog('② didChangeDependencies()',
        detail: 'initState 后立即调用，或 InheritedWidget 变化时触发');
    _addLog('    Theme.of(context) 现在安全了');
  }

  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addLog('③ didUpdateWidget()',
        detail: '父组件重建，但当前 Widget 被复用（runtimeType 和 key 都没变）');
    _addLog('    oldWidget 和 widget 可对比，选择性响应参数变化');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final labels = {
      AppLifecycleState.resumed: '前台活跃',
      AppLifecycleState.inactive: '非活跃(来电等)',
      AppLifecycleState.paused: '进入后台',
      AppLifecycleState.hidden: '完全隐藏',
      AppLifecycleState.detached: '被宿主分离',
    };
    _addLog('📱 App 生命周期: ${labels[state]} ($state)');
  }

  @override
  void deactivate() {
    super.deactivate();
    _addLog('④ deactivate()', detail: '从树中临时移除。若 GlobalKey 引用可能被重新插入');
  }

  @override
  void dispose() {
    _addLog('⑤ dispose()', detail: '永久销毁，释放所有资源。mounted 变为 false');
    WidgetsBinding.instance.removeObserver(this);
    _textCtrl.dispose();
    super.dispose();
  }

  void _addLog(String msg, {String? detail}) {
    final seq = _logSeq++;
    setState(() {
      _lifecycleLog.insert(0, '$seq $msg');
      if (detail != null) _lifecycleLog.insert(1, '   $detail');
      if (_lifecycleLog.length > 50) {
        _lifecycleLog.removeRange(50, _lifecycleLog.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _counter++;
    if (_lifecycleLog.isNotEmpty && _lifecycleLog.first.startsWith('▶')) {
      _lifecycleLog.removeAt(0);
    }
    _lifecycleLog.insert(0, '▶ build() 第$_counter 次 | mounted=$mounted');
    if (_lifecycleLog.length > 50) {
      _lifecycleLog.removeRange(50, _lifecycleLog.length);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('第4章 · 生命周期'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 生命周期全景图\n'
            '② 创建阶段：createState → initState → didChangeDependencies\n'
            '③ 构建阶段：build 方法的完整职责\n'
            '④ 更新阶段：didUpdateWidget 与热重载\n'
            '⑤ 销毁阶段：deactivate → dispose\n'
            '⑥ 应用生命周期：AppLifecycleState 完全指南\n'
            '⑦ mounted 属性：异步安全的守卫\n'
            '⑧ 页面保活：AutomaticKeepAliveClientMixin\n'
            '⑨ RestorationMixin：状态恢复\n'
            '⑩ 资源管理最佳实践\n'
            '⑪ 子组件生命周期与父子联动',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. 生命周期全景图
          // ════════════════════════════════════════════════
          const SectionHeader('1. 生命周期全景图', icon: Icons.route),
          const Paragraph(
            'State 对象的生命周期就像一个人的一生。理解它，你就能在正确的时间做正确的事。\n\n'
            '完整顺序（从生到死）：\n\n'
            '┌───────────────── 创建阶段 ────────────────┐\n'
            '│ Widget.createState()  → 构造 State 对象   │\n'
            '│ State.initState()     → 初始化             │\n'
            '│ State.didChangeDeps() → 依赖就绪           │\n'
            '│ State.build()         → 首次构建 UI        │\n'
            '└────────────────────────────────────────────┘\n'
            '         ↓\n'
            '┌───────────────── 活动阶段 ────────────────┐\n'
            '│ setState(fn)          → 标记 dirty         │\n'
            '│ State.build()         → 重建 UI             │\n'
            '│ State.didUpdateWidget → 父传入新配置         │\n'
            '│ (上述三者可能循环多次)                      │\n'
            '└────────────────────────────────────────────┘\n'
            '         ↓\n'
            '┌───────────────── 销毁阶段 ────────────────┐\n'
            '│ State.deactivate()    → 临时移除           │\n'
            '│ State.dispose()       → 永久销毁           │\n'
            '└────────────────────────────────────────────┘',
          ),
          const TipBox(
            '核心口诀：\n'
            '• 创建一次性的东西 → initState\n'
            '• 需要 context 的初始化 → didChangeDependencies\n'
            '• 构建 UI → build\n'
            '• 响应配置变化 → didUpdateWidget\n'
            '• 释放资源 → dispose',
            type: TipType.info,
          ),

          // ════════════════════════════════════════════════
          // 2. 创建阶段
          // ════════════════════════════════════════════════
          const SectionHeader('2. 创建阶段详解', icon: Icons.wb_sunny),
          const Paragraph(
            '创建阶段是 StatefulWidget 从无到有的过程，分为三步：\n\n'
            '步骤 1: Widget.createState()\n'
            '• Flutter 调用你重写的 createState() 方法\n'
            '• 创建一个 State 对象（new/const 均可）\n'
            '• 此时 State 还没有绑定 Element，mounted = false\n\n'
            '步骤 2: State.initState()\n'
            '• State 对象被绑定到 Element\n'
            '• 只调用一次（除非 Widget 的 key 改变导致重建）\n'
            '• mounted 和 context 可用，但 InheritedWidget 的依赖尚未建立\n'
            '• 这是创建 Controller、监听器、订阅的最佳位置\n\n'
            '步骤 3: State.didChangeDependencies()\n'
            '• initState 之后立即调用\n'
            '• 之后当依赖的 InheritedWidget 发生变化时也会调用\n'
            '• context.dependOnInheritedWidgetOfExactType 在此安全可用',
          ),
          const CodeBlock(
            r'''@override
void initState() {
  super.initState();  // ← 必须第一行调用

  // ✅ 在这里做：
  _animationCtrl = AnimationController(vsync: this, duration: ...);
  _focusNode = FocusNode();
  _scrollCtrl = ScrollController();
  _textCtrl = TextEditingController();
  _subscription = someStream.listen((data) { ... });

  // ✅ 首次加载数据
  _loadInitialData();

  // ❌ 不能做的事：
  // Theme.of(context);            → 崩溃！依赖未建立
  // Navigator.of(context);        → 可能崩溃
  // setState(() {});              → 调用会报错
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // ✅ 现在可以安全获取：
  final theme = Theme.of(context);
  final media = MediaQuery.of(context);
  // 如果需要基于主题的初始化，在这里做
}''',
            language: 'Dart',
          ),
          const TipBox(
            'initState 中不能使用 context 查找 InheritedWidget，因为依赖关系还没建立。\n'
            '如果确实需要 context，可以使用 WidgetsBinding.instance.addPostFrameCallback。',
            type: TipType.caution,
          ),

          // ════════════════════════════════════════════════
          // 3. 构建阶段
          // ════════════════════════════════════════════════
          const SectionHeader('3. 构建阶段 —— build 方法', icon: Icons.build_circle),
          const Paragraph(
            'build 是生命周期中调用最频繁的方法。它把一个 State 变成一棵 Widget 树。\n\n'
            '调用时机（五种）：\n'
            '1. initState / didChangeDependencies 之后（首次构建）\n'
            '2. setState 被调用后\n'
            '3. didUpdateWidget 被调用后\n'
            '4. 依赖的 InheritedWidget 数据变化后\n'
            '5. 父 Widget 重建导致子 Widget 需要更新\n\n'
            'build 的铁律：\n'
            '• 必须是纯函数 —— 给定相同的 State，总是返回相同的 Widget 树\n'
            '• 禁止副作用 —— 不能发网络请求、不能写数据库、不能 setState\n'
            '• 不能耗时 —— build 卡顿直接导致掉帧\n'
            '• 不持有外部引用 —— 只依赖 this.state 和 this.widget 以及 context',
          ),
          const CodeBlock(
            r'''// ✅ 好的 build
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

// ❌ 坏的 build
@override
Widget build(BuildContext context) {
  _fetchData();         // ← 每次重建都发网络请求！
  saveToDb(_count);     // ← 副作用！
  return ...;
}

// ✅ 首次构建后执行操作
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // 在这里做需要在首次渲染后的操作
    _showOnboardingDialog();
  });
}''',
            language: 'Dart',
          ),
          const TipBox(
            'build 可能被调用数百次！不要在其中做任何一次性操作。\n'
            '首次数据加载放 initState，配置响应放 didUpdateWidget。',
            type: TipType.warning,
          ),

          // ════════════════════════════════════════════════
          // 4. 更新阶段
          // ════════════════════════════════════════════════
          const SectionHeader('4. 更新阶段 —— didUpdateWidget', icon: Icons.update),
          const Paragraph(
            '当父 Widget 重建时，如果当前子 Widget 被复用（runtimeType 和 key 都没变），\n'
            'Flutter 调用 didUpdateWidget(oldWidget) 而不是 initState。\n\n'
            '调用顺序：父 Widget 重建 → 子 Widget 的 didUpdateWidget(oldWidget) → build\n\n'
            '关键理解：\n'
            '• oldWidget 参数持有旧 Widget 的引用，widget 属性已指向新 Widget\n'
            '• 可以对比新旧 widget 的字段来决定是否需要重新加载数据\n'
            '• 对比发生在 build 之前 → 如果确定不需要重建，可以提前 return\n\n'
            '典型场景：\n'
            '• 路由参数变化：/user/123 → /user/456（widget.userId 变了但 Widget 类型没变）\n'
            '• 父传入的新数据：List 长度变了但 ListView 的 key 没变\n'
            '• 主题/语言切换：widget 的样式参数可能变化',
          ),
          const CodeBlock(
            r'''@override
void didUpdateWidget(covariant UserDetailWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  // 如果 userId 变了，重新加载用户数据
  if (widget.userId != oldWidget.userId) {
    _loadUser(widget.userId);  // 异步加载
  }

  // 如果只是一个不相关的属性变了，跳过
  if (widget.title != oldWidget.title) {
    // title 变了 → build 会自然反映新值，不需要额外操作
  }

  // ⚠️ 注意：调用 setState 在这里是多余的，build 会自动触发
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '热重载（Hot Reload）与 didUpdateWidget：\n\n'
            '热重载会触发所有 Widget 的 reassemble() 方法，不是 didUpdateWidget。\n'
            'reassemble() 只在 debug 模式调用，release 模式不会触发。\n'
            '它是 Flutter 团队为了开发体验做的特殊处理。\n\n'
            '如果你需要在热重载时保存/恢复状态，可以 override reassemble()：',
          ),
          const CodeBlock(
            r'''@override
void reassemble() {
  super.reassemble();
  // debug 模式下热重载时触发
  // 可以在这里做状态重置以确保一致性
  _reinitializeDebugState();
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 5. 销毁阶段
          // ════════════════════════════════════════════════
          const SectionHeader('5. 销毁阶段 —— deactivate 与 dispose', icon: Icons.exit_to_app),
          const Paragraph(
            '销毁阶段分为两步，deactivate 是"还有机会回头的"，dispose 是"彻底没了"。\n\n'
            'deactivate()：\n'
            '• Widget 从树上移除（但不一定销毁！）\n'
            '• 如果 Element 被 GlobalKey 引用，可能被重新插入（activate）\n'
            '• 如果在一定帧数内没有被重新插入 → 进入 dispose\n'
            '• 此时 State 仍在内存中，只是不再渲染\n\n'
            'dispose()：\n'
            '• 永久销毁，State 对象将从内存中释放\n'
            '• mounted 变为 false → 不能再调用 setState\n'
            '• 必须释放所有在 initState 中创建的资源\n'
            '• super.dispose() 必须是最后一行',
          ),
          const CodeBlock(
            r'''@override
void dispose() {
  // 1. 释放动画控制器
  _animationCtrl.dispose();

  // 2. 释放焦点节点
  _focusNode.dispose();

  // 3. 释放文本控制器
  _textCtrl.dispose();

  // 4. 释放滚动控制器
  _scrollCtrl.dispose();

  // 5. 取消流订阅
  _subscription?.cancel();

  // 6. 移除观察者
  WidgetsBinding.instance.removeObserver(this);

  // 7. 最后调用 super
  super.dispose();  // 此后 mounted = false
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 6. 应用生命周期
          // ════════════════════════════════════════════════
          const SectionHeader('6. 应用生命周期 (AppLifecycleState)', icon: Icons.phone_android),
          const Paragraph(
            '通过 WidgetsBindingObserver 混入，你可以监听整个 App 的前后台切换。\n'
            '这对于"保存用户数据"、"暂停动画"、"停止网络请求"等场景至关重要。\n\n'
            '五个状态详解：\n\n'
            '1. resumed —— App 回到前台，完全可见且可交互\n'
            '   这是用户正常使用 App 的状态。适合：恢复动画、继续播放、重新建立连接\n\n'
            '2. inactive —— 非活跃过渡态\n'
            '   例：来电时 App 半透明、进入多任务视图（但不滑到另一应用）\n'
            '   通常很短暂，适合：暂停敏感操作但不要释放重要资源\n\n'
            '3. paused —— App 进入后台，完全不可见\n'
            '   用户按 Home 键或切换到其他 App\n'
            '   适合：保存草稿、暂停动画、释放相机/麦克风等系统资源\n\n'
            '4. hidden —— App 被隐藏（Flutter 3.13+）\n'
            '   macOS/Windows 桌面应用的窗口被最小化等\n\n'
            '5. detached —— App 即将被宿主销毁\n'
            '   像 Android 上 Activity 被销毁前的最后通知',
          ),
          const CodeBlock(
            r'''// ─ 完整实现 ─
class _MyState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);  // 注册
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // 必须移除！
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _animationCtrl.forward();         // 恢复动画
        _startDataRefreshTimer();         // 恢复数据刷新
        break;
      case AppLifecycleState.paused:
        _animationCtrl.stop();            // 暂停动画
        _saveDraftToDisk();               // 保存草稿
        _stopDataRefreshTimer();          // 停止刷新
        break;
      case AppLifecycleState.inactive:
        // 短暂过渡，一般不需要处理
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // 释放大资源
        _releaseImageCache();
        break;
    }
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '生产建议：\n'
            '• paused 是保存数据的黄金时机——用户切换 App 时数据不会丢\n'
            '• resumed 时重新检查登录状态、刷新到期 Token\n'
            '• 相机、麦克风、GPS 等系统资源必须在 paused 时释放',
            type: TipType.info,
          ),

          // ════════════════════════════════════════════════
          // 7. mounted
          // ════════════════════════════════════════════════
          const SectionHeader('7. mounted —— 异步安全的守卫', icon: Icons.shield),
          const Paragraph(
            'mounted 是 State 对象的一个 bool 属性，表示 State 当前是否在 Widget 树中（active 状态）。\n\n'
            'mounted 的状态变化：\n'
            '• 构造 State 时：mounted = false\n'
            '• initState 调用后：mounted = true\n'
            '• dispose 调用 super.dispose() 后：mounted = false\n\n'
            '为什么需要 mounted？\n'
            '异步操作的回调是在未来某个时间执行的，那时用户可能已经关闭了页面。\n'
            '如果不检查 mounted 就调用 setState，会抛出异常导致应用崩溃。',
          ),
          const CodeBlock(
            r'''// ✅ 安全模式：每次异步回调都检查
Future<void> _loadData() async {
  final data = await api.fetchSomeData();     // 可能耗时数秒
  if (!mounted) return;                       // 用户已经关掉页面了
  setState(() => _data = data);
}

// ✅ 多个异步操作，每次 await 后都检查
Future<void> _loadMultiple() async {
  final user = await api.getUser();
  if (!mounted) return;
  setState(() => _user = user);

  final posts = await api.getPosts(user.id);
  if (!mounted) return;
  setState(() => _posts = posts);
}

// ✅ Timer/Delayed 也要检查
void _startTimer() {
  Timer(const Duration(seconds: 5), () {
    if (!mounted) return;
    setState(() => _showReminder = true);
  });
}

// ❌ 崩溃源头
Future<void> _bad() async {
  final data = await slowApi();  // 用户点了返回按钮
  setState(() {});               // 💥 崩溃！mounted = false
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 8. 页面保活
          // ════════════════════════════════════════════════
          const SectionHeader('8. 页面保活 (KeepAlive)', icon: Icons.energy_savings_leaf),
          const Paragraph(
            '在 TabBarView、PageView 中，默认行为是切换页面时销毁旧页面。\n'
            '如果希望保持页面状态（输入框内容、滚动位置等），使用 AutomaticKeepAliveClientMixin。\n\n'
            '原理：\n'
            '• 混入后，Element 不会在不可见时 deactivate\n'
            '• 页面保持在内存中，状态完好无损\n'
            '• 重新切换到该页面时直接复用，不重建\n\n'
            '使用步骤：\n'
            '1. State 类混入 AutomaticKeepAliveClientMixin\n'
            '2. 重写 wantKeepAlive 返回 true\n'
            '3. 在 build 方法开头调用 super.build(context)\n'
            '4. 可选：运行时调用 updateKeepAlive() 动态改变保活状态',
          ),
          const CodeBlock(
            r'''class _TabPageState extends State<TabPage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;  // 告诉框架：这个页面要保持存活

  @override
  Widget build(BuildContext context) {
    super.build(context);  // ← 必须调用！框架需要它注入 KeepAlive 节点
    return ListView(
      children: [
        TextField(...),  // Tab 切换后输入内容不丢
        // ...
      ],
    );
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '性能提醒：\n'
            '每个保活页面都持续占用内存。3-5 个页面无所谓，超过 10 个页面建议使用缓存策略。\n'
            '可以动态修改 wantKeepAlive（调用 updateKeepAlive）来实现按需保活。',
            type: TipType.warning,
          ),

          // ════════════════════════════════════════════════
          // 9. RestorationMixin
          // ════════════════════════════════════════════════
          const SectionHeader('9. RestorationMixin —— 状态恢复', icon: Icons.restore),
          const Paragraph(
            'Android 系统可能在低内存时杀掉后台的 Activity。\n'
            '当用户返回 App 时，RestorationMixin 帮你恢复之前的状态。\n\n'
            '使用场景：\n'
            '• 输入框中的草稿内容\n'
            '• 表单填写了一半的数据\n'
            '• 滚动列表的位置\n\n'
            '工作原理：\n'
            '1. 使用 RestorableProperty 系列类（RestorableInt, RestorableString 等）包装状态\n'
            '2. 框架在 App 暂停时自动序列化这些值\n'
            '3. App 恢复时自动反序列化并恢复状态',
          ),
          const CodeBlock(
            r'''class _MyFormState extends State<MyForm> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);
  final RestorableString _text = RestorableString('');

  @override
  String? get restorationId => 'my_form';  // 必须在 Widget 树中唯一

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
    registerForRestoration(_text, 'text');
  }

  @override
  void dispose() {
    _counter.dispose();  // Restorable 也需要 dispose！
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: ${_counter.value}'),
        TextField(
          onChanged: (v) => _text.value = v,
        ),
      ],
    );
  }
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 10. 资源管理
          // ════════════════════════════════════════════════
          const SectionHeader('10. 资源管理最佳实践', icon: Icons.cleaning_services),
          const Paragraph(
            'Flutter 开发中最常见的资源泄漏（Memory Leak）就是忘记 dispose。\n\n'
            '需要 dispose 的常见资源清单：\n\n'
            '动画类：AnimationController、CurvedAnimation、Ticker\n'
            '控制器：TextEditingController、ScrollController、PageController、TabController\n'
            '焦点：FocusNode、FocusScopeNode\n'
            '流：StreamSubscription、StreamController\n'
            'Timer：Timer（需 cancel）\n'
            '监听器：addListener 的匿名函数、addObserver 的注册\n'
            '平台通道：MethodChannel、EventChannel\n'
            '动画：AnimationController\n\n'
            '黄金法则：initState 中创建的，dispose 中释放。一一对应，不遗漏。',
          ),
          const CodeBlock(
            r'''// ✅ 标准资源管理模式
class MyWidget extends StatefulWidget { ... }

class _MyWidgetState extends State<MyWidget>
    with TickerProviderStateMixin {
  // 声明
  late final AnimationController _animCtrl;
  late final TextEditingController _textCtrl;
  late final ScrollController _scrollCtrl;
  late final FocusNode _focusNode;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: ...);
    _textCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _focusNode = FocusNode();
    _sub = someStream.listen(_onData);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _sub?.cancel();
    super.dispose();  // 最后
  }
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 11. 子组件生命周期
          // ════════════════════════════════════════════════
          const SectionHeader('11. 子组件的生命周期与父子联动', icon: Icons.account_tree),
          const Paragraph(
            '当父 StatefulWidget 重建时，它的子组件的生命周期如何变化？\n\n'
            '情况1：子组件是 StatelessWidget\n'
            '→ 每次父 rebuild，子 StatelessWidget 都重新 build\n'
            '→ 底层 Element 被复用（类型没变）→ 仅更新 Widget 引用\n\n'
            '情况2：子组件是 StatefulWidget（key 不变）\n'
            '→ 子 State 对象的 didUpdateWidget 被调用（不是 initState）\n'
            '→ 然后 build 被调用\n'
            '→ 内部状态保持！\n\n'
            '情况3：子组件是 StatefulWidget（key 变了）\n'
            '→ 旧子 State 走 deactivate → dispose\n'
            '→ 新子 State 走 initState → didChangeDependencies → build\n'
            '→ 内部状态全部丢失！\n\n'
            '情况4：子组件从 Widget 树中被移除\n'
            '→ 直接走 deactivate → dispose\n'
            '→ 即使父组件还活着',
          ),

          // ════════════════════════════════════════════════
          // 12. 常见错误
          // ════════════════════════════════════════════════
          const SectionHeader('12. 常见错误 Top 10', icon: Icons.error_outline),
          const Paragraph(
            '1. 忘记 super.initState() —— 直接崩溃\n'
            '2. 忘记 super.dispose() —— mounted 不会变为 false，后续 setState 检查失效\n'
            '3. build 中调用 setState —— 无限循环，应用卡死\n'
            '4. 忘记 dispose 控制器 —— 内存泄漏，设备发烫\n'
            '5. 异步回调未检查 mounted —— 崩溃\n'
            '6. initState 中使用 context 查找 InheritedWidget —— 崩溃\n'
            '7. dispose 顺序错误（super.dispose 放中间） —— 逻辑错误\n'
            '8. 不删除 WidgetsBindingObserver —— 内存泄漏\n'
            '9. 不取消 Timer —— 页面关了 Timer 还在跑\n'
            '10. AutomaticKeepAliveClientMixin 忘记 super.build(context) —— 不生效',
          ),

          // ════════════════════════════════════════════════
          // 13. 交互演示
          // ════════════════════════════════════════════════
          const SectionHeader('🧪 实时生命周期日志', icon: Icons.monitor),
          const Paragraph('点击按钮触发 setState、切换子组件可见性，观察生命周期方法的调用顺序。'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('触发 setState'),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showChild = !_showChild),
              icon: Icon(_showChild ? Icons.visibility_off : Icons.visibility),
              label: Text(_showChild ? '隐藏子组件' : '显示子组件'),
            ),
          ]),
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
              child: _LifecycleChild(
                onLog: (msg) => setState(() {
                  _lifecycleLog.insert(0, '👶 子: $msg');
                  if (_lifecycleLog.length > 50) _lifecycleLog.removeRange(50, _lifecycleLog.length);
                }),
              ),
            ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
            constraints: const BoxConstraints(maxHeight: 350),
            child: ListView(
              reverse: true,
              children: _lifecycleLog.map((log) {
                Color c = Colors.white70;
                if (log.contains('▶ build')) c = Colors.greenAccent;
                if (log.contains('📱')) c = Colors.purpleAccent;
                if (RegExp(r'[①②③④⑤]').hasMatch(log) || log.contains('👶')) c = Colors.orangeAccent;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(log, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: c, height: 1.3)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const OutputBox('🟢 绿色 = build()  🟠 橙色 = 生命周期方法  🟣 紫色 = App 生命周期\n👶 = 子组件生命周期'),

          // ════════════════════════════════════════════════
          // 14. 总结
          // ════════════════════════════════════════════════
          const SectionHeader('14. 总结', icon: Icons.summarize),
          const Paragraph(
            'StatefulWidget 生命周期核心口诀：\n\n'
            '生：initState → 初始化资源\n'
            '依赖：didChangeDependencies → 获取 InheritedWidget\n'
            '构：build → 构建 UI 树\n'
            '改：didUpdateWidget → 响应父组件变化\n'
            '灭：deactivate → dispose → 释放资源\n\n'
            '安全底线：\n'
            '• 每个 initState 中创建的资源，在 dispose 中释放\n'
            '• 每个异步 await 后，检查 if (!mounted) return;\n'
            '• 每个 WidgetsBindingObserver 注册必须有对应的 removeObserver',
          ),

          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 创建 StatefulWidget，在每个生命周期方法中 print 日志，观察完整顺序\n'
            '2. 尝试在异步回调中不检查 mounted 就 setState → 出现崩溃\n'
            '3. 用 AutomaticKeepAliveClientMixin 做一个 TabBarView，切换 Tab 不丢数据\n'
            '4. 在 didUpdateWidget 中对比新旧参数，选择性重新加载数据\n'
            '5. 实现 AppLifecycleState 监听，切换到后台时保存草稿\n'
            '6. 故意忘记 dispose 一个 AnimationController，用 DevTools 检测内存泄漏',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 演示用子组件 —— 观察子组件的生命周期
class _LifecycleChild extends StatefulWidget {
  final void Function(String msg) onLog;
  const _LifecycleChild({required this.onLog});

  @override
  State<_LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<_LifecycleChild> {
  @override
  void initState() {
    super.initState();
    widget.onLog('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onLog('didChangeDeps');
  }

  @override
  void didUpdateWidget(covariant _LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onLog('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.onLog('deactivate');
  }

  @override
  void dispose() {
    widget.onLog('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onLog('build');
    return const Text(
      '子组件已创建。隐藏触发 deactivate → dispose；\n重新显示触发 initState → didChangeDependencies → build。',
      style: TextStyle(fontSize: 13, color: Colors.black54),
    );
  }
}
