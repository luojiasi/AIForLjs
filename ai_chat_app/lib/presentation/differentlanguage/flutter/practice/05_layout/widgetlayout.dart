import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第五章：布局 Widget 大全 (Layout)
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
  int _flexFitIdx = 0; // 0=Expanded, 1=Flexible.loose
  double _fraction = 50; // 50%

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
    _ => '',
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
      appBar: AppBar(title: const Text('第5章 · 布局 Widget 大全'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph('① LayoutBuilder ② Flex(Row/Column/Flex) ③ Expanded vs Flexible ④ Stack+Positioned ⑤ AspectRatio/FractionallySizedBox ⑥ ConstrainedBox/SizedBox/LimitedBox ⑦ IntrinsicWidth/IntrinsicHeight ⑧ MediaQuery ⑨ LayoutBuilder vs MediaQuery ⑩ 响应式布局实战'),
          const DividerLine(),

          // ── 1. LayoutBuilder ──
          const SectionHeader('1. LayoutBuilder —— 响应式构建', icon: Icons.build),
          const Paragraph('LayoutBuilder 在构建时获取父组件给你的 BoxConstraints（minWidth、maxWidth、minHeight、maxHeight），从而根据可用空间动态调整布局。只会在父约束变化时重新构建。'),
          const CodeBlock(
            r'''LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 400) {
      return _buildCompactLayout();
    } else {
      return _buildWideLayout();
    }
  },
)''',
            language: 'Dart',
          ),
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
                    Text(w > 350 ? '宽屏模式 (>350px) -> Row' : '窄屏模式 (<=350px) -> Column',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ]),
                );
              },
            );
          }),
          const TipBox('LayoutBuilder 拿到的约束是「父组件的约束」，不是屏幕尺寸！嵌套在 SizedBox 里就只能拿到 SizedBox 的范围。', type: TipType.info),
          const DividerLine(),

          // ── 2. Flex 家族 ──
          const SectionHeader('2. Flex 家族 —— Row, Column, Flex', icon: Icons.linear_scale),
          const Paragraph('Row 和 Column 本质上都是 Flex 的特例。Flex 通过 direction 可以指定任意方向。\nMainAxisAlignment 控制主轴对齐，CrossAxisAlignment 控制交叉轴。Row 的主轴=水平/交叉轴=垂直；Column 相反。'),
          const CodeBlock(
            r'''// 三者等价关系
Row(children: [...]) == Flex(direction: Axis.horizontal, ...)
Column(children: [...]) == Flex(direction: Axis.vertical, ...)

// MainAxisAlignment: start center end spaceBetween spaceAround spaceEvenly
// CrossAxisAlignment: start center end stretch''',
            language: 'Dart',
          ),
          // MainAxisAlignment 交互
          Center(child: Text('MainAxisAlignment: ${_aName(curA)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
          Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(mainAxisAlignment: curA, children: [
              _Box(color: Colors.red), _Box(color: Colors.green), _Box(color: Colors.blue),
            ]),
          ),
          Wrap(spacing: 8, children: List.generate(_aligns.length, (i) =>
            ChoiceChip(label: Text(_aName(_aligns[i])), selected: i == _rowIdx, onSelected: (_) => setState(() => _rowIdx = i)),
          )),
          const SizedBox(height: 12),
          // CrossAxisAlignment 交互
          Center(child: Text('CrossAxisAlignment: ${_cName(curC)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
          Container(
            width: double.infinity, height: 100,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(crossAxisAlignment: curC, children: [
              _Box(color: Colors.red, size: 40), _Box(color: Colors.green, size: 60), _Box(color: Colors.blue, size: 30),
            ]),
          ),
          Wrap(spacing: 8, children: List.generate(_crossAligns.length, (i) =>
            ChoiceChip(label: Text(_cName(_crossAligns[i])), selected: i == _crossIdx, onSelected: (_) => setState(() => _crossIdx = i)),
          )),
          const TipBox('快速记忆：Row = 行 = 横排，Main=水平；Column = 列 = 竖排，Main=垂直。', type: TipType.tip),
          const DividerLine(),

          // ── 3. Expanded vs Flexible ──
          const SectionHeader('3. Expanded vs Flexible —— 弹性布局', icon: Icons.space_bar),
          const Paragraph('Expanded 是 Flexible(fit: FlexFit.tight) 的语法糖 —— 强制子组件填满剩余空间。\nFlexible 默认 fit: FlexFit.loose，允许子组件保持自身尺寸不强制填满。flex 参数分配比例（类似 Android weight）。'),
          const CodeBlock(
            r'''Expanded(flex: 2, child: ...)  // 强制填满 (FlexFit.tight)
Flexible(flex: 2, child: ...)  // 可选填满 (FlexFit.loose)
// 核心区别：Expanded 强制子组件撑满分配宽度
// Flexible 的子组件可以保持比分配值小的尺寸''',
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
                ? Expanded(flex: 2, child: Container(decoration: BoxDecoration(color: Colors.green.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Text('Expanded\n撑满', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)))))
                : Flexible(flex: 2, child: Container(width: 40,
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Text('Flexible\n可收缩', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12))))),
              Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: Colors.blue.withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('1', style: TextStyle(color: Colors.white))))),
            ]),
          ),
          const Paragraph('Expanded 强制绿色方块撑满 2/4 宽度；Flexible 允许它保持 40px 固有宽度。'),
          const TipBox('大多数情况用 Expanded。子组件需要保持固有尺寸（如文本不强制换行）时，用 Flexible。', type: TipType.tip),
          const DividerLine(),

          // ── 4. Stack + Positioned ──
          const SectionHeader('4. Stack + Positioned —— 层叠布局', icon: Icons.layers),
          const Paragraph('Stack 将子组件叠放。Positioned 相对 Stack 四边定位。Positioned.fill 填满整个 Stack。clipBehavior 控制是否裁剪超出部分。'),
          const CodeBlock(
            r'''Stack(
  clipBehavior: Clip.hardEdge,
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    Positioned(top: 10, right: 10, child: Badge(...)),
    Positioned.fill(child: Center(child: Text('填满'))),
  ],
)''',
            language: 'Dart',
          ),
          Row(children: [
            const Text('裁剪溢出 (clip) '),
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
                    child: const Center(child: Text('Positioned.fill 横跨', style: TextStyle(color: Colors.white, fontSize: 10))))),
              ],
            ),
          )),
          const Paragraph('Clip.none 让角标溢出容器（适合气泡效果）；Clip.hardEdge 裁剪超出部分。Positioned.fill 配合 left/right/top/bottom 填满 Stack。'),
          const DividerLine(),

          // ── 5. 比例尺寸 ──
          const SectionHeader('5. 比例尺寸组件 —— AspectRatio & FractionallySizedBox', icon: Icons.aspect_ratio),
          const Paragraph('AspectRatio 强制子组件保持宽高比。FractionallySizedBox 按父容器比例设尺寸。'),
          const CodeBlock(
            r'''AspectRatio(aspectRatio: 16/9, child: ...)          // 16:9
FractionallySizedBox(widthFactor: 0.5, child: ...)   // 50%''',
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
          const Text('FractionallySizedBox 比例', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(value: _fraction.toDouble(), min: 10, max: 100, divisions: 9,
              label: '${_fraction}%', onChanged: (v) => setState(() => _fraction = v.round().toDouble())),
          Container(
            width: double.infinity, height: 40,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              widthFactor: _fraction / 100, heightFactor: 1,
              child: Container(decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center,
                  child: Text('${_fraction}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
          const TipBox('aspectRatio = 宽/高，16:9 就是 16/9。FractionallySizedBox 非常适合进度条。', type: TipType.tip),
          const DividerLine(),

          // ── 6. 约束盒子 ──
          const SectionHeader('6. 约束盒子 —— ConstrainedBox, SizedBox, LimitedBox', icon: Icons.crop_square),
          const Paragraph('布局核心口诀：「约束往下传，大小往上报」。\nSizedBox 固定宽高；ConstrainedBox 始终生效的 min/max 约束；LimitedBox 只在无约束时生效。'),
          const CodeBlock(
            r'''SizedBox(width: 100, height: 100, child: ...)                      // 固定尺寸
ConstrainedBox(constraints: BoxConstraints(minWidth:100, maxWidth:300), child: ...)  // 始终生效
LimitedBox(maxWidth: 200, child: ...)                                // 无约束时才生效''',
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
              const Text('LimitedBox (maxWidth:150，Column 内无约束时生效)'),
              Column(children: [
                LimitedBox(maxWidth: 150, child: Container(height: 30, color: Colors.orange.withOpacity(0.7),
                    child: const Center(child: Text('Limited 150px', style: TextStyle(color: Colors.white, fontSize: 12))))),
              ]),
            ]),
          ),
          const DividerLine(),

          // ── 7. 固有尺寸 ──
          const SectionHeader('7. 固有尺寸 —— IntrinsicWidth & IntrinsicHeight', icon: Icons.straighten),
          const Paragraph('IntrinsicWidth/IntrinsicHeight 让父组件根据子组件的「固有尺寸」确定自身大小。\n常见场景：Row 里所有子项等高，或 Column 宽度等于最宽子项。注意：会触发额外布局计算，性能开销较大。'),
          const CodeBlock(
            r'''// 等高：Row 里所有子项高度一致
IntrinsicHeight(
  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(height: 100),  // 最高 -> 决定整行高度
    Container(height: 50),   // 被拉伸到 100
  ]),
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
                  child: const Center(child: Text('拉伸到最高', style: TextStyle(fontSize: 12))))),
            ])),
          ),
          const TipBox('IntrinsicHeight 让 Row 内所有子项等高，适合卡片布局。但避免在频繁重建的列表中使用。', type: TipType.warning),
          const DividerLine(),

          // ── 8. MediaQuery ──
          const SectionHeader('8. MediaQuery —— 响应式断点', icon: Icons.screen_rotation),
          const Paragraph('MediaQuery 获取屏幕尺寸、方向、文字缩放等信息。Material Design 推荐断点：600px(手机/平板竖屏) 840px(平板横屏) 1200px(桌面)。'),
          const CodeBlock(
            r'''final size = MediaQuery.of(context).size;
final width = size.width;  final height = size.height;
// 断点: <600 手机 | 600~840 平板竖屏 | 840~1200 平板横屏 | >1200 桌面
final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
final padding = MediaQuery.of(context).padding;  // 安全区''',
            language: 'Dart',
          ),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('当前设备信息:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('屏幕: ${screenWidth.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}'),
              Text('方向: ${MediaQuery.of(context).orientation == Orientation.landscape ? "横屏" : "竖屏"}'),
              Text('文字缩放: ${MediaQuery.of(context).textScaleFactor.toStringAsFixed(2)}x'),
              Text('亮度: ${MediaQuery.of(context).platformBrightness == Brightness.dark ? "深色" : "浅色"}'),
              Text('底部安全区: ${MediaQuery.of(context).padding.bottom.toStringAsFixed(0)}px'),
            ]),
          ),
          const DividerLine(),

          // ── 9. LayoutBuilder vs MediaQuery ──
          const SectionHeader('9. LayoutBuilder vs MediaQuery', icon: Icons.compare_arrows),
          const Paragraph('两者都是做响应式的常用工具，但适用场景不同：'),
          const CodeBlock(
            r'''// MediaQuery —— 获取屏幕信息（全局）
final w = MediaQuery.of(context).size.width;
// 适合：全局布局决策（NavigationRail vs BottomBar）
// 局限：不知道父组件的约束

// LayoutBuilder —— 获取父约束（组件级）
LayoutBuilder(builder: (_, constraints) { final w = constraints.maxWidth; ... });
// 适合：组件内部自适应（卡片横排/竖排）
// 局限：不知道设备方向、安全区''',
            language: 'Dart',
          ),
          const Paragraph('选择指南：整个页面布局用 MediaQuery，组件内部自适应用 LayoutBuilder。两者可结合使用。'),
          const TipBox('经验法则：想知道「屏幕多大」用 MediaQuery；想知道「我爸留了多少空间」用 LayoutBuilder。', type: TipType.tip),
          const DividerLine(),

          // ── 10. 响应式布局综合演示 ──
          const SectionHeader('10. 响应式布局综合演示', icon: Icons.devices),
          const Paragraph('下方区域根据可用宽度自动切换布局模式（尝试调整窗口宽度）：'),
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
          const Paragraph('宽屏(>500px)显示侧边导航 + 内容区；窄屏显示底部导航。这是常见 App 的响应式策略。'),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph('1. 用 Stack+Positioned 实现「圆形头像+在线绿点」\n'
              '2. 用 Expanded+flex 实现左:中:右=1:2:1 布局\n'
              '3. 用 LayoutBuilder 实现宽度<400 时 Column、>=400 时 Row 的响应式卡片\n'
              '4. 用 AspectRatio 实现正方形头像\n'
              '5. 用 FractionallySizedBox 实现进度条动画\n'
              '6. 用 IntrinsicHeight 实现等高卡片 Row'),
          const TipBox('布局前先画草图。善用 Flutter Inspector 的 Layout Explorer 调试约束！', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
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
