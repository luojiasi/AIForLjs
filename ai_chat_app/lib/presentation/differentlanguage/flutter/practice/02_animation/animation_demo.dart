import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第二章：动画大全
/// 从零开始掌握 Flutter 动画系统
/// 涵盖：隐式动画、显式动画、Tween、Curve、交错动画、Hero、
///       Transition 系列、TweenSequence、自定义 Tween、
///       物理动画、Lottie、性能优化
/// ============================================================

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo>
    with TickerProviderStateMixin {
  // ── 隐式动画状态 ──
  bool _isExpanded = false;
  double _opacity = 1.0;
  double _containerWidth = 120.0;
  double _containerHeight = 120.0;
  Color _containerColor = Colors.blue;
  double _containerRadius = 12.0;

  // ── 显式动画控制器 ──
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _curvedAnimation;

  // ── 交错动画 ──
  late final AnimationController _staggeredController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;

  // ── 旋转动画 ──
  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;

  // ── 新增：颜色动画 ──
  late final AnimationController _colorController;
  late final Animation<Color?> _colorAnim;

  // ── 新增：TweenSequence ──
  late final AnimationController _sequenceController;
  late final Animation<double> _sequenceAnim;

  // ── 新增：AnimatedSwitcher ──
  int _switchIndex = 0;

  // ── 新增：AnimatedList ──
  final _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = ['苹果', '香蕉', '橘子'];
  int _nextId = 4;

  @override
  void initState() {
    super.initState();

    // 1. 基础显式动画
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animation = Tween<double>(begin: 0, end: 300).animate(_curvedAnimation);

    _controller.addStatusListener((status) {
      debugPrint('动画状态变化: $status');
    });

    // 2. 交错动画
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );
    _slideAnim = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // 3. 旋转动画
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.linear),
    );

    // 4. 颜色动画（ColorTween）
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _colorAnim = ColorTween(begin: Colors.blue, end: Colors.orange).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    // 5. TweenSequence
    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sequenceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),   // 第1段：从0到1
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),   // 第2段：回弹到0.5
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),   // 第3段：再到1
    ]).animate(_sequenceController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _staggeredController.dispose();
    _spinController.dispose();
    _colorController.dispose();
    _sequenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第2章 · 动画大全'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ══════════════════════════════════════════════════
          // 章节目录
          // ══════════════════════════════════════════════════
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 动画是什么 —— 从现实中理解 Flutter 动画原理\n'
            '② Ticker 与 vsync —— 动画的"心跳"机制\n'
            '③ 隐式动画：AnimatedContainer / AnimatedOpacity 全家桶\n'
            '④ TweenAnimationBuilder —— 万能隐式动画\n'
            '⑤ 显式动画核心：AnimationController + Tween + Curve\n'
            '⑥ AnimatedBuilder vs AnimatedWidget\n'
            '⑦ CurvedAnimation 与内置曲线大全\n'
            '⑧ Transition 系列组件\n'
            '⑨ TweenSequence —— 分阶段动画\n'
            '⑩ 交错动画（Staggered Animation）\n'
            '⑪ 颜色动画与 ColorTween\n'
            '⑫ Hero 共享元素过渡\n'
            '⑬ AnimatedSwitcher / AnimatedList\n'
            '⑭ 性能优化与最佳实践',
          ),
          const DividerLine(),

          // ══════════════════════════════════════════════════
          // 1. 动画是什么
          // ══════════════════════════════════════════════════
          const SectionHeader('1. 动画是什么？', icon: Icons.help_outline),
          const Paragraph(
            '在 Flutter 中，动画（Animation）本质上是一种 "随时间变化的值"。\n\n'
            '想象你看电影：每秒 24 张静态图片快速切换，人眼就产生了"动"的错觉。\n'
            'Flutter 动画的原理完全一样 —— 每 16 毫秒（60fps）重新渲染一帧，\n'
            '每帧中某个属性的值稍有不同，连起来就是动画。\n\n'
            'Flutter 动画系统的核心对象只有三个：\n'
            '• Animation<double> —— 动画的"值"（生成 0.0 ~ 1.0 之间的一系列数字）\n'
            '• AnimationController —— 动画的"发动机"（控制播放/暂停/停止/循环）\n'
            '• Tween —— 动画的"翻译官"（把 0~1 映射到你需要的范围，比如 0~300px）\n\n'
            '这三者的关系可以类比为：\n'
            '• AnimationController = 发动机（输出从 0 到 1 的油量）\n'
            '• Tween = 变速箱（把发动机转速翻译成车轮转速）\n'
            '• Curve = 油门曲线（控制加速快慢的感觉）\n'
            '• AnimatedBuilder = 仪表盘（把变速箱输出显示成速度表）',
          ),
          const TipBox(
            'Flutter 动画的关键理念：动画改变的是"值"，不是 Widget。\n'
            '每一帧中，Animation 对象的值发生变化 → setState 或 AnimatedBuilder 触发重建 → 新值渲染出新的 UI。\n'
            '这就是为什么动画代码里几乎一定有 setState 或 AnimatedBuilder。',
            type: TipType.info,
          ),

          // ══════════════════════════════════════════════════
          // 2. Ticker 与 vsync
          // ══════════════════════════════════════════════════
          const SectionHeader('2. Ticker 与 vsync —— 动画的"心跳"', icon: Icons.timer),
          const Paragraph(
            'Ticker（计时器）是 Flutter 动画系统的底层机制。它每秒触发约 60 次回调，\n'
            '每次回调代表一帧，回调中会计算当前帧动画的数值。\n\n'
            'Ticker 的特点：\n'
            '1. 与屏幕刷新率同步（60Hz 屏幕 = 每秒 60 帧，120Hz = 每秒 120 帧）\n'
            '2. 当 Widget 不可见时自动暂停（节省 CPU/GPU）\n'
            '3. 每个 Ticker 需要绑定一个 vsync（垂直同步信号）\n\n'
            'vsync 是什么？\n'
            'vsync 是 Flutter 的"垂直同步"参数。你需要使用 TickerProvider 来提供 vsync。\n'
            'TickerProviderStateMixin 让 State 类变成 TickerProvider，然后通过 vsync: this 传给 Controller。\n\n'
            '为什么 vsync 重要？\n'
            '• 防止动画在不可见时浪费 CPU 性能\n'
            '• 防止内存泄漏（页面销毁时自动停掉 Ticker）\n'
            '• 确保动画帧率与屏幕刷新率同步',
          ),
          const CodeBlock(
            r'''// ❌ 错误：没有 vsync
_controller = AnimationController(duration: Duration(seconds: 1));
// 编译器报错：缺少必填参数 vsync

// ✅ 正确写法
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {  // ← 混入这个
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,       // ← 必须传 this
      duration: const Duration(seconds: 1),
    );
  }
}

// 如果有多个 AnimationController，用 TickerProviderStateMixin
class _MultiAnimState extends State<MyWidget>
    with TickerProviderStateMixin {  // 注意：没有 Single
  // 可以创建多个 Controller，都传 vsync: this
}''',
            language: 'Dart',
          ),
          const TipBox(
            '记忆口诀：单动画用 SingleTickerProviderStateMixin，多动画用 TickerProviderStateMixin。\n'
            '如果只用一个 Controller 但用了 TickerProviderStateMixin，功能正常但稍浪费。\n'
            '如果多个 Controller 却用了 Single，运行时报错。',
            type: TipType.caution,
          ),

          // ══════════════════════════════════════════════════
          // 3. 两种动画
          // ══════════════════════════════════════════════════
          const SectionHeader('3. 两种动画：隐式 vs 显式', icon: Icons.compare_arrows),
          const Paragraph(
            'Flutter 提供两种制作动画的方式，就像开车有自动挡和手动挡：\n\n'
            '隐式动画（Implicit Animation）—— 自动挡\n'
            '• 你只需要改变目标值（新的宽度、颜色、透明度等），Flutter 自动帮你补间过渡\n'
            '• 组件名规律：Animated + 属性名，如 AnimatedContainer、AnimatedOpacity\n'
            '• 优点：代码极少，声明式写法\n'
            '• 缺点：不能控制播放进度、不能循环、不能暂停\n\n'
            '显式动画（Explicit Animation）—— 手动挡\n'
            '• 你需要自己创建 AnimationController 并调用 forward() / reverse() / repeat()\n'
            '• 组件名规律：属性名 + Transition，如 FadeTransition、ScaleTransition\n'
            '• 优点：完全控制播放状态、可以循环反转暂停、可以组合交错\n'
            '• 缺点：代码量较大，需要管理 Controller 生命周期',
          ),
          const TipBox(
            '选择原则：\n'
            '90% 的场景用隐式动画就够了。只有当需要循环、反向播放、或精确控制进度时才用显式动画。\n'
            '如果发现自己在隐式动画里 hack 循环效果，就该换显式动画了。',
            type: TipType.tip,
          ),

          // ══════════════════════════════════════════════════
          // 4. 隐式动画家族
          // ══════════════════════════════════════════════════
          const SectionHeader('4. 隐式动画家族全解', icon: Icons.blur_on),
          const Paragraph(
            '隐式动画是 Flutter 中最容易上手的动画方式。只需指定目标值，Flutter 自动计算中间帧。\n'
            '所有隐式动画组件都接受 duration（时长）和 curve（曲线）两个关键参数。\n\n'
            '隐式动画全家桶：'),
          const CodeBlock(
            r'''// 容器属性动画 —— 最常用
AnimatedContainer({duration, curve, width, height, color, margin, padding,
  decoration, alignment, transform, ...})

// 透明度
AnimatedOpacity({duration, curve, opacity})

// 内边距
AnimatedPadding({duration, curve, padding})

// 对齐
AnimatedAlign({duration, curve, alignment})

// 定位（Stack 中使用）
AnimatedPositioned({duration, curve, left, top, width, height, ...})

// 默认文本样式
AnimatedDefaultTextStyle({duration, curve, style})

// 物理模型（阴影深度）
AnimatedPhysicalModel({duration, curve, shape, elevation, color, ...})

// 旋转（围绕指定点）
AnimatedRotation({duration, curve, turns})

// 缩放
AnimatedScale({duration, curve, scale})

// 平移
AnimatedSlide({duration, curve, offset})

// 裁切
AnimatedSize({duration, curve, alignment, ...})

// 交叉淡入淡出
AnimatedCrossFade({duration, firstChild, secondChild, crossFadeState, ...})

// 切换动画
AnimatedSwitcher({duration, switchInCurve, switchOutCurve, transitionBuilder, ...})

// 列表增删动画
AnimatedList({initialItemCount, itemBuilder, ...})

// 主题切换动画
AnimatedTheme({duration, curve, data})''',
            language: 'Dart',
          ),
          const Paragraph(
            '所有这些组件的使用模式完全一致：\n'
            '1. 声明一个 StatefulWidget（因为要改变状态）\n'
            '2. 在 State 中定义属性变量\n'
            '3. 改变属性 → setState → 组件自动产生动画过渡\n'
            '4. 每个组件都接受 duration（必须）和 curve（可选，默认 Curves.linear）',
          ),

          const DividerLine(),

          // ── AnimatedContainer 深入 ──
          const SectionHeader('4.1 AnimatedContainer 深入', icon: Icons.crop_square),
          const Paragraph(
            'AnimatedContainer 是隐式动画中使用频率最高的组件。\n'
            '它的核心逻辑非常简单：\n\n'
            '• 每次 build 时，比较新旧属性值\n'
            '• 如果不同，启动一个 timer，在 duration 时间内从旧值平滑过渡到新值\n'
            '• 过渡过程中不断 setState，用当前中间值渲染\n\n'
            'AnimatedContainer 支持的动画属性（几乎所有 Container 的属性都支持）：\n'
            '• width / height —— 尺寸变化\n'
            '• color —— 颜色变化\n'
            '• padding / margin —— 间距变化\n'
            '• decoration —— 完整装饰（渐变色、边框、圆角、阴影）\n'
            '• alignment —— 对齐方式\n'
            '• transform —— 变换（旋转、缩放、平移的矩阵形式）\n'
            '• constraints —— 约束条件\n\n'
            '注意事项：\n'
            '1. 只有 AnimatedContainer 自身的属性才会产生动画，子组件的属性不会\n'
            '2. decoration 变化时，新旧 decoration 会按属性逐一过渡，不是整体替换\n'
            '3. 如果某个属性变化了但没看到动画，检查是否在 setState 中修改',
          ),
          const CodeBlock(
            r'''AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  // 所有以下属性变化都会产生动画
  width: _isBig ? 200 : 80,
  height: _isBig ? 200 : 80,
  decoration: BoxDecoration(
    color: _isBig ? Colors.blue : Colors.red,
    borderRadius: BorderRadius.circular(_isBig ? 30 : 8),
    boxShadow: [
      BoxShadow(
        color: (_isBig ? Colors.blue : Colors.red).withOpacity(0.4),
        blurRadius: _isBig ? 20 : 4,
      ),
    ],
  ),
  child: const Center(child: Text('点我')),
)''',
            language: 'Dart',
          ),

          // 交互演示: AnimatedContainer
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: _isExpanded ? 200 : 100,
                height: _isExpanded ? 200 : 100,
                decoration: BoxDecoration(
                  color: _isExpanded ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(_isExpanded ? 20 : 10),
                  boxShadow: [
                    BoxShadow(
                      color: (_isExpanded ? Colors.blue : Colors.red).withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('点我', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ),
          OutputBox(
            '大小: ${_isExpanded ? "200x200" : "100x100"}  颜色: ${_isExpanded ? "蓝" : "红"}\n'
            '圆角: ${_isExpanded ? "20" : "10"}  状态值 _isExpanded = $_isExpanded',
          ),

          const DividerLine(),

          // ── 4.2 AnimatedOpacity ──
          const SectionHeader('4.2 AnimatedOpacity', icon: Icons.opacity),
          const Paragraph(
            'AnimatedOpacity 控制子组件的透明度从 0.0（完全透明）到 1.0（完全不透明）。\n\n'
            '关键点：即使 opacity 为 0，子组件仍然占空间且可以响应点击！\n'
            '如果希望完全隐藏且不占空间，用 AnimatedSwitcher 或者结合 AnimatedSize。\n\n'
            '性能注意：opacity 变化会触发每次重绘整个子组件树。如果子组件复杂，\n'
            '考虑用 FadeTransition（显式动画）替代，性能更好。',
          ),
          Center(
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('淡入淡出', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _opacity = _opacity == 1.0 ? 0.0 : 1.0),
                  child: Text(_opacity == 1.0 ? '隐藏' : '显示'),
                ),
              ],
            ),
          ),

          const DividerLine(),

          // ── 4.3 多属性联动 ──
          const SectionHeader('4.3 多属性联动演示', icon: Icons.dashboard_customize),
          const Paragraph('下面展示 AnimatedContainer 的多个属性同时动画。拖动滑块改变目标值，观察宽度、高度、颜色、圆角同时过渡。'),
          ..._buildMultiAnimatedDemo(),

          // ══════════════════════════════════════════════════
          // 5. TweenAnimationBuilder
          // ══════════════════════════════════════════════════
          const SectionHeader('5. TweenAnimationBuilder —— 万能隐式动画', icon: Icons.build_circle),
          const Paragraph(
            'TweenAnimationBuilder 被称为"隐式动画的终结者"，因为它可以对任何属性产生动画。\n\n'
            '原理：\n'
            '1. 你指定一个 Tween（起始值 → 目标值）和一个 builder 函数\n'
            '2. 当目标值改变时，builder 会被多次调用，每次传入不同的中间值\n'
            '3. 你在 builder 中用当前值构造任意 Widget\n\n'
            'TweenAnimationBuilder 的三个必填参数：\n'
            '• tween: Tween<T> —— 定义值的起始和结束范围\n'
            '• duration: Duration —— 动画时长\n'
            '• builder: (BuildContext, T, Widget?) → Widget —— 用中间值构建 UI\n\n'
            '第3个参数 child 是可选的"静态子组件"，不会随动画重建，用于性能优化。',
          ),
          const CodeBlock(
            r'''TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0, end: 1),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOutBack,
  builder: (BuildContext context, double value, Widget? child) {
    // value 从 begin 平滑过渡到 end
    // 你可以用 value 计算任意属性
    return Opacity(
      opacity: value,                     // 淡入
      child: Transform.scale(
        scale: 0.5 + value * 0.5,        // 放大
        child: child,                     // 不变的子组件
      ),
    );
  },
  child: Text('Hello'),  // 这个不会随动画重建
)''',
            language: 'Dart',
          ),
          const Paragraph(
            'TweenAnimationBuilder 的类型参数 T 可以是：\n'
            '• double —— 最常见，用于尺寸、位置、透明度\n'
            '• Color —— 颜色过渡（用 ColorTween）\n'
            '• Size —— 尺寸对象过渡\n'
            '• Offset —— 位移过渡\n'
            '• Alignment —— 对齐方式过渡\n'
            '• 甚至是自定义类型 —— 只要你提供正确的 Tween 子类',
          ),
          _TweenAnimationDemo(),

          // ══════════════════════════════════════════════════
          // 6. AnimationController
          // ══════════════════════════════════════════════════
          const SectionHeader('6. AnimationController —— 显式动画的核心', icon: Icons.tune),
          const Paragraph(
            'AnimationController 是显式动画的"发动机"，它产生从 0.0 到 1.0 的连续值。\n\n'
            'AnimationController 的关键属性和方法：\n\n'
            '属性：\n'
            '• value —— 当前值（0.0 ~ 1.0），双击可读写\n'
            '• duration —— 动画时长（从 0 到 1 的总耗时）\n'
            '• vsync —— TickerProvider，防止后台消耗\n'
            '• status —— 当前状态：forward（正在播放）/ reverse（正在倒放）/ completed（播完）/ dismissed（回位）\n'
            '• lowerBound —— 下限（默认 0.0）\n'
            '• upperBound —— 上限（默认 1.0）\n\n'
            '控制方法：\n'
            '• forward() —— 正向播放（0 → 1），返回 Future<void>，播完才完成\n'
            '• reverse() —— 反向播放（1 → 0），返回 Future<void>\n'
            '• repeat({min, max, reverse, period}) —— 循环播放\n'
            '• reset() —— 重置到 lowerBound（默认 0）\n'
            '• stop() —— 停止在当前帧\n'
            '• animateTo(target) —— 播放到指定位置\n'
            '• animateBack(target) —— 反向播放到指定位置\n'
            '• fling({velocity}) —— 模拟惯性滚动到目标\n\n'
            '监听：\n'
            '• addListener(listener) —— 值变化时回调（用于 UI 重建）\n'
            '• addStatusListener(listener) —— 状态变化时回调（completed/dismissed 等）\n'
            '• removeListener / removeStatusListener —— 移除监听\n\n'
            '生命周期管理（非常重要！）：\n'
            '• 必须在 initState 中创建\n'
            '• 必须在 dispose 中调用 dispose() 释放资源\n'
            '• 忘记 dispose 会导致内存泄漏和后台性能浪费！',
          ),
          const CodeBlock(
            r'''// ━ 完整使用流程 ━

// 1. 类声明添加 Mixin
class _MyState extends State<MyWidget>
    with SingleTickerProviderStateMixin {

  // 2. 声明（late 延迟初始化）
  late final AnimationController _controller;

  // 3. 在 initState 中初始化
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.0,     // 默认值，可不写
      upperBound: 1.0,     // 默认值，可不写
      value: 0.5,          // 初始值，默认从 lowerBound 开始
    );
    // 可选：创建完就开始播放
    // _controller.forward();
  }

  // 4. 在 dispose 中释放
  @override
  void dispose() {
    _controller.dispose();  // ← 一定不能忘！
    super.dispose();
  }

  // 5. 在 build 中使用
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: _controller.value, child: child);
      },
      child: const Text('Hello'),
    );
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '关于 animateTo 的特殊说明：\n'
            '• animateTo(target, duration: ...) 可以临时指定不同动画时长\n'
            '• animateBack(target) 等同于 animateTo 但方向为反向\n'
            '• fling(velocity: 1.0) 模拟物理惯性，自动减速直到停止\n'
            '• repeat 的 period 参数可以重置循环时长，不同于构造函数的 duration',
            type: TipType.info,
          ),

          // ══════════════════════════════════════════════════
          // 7. Tween 与 Curve
          // ══════════════════════════════════════════════════
          const SectionHeader('7. Tween 与 CurvedAnimation 深入', icon: Icons.show_chart),
          const Paragraph(
            'Tween（补间）将 AnimationController 输出的 0~1 值映射到任意范围。\n'
            'CurvedAnimation（曲线动画）改变动画的"速度感觉"。\n\n'
            'Tween 的种类：\n'
            '• Tween<T> —— 基类，可以 override lerp(t) 实现自定义\n'
            '• ReverseTween —— 翻转 begin 和 end\n'
            '• ColorTween —— begin: Colors.xxx → end: Colors.yyy\n'
            '• SizeTween —— begin: Size(0,0) → end: Size(100,100)\n'
            '• RectTween —— begin: Rect → end: Rect\n'
            '• IntTween —— begin: 0 → end: 100（返回整数）\n'
            '• StepTween —— 阶梯式（离散值）\n'
            '• ConstantTween —— 始终返回固定值',
          ),
          const CodeBlock(
            r'''// ━ 常用 Tween 示例 ━

// 基本用法
final anim = Tween<double>(begin: 0, end: 300).animate(controller);

// 颜色变化
final colorAnim = ColorTween(
  begin: Colors.blue,
  end: Colors.orange,
).animate(curvedController);

// 尺寸变化
final sizeAnim = SizeTween(
  begin: const Size(0, 0),
  end: const Size(100, 100),
).animate(controller);

// IntTween —— 整数过渡
final countAnim = IntTween(begin: 0, end: 99)
    .animate(controller);

// RectTween —— 矩形过渡
final rectAnim = RectTween(
  begin: const Rect.fromLTWH(0, 0, 50, 50),
  end: const Rect.fromLTWH(50, 50, 100, 100),
).animate(controller);

// ConstantTween —— 始终返回固定值
final constAnim = ConstantTween<double>(100.0)
    .animate(controller);  // 值为100不变''',
            language: 'Dart',
          ),
          const Paragraph(
            'Curve（曲线）控制动画的"速度感"。同一个 Tween，不同的 Curve，动画感觉完全不同。\n\n'
            '所有 Curve 函数满足：输入 0.0 → 输出 0.0，输入 1.0 → 输出 1.0。\n'
            '中间点的输出控制的是"动画的进度"而非"终点"。\n\n'
            '常用 Curve 分类：\n\n'
            '基础曲线：\n'
            '• Curves.linear —— 匀速（默认，最机械的感受）\n'
            '• Curves.easeIn —— 慢速开始，逐渐加速（像汽车起步）\n'
            '• Curves.easeOut —— 快速开始，逐渐减速（像汽车刹停）\n'
            '• Curves.easeInOut —— 两头慢中间快（最自然的运动感）\n\n'
            '弹性曲线：\n'
            '• Curves.bounceIn / bounceOut / bounceInOut —— 弹跳效果\n'
            '• Curves.elasticIn / elasticOut / elasticInOut —— 橡皮筋弹性\n\n'
            'Material Design 曲线：\n'
            '• Curves.fastOutSlowIn —— 快速开始慢速结束（推荐用于大多数场景）\n'
            '• Curves.fastLinearToSlowEaseIn —— 快→匀速→慢\n'
            '• Curves.slowMiddle —— 中间减速\n'
            '• Curves.decelerate —— 减速\n\n'
            '自定义 Curve：\n'
            '• Cubic(x1, y1, x2, y2) —— 三次贝塞尔曲线（CSS 的 cubic-bezier 同理）\n'
            '• Interval(begin, end, curve) —— 时间段映射（交错动画的核心）\n'
            '• SawTooth(count) —— 锯齿波\n'
            '• Threshold(threshold) —— 阈值（0 或 1）',
          ),
          const CodeBlock(
            r'''// 自定义 Curve：三次贝塞尔
final myCurve = Cubic(0.25, 0.1, 0.25, 1.0);

// Interval 用于交错动画
final fadeCurve = Interval(0.0, 0.4, curve: Curves.easeIn);
final scaleCurve = Interval(0.3, 0.7, curve: Curves.elasticOut);
final slideCurve = Interval(0.6, 1.0, curve: Curves.easeOut);

// 实现自定义 Curve
class SineCurve extends Curve {
  @override
  double transform(double t) {
    return t + sin(t * pi * 2) * 0.1;  // 正弦波叠加
  }
}''',
            language: 'Dart',
          ),

          // ══════════════════════════════════════════════════
          // 8. Transition 系列
          // ══════════════════════════════════════════════════
          const SectionHeader('8. Transition 系列组件', icon: Icons.transform),
          const Paragraph(
            'Transition 系列是显式动画的"UI 包装器"。它们接收一个 Animation 对象，\n'
            '内置了 AnimatedBuilder 的逻辑，让你直接用组件名表达动画意图。\n\n'
            '所有 Transition 组件的规律：\n'
            '• 构造函数需要一个 Animation<T> 参数\n'
            '• 内置 child 属性（缓存的静态子组件）\n'
            '• 内部自动处理 AnimatedBuilder 逻辑\n\n'
            '常用 Transition 组件：',
          ),
          const CodeBlock(
            r'''// 透明度过渡（注意：是 FadeTransition 不是 OpacityTransition）
FadeTransition(opacity: animation, child: Text('淡入'))

// 缩放过渡
ScaleTransition(scale: animation, child: Text('放大'))

// 旋转过渡
RotationTransition(turns: animation, child: Text('旋转'))

// 平移过渡（用 Offset 值）
SlideTransition(position: offsetAnimation, child: Text('滑动'))

// 尺寸过渡
SizeTransition(sizeFactor: animation, child: Text('展开'))

// 对齐过渡
AlignTransition(alignment: alignmentAnim, child: Text('移动'))

// 装饰过渡 —— 背景/边框/阴影动画
DecoratedBoxTransition(
  decoration: decorationAnim,
  child: Text('装饰变化'),
)

// 相对位置过渡
PositionedTransition(rect: rectAnim, child: Text('定位'))

// 相对矩形过渡（ClipRRect 动画）
RelativeRectTransition(rect: rectAnim, child: Text('相对移动'))''',
            language: 'Dart',
          ),
          const Paragraph(
            'Transition 与 AnimatedBuilder 的区别：\n'
            '• Transition 组件一次性封装了动画类型 + 子组件缓存，代码更少\n'
            '• AnimatedBuilder 更灵活，可以在 builder 中做任意复杂操作\n'
            '• 多个 Transition 嵌套可以产生组合动画效果\n'
            '• 如果需要同时对多个属性进行动画，AnimatedBuilder 通常更清晰',
          ),

          // ══════════════════════════════════════════════════
          // 9. 显式动画交互演示
          // ══════════════════════════════════════════════════
          const SectionHeader('9. 显式动画交互演示', icon: Icons.play_circle_fill),
          const Paragraph('点击按钮控制动画条。注意观察 forward / reverse / repeat(reverse:true) / reset 的四种不同效果。记住：每个操作的数据流是 Controller(0→1) → Tween(0→300) → AnimatedBuilder(渲染)'),
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => Container(
                    width: _animation.value,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('动画条', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => _controller.forward(), child: const Text('播放')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _controller.reverse(), child: const Text('倒放')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _controller.repeat(reverse: true), child: const Text('循环')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _controller.reset(), child: const Text('重置')),
                  ],
                ),
              ],
            ),
          ),
          OutputBox(
            'forward → 从 0 到 300（正向播放）\n'
            'reverse → 从 300 到 0（反向播放）\n'
            'repeat(reverse:true) → 来回循环\n'
            'reset → 瞬间跳回 0\n\n'
            '当前值: ${_animation.value.toStringAsFixed(2)}  状态: ${_controller.status}',
          ),

          // ══════════════════════════════════════════════════
          // 10. AnimatedBuilder vs AnimatedWidget
          // ══════════════════════════════════════════════════
          const SectionHeader('10. AnimatedBuilder vs AnimatedWidget', icon: Icons.compare),
          const Paragraph(
            '两者都是将 Animation 对象的值映射到 UI 的工具，但适用场景不同。\n\n'
            'AnimatedBuilder：\n'
            '• 直接在 build 方法中使用，不需要创建新类\n'
            '• 适用于"一次性"的动画 UI\n'
            '• builder 函数每次值变化都会调用\n'
            '• child 参数缓存静态子组件，避免不必要的重建\n\n'
            'AnimatedWidget：\n'
            '• 需要继承 AnimatedWidget 创建新类\n'
            '• 适用于"可复用的"动画组件\n'
            '• 内部通过 listenable 参数接收 Animation 对象\n'
            '• 代码更简洁（如果多处使用同一动画组件）',
          ),
          const CodeBlock(
            r'''// ━ AnimatedBuilder 用法 ━
AnimatedBuilder(
  animation: _controller,          // 要监听的动画
  builder: (context, child) {       // 每次值变化都调用
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: child,                 // 静态子组件不重建
    );
  },
  child: const Icon(Icons.refresh), // 不变的子组件
);

// ━ AnimatedWidget 用法 ━
class RotatingIcon extends AnimatedWidget {
  const RotatingIcon({super.key, required super.listenable});

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(
      angle: animation.value * 2 * pi,
      child: const Icon(Icons.refresh),
    );
  }
}
// 使用：RotatingIcon(listenable: _controller)

// ━ 性能对比 ━
// AnimatedBuilder 的 child 参数如果不传，每次都会重建子组件树
// ✅ 好：child: const ExpensiveWidget()  → 只建一次
// ❌ 差：builder: (...) => ExpensiveWidget()  → 每帧都建
// AnimatedWidget 自动缓存子组件，但每次 build 仍创建新实例''',
            language: 'Dart',
          ),
          const TipBox(
            '性能要点：\n'
            '• AnimatedBuilder 的 child 参数是性能优化的关键\n'
            '• 如果子组件不变，尽量用 child 参数传入\n'
            '• 如果多处使用同一动画模式，封装成 AnimatedWidget 更干净\n'
            '• 如果需要组合多个动画值，AnimatedBuilder 更灵活',
            type: TipType.info,
          ),

          // ══════════════════════════════════════════════════
          // 11. 旋转动画 + 颜色动画
          // ══════════════════════════════════════════════════
          const SectionHeader('11. 旋转动画与颜色动画', icon: Icons.rotate_right),
          const Paragraph(
            '用 AnimatedBuilder 实现的旋转动画，同时演示 ColorTween 的颜色过渡。\n'
            'Transform.rotate 的 angle 单位是弧度。一个完整圆 = 2π ≈ 6.28 弧度。'
          ),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 旋转
                    AnimatedBuilder(
                      animation: _spinAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _spinAnimation.value,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal, width: 2),
                            ),
                            child: const Icon(Icons.refresh, size: 40, color: Colors.teal),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // 颜色变化
                    AnimatedBuilder(
                      animation: _colorAnim,
                      builder: (context, child) {
                        return Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: _colorAnim.value,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(Icons.palette, color: Colors.white, size: 40),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () { _spinController.repeat(); _colorController.repeat(reverse: true); },
                      child: const Text('两个一起播'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () { _spinController.stop(); _colorController.stop(); },
                      child: const Text('停止'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () { _spinController.reset(); _colorController.reset(); },
                      child: const Text('复位'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutputBox(
            '左侧：旋转动画 angle = Tween(0, 2π)\n'
            '右侧：颜色动画 ColorTween(blue → orange)\n'
            '两者独立控制，互不影响',
          ),

          // ══════════════════════════════════════════════════
          // 12. TweenSequence
          // ══════════════════════════════════════════════════
          const SectionHeader('12. TweenSequence —— 分阶段动画', icon: Icons.linear_scale),
          const Paragraph(
            'TweenSequence 允许在一个动画中定义"阶段列表"。每个阶段有自己的 Tween 和 weight（权重），\n'
            '权重决定该阶段占总时长的比例。\n\n'
            '与交错动画的区别：\n'
            '• 交错动画：多个动画并列，通过 Interval 控制每个的时间段\n'
            '• TweenSequence：一个动画串联多个阶段，自动按权重分配时间\n\n'
            '适用场景：\n'
            '• 进度条从 0→100→80→100（加载完成后的回弹效果）\n'
            '• 物体先加速前进再减速停下\n'
            '• 任何"一段接一段"的连续值变化',
          ),
          const CodeBlock(
            r'''// TweenSequence：定义三阶段动画
final sequenceAnim = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 0.0, end: 1.0),
    weight: 40,    // 占总时长的 40%
  ),
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.8),
    weight: 20,    // 占总时长的 20%
  ),
  TweenSequenceItem(
    tween: Tween(begin: 0.8, end: 1.0),
    weight: 40,    // 占总时长的 40%
  ),
]).animate(controller);

// 效果：0 → 1（40%时间）→ 0.8（20%时间）→ 1（40%时间）
// 总效果：前进→轻微回弹→最终到达''',
            language: 'Dart',
          ),
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _sequenceAnim,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // 进度条
                        Container(
                          width: 300,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 300 * _sequenceAnim.value,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '进度: ${(_sequenceAnim.value * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => _sequenceController.forward(), child: const Text('播放')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _sequenceController.reset(), child: const Text('重置')),
                  ],
                ),
              ],
            ),
          ),
          const Paragraph('观察进度条：先快速到100% → 回弹到80% → 再慢慢到100%。这就是 TweenSequence 的典型应用。'),

          // ══════════════════════════════════════════════════
          // 13. 交错动画深入
          // ══════════════════════════════════════════════════
          const SectionHeader('13. 交错动画 (Staggered Animation) 深入', icon: Icons.layers),
          const Paragraph(
            '交错动画是 Flutter 动画系统最强的功能之一。\n'
            '它让多个动画按时间表依次或重叠播放，创造出丰富的复合效果。\n\n'
            '核心原理：\n'
            '1. 一个 AnimationController（所有子动画共用同一个引擎）\n'
            '2. 每个子动画用 Interval(begin, end, curve) 定义自己的时间段\n'
            '3. Interval 的 begin 和 end 表示在这个 Controller 的"时间线"上从哪到哪\n'
            '4. 各子动画可以重叠（如淡入 0~40%、缩放 30%~70%）产生交叉效果\n\n'
            'Interval 的三个参数：\n'
            '• begin —— 动画开始时间（0.0 ~ 1.0，表示时间线上的位置）\n'
            '• end —— 动画结束时间（0.0 ~ 1.0，必须 > begin）\n'
            '• curve —— 该阶段内的速度曲线（默认 Curves.linear）',
          ),
          const CodeBlock(
            r'''// ━ 交错动画完整示例 ━
late final AnimationController _ctrl;
late final Animation<double> _fade, _scale, _slide;

void initState() {
  super.initState();
  _ctrl = AnimationController(vsync: this, duration: Duration(ms: 1500));

  // 第1段：淡入（前40%时间）
  _fade = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Interval(0.0, 0.4, curve: Curves.easeIn)),
  );

  // 第2段：弹性放大（30%~70%，与第1段和第3段有重叠）
  _scale = Tween(begin: 0.5, end: 1.2).animate(
    CurvedAnimation(parent: _ctrl, curve: Interval(0.3, 0.7, curve: Curves.elasticOut)),
  );

  // 第3段：向上滑动到位（最后40%时间）
  _slide = Tween(begin: -50.0, end: 0.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Interval(0.6, 1.0, curve: Curves.easeOut)),
  );
}

// 使用时，所有三个动画同时变化但速度不同
AnimatedBuilder(
  animation: _ctrl,  // 监听 Controller（不是子动画）
  builder: (context, child) {
    return Opacity(
      opacity: _fade.value,
      child: Transform.translate(
        offset: Offset(0, _slide.value),
        child: Transform.scale(scale: _scale.value, child: child),
      ),
    );
  },
  child: MyWidget(),
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          _StaggeredAnimationPreview(
            fadeAnim: _fadeAnim,
            scaleAnim: _scaleAnim,
            slideAnim: _slideAnim,
            controller: _staggeredController,
          ),

          // ══════════════════════════════════════════════════
          // 14. Hero 动画
          // ══════════════════════════════════════════════════
          const SectionHeader('14. Hero 动画 —— 共享元素过渡', icon: Icons.photo_library),
          const Paragraph(
            'Hero 是 Flutter 内置的页面间共享元素过渡动画。\n'
            '两个页面中 tag 相同的 Hero 组件会自动产生"飞过去"的过渡效果，无需任何额外代码。\n\n'
            'Hero 的工作流程：\n'
            '1. 页面 A 中有一个 Hero(tag: "xxx", child: WidgetA)\n'
            '2. 导航到页面 B\n'
            '3. 页面 B 中有一个 Hero(tag: "xxx", child: WidgetB)\n'
            '4. Flutter 自动：记录 WidgetA 的位置大小 → 在覆盖层播放"WidgetA 飞到 WidgetB 位置并变形"的动画 → 移除覆盖层显示 WidgetB\n\n'
            '关键约束：\n'
            '• tag 必须在路由跳转的两个页面之间唯一（同一路由树上有相同 tag 会报错）\n'
            '• child 组件应该"形态相似"（如都是圆形头像），否则过渡不自然\n'
            '• Hero 支持 createRectTween 自定义飞行路径\n'
            '• 可以用 flightShuttleBuilder 自定义飞行过程中的 Widget',
          ),
          const CodeBlock(
            r'''// ─ 基础用法 ─
// 页面A：小图
Hero(
  tag: 'user_avatar',
  child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(url)),
)

// 页面B：大图
Hero(
  tag: 'user_avatar',  // ← 必须与A一致
  child: CircleAvatar(radius: 150, backgroundImage: NetworkImage(url)),
)

// ─ 自定义飞行路径 ─
Hero(
  tag: 'custom',
  createRectTween: (begin, end) {
    // begin = 页面A中 Hero 的位置
    // end = 页面B中 Hero 的目标位置
    return MaterialRectArcTween(begin: begin, end: end);  // 弧形路径
    // 或 RectTween(begin: begin, end: end)  直线路径
    // 或 MaterialRectCenterArcTween(...)    中心弧形
  },
  child: ...,
)

// ─ 自定义飞行中样式 ─
Hero(
  tag: 'styled',
  flightShuttleBuilder: (flightContext, anim, flightDirection, fromContext, toContext) {
    // 飞的过程中显示的 Widget，anim 是当前的过渡进度
    return RotationTransition(
      turns: anim,
      child: fromContext.widget,  // 或自定义 Widget
    );
  },
  child: ...,
)''',
            language: 'Dart',
          ),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const _HeroDetailPage()),
              ),
              child: Hero(
                tag: 'demo_hero',
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 8)],
                  ),
                  child: const Center(child: Text('点我', style: TextStyle(color: Colors.white, fontSize: 20))),
                ),
              ),
            ),
          ),
          const TipBox(
            'Hero 的 tag 必须是 Object 类型，所以不仅可以是 String，还可以是 int 甚至自定义类。\n'
            '但通常用 String 最方便。确保跳转的两个页面中 tag 完全相等（==），否则不会触发 Hero 动画。',
            type: TipType.info,
          ),

          // ══════════════════════════════════════════════════
          // 15. AnimatedSwitcher
          // ══════════════════════════════════════════════════
          const SectionHeader('15. AnimatedSwitcher —— 切换动画', icon: Icons.swap_horiz),
          const Paragraph(
            'AnimatedSwitcher 在两个 child 之间切换时自动播放过渡动画。\n\n'
            '关键概念：\n'
            '• AnimatedSwitcher 通过 "key" 判断 child 是否改变\n'
            '• 如果不指定 key，切换可能不触发动画（Flutter 认为 child 没变）\n'
            '• 通常用 ValueKey 包裹 child，确保每次切换都触发动画\n'
            '• transitionBuilder 可以自定义过渡效果（缩放、旋转、滑动等）\n'
            '• switchInCurve / switchOutCurve 分别控制进入和退出的曲线',
          ),
          const CodeBlock(
            r'''AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  switchInCurve: Curves.easeOut,   // 新内容出现的曲线
  switchOutCurve: Curves.easeIn,   // 旧内容消失的曲线
  transitionBuilder: (child, animation) {
    // 自定义过渡效果：缩放 + 淡入
    return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
  },
  child: Text(
    '$_switchIndex',
    key: ValueKey(_switchIndex),  // ← 必须有，否则计数变化不触发动画
    style: TextStyle(fontSize: 40),
  ),
)''',
            language: 'Dart',
          ),
          Center(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                  },
                  child: Container(
                    key: ValueKey(_switchIndex),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple][_switchIndex % 5],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_switchIndex + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => setState(() => _switchIndex--), child: const Text('上一个')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: () => setState(() => _switchIndex++), child: const Text('下一个')),
                  ],
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════
          // 16. AnimatedList
          // ══════════════════════════════════════════════════
          const SectionHeader('16. AnimatedList —— 列表增删动画', icon: Icons.list_alt),
          const Paragraph(
            'AnimatedList 在添加/删除列表项时自动播放过渡动画。\n\n'
            '关键对象：\n'
            '• GlobalKey<AnimatedListState> —— 用于控制列表的增删操作\n'
            '• insertItem(index, duration) —— 在指定位置插入，自动播放插入动画\n'
            '• removeItem(index, builder, duration) —— 删除指定位置，先播放删除动画再移除\n'
            '• itemBuilder(context, index, animation) —— 构建列表项，animation 是该项的过渡动画',
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _items.length,
                    itemBuilder: (context, index, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(_items[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('添加一项'),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════
          // 17. 物理动画简介
          // ══════════════════════════════════════════════════
          const SectionHeader('17. 基于物理的动画', icon: Icons.waves),
          const Paragraph(
            '除了基于时间的动画，Flutter 还支持"基于物理"的动画。\n'
            '这类动画模拟真实世界的物理效果（摩擦力、弹力、重力等），非常适合手势驱动的交互动画。\n\n'
            '核心 API：\n'
            '• AnimationController.fling(velocity: ...) —— 惯性滚动\n'
            '• SpringSimulation —— 弹簧效果（安卓原生动画的主要方式）\n'
            '• GravitySimulation —— 重力下落\n'
            '• FrictionSimulation —— 摩擦力减速\n'
            '• ScrollSimulation —— 滚动模拟\n'
            '• AnimationController.animateWith(simulation) —— 使用自定义 Simulation',
          ),
          const CodeBlock(
            r'''// ━ 弹簧动画 ━
final spring = SpringSimulation(
  SpringDescription(mass: 1, stiffness: 100, damping: 10),
  0.0,  // 起始值
  1.0,  // 目标值
  0.5,  // 初始速度
);
_controller.animateWith(spring);

// ━ 惯性动画（手势松手后继续滚动）━━
_controller.fling(velocity: 2.0);  // 以2.0的速度开始，摩擦力自动减速到停

// ━ 重力下落 ━
final gravity = GravitySimulation(
  9.8,  // 重力加速度
  0.0,  // 起始位置
  100.0, // 终点位置
  0.0,  // 初速度
);
_controller.animateWith(gravity);''',
            language: 'Dart',
          ),
          const TipBox(
            '基于物理的动画特别适合拖拽、滑动、松手惯性等手势场景。\n'
            'flutter/physics.dart 提供了完整的物理模拟框架。',
            type: TipType.tip,
          ),

          // ══════════════════════════════════════════════════
          // 18. 性能优化
          // ══════════════════════════════════════════════════
          const SectionHeader('18. 动画性能优化', icon: Icons.speed),
          const Paragraph(
            '动画性能是 Flutter 应用流畅度的关键。60fps 意味着每帧只有 ~16ms 的预算。\n\n'
            '核心优化原则：\n\n'
            '1. 用 const 构造函数\n'
            '   • 子组件是 const 时，Flutter 不会重建它们，直接复用\n'
            '   • AnimatedBuilder 的 child 参数应使用 const\n\n'
            '2. 尽可能缩小重建范围\n'
            '   • 不要把整个页面放在 AnimatedBuilder 的 builder 里\n'
            '   • 只包裹需要动画的部分\n\n'
            '3. 使用 RepaintBoundary\n'
            '   • 将动画部分包在 RepaintBoundary 中，隔离重绘区域\n'
            '   • 减少整体页面的重绘开销\n\n'
            '4. 避免在动画回调中做重计算\n'
            '   • addListener 回调 60次/秒，内部不能有耗时操作\n'
            '   • 计算提前做好，回调中只更新 UI\n\n'
            '5. 优先选择隐式动画\n'
            '   • 隐式动画内部做了大量优化，性能通常优于手写的显式动画\n'
            '   • 不是必须用显式动画时，就用隐式\n\n'
            '6. 用 Ticker 而不是 Timer\n'
            '   • Timer 不会与屏幕刷新率同步，可能导致掉帧\n'
            '   • Ticker 与 Vsync 同步，保证每帧都在正确的时机触发',
          ),
          const CodeBlock(
            r'''// ✅ 好的写法：child 用 const
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(angle: _controller.value, child: child);
  },
  child: const Icon(Icons.star),  // const —— 永不重建
);

// ✅ 好的写法：RepaintBoundary 隔离重绘
RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => MovingWidget(),
  ),
);

// ❌ 差的写法：把大组件树放在 builder 里重建
AnimatedBuilder(
  animation: _controller,
  builder: (context, _) => BigComplexPage(),  // 每帧都重建整个页面！
);

// ❌ 差的写法：在 addListener 中做重计算
_controller.addListener(() {
  heavyComputation();  // 这个函数被调用60次/秒！
  setState(() {});
});''',
            language: 'Dart',
          ),
          const TipBox(
            '性能分析工具：\n'
            '• Flutter DevTools → Performance 面板 → 查看帧率和卡顿\n'
            '• debugProfilePaintsEnabled = true → 查看哪些区域在重绘\n'
            '• debugProfileBuildsEnabled = true → 查看哪些 Widget 在重建\n'
            '这些工具能帮你快速定位动画性能瓶颈。',
            type: TipType.tip,
          ),

          // ══════════════════════════════════════════════════
          // 19. 常见错误
          // ══════════════════════════════════════════════════
          const SectionHeader('19. 常见错误', icon: Icons.error_outline),
          const Paragraph(
            '1. 忘记 dispose Controller —— 最常见也最严重的错误，导致内存泄漏和后台 CPU 浪费\n'
            '2. 忘记 vsync —— 编译期就能发现的错误，提示"vsync is required"\n'
            '3. 用 SingleTickerProvider 创建多个 Controller —— 运行时报错\n'
            '4. 在 build 方法中创建 Controller —— build 可能被频繁调用，Controller 会被反复创建\n'
            '5. AnimationController 在 initState 之前使用 —— late 变量未初始化\n'
            '6. AnimatedBuilder 的 builder 函数里新建大型 Widget 树 —— 性能问题\n'
            '7. AnimatedSwitcher 不加 key —— 切换不触发动画\n'
            '8. 忘记 setState —— 改了目标值但隐式动画不触发\n'
            '9. Hero tag 冲突 —— 同一路由中两个 Hero 用了相同 tag\n'
            '10. Tween 和 Animation 的泛型不匹配 —— 编译错误',
          ),
          const TipBox(
            '调试技巧：\n'
            '• 如果动画不动，先检查是否调用了 setState（隐式动画）或 forward()（显式动画）\n'
            '• 如果动画异常，检查 Tween 的 begin 和 end 值是否正确\n'
            '• 如果过渡效果没有动画，检查有没有在 setState 之前改变值',
            type: TipType.caution,
          ),

          // ══════════════════════════════════════════════════
          // 20. 总结
          // ══════════════════════════════════════════════════
          const SectionHeader('20. 总结与最佳实践', icon: Icons.summarize),
          const Paragraph(
            'Flutter 动画知识体系总结：\n\n'
            '基础层：\n'
            '• Ticker + vsync → 动画的"心跳"\n'
            '• AnimationController → 动画的"发动机"\n'
            '• Animation<T> → 动画的"值"\n'
            '• Tween → 动画的"翻译官"\n'
            '• Curve → 动画的"速度感"\n\n'
            'UI 层：\n'
            '• 隐式动画（AnimatedXxx）→ 简单场景首选\n'
            '• TweenAnimationBuilder → 万能隐式动画\n'
            '• Transition 系列 → 显式动画标准 UI 组件\n'
            '• AnimatedBuilder → 自定义显式动画\n'
            '• AnimatedWidget → 可复用的显式动画组件\n\n'
            '进阶能力：\n'
            '• TweenSequence → 多阶段值动画\n'
            '• 交错动画（Interval）→ 多动画时间线编排\n'
            '• Hero → 页面间共享元素过渡\n'
            '• AnimatedSwitcher / AnimatedList → 列表切换动画\n'
            '• 物理动画（Simulation）→ 真实物理效果\n\n'
            '核心口诀：\n'
            '1. 简单属性变 → 隐式动画（AnimatedXxx）\n'
            '2. 任何属性变 → TweenAnimationBuilder\n'
            '3. 需要控制 → AnimationController + AnimatedBuilder\n'
            '4. 页面切图 → Hero\n'
            '5. 复杂编排 → 交错动画 / TweenSequence\n'
            '6. Controller 必 dispose！\n'
            '7. vsync 必传 this！',
          ),

          // ══════════════════════════════════════════════════
          // 21. 小练习
          // ══════════════════════════════════════════════════
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 AnimatedContainer 实现点击切换白天/黑夜模式的卡片\n'
            '2. 用 TweenAnimationBuilder 实现一个"呼吸灯"效果（大小和透明度周期性变化）\n'
            '3. 用 AnimationController + Tween 实现加载旋转指示器\n'
            '4. 自制一个"弹簧按钮"：按下缩小到 0.8，松手弹回 1.0\n'
            '5. 用交错动画实现"列表项依次飞入"的入场效果\n'
            '6. 给 Hero 加上 flightShuttleBuilder 自定义飞行样式\n'
            '7. 用 TweenSequence 实现下载完成后的"进度条回弹"效果\n'
            '8. 用 AnimatedSwitcher 做图片轮播切换效果\n'
            '9. 用 AnimatedList 做待办事项的添加/完成删除动画\n'
            '10. 实现一个"滑动删除"动画（Dismissible + 自定义背景）',
          ),
          const TipBox(
            '综合挑战：用本章学到的知识，做一个"赛跑动画"。\n'
            '三个彩色方块从左到右移动，使用不同的 Curve（linear / easeOut / bounceOut），\n'
            '让人直观感受不同曲线对动画感觉的影响。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── 多属性联动 Demo Builder ───
  List<Widget> _buildMultiAnimatedDemo() {
    return [
      const SizedBox(height: 8),
      // 目标盒子（所有属性联动变化）
      Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: _containerWidth,
          height: _containerHeight,
          decoration: BoxDecoration(
            color: _containerColor,
            borderRadius: BorderRadius.circular(_containerRadius),
          ),
          child: const Center(
            child: Text('看！', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      // 宽度滑块
      _buildSlider('宽度', _containerWidth, 60.0, 200.0, (v) => setState(() => _containerWidth = v)),
      // 高度滑块
      _buildSlider('高度', _containerHeight, 60.0, 200.0, (v) => setState(() => _containerHeight = v)),
      // 圆角滑块
      _buildSlider('圆角', _containerRadius, 0.0, 60.0, (v) => setState(() => _containerRadius = v)),
      const SizedBox(height: 8),
      // 颜色按钮
      Wrap(
        spacing: 8,
        children: [
          Colors.blue, Colors.red, Colors.green,
          Colors.orange, Colors.purple, Colors.teal,
        ].map((c) => ChoiceChip(
          label: Text('', style: TextStyle(fontSize: 10)),
          selected: _containerColor.value == c.value,
          selectedColor: c,
          backgroundColor: c.withOpacity(0.3),
          onSelected: (_) => setState(() => _containerColor = c),
        )).toList(),
      ),
    ];
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(width: 40, child: Text('${value.toInt()}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
      ],
    );
  }

  // ─── AnimatedList 操作方法 ───
  void _addItem() {
    final newItem = '水果 $_nextId';
    _nextId++;
    _items.add(newItem);
    _listKey.currentState?.insertItem(_items.length - 1);
  }

  void _removeItem(int index) {
    final removed = _items[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.check)),
          title: Text('已删除: $removed'),
        ),
      ),
    );
    _items.removeAt(index);
  }
}

// ═══════════════════════════════════════════════════════════════
// 辅助组件
// ═══════════════════════════════════════════════════════════════

/// Hero 详情页
class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero 详情页'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'demo_hero',
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 20)],
                ),
                child: const Center(child: Text('放大啦！', style: TextStyle(color: Colors.white, fontSize: 32))),
              ),
            ),
            const SizedBox(height: 24),
            const Text('点击返回按钮查看反向 Hero 动画'),
          ],
        ),
      ),
    );
  }
}

/// 交错动画展示组件
class _StaggeredAnimationPreview extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final Animation<double> slideAnim;
  final AnimationController controller;

  const _StaggeredAnimationPreview({
    required this.fadeAnim,
    required this.scaleAnim,
    required this.slideAnim,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Opacity(
                opacity: fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, slideAnim.value),
                  child: Transform.scale(
                    scale: scaleAnim.value,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 16)],
                      ),
                      child: const Center(
                        child: Text('交错', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('动画阶段：', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          const Text('1. 淡入 (0-40%)  2. 弹性放大 (30-70%)  3. 上移到位 (60-100%)', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => controller.forward(), child: const Text('播放交错动画')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => controller.reset(), child: const Text('重置')),
            ],
          ),
        ],
      ),
    );
  }
}

/// TweenAnimationBuilder 演示组件
class _TweenAnimationDemo extends StatefulWidget {
  @override
  State<_TweenAnimationDemo> createState() => _TweenAnimationDemoState();
}

class _TweenAnimationDemoState extends State<_TweenAnimationDemo> {
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Paragraph('点击按钮观察数值从 0 平滑过渡到 1，并同时影响缩放、颜色、圆角、阴影四个属性：'),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _triggered ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + value * 0.5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20 + value * 40, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.lerp(Colors.orange, Colors.pink, value)!,
                    Color.lerp(Colors.amber, Colors.purple, value)!,
                  ]),
                  borderRadius: BorderRadius.circular(12 + value * 8),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2 + value * 0.3), blurRadius: 4 + value * 12)],
                ),
                child: Text(
                  _triggered ? '展开了！value=${value.toStringAsFixed(3)}' : 'TweenAnimationBuilder',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => setState(() => _triggered = !_triggered),
          child: Text(_triggered ? '收起' : '展开动画'),
        ),
      ],
    );
  }
}
