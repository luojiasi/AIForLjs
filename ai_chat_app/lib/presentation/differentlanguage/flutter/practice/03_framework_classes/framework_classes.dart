import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第三章：框架核心类
/// Widget / Element / RenderObject —— Flutter 的三棵树架构深度解析
/// 从 BuildContext 到底层渲染管线的完整知识
/// ============================================================

class FrameworkClassesDemo extends StatefulWidget {
  const FrameworkClassesDemo({super.key});

  @override
  State<FrameworkClassesDemo> createState() => _FrameworkClassesDemoState();
}

class _FrameworkClassesDemoState extends State<FrameworkClassesDemo> {
  int _rebuildCount = 0;
  bool _showElementInfo = false;
  final List<String> _log = [];

  void _addLog(String msg) {
    setState(() {
      _log.add('${DateTime.now().toString().substring(11, 19)}  $msg');
      if (_log.length > 20) _log.removeAt(0);
    });
  }

  @override
  void initState() {
    super.initState();
    _addLog('State 对象已创建 (initState)');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('首帧渲染完成 (postFrameCallback)');
    });
  }

  @override
  Widget build(BuildContext context) {
    _addLog('build() 第${++_rebuildCount}次调用');
    // 防止日志触发无限循环
    return Scaffold(
      appBar: AppBar(title: const Text('第3章 · 框架核心类'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ════════════════════════════════════════════════
          // 本章内容
          // ════════════════════════════════════════════════
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 三层架构全景图：Widget / Element / RenderObject 的分工\n'
            '② Widget —— 不可变的配置蓝图\n'
            '③ Element —— 三棵树的调度中心\n'
            '④ RenderObject —— 布局、绘制、命中测试详解\n'
            '⑤ BuildContext 到底是什么\n'
            '⑥ Key 系统深度解析\n'
            '⑦ InheritedWidget 与依赖追踪\n'
            '⑧ build 方法的底层原理\n'
            '⑨ setState 触发的完整链路\n'
            '⑩ 三棵树协同工作实战',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. 三层架构全景
          // ════════════════════════════════════════════════
          const SectionHeader('1. 三层架构全景图', icon: Icons.home),
          const Paragraph(
            'Flutter 不是一个简单的 UI 库，而是一个完整的渲染框架。\n'
            '它的核心架构分为三个层次，每个层次有自己的职责：\n\n'
            '第一层：Widget（蓝图层）\n'
            '• 你和它打交道最多，写在 build() 方法里的那些类\n'
            '• 每个 Widget 是一个不可变的配置对象\n'
            '• 声明式描述 UI "应该长什么样"（不是"怎么变的"）\n'
            '• Text("Hello") 不是字本身，只是"我要在这里显示 Hello 字样的描述"\n\n'
            '第二层：Element（调度层）\n'
            '• Flutter 框架自动创建的，你通常看不到\n'
            '• 每个 Widget 对应一个 Element，但反过来不一定\n'
            '• 管理 Widget 的实例化、更新、销毁\n'
            '• 连接 Widget 和 RenderObject 的桥梁\n'
            '• BuildContext 就是 Element 暴露给开发者的接口\n\n'
            '第三层：RenderObject（渲染层）\n'
            '• 真正"干活"的层——计算位置、大小、绘制到屏幕\n'
            '• 一个 Element 不一定会创建 RenderObject（如 Column 有，Padding 没有）\n'
            '• RenderObjectElement 的子类才会创建 RenderObject\n'
            '• 负责三件事：Layout / Paint / HitTest',
          ),
          const Paragraph(
            '三棵树的关系用一个比喻：\n'
            '• Widget 树 = 建筑设计图纸（画在纸上，可以撕了重画）\n'
            '• Element 树 = 施工项目经理（拿着图纸，指挥施工，知道哪些墙已经砌好可以复用）\n'
            '• RenderObject 树 = 实际砌好的墙、地砖、窗框（真实存在，看得见摸得着）\n\n'
            '关键洞见：Widget 树每次 setState 都可能重建任意多次，但 Element 树和 RenderObject 树尽量保持不变。\n'
            '框架通过比对 Widget 的 runtimeType 和 key 来决定：复用旧 Element？还是建新的？',
          ),
          const CodeBlock(
            r'''// ─ 三棵树的数据结构关系 ─
//
// Widget 树                    Element 树                  RenderObject 树
// ──────────                  ────────────                ────────────────
// Column                       ColumnElement               (无 RenderObject)
//   ├─ Container                 ├─ ContainerElement         ├─ RenderDecoratedBox
//   │    └─ Text                   │    └─ TextElement       │    └─ RenderParagraph
//   └─ Row                        └─ RowElement              └─ RenderFlex
//        ├─ Icon                       ├─ IconElement              ├─ RenderParagraph
//        └─ Text                       └─ TextElement              └─ RenderParagraph
//
// 注意：不是每个 Widget 都对应一个 RenderObject！
// Column、Row 本身通过 RenderFlex 渲染子节点
// Container 代理到 RenderDecoratedBox
// Padding 代理到 RenderPadding''',
            language: 'Plaintext',
          ),
          const TipBox(
            '每天写 Flutter 代码时，你在构建 Widget 树。\n'
            '理解 Element 树和 RenderObject 树的"隐藏工作"，是写出高性能 Flutter 应用的关键。\n'
            '特别是：Widget 不可变 → 每次重建都是新对象 → 但底层 Element 尽量复用。',
            type: TipType.info,
          ),

          // ════════════════════════════════════════════════
          // 2. Widget 详解
          // ════════════════════════════════════════════════
          const SectionHeader('2. Widget —— 不可变的配置对象', icon: Icons.description),
          const Paragraph(
            'Widget 是 Flutter UI 系统的第一公民。你写的每个界面，本质上是构造了一棵 Widget 配置树。\n\n'
            'Widget 的核心特征：\n\n'
            '① 不可变（Immutable）\n'
            '所有属性都用 final 修饰。一旦创建，就不能修改任何字段。\n'
            '这意味着：你不能 widget.color = Colors.red 来改颜色，必须建一个新 Widget。\n'
            '这看起来很浪费，但实际上 Widget 是极其轻量级的对象（通常只有几十到几百字节）。\n\n'
            '② createElement()\n'
            '每个 Widget 类型都知道如何创建自己的 Element。\n'
            'StatelessWidget → StatelessElement\n'
            'StatefulWidget → StatefulElement\n'
            'Row/Column → MultiChildRenderObjectElement\n'
            'Text → SingleChildRenderObjectElement\n\n'
            '③ canUpdate(old, new)\n'
            '框架判断两个 Widget 是否"等价"的核心方法：\n'
            'return oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key;\n'
            '两条件全满足 → 复用 Element；任一不满足 → 新建 Element\n\n'
            '④ 轻量级\n'
            'Widget 不持有任何重量级资源。它就是一堆 final 字段的集合。\n'
            '每帧都可能创建成百上千个 Widget，但创建成本几乎可以忽略不计。',
          ),
          const CodeBlock(
            r'''// Widget 基类的核心结构（简化）
abstract class Widget {
  final Key? key;   // 只有这一个字段！

  const Widget({this.key});

  // 创建对应的 Element
  @protected
  Element createElement();

  // 判断新旧 Widget 是否可以复用同一个 Element
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType
        && oldWidget.key == newWidget.key;
  }

  // 调试用：描述 Widget 层级
  @override
  String toStringShort() => runtimeType.toString();
}

// StatelessWidget 的 createElement
abstract class StatelessWidget extends Widget {
  // ...
  @override
  StatelessElement createElement() => StatelessElement(this);
}

// StatefulWidget 的 createElement
abstract class StatefulWidget extends Widget {
  // ...
  @override
  StatefulElement createElement() => StatefulElement(this);
}''',
            language: 'Dart',
          ),
          const TipBox(
            'Widget 只有 final 字段（除 key 外没有其他字段），这一点很重要。\n'
            '它意味着：Widget = 纯粹的数据配置。就像 JSON 配置文件一样。\n'
            '这也是为什么 Flutter 能用一个 build 方法就描述整个界面。',
            type: TipType.info,
          ),

          const SectionHeader('2.1 StatelessWidget vs StatefulWidget 的深层差异', icon: Icons.compare),
          const Paragraph(
            '表面差异：StatelessWidget 没状态，StatefulWidget 有状态。\n'
            '深层差异在于 createState() 方法的调用时机和 Element 的行为：\n\n'
            'StatelessElement：\n'
            '• build() 直接委托给 widget.build(this)\n'
            '• Widget 更新时直接换一个 Widget 引用\n'
            '• 没有 State 对象，状态完全由父组件决定\n\n'
            'StatefulElement：\n'
            '• 构造时调用 widget.createState() 创建 State 对象\n'
            '• State 和 Element 通过 _state._element 互相持有引用\n'
            '• Widget 更新时替换 Widget 引用但 State 对象保持不变\n'
            '• State 对象的生命周期由 _StateLifecycle 枚举控制\n'
            '• 内部状态在 Widget 更新时不会丢失\n\n'
            '关键理解：State 对象存活于 Element 中，不是 Widget 中！\n'
            'Widget 被替换了但 Element 被复用 → State 还在。',
          ),

          // ════════════════════════════════════════════════
          // 3. BuildContext 深度解析
          // ════════════════════════════════════════════════
          const SectionHeader('3. BuildContext 深度解析', icon: Icons.explore),
          const Paragraph(
            'BuildContext 是 Flutter 中最常见却最被误解的概念之一。\n\n'
            '它到底是什么？\n'
            'BuildContext 是一个抽象接口，实质是在 Element 树中定位自己的"坐标"。\n'
            '你拿到的每一个 context 参数，实际上是一个 Element 对象。\n\n'
            'BuildContext 的核心能力：\n\n'
            '① 向上查找祖先 Widget\n'
            'Theme.of(context) —— 找到最近的 Theme widget\n'
            'Navigator.of(context) —— 找到最近的 Navigator widget\n'
            'MediaQuery.of(context) —— 获取媒体信息\n'
            'ScaffoldMessenger.of(context) —— 显示 SnackBar\n\n'
            '② 注册依赖关系\n'
            'dependOnInheritedWidgetOfExactType() —— 当数据变化时自动重建\n'
            'findAncestorWidgetOfExactType() —— 只查找不依赖\n'
            'visitAncestorElements() —— 向上遍历所有祖先\n\n'
            '③ 获取 RenderObject\n'
            'findRenderObject() —— 获取当前 Widget 的 RenderObject\n'
            'size —— 获取当前 Widget 的尺寸（需在布局完成后调用）',
          ),
          const CodeBlock(
            r'''// BuildContext 关键方法详解

// 1. dependOnInheritedWidgetOfExactType —— 注册依赖 + 查找
final theme = context.dependOnInheritedWidgetOfExactType<Theme>();
// 当 Theme 数据变化时，当前 Widget 自动标记为 dirty → 触发重建

// 2. findAncestorWidgetOfExactType —— 只查找不依赖
final scaffold = context.findAncestorWidgetOfExactType<Scaffold>();
// 找到 Scaffold 但不监听变化

// 3. visitAncestorElements —— 遍历祖先
bool found = false;
context.visitAncestorElements((element) {
  if (element.widget.runtimeType == Material) {
    found = true;
    return false;  // 停止遍历
  }
  return true;  // 继续向上
});

// 4. visitChildElements —— 遍历子元素
context.visitChildElements((element) {
  // 遍历所有直接子元素
});

// 5. findRenderObject —— 获取渲染对象
final RenderBox? box = context.findRenderObject() as RenderBox?;
final size = box?.size;   // 尺寸
final offset = box?.localToGlobal(Offset.zero);  // 全局坐标''',
            language: 'Dart',
          ),
          const Paragraph(
            'BuildContext 的关键限制：\n'
            '1. 只能向上查找 —— context 不能"向下"找子 Widget\n'
            '2. 不能跨分支查找 —— Row 左边的 context 找不到右边的 Widget\n'
            '3. 不能在 build 期间使用 context.findRenderObject —— 此时布局尚未完成\n'
            '4. 异步回调中使用 context 必须检查 mounted —— Widget 可能已经销毁了',
          ),
          const TipBox(
            '常见误区：Dialog 中 context 的问题\n\n'
            'showDialog({builder: (ctx) => AlertDialog...}) 中的 ctx 是 Dialog 的 context，\n'
            '不在原页面 Scaffold 的子树中，所以 ScaffoldMessenger.of(ctx) 可能找不到。\n'
            '解决方案：在 showDialog 之前用 Builder 包一层，获取 Scaffold 的 context。',
            type: TipType.caution,
          ),

          // ════════════════════════════════════════════════
          // 4. Element 详解
          // ════════════════════════════════════════════════
          const SectionHeader('4. Element —— 调度中心详解', icon: Icons.construction),
          const Paragraph(
            'Element 是连接 Widget 蓝图和 RenderObject 执行者的"桥梁"。\n'
            '每个 Element 持有：一个 Widget 引用、一个 parent Element 引用、以及 0 或 1 个 RenderObject。\n\n'
            'Element 的完整生命周期（七个阶段）：\n\n'
            '阶段1：创建（initial）\n'
            'Widget.createElement() 创建 Element 对象。此时 Element 还没插入树，没有 parent。\n\n'
            '阶段2：挂载（mount）\n'
            'Element.mount(parent, newSlot) 被调用：\n'
            '• 设置 _parent 引用\n'
            '• 设置 _slot（在父节点中的位置）\n'
            '• 将 _lifecycleState 改为 active\n'
            '• 创建 RenderObject（如果是 RenderObjectElement）\n'
            '• 递归挂载子元素\n'
            '• 调用 State.initState()（如果是 StatefulElement）\n\n'
            '阶段3：活动（active）\n'
            'Element 正常工作，响应重建请求。每次 build() 后可能调用 Element.update() 更新 Widget。\n\n'
            '阶段4：更新（update）\n'
            '新旧 Widget runtimeType 和 key 相同时调用。更新持有的 Widget 引用，触发子元素重建。\n\n'
            '阶段5：停用（inactive）\n'
            'Element 从树上临时移除，但有 GlobalKey 引用 → 可能被重新插入（reparent）。\n'
            '没有 GlobalKey 引用 → 一定时间内没重新插入 → 变为 defunct。\n\n'
            '阶段6：移出（unmount）\n'
            'State.dispose() 被调用，RenderObject 被 detach，所有资源释放。\n\n'
            '阶段7：弃用（defunct）\n'
            'Element 已经彻底死亡，等待 GC 回收。',
          ),
          const CodeBlock(
            r'''// Element 生命周期状态枚举
enum _ElementLifecycle {
  initial,    // 刚创建，还没 mount
  active,     // 正常工作状态
  inactive,   // 暂时移除（有 GlobalKey 可能复生）
  defunct,    // 彻底死亡，等 GC
}

// Element 核心方法调用顺序：
// 1. Widget.createElement() → Element 对象（initial 状态）
// 2. Element.mount(parent) → active 状态
//    ├─ 如果是 StatefulElement → State.initState()
//    └─ 如果是 RenderObjectElement → 创建 RenderObject + attach
// 3. Element.update(newWidget) → 更新 Widget 引用
//    └─ State.didUpdateWidget(oldWidget)
// 4. Element.deactivate() → inactive 状态（暂时移除）
// 5a. Element.activate() → 回到 active（被 GlobalKey 救回）
// 5b. Element.unmount() → defunct 状态
//    ├─ State.dispose()
//    └─ RenderObject.dispose()''',
            language: 'Dart',
          ),
          const Paragraph(
            'Element 的性能意义：\n'
            'Element 是"重量级"对象，创建和销毁成本远大于 Widget。\n'
            '这就是为什么 Flutter 尽量复用 Element —— 只更新它持有的 Widget 引用。\n'
            '这就是 canUpdate 机制的真正意义：复用 Element，只换 Widget。\n\n'
            '一个 Widget 可以随意创建（几乎零成本），但 Element 不行。\n'
            '框架通过"Widget 重建 + Element 复用"实现高性能声明式 UI。',
          ),

          // ════════════════════════════════════════════════
          // 5. RenderObject 详解
          // ════════════════════════════════════════════════
          const SectionHeader('5. RenderObject —— 渲染执行者详解', icon: Icons.palette),
          const Paragraph(
            'RenderObject 是 Flutter 渲染管线的最终执行者。\n'
            '它负责三件事：布局（layout）、绘制（paint）、命中测试（hitTest）。\n\n'
            '5.1 布局（Layout）\n'
            '核心方法：performLayout()\n'
            '流程：父组件传递 Constraints → 子组件在这个约束下计算自己的 Size → 父组件根据子组件大小排列它们\n'
            'Constraints 是"限制条件"：minWidth、maxWidth、minHeight、maxHeight\n'
            '布局是深度优先的：先计算子组件的布局，再计算父组件的总尺寸\n\n'
            'Constraint 传递规则（核心！）：\n'
            '• 父传给子：一组约束（Constraints）—— "你最小这么大，最大这么大"\n'
            '• 子传回父：一个 Size —— "我实际多大"\n'
            '• 父决定位置：在父的坐标系中把子放在哪里\n\n'
            '5.2 绘制（Paint）\n'
            '核心方法：paint(PaintingContext context, Offset offset)\n'
            '流程：绘制自身（Canvas API）→ 绘制子组件（context.paintChild(child, offset)）\n'
            '绘制顺序：父先画自身背景 → 子画 → 父画前景\n'
            'RepaintBoundary：绘制隔离边界，该区域内的重绘不影响外部\n\n'
            '5.3 命中测试（HitTest）\n'
            '核心方法：hitTest(HitTestResult result, {Offset position})\n'
            '触摸事件从 RenderView 向下传递，找到被点击的 RenderObject\n'
            '流程：判断触摸点是否在自己范围内 → 是则加入结果 → 交给子节点继续检测',
          ),
          const CodeBlock(
            r'''// ─ 自定义 RenderBox 完整示例 ─
class RenderColorBar extends RenderBox {
  Color _color = Colors.blue;
  double _progress = 0.5;

  set color(Color c) { if (_color != c) { _color = c; markNeedsPaint(); } }
  set progress(double p) { if (_progress != p) { _progress = p; markNeedsLayout(); } }

  // 1. 布局：在约束内确定自己的大小
  @override
  void performLayout() {
    // 接受约束但只占满宽度，高度固定
    size = Size(constraints.maxWidth, 30);
  }

  // 2. 绘制：用 Canvas 画进度条
  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // 背景
    canvas.drawRect(rect, Paint()..color = Colors.grey[300]!);
    // 进度条
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width * _progress, size.height),
      Paint()..color = _color,
    );
  }

  // 3. 命中测试：在范围内就响应
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // position 相对于自身坐标系的点击位置
    if (size.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  // 4. 固有尺寸（可选）：预估理想大小
  @override
  double computeMinIntrinsicHeight(double width) => 30;
  @override
  double computeMaxIntrinsicHeight(double width) => 30;
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '常见 RenderObject 子类速查：\n'
            '• RenderParagraph —— 文本渲染（Text Widget 背后）\n'
            '• RenderImage —— 图片渲染\n'
            '• RenderFlex —— Row / Column 的布局逻辑\n'
            '• RenderStack —— Stack 的层叠布局\n'
            '• RenderSliverList —— 可滚动列表中的"条目"\n'
            '• RenderDecoratedBox —— Container 的装饰绘制\n'
            '• RenderClipRect —— ClipRect 的裁切\n'
            '• RenderOpacity —— 透明度\n'
            '• RenderTransform —— 变换（旋转、缩放、平移）',
          ),

          // ════════════════════════════════════════════════
          // 6. Key
          // ════════════════════════════════════════════════
          const SectionHeader('6. Key 系统深度解析', icon: Icons.vpn_key),
          const Paragraph(
            'Key 存在的唯一目的：帮 Flutter 判断哪些 Element 可以复用。\n\n'
            '没有 Key 时：\n'
            'Flutter 通过"同级位置"来找匹配的 Element。\n'
            '列表 [A, B, C] 删除 A 后变成 [B, C]，Flutter 会把旧 B 的 Element 匹配给新位置0（现在是 B 的 Widget），\n'
            '旧 C 匹配给新位置1（现在是 C 的 Widget），A 的 Element 被释放。虽然没有"状态错乱"，\n'
            '但是 B 和 C 发生了不必要的 Element 更新（update 调用）。\n\n'
            '有 Key 时：\n'
            'Flutter 先用 key 找匹配 Element，如果找不到再按位置找。\n'
            '列表 [A, B, C] 删除 A 后，B 和 C 的 key 不变 → Element 直接复用，只进行位置调整。\n\n'
            'Key 为什么重要：\n'
            '1. 避免状态丢失 —— 带有 StatefulWidget 的列表项，没 key 时状态可能错乱\n'
            '2. 提升性能 —— 减少不必要的 Element 创建和更新\n'
            '3. 动画正确 —— AnimatedList 等依赖 key 来追踪项',
          ),
          const CodeBlock(
            r'''// Key 的类型体系
// Key（抽象类）
//   ├─ LocalKey ──── 同父节点下唯一
//   │    ├─ ValueKey<T>(value) ── 基于值的相等判断（最常用）
//   │    ├─ ObjectKey(value) ── 基于对象引用相等判断
//   │    └─ UniqueKey() ── 每次都不同，强制不复用
//   └─ GlobalKey<T extends State> ──── 全局唯一，可跨树访问
//        ├─ GlobalKey() ── 普通全局 key
//        └─ GlobalObjectKey(value) ── 基于对象的全局 key

// ─ 选择指南 ─
// ValueKey：绝大部分场景。列表项有唯一 id 时用它
ListView(children: items.map((item) =>
  TodoItem(key: ValueKey(item.id), item: item),
));

// ObjectKey：当值相等但对象引用不同时需要区分
final a = Todo('早餐'); final b = Todo('早餐'); // 内容相同但两个对象
TodoItem(key: ObjectKey(a), item: a);       // ObjectKey 通过 identical 比较

// UniqueKey：希望强制重建（如动画重置）
AnimatedSwitcher(
  child: Container(
    key: UniqueKey(),  // 每次 build 都不同，强制重建动画
    // ...
  ),
);

// GlobalKey：需要跨树访问 State 时
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// 任意地方：_formKey.currentState?.validate()

// GlobalKey<ScaffoldState>：打开 Drawer 或显示 SnackBar
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
_scaffoldKey.currentState?.openDrawer();''',
            language: 'Dart',
          ),
          const TipBox(
            'GlobalKey 的使用成本：\n'
            '• 每个 GlobalKey 都会注册到全局 map 中，有哈希查找成本\n'
            '• 列表中使用大量 GlobalKey 会显著降低性能\n'
            '• GlobalKey 的 Element 被移除后不会立即释放 → 消耗更多内存\n'
            '• 仅在必要时使用 GlobalKey，大多数情况用 ValueKey 即可',
            type: TipType.warning,
          ),

          // ════════════════════════════════════════════════
          // 7. InheritedWidget
          // ════════════════════════════════════════════════
          const SectionHeader('7. InheritedWidget —— 数据向下传递的管道', icon: Icons.share),
          const Paragraph(
            'InheritedWidget 是 Flutter 状态管理的基础设施。Provider、Bloc、Riverpod 等方案的底层几乎都依赖它。\n\n'
            '它解决的核心问题：\n'
            '在深层 Widget 树中，祖先的数据如何高效传递给任意深度的后代，而不需要一层层通过构造函数传参。\n\n'
            '工作流程：\n'
            '1. 祖先创建 InheritedWidget，将数据作为属性传入\n'
            '2. 后代通过 context.dependOnInheritedWidgetOfExactType<T>() 获取数据\n'
            '3. 这个调用会"注册依赖"——当前 Element 被加入 InheritedElement 的依赖列表\n'
            '4. 当 InheritedWidget 的 updateShouldNotify 返回 true 时，所有注册过的后代自动重建\n\n'
            '关键方法对比：\n'
            '• dependOnInheritedWidgetOfExactType<T>() —— 获取数据 + 注册依赖（数据变自动重建）\n'
            '• getInheritedWidgetOfExactType<T>() —— 获取数据但不注册依赖\n'
            '• findAncestorWidgetOfExactType<T>() —— 在 Widget 层查找祖先（不注册）',
          ),
          const CodeBlock(
            r'''// ─ 自定义 InheritedWidget 完整示例 ─
class CounterScope extends InheritedWidget {
  final int count;
  final VoidCallback increment;

  const CounterScope({
    super.key,
    required this.count,
    required this.increment,
    required super.child,
  });

  // 提供便捷静态方法
  static CounterScope of(BuildContext context) {
    // 注册依赖：counter 变了，当前 Widget 自动重建
    return context.dependOnInheritedWidgetOfExactType<CounterScope>()!;
  }

  // 另一种：只读取不依赖（用于 onPressed 回调中）
  static CounterScope read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<CounterScope>()!;
  }

  @override
  bool updateShouldNotify(CounterScope oldWidget) {
    return count != oldWidget.count;  // 仅 count 变化时通知
  }
}

// 使用：
// 祖先层（如 MaterialApp 上方）
CounterScope(count: _count, increment: _increment, child: ChildWidget(),)

// 任意深层的后代
@override
Widget build(BuildContext context) {
  final scope = CounterScope.of(context);  // 自动注册依赖
  return Text('${scope.count}');
}''',
            language: 'Dart',
          ),
          const Paragraph(
            'InheritedWidget 的性能考虑：\n'
            '• updateShouldNotify 的返回值直接影响性能 —— 不要总返回 true\n'
            '• 只比较真正影响 UI 的字段，不要做深度对象比较\n'
            '• 把 InheritedWidget 放在尽可能高的层级——覆盖范围越大但更新影响也越大\n'
            '• 不要在一个 InheritedWidget 中放太多无关数据——不同数据分开不同的 InheritedWidget',
          ),

          // ════════════════════════════════════════════════
          // 8. build 底层原理
          // ════════════════════════════════════════════════
          const SectionHeader('8. build 方法的底层原理', icon: Icons.build_circle),
          const Paragraph(
            'build() 是你最常写的 Flutter 方法，但它底层到底发生了什么？\n\n'
            '调用时机（五种情况）：\n'
            '1. 首次插入 —— Element.mount() 中，State.initState() 后在 postFrameCallback 之前调用\n'
            '2. setState 触发 —— 标记 Element 为 dirty，下一帧调用\n'
            '3. didUpdateWidget —— 父组件重建传了新 Widget，更新配置后调用\n'
            '4. InheritedWidget 数据变化 —— 依赖的后代 Element 标记为 dirty\n'
            '5. 父 Element rebuild —— 父更新后，子 Element 可能需要更新\n\n'
            'build 的黄金法则：\n'
            '• 必须是纯函数 —— 相同状态产生相同的 Widget 树\n'
            '• 禁止副作用 —— 不能发网络请求、不能直接操作数据库、不能 setState\n'
            '• 不能耗时 —— build 卡顿直接导致掉帧\n'
            '• 不依赖外部可变状态 —— 除了 this.state 和 context 提供的数据\n\n'
            '框架在 build 后的工作（自动完成，开发者无需关心）：\n'
            '1. 收集新 Widget 树和旧 Widget 树的差异\n'
            '2. 调用 canUpdate 逐节点比对\n'
            '3. 对可复用的 Element 调用 update(newWidget)\n'
            '4. 对不可复用的创建新 Element 并 mount\n'
            '5. 移除不再需要的 Element 并 dispose',
          ),
          const CodeBlock(
            r'''// build 方法的内部调用路径（简化）
//
// setState(fn) →
//   _element.markNeedsBuild() → 标记 dirty
//   (下一帧 VSync) →
//   _element.rebuild() →
//     if (widget is StatelessWidget):
//       widget.build(this)           ← 你写的 build
//     else if (widget is StatefulWidget):
//       state.build(this)            ← 你写的 build
//     → 得到新 Widget 树
//     → updateChild(旧树, 新树)    ← Flutter 自动 diff
//       ├─ 类型相同+key相同 → Element.update(newWidget)
//       └─ 类型不同或 key不同 → 新建 Element + mount

// ─ 首次构建的时间线 ─
// 1. Widget.createElement()
// 2. Element.mount(parent)
//    ├─ State.initState()
//    ├─ Element._firstBuild()  ← 触发首次 build
//    │   └─ State.build(context)   ← 你写的 build
//    └─ (下一帧) postFrameCallback''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 9. setState 触发链路
          // ════════════════════════════════════════════════
          const SectionHeader('9. setState 触发的完整链路', icon: Icons.refresh),
          const Paragraph(
            'setState 是 Flutter 中最基础的"让界面刷新"的方式。但它在底层触发了什么？\n\n'
            '完整步骤分解：\n\n'
            '步骤1：setState(fn) 被调用\n'
            '• 执行 fn 回调（更新状态变量）\n'
            '• 将 _StateLifecycle 状态设为 dirty\n'
            '• 调用 Element.markNeedsBuild() 把当前 Element 加入脏列表\n\n'
            '步骤2：调度一个微任务（microtask）\n'
            '• 不是立即执行，而是等到当前同步代码执行完毕\n'
            '• 多个 setState 在同一个事件循环中会合并成一次 rebuild\n\n'
            '步骤3：VSync 信号到达\n'
            '• SchedulerBinding 收到新的帧回调\n'
            '• 遍历所有的"脏 Element"并为每个调用 rebuild\n\n'
            '步骤4：Element.rebuild()\n'
            '• 调用 widget.build(context) 或 state.build(context)\n'
            '• 得到新的 Widget 树\n\n'
            '步骤5：差分更新\n'
            '• Element.updateChild() 逐节点对比新旧 Widget\n'
            '• 类型相同的 → 复用 Element 并 update(newWidget)\n'
            '• 类型不同的 → 创建新 Element 并 mount\n\n'
            '步骤6：渲染更新\n'
            '• 标志为 dirty 的 Element 触发 RenderObject.markNeedsLayout() 或 markNeedsPaint()\n'
            '• 下一帧的渲染管线中执行布局和绘制\n\n'
            '步骤7：引擎提交\n'
            '• GPU 收到新的 Layer 树\n'
            '• 提交到屏幕',
          ),
          const CodeBlock(
            r'''// setState 源码（简化）
@protected
void setState(VoidCallback fn) {
  assert(fn != null);
  assert(() {
    if (_debugLifecycleState == _StateLifecycle.defunct) {
      throw FlutterError('setState() called after dispose(): $this');
    }
    if (_debugLifecycleState == _StateLifecycle.created && !mounted) {
      throw FlutterError('setState() called in constructor: $this');
    }
    return true;
  }());
  final result = fn() as dynamic;  // ① 执行回调
  _element!.markNeedsBuild();      // ② 标记 dirty
  // ③ 框架在下一帧自动调用 Element.rebuild()
}

// markNeedsBuild 关键代码
void markNeedsBuild() {
  if (!_active) return;
  if (_dirty) return;           // 已经是 dirty，不重复标记
  _dirty = true;
  owner!.scheduleBuildFor(this); // 加入全局"脏列表"
}

// setState 合并机制：
// 用户代码：
void _bad() {
  setState(() => _a++);  // 第一次标记 dirty
  setState(() => _b++);  // 第二次发现已经 dirty → 跳过
  setState(() => _c++);  // 同上
}
// 实际上 _a, _b, _c 都变了，但只触发一次 rebuild

// 异步安全：
void _onComplete() async {
  final data = await fetchData();
  if (!mounted) return;       // ← 重要！Widget 可能已销毁
  setState(() => _data = data);
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 10. 三层协作实战
          // ════════════════════════════════════════════════
          const SectionHeader('10. 三棵树协作实战 —— 调试你的理解', icon: Icons.live_help),
          const Paragraph(
            '假设你有一个 Counter 页面，点击按钮后发生了以下操作，逐一思考对应的层：\n\n'
            '1. 用户点击 "+1" 按钮\n'
            '   → RenderObject 层：hitTest 检测到点击位置在按钮范围内\n'
            '   → Element 层：事件通过手势系统传递到 GestureDetector\n'
            '   → Widget 层：onPressed 回调被调用\n\n'
            '2. onPressed 中调用 setState(() => _counter++)\n'
            '   → Widget 层：_counter 从 0 变为 1\n'
            '   → Element 层：Element 被标为 dirty\n'
            '   → 等待下一帧\n\n'
            '3. 下一帧的 VSync 触发\n'
            '   → Element 层：Element.rebuild() → State.build(context)\n'
            '   → Widget 层：新的 Text("Count: 1") Widget 被创建\n'
            '   → Element 层：canUpdate 比对（类型和 key 都没变）→ Element.update(newWidget)\n'
            '   → RenderObject 层：RenderParagraph.text = "Count: 1" — 文本内容变了\n\n'
            '4. 渲染管线\n'
            '   → RenderObject.markNeedsLayout（如果大小变了）或 markNeedsPaint（只颜色/内容变）\n'
            '   → Paint 阶段：Canvas.drawParagraph("Count: 1")\n'
            '   → GPU 提交，屏幕更新',
          ),
          const TipBox(
            '思考题：如果 StatefulWidget 的 key 变了会怎样？\n'
            '答：canUpdate 返回 false → 旧 Element 被 unmount 并 dispose → 新 Element 被创建并 mount → State.initState 被重新调用 → 所有状态丢失。',
            type: TipType.info,
          ),

          // ════════════════════════════════════════════════
          // 11. 交互演示
          // ════════════════════════════════════════════════
          const SectionHeader('🟢 交互演示：观察重建过程', icon: Icons.touch_app),
          const Paragraph('点击下方按钮触发 setState，观察日志中 build 被调用的次数。注意：每次按钮点击只触发一次重建。'),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('build() 被调用了', style: TextStyle(fontSize: 14)),
                  Text(
                    '$_rebuildCount 次',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('触发 setState'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 日志查看
          Row(
            children: [
              const Text('生命周期日志', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: () => setState(() => _log.clear()), child: const Text('清空')),
            ],
          ),
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (context, index) => Text(
                _log[index],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent, height: 1.4),
              ),
            ),
          ),

          // ════════════════════════════════════════════════
          // 12. 常见面试题
          // ════════════════════════════════════════════════
          const SectionHeader('12. 高频面试题', icon: Icons.quiz),
          const Paragraph(
            'Q1: Widget 和 Element 有什么关系？\n'
            'A: Widget 是配置（蓝图），Element 是实例（实际的节点）。一个 Widget 可以对应多个 Element（如 ListView 中的模板 Widget 被多次实例化）。Element 持有 Widget 的引用。\n\n'
            'Q2: BuildContext 是什么？\n'
            'A: BuildContext 是 Element 的接口。它代表当前 Widget 在 Widget 树中的位置。通过它可以查找祖先 Widget、获取 Theme/MediaQuery 等。\n\n'
            'Q3: 为什么 Widget 是不可变的？\n'
            'A: 可预测性（相同配置 = 相同 UI）、可缓存、可复用。Flutter 通过快速创建/销毁 Widget + 复用 Element 来实现高性能声明式 UI 更新。\n\n'
            'Q4: setState 之后发生了什么？\n'
            'A: 执行回调 → 标记 Element 为 dirty → 下一帧 VSync → Element.rebuild() → build(context) → 新 Widget 树 → Widget/Element 差分对比 → 更新 RenderObject → 重新布局/绘制。\n\n'
            'Q5: GlobalKey 和 LocalKey 的区别？\n'
            'A: LocalKey 只在同父节点下比较；GlobalKey 在整个 App 中唯一，可以跨树访问 State。GlobalKey 有性能开销。\n\n'
            'Q6: InheritedWidget 和普通 Widget 有什么区别？\n'
            'A: InheritedWidget 会建立依赖追踪。子组件通过 dependOn... 注册依赖后，当 InheritedWidget 的 updateShouldNotify 返回 true，这些子组件自动重建。',
          ),

          // ════════════════════════════════════════════════
          // 13. 总结
          // ════════════════════════════════════════════════
          const SectionHeader('13. 总结', icon: Icons.summarize),
          const Paragraph(
            'Flutter 框架的核心架构是 Widget-Element-RenderObject 三层模型：\n\n'
            'Widget 层（你的代码）—— 不可变的配置，声明式描述 UI\n'
            'Element 层（框架管理）—— Widget 的实例，管理生命周期和差分更新\n'
            'RenderObject 层（框架管理）—— 执行布局、绘制、命中测试\n\n'
            '理解这个架构的好处：\n'
            '• 写出更高效的代码（知道什么情况下 Element 被复用）\n'
            '• 调试更方便（知道 rebuild 的原因）\n'
            '• 理解状态管理方案的原理（都是基于 InheritedWidget 或其变体）\n'
            '• 面试更有信心（这些问题太常问了）\n\n'
            '核心口诀：\n'
            'Widget 画蓝图（不可变、轻量、可随意创建）\n'
            'Element 做管理（复用、调度、连接桥梁）\n'
            'RenderObject 干实活（布局、绘制、命中测试）',
          ),

          // ════════════════════════════════════════════════
          // 14. 小练习
          // ════════════════════════════════════════════════
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用自己的话解释 Widget、Element、RenderObject 三者的关系\n'
            '2. 写出 canUpdate 的两个判断条件及其作用\n'
            '3. 解释为什么 StatefulWidget 的 key 改变会导致状态丢失\n'
            '4. 写一个自定义 InheritedWidget 并验证 dependOn 的自动重建行为\n'
            '5. 用 RepaintBoundary 包裹一个动画组件，用 DevTools 观察重绘区域变化\n'
            '6. 追踪一次 setState 的完整调用链路（用断点或 print 日志）\n'
            '7. 解释 GlobalKey 为什么有性能开销，以及应该在什么场景下使用它\n'
            '8. 尝试自己写一个自定义 Container（通过 RenderBox 实现基本的布局和绘制）',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
