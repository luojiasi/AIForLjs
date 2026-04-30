import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

class FlutterWidgetBasics extends StatefulWidget {
  const FlutterWidgetBasics({super.key});

  @override
  State<FlutterWidgetBasics> createState() => _FlutterWidgetBasicsState();
}

class _FlutterWidgetBasicsState extends State<FlutterWidgetBasics> {
  int _count = 0;
  int _selectedAlignment = 0;
  bool _showStackOverlay = true;

  static const List<MainAxisAlignment> _alignments = [
    MainAxisAlignment.start,
    MainAxisAlignment.center,
    MainAxisAlignment.end,
    MainAxisAlignment.spaceAround,
    MainAxisAlignment.spaceBetween,
    MainAxisAlignment.spaceEvenly,
  ];

  static const List<String> _alignmentNames = [
    'start',
    'center',
    'end',
    'spaceAround',
    'spaceBetween',
    'spaceEvenly',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter · Widget 基础'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========== 目录概览 ==========
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '0   StatelessWidget vs StatefulWidget\n'
            '1   Text — 文字进阶\n'
            '2   Image — 图片\n'
            '3   Icon — 图标\n'
            '4   Button — 按钮\n'
            '5   Container — 容器进阶\n'
            '6   Row & Column — 线性布局\n'
            '7   Stack & Positioned — 层叠布局\n'
            '8   Expanded vs Flexible — 弹性布局\n'
            '9   SizedBox vs Container — 尺寸控制\n'
            '10  Padding & EdgeInsets — 间距详解\n'
            '11  DecoratedBox — 装饰组件\n'
            '12  GestureDetector & InkWell — 手势\n'
            '13  MediaQuery & SafeArea — 屏幕适配\n'
            '14  ListView & ListView.builder — 列表\n'
            '15  GridView — 网格布局',
          ),
          const TipBox(
            'Widget 是 Flutter 的一切！Flutter 的核心理念就是「万物皆 Widget」。'
            '本章将系统性地讲解 Flutter 中最常用、最重要的 Widget 及其进阶用法。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ========== 0. StatelessWidget vs StatefulWidget ==========
          const SectionHeader('0. StatelessWidget vs StatefulWidget', icon: Icons.compare_arrows),
          const Paragraph(
            'Flutter 的 Widget 分为两种类型：StatelessWidget（无状态组件）和 '
            'StatefulWidget（有状态组件）。理解它们的区别是 Flutter 开发的第一步。',
          ),
          const Paragraph(
            'StatelessWidget：组件创建后不可改变，属性全部通过构造函数传入，'
            'build 方法只调用一次。适合显示固定内容的场景，如静态文本、图标、固定的布局结构。',
          ),
          const Paragraph(
            'StatefulWidget：组件可以随时间变化，通过 setState() 方法触发 UI 重建。'
            '适合需要用户交互、计时器、网络请求更新 UI 等动态场景。',
          ),
          const CodeBlock(
            r'''
// ---- StatelessWidget ----
// 创建后不会改变，没有可变状态
class MyTitle extends StatelessWidget {
  const MyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('我不会自动改变');
  }
}

// ---- StatefulWidget ----
// 可以随时间变化，通过 setState 更新 UI
class MyCounter extends StatefulWidget {
  const MyCounter({super.key});

  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int count = 0;  // 可变状态

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('计数: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('加一'),
        ),
      ],
    );
  }
}
''',
            language: 'Dart',
          ),
          const TipBox(
            'StatelessWidget 适合纯展示；StatefulWidget 适合有交互、计时器、'
            '动画等动态场景。能用 StatelessWidget 就尽量用，减少不必要的 StatefulWidget。',
            type: TipType.tip,
          ),
          const TipBox(
            '一个常见的误解：StatelessWidget 不会重建，StatefulWidget 会重建。'
            '实际上，两者都可能重建，关键在于 StatefulWidget 可以通过 setState() '
            '主动触发重建。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ========== 1. Text（进阶） ==========
          const SectionHeader('1. Text — 文字组件（进阶）', icon: Icons.text_fields),
          const Paragraph(
            'Text 是最常用的组件。除了显示文字外，Flutter 的 Text 组件还提供了丰富的样式控制、'
            '溢出处理、对齐方式和富文本功能。',
          ),

          // 1.1 TextStyle
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'TextStyle — 文字样式',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const CodeBlock(
            r'''
Text(
  '带样式的文字',
  style: TextStyle(
    fontSize: 20,                     // 字号
    fontWeight: FontWeight.bold,       // 字重
    fontStyle: FontStyle.italic,       // 斜体
    color: Colors.blue,               // 颜色
    letterSpacing: 2,                 // 字间距
    wordSpacing: 4,                   // 词间距
    height: 1.5,                      // 行高（字体大小的倍数）
    decoration: TextDecoration.lineThrough,   // 删除线
    decorationColor: Colors.red,
    decorationStyle: TextDecorationStyle.wavy,
    shadows: [                        // 文字阴影
      Shadow(
        color: Colors.grey,
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ],
  ),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          const Text(
            'Hello Flutter — 样式丰富的文字，蓝色加粗 20 号',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: 2,
            ),
          ),

          // 1.2 overflow & maxLines
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              'overflow / maxLines — 溢出处理',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const Paragraph(
            '当文字内容超出可用宽度时，可以通过 overflow 控制显示方式，'
            '配合 maxLines 限制最大行数。',
          ),
          const CodeBlock(
            r'''
Text(
  '一段很长的文字，可能会超出容器的宽度范围，需要做溢出处理。',
  maxLines: 2,                         // 最多2行
  overflow: TextOverflow.ellipsis,     // 超出显示 '...'
  softWrap: true,                      // 允许换行（默认 true）
)
// TextOverflow 枚举值：
//   clip      — 直接裁剪
//   ellipsis  — 显示省略号
//   fade      — 渐隐效果
//   visible   — 强制显示（可能溢出）
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '这是一段很长的文字，用来演示 overflow 溢出处理的效果。'
              '如果不限制 maxLines 和 overflow，它会不断延伸并导致溢出警告。',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 1.3 textAlign
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              'textAlign — 对齐方式',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const CodeBlock(
            r'''
Text(
  '居中文字',
  textAlign: TextAlign.center,
)
// TextAlign 枚举值：
//   left    — 左对齐
//   right   — 右对齐
//   center  — 居中
//   justify — 两端对齐
//   start   — 起始对齐（依赖语言方向）
//   end     — 末尾对齐（依赖语言方向）
''',
            language: 'Dart',
          ),

          // 1.4 Text.rich
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              'Text.rich + TextSpan — 富文本',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const Paragraph(
            'Text.rich 允许在一段文字中混搭多种样式，适合实现关键词高亮、行内链接等效果。',
          ),
          const CodeBlock(
            r'''
Text.rich(
  TextSpan(
    text: '普通文字 ',
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(
        text: '红色加粗',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      TextSpan(
        text: ' 蓝色可点击',
        style: TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () => print('点击了'),
      ),
    ],
  ),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: '普通文字 ',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              children: const [
                TextSpan(
                  text: '红色加粗',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: ' 蓝色链接样式',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const TipBox(
            'Text.rich + TextSpan 是实现「关键词高亮」「行内链接」「混合颜色文案」'
            '的利器。配合 TapGestureRecognizer 可以注册点击事件。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ========== 2. Image ==========
          const SectionHeader('2. Image — 图片组件', icon: Icons.image),
          const Paragraph('Image 支持从网络、本地文件、内存等来源加载图片。'),
          const CodeBlock(
            r'''
// 从网络加载图片
Image.network(
  'https://example.com/image.jpg',
  width: 200,
  height: 200,
  fit: BoxFit.cover,          // 裁剪方式
  loadingBuilder: (ctx, child, progress) {
    if (progress == null) return child;
    return const CircularProgressIndicator();
  },
  errorBuilder: (ctx, error, stack) {
    return const Icon(Icons.broken_image, size: 48);
  },
)

// 从 assets 加载（需在 pubspec.yaml 声明）
Image.asset('images/logo.png')

// 从本地文件加载
Image.file(File('/path/to/image.jpg'))

// BoxFit 常用取值：
//   cover  — 等比例缩放，裁剪多余部分（填满）
//   contain — 等比例缩放，显示完整图片
//   fill   — 拉伸填满，可能变形
//   fitWidth  — 宽度适应
//   fitHeight — 高度适应
''',
            language: 'Dart',
          ),
          const TipBox(
            '网络图片一定要处理加载失败的情况！用 errorBuilder 显示替代图或者占位符，'
            '避免用户看到空白区域。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ========== 3. Icon ==========
          const SectionHeader('3. Icon — 图标组件', icon: Icons.emoji_symbols),
          const Paragraph(
            'Flutter 内置了 Material Design 图标库。图标可以自由设置颜色、大小，'
            '也可以结合 CircleAvatar 等组件实现更丰富的视觉效果。',
          ),
          const CodeBlock(
            r'''
Icon(
  Icons.favorite,
  color: Colors.red,
  size: 48,
)

// 带圆形背景的图标（头像）
CircleAvatar(
  backgroundColor: Colors.blue,
  child: Icon(Icons.person, color: Colors.white),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 40),
              Icon(Icons.star, color: Colors.amber, size: 40),
              Icon(Icons.thumb_up, color: Colors.blue, size: 40),
              Icon(Icons.settings, color: Colors.grey, size: 40),
              Icon(Icons.android, color: Colors.green, size: 40),
              Icon(Icons.music_note, color: Colors.purple, size: 40),
            ],
          ),
          const DividerLine(),

          // ========== 4. Button ==========
          const SectionHeader('4. Button — 按钮组件', icon: Icons.smart_button),
          const Paragraph('Flutter 提供了多种按钮，每种适合不同的交互场景和强调级别。'),
          const CodeBlock(
            r'''
// 凸起按钮 — 最高强调，主要操作
ElevatedButton(
  onPressed: () => print('点击'),
  child: Text('凸起按钮'),
)

// 文字按钮 — 最低强调，次要操作
TextButton(
  onPressed: () {},
  child: Text('文字按钮'),
)

// 边框按钮 — 中等强调
OutlinedButton(
  onPressed: () {},
  child: Text('边框按钮'),
)

// 带图标的按钮
ElevatedButton.icon(
  icon: Icon(Icons.send),
  label: Text('发送'),
  onPressed: () {},
)

// FilledButton — Material 3 新增
FilledButton(
  onPressed: () {},
  child: Text('填充按钮'),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          const TipBox(
            '按钮的 onPressed 设为 null 时按钮会自动变成禁用状态（灰色不可点击）。'
            '可以用这个特性来控制按钮可用性，无需手动设置颜色。',
            type: TipType.tip,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _count++),
                child: const Text('ElevatedButton'),
              ),
              TextButton(onPressed: () {}, child: const Text('TextButton')),
              OutlinedButton(onPressed: () {}, child: const Text('OutlinedButton')),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send),
                label: const Text('发送'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutputBox('ElevatedButton 点击次数: $_count'),
          const DividerLine(),

          // ========== 5. Container（进阶） ==========
          const SectionHeader('5. Container — 万能容器（进阶）', icon: Icons.crop_square),
          const Paragraph(
            'Container 是 Flutter 中最灵活的组件之一。它能同时控制大小、内边距、外边距、背景、'
            '圆角、阴影、边框、变换等。本质上说，Container 是对多个基础 Widget 的语法糖组合。',
          ),
          const Paragraph(
            'Container 的内部组合机制：它依次组合了 Align → Padding → DecoratedBox → '
            'transform → constraints → child。理解这一点，你就知道什么时候该用 Container，'
            '什么时候该用更轻量的替代品。',
          ),
          const CodeBlock(
            r'''
Container(
  width: 200,
  height: 100,
  margin: EdgeInsets.all(16),          // 外边距
  padding: EdgeInsets.all(12),         // 内边距
  alignment: Alignment.center,         // 子组件对齐方式
  transform: Matrix4.rotationZ(0.1),  // 旋转变换
  decoration: BoxDecoration(
    color: Colors.blue,                // 背景色
    borderRadius: BorderRadius.circular(16),   // 圆角
    boxShadow: [                       // 阴影
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    gradient: LinearGradient(          // 渐变背景
      colors: [Colors.blue, Colors.purple],
    ),
    border: Border.all(                // 边框
      color: Colors.blue.shade700,
      width: 2,
    ),
  ),
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '带渐变和阴影的 Container',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const TipBox(
            'Container 很方便，但当只需要一个功能时（比如只需要 padding），'
            '用更具体的 Padding 组件更高效。Container 是「瑞士军刀」，'
            '但不是所有场景都需要瑞士军刀。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ========== 6. Row & Column ==========
          const SectionHeader('6. Row & Column — 线性布局', icon: Icons.view_stream),
          const Paragraph(
            'Row（水平排列）和 Column（垂直排列）是最基础的布局组件。'
            '它们都是 Flex 的子类，通过 mainAxisAlignment 和 crossAxisAlignment '
            '控制子组件的排列方式。',
          ),

          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'MainAxisAlignment / CrossAxisAlignment — 对齐方式',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const CodeBlock(
            r'''
// Row 的主轴是水平方向，Column 的主轴是垂直方向
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //   start        — 起始对齐
  //   center       — 居中对齐
  //   end          — 末尾对齐
  //   spaceAround  — 均匀分布（两端间距为一半）
  //   spaceBetween — 两端靠边，中间均匀
  //   spaceEvenly  — 完全均匀分布
  crossAxisAlignment: CrossAxisAlignment.center,
  //   start     — 顶部/起始对齐
  //   center    — 居中对齐（默认）
  //   end       — 底部/末尾对齐
  //   stretch   — 拉伸填满交叉轴
  //   baseline  — 基线对齐（需文字组件）
  mainAxisSize: MainAxisSize.max,
  //   max  — 占据所有主轴空间（默认）
  //   min  — 只占子组件所需空间
  children: [
    Icon(Icons.star, size: 32),
    Text('评分'),
  ],
)
''',
            language: 'Dart',
          ),

          // Interactive Row alignment demo
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              '交互演示 — 切换 MainAxisAlignment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const Paragraph('点击下面的标签，观察 Row 子组件的排列变化：'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: _alignments[_selectedAlignment],
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_alignmentNames.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_alignmentNames[i], style: const TextStyle(fontSize: 12)),
                    selected: _selectedAlignment == i,
                    onSelected: (_) => setState(() => _selectedAlignment = i),
                  ),
                );
              }),
            ),
          ),

          // CrossAxisAlignment demo
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              'CrossAxisAlignment.stretch 演示',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const CodeBlock(
            r'''
// crossAxisAlignment: stretch 会让所有子项拉伸到交叉轴最大高度
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Container(width: 50, height: 30, color: Colors.red),
    Container(width: 50, height: 60, color: Colors.green),
    Container(width: 50, height: 45, color: Colors.blue),
  ],
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                    ),
                    child: Center(child: Text('30', style: TextStyle(color: Colors.white))),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.green),
                    child: Center(child: Text('60', style: TextStyle(color: Colors.white))),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                    ),
                    child: Center(child: Text('45', style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
          const DividerLine(),

          // ========== 7. Stack + Positioned ==========
          const SectionHeader('7. Stack — 层叠布局', icon: Icons.layers),
          const Paragraph(
            'Stack 允许子组件相互层叠（后添加的在上层）。配合 Positioned 可以精确控制子组件的位置。'
            '适合实现「徽标角标」「图片上的文字」「头像叠加」等效果。',
          ),
          const CodeBlock(
            r'''
Stack(
  // fit: StackFit.loose       — 不限制子组件大小（默认）
  // fit: StackFit.expand      — 子组件扩展为 Stack 大小
  // fit: StackFit.passthrough — 透传父约束给子组件
  clipBehavior: Clip.hardEdge,   // 裁剪超出部分
  children: [
    // 底层：背景
    Container(color: Colors.grey[200]),
    // 上层：用 Positioned 精确定位
    Positioned(
      top: 8,
      right: 8,
      child: CircleAvatar(
        backgroundColor: Colors.red,
        child: Text('3', style: TextStyle(color: Colors.white)),
      ),
    ),
    // 不包 Positioned 的子组件默认左上角对齐
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: EdgeInsets.all(8),
        child: Text('底部标签', textAlign: TextAlign.center),
      ),
    ),
  ],
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),

          // Interactive Stack demo
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              '交互演示 — Stack 实现徽标角标',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // 底层 — 头像占位
                  const Center(
                    child: Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                  // 角标 — 右上角
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _showStackOverlay = !_showStackOverlay),
                      child: AnimatedOpacity(
                        opacity: _showStackOverlay ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.red,
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 底部标签
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        '用户名称',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // 在线状态指示器
                  const Positioned(
                    bottom: 42,
                    right: 16,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Paragraph('提示：点击右上角的红色角标会切换其显示/隐藏，演示了 Stack 的动态交互能力。'),
          const TipBox(
            'Positioned 的 top/right/bottom/left 属性基于 Stack 的边缘定位。'
            '不包裹 Positioned 的子组件默认在 Stack 的左上角（根据 alignment 属性变化）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ========== 8. Expanded vs Flexible ==========
          const SectionHeader('8. Expanded vs Flexible — 弹性布局', icon: Icons.space_bar),
          const Paragraph(
            'Expanded 和 Flexible 都必须作为 Row、Column 或 Flex 的直接子组件使用。'
            '它们按 flex 比例分配主轴上的剩余空间。区别在于：Expanded 强制子组件填满分配的空间，'
            '而 Flexible 允许子组件小于分配的空间（由 fit 属性控制）。',
          ),
          const CodeBlock(
            r'''
// Expanded —— 强制填满分配的空间
Row(
  children: [
    Expanded(
      flex: 2,  // 占 2/3 空间
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,  // 占 1/3 空间
      child: Container(color: Colors.blue),
    ),
  ],
)

// Flexible —— 子组件可以小于分配的空间
Row(
  children: [
    Flexible(
      flex: 1,
      fit: FlexFit.loose,   // 子组件可以小于分配空间（默认）
      // fit: FlexFit.tight, // 效果同 Expanded
      child: Container(
        width: 50,  // 即使分配了更多空间，也只占 50
        color: Colors.red,
      ),
    ),
  ],
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'flex: 2',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'flex: 1',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const TipBox(
            'Expanded 等价于 Flexible(fit: FlexFit.tight)。'
            '想让子组件按比例分配空间就用 Expanded；想「尽量占空间但允许更小」就用 Flexible。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ========== 9. SizedBox vs Container ==========
          const SectionHeader('9. SizedBox vs Container — 尺寸控制', icon: Icons.aspect_ratio),
          const Paragraph(
            'SizedBox 和 Container 都能控制尺寸，但 SizedBox 更轻量。'
            '当只需要固定宽高时，优先使用 SizedBox；需要同时设置背景、边框、圆角等装饰时才用 Container。',
          ),
          const CodeBlock(
            r'''
// SizedBox —— 纯粹的尺寸控制，最轻量
SizedBox(
  width: 100,
  height: 100,
  child: Card(child: Center(child: Text('固定尺寸'))),
)

// SizedBox.expand —— 填满父组件可用空间
SizedBox.expand(
  child: Icon(Icons.star),
)

// SizedBox 常用作间距
SizedBox(width: 16),   // 水平间距
SizedBox(height: 16),  // 垂直间距

// Container —— 功能丰富，但创建了更多内部对象
Container(
  width: 100,
  height: 100,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text('Hello'),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Card(
                  child: Center(child: Text('SizedBox', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: Text('Container', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          const TipBox(
            '用 SizedBox(width: 16) 作间距比 Container(width: 16) 更高效，'
            '因为 SizedBox 内部不创建 Alignment、Padding 等额外对象。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ========== 10. Padding vs EdgeInsets ==========
          const SectionHeader('10. Padding & EdgeInsets — 间距详解', icon: Icons.space_dashboard),
          const Paragraph(
            'Padding 是一个 Widget，它接收一个 EdgeInsets 对象来控制内边距。'
            'EdgeInsets 提供了 4 种构造方法，适应不同的间距设置需求。',
          ),
          const CodeBlock(
            r'''
// EdgeInsets 的 4 种构造方法

// 1. all — 所有方向相同
EdgeInsets.all(16)

// 2. symmetric — 对称设置
EdgeInsets.symmetric(
  horizontal: 16,  // 左右
  vertical: 8,     // 上下
)

// 3. only — 单独指定各方向
EdgeInsets.only(
  left: 8,
  top: 16,
  right: 8,
  bottom: 0,
)

// 4. fromLTRB — 从左到右依次指定
EdgeInsets.fromLTRB(8, 16, 8, 0)
// 参数顺序: left, top, right, bottom

// Padding 组件使用
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
  child: Text('带内边距的文字'),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('EdgeInsets.all(16) — 四边相同间距'),
                ),
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('EdgeInsets.symmetric — 水平16 垂直12'),
                ),
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.only(left: 24, top: 8, bottom: 8),
                  child: Text('EdgeInsets.only — 左边距24'),
                ),
              ],
            ),
          ),
          const DividerLine(),

          // ========== 11. DecoratedBox ==========
          const SectionHeader('11. DecoratedBox — 装饰组件', icon: Icons.dashboard_customize),
          const Paragraph(
            'DecoratedBox 是 Container 内部实际用于绘制 decoration 的组件。'
            '当只需要背景色、圆角、边框等装饰而不需要 Container 的其他功能（padding、alignment）时，'
            '用 DecoratedBox 更轻量，组合也更清晰。',
          ),
          const CodeBlock(
            r'''
// DecoratedBox —— 纯粹的装饰组件
DecoratedBox(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue.shade700),
  ),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('带背景的文本'),
  ),
)

// 等价于 Container，但更轻量
// Container 内部实际：Align → Padding → DecoratedBox → transform → ...
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'DecoratedBox + Padding = 轻量版 Container',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          const TipBox(
            '当你只需要「背景 + 内容」时，用 DecoratedBox + Padding 代替 Container '
            '可以减少不必要的嵌套层次。这在构建大型 widget 树时小优化能累积。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ========== 12. GestureDetector & InkWell ==========
          const SectionHeader('12. GestureDetector & InkWell — 手势处理', icon: Icons.touch_app),
          const Paragraph(
            'GestureDetector 是最通用的手势检测组件，可以识别点击、双击、长按、拖动、'
            '缩放等几乎所有手势。InkWell 是 Material Design 的水波纹效果组件，'
            '适合用在按钮、卡片等需要点击反馈的场景。',
          ),
          const CodeBlock(
            r'''
// GestureDetector —— 通用手势检测，无视觉反馈
GestureDetector(
  onTap: () => print('点击'),
  onDoubleTap: () => print('双击'),
  onLongPress: () => print('长按'),
  onPanUpdate: (d) => print('拖动: ${d.delta}'),
  child: Container(
    padding: EdgeInsets.all(16),
    color: Colors.blue,
    child: Text('点击/双击/长按'),
  ),
)

// InkWell —— Material 水波纹，有视觉反馈
InkWell(
  onTap: () => print('点击'),
  onLongPress: () => print('长按'),
  borderRadius: BorderRadius.circular(12),
  splashColor: Colors.blue.withOpacity(0.3),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('有水波纹反馈'),
  ),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),

          // Interactive GestureDetector demo
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              '交互演示 — GestureDetector 点击/双击/长按',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const Paragraph('试试点击、双击、长按下面的区域（计数器会变化）：'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _count++),
            onDoubleTap: () => setState(() => _count += 10),
            onLongPress: () => setState(() => _count = 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.touch_app, size: 48, color: Colors.blue[400]),
                  const SizedBox(height: 8),
                  const Text(
                    '点击 +1  |  双击 +10  |  长按归零',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  OutputBox('当前计数: $_count'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // InkWell demo
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'InkWell 水波纹演示',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('点击我看看水波纹效果', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const TipBox(
            'GestureDetector 没有视觉反馈，适合非 Material 设计或自定义效果。'
            'InkWell 自带 Material 水波纹，让用户感知到「点到了」。'
            '在 MaterialApp 中推荐优先使用 InkWell。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ========== 13. MediaQuery & SafeArea ==========
          const SectionHeader('13. MediaQuery & SafeArea — 屏幕适配', icon: Icons.phone_iphone),
          const Paragraph(
            'MediaQuery 提供当前设备的屏幕信息（尺寸、边距、方向等）。'
            'SafeArea 利用 MediaQuery 的数据自动避开屏幕的安全区域'
            '（刘海屏、状态栏、底部导航条），确保内容不被遮挡。',
          ),
          const CodeBlock(
            r'''
// MediaQuery —— 获取屏幕信息
final media = MediaQuery.of(context);

media.size              // 屏幕尺寸（Size 对象）
media.padding           // 安全区域边距
media.viewInsets        // 键盘等系统 UI 占位
media.orientation       // 屏幕方向 Orientation.portrait / .landscape
media.platformBrightness // 深色/浅色模式

// 根据屏幕方向调整布局
if (media.orientation == Orientation.landscape) {
  // 横屏布局
} else {
  // 竖屏布局
}

// SafeArea —— 自动避开安全区域
SafeArea(
  left: true,     // 避开左边缘
  top: true,      // 避开状态栏（默认 true）
  right: true,    // 避开右边缘
  bottom: true,   // 避开底部导航条（默认 true）
  minimum: EdgeInsets.all(8),  // 最小边距保底
  child: Text('自动避开刘海屏和状态栏'),
)
''',
            language: 'Dart',
          ),
          const TipBox(
            'SafeArea 的 minimum 参数可以保证即使在没有安全区域的设备上也有最小间距。'
            '在横屏模式下，SafeArea 会自动避开摄像头区域的「刘海」。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ========== 14. ListView ==========
          const SectionHeader('14. ListView — 列表组件', icon: Icons.list_alt),
          const Paragraph(
            'ListView 是 Flutter 中最常用的可滚动列表组件。它有两种主要用法：'
            'ListView(children: [...]) 适用于列表项较少（如少于 20 项）的场景；'
            'ListView.builder 适用于长列表或无限列表，按需构建，性能更优。',
          ),
          const CodeBlock(
            r'''
// 方式一：ListView(children: [...]) —— 一次性构建所有子项
ListView(
  padding: EdgeInsets.all(16),
  scrollDirection: Axis.vertical,   // 垂直滚动
  // scrollDirection: Axis.horizontal, // 水平滚动
  children: [
    ListTile(title: Text('项目 1')),
    ListTile(title: Text('项目 2')),
    // ... 适合少量固定项
  ],
)

// 方式二：ListView.builder() —— 按需构建，性能更好
ListView.builder(
  padding: EdgeInsets.all(16),
  itemCount: 1000,          // 总项数
  itemExtent: 60,           // 固定高度（提升滚动性能）
  itemBuilder: (ctx, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('$index')),
      title: Text('第 $index 项'),
    );
  },
)
''',
            language: 'Dart',
          ),
          const TipBox(
            'ListView.builder 只有在项即将出现在屏幕上时才构建，适合超长列表。'
            'itemExtent 设置固定高度可以让 ListView 更高效地计算滚动范围。'
            '水平 ListView 记得给子项设置宽度约束。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ========== 15. GridView ==========
          const SectionHeader('15. GridView — 网格布局', icon: Icons.grid_on),
          const Paragraph(
            'GridView 用于展示网格状布局。两种常用模式：Gridview.count（指定列数）'
            '和 Gridview.extent（指定每项最大宽度，自动计算列数）。',
          ),
          const CodeBlock(
            r'''
// GridView.count —— 固定列数
GridView.count(
  crossAxisCount: 3,          // 3列
  crossAxisSpacing: 8,        // 列间距
  mainAxisSpacing: 8,         // 行间距
  childAspectRatio: 1.0,      // 宽高比（1:1 正方形）
  children: [
    Container(color: Colors.red),
    Container(color: Colors.blue),
  ],
)

// GridView.extent —— 动态列数（根据宽度自动计算）
GridView.extent(
  maxCrossAxisExtent: 150,    // 每项最大宽度
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  children: [...],
)

// GridView.builder 用于长列表
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0,
  ),
  itemCount: 100,
  itemBuilder: (ctx, index) => Container(color: ...),
)
''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(8, (i) {
                const colors = [
                  Colors.red, Colors.blue, Colors.green, Colors.orange,
                  Colors.purple, Colors.teal, Colors.pink, Colors.amber,
                ];
                return Container(
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$i',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const TipBox(
            'GridView.builder 同样支持 builder 模式用于长列表。'
            'childAspectRatio 控制宽高比：1.0 是正方形，0.5 是宽比高长一倍。'
            '别忘了给 GridView 设置高度约束（如 SizedBox 包裹）。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ========== 练习 ==========
          const SectionHeader('本章练习', icon: Icons.edit),
          const Paragraph('1. 用 Text.rich 实现一段包含「红色关键词」和「蓝色链接」的富文本。'),
          const Paragraph('2. 用 Row + Expanded 实现一个三栏等宽布局，每栏颜色不同。'),
          const Paragraph('3. 用 Stack + Positioned 实现一个带角标的头像（红点/数字角标）。'),
          const Paragraph('4. 用 GestureDetector 实现一个可拖动的小方块（提示：用 onPanUpdate）。'),
          const Paragraph('5. 用 GridView.count 实现一个 4x2 的彩色数字网格。'),
          const SizedBox(height: 8),
          const TipBox(
            '所有练习都可以用上面的代码示例作为参考。试着组合不同的 Widget，'
            'Flutter 的魅力就在于「小 Widget 搭出大界面」。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
