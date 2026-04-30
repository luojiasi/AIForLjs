import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第三章：框架核心类
/// Widget、Element、RenderObject 的关系与分工
/// ============================================================

class FrameworkClassesDemo extends StatefulWidget {
  const FrameworkClassesDemo({super.key});

  @override
  State<FrameworkClassesDemo> createState() => _FrameworkClassesDemoState();
}

class _FrameworkClassesDemoState extends State<FrameworkClassesDemo> {
  int _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第3章 · 框架核心类'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 本章内容概览 ──
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 三层架构：Widget / Element / RenderObject\n'
            '② BuildContext —— Widget 的「上下文」\n'
            '③ Widget —— 配置描述（蓝图）\n'
            '④ Element —— 实例化与生命周期\n'
            '⑤ RenderObject —— 布局、绘制、命中测试\n'
            '⑥ Key —— Widget 的「身份证」\n'
            '⑦ InheritedWidget —— 数据共享的幕后英雄\n'
            '⑧ build 方法详解\n'
            '⑨ setState 触发了什么',
          ),
          const DividerLine(),

          // ── 1. 用一个比喻理解三层架构 ──
          const SectionHeader('1. 用一个比喻理解三层架构', icon: Icons.home),
          const Paragraph(
            'Flutter 的框架有三层核心类，我们用「盖房子」来比喻：\n\n'
            '🏠 Widget（蓝图）—— 你想建什么样的房子\n'
            '  → 描述房子的位置、大小、颜色，但这不是真的房子\n\n'
            '🏗️ Element（施工队）—— 按照蓝图开始施工\n'
            '  → 把蓝图变成实际存在的房子，并管理房子的结构\n\n'
            '🎨 RenderObject（装修工）—— 负责实际布局和绘制\n'
            '  → 决定墙刷什么颜色、家具怎么摆放\n\n'
            'Flutter 启动后会同时维护三棵树：\n'
            '• Widget 树：开发者编写的配置描述层级\n'
            '• Element 树：框架自动管理的实例层级（桥梁）\n'
            '• RenderObject 树：真正执行布局和绘制的层级\n\n'
            '当 setState 触发重建时，Widget 树重新构建，Flutter\n'
            '通过比对 Element 树找到差异，只更新变化的部分。\n'
            'Widget 极其轻量，可以频繁创建销毁而不影响性能。',
          ),
          const TipBox(
            '三棵树的理解是 Flutter 进阶的基石。日常开发主要和\n'
            'Widget 打交道，但理解背后的原理能帮你写出更优的代码。',
            type: TipType.tip,
          ),

          // ── 2. BuildContext ──
          const DividerLine(),
          const SectionHeader('2. BuildContext —— Widget 的上下文', icon: Icons.explore),
          const Paragraph(
            'BuildContext 是 Flutter 中常见却又容易被忽视的概念。\n'
            '每个 Widget 都有一个 BuildContext，它实际上是该 Widget\n'
            '对应 Element 的引用 —— 是 Element 暴露给开发者的接口。\n\n'
            'BuildContext 提供的能力：\n'
            '• Theme.of(context) —— 获取应用主题\n'
            '• MediaQuery.of(context) —— 获取屏幕尺寸、方向等信息\n'
            '• Navigator.of(context) —— 页面路由与导航\n'
            '• Scaffold.of(context) —— 获取 Scaffold 状态（SnackBar 等）\n'
            '• DefaultTextStyle.of(context) —— 获取默认文本样式\n\n'
            '关键理解：使用 context 本质上是在 Element 树\n'
            '上「上行查找」—— 从当前节点向上遍历，找到最近的匹配节点。\n'
            '这解释了为什么 Dialog 中的 context 无法访问页面 Scaffold。',
          ),
          const CodeBlock(
            r'''// BuildContext = Element 的轻量级接口
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);         // 上行查找 Theme
  final media = MediaQuery.of(context);    // 上行查找 MediaQuery
  Navigator.of(context).pushNamed('/detail'); // 上行查找 Navigator
  return Container(
    color: theme.colorScheme.primary,
    width: media.size.width,
    child: const Text('Hello'),
  );
}''',
            language: 'Dart',
          ),
          const Paragraph(
            'BuildContext 的关键特性：\n'
            '1. 树状节点 — context 沿 Element 树向上查找，不能跨分支\n'
            '2. 作用域边界 — Dialog 中的 context 无法访问页面 Scaffold\n'
            '3. 异步安全 — 异步回调中使用 context 前必须用 mounted 检查',
          ),
          const TipBox(
            '常见错误：在异步回调中使用已 dispose 的 context。\n'
            '一定要用 if (mounted) 检查，这是最常见的崩溃原因之一。',
            type: TipType.caution,
          ),

          // ── 3. Widget 详解 ──
          const DividerLine(),
          const SectionHeader('3. Widget —— 配置描述（蓝图）', icon: Icons.description),
          const Paragraph(
            'Widget 是 Flutter 里「一切皆 Widget」的那个 Widget。\n\n'
            '最关键的特性：Widget 是不可变的（immutable）！\n'
            '所有属性用 final 修饰，一旦创建就不能修改。\n'
            'Widget 只描述界面应该长什么样，本身不占屏幕空间。\n\n'
            'Widget 的类型：\n'
            '• StatelessWidget —— 没有内部状态的配置\n'
            '• StatefulWidget —— 有内部状态的配置（配合 State 对象）\n\n'
            'Flutter 通过 canUpdate 判断是否复用 Element：比较新旧\n'
            'Widget 的 runtimeType 和 key。都相同则复用 Element。',
          ),
          const CodeBlock(
            r'''// Flutter 判断 Element 复用的核心逻辑
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
// 类型变了 → 不能复用，创建新 Element
// key 变了 → 不能复用，创建新 Element
// 类型和 key 都没变 → 复用 Element，只更新配置''',
            language: 'Dart',
          ),
          const TipBox(
            'Widget 不可变的好处：安全、可预测、可缓存。\n'
            '同样的配置永远产生同样的渲染结果。',
            type: TipType.info,
          ),

          // ── 4. Element 详解 ──
          const DividerLine(),
          const SectionHeader('4. Element —— 实例化与生命周期', icon: Icons.construction),
          const Paragraph(
            'Element 是 Widget 的实例化对象，是 Widget 树中的「节点」，\n'
            '也是连接 Widget 和 RenderObject 的桥梁。\n\n'
            'Element 的四个核心生命周期方法：\n\n'
            '1. createElement() —— Widget 调用此方法创建 Element\n'
            '   每个 Widget 类型定义如何创建对应的 Element\n\n'
            '2. mount(parent, slot) —— 插入 Element 树\n'
            '   获得 parent 引用，创建 RenderObject 并挂载\n\n'
            '3. update(newWidget) —— 更新配置\n'
            '   Widget 树重建时复用 Element，更新持有的 Widget 引用\n\n'
            '4. unmount() —— 从 Element 树中移除\n'
            '   清理内部状态，准备销毁\n\n'
            'Element 是「三棵树」的调度中心，负责协调 Widget\n'
            '的配置更新和 RenderObject 的绘制。',
          ),
          const CodeBlock(
            r'''// Element 的简化结构（理解即可，不需自己实现）
abstract class Element {
  Widget _widget;       // 持有的 Widget
  Element? _parent;     // 父节点
  bool _active = false;

  void mount(Element? parent, Object? newSlot) {
    _parent = parent;
    _active = true;
    // RenderObjectElement 还会调用：
    //   widget.createRenderObject(this)
    //   并 attach 到 RenderObject 树
  }

  void update(covariant Widget newWidget) {
    _widget = newWidget;
    rebuild(); // 重建子节点
  }

  void unmount() { _active = false; }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            'Element 还参与命中测试：用户触摸时，Flutter 从\n'
            'RenderObject 树根节点开始遍历，找到触摸点下的\n'
            '所有 RenderObject，通过 Element 链路将事件分发给 Widget。',
          ),

          // ── 5. RenderObject ──
          const DividerLine(),
          const SectionHeader('5. RenderObject —— 布局与绘制', icon: Icons.palette),
          const Paragraph(
            'RenderObject 是真正「干活」的类，负责三件事：\n\n'
            '1. 布局（Layout）—— 确定大小和位置\n'
            '   父节点传递 constraints，子节点计算自己的 size\n'
            '   布局是深度优先的（先子后父）\n\n'
            '2. 绘制（Paint）—— 画到屏幕上\n'
            '   paint() 使用 Canvas API 绘制；RepaintBoundary\n'
            '   可隔离绘制区域，减少不必要的重绘\n\n'
            '3. 命中测试（HitTest）—— 处理触摸事件\n'
            '   hitTest() 判断触摸点是否在自身区域内',
          ),
          const CodeBlock(
            r'''// RenderObject 的三项核心工作
class RenderCustomBox extends RenderBox {
  // 布局：在约束范围内确定大小
  @override
  void performLayout() {
    size = constraints.constrain(Size(200, 100));
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
  }
  // 绘制：画到 Canvas 上
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = Colors.blue);
    if (child != null) context.paintChild(child!, offset);
  }
  // 命中测试：响应触摸
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '常见子类：RenderParagraph（Text）、RenderImage、\n'
            'RenderFlex（Row/Column）、RenderStack、RenderSliverList。',
          ),

          // ── 6. Keys ──
          const DividerLine(),
          const SectionHeader('6. Key —— Widget 的「身份证」', icon: Icons.vpn_key),
          const Paragraph(
            'Key 控制 Flutter 的 Element 复用行为。\n\n'
            '为什么需要 Key？\n'
            '如果没有 key，Flutter 只比较 Widget 的类型和位置。\n'
            '当列表顺序变化时，Element 会被错误复用。\n\n'
            '举例：列表 [A, B, C] 中删除了 A。\n'
            '• 没有 key：B 的 Element 被复用给 A 的位置，状态错乱\n'
            '• 有 key：Flutter 知道 A 离开了，B 和 C 保持不变\n\n'
            'Key 的分类：\n'
            '• LocalKey —— 同一父节点下唯一\n'
            '  • ValueKey(value) —— 基于值比较（最常用）\n'
            '  • ObjectKey(value) —— 基于对象身份比较\n'
            '  • UniqueKey() —— 每次都不同（强制不复用）\n'
            '• GlobalKey —— 整个应用唯一，可跨树访问 State\n'
            '  有性能开销，谨慎使用',
          ),
          const CodeBlock(
            r'''// ❌ 没有 Key —— 列表顺序变化时状态错乱
ListView(
  children: items.map((item) => TodoItem(item: item)).toList(),
)

// ✅ 有 Key —— Flutter 正确追踪每个 Widget
ListView(
  children: items.map((item) => TodoItem(
    key: ValueKey(item.id),
    item: item,
  )).toList(),
)

// GlobalKey 应用：访问 Form 的 State
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// 之后通过 _formKey.currentState!.validate() 验证表单''',
            language: 'Dart',
          ),
          const TipBox(
            '避免在列表中大量使用 GlobalKey，性能会明显下降。\n'
            '95% 的场景用 ValueKey 足以解决问题。',
            type: TipType.warning,
          ),

          // ── 7. InheritedWidget ──
          const DividerLine(),
          const SectionHeader('7. InheritedWidget —— 数据共享的幕后英雄', icon: Icons.share),
          const Paragraph(
            'Theme.of(context) 和 MediaQuery.of(context) 的背后\n'
            '就是 InheritedWidget。\n\n'
            '工作机制：\n'
            '1. 祖先用 InheritedWidget 包裹子树，提供共享数据\n'
            '2. 子节点调用 MyInherited.of(context) 获取数据\n'
            '3. context 沿 Element 树向上查找最近的同类型数据\n'
            '4. updateShouldNotify 判断数据是否变化\n'
            '5. 变化时，依赖它的子节点自动触发\n'
            '   didChangeDependencies 并重建',
          ),
          const CodeBlock(
            r'''// 自定义 InheritedWidget
class MyTheme extends InheritedWidget {
  final ThemeData themeData;
  const MyTheme({
    super.key,
    required this.themeData,
    required super.child,
  });

  static MyTheme of(BuildContext context) {
    // dependOn... 注册依赖，数据变化时自动重建
    return context.dependOnInheritedWidgetOfExactType<MyTheme>()!;
  }

  @override
  bool updateShouldNotify(MyTheme oldWidget) {
    return themeData != oldWidget.themeData;
  }
}''',
            language: 'Dart',
          ),
          const Paragraph(
            '内置关键 InheritedWidget：Theme、MediaQuery、\n'
            'Navigator、Directionality、DefaultTextStyle、Scaffold。',
          ),
          const TipBox(
            'dependOnInheritedWidgetOfExactType 会注册依赖，\n'
            '数据变化时自动重建；findAncestorWidgetOfExactType\n'
            '只查找不依赖，不会触发重建。',
            type: TipType.info,
          ),

          // ── 8. build 方法详解 ──
          const DividerLine(),
          const SectionHeader('8. build 方法详解', icon: Icons.build_circle),
          const Paragraph(
            'build 是每个 Widget 必须实现的方法。\n\n'
            '什么时候调用 build？\n'
            '• Widget 第一次插入 Widget 树时\n'
            '• setState 触发状态更新后\n'
            '• didUpdateWidget 更新配置后\n'
            '• 依赖的 InheritedWidget 数据变化时\n'
            '• 父 Widget 重建导致当前 Widget 需要重建\n\n'
            'build 的黄金法则：\n'
            '• 必须是纯函数 —— 相同输入产生相同输出\n'
            '• 不能有副作用 —— 禁止 setState、网络请求等\n'
            '• 不能执行耗时操作 —— 可能掉帧',
          ),
          const CodeBlock(
            r'''// ✅ 正确：build 只构建 Widget 树
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Counter: $_counter'),
      ElevatedButton(
        onPressed: () => setState(() => _counter++),
        child: const Text('+1'),
      ),
    ],
  );
}
// ❌ 错误：setState(() {}); // 无限循环
// ❌ 错误：_fetchData();    // 每次重建都请求

// ✅ 首次构建后的操作
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _doAfterBuild(); // 只执行一次
  });
}''',
            language: 'Dart',
          ),

          // ── 9. setState 触发了什么 ──
          const DividerLine(),
          const SectionHeader('9. setState 触发了什么？', icon: Icons.refresh),
          const Paragraph(
            'setState 的调用流程：\n\n'
            '步骤 1：标记该 State 对应的 Element 为 dirty\n'
            '步骤 2：下一帧 VSync 信号到来时调用 build()\n'
            '步骤 3：build() 返回新的 Widget 配置树\n'
            '步骤 4：Flutter 对比新旧 Widget 树的差异（diff）\n'
            '步骤 5：通过 canUpdate 决定复用还是新建 Element\n'
            '步骤 6：复用 → update() | 新建 → mount()\n'
            '步骤 7：触发 RenderObject 重新布局和绘制\n\n'
            'setState 不是立即刷新，而是「标记脏、下一帧刷新」。\n'
            '这保证了动画平滑和 60fps 流畅度。\n'
            '前提：必须在 mounted 为 true 时调用。',
          ),
          const CodeBlock(
            r'''// 标准模式
void _onPressed() {
  setState(() => _counter++);
}
// 异步安全模式
void _onAsyncComplete() async {
  final result = await fetchData();
  if (mounted) {
    setState(() => _data = result);
  }
}''',
            language: 'Dart',
          ),

          // 交互示例
          const Paragraph('点击按钮观察 build 被调用的次数：'),
          const SizedBox(height: 8),
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
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _rebuildCount++),
                    child: const Text('触发 setState'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const OutputBox('每次点击按钮，触发一次重建。\n'
              'Flutter 不会重建整棵树，只会重建变化的部分。'),

          // ── 10. 为什么分三层 ──
          const DividerLine(),
          const SectionHeader('10. 为什么 Flutter 要分三层？', icon: Icons.psychology),
          const Paragraph(
            '1. 高性能 —— Widget 是轻量级配置，可频繁创建销毁。\n'
            '   Element 和 RenderObject 被复用，减少开销。\n\n'
            '2. 声明式 UI —— 只描述界面「应该长什么样」，\n'
            '   Flutter 自己决定怎么更新。\n\n'
            '3. 关注点分离 —— 各层各司其职，互不干扰。\n\n'
            '4. 易于优化 —— 每层可独立优化，不影响其他层。',
          ),
          const TipBox(
            '理解 Element 和 RenderObject 的原理，\n'
            '能让你的调试和性能优化更得心应手。',
            type: TipType.tip,
          ),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用自己的话解释 Widget、Element、RenderObject 三者的关系\n'
            '2. 为什么 Widget 必须是 immutable 的？\n'
            '3. 在列表中使用 Key 和不使用 Key，观察状态行为差异\n'
            '4. 写一个自定义 InheritedWidget，实现跨组件数据共享\n'
            '5. 查阅资料：RepaintBoundary 跟 RenderObject 有什么关系？',
          ),
          const SizedBox(height: 8),
          const TipBox('提示：Widget 不可变的好处是安全且可预测——同样的输入永远产生同样的输出。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
