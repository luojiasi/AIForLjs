import 'dart:math';
import 'package:flutter/material.dart';

/// ============================================================
/// 02_Flutter 动画大全
/// 本文件演示 Flutter 中所有常用动画的用法
/// 每个示例都配有交互式控制，可实时调节参数观察效果
/// ============================================================

class AnimationDemo extends StatelessWidget {
  const AnimationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 动画大全'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 一、什么是动画 ====================
          _SectionTitle(title: '一、什么是 Flutter 动画'),
          _Explainer(
            text: 'Flutter 动画框架分为两类：\n\n'
                '1️⃣ 隐式动画 — 通过改变属性值自动触发过渡效果\n'
                '   例：AnimatedContainer、AnimatedOpacity、TweenAnimationBuilder\n'
                '   特点：简单易用，Flutter 自动管理动画过程\n\n'
                '2️⃣ 显式动画 — 通过 AnimationController 手动控制\n'
                '   例：AnimationController + AnimatedBuilder\n'
                '   特点：灵活强大，可控制速度、方向、循环等\n\n'
                '⭐ 核心概念：Animation<double>、AnimationController、Tween、Curve',
          ),
          _DividerLine(),

          // ==================== 二、隐式动画 ====================
          _SectionTitle(title: '二、隐式动画（Implicit Animations）'),
          _Explainer(
            text: '隐式动画是最简单的动画方式。你只需要改变属性的目标值，'
                'Flutter 会自动从旧值过渡到新值。每个可动画属性都有对应的 AnimatedXxx 版本。',
          ),

          // ---------- 1. AnimatedContainer ----------
          _WidgetTitle(title: '1. AnimatedContainer —— 动画容器'),
          _Explainer(
            text: 'AnimatedContainer 是使用频率最高的隐式动画组件。'
                '当 width、height、color、borderRadius 等属性变化时，自动播放过渡动画。\n'
                '★ duration = 动画时长  ★ curve = 动画曲线',
          ),
          _CodeBlock(code: 'AnimatedContainer(\n'
              '  duration: Duration(seconds: 1),\n'
              '  curve: Curves.easeInOut,\n'
              '  width: _expanded ? 300 : 100,\n'
              '  height: _expanded ? 200 : 100,\n'
              '  decoration: BoxDecoration(\n'
              '    color: _expanded ? Colors.blue : Colors.red,\n'
              '    borderRadius: BorderRadius.circular(_expanded ? 24 : 8),\n'
              '  ),\n'
              '  child: ...,\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedContainerDemo(),
          _DividerLine(),

          // ---------- 2. AnimatedOpacity ----------
          _WidgetTitle(title: '2. AnimatedOpacity —— 淡入淡出'),
          _Explainer(
            text: 'AnimatedOpacity 控制子 Widget 的透明度动画。\n'
                '★ opacity: 0.0（完全透明）→ 1.0（完全不透明）\n'
                '★ 常用于显示/隐藏元素的过渡效果',
          ),
          _CodeBlock(code: 'AnimatedOpacity(\n'
              '  opacity: _visible ? 1.0 : 0.0,\n'
              '  duration: Duration(milliseconds: 500),\n'
              '  child: Text("淡入淡出文本"),\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedOpacityDemo(),
          _DividerLine(),

          // ---------- 3. AnimatedPadding + AnimatedMargin ----------
          _WidgetTitle(title: '3. AnimatedPadding —— 边距动画'),
          _Explainer(
            text: 'AnimatedPadding 让 padding 变化时有平滑过渡效果。\n'
                '★ 通过滑块控制内边距大小，容器内容会平滑移动',
          ),
          _CodeBlock(code: 'AnimatedPadding(\n'
              '  padding: EdgeInsets.all(_padding),\n'
              '  duration: Duration(milliseconds: 300),\n'
              '  child: Container(color: Colors.blue, child: Text("内容")),\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedPaddingDemo(),
          _DividerLine(),

          // ---------- 4. AnimatedAlign ----------
          _WidgetTitle(title: '4. AnimatedAlign —— 对齐动画'),
          _Explainer(
            text: 'AnimatedAlign 在不同对齐方式之间平滑过渡。\n'
                '★ 点击按钮在 topLeft / center / bottomRight 之间切换',
          ),
          _CodeBlock(code: 'AnimatedAlign(\n'
              '  alignment: _alignments[_index],\n'
              '  duration: Duration(milliseconds: 500),\n'
              '  child: Container(width: 60, height: 60, color: Colors.blue),\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedAlignDemo(),
          _DividerLine(),

          // ---------- 5. AnimatedPositioned ----------
          _WidgetTitle(title: '5. AnimatedPositioned —— 位置动画（Stack 内）'),
          _Explainer(
            text: 'AnimatedPositioned 必须在 Stack 中使用，让子 Widget 的位置变化平滑。\n'
                '★ 点击按钮让色块在四个角之间移动',
          ),
          _CodeBlock(code: 'Stack(\n'
              '  children: [\n'
              '    AnimatedPositioned(\n'
              '      left: _left, top: _top,\n'
              '      width: 80, height: 80,\n'
              '      duration: Duration(seconds: 1),\n'
              '      child: Container(color: Colors.blue),\n'
              '    ),\n'
              '  ],\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedPositionedDemo(),
          _DividerLine(),

          // ---------- 6. TweenAnimationBuilder ----------
          _WidgetTitle(title: '6. TweenAnimationBuilder —— 补间动画构建器'),
          _Explainer(
            text: 'TweenAnimationBuilder 是万能的隐式动画工具。'
                '不需要 AnimatedXxx 组件，直接对任意数值属性做动画。\n'
                '★ 下面演示让数字从 0 到 100 的计数动画',
          ),
          _CodeBlock(code: 'TweenAnimationBuilder<double>(\n'
              '  tween: Tween(begin: 0, end: _value),\n'
              '  duration: Duration(seconds: 1),\n'
              '  builder: (context, value, child) {\n'
              '    return Text(value.toStringAsFixed(1));\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _TweenAnimationBuilderDemo(),
          _DividerLine(),

          // ---------- 7. AnimatedSwitcher ----------
          _WidgetTitle(title: '7. AnimatedSwitcher —— 切换动画'),
          _Explainer(
            text: 'AnimatedSwitcher 在两个不同的子 Widget 之间切换时播放动画。\n'
                '★ 切换时旧 Widget 淡出，新 Widget 淡入\n'
                '★ 可通过 switchInCurve / switchOutCurve 自定义效果',
          ),
          _CodeBlock(code: 'AnimatedSwitcher(\n'
              '  duration: Duration(milliseconds: 500),\n'
              '  transitionBuilder: (child, animation) {\n'
              '    return FadeTransition(opacity: animation, child: child);\n'
              '  },\n'
              '  child: _icons[_index],  // 需要 unique key\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedSwitcherDemo(),
          _DividerLine(),

          // ==================== 三、显式动画 ====================
          _SectionTitle(title: '三、显式动画（Explicit Animations）'),
          _Explainer(
            text: '显式动画通过 AnimationController 精确控制动画的每一个细节。\n'
                '适用场景：循环动画、物理效果、手势驱动的动画、复杂的序列动画。',

          ),

          // ---------- 8. AnimationController ----------
          _WidgetTitle(title: '8. AnimationController —— 动画控制器'),
          _Explainer(
            text: 'AnimationController 是显式动画的核心。\n'
                '★ 需要 vsync 参数（通常传入 State）\n'
                '★ 通过 controller.forward() / reverse() / repeat() 控制\n'
                '★ 通过 AnimatedBuilder 监听值变化来构建 UI\n'
                '★ ⚠️ 必须在 dispose() 中释放',
          ),
          _CodeBlock(code: 'class _State extends State<MyWidget>\n'
              '    with SingleTickerProviderStateMixin {\n'
              '  late AnimationController _controller;\n'
              '\n'
              '  @override\n'
              '  void initState() {\n'
              '    super.initState();\n'
              '    _controller = AnimationController(\n'
              '      vsync: this,\n'
              '      duration: Duration(seconds: 2),\n'
              '    );\n'
              '  }\n'
              '\n'
              '  @override\n'
              '  void dispose() {\n'
              '    _controller.dispose();  // ⚠️ 必须释放\n'
              '    super.dispose();\n'
              '  }\n'
              '\n'
              '  @override\n'
              '  Widget build(BuildContext context) {\n'
              '    return AnimatedBuilder(\n'
              '      animation: _controller,\n'
              '      builder: (context, child) {\n'
              '        return Transform.rotate(\n'
              '          angle: _controller.value * 2 * pi,\n'
              '          child: child,\n'
              '        );\n'
              '      },\n'
              '      child: Icon(Icons.refresh),\n'
              '    );\n'
              '  }\n'
              '}'),
          const SizedBox(height: 8),
          const _AnimationControllerDemo(),
          _DividerLine(),

          // ---------- 9. 曲线动画 ----------
          _WidgetTitle(title: '9. Curves —— 动画曲线'),
          _Explainer(
            text: '动画曲线决定了动画的快慢变化模式。Flutter 内置了 30+ 种曲线。\n'
                '★ 曲线类型：ease（慢快慢）、linear（匀速）、bounce（弹跳）、elastic（弹性）等\n'
                '★ 下面演示同一动画在不同曲线下的效果',
          ),
          _CodeBlock(code: 'AnimationController(\n'
              '  duration: Duration(seconds: 1),\n'
              ')..forward();\n'
              '\n'
              '// 使用 CurvedAnimation 包装\n'
              'final curved = CurvedAnimation(\n'
              '  parent: controller,\n'
              '  curve: Curves.bounceOut,\n'
              ');'),
          const SizedBox(height: 8),
          const _CurvesDemo(),
          _DividerLine(),

          // ---------- 10. 交错动画 ----------
          _WidgetTitle(title: '10. Staggered Animation —— 交错动画'),
          _Explainer(
            text: '交错动画（Staggered Animation）通过一个 AnimationController '
                '驱动多个不同时间段的动画，形成连锁反应效果。\n'
                '★ 一个控制器控制多个 Interval（如 0-0.3, 0.3-0.6, 0.6-1.0）\n'
                '★ 常用于复杂的入场动画序列',
          ),
          _CodeBlock(code: '// 三段交错：透明度 → 位移 → 旋转\n'
              'final opacityAnim = Tween(begin: 0, end: 1)\n'
              '    .animate(CurvedAnimation(\n'
              '  parent: controller,\n'
              '  curve: Interval(0.0, 0.3, curve: Curves.easeIn),\n'
              '));'),
          const SizedBox(height: 8),
          const _StaggeredDemo(),
          _DividerLine(),

          // ---------- 11. Hero ----------
          _WidgetTitle(title: '11. Hero —— 共享元素动画'),
          _Explainer(
            text: 'Hero 动画让两个页面之间的共享元素产生平滑过渡。\n'
                '★ 两个页面的 Hero 组件必须有相同的 tag\n'
                '★ Flutter 自动将源页面元素"飞"到目标页面位置',
          ),
          _CodeBlock(code: '// 页面 A\n'
              'Hero(\n'
              '  tag: "avatar",\n'
              '  child: CircleAvatar(\n'
              '    radius: 40,\n'
              '    backgroundImage: ...\n'
              '  ),\n'
              ')\n\n'
              '// 页面 B（放大版本）\n'
              'Hero(\n'
              '  tag: "avatar",  // 同一个 tag\n'
              '  child: Image.network(...),\n'
              ')'),
          const SizedBox(height: 8),
          const _HeroDemo(),
          _DividerLine(),

          // ==================== 四、物理与实用动画 ====================
          _SectionTitle(title: '四、物理与实用动画'),

          // ---------- 12. AnimatedList ----------
          _WidgetTitle(title: '12. AnimatedList —— 列表增删动画'),
          _Explainer(
            text: 'AnimatedList 为列表项的插入和删除提供动画效果。\n'
                '★ insertItem() = 插入动画（淡入+滑入）\n'
                '★ removeItem() = 删除动画（淡出+滑出）',
          ),
          _CodeBlock(code: 'AnimatedList(\n'
              '  key: _listKey,\n'
              '  initialItemCount: _items.length,\n'
              '  itemBuilder: (context, index, animation) {\n'
              '    return SizeTransition(\n'
              '      sizeFactor: animation,\n'
              '      child: ListTile(title: Text(_items[index])),\n'
              '    );\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedListDemo(),
          _DividerLine(),

          // ---------- 13. 弹簧动画 ----------
          _WidgetTitle(title: '13. Spring Simulation —— 弹簧效果'),
          _Explainer(
            text: 'Flutter 的 SpringSimulation 模拟真实物理弹簧效果。\n'
                '★ mass（质量）、stiffness（刚度）、damping（阻尼）控制弹簧行为\n'
                '★ 或者使用更简单的 SpringDescription 配合 AnimationController',
          ),
          _CodeBlock(code: '// 弹簧动画\n'
              'final spring = SpringDescription(\n'
              '  mass: 1.0,         // 质量，越大越"重"\n'
              '  stiffness: 100.0,  // 刚度，越大弹得越快\n'
              '  damping: 10.0,     // 阻尼，越大越停得快\n'
              ');\n'
              '_controller = AnimationController(\n'
              '  vsync: this,\n'
              '  duration: Duration(seconds: 2),\n'
              ');'),
          const SizedBox(height: 8),
          const _SpringAnimationDemo(),
          _DividerLine(),

          // ---------- 14. AnimatedBuilder ----------
          _WidgetTitle(title: '14. AnimatedBuilder —— 高效动画构建'),
          _Explainer(
            text: 'AnimatedBuilder 是显式动画的推荐构建方式。\n'
                '它能将动画逻辑与显示逻辑分离，并且通过 child 参数\n'
                '缓存不变化的部分，提高性能。',
          ),
          _CodeBlock(code: 'AnimatedBuilder(\n'
              '  animation: _controller,\n'
              '  // 通过 child 缓存不变的部分\n'
              '  child: Icon(Icons.star, size: 48),\n'
              '  builder: (context, child) {\n'
              '    return Transform.scale(\n'
              '      scale: 1 + _controller.value * 0.5,\n'
              '      child: child,\n'
              '    );\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _AnimatedBuilderDemo(),
          _DividerLine(),

          // ==================== 五、综合实战 ====================
          _SectionTitle(title: '五、动画综合实战'),
          _Explainer(
            text: '综合运用多种动画技术实现一个可交互的动画卡片。\n'
                '包含：缩放、旋转、阴影、圆角、颜色等多种动画组合。',
          ),
          const _ComprehensiveDemo(),
          _DividerLine(),

          // 总结
          _SectionTitle(title: '总结'),
          _Explainer(
            text: 'Flutter 动画的核心要点：\n\n'
                '1. 简单场景用隐式动画 — AnimatedContainer / AnimatedOpacity 等\n\n'
                '2. 复杂场景用显式动画 — AnimationController + AnimatedBuilder\n\n'
                '3. 动画曲线让动画更自然 — Curves 提供了丰富的缓动函数\n\n'
                '4. ⚠️ 显式动画必须释放 — controller.dispose() 防止内存泄漏\n\n'
                '5. vsync 参数是必须的 — 用 SingleTickerProviderStateMixin\n\n'
                '6. 组合使用 Interval 实现交错动画效果\n\n'
                '7. 物理弹簧动画让交互更真实 — SpringSimulation',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================================
// 1. AnimatedContainer 交互演示
// ============================================================

class _AnimatedContainerDemo extends StatefulWidget {
  const _AnimatedContainerDemo();

  @override
  State<_AnimatedContainerDemo> createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<_AnimatedContainerDemo> {
  bool _expanded = false;

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];
  int _colorIndex = 0;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          width: _expanded ? 300 : 100,
          height: _expanded ? 150 : 60,
          decoration: BoxDecoration(
            color: _colors[_colorIndex],
            borderRadius: BorderRadius.circular(_expanded ? 24 : 8),
            boxShadow: [
              BoxShadow(
                color: _colors[_colorIndex].withValues(alpha: 0.4),
                blurRadius: _expanded ? 16 : 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _expanded ? '展开状态' : '展开',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _toggle,
          child: Text(_expanded ? '收缩' : '展开'),
        ),
        const SizedBox(height: 8),
        _TipText(
          text: '点击按钮切换 AnimatedContainer 的尺寸、颜色、圆角、阴影。\n'
              '所有变化都会平滑过渡，无需手动管理动画过程。',
        ),
      ],
    );
  }
}

// ============================================================
// 2. AnimatedOpacity 交互演示
// ============================================================

class _AnimatedOpacityDemo extends StatefulWidget {
  const _AnimatedOpacityDemo();

  @override
  State<_AnimatedOpacityDemo> createState() => _AnimatedOpacityDemoState();
}

class _AnimatedOpacityDemoState extends State<_AnimatedOpacityDemo> {
  double _opacity = 1.0;
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '淡入淡出效果',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 滑块控制透明度
        Row(
          children: [
            const Text('透明度', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: _opacity,
                min: 0.0,
                max: 1.0,
                onChanged: (v) => setState(() => _opacity = v),
              ),
            ),
            Text(_opacity.toStringAsFixed(2), style: const TextStyle(fontSize: 13)),
          ],
        ),
        // 快速切换按钮
        ElevatedButton.icon(
          icon: Icon(_visible ? Icons.visibility : Icons.visibility_off, size: 18),
          label: Text(_visible ? '隐藏' : '显示'),
          onPressed: () {
            setState(() {
              _visible = !_visible;
              _opacity = _visible ? 1.0 : 0.0;
            });
          },
        ),
        const SizedBox(height: 8),
        _TipText(text: '拖动滑块控制透明度，或点击按钮快速切换显示/隐藏。'),
      ],
    );
  }
}

// ============================================================
// 3. AnimatedPadding 交互演示
// ============================================================

class _AnimatedPaddingDemo extends StatefulWidget {
  const _AnimatedPaddingDemo();

  @override
  State<_AnimatedPaddingDemo> createState() => _AnimatedPaddingDemoState();
}

class _AnimatedPaddingDemoState extends State<_AnimatedPaddingDemo> {
  double _padding = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 子内容：AnimatedPadding 容器
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedPadding(
            padding: EdgeInsets.all(_padding),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('内边距动画', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('内边距', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: _padding,
                min: 0,
                max: 48,
                divisions: 48,
                onChanged: (v) => setState(() => _padding = v),
              ),
            ),
            Text('${_padding.toInt()}px', style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        _TipText(text: '拖动滑块改变内边距，蓝色容器会平滑地扩大/缩小。'),
      ],
    );
  }
}

// ============================================================
// 4. AnimatedAlign 交互演示
// ============================================================

class _AnimatedAlignDemo extends StatefulWidget {
  const _AnimatedAlignDemo();

  @override
  State<_AnimatedAlignDemo> createState() => _AnimatedAlignDemoState();
}

class _AnimatedAlignDemoState extends State<_AnimatedAlignDemo> {
  int _index = 0;

  static const _alignments = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  static const _labels = [
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'center',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
  ];

  void _next() {
    setState(() => _index = (_index + 1) % _alignments.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AnimatedAlign(
            alignment: _alignments[_index],
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _labels[_index].substring(0, 2),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('当前位置：${_labels[_index]}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _next, child: const Text('下一个位置')),
          ],
        ),
        const SizedBox(height: 4),
        _TipText(text: '点击按钮切换蓝色方块的对齐位置，观察平滑移动动画。'),
      ],
    );
  }
}

// ============================================================
// 5. AnimatedPositioned 交互演示
// ============================================================

class _AnimatedPositionedDemo extends StatefulWidget {
  const _AnimatedPositionedDemo();

  @override
  State<_AnimatedPositionedDemo> createState() => _AnimatedPositionedDemoState();
}

class _AnimatedPositionedDemoState extends State<_AnimatedPositionedDemo> {
  int _corner = 0;

  static const _positions = [
    // top-left
    {'left': 8.0, 'top': 8.0, 'color': Colors.red},
    // top-right
    {'left': 212.0, 'top': 8.0, 'color': Colors.blue},
    // bottom-right
    {'left': 212.0, 'top': 112.0, 'color': Colors.green},
    // bottom-left
    {'left': 8.0, 'top': 112.0, 'color': Colors.orange},
    // center
    {'left': 110.0, 'top': 60.0, 'color': Colors.purple},
  ];

  static const _labels = ['左上', '右上', '右下', '左下', '居中'];

  @override
  Widget build(BuildContext context) {
    final pos = _positions[_corner];
    final color = pos['color'] as Color;

    return Column(
      children: [
        Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                left: pos['left']! as double,
                top: pos['top']! as double,
                width: 80,
                height: 80,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _labels[_corner],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _positions.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_labels[i], style: const TextStyle(fontSize: 12)),
                  selected: _corner == i,
                  onSelected: (_) => setState(() => _corner = i),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _TipText(text: '点击 Chip 切换色块位置，AnimatedPositioned 会自动平滑移动。'),
      ],
    );
  }
}

// ============================================================
// 6. TweenAnimationBuilder 交互演示
// ============================================================

class _TweenAnimationBuilderDemo extends StatefulWidget {
  const _TweenAnimationBuilderDemo();

  @override
  State<_TweenAnimationBuilderDemo> createState() => _TweenAnimationBuilderDemoState();
}

class _TweenAnimationBuilderDemoState extends State<_TweenAnimationBuilderDemo> {
  double _target = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一个演示：数值动画
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text('数值动画', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _target),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('目标值', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: _target,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) => setState(() => _target = v),
                    ),
                  ),
                  Text('${_target.toInt()}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 第二个演示：颜色动画
        _ColorTweenDemo(),
        const SizedBox(height: 8),
        _TipText(text: 'TweenAnimationBuilder 可以对任意数值做动画。'
            '拖动滑块改变目标值，观察数字平滑变化。'),
      ],
    );
  }
}

class _ColorTweenDemo extends StatefulWidget {
  @override
  State<_ColorTweenDemo> createState() => _ColorTweenDemoState();
}

class _ColorTweenDemoState extends State<_ColorTweenDemo> {
  Color _targetColor = Colors.blue;

  static const _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('颜色补间动画', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: Colors.blue, end: _targetColor),
            duration: const Duration(milliseconds: 500),
            builder: (context, color, _) {
              return Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('颜色过渡', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colors.map((c) {
              return GestureDetector(
                onTap: () => setState(() => _targetColor = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                    border: _targetColor == c
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 7. AnimatedSwitcher 交互演示
// ============================================================

class _AnimatedSwitcherDemo extends StatefulWidget {
  const _AnimatedSwitcherDemo();

  @override
  State<_AnimatedSwitcherDemo> createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<_AnimatedSwitcherDemo> {
  int _index = 0;

  static const _icons = [
    Icons.home,
    Icons.favorite,
    Icons.settings,
    Icons.star,
    Icons.notifications,
    Icons.person,
  ];

  static const _labels = [
    '首页',
    '收藏',
    '设置',
    '星标',
    '通知',
    '个人',
  ];

  void _next() {
    setState(() => _index = (_index + 1) % _icons.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Column(
                key: ValueKey(_index),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icons[_index], size: 64, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(_labels[_index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _next, child: const Text('切换图标')),
        const SizedBox(height: 4),
        _TipText(text: '点击按钮切换图标，可以看到缩放+淡入淡出的组合切换效果。'),
      ],
    );
  }
}

// ============================================================
// 8. AnimationController 交互演示
// ============================================================

class _AnimationControllerDemo extends StatefulWidget {
  const _AnimationControllerDemo();

  @override
  State<_AnimationControllerDemo> createState() => _AnimationControllerDemoState();
}

class _AnimationControllerDemoState extends State<_AnimationControllerDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _duration = 2.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_duration * 1000).toInt()),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDuration(double v) {
    setState(() {
      _duration = v;
      _controller.duration = Duration(milliseconds: (v * 1000).toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 旋转方块
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(_controller.value * 2 * pi)
                      ..setEntry(0, 0, 1 + _controller.value * 0.5)
                      ..setEntry(1, 1, 1 + _controller.value * 0.5),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blue.withValues(alpha: 0.5 + _controller.value * 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12 + _controller.value * 16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3 + _controller.value * 0.3),
                            blurRadius: 4 + _controller.value * 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.star, color: Colors.white, size: 28 + _controller.value * 12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _controller.value,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Text('进度: ${(_controller.value * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () => _controller.reverse(),
              tooltip: '反向播放',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(_isPlaying ? '暂停' : '播放'),
              onPressed: () {
                if (_controller.isCompleted) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
                setState(() => _isPlaying = true);
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () => _controller.forward(),
              tooltip: '正向播放',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.loop),
              onPressed: () {
                _controller.repeat(reverse: true);
                setState(() => _isPlaying = true);
              },
              tooltip: '循环播放',
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                _controller.reset();
                setState(() => _isPlaying = false);
              },
              tooltip: '重置',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 时长调节
        Row(
          children: [
            const Text('时长', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: _duration,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                onChanged: _updateDuration,
              ),
            ),
            Text('${_duration.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        _TipText(text: '点击播放/循环观看动画，拖动滑块调节动画时长。'
            '旋转、缩放、圆角、阴影同时变化展现了 AnimationController 的强大。'),
      ],
    );
  }
}

// ============================================================
// 9. 动画曲线交互演示
// ============================================================

class _CurvesDemo extends StatefulWidget {
  const _CurvesDemo();

  @override
  State<_CurvesDemo> createState() => _CurvesDemoState();
}

class _CurvesDemoState extends State<_CurvesDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedCurve = 0;
  bool _playing = false;

  static const _curves = <_CurveEntry>[
    _CurveEntry('easeInOut', Curves.easeInOut),
    _CurveEntry('linear', Curves.linear),
    _CurveEntry('bounceOut', Curves.bounceOut),
    _CurveEntry('elasticOut', Curves.elasticOut),
    _CurveEntry('easeOutBack', Curves.easeOutBack),
    _CurveEntry('fastOutSlowIn', Curves.fastOutSlowIn),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _playing = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.reset();
    _controller.forward();
    setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    final curve = _curves[_selectedCurve];
    final curved = CurvedAnimation(parent: _controller, curve: curve.curve);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 小球运动
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: AnimatedBuilder(
                    animation: curved,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          Positioned(
                            left: curved.value * (300 - 48),
                            top: 6,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${(_controller.value * 100).toInt()}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 曲线名称
              Text(curve.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              const SizedBox(height: 4),
              Text('进度: ${(_controller.value * 100).toInt()}%',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 曲线选择
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(_curves.length, (i) {
            return ChoiceChip(
              label: Text(_curves[i].name, style: const TextStyle(fontSize: 12)),
              selected: _selectedCurve == i,
              onSelected: (_) => setState(() => _selectedCurve = i),
              selectedColor: Colors.blue[100],
            );
          }),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('播放'),
          onPressed: _playing ? null : _play,
        ),
        const SizedBox(height: 4),
        _TipText(text: '选择不同的曲线后点击播放，观察小球在不同曲线下的运动节奏差异。'),
      ],
    );
  }
}

class _CurveEntry {
  final String name;
  final Curve curve;
  const _CurveEntry(this.name, this.curve);
}

// ============================================================
// 10. 交错动画交互演示
// ============================================================

class _StaggeredDemo extends StatefulWidget {
  const _StaggeredDemo();

  @override
  State<_StaggeredDemo> createState() => _StaggeredDemoState();
}

class _StaggeredDemoState extends State<_StaggeredDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _translateAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 四段交错：透明度(0-0.25) → 位移(0.25-0.5) → 旋转(0.5-0.75) → 缩放(0.75-1.0)
    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)),
    );
    _translateAnim = Tween(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.5, curve: Curves.easeOutCubic)),
    );
    _rotationAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.75, curve: Curves.easeOutBack)),
    );
    _scaleAnim = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _opacityAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _translateAnim.value),
                    child: Transform.rotate(
                      angle: _rotationAnim.value * 2 * pi,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 动画进度指示
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _IntervalLabel(label: '①透明度', active: _controller.value >= 0 && _controller.value < 0.25),
                    _IntervalLabel(label: '②位移', active: _controller.value >= 0.25 && _controller.value < 0.5),
                    _IntervalLabel(label: '③旋转', active: _controller.value >= 0.5 && _controller.value < 0.75),
                    _IntervalLabel(label: '④缩放', active: _controller.value >= 0.75),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('播放交错动画'),
          onPressed: _controller.isAnimating ? null : _play,
        ),
        const SizedBox(height: 4),
        _TipText(text: '点击播放后，四段动画按顺序依次执行：先淡入，再上移，再旋转，最后放大。'
            '这就是交错动画的魅力——一个控制器驱动多个时序不同的动画。'),
      ],
    );
  }
}

class _IntervalLabel extends StatelessWidget {
  final String label;
  final bool active;
  const _IntervalLabel({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
        color: active ? Colors.blue : Colors.grey,
      ),
    );
  }
}

// ============================================================
// 11. Hero 动画交互演示（模拟）
// ============================================================

class _HeroDemo extends StatelessWidget {
  const _HeroDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openDetailPage(context),
                child: Hero(
                  tag: 'demo-hero',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.flight_takeoff, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('点击上方图标跳转到详情页',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _CodeBlock(code: '// 页面 A — 小图标\n'
            'Hero(\n'
            '  tag: "my-tag",\n'
            '  child: Icon(Icons.star, size: 40),\n'
            ')\n\n'
            '// 页面 B — 大图标（同一个 tag）\n'
            'Hero(\n'
            '  tag: "my-tag",\n'
            '  child: Icon(Icons.star, size: 200),\n'
            ')'),
        const SizedBox(height: 8),
        _TipText(text: 'Hero 动画需要两个页面使用相同的 tag。'
            'Flutter 会自动计算起始和结束位置，生成平滑的飞行动画。'),
      ],
    );
  }

  void _openDetailPage(BuildContext context) {
    Navigator.of(context).push(_HeroDetailRoute());
  }
}

class _HeroDetailRoute extends PageRouteBuilder {
  _HeroDetailRoute()
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const _HeroDetailPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero 详情页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'demo-hero',
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.flight_takeoff, color: Colors.white, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hero 共享元素动画',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('点击返回按钮，观察图标如何飞回原位'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 12. AnimatedList 交互演示
// ============================================================

class _AnimatedListDemo extends StatefulWidget {
  const _AnimatedListDemo();

  @override
  State<_AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<_AnimatedListDemo> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _items = <String>[];
  int _counter = 0;

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
  ];

  void _addItem() {
    final index = _items.length;
    _items.add('项目 ${++_counter}');
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _removeItem(int index) {
    final item = _items[index];
    _listKey.currentState?.removeItem(
      index,
      duration: const Duration(milliseconds: 400),
      (context, animation) {
        return _buildItem(item, index, animation, removing: true);
      },
    );
    _items.removeAt(index);
  }

  Widget _buildItem(String item, int index, Animation<double> animation,
      {bool removing = false}) {
    final color = _colors[index % _colors.length];

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: removing ? Colors.grey : color,
              child: Text('${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(item, style: TextStyle(
              decoration: removing ? TextDecoration.lineThrough : null,
              color: removing ? Colors.grey : null,
            )),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: removing ? null : () => _removeItem(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          constraints: const BoxConstraints(maxHeight: 300),
          child: _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('列表为空，点击"添加"按钮添加项目',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: _items.length,
                  itemBuilder: (context, index, animation) {
                    return _buildItem(_items[index], index, animation);
                  },
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加'),
              onPressed: _addItem,
            ),
            const SizedBox(width: 12),
            Text('共 ${_items.length} 项', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        _TipText(text: '点击"添加"插入新项目（淡入+展开动画），点击右侧红色删除按钮移除项目（淡出+收缩动画）。'),
      ],
    );
  }
}

// ============================================================
// 13. 弹簧动画交互演示
// ============================================================

class _SpringAnimationDemo extends StatefulWidget {
  const _SpringAnimationDemo();

  @override
  State<_SpringAnimationDemo> createState() => _SpringAnimationDemoState();
}

class _SpringAnimationDemoState extends State<_SpringAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _animating = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerSpring() {
    _controller.reset();
    _controller.forward();
    setState(() => _animating = true);
  }

  @override
  Widget build(BuildContext context) {
    // 使用弹簧曲线模拟
    final springCurve = Curves.bounceOut;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final curved = CurvedAnimation(parent: _controller, curve: springCurve);
              return AnimatedBuilder(
                animation: curved,
                builder: (context, _) {
                  final scale = 1.0 + (1.0 - curved.value) * 0.6;
                  final rotation = (1.0 - curved.value) * 0.1;
                  return Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(rotation)
                        ..setEntry(0, 0, scale)
                        ..setEntry(1, 1, scale),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withValues(alpha: 0.3 + (1 - _controller.value) * 0.4),
                              blurRadius: 8 + (1 - _controller.value) * 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.bolt, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (!_animating)
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('触发弹簧动画'),
            onPressed: _triggerSpring,
          )
        else
          const Text('弹跳中...', style: TextStyle(color: Colors.grey)),
        _TipText(text: '点击"触发弹簧动画"观看弹跳效果。使用 bounceOut 曲线模拟弹簧的回弹效果。'),
      ],
    );
  }
}

// ============================================================
// 14. AnimatedBuilder 交互演示
// ============================================================

class _AnimatedBuilderDemo extends StatefulWidget {
  const _AnimatedBuilderDemo();

  @override
  State<_AnimatedBuilderDemo> createState() => _AnimatedBuilderDemoState();
}

class _AnimatedBuilderDemoState extends State<_AnimatedBuilderDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // child 参数缓存不变的部分（图标），builder 只重建变化的部分（Transform）
    // 这是 AnimatedBuilder 的性能优势所在
    const cachedChild = Icon(Icons.explore, size: 48, color: Colors.white);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 使用 AnimatedBuilder 的高效模式
          AnimatedBuilder(
            animation: _animation,
            child: cachedChild,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_animation.value * 2 * pi),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: child, // 使用缓存的 child
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _TipText(text: 'AnimatedBuilder 的 child 参数可以缓存不变化的部分。'
              '这里 Icon(Icons.explore) 只创建一次，builder 中复用了该实例，提高了性能。'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('旋转', _animation.value * 360),
              const SizedBox(width: 16),
              _buildBadge('方向', _animation.value > 0.5 ? '→' : '←'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: ${value is double ? value.toStringAsFixed(1) : value}',
          style: const TextStyle(fontSize: 12, color: Colors.blue)),
    );
  }
}

// ============================================================
// 15. 综合实战交互演示
// ============================================================

class _ComprehensiveDemo extends StatefulWidget {
  const _ComprehensiveDemo();

  @override
  State<_ComprehensiveDemo> createState() => _ComprehensiveDemoState();
}

class _ComprehensiveDemoState extends State<_ComprehensiveDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _expanded = false;
  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _expanded = !_expanded;
      _color = _expanded ? Colors.blue : Colors.purple;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GestureDetector(
          onTap: _toggle,
          child: Card(
          elevation: 4 + _controller.value * 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 + _controller.value * 12),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _color,
                  _color.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12 + _controller.value * 12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16 + _controller.value * 16),
              child: Column(
                children: [
                  // 头像区
                  Row(
                    children: [
                      // 头像 - 缩放+旋转
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(_controller.value * 0.2)
                          ..setEntry(0, 0, 1 + _controller.value * 0.2)
                          ..setEntry(1, 1, 1 + _controller.value * 0.2),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8 + _controller.value * 16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2 * _controller.value),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.blue, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Opacity(
                          opacity: 0.7 + _controller.value * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expanded ? '已展开' : '点击展开',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '综合动画实战演示',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 展开指示器
                      Transform.rotate(
                        angle: _controller.value * pi / 2,
                        child: const Icon(Icons.expand_more, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  // 展开的详情区
                  ClipRect(
                    child: Align(
                      heightFactor: _controller.value,
                      child: Opacity(
                        opacity: _controller.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white30, height: 1),
                            const SizedBox(height: 16),
                            // 详情项淡入
                            ..._buildDetailItems(),
                            const SizedBox(height: 12),
                            // 操作按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _ActionChip(icon: Icons.thumb_up, label: '点赞', delay: _controller),
                                const SizedBox(width: 8),
                                _ActionChip(icon: Icons.share, label: '分享', delay: _controller),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailItems() {
    const items = [
      _DetailItem(icon: Icons.palette, label: '动画类型', value: '组合动画'),
      _DetailItem(icon: Icons.timer, label: '动画时长', value: '800ms'),
      _DetailItem(icon: Icons.auto_awesome, label: '涉及属性', value: '缩放/旋转/圆角/透明度'),
    ];
    return items;
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Animation<double> delay;
  const _ActionChip({required this.icon, required this.label, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, 20 * (1 - delay.value)),
      child: Opacity(
        opacity: delay.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 以下为通用辅助组件（与 layout/lifecycle 页面保持风格一致）
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
