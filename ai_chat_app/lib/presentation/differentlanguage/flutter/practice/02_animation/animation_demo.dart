import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第二章：动画大全
/// 从隐式动画到显式动画，从 Tween 到交错动画
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

  @override
  void initState() {
    super.initState();

    // 1. 基础显式动画
    _controller = AnimationController(
      vsync: this, // vsync 防止后台消耗性能
      duration: const Duration(seconds: 2),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animation = Tween<double>(begin: 0, end: 300).animate(_curvedAnimation);

    // 添加状态监听
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
  }

  @override
  void dispose() {
    // 所有 Controller 必须释放！
    _controller.dispose();
    _staggeredController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第2章 · 动画大全'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 章节目录 ──
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 隐式动画：AnimatedContainer / AnimatedOpacity / TweenAnimationBuilder\n'
            '② 显式动画：AnimationController + Tween\n'
            '③ CurvedAnimation 与内置曲线\n'
            '④ AnimatedBuilder vs AnimatedWidget\n'
            '⑤ Hero 页面过渡动画\n'
            '⑥ 交错动画（Staggered Animation）\n'
            '⑦ 旋转动画实战\n'
            '⑧ 总结与最佳实践',
          ),
          const DividerLine(),

          // ── 1. 动画基础概念 ──
          const SectionHeader('1. 两种动画：隐式 vs 显式', icon: Icons.compare_arrows),
          const Paragraph(
            '隐式动画（Implicit Animation）：改变属性后 Flutter 自动补间过渡。\n'
            '比如 AnimatedContainer、AnimatedOpacity、TweenAnimationBuilder。\n'
            '特点：简单易用，只需声明目标值。\n\n'
            '显式动画（Explicit Animation）：通过 AnimationController 手动控制。\n'
            '适合循环、反转、精细控制播放进度等复杂场景。\n'
            '特点：灵活但需要更多代码。',
          ),
          const TipBox(
            '类比：隐式动画 = 自动挡汽车（只管方向和油门），显式动画 = 手动挡（精确控制每个档位）。',
            type: TipType.tip,
          ),

          // ── 2. AnimatedContainer ──
          const DividerLine(),
          const SectionHeader('2. AnimatedContainer', icon: Icons.blur_on),
          const Paragraph(
            'AnimatedContainer 是最常用的隐式动画组件。\n'
            '当它的属性（宽高、颜色、圆角、边距等）变化时，自动产生平滑过渡动画。\n'
            '只需指定 duration 和 curve，Flutter 帮你完成中间帧。',
          ),
          const CodeBlock(
            r'''AnimatedContainer(
  duration: const Duration(seconds: 1),
  curve: Curves.easeInOut,
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  // 属性改变 -> 自动补间动画
)''',
            language: 'Dart',
          ),
          // 可交互示例
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
            '大小: ${_isExpanded ? "200x200" : "100x100"}  '
            '颜色: ${_isExpanded ? "蓝" : "红"}  '
            '点击容器切换',
          ),

          // ── 3. AnimatedOpacity ──
          const DividerLine(),
          const SectionHeader('3. AnimatedOpacity 与隐式动画家族', icon: Icons.opacity),
          const Paragraph(
            '透明度渐变动画。隐式动画家族还包括：\n'
            'AnimatedPadding、AnimatedAlign、AnimatedPositioned、\n'
            'AnimatedDefaultTextStyle、AnimatedTheme、AnimatedSlide 等。\n\n'
            '它们的使用模式完全一样：改变目标属性 -> 自动过渡。',
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

          // ── 4. TweenAnimationBuilder ──
          const DividerLine(),
          const SectionHeader('4. TweenAnimationBuilder', icon: Icons.build_circle),
          const Paragraph(
            'TweenAnimationBuilder 是「隐式动画终结者」——\n'
            '任何属性想加动画，都可以用它。只要指定起始值、目标值、和 builder 即可。',
          ),
          const CodeBlock(
            r'''TweenAnimationBuilder<double>(
  tween: Tween<double>(begin: 0, end: 1),
  duration: Duration(seconds: 1),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,  // 从 0 -> 1 渐变
      child: Transform.scale(
        scale: value,  // 从 0 -> 1 缩放
        child: child,
      ),
    );
  },
  child: Text('我淡入并放大'),
)''',
            language: 'Dart',
          ),
          // 可交互的 TweenAnimationBuilder
          _TweenAnimationDemo(),

          // ── 5. AnimationController ──
          const DividerLine(),
          const SectionHeader('5. AnimationController —— 显式动画的核心', icon: Icons.tune),
          const Paragraph(
            'AnimationController 是显式动画的「发动机」。它：\n'
            '• 生成从 0.0 到 1.0 的线性值（默认）\n'
            '• 参数 vsync 防止页面切到后台时浪费性能\n'
            '• 提供 forward() / reverse() / repeat() / reset() / stop() 五种控制方法\n'
            '• 通过 addStatusListener 监听动画状态变化',
          ),
          const CodeBlock(
            r'''// 1. 声明（需要 with SingleTickerProviderStateMixin）
late final AnimationController _controller;

// 2. 初始化（在 initState 中）
_controller = AnimationController(
  vsync: this,           // 防止后台消耗
  duration: const Duration(seconds: 2),
);

// 3. 控制
_controller.forward();         // 正向播放
_controller.reverse();         // 反向播放
_controller.repeat();          // 循环
_controller.repeat(reverse: true);  // 来回循环
_controller.reset();           // 重置到 0
_controller.stop();            // 停止

// 4. 释放（在 dispose 中）
_controller.dispose();

// 5. 状态监听
_controller.addStatusListener((status) {
  // status 枚举：
  // AnimationStatus.forward  - 正向播放中
  // AnimationStatus.reverse  - 反向播放中
  // AnimationStatus.completed - 播放完成
  // AnimationStatus.dismissed - 回到起始
});''',
            language: 'Dart',
          ),
          const TipBox(
            '使用 SingleTickerProviderStateMixin（单个动画）或 TickerProviderStateMixin（多个动画）。\n'
            'vsync 参数必须传 this，这是 Flutter 的 ticker 机制。',
            type: TipType.info,
          ),

          // ── 6. Tween 与 CurvedAnimation ──
          const DividerLine(),
          const SectionHeader('6. Tween 与 CurvedAnimation', icon: Icons.show_chart),
          const Paragraph(
            'Tween 定义动画的「值范围」。默认 AnimationController 生成 0.0 ~ 1.0，\n'
            '通过 Tween 可以映射到任意类型：double、Color、Size、Offset 甚至自定义类型。\n\n'
            'CurvedAnimation 改变动画的「速度曲线」，让动画更自然。\n'
            '常用曲线：\n'
            '• Curves.easeIn —— 慢速开始\n'
            '• Curves.easeOut —— 慢速结束\n'
            '• Curves.easeInOut —— 两头慢中间快\n'
            '• Curves.bounceOut —— 结束时有弹跳\n'
            '• Curves.elasticOut —— 弹性效果\n'
            '• Curves.fastOutSlowIn —— 快速开始慢速结束',
          ),
          const CodeBlock(
            r'''// Tween 将 0~1 映射到其他范围
Tween<double>(begin: 0, end: 300);           // 尺寸变化
Tween<Color>(begin: Colors.red, end: Colors.blue);  // 颜色变化
Tween<Size>(begin: Size(0,0), end: Size(100,100)); // 尺寸对象
Tween<Offset>(begin: Offset(0,0), end: Offset(100,0)); // 位移

// 链式组合
_animation = Tween<double>(begin: 0, end: 300)
    .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,  // 弹跳曲线
    ));

// 多个 Tween 叠加（交错效果见第9节）
Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
);
Tween<double>(begin: 1, end: 2).animate(
  CurvedAnimation(parent: _controller, curve: Interval(0.3, 0.6)),
);''',
            language: 'Dart',
          ),

          // ── 7. 显式动画演示 ──
          const DividerLine(),
          const SectionHeader('7. 显式动画交互演示', icon: Icons.play_circle_fill),
          const Paragraph('点击按钮控制动画条。观察 forward / reverse / repeat 的不同效果。'),
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
            'forward -> 从 0 到 300\n'
            'reverse -> 从 300 到 0\n'
            'repeat(reverse: true) -> 来回循环\n'
            'reset -> 回到 0',
          ),

          // ── 8. AnimatedBuilder vs AnimatedWidget ──
          const DividerLine(),
          const SectionHeader('8. AnimatedBuilder vs AnimatedWidget', icon: Icons.compare),
          const Paragraph(
            '两者都是将动画值映射到 UI 的工具，但使用场景不同：\n\n'
            'AnimatedBuilder —— 适合「临时动画」，在 build 中直接写逻辑，不需要新建类。\n'
            'AnimatedWidget —— 适合「可复用的动画组件」，封装成独立类。',
          ),
          const CodeBlock(
            r'''// AnimatedBuilder：直接在 build 中使用
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: child,  // child 参数缓存不变的子组件
    );
  },
  child: Icon(Icons.refresh),  // 不变的子组件
);

// AnimatedWidget：封装成独立类
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
// 使用：RotatingIcon(listenable: _controller)''',
            language: 'Dart',
          ),
          const TipBox(
            '经验法则：\n'
            '• 动画只用一次 -> AnimatedBuilder\n'
            '• 动画在多个地方复用 -> AnimatedWidget\n'
            '• AnimatedBuilder 的 child 参数可以缓存不变的部分，提升性能',
            type: TipType.tip,
          ),

          // ── 9. 旋转动画实战 ──
          const DividerLine(),
          const SectionHeader('9. 旋转动画', icon: Icons.rotate_right),
          const Paragraph('用 AnimatedBuilder 实现的旋转动画。点击按钮控制启停。'),
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _spinAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _spinController.repeat(),
                      child: const Text('开始旋转'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _spinController.stop(),
                      child: const Text('停止'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _spinController.reset(),
                      child: const Text('复位'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 10. Hero 动画 ──
          const DividerLine(),
          const SectionHeader('10. Hero 动画 —— 共享元素过渡', icon: Icons.photo_library),
          const Paragraph(
            'Hero 是 Flutter 内置的页面过渡动画。\n'
            '两个页面中 tag 相同的 Hero 组件会自动产生「飞过去」的过渡效果。\n'
            '常用于：头像列表 -> 详情页、缩略图 -> 全屏大图。',
          ),
          const CodeBlock(
            r'''// 页面 A：小图
Hero(
  tag: 'avatar',
  child: CircleAvatar(
    radius: 30,
    backgroundImage: NetworkImage('...'),
  ),
)

// 页面 B：大图（同一 tag）
Hero(
  tag: 'avatar',  // tag 必须一致
  child: CircleAvatar(
    radius: 150,
    backgroundImage: NetworkImage('...'),
  ),
)
// Flutter 自动在两个页面之间播放过渡动画！''',
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 8),
                    ],
                  ),
                  child: const Center(
                    child: Text('点我', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
              ),
            ),
          ),
          const TipBox(
            'Hero 的 tag 必须在整个应用中唯一。\n'
            'Flutter 自动把第一个页面的元素「飞」到第二个页面的对应位置。',
            type: TipType.tip,
          ),

          // ── 11. 交错动画 ──
          const DividerLine(),
          const SectionHeader('11. 交错动画 (Staggered Animation)', icon: Icons.layers),
          const Paragraph(
            '交错动画把多个动画串联起来依次播放，创造出丰富的视觉效果。\n\n'
            '实现原理：\n'
            '• 每个子动画使用 Interval(start, end) 控制自己的时间段\n'
            '• 所有子动画共用同一个 AnimationController\n'
            '• Interval 的 start/end 范围在 0.0 ~ 1.0 之间\n\n'
            '比如：先淡入（0~40%时间）-> 再放大（30%~70%）-> 最后移动到位（60%~100%）。',
          ),
          const CodeBlock(
            r'''// 三个动画共用同一个 Controller
_fadeAnim = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(parent: controller, curve: Interval(0.0, 0.4)),
);
_scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(
  CurvedAnimation(parent: controller, curve: Interval(0.3, 0.7, curve: Curves.elasticOut)),
);
_slideAnim = Tween<double>(begin: -50, end: 0).animate(
  CurvedAnimation(parent: controller, curve: Interval(0.6, 1.0, curve: Curves.easeOut)),
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          // 可交互的交错动画
          _StaggeredAnimationPreview(
            fadeAnim: _fadeAnim,
            scaleAnim: _scaleAnim,
            slideAnim: _slideAnim,
            controller: _staggeredController,
          ),

          // ── 12. 总结 ──
          const DividerLine(),
          const SectionHeader('总结', icon: Icons.summarize),
          const Paragraph(
            '隐式动画：简单属性变化 -> AnimatedXxx 组件 / TweenAnimationBuilder\n'
            '显式动画：需要精细控制 -> AnimationController + Tween\n'
            '速度曲线：CurvedAnimation + Curves.xxx\n'
            'UI 构建：AnimatedBuilder（临时） / AnimatedWidget（复用）\n'
            '页面过渡：Hero + tag\n'
            '复杂效果：交错动画 + Interval\n\n'
            '核心记住：\n'
            '1. 所有 Controller 必须在 dispose 中释放\n'
            '2. vsync: this 防止后台消耗\n'
            '3. AnimationController 默认值范围 0.0 ~ 1.0\n'
            '4. Tween 把 0~1 映射到目标范围',
          ),
          const TipBox(
            '最佳实践：\n'
            '• 简单效果用隐式动画（少写代码）\n'
            '• 循环/反转/精确控制用显式动画\n'
            '• 页面过渡用 Hero\n'
            '• 复杂动画拆成交错序列',
            type: TipType.info,
          ),

          // ── 练习 ──
          const DividerLine(),
          const SectionHeader('小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 AnimatedOpacity 让文字闪烁（循环显示隐藏）\n'
            '2. 用 TweenAnimationBuilder 实现颜色渐变的背景\n'
            '3. 用 AnimationController + Tween 实现加载旋转指示器\n'
            '4. 给 Hero 加上文字标签一起过渡\n'
            '5. 实现一个三阶段交错动画：淡入 -> 旋转 -> 移动到右下角',
          ),
          const SizedBox(height: 8),
          const TipBox(
            '提示：Tween<double>(begin: 0, end: 2*pi) 可以做旋转动画。\n'
            'Interval(0.0, 0.33) 控制第一阶段，以此类推。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
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
        child: Hero(
          tag: 'demo_hero',
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 20),
              ],
            ),
            child: const Center(
              child: Text('放大啦！', style: TextStyle(color: Colors.white, fontSize: 32)),
            ),
          ),
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '交错',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
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
          const Text(
            '1. 淡入 (0-40%)  2. 弹性放大 (30-70%)  3. 上移到位 (60-100%)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => controller.forward(),
                child: const Text('播放交错动画'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.reset(),
                child: const Text('重置'),
              ),
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
        const Paragraph('点击下方按钮观察 TweenAnimationBuilder 的隐式动画效果：'),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _triggered ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + value * 0.5,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 + value * 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(Colors.orange, Colors.pink, value)!,
                      Color.lerp(Colors.amber, Colors.purple, value)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12 + value * 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2 + value * 0.3),
                      blurRadius: 4 + value * 12,
                    ),
                  ],
                ),
                child: Text(
                  _triggered ? '展开了！' : 'TweenAnimationBuilder',
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
