import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第十章：Widget 基础大全
/// 涵盖：Text、Image、Icon、Button、Container、Row/Column、
///       Stack、Expanded/Flexible、SizedBox、Padding、
///       DecoratedBox、GestureDetector、InkWell、
///       ListView、GridView、Wrap、Table、SingleChildScrollView
/// ============================================================

class FlutterWidgetBasics extends StatefulWidget {
  const FlutterWidgetBasics({super.key});

  @override
  State<FlutterWidgetBasics> createState() => _FlutterWidgetBasicsState();
}

class _FlutterWidgetBasicsState extends State<FlutterWidgetBasics> {
  int _count = 0;
  int _selectedAlignment = 0;
  bool _showStackOverlay = true;
  double _sliderW = 200;
  int _wrapSelected = 0;

  static const List<MainAxisAlignment> _alignments = [
    MainAxisAlignment.start, MainAxisAlignment.center,
    MainAxisAlignment.end, MainAxisAlignment.spaceAround,
    MainAxisAlignment.spaceBetween, MainAxisAlignment.spaceEvenly,
  ];

  static const List<String> _alignmentNames = [
    'start', 'center', 'end',
    'spaceAround', 'spaceBetween', 'spaceEvenly',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第10章 · Widget 基础大全'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════
          // 章节目录
          // ═══════════════════════════════════════
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '0   StatelessWidget vs StatefulWidget —— 两种 Widget 的本质区别\n'
            '1   Text —— 文字样式、溢出处理、富文本、排版\n'
            '2   Image —— 网络/本地/内存图片、加载状态、缓存\n'
            '3   Icon —— 内置图标库、自定义图标\n'
            '4   Button —— 六种按钮的用途和选择\n'
            '5   Container —— 万能容器的内部组合机制\n'
            '6   Row & Column —— 线性布局与对齐方式\n'
            '7   Stack & Positioned —— 层叠布局\n'
            '8   Expanded vs Flexible —— 弹性空间分配\n'
            '9   SizedBox vs Container —— 尺寸控制选型\n'
            '10  Padding & EdgeInsets —— 间距系统\n'
            '11  DecoratedBox —— 装饰组件\n'
            '12  GestureDetector & InkWell —— 手势处理\n'
            '13  MediaQuery & SafeArea —— 屏幕适配\n'
            '14  ListView & ListView.builder —— 列表组件\n'
            '15  GridView —— 网格布局\n'
            '16  Wrap & Flow —— 流式布局\n'
            '17  Table —— 表格布局\n'
            '18  Widget 选择决策树',
          ),
          const TipBox(
            'Flutter 的核心哲学是"万物皆 Widget"。本章系统讲解最常用、最重要的 Widget 及其进阶用法。'
            '每个 Widget 都有交互演示，建议动手尝试。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 0. StatelessWidget vs StatefulWidget
          // ═══════════════════════════════════════
          const SectionHeader('0. StatelessWidget vs StatefulWidget', icon: Icons.compare_arrows),
          const Paragraph(
            'Flutter 中所有 Widget 分为两种类型。理解它们的区别是 Flutter 开发的第一步。\n\n'
            'StatelessWidget（无状态组件）：\n'
            '  • 属性全部通过构造函数传入，创建后不可改变\n'
            '  • build 方法在父组件重建或配置变化时可能被多次调用\n'
            '  • 适合：静态文本、图标、固定布局结构、纯展示组件\n'
            '  • 性能最好 —— 没有 State 对象的开销\n\n'
            'StatefulWidget（有状态组件）：\n'
            '  • 由两个类组成：Widget（不可变配置）+ State（可变状态）\n'
            '  • 通过 setState() 主动触发 UI 重建\n'
            '  • 适合：用户交互、计时器、动画、网络请求更新\n'
            '  • State 对象有完整的生命周期（initState → build → dispose）\n\n'
            '选择原则：能用 StatelessWidget 就用 StatelessWidget——更简单、更高效。'
            '很多初学者把所有东西都写成 StatefulWidget，这是不必要的。'
            'Provider/Bloc 等状态管理工具让 StatelessWidget 也能响应数据变化。',
          ),
          const CodeBlock(
            r'''// ── StatelessWidget：无内部状态 ──
class Greeting extends StatelessWidget {
  final String name;  // 通过构造器传入
  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('你好，$name');
  }
}
// 使用：Greeting(name: '张三')

// ── StatefulWidget：有可变状态 ──
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();  // 创建 State
}

class _CounterState extends State<Counter> {
  int _count = 0;  // 可变状态（存在 State 对象中）

  void _increment() {
    setState(() { _count++; });  // 通知 Flutter 重建 UI
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('计数: $_count'),
      ElevatedButton(onPressed: _increment, child: const Text('+1')),
    ]);
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '一个常见误解：StatelessWidget 不会重建。实际上，父组件重建时，子 StatelessWidget 也会重建。区别在于 StatefulWidget 可以通过 setState 主动触发自身重建，而 StatelessWidget 只能被动等待。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 1. Text
          // ═══════════════════════════════════════
          const SectionHeader('1. Text —— 文字组件完全指南', icon: Icons.text_fields),
          const Paragraph(
            'Text 是 Flutter 中使用频率最高的组件。它不仅仅显示文字，还提供完整的排版控制。\n\n'
            '核心构造函数参数：\n'
            '  • data: String —— 要显示的文字\n'
            '  • style: TextStyle? —— 文字样式（颜色、字号、字重、行高等）\n'
            '  • textAlign: TextAlign? —— 水平对齐\n'
            '  • textDirection: TextDirection? —— 文字方向\n'
            '  • softWrap: bool —— 是否自动换行（默认 true）\n'
            '  • overflow: TextOverflow —— 溢出处理（clip/ellipsis/fade）\n'
            '  • maxLines: int? —— 最大行数\n'
            '  • textScaler: TextScaler? —— 文字缩放（替代废弃的 textScaleFactor）\n'
            '  • strutStyle: StrutStyle? —— 行高约束（统一多字体的行高）\n'
            '  • textWidthBasis: TextWidthBasis —— 宽度计算基准\n'
            '  • textHeightBehavior: TextHeightBehavior? —— 首行/末行高度行为\n'
            '  • semanticsLabel: String? —— 无障碍标签',
          ),
          const CodeBlock(
            r'''// ── 基础用法 ──
Text('Hello Flutter');

// ── 完整样式 ──
Text(
  '带样式的文字',
  style: TextStyle(
    fontSize: 20,                       // 字号（逻辑像素）
    fontWeight: FontWeight.bold,        // 字重（w100~w900）
    fontStyle: FontStyle.italic,        // 斜体
    color: Colors.blue,                 // 颜色
    letterSpacing: 2.0,                 // 字间距
    wordSpacing: 4.0,                   // 词间距
    height: 1.5,                        // 行高倍数
    decoration: TextDecoration.underline, // 下划线
    decorationColor: Colors.red,        // 装饰线颜色
    decorationStyle: TextDecorationStyle.dashed, // 虚线
    backgroundColor: Colors.yellow,     // 文字底色
    shadows: [                          // 阴影
      Shadow(color: Colors.grey, blurRadius: 4, offset: Offset(2, 2)),
    ],
  ),
);

// ── 溢出处理 ──
Text(
  '这是一段非常长的文字用来演示溢出处理的效果当文字超出可用宽度时的显示方式',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,  // clip | ellipsis | fade
  softWrap: true,
);

// ── Text.rich 富文本 ──
Text.rich(
  TextSpan(
    text: '普通文字 ',
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(
        text: '红色加粗',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: ' 可点击',
        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()..onTap = () => print('点击'),
      ),
    ],
  ),
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          // 实时样式预览
          const Text(
            'Hello Flutter — 蓝色加粗 20 号文字示例',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Container(
            width: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Text(
              '一段很长的文字用来演示 maxLines=2 + TextOverflow.ellipsis 的效果。'
              '超出两行的内容将被省略号替换，这是移动端最常见的溢出处理方式。',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: '普通文字 ',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              children: const [
                TextSpan(text: '红色加粗', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                TextSpan(text: ' 蓝色链接', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              ],
            ),
          ),
          const TipBox(
            'Text.rich + TextSpan 实现内联多样式。TapGestureRecognizer 注册点击事件（记得在 dispose 中 dispose recognizer）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 2. Image
          // ═══════════════════════════════════════
          const SectionHeader('2. Image —— 图片组件', icon: Icons.image),
          const Paragraph(
            'Image 支持多种图片来源，并提供完整的加载状态和错误处理。\n\n'
            '四种加载方式：\n'
            '  • Image.network —— 从网络 URL 加载（最常用）\n'
            '  • Image.asset —— 从项目 assets 目录加载\n'
            '  • Image.file —— 从设备本地文件加载\n'
            '  • Image.memory —— 从 Uint8List 字节数据加载\n\n'
            'BoxFit 枚举控制图片如何适配容器：\n'
            '  • cover —— 等比例缩放填满容器，超出部分裁剪（最常用）\n'
            '  • contain —— 等比例缩放，完整显示图片内容\n'
            '  • fill —— 拉伸填满，可能变形\n'
            '  • fitWidth —— 宽度填满，高度自适应\n'
            '  • fitHeight —— 高度填满，宽度自适应\n'
            '  • none —— 原始尺寸，不缩放\n'
            '  • scaleDown —— 同 contain，但不放大（仅缩小）',
          ),
          const CodeBlock(
            r'''// ── 网络图片（带加载状态和错误处理）──
Image.network(
  'https://picsum.photos/200',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  // 加载中
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;  // 加载完成
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  // 加载失败
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.broken_image, size: 48, color: Colors.grey),
        Text('图片加载失败', style: TextStyle(color: Colors.grey)),
      ]),
    );
  },
  // 缓存策略
  cacheWidth: 400,   // 缓存时限制宽度（节省内存）
  cacheHeight: 400,
);

// ── Asset 图片（需先在 pubspec.yaml 声明）──
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
  fit: BoxFit.contain,
  // 支持不同分辨率：assets/images/2.0x/logo.png
);

// ── 本地文件图片 ──
Image.file(
  File('/storage/photos/avatar.jpg'),
  fit: BoxFit.cover,
);

// ── FadeInImage（带占位图和淡入动画）──
FadeInImage.assetNetwork(
  placeholder: 'assets/loading.gif',
  image: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/400/200',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const OutputBox('Image.network + BoxFit.cover + 圆角裁剪。errorBuilder 保证加载失败也有友好提示。'),
          const TipBox(
            '网络图片务必设置 errorBuilder——网络不稳定时用户至少看到占位图而非空白。cacheWidth/cacheHeight 限制缓存尺寸，避免大图占用过多内存。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 3. Icon
          // ═══════════════════════════════════════
          const SectionHeader('3. Icon —— 图标组件', icon: Icons.emoji_symbols),
          const Paragraph(
            'Flutter 内置了 Material Design Icons 图标库（2000+ 图标）。Icon 可以自由设置颜色、大小。\n\n'
            '常用属性：\n'
            '  • icon: IconData —— 图标数据（如 Icons.star）\n'
            '  • size: double —— 图标大小（默认 24）\n'
            '  • color: Color? —— 图标颜色\n'
            '  • semanticLabel: String? —— 无障碍描述\n'
            '  • fill: double —— 填充比例（0=空心, 1=实心，需图标本身支持）\n'
            '  • weight: double —— 描边粗细\n'
            '  • grade: double —— 粗细等级\n'
            '  • opticalSize: double —— 光学大小\n'
            '  • shadows: List<Shadow>? —— 阴影\n\n'
            '配合 CircleAvatar 可实现带圆形背景的图标（头像效果）。',
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 16, runSpacing: 12,
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 36),
              Icon(Icons.star, color: Colors.amber, size: 36),
              Icon(Icons.thumb_up, color: Colors.blue, size: 36),
              Icon(Icons.settings, color: Colors.grey, size: 36),
              Icon(Icons.android, color: Colors.green, size: 36),
              Icon(Icons.music_note, color: Colors.purple, size: 36),
              Icon(Icons.flight, color: Colors.orange, size: 36),
              Icon(Icons.beach_access, color: Colors.teal, size: 36),
            ],
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 4. Button
          // ═══════════════════════════════════════
          const SectionHeader('4. Button —— 六种按钮详解', icon: Icons.smart_button),
          const Paragraph(
            'Flutter 提供六种按钮，按视觉强调级别从高到低排列：\n\n'
            '① FilledButton —— 实心填充按钮（Material 3 推荐，最高强调）\n'
            '  适用于：页面唯一的主要操作（如"提交""购买"）\n\n'
            '② ElevatedButton —— 凸起按钮（有阴影，M3 中带浅色填充）\n'
            '  适用于：card 中的主要操作、需要视觉突出的按钮\n\n'
            '③ OutlinedButton —— 边框按钮（中等强调）\n'
            '  适用于：次要操作、"取消""返回"等\n\n'
            '④ TextButton —— 纯文字按钮（最低强调）\n'
            '  适用于：最小干扰的操作、"了解更多""跳过"等\n\n'
            '⑤ IconButton —— 图标按钮\n'
            '  适用于：工具栏、列表中紧凑的操作（如删除、编辑图标）\n\n'
            '⑥ FloatingActionButton —— 浮动操作按钮\n'
            '  适用于：页面最重要的单一操作（如"新建""发布"）',
          ),
          const CodeBlock(
            r'''// ── FilledButton（最强调）──
FilledButton(
  onPressed: () {},
  style: FilledButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: const Text('主要操作'),
);

// ── ElevatedButton（带阴影）──
ElevatedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.send, size: 18),
  label: const Text('发送'),
);

// ── OutlinedButton（边框）──
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Colors.blue),
  ),
  child: const Text('次要操作'),
);

// ── TextButton（最小干扰）──
TextButton(onPressed: () {}, child: const Text('跳过'));

// ── IconButton（紧凑）──
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.delete),
  color: Colors.red,
  tooltip: '删除',
);

// ── FloatingActionButton ──
FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(onPressed: () => setState(() => _count++), child: const Text('Filled')),
            ElevatedButton.icon(onPressed: () => setState(() => _count++), icon: const Icon(Icons.send, size: 16), label: const Text('Elevated')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete), color: Colors.red, tooltip: '删除'),
          ]),
          const SizedBox(height: 8),
          OutputBox('按钮点击次数: $_count\n\nonPressed = null 时按钮自动变为禁用状态（灰色）。'),
          const TipBox(
            '一个页面只应有一个最高强调的按钮。如果所有按钮都是 FilledButton，用户就不知道该点哪个了。视觉层级引导用户行为。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 5. Container
          // ═══════════════════════════════════════
          const SectionHeader('5. Container —— 万能容器的内部机制', icon: Icons.crop_square),
          const Paragraph(
            'Container 是 Flutter 中最灵活的组件之一，它用一个 Widget 包装了多种功能。\n'
            '理解它的内部组合顺序，能帮助你判断何时该用 Container，何时该用更轻量的替代品。\n\n'
            'Container 内部依次组合：\n'
            '  ① Align（alignment 属性）\n'
            '  ② Padding（padding 属性）\n'
            '  ③ DecoratedBox（decoration 属性）\n'
            '  ④ Transform（transform 属性）\n'
            '  ⑤ ConstrainedBox（constraints 属性）\n'
            '  ⑥ 最后放 child\n\n'
            '设计哲学：只用一个功能 → 用专门的 Widget（只需 padding → Padding；只需 decoration → DecoratedBox）；'
            '需要两个以上功能 → 用 Container。',
          ),
          const CodeBlock(
            r'''Container(
  width: 200,                      // 宽度
  height: 100,                     // 高度
  margin: const EdgeInsets.all(16),// 外边距
  padding: const EdgeInsets.all(12),// 内边距
  alignment: Alignment.center,     // 子组件对齐
  constraints: const BoxConstraints(// 额外约束
    minWidth: 100, maxWidth: 300,
  ),
  transform: Matrix4.rotationZ(0.1), // 变换（旋转）
  decoration: BoxDecoration(
    color: Colors.blue,            // 背景色
    borderRadius: BorderRadius.circular(16), // 圆角
    boxShadow: [                   // 阴影
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    gradient: const LinearGradient(// 渐变（与 color 互斥！）
      colors: [Colors.blue, Colors.purple],
    ),
    border: Border.all(            // 边框
      color: Colors.blue.shade700,
      width: 2,
    ),
  ),
  child: const Text('Hello', style: TextStyle(color: Colors.white)),
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('带渐变和阴影的 Container', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          const TipBox(
            'decoration 的 color 和 gradient 互斥——同时设置会报错。需要渐变色背景时用 gradient，纯色用 color。Container 很方便，但只做一件事时请用更轻量的组件。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 6. Row & Column
          // ═══════════════════════════════════════
          const SectionHeader('6. Row & Column —— 线性布局', icon: Icons.view_stream),
          const Paragraph(
            'Row（水平排列）和 Column（垂直排列）是 Flutter 最基础的布局组件。它们都是 Flex 的子类。\n\n'
            '核心参数：\n'
            '  • mainAxisAlignment —— 主轴方向的对齐方式\n'
            '  • crossAxisAlignment —— 交叉轴方向的对齐方式\n'
            '  • mainAxisSize —— 主轴尺寸（max=占满空间, min=收缩到子组件大小）\n'
            '  • textDirection —— 文字方向（影响 start/end 的含义）\n'
            '  • verticalDirection —— 垂直方向（down/up，影响 Column 的排列顺序）\n\n'
            'MainAxisAlignment 六种取值：\n'
            '  start — 起始对齐 | center — 居中 | end — 末尾对齐\n'
            '  spaceAround — 均匀分布（两端间距为中间的一半）\n'
            '  spaceBetween — 两端贴边，中间均匀分布\n'
            '  spaceEvenly — 完全均匀分布（所有间距相等）',
          ),
          // 交互：切换对齐方式
          const SizedBox(height: 8),
          const Text('点击下方标签切换 MainAxisAlignment：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              mainAxisAlignment: _alignments[_selectedAlignment],
              children: [
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(8)))),
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(8)))),
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(8)))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_alignmentNames.length, (i) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_alignmentNames[i], style: const TextStyle(fontSize: 12)),
                  selected: _selectedAlignment == i,
                  onSelected: (_) => setState(() => _selectedAlignment = i),
                ),
              )),
            ),
          ),
          const SizedBox(height: 8),
          OutputBox('当前对齐: ${_alignmentNames[_selectedAlignment]} —— 观察三个方块的排列变化。'),
          // CrossAxisAlignment.stretch 演示
          const SizedBox(height: 8),
          const Text('CrossAxisAlignment.stretch 示例：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: DecoratedBox(decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.horizontal(left: Radius.circular(12))), child: Center(child: Text('30', style: TextStyle(color: Colors.white))))),
                SizedBox(width: 4),
                Expanded(child: DecoratedBox(decoration: BoxDecoration(color: Colors.green), child: Center(child: Text('60', style: TextStyle(color: Colors.white))))),
                SizedBox(width: 4),
                Expanded(child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.horizontal(right: Radius.circular(12))), child: Center(child: Text('45', style: TextStyle(color: Colors.white))))),
              ],
            ),
          ),
          const OutputBox('stretch 让所有子项拉伸到交叉轴的最大高度，无论各自的原始高度。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 7. Stack + Positioned
          // ═══════════════════════════════════════
          const SectionHeader('7. Stack & Positioned —— 层叠布局', icon: Icons.layers),
          const Paragraph(
            'Stack 让子组件像图层一样层叠（后添加的在上层）。配合 Positioned 可精确控制子组件位置。\n\n'
            'Stack 参数：\n'
            '  • alignment: AlignmentDirectional —— 未定位子组件的默认对齐（默认 topStart）\n'
            '  • fit: StackFit —— 子组件尺寸约束方式\n'
            '    - loose（默认）：子组件可以小于 Stack\n'
            '    - expand：强制子组件填满 Stack\n'
            '    - passthrough：透传父约束\n'
            '  • clipBehavior: Clip —— 溢出裁剪方式（默认 hardEdge）\n\n'
            'Positioned 参数：\n'
            '  • top/right/bottom/left: double? —— 距离 Stack 各边的距离\n'
            '  • width/height: double? —— 固定尺寸\n'
            '  • 四个边都设 → 自动拉伸；只设两边 → 固定位置\n\n'
            '典型场景：头像+角标、图片+文字覆盖、卡片层叠效果。',
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
              child: Stack(children: [
                const Center(child: Icon(Icons.person, size: 80, color: Colors.grey)),
                // 角标
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _showStackOverlay = !_showStackOverlay),
                    child: AnimatedOpacity(
                      opacity: _showStackOverlay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const CircleAvatar(radius: 16, backgroundColor: Colors.red, child: Text('3', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                // 底部标签
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text('用户名称', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
                // 在线状态
                const Positioned(bottom: 42, right: 16, child: CircleAvatar(radius: 8, backgroundColor: Colors.green)),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          const OutputBox('点击红色角标切换显示/隐藏。Stack 的多层叠加实现头像+角标+在线状态+名称标签。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 8. Expanded vs Flexible
          // ═══════════════════════════════════════
          const SectionHeader('8. Expanded vs Flexible —— 弹性空间分配', icon: Icons.space_bar),
          const Paragraph(
            'Expanded 和 Flexible 必须作为 Row、Column 或 Flex 的直接子组件使用。\n'
            '它们按 flex 比例分配主轴上的剩余空间。\n\n'
            'Expanded：强制子组件填满分配到的所有空间\n'
            '  • 等价于 Flexible(fit: FlexFit.tight)\n'
            '  • 即使子组件设置了更小的尺寸也会被拉伸\n\n'
            'Flexible：允许子组件小于分配到的空间\n'
            '  • fit: FlexFit.loose（默认）—— 子组件可以更小\n'
            '  • fit: FlexFit.tight —— 效果同 Expanded\n\n'
            'flex 参数：默认 1，比例分配剩余空间。\n'
            'flex: 2 的组件获得的剩余空间是 flex: 1 的两倍。',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, height: 50,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Expanded(flex: 2, child: DecoratedBox(decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.horizontal(left: Radius.circular(12))), child: Center(child: Text('flex: 2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
              SizedBox(width: 4),
              Expanded(flex: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.horizontal(right: Radius.circular(12))), child: Center(child: Text('flex: 1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
            ]),
          ),
          const SizedBox(height: 4),
          const OutputBox('flex: 2 占 2/3 宽度，flex: 1 占 1/3。flex 按权重分配剩余空间。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 9. SizedBox vs Container
          // ═══════════════════════════════════════
          const SectionHeader('9. SizedBox vs Container —— 尺寸控制', icon: Icons.aspect_ratio),
          const Paragraph(
            'SizedBox 和 Container 都能控制尺寸，但内部实现不同：\n\n'
            'SizedBox —— 纯尺寸控制，最轻量\n'
            '  • SizedBox(width, height) —— 固定尺寸\n'
            '  • SizedBox.expand —— 填满父组件可用空间\n'
            '  • SizedBox.shrink —— 收缩到最小（0 尺寸）\n'
            '  • SizedBox(width: 16) 常用于间距\n\n'
            'Container —— 功能丰富但有额外开销\n'
            '  • 包含 Align + Padding + DecoratedBox + Transform + ConstrainedBox\n'
            '  • 如果只需要尺寸控制，用 SizedBox 更高性能',
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 80, height: 80,
              child: Card(child: Center(child: Text('SizedBox', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[700])))),
            ),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Container', style: TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center)),
            ),
          ]),
          const TipBox('SizedBox(width: 16) 作间距比 Container(width: 16) 高效——内部不创建额外的 Alignment、Padding、DecoratedBox 等对象。', type: TipType.tip),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 10. Padding & EdgeInsets
          // ═══════════════════════════════════════
          const SectionHeader('10. Padding & EdgeInsets —— 间距系统', icon: Icons.space_dashboard),
          const Paragraph(
            'EdgeInsets 提供四种构造方法适应不同需求：\n'
            '  • EdgeInsets.all(double) —— 四边相同\n'
            '  • EdgeInsets.symmetric(horizontal, vertical) —— 对称设置\n'
            '  • EdgeInsets.only(left, top, right, bottom) —— 单独指定\n'
            '  • EdgeInsets.fromLTRB(l, t, r, b) —— 从左到右依次指定\n\n'
            'Padding Widget 接收一个 EdgeInsets 对象。它是 Container padding 属性的底层实现。',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: EdgeInsets.all(16), child: Text('EdgeInsets.all(16) — 四边相同间距')),
              Divider(height: 1),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('EdgeInsets.symmetric(horizontal: 16, vertical: 12)')),
              Divider(height: 1),
              Padding(padding: EdgeInsets.only(left: 24, top: 8, bottom: 8), child: Text('EdgeInsets.only(left: 24) — 只有左边距24')),
            ]),
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 11. DecoratedBox
          // ═══════════════════════════════════════
          const SectionHeader('11. DecoratedBox —— 装饰组件', icon: Icons.dashboard_customize),
          const Paragraph(
            'DecoratedBox 是 Container 内部实际绘制 decoration 的组件。\n'
            '如果只需要背景色/圆角/边框，而不需要 Container 的 padding/alignment 等，用 DecoratedBox 更轻量。\n\n'
            '两个参数：\n'
            '  • decoration: Decoration —— 前景/背景装饰\n'
            '  • position: DecorationPosition.background/foreground —— 装饰层位置',
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
            child: const Padding(padding: EdgeInsets.all(16), child: Text('DecoratedBox + Padding = 轻量版 Container', style: TextStyle(color: Colors.green))),
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 12. GestureDetector & InkWell
          // ═══════════════════════════════════════
          const SectionHeader('12. GestureDetector & InkWell —— 手势处理', icon: Icons.touch_app),
          const Paragraph(
            'GestureDetector：通用手势检测，无视觉反馈，功能全面（点击/双击/长按/拖动/缩放）。\n'
            'InkWell：Material Design 水波纹效果，视觉反馈好，适合按钮/卡片场景。\n\n'
            '选择原则：MaterialApp 中优先用 InkWell（水波纹 + 无障碍友好），需要复杂手势用 GestureDetector。',
          ),
          const SizedBox(height: 8),
          // GestureDetector 交互
          GestureDetector(
            onTap: () => setState(() => _count++),
            onDoubleTap: () => setState(() => _count += 10),
            onLongPress: () => setState(() => _count = 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue[200]!)),
              child: Column(children: [
                Icon(Icons.touch_app, size: 48, color: Colors.blue[400]),
                const SizedBox(height: 8),
                const Text('点击 +1  |  双击 +10  |  长按归零', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                OutputBox('计数: $_count'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          // InkWell 水波纹
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.05),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                child: const Row(children: [
                  Icon(Icons.touch_app, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('点击我观察水波纹效果（InkWell）', style: TextStyle(fontSize: 16)),
                ]),
              ),
            ),
          ),
          const TipBox('GestureDetector 无视觉反馈，InkWell 有水波纹。InkWell 必须在 Material 组件的后代中使用，否则水波纹不可见。', type: TipType.info),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 13. MediaQuery & SafeArea
          // ═══════════════════════════════════════
          const SectionHeader('13. MediaQuery & SafeArea —— 屏幕适配', icon: Icons.phone_iphone),
          const Paragraph(
            'MediaQuery：读取设备全局信息（屏幕尺寸、边距、方向、系统亮度）。\n'
            'SafeArea：自动避开系统 UI（刘海、状态栏、底部导航条），本质是用 MediaQuery.padding 做 Padding。\n\n'
            '关键区别：MediaQuery.size 是全屏尺寸，LayoutBuilder.constraints 是被父组件削减后的可用空间。',
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) {
              final mq = MediaQuery.of(ctx);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('当前设备信息：', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('屏幕: ${mq.size.width.toStringAsFixed(0)} x ${mq.size.height.toStringAsFixed(0)}  方向: ${mq.orientation == Orientation.portrait ? "竖屏" : "横屏"}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  Text('顶部安全区: ${mq.padding.top.toStringAsFixed(0)}px  底部: ${mq.padding.bottom.toStringAsFixed(0)}px  键盘: ${mq.viewInsets.bottom.toStringAsFixed(0)}px', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ]),
              );
            },
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 14. ListView
          // ═══════════════════════════════════════
          const SectionHeader('14. ListView —— 列表组件', icon: Icons.list_alt),
          const Paragraph(
            'ListView 是最常用的可滚动列表。两种构建方式对应不同使用场景：\n\n'
            '① ListView(children: [...]) —— 一次性构建所有子组件\n'
            '  适用：少量固定列表项（< 20 项），如设置页。\n'
            '  缺点：所有项立即构建，长列表会卡顿。\n\n'
            '② ListView.builder —— 按需构建（懒加载）\n'
            '  适用：长列表、无限列表、数据量未知的场景。\n'
            '  原理：只构建屏幕上可见的项 + 少量缓冲区。滑动时回收离开屏幕的项。\n\n'
            '③ ListView.separated —— 带分隔线的 builder\n'
            '  适用：需要项之间分隔线的列表（如聊天列表）。\n\n'
            '性能优化：\n'
            '  • itemExtent: 固定项高度 → ListView 可跳过布局计算，滚动性能大幅提升\n'
            '  • prototypeItem: 提供一个样板块 → Flutter 自动测量高度\n'
            '  • addAutomaticKeepAlives: 是否缓存离开屏幕的 State（默认 true）',
          ),
          const CodeBlock(
            r'''// ── ListView(children) — 少量固定项 ──
ListView(
  padding: const EdgeInsets.all(16),
  children: [
    ListTile(leading: Icon(Icons.settings), title: Text('设置')),
    ListTile(leading: Icon(Icons.info), title: Text('关于')),
    ListTile(leading: Icon(Icons.logout), title: Text('退出')),
  ],
);

// ── ListView.builder — 高效长列表 ──
ListView.builder(
  itemCount: 1000,
  itemExtent: 60,  // 固定高度 → 高性能
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('$index')),
      title: Text('第 $index 项'),
    );
  },
);

// ── ListView.separated — 带分隔线 ──
ListView.separated(
  itemCount: 50,
  separatorBuilder: (_, __) => const Divider(height: 1),
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);

// ── 水平 ListView ──
SizedBox(
  height: 80,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 20,
    itemBuilder: (_, i) => Container(
      width: 80,
      margin: const EdgeInsets.all(4),
      color: Colors.blue,
      child: Center(child: Text('$i', style: TextStyle(color: Colors.white))),
    ),
  ),
);''',
            language: 'Dart',
          ),
          const TipBox(
            'ListView.builder 是生产环境中最常用的。itemExtent 设置固定高度可大幅提升滚动性能（Flutter 跳过测量步骤）。对于动态高度的列表项，不要设 itemExtent。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 15. GridView
          // ═══════════════════════════════════════
          const SectionHeader('15. GridView —— 网格布局', icon: Icons.grid_on),
          const Paragraph(
            'GridView 适合网格状布局。三种常用模式：\n\n'
            '① GridView.count —— 固定列数\n'
            '  crossAxisCount: 3 → 始终 3 列\n\n'
            '② GridView.extent —— 固定每项最大宽度，自动计算列数\n'
            '  maxCrossAxisExtent: 150 → 每项最大 150px，自动算列数（响应式友好）\n\n'
            '③ GridView.builder —— 懒加载网格（长列表）\n\n'
            'gridDelegate 参数控制网格布局规则：\n'
            '  • SliverGridDelegateWithFixedCrossAxisCount（固定列数）\n'
            '  • SliverGridDelegateWithMaxCrossAxisExtent（固定最大宽度）\n'
            '  • childAspectRatio —— 宽高比（1.0 = 正方形，0.5 = 宽是高的两倍）',
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8, mainAxisSpacing: 8,
              childAspectRatio: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(8, (i) {
                const colors = [
                  Colors.red, Colors.blue, Colors.green, Colors.orange,
                  Colors.purple, Colors.teal, Colors.pink, Colors.amber,
                ];
                return Container(
                  decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('$i', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                );
              }),
            ),
          ),
          const OutputBox('GridView.count(crossAxisCount: 4) → 固定 4 列网格。childAspectRatio: 1.0 → 正方形。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 16. Wrap
          // ═══════════════════════════════════════
          const SectionHeader('16. Wrap —— 流式布局', icon: Icons.wrap_text),
          const Paragraph(
            'Wrap 让子组件在一行（列）放不下时自动换行（换列）。比 Row/Column 更智能，适合标签、筛选栏等场景。\n\n'
            '核心参数：\n'
            '  • direction: Axis —— 主轴方向（水平 horizontal 或垂直 vertical）\n'
            '  • alignment: WrapAlignment —— 主轴对齐方式\n'
            '  • spacing: double —— 主轴间距\n'
            '  • runAlignment: WrapAlignment —— 交叉轴对齐方式\n'
            '  • runSpacing: double —— 交叉轴间距\n'
            '  • crossAxisAlignment: WrapCrossAlignment —— 子组件在交叉轴的对齐\n'
            '  • textDirection / verticalDirection —— 方向控制\n\n'
            '使用场景：标签云、商品标签筛选、工具栏按钮组、多列流式表单。',
          ),
          const CodeBlock(
            r'''Wrap(
  direction: Axis.horizontal,
  alignment: WrapAlignment.start,
  spacing: 8,    // 水平间距
  runSpacing: 8,  // 垂直间距
  children: [
    Chip(label: Text('Flutter')),
    Chip(label: Text('Dart')),
    Chip(label: Text('Widget')),
    Chip(label: Text('State')),
    Chip(label: Text('BuildContext')),
    Chip(label: Text('Provider')),
    Chip(label: Text('Material 3')),
  ],
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          const Text('拖动滑块改变容器宽度，观察自动换行效果：', style: TextStyle(fontSize: 13)),
          Slider(value: _sliderW, min: 100, max: 350, divisions: 25, label: '${_sliderW.toInt()}px', onChanged: (v) => setState(() => _sliderW = v)),
          Container(
            width: _sliderW,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                'Flutter', 'Dart', 'Widget', 'State', 'BuildContext', 'Provider',
                'Material 3', 'Animation', 'Theme', 'Navigation',
              ].map((label) => ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: _wrapSelected == label.hashCode % 100,
                onSelected: (_) => setState(() => _wrapSelected = label.hashCode % 100),
              )).toList(),
            ),
          ),
          const OutputBox('宽度越小，换行越多。Wrap 自动处理子组件的流向和换行——比 Row 更适合动态内容。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 17. Table
          // ═══════════════════════════════════════
          const SectionHeader('17. Table —— 表格布局', icon: Icons.table_chart),
          const Paragraph(
            'Table 提供经典的表格布局。与 Row/Column 嵌套不同，Table 能保证每一列的宽度对齐。\n\n'
            '核心参数：\n'
            '  • columnWidths: Map<int, TableColumnWidth> —— 每列的宽度\n'
            '  • defaultColumnWidth: TableColumnWidth —— 默认列宽\n'
            '  • border: TableBorder —— 表格边框\n'
            '  • defaultVerticalAlignment: TableCellVerticalAlignment —— 单元格垂直对齐\n'
            '  • textDirection / textBaseline —— 方向控制\n\n'
            '列宽类型：\n'
            '  • FixedColumnWidth(double) —— 固定像素宽\n'
            '  • FlexColumnWidth(int) —— 按比例分配剩余空间\n'
            '  • IntrinsicColumnWidth() —— 按内容自适应\n'
            '  • FractionColumnWidth(double) —— 占表格宽度的比例',
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Table(
              border: TableBorder.all(color: Colors.grey[200]!, borderRadius: BorderRadius.circular(12)),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue[50]),
                  children: const [
                    Padding(padding: EdgeInsets.all(12), child: Text('名称', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('数量', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('价格', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...['苹果', '香蕉', '橙子'].map((name) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(name)),
                    const Padding(padding: EdgeInsets.all(12), child: Text('1')),
                    Padding(padding: const EdgeInsets.all(12), child: Text('¥${(name.hashCode % 20 + 5.0).toStringAsFixed(1)}')),
                  ],
                )),
              ],
            ),
          ),
          const OutputBox('FlexColumnWidth 按比例分配列宽（2:1:1）。Table 保证跨行的列对齐——Row 嵌套做不到。'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 18. Widget 选择决策树
          // ═══════════════════════════════════════
          const SectionHeader('18. Widget 选择决策树', icon: Icons.account_tree),
          const Paragraph(
            '面对一个 UI 需求，应该用哪个 Widget？按以下流程判断：\n\n'
            '需要布局？→ 是 → 线性排列？→ Row / Column\n'
            '                → 层叠？→ Stack\n'
            '                → 网格？→ GridView\n'
            '                → 自动换行？→ Wrap\n'
            '                → 列对齐？→ Table\n\n'
            '需要滚动？→ 是 → 少量固定项？→ ListView(children)\n'
            '                → 大量/无限？→ ListView.builder\n'
            '                → 横向滚动？→ ListView(scrollDirection: Axis.horizontal)\n\n'
            '需要装饰？→ 背景/圆角/阴影/边框？→ 只是装饰？→ DecoratedBox\n'
            '                → 还要尺寸/间距？→ Container\n\n'
            '需要间距？→ 只要间距？→ SizedBox\n'
            '             → 还要背景？→ Container\n'
            '             → 内边距？→ Padding\n\n'
            '需要交互？→ 水波纹？→ InkWell\n'
            '             → 复杂手势？→ GestureDetector\n'
            '             → 按钮语义？→ ElevatedButton/FilledButton\n\n'
            '需要显示：文字 → Text | 图片 → Image | 图标 → Icon | 列表 → ListTile',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 练习
          // ═══════════════════════════════════════
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 Text.rich 实现一段包含"红色关键词"和"可点击蓝色链接"的富文本\n'
            '2. 用 Row + Expanded 实现三栏等宽布局，每栏颜色不同\n'
            '3. 用 Stack + Positioned 实现微信聊天样式：头像 + 红色未读角标 + 绿色在线状态点\n'
            '4. 用 GestureDetector 实现可拖动的小方块（onPanUpdate + Transform.translate）\n'
            '5. 用 GridView.extent 实现响应式网格（手机 2 列，平板 4 列）\n'
            '6. 用 Wrap + Chip 实现标签选择器（可多选，选中高亮）\n'
            '7. 用 Table 实现一个带表头的成绩单表格\n'
            '8. 用 ListView.builder + itemExtent 实现高性能的 1000 项列表',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
