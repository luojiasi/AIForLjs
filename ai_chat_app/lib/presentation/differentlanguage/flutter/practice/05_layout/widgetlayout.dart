import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第五章：布局系统完全指南
/// 从布局模型原理到所有布局 Widget 的完全掌握
/// 涵盖：Flutter 布局模型、约束系统、所有布局 Widget、
///       响应式设计、常见布局模式
/// ============================================================

class WidgetLayoutDemo extends StatefulWidget {
  const WidgetLayoutDemo({super.key});
  @override
  State<WidgetLayoutDemo> createState() => _WidgetLayoutDemoState();
}

class _WidgetLayoutDemoState extends State<WidgetLayoutDemo> {
  int _rowIdx = 0;
  int _crossIdx = 0;
  bool _showBadge = true;
  bool _clipStack = false;
  int _flexFitIdx = 0;
  double _fraction = 50;
  double _wrapSpacing = 8;
  int _wrapItemCount = 6;

  final List<MainAxisAlignment> _aligns = [
    MainAxisAlignment.start, MainAxisAlignment.center, MainAxisAlignment.end,
    MainAxisAlignment.spaceBetween, MainAxisAlignment.spaceAround, MainAxisAlignment.spaceEvenly,
  ];
  final List<CrossAxisAlignment> _crossAligns = [
    CrossAxisAlignment.start, CrossAxisAlignment.center, CrossAxisAlignment.end, CrossAxisAlignment.stretch,
  ];

  String _aName(MainAxisAlignment a) => switch (a) {
    MainAxisAlignment.start => 'start', MainAxisAlignment.center => 'center',
    MainAxisAlignment.end => 'end', MainAxisAlignment.spaceBetween => 'spaceBetween',
    MainAxisAlignment.spaceAround => 'spaceAround', MainAxisAlignment.spaceEvenly => 'spaceEvenly',
  };

  String _cName(CrossAxisAlignment a) => switch (a) {
    CrossAxisAlignment.start => 'start', CrossAxisAlignment.center => 'center',
    CrossAxisAlignment.end => 'end', CrossAxisAlignment.stretch => 'stretch',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final curA = _aligns[_rowIdx];
    final curC = _crossAligns[_crossIdx];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('第5章 · 布局系统'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① Flutter 布局模型：约束向下、尺寸向上\n'
            '② BoxConstraints 详解\n'
            '③ LayoutBuilder —— 响应父约束\n'
            '④ Flex 家族：Row、Column、Flex\n'
            '⑤ MainAxisAlignment vs CrossAxisAlignment\n'
            '⑥ Expanded vs Flexible\n'
            '⑦ Wrap / Flow —— 自动换行\n'
            '⑧ Stack + Positioned —— 层叠布局\n'
            '⑨ 比例尺寸：AspectRatio、FractionallySizedBox\n'
            '⑩ 约束盒子：ConstrainedBox、SizedBox、LimitedBox、OverflowBox\n'
            '⑪ Intrinsic 系列\n'
            '⑫ MediaQuery\n'
            '⑬ 响应式布局实战',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. Flutter 布局模型
          // ════════════════════════════════════════════════
          const SectionHeader('1. Flutter 布局模型 —— 约束向下，尺寸向上', icon: Icons.account_tree),
          const Paragraph(
            'Flutter 的布局系统和 HTML/CSS 完全不同。理解它的核心模型是掌握 Flutter 布局的关键。\n\n'
            '核心规则（每个 Flutter 开发者必须牢记的公式）：\n'
            'Constraints go DOWN（约束向下传递）\n'
            'Sizes go UP（尺寸向上报告）\n'
            'Parent sets position（父组件决定子组件位置）\n\n'
            '完整流程：\n'
            '1. 父组件将约束（Constraints）传递给子组件\n'
            '   约束包括：minWidth、maxWidth、minHeight、maxHeight\n'
            '   例如：minWidth=0, maxWidth=360, minHeight=0, maxHeight=infinity\n\n'
            '2. 子组件根据约束决定自己的大小（Size）\n'
            '   子组件可以选择在 min 和 max 之间任意值\n'
            '   例如：在这个约束下，子组件决定自己的大小 = 100x50\n\n'
            '3. 父组件收到子组件的大小，决定子组件的位置\n'
            '   根据对齐方式（mainAxisAlignment、crossAxisAlignment）排列\n\n'
            '关键限制：子组件不能"无视"父亲的约束！\n'
            '如果父亲说 maxWidth=200，子组件不能变成 300。\n'
            '这导致了很多新手困惑：为什么设置了 width: 300 却不起作用？',
          ),
          const CodeBlock(
            r'''// Flutter 的布局算法（核心公式）：
//
// 父: 给出约束 constraints = BoxConstraints(minW, maxW, minH, maxH)
//   ↓
// 子: 收到约束 → 决定自己的 size
//      size 必须在 [minW..maxW] × [minH..maxH] 之间
//   ↑
// 父: 收到 size → 决定子 offset，放置子组件
//
// ─ 举例：屏幕上的 Column ─
// 1. RenderView 给 Column 约束：w=[0, 360], h=[0, 640]
// 2. Column 遍历子组件，逐个给每个子约束：
//    子1 Text:     w=[0, 360], h=[0, 640] → Text 报告 size = 360x20
//    子2 Button:   w=[0, 360], h=[0, 620] → Button 报告 size = 100x48
//    3 Container:  w=[0, 360], h=[0, 572] → Container 报告 size = 360x200
// 3. Column 总高度 = 20 + 48 + 200 = 268
//    报告自己的 size = 360x268
// 4. RenderView 把 Column 放在 offset=(0, 0)''',
            language: 'Plaintext',
          ),
          const TipBox(
            '如果子组件设置了大小但没生效，99% 是因为父组件的约束限制了它。\n'
            '比如 Row 里的 Container(width:300) 不生效，因为 Row 给了它一个有限的 maxWidth。\n'
            '解决方案：用 Expanded 或 Flexible 包裹。',
            type: TipType.info,
          ),

          // ════════════════════════════════════════════════
          // 2. BoxConstraints
          // ════════════════════════════════════════════════
          const SectionHeader('2. BoxConstraints 详解', icon: Icons.crop_square),
          const Paragraph(
            'BoxConstraints 是 Flutter 布局的核心数据结构。它由四个属性组成：\n\n'
            '• minWidth —— 子组件的最小宽度（默认 0）\n'
            '• maxWidth —— 子组件的最大宽度（默认 double.infinity）\n'
            '• minHeight —— 子组件的最小高度（默认 0）\n'
            '• maxHeight —— 子组件的最大高度（默认 double.infinity）\n\n'
            '常用约束模式：\n\n'
            '• loose 约束（宽松）：min=0，max 有值。子组件可以不填满。\n'
            '  Row/Column 默认给子组件 loose 约束（maxWidth=maxHeight=infinity）\n\n'
            '• tight 约束（严格）：min=max。子组件必须正好这个大小。\n'
            '  AppBar 给子组件 tight 约束（固定高度）\n\n'
            '• bounded 约束（有界）：max 有限值。子组件不能超过。\n'
            '  ListView 给子组件 bounded 约束（maxWidth=viewport）\n\n'
            '• unbounded 约束（无界）：max=infinity。子组件多大都行。\n'
            '  SingleChildScrollView 给子组件 unbounded 约束',
          ),
          const CodeBlock(
            r'''// BoxConstraints 的常用创建方式
BoxConstraints.tight(Size(100, 100))     // min=max=100
BoxConstraints.tightFor(width: 100)      // minW=maxW=100, minH=0, maxH=inf
BoxConstraints.loose(Size(200, 200))     // min=0, max=200
BoxConstraints.expand(width: 200, height: 300)  // min=max=200×300
BoxConstraints(minWidth: 50, maxWidth: 200)     // 自定义区间

// 检查约束
constraints.isTight      // min == max ?
constraints.hasTightWidth   // minW == maxW ?
constraints.hasInfiniteWidth  // maxW == double.infinity ?
constraints.hasBoundedWidth  // maxW != infinity ?
constraints.constrain(Size(200, 100))  // 将 Size 限制在约束内''',
            language: 'Dart',
          ),
          const TipBox(
            '理解 BoxConstraints 是学好 Flutter 布局的密码。\n'
            '当布局不对时，先问自己：父组件给的约束是什么？',
            type: TipType.tip,
          ),

          // ════════════════════════════════════════════════
          // 3. LayoutBuilder
          // ════════════════════════════════════════════════
          const SectionHeader('3. LayoutBuilder —— 根据可用空间决定布局', icon: Icons.build),
          const Paragraph(
            'LayoutBuilder 是 Flutter 响应式布局的最基础工具。\n'
            '它在构建时获取父组件传下来的 BoxConstraints，让你根据可用空间决定布局。\n\n'
            '参数：\n'
            '• builder: (BuildContext, BoxConstraints) → Widget\n'
            '   第一个参数是 build 的 context，第二个是父传来的约束\n\n'
            '何时重建：\n'
            '• 父组件的约束发生变化时（如窗口大小改变）\n'
            '• 不会因为其他原因重建（不会受 setState 影响——除非父重建）\n\n'
            '典型用途：\n'
            '• 根据宽度选择横排/竖排（移动端/桌面端适配）\n'
            '• 控制子组件数量（宽屏显示更多列）\n'
            '• 自适应文字大小\n'
            '• 根据剩余空间决定是否显示某些元素',
          ),
          const CodeBlock(
            r'''// LayoutBuilder 常用模式
LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth = constraints.maxWidth;

    // 模式1: 根据宽度选择布局
    if (maxWidth < 600) {
      return _buildMobileLayout();
    } else if (maxWidth < 1200) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }

    // 模式2: 根据宽度选择列数
    final columns = maxWidth ~/ 200;  // 每列200px
    return Wrap(children: List.generate(children, ...));

    // 模式3: 根据高度选择
    if (constraints.maxHeight > 400) {
      return _buildWithImage();
    }
    return _buildWithoutImage();
  },
)''',
            language: 'Dart',
          ),
          // 交互演示
          Builder(builder: (context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Container(
                  width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('可用宽度: ${w.toStringAsFixed(0)}px', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (w > 350)
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        _SmallBox(color: Colors.red), _SmallBox(color: Colors.green), _SmallBox(color: Colors.blue),
                      ])
                    else
                      Column(children: [
                        _SmallBox(color: Colors.red), const SizedBox(height: 4),
                        _SmallBox(color: Colors.green), const SizedBox(height: 4),
                        _SmallBox(color: Colors.blue),
                      ]),
                    Text(w > 350 ? '宽屏模式 (>350px) → Row' : '窄屏模式 (<=350px) → Column', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ]),
                );
              },
            );
          }),
          const TipBox('LayoutBuilder 拿到的约束是父给了多少空间，不是屏幕尺寸。如果父是 SizedBox(width:200)，LayoutBuilder 拿到的 maxWidth 就是 200。', type: TipType.info),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 4. Flex 家族
          // ════════════════════════════════════════════════
          const SectionHeader('4. Flex 家族：Row、Column、Flex', icon: Icons.linear_scale),
          const Paragraph(
            'Row、Column、Flex 是 Flutter 中最常用的布局组件。Row 横向排列子组件，Column 纵向排列。\n\n'
            '三者关系：\n'
            '• Row = Flex(direction: Axis.horizontal)\n'
            '• Column = Flex(direction: Axis.vertical)\n'
            '• Flex 可以直接指定任意 direction\n\n'
            '两个核心对齐属性：\n'
            '• mainAxisAlignment —— 主轴（Row 是水平、Column 是垂直）的对齐方式\n'
            '• crossAxisAlignment —— 交叉轴的对齐方式\n\n'
            '六个 MainAxisAlignment 详解：\n'
            '• start —— 靠主轴起始端（默认）\n'
            '• center —— 居中\n'
            '• end —— 靠主轴末端\n'
            '• spaceBetween —— 两端靠边，中间均匀分布（子组件之间空间相等）\n'
            '• spaceAround —— 每个子组件前后空间相等（首尾空间是间距的一半）\n'
            '• spaceEvenly —— 所有间距完全相等（包括首尾）\n\n'
            '四个 CrossAxisAlignment 详解：\n'
            '• start —— 靠交叉轴起始端\n'
            '• center —— 居中\n'
            '• end —— 靠交叉轴末端\n'
            '• stretch —— 拉伸填满交叉轴（子组件高度强制等于 Row 高度）',
          ),
          const CodeBlock(
            r'''// Row/Column 的关键属性和用途
Row(
  mainAxisAlignment: MainAxisAlignment.center,    // 主轴对齐
  crossAxisAlignment: CrossAxisAlignment.center,  // 交叉轴对齐
  mainAxisSize: MainAxisSize.min,   // 包裹内容（默认 max，占满父组件）
  verticalDirection: VerticalDirection.down,  // 垂直方向（影响 Column 的 start/end）
  textDirection: TextDirection.ltr,  // 文本方向（影响 Row 的 start/end）
  textBaseline: TextBaseline.alphabetic,  // 文本基线（crossAxisAlignment=baseline 时用）
  children: [...],
)

// Flex 参数完全一样，多一个 direction
Flex(
  direction: Axis.horizontal,   // 或 Axis.vertical
  // ...其余属性同 Row/Column
)''',
            language: 'Dart',
          ),
          // MainAxisAlignment 交互演示
          Center(child: Text('MainAxisAlignment: ${_aName(curA)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
          Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(mainAxisAlignment: curA, children: [
              _Box(color: Colors.red), _Box(color: Colors.green), _Box(color: Colors.blue),
            ]),
          ),
          Wrap(spacing: 8, children: List.generate(_aligns.length, (i) =>
            ChoiceChip(label: Text(_aName(_aligns[i]), style: const TextStyle(fontSize: 11)), selected: i == _rowIdx, onSelected: (_) => setState(() => _rowIdx = i)),
          )),
          const SizedBox(height: 12),
          // CrossAxisAlignment 交互演示
          Center(child: Text('CrossAxisAlignment: ${_cName(curC)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
          Container(
            width: double.infinity, height: 100,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(crossAxisAlignment: curC, children: [
              _Box(color: Colors.red, size: 40), _Box(color: Colors.green, size: 60), _Box(color: Colors.blue, size: 30),
            ]),
          ),
          Wrap(spacing: 8, children: List.generate(_crossAligns.length, (i) =>
            ChoiceChip(label: Text(_cName(_crossAligns[i]), style: const TextStyle(fontSize: 11)), selected: i == _crossIdx, onSelected: (_) => setState(() => _crossIdx = i)),
          )),
          const TipBox('记忆技巧：Row = 水平行，main=水平方向；Column = 垂直列，main=垂直方向。spaceBetween/spaceAround/spaceEvenly 的区别只在于间距的分配方式。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 5. Expanded vs Flexible
          // ════════════════════════════════════════════════
          const SectionHeader('5. Expanded vs Flexible —— 弹性空间分配', icon: Icons.space_bar),
          const Paragraph(
            'Expanded 和 Flexible 是 Flex 布局中控制子组件空间分配的关键组件。它们只能用在 Flex/Row/Column 内部。\n\n'
            'Expanded 的本质：Flexible(fit: FlexFit.tight)\n'
            '• tight 模式：强制子组件占满分配的空间，子组件自身的尺寸约束被忽略\n'
            '• 参数 flex 控制分配比例（类似 CSS 的 flex-grow）\n\n'
            'Flexible 的本质：Flexible(fit: FlexFit.loose)\n'
            '• loose 模式：子组件可以选择不占满分配的空间\n'
            '• 给子组件的约束中 maxWidth = 分配的空间，但子组件可以保持更小的尺寸\n\n'
            'flex 参数的工作原理：\n'
            '1. 先计算所有非弹性子组件的大小（固定的）\n'
            '2. 剩余空间按 flex 比例分配给 Expanded/Flexible\n'
            '3. flex: 2 拿到的空间正好是 flex: 1 的两倍',
          ),
          const CodeBlock(
            r'''// Expanded: 强制填满
Expanded(
  flex: 2,  // 占 2/(1+2+1) = 1/2 的剩余空间
  child: Container(color: Colors.red),
)

// Flexible: 可选填满
Flexible(
  flex: 2,
  fit: FlexFit.loose,  // 默认值
  child: Container(
    width: 50,  // 如果剩余空间 >50，只占50；否则填满剩余
    color: Colors.blue,
  ),
)

// Spacer：Expanded 的空占位版本
Spacer(flex: 1)  // 等价于 Expanded(flex: 1, child: SizedBox.shrink())''',
            language: 'Dart',
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ChoiceChip(label: const Text('Expanded (tight)'), selected: _flexFitIdx == 0, onSelected: (_) => setState(() => _flexFitIdx = 0)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Flexible (loose)'), selected: _flexFitIdx == 1, onSelected: (_) => setState(() => _flexFitIdx = 1)),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, height: 60,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: Colors.red.withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('1', style: TextStyle(color: Colors.white))))),
              _flexFitIdx == 0
                ? Expanded(flex: 2, child: Container(decoration: BoxDecoration(color: Colors.green.withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Expanded\n撑满', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)))))
                : Flexible(flex: 2, child: Container(width: 40, decoration: BoxDecoration(color: Colors.green.withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Flexible\n可收缩', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12))))),
              Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: Colors.blue.withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('1', style: TextStyle(color: Colors.white))))),
            ]),
          ),
          const Paragraph('观察绿色方块的差异：Expanded 强制它撑满 2/4 宽度；Flexible 允许它保持 40px 固有宽度。'),
          const TipBox('绝大多数情况用 Expanded。当你需要子组件保持自身尺寸（如 Text 不强制换行、Chip 不拉伸变形）时用 Flexible。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 6. Wrap
          // ════════════════════════════════════════════════
          const SectionHeader('6. Wrap —— 自动换行布局', icon: Icons.wrap_text),
          const Paragraph(
            'Wrap 是 Row 的升级版。当子组件超出可用宽度时，自动把多余的子组件放到下一行。\n\n'
            '关键属性：\n'
            '• direction —— 主轴方向（Axis.horizontal 或 vertical）\n'
            '• alignment —— 主轴（每行内）的对齐方式\n'
            '• runAlignment —— 交叉轴（行与行之间）的对齐方式\n'
            '• spacing —— 主轴方向子组件之间的间距\n'
            '• runSpacing —— 交叉轴方向行之间的间距\n'
            '• textDirection —— 文本方向（控制 start/end）\n\n'
            '与 Flow 的区别：\n'
            '• Wrap 简单易用，自动计算换行\n'
            '• Flow 需要手动用 delegate 计算位置，更灵活但代码更多\n'
            '• 90% 的场景用 Wrap 就够了',
          ),
          const CodeBlock(
            r'''Wrap(
  direction: Axis.horizontal,
  alignment: WrapAlignment.start,
  runAlignment: WrapAlignment.center,
  spacing: 8,        // 水平间距
  runSpacing: 4,      // 垂直间距
  children: tags.map((t) => Chip(label: Text(t))).toList(),
)''',
            language: 'Dart',
          ),
          // 交互演示
          const Text('Wrap 交互演示（调整间距和数量）', style: TextStyle(fontWeight: FontWeight.w600)),
          Row(children: [
            const Text('间距', style: TextStyle(fontSize: 12)),
            Expanded(child: Slider(value: _wrapSpacing, min: 0, max: 24, onChanged: (v) => setState(() => _wrapSpacing = v))),
            Text('${_wrapSpacing.toInt()}', style: const TextStyle(fontSize: 12)),
          ]),
          Row(children: [
            const Text('数量', style: TextStyle(fontSize: 12)),
            Expanded(child: Slider(value: _wrapItemCount.toDouble(), min: 2, max: 15, divisions: 13, onChanged: (v) => setState(() => _wrapItemCount = v.toInt()))),
            Text('$_wrapItemCount', style: const TextStyle(fontSize: 12)),
          ]),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Wrap(
              spacing: _wrapSpacing, runSpacing: _wrapSpacing,
              children: List.generate(_wrapItemCount, (i) => Chip(
                avatar: CircleAvatar(backgroundColor: Colors.primaries[i % Colors.primaries.length], radius: 8),
                label: Text('标签 $i', style: const TextStyle(fontSize: 11)),
              )),
            ),
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 7. Stack + Positioned
          // ════════════════════════════════════════════════
          const SectionHeader('7. Stack + Positioned —— 层叠布局', icon: Icons.layers),
          const Paragraph(
            'Stack 让子组件像"叠罗汉"一样堆叠在一起。后面的子组件覆盖前面的。\n\n'
            'Stack 布局规则：\n'
            '1. 没有 Positioned 包裹的子组件：默认对齐方式由 alignment 决定（默认 top-left）\n'
            '2. 有 Positioned 包裹的子组件：根据 top/left/right/bottom 精确定位\n'
            '3. Positioned.fill 填满整个 Stack 区域\n\n'
            'Stack 自身的尺寸：\n'
            '• 默认 fit: StackFit.loose —— 尺寸由最大的未定位子组件决定\n'
            '• StackFit.expand —— 尽可能放大填满父组件\n'
            '• StackFit.passthrough —— 直接传递父约束给子组件\n\n'
            'clipBehavior：\n'
            '• Clip.hardEdge —— 裁剪超出 Stack 范围的内容（性能好）\n'
            '• Clip.none —— 不裁剪，允许内容溢出（用于气泡、悬浮效果）',
          ),
          const CodeBlock(
            r'''// Stack 各参数说明
Stack(
  alignment: Alignment.center,  // 未定位子组件的默认对齐
  textDirection: TextDirection.ltr,  // start/end 的方向
  fit: StackFit.loose,          // Stack 自身的尺寸策略
  clipBehavior: Clip.hardEdge,  // 是否裁剪溢出
  children: [
    // 底层：填满 Stack
    Positioned.fill(child: Container(color: Colors.blue)),
    // 右上角：距顶部10，距右侧10
    Positioned(top: 10, right: 10, child: Badge()),
    // 底部横跨：left=0, right=0, bottom=0
    Positioned(left: 0, right: 0, bottom: 0, child: BottomBar()),
    // 未定位：默认放在 alignment 的位置
    Container(width: 50, height: 50, color: Colors.red),
  ],
)''',
            language: 'Dart',
          ),
          Row(children: [
            const Text('裁剪溢出 (Clip.hardEdge) '),
            Checkbox(value: _clipStack, onChanged: (v) => setState(() => _clipStack = v ?? false)),
          ]),
          Center(child: GestureDetector(
            onTap: () => setState(() => _showBadge = !_showBadge),
            child: Stack(
              clipBehavior: _clipStack ? Clip.hardEdge : Clip.none,
              children: [
                Container(width: 160, height: 160,
                  decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue[200]!)),
                  child: const Center(child: Text('底层', style: TextStyle(fontSize: 18, color: Colors.blue)))),
                if (_showBadge) Positioned(top: -8, right: -8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: const Text('角标', style: TextStyle(color: Colors.white, fontSize: 12)),
                )),
                const Positioned(bottom: 8, right: 8, child: Text('点击切换', style: TextStyle(fontSize: 12, color: Colors.grey))),
                Positioned(top: 0, left: 0, right: 0, child: Container(height: 24, color: Colors.black26,
                    child: const Center(child: Text('Positioned 横跨', style: TextStyle(color: Colors.white, fontSize: 10))))),
              ],
            ),
          )),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 8. 比例尺寸
          // ════════════════════════════════════════════════
          const SectionHeader('8. 比例尺寸：AspectRatio & FractionallySizedBox', icon: Icons.aspect_ratio),
          const Paragraph(
            'AspectRatio 强制子组件保持特定的宽高比，即使父组件给的约束更大。\n'
            '它总是 "挑最小的满足条件"：\n'
            '—— 如果父约束很宽，它按高度 * aspectRatio 取宽度（可能小于父给定的最大宽度）\n'
            '—— 如果父约束很高，它按宽度 / aspectRatio 取高度（可能小于父给定的最大高度）\n\n'
            'FractionallySizedBox 按父组件尺寸的百分比来确定自身尺寸。\n'
            '• widthFactor：宽度 = 父宽度 * widthFactor\n'
            '• heightFactor：高度 = 父高度 * heightFactor\n'
            '• 当为 null 时不约束该维度',
          ),
          const CodeBlock(
            r'''// 永远保持 16:9 比例
AspectRatio(
  aspectRatio: 16 / 9,  // 宽 / 高
  child: Container(color: Colors.amber),
)

// 占父组件宽度的 50%，高度的 80%
FractionallySizedBox(
  widthFactor: 0.5,
  heightFactor: 0.8,
  child: Container(color: Colors.teal),
)

// 宽度占50%，高度充满
FractionallySizedBox(
  widthFactor: 0.5,
  heightFactor: 1.0,
  child: ...
)''',
            language: 'Dart',
          ),
          const Text('AspectRatio 16:9', style: TextStyle(fontWeight: FontWeight.w600)),
          Container(
            width: double.infinity, height: 100,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Center(child: SizedBox(width: 160, child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('16:9', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ))),
          ),
          const SizedBox(height: 8),
          const Text('FractionallySizedBox', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(value: _fraction, min: 10, max: 100, divisions: 9, label: '${_fraction}%', onChanged: (v) => setState(() => _fraction = v.round().toDouble())),
          Container(
            width: double.infinity, height: 40,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              widthFactor: _fraction / 100, heightFactor: 1,
              child: Container(decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center,
                  child: Text('${_fraction.toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 9. 约束盒子
          // ════════════════════════════════════════════════
          const SectionHeader('9. 约束盒子全家桶', icon: Icons.crop_square),
          const Paragraph(
            'Flutter 提供了一组用于控制约束的组件：\n\n'
            '• SizedBox(width, height) —— 固定尺寸。如果没有 child，就是一个占位方块\n'
            '• ConstrainedBox(constraints) —— 给子组件施加额外约束，可以比父约束更严格但不能更宽松\n'
            '• UnconstrainedBox —— 解除父组件的约束，子组件可以使用自己的固有尺寸\n'
            '• LimitedBox(maxWidth, maxHeight) —— 只在无约束时生效（如 ListView 中的 Column 内部）\n'
            '• OverflowBox —— 允许子组件超出父组件的约束范围\n'
            '• FittedBox —— 将子组件缩放以适应父组件大小',
          ),
          const CodeBlock(
            r'''// SizedBox: 固定尺寸或占位
SizedBox(width: 100, height: 100, child: ...)   // 固定100x100
SizedBox(width: 100)                              // 固定宽100，高由子决定
SizedBox.expand(child: ...)                       // 尽可能放大
SizedBox.shrink()                                 // 大小为0的空盒子

// ConstrainedBox: 增加约束（不能比父约束更宽）
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
  child: Container(...),
)

// UnconstrainedBox: 解除约束
UnconstrainedBox(
  child: Container(width: 500, height: 300),  // 即使父约束不给500宽也能生效
)

// OverflowBox: 允许溢出
OverflowBox(
  maxWidth: 500,  // 子组件可以宽500，即使父只给300
  child: Container(width: 500, ...),
)''',
            language: 'Dart',
          ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ConstrainedBox (minWidth:100, maxWidth:200)'),
              const SizedBox(height: 4),
              ConstrainedBox(constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                child: Container(height: 40, color: Colors.purple.withOpacity(0.7),
                    child: const Center(child: Text('100~200px', style: TextStyle(color: Colors.white))))),
              const SizedBox(height: 8),
              const Text('LimitedBox (maxWidth:150，仅在无约束时生效)'),
              Column(children: [
                LimitedBox(maxWidth: 150, child: Container(height: 30, color: Colors.orange.withOpacity(0.7),
                    child: const Center(child: Text('Limited 150px', style: TextStyle(color: Colors.white, fontSize: 12))))),
              ]),
            ]),
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 10. Intrinsic
          // ════════════════════════════════════════════════
          const SectionHeader('10. Intrinsic —— 固有尺寸布局', icon: Icons.straighten),
          const Paragraph(
            'IntrinsicWidth 和 IntrinsicHeight 让父组件"看看子组件的固有尺寸再决定自己多大"。\n\n'
            '工作原理：\n'
            '1. Flutter 先做一次"虚拟布局"来计算所有子组件的固有尺寸\n'
            '2. 然后用最大的那个作为参考来设置父组件的大小\n'
            '3. 最后再做一次真正的布局\n\n'
            '性能代价：布局被计算了两次！因此只在必要时使用，避免在频繁重建的列表中使用。\n\n'
            '常见场景：\n'
            '• Row 内所有子项等高（IntrinsicHeight + crossAxisAlignment.stretch）\n'
            '• Column 宽度等于最宽子项\n'
            '• 卡片网格中所有行等高',
          ),
          const CodeBlock(
            r'''// Row 内子项等高（配合 CrossAxisAlignment.stretch）
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(height: 100, ...),  // 最高 → 决定整行
      Container(height: 50, ...),   // 被拉伸到100
      Container(height: 80, ...),   // 被拉伸到100
    ],
  ),
)

// Column 宽度等于最宽子项
IntrinsicWidth(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('短'),                    // 宽度小
      Text('这段文字很长很长'),      // 最宽 → 决定整列
    ],
  ),
)''',
            language: 'Dart',
          ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 60, color: Colors.red[200], padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Center(child: Text('高\n100', textAlign: TextAlign.center))),
              const SizedBox(width: 8),
              Container(width: 60, color: Colors.green[200], padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Center(child: Text('50'))),
              const SizedBox(width: 8),
              Expanded(child: Container(color: Colors.blue[200], padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Center(child: Text('自动拉伸到最高', style: TextStyle(fontSize: 12))))),
            ])),
          ),
          const TipBox('如果你发现自己在疯狂调试 Row 里对齐不一致的问题，可能只需要一个 IntrinsicHeight。但别在长列表里用。', type: TipType.warning),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 11. MediaQuery
          // ════════════════════════════════════════════════
          const SectionHeader('11. MediaQuery —— 设备与屏幕信息', icon: Icons.screen_rotation),
          const Paragraph(
            'MediaQuery 提供设备级别的信息：屏幕尺寸、方向、文字缩放比例、亮度模式、安全区域等。\n\n'
            'Material Design 断点参考：\n'
            '• < 600px —— 手机（紧凑布局）\n'
            '• 600-840px —— 平板竖屏\n'
            '• 840-1200px —— 平板横屏\n'
            '• > 1200px —— 桌面/大屏\n\n'
            'MediaQuery.of(context) 的完整属性：\n'
            '• size —— 逻辑像素尺寸\n'
            '• devicePixelRatio —— 设备像素比（物理像素/逻辑像素）\n'
            '• textScaleFactor —— 系统字体缩放\n'
            '• platformBrightness —— 平台亮度模式\n'
            '• padding —— 系统 UI 安全区（状态栏、底部手势条等）\n'
            '• viewInsets —— 键盘等系统 UI 占据的空间\n'
            '• orientation —— 设备方向\n'
            '• highContrast / alwaysUse24HourFormat 等无障碍属性',
          ),
          const CodeBlock(
            r'''final media = MediaQuery.of(context);
final width = media.size.width;
final height = media.size.height;
final pixelRatio = media.devicePixelRatio;  // 1x, 2x, 3x
final isLandscape = media.orientation == Orientation.landscape;
final safeTop = media.padding.top;   // 状态栏高度
final safeBottom = media.padding.bottom;  // 底部手势条

// ⚠️ 重要：MediaQuery.of(context) 必须在 MaterialApp 的 context 下使用
// 否则可能找不到或获取不准确的值''',
            language: 'Dart',
          ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('当前设备信息:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('屏幕: ${screenWidth.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}'),
              Text('像素比: ${MediaQuery.of(context).devicePixelRatio}x'),
              Text('方向: ${MediaQuery.of(context).orientation == Orientation.landscape ? "横屏" : "竖屏"}'),
              Text('文字缩放: ${MediaQuery.of(context).textScaleFactor.toStringAsFixed(2)}x'),
              Text('亮度: ${MediaQuery.of(context).platformBrightness == Brightness.dark ? "深色" : "浅色"}'),
              Text('底部安全区: ${MediaQuery.of(context).padding.bottom.toStringAsFixed(0)}px'),
            ]),
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 12. LayoutBuilder vs MediaQuery
          // ════════════════════════════════════════════════
          const SectionHeader('12. LayoutBuilder vs MediaQuery —— 如何选择？', icon: Icons.compare_arrows),
          const Paragraph(
            '两者都是响应式布局的工具，但关注点不同：\n\n'
            'MediaQuery：关注"设备/屏幕"层面\n'
            '• 获取屏幕物理尺寸\n'
            '• 设备方向、安全区\n'
            '• 适合：全局布局决策（手机用 BottomNav、平板用 SideNav）\n\n'
            'LayoutBuilder：关注"父组件约束"层面\n'
            '• 获取父组件给了多少空间\n'
            '• 组件内部的响应式（不关心屏幕，只关心父亲给了多少）\n'
            '• 适合：组件内部自适应\n\n'
            '选择指南：\n'
            '• 全局页面级决策 → MediaQuery\n'
            '• 组件内部自适应 → LayoutBuilder\n'
            '• 两者可组合使用（MediaQuery 断点 + LayoutBuilder 内部微调）',
          ),
          const CodeBlock(
            r'''// 组合使用 MediaQuery + LayoutBuilder
class ResponsiveBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 屏幕级决策
    if (screenWidth > 600) return _WideLayout();

    // 组件内部级决策
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) return _CompactWide();
        return _CompactNarrow();
      },
    );
  }
}''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 13. 综合演示
          // ════════════════════════════════════════════════
          const SectionHeader('13. 响应式布局综合演示', icon: Icons.devices),
          const Paragraph('下方区域根据可用宽度自动切换布局模式。调整窗口宽度观察效果。'),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Container(
                height: 200,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: w > 500
                  ? Row(children: [
                      Container(width: 100, decoration: BoxDecoration(color: Colors.blue[50],
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.home, color: Colors.blue), Text('首页', style: TextStyle(fontSize: 12)), SizedBox(height: 12),
                            Icon(Icons.search, color: Colors.blue), Text('搜索', style: TextStyle(fontSize: 12)),
                          ])),
                      const Expanded(child: Center(child: Text('宽屏: 侧边栏 + 内容区', style: TextStyle(fontSize: 16)))),
                    ])
                  : Column(children: [
                      const Expanded(child: Center(child: Text('窄屏: 内容区', style: TextStyle(fontSize: 16)))),
                      Container(height: 40, decoration: BoxDecoration(color: Colors.blue[50],
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            Icon(Icons.home, color: Colors.blue, size: 20), Icon(Icons.search, color: Colors.blue, size: 20),
                            Icon(Icons.settings, color: Colors.blue, size: 20), Icon(Icons.person, color: Colors.blue, size: 20),
                          ])),
                    ]),
              );
            },
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 14. 布局调试
          // ════════════════════════════════════════════════
          const SectionHeader('14. 布局调试技巧', icon: Icons.bug_report),
          const Paragraph(
            '布局不正确时的排查步骤：\n'
            '1. Flutter Inspector → 选中异常的 Widget → 查看 Constraints\n'
            '2. 确认父组件给的约束是什么（看 maxWidth/maxHeight）\n'
            '3. 检查是否有 Expanded/Flexible 在不正确的位置\n'
            '4. 用 debugPaintSizeEnabled=true 显示辅助线\n'
            '5. 临时给子组件加上不同背景色观察实际尺寸\n'
            '6. 临时用 Container 替换问题组件观察约束传递',
          ),
          const CodeBlock(
            r'''// 调试用工具代码
import 'package:flutter/rendering.dart';

// 1. 显示所有组件的边界和约束
debugPaintSizeEnabled = true;

// 2. 显示基线
debugPaintBaselinesEnabled = true;

// 3. 显示 layer 信息
debugPaintLayerBordersEnabled = true;

// 4. 在代码中打印约束
LayoutBuilder(
  builder: (context, constraints) {
    debugPrint('当前约束: $constraints');
    return ...;
  },
)''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 15. 总结
          // ════════════════════════════════════════════════
          const SectionHeader('15. 总结与核心公式', icon: Icons.summarize),
          const Paragraph(
            'Flutter 布局三大公式（背下来）：\n\n'
            '1. Constraints go DOWN, Sizes go UP\n'
            '   父给约束，子报尺寸\n\n'
            '2. 父决定子组件的位置\n'
            '   子不能自己决定自己在父中的位置（除非用 Align/Positioned）\n\n'
            '3. 子不能突破父的约束\n'
            '   约束是硬性限制，不能被无视（除非用 UnconstrainedBox/OverflowBox）\n\n'
            '快速选择布局组件：\n'
            '• 横向排列 → Row\n'
            '• 纵向排列 → Column\n'
            '• 需要弹性分配 → Expanded/Flexible\n'
            '• 需要自动换行 → Wrap\n'
            '• 需要层叠 → Stack\n'
            '• 需要固定比例 → AspectRatio\n'
            '• 需要百分比 → FractionallySizedBox\n'
            '• 需要响应式 → LayoutBuilder',
          ),

          // ===== 交互式演示 =====
          const _ContainerDecorationDemo(),
          const _PaddingMarginDemo(),
          const DividerLine(),

          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 Stack+Positioned 实现"圆形头像+右下角在线绿点"\n'
            '2. 用 Expanded(flex) 实现左:中:右=1:2:1 布局\n'
            '3. 用 LayoutBuilder 实现宽度<400 时 Column、>=400 时 Row 的响应式卡片\n'
            '4. 用 AspectRatio 实现正方形头像网格\n'
            '5. 用 FractionallySizedBox 实现进度条效果\n'
            '6. 用 IntrinsicHeight 实现等高卡片 Row\n'
            '7. 用 Wrap 实现可自适应换行的标签列表\n'
            '8. 实现一个"顶部导航 → 侧边导航"的响应式切换（用 LayoutBuilder + MediaQuery）',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// Container 装饰属性演示
class _ContainerDecorationDemo extends StatefulWidget {
  const _ContainerDecorationDemo();
  @override
  State<_ContainerDecorationDemo> createState() => _ContainerDecorationDemoState();
}

class _ContainerDecorationDemoState extends State<_ContainerDecorationDemo> {
  double _radius = 12;
  double _blur = 8;
  double _spreadRadius = 0;
  bool _hasBorder = false;
  bool _useGradient = false;
  int _colorIdx = 0;

  static const _colors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink];
  static const _colorNames = ['蓝色', '紫色', '青色', '橙色', '粉色'];

  Color get _baseColor => _colors[_colorIdx];

  String get _codeStr {
    final colorLine = _useGradient
        ? 'gradient: LinearGradient(\n      colors: [color.withOpacity(0.9),\n               color.withOpacity(0.3)],\n    ),'
        : 'color: ${_colorNames[_colorIdx]}.withOpacity(0.7),';
    final borderLine = _hasBorder ? '    border: Border.all(color: color, width: 2),\n' : '';
    final shadowLine = _blur > 0
        ? '    boxShadow: [BoxShadow(\n      blurRadius: ${_blur.toInt()},\n      spreadRadius: ${_spreadRadius.toInt()},\n    )],\n'
        : '';
    return 'Container(\n'
        '  width: 140, height: 90,\n'
        '  decoration: BoxDecoration(\n'
        '    $colorLine\n'
        '    borderRadius: BorderRadius.circular(${_radius.toInt()}),\n'
        '$borderLine$shadowLine'
        '  ),\n'
        ')';
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _useGradient ? null : _baseColor.withOpacity(0.7),
      gradient: _useGradient ? LinearGradient(
        colors: [_baseColor.withOpacity(0.9), _baseColor.withOpacity(0.3)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ) : null,
      borderRadius: BorderRadius.circular(_radius),
      border: _hasBorder ? Border.all(color: _baseColor, width: 2) : null,
      boxShadow: _blur > 0 ? [
        BoxShadow(
          color: _baseColor.withOpacity(0.4),
          blurRadius: _blur,
          spreadRadius: _spreadRadius,
          offset: const Offset(2, 4),
        )
      ] : null,
    );

    return InteractivePlayground(
      title: '📦 Container Decoration 演示',
      subtitle: '调整参数，实时预览 BoxDecoration 效果',
      children: [
        ParamChoiceChips<int>(
          label: '颜色',
          value: _colorIdx,
          options: List.generate(_colors.length, (i) => (i, _colorNames[i])),
          onChanged: (v) => setState(() => _colorIdx = v),
        ),
        ParamSlider(label: '圆角 borderRadius', value: _radius, min: 0, max: 50, divisions: 50,
          onChanged: (v) => setState(() => _radius = v), displayValue: (v) => '${v.toInt()}'),
        ParamSlider(label: '阴影模糊 blurRadius', value: _blur, min: 0, max: 30, divisions: 30,
          onChanged: (v) => setState(() => _blur = v), displayValue: (v) => '${v.toInt()}'),
        ParamSlider(label: '阴影扩散 spreadRadius', value: _spreadRadius, min: 0, max: 10, divisions: 10,
          onChanged: (v) => setState(() => _spreadRadius = v), displayValue: (v) => '${v.toInt()}'),
        ParamSwitch(label: '渐变色 gradient', value: _useGradient, onChanged: (v) => setState(() => _useGradient = v),
          trueLabel: '渐变', falseLabel: '纯色'),
        ParamSwitch(label: '边框 border', value: _hasBorder, onChanged: (v) => setState(() => _hasBorder = v),
          trueLabel: '显示', falseLabel: '隐藏'),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 140, height: 90,
            decoration: decoration,
            child: const Center(child: Text('Container', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_codeStr),
      ],
    );
  }
}

/// Padding vs Margin 对比演示
class _PaddingMarginDemo extends StatefulWidget {
  const _PaddingMarginDemo();
  @override
  State<_PaddingMarginDemo> createState() => _PaddingMarginDemoState();
}

class _PaddingMarginDemoState extends State<_PaddingMarginDemo> {
  double _padding = 16;
  double _margin = 12;
  bool _showAnnotation = true;

  @override
  Widget build(BuildContext context) {
    final p = _padding.toInt();
    final m = _margin.toInt();

    return InteractivePlayground(
      title: '📐 Padding vs Margin 对比演示',
      subtitle: '拖动滑块观察 padding（内间距）与 margin（外间距）的视觉差异',
      children: [
        ParamIntSlider(label: 'padding（内间距）', value: p, min: 0, max: 40,
          onChanged: (v) => setState(() => _padding = v.toDouble()), unit: 'px'),
        ParamIntSlider(label: 'margin（外间距）', value: m, min: 0, max: 40,
          onChanged: (v) => setState(() => _margin = v.toDouble()), unit: 'px'),
        ParamSwitch(label: '显示标注', value: _showAnnotation, onChanged: (v) => setState(() => _showAnnotation = v),
          trueLabel: '开', falseLabel: '关'),
        const SizedBox(height: 8),
        // 可视化区域：从外到内：灰色背景→margin空间→蓝色容器→padding空间→内容
        Container(
          width: double.infinity,
          color: Colors.orange[50], // 最外层：margin 所在区域
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.all(_margin),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[400]!, width: 2),
            ),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_padding),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[500],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text('内容 (Content)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 图例
        if (_showAnnotation)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LegendItem(color: Colors.orange[100]!, label: 'margin: ${m}px（外间距）'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.blue[100]!, label: 'padding: ${p}px（内间距）'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.blue[500]!, label: '内容区'),
          ]),
        LiveCodeBlock(
          'Container(\n'
          '  margin: EdgeInsets.all($m),    // 外间距\n'
          '  decoration: BoxDecoration(\n'
          '    color: Colors.blue[100],\n'
          '  ),\n'
          '  padding: EdgeInsets.all($p),   // 内间距\n'
          '  child: Text("内容"),\n'
          ')',
        ),
        LiveOutputBox(
          'margin=$m: 容器与外部邻居的距离\n'
          'padding=$p: 容器边框与内部内容的距离\n'
          '总占用宽度 ≈ 内容 + ${p * 2}(padding×2) + ${m * 2}(margin×2)',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}

class _Box extends StatelessWidget {
  final Color color;
  final double size;
  const _Box({required this.color, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(
    width: size > 0 ? size : null, height: size > 0 ? size : null,
    decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
  );
}

class _SmallBox extends StatelessWidget {
  final Color color;
  const _SmallBox({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 60, height: 30,
    decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
  );
}
