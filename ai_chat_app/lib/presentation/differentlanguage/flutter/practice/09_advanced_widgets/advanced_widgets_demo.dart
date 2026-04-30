import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第九章：高级 Widget
class AdvancedWidgetsDemo extends StatefulWidget {
  const AdvancedWidgetsDemo({super.key});
  @override
  State<AdvancedWidgetsDemo> createState() => _AdvancedWidgetsDemoState();
}

class _AdvancedWidgetsDemoState extends State<AdvancedWidgetsDemo> {
  // ── 表单 ──
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  bool _obscure = true;
  String _formStatus = '等待输入...';

  // ── 响应式 ──
  double _sliderW = 200;

  // ── 手势 ──
  double _dx = 0, _dy = 0;
  String _gestureInfo = '拖动下面的方块试试';
  int _tapCount = 0;
  String _gestureEvent = '等待手势...';

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _emailCtl.dispose(); _pwdCtl.dispose(); super.dispose(); }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _formStatus = '验证通过！邮箱: ${_emailCtl.text}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证通过！'), backgroundColor: Colors.green));
    } else {
      setState(() => _formStatus = '验证未通过');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('第9章 · 高级 Widget'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph('① Form/TextFormField  ② AlertDialog/BottomSheet/SnackBar  '
              '③ CustomPaint/CustomPainter  ④ LayoutBuilder/MediaQuery/SafeArea  '
              '⑤ GestureDetector/InteractiveViewer'),
          const DividerLine(),

          // ── 1. 表单验证 ──
          const SectionHeader('1. Form —— 表单验证', icon: Icons.assignment),
          const Paragraph('核心组件：GlobalKey<FormState> 表单身份证、TextFormField.validator 校验器、'
              'autovalidateMode 验证时机（never/onUserInteraction/always）、onSaved 通过后保存。'
              'TextEditingController 管理输入文本，可 addListener 监听实时变化。'),
          const CodeBlock(
            r'''final _formKey = GlobalKey<FormState>();
final _emailCtl = TextEditingController();

@override
void initState() {
  super.initState();
  _emailCtl.addListener(() => print('输入: ${_emailCtl.text}'));
}

Form(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(children: [
    TextFormField(
      controller: _emailCtl,
      decoration: const InputDecoration(labelText: '邮箱'),
      validator: (v) {
        if (v == null || v.isEmpty) return '必填';
        if (!v.contains('@')) return '需要 @';
        return null;  // null = 验证通过
      },
      onSaved: (v) => print('保存: $v'),
    ),
    ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          // 提交
        }
      },
      child: const Text('提交'),
    ),
  ]),
);

// 手动重置
_formKey.currentState!.reset();
_emailCtl.clear();''',
            language: 'Dart'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
            child: Form(key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction, child: Column(children: [
              TextFormField(controller: _emailCtl,
                decoration: const InputDecoration(labelText: '邮箱', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) { if (v == null || v.isEmpty) return '请输入邮箱'; if (!v.contains('@')) return '需要 @'; return null; },
                onSaved: (v) => print('保存邮箱: $v'),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _pwdCtl, obscureText: _obscure,
                decoration: InputDecoration(labelText: '密码（至少6位）', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                ),
                validator: (v) { if (v == null || v.isEmpty) return '请输入密码'; if (v.length < 6) return '至少6位'; return null; },
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('提交'))),
            ])),
          ),
          const SizedBox(height: 8),
          OutputBox('$_formStatus\n输入后移开焦点触发验证（autovalidateMode: onUserInteraction）。'),
          const TipBox('validator 返回 null=通过，返回字符串=错误提示。onSaved 在 validate() 通过后调用。', type: TipType.tip),

          // ── 2. 弹窗 ──
          const DividerLine(),
          const SectionHeader('2. 弹窗体系 —— Dialog / BottomSheet / SnackBar', icon: Icons.quiz_outlined),
          const Paragraph('三种弹窗适用不同场景：\n'
              '🔹 AlertDialog（showDialog）：居中阻断操作，适合重要确认（删除、协议）\n'
              '🔸 BottomSheet（showModalBottomSheet）：底部滑入，适合选项菜单\n'
              '🔹 SnackBar：底部临时提示自动消失，适合操作反馈（已保存、已删除）\n'
              'UX 原则：越重要越"重"（阻断），越轻量越"轻"（自动消失）。'),
          const CodeBlock(
            r'''// AlertDialog
showDialog(
  context: context,
  barrierDismissible: true,       // 点外部关闭
  builder: (ctx) => AlertDialog(
    title: const Text('提示'),
    content: const Text('确定删除？'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
      TextButton(onPressed: () { Navigator.pop(ctx); deleteItem(); },
        child: const Text('删除')),
    ],
  ),
);

// Modal BottomSheet + DraggableScrollableSheet
showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  isScrollControlled: true,
  builder: (ctx) => DraggableScrollableSheet(
    initialChildSize: 0.35,
    minChildSize: 0.15,
    maxChildSize: 0.6,
    expand: false,
    builder: (ctx, scrollCtl) => Column(children: [
      ListTile(leading: Icon(Icons.share), title: Text('分享')),
      ListTile(leading: Icon(Icons.edit), title: Text('编辑')),
      ListTile(leading: Icon(Icons.delete), title: Text('删除')),
    ]),
  ),
);

// SnackBar（轻量反馈）
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('操作成功'),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(label: '撤销', onPressed: () => undo()),
    duration: const Duration(seconds: 3),
  ),
);''',
            language: 'Dart'),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: () => _showAlert(context), icon: const Icon(Icons.warning), label: const Text('AlertDialog')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: () => _showSheet(context), icon: const Icon(Icons.vertical_align_bottom), label: const Text('BottomSheet')),
          ]),
          const OutputBox('AlertDialog 阻断操作需回应。BottomSheet 底部滑入，可手势滑动关闭。'),
          const TipBox('UX 选择：操作确认→AlertDialog，选项列表→BottomSheet，操作反馈→SnackBar。', type: TipType.info),

          // ── 3. CustomPaint ──
          const DividerLine(),
          const SectionHeader('3. CustomPaint —— 自定义绘图', icon: Icons.brush),
          const Paragraph('CustomPaint（画板）+ CustomPainter（画家）+ Canvas（画笔）。Canvas 核心方法：\n'
              'drawCircle（圆）、drawLine（线）、drawRect（矩形）、drawPath（路径/贝塞尔）、'
              'drawArc（弧/扇形）、drawImage（图片）。Paint 控制样式：color、strokeWidth、'
              'style（fill/stroke）、shader（渐变）、blendMode（混合模式）。'),
          const CodeBlock(
            r'''class MyPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = Colors.blue..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.red
      ..style = PaintingStyle.stroke..strokeWidth = 3;

    // 渐变
    final gradientPaint = Paint()..shader = LinearGradient(
      colors: [Colors.orange, Colors.red],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(Offset(50, 50), 40, fillPaint);
    canvas.drawRect(Rect.fromLTWH(100, 10, 80, 80), strokePaint);

    // 路径（三角形）
    final path = Path()
      ..moveTo(10, 150)..lineTo(50, 100)..lineTo(90, 150)..close();
    canvas.drawPath(path, gradientPaint);

    // 弧（扇形）
    canvas.drawArc(Rect.fromCircle(center: Offset(150, 150), radius: 40),
      0, 1.5, true, fillPaint);

    canvas.drawLine(Offset(0, 0), Offset(200, 200), strokePaint);
  }
  bool shouldRepaint(old) => false;
}''',
            language: 'Dart'),
          Center(child: Container(width: 200, height: 200,
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
            child: const CustomPaint(painter: _SmileyPainter()),
          )),
          const SizedBox(height: 8),
          const OutputBox('笑脸纯代码绘制：drawCircle（脸+眼）+ drawArc（嘴）。Canvas API 可做任意图形。'),
          const TipBox('shouldRepaint 返回 true 导致每次 setState 都重绘。内容不变时返回 false 提升性能。', type: TipType.tip),

          // ── 4. 响应式布局 ──
          const DividerLine(),
          const SectionHeader('4. LayoutBuilder / MediaQuery / SafeArea', icon: Icons.phone_iphone),
          const Paragraph('三个响应式工具解决不同层面适配：\n'
              '🔹 MediaQuery：读取屏幕信息（size、padding、orientation、textScaleFactor）\n'
              '🔸 LayoutBuilder：读取父容器约束（maxWidth/maxHeight/minWidth/minHeight）\n'
              '🔹 SafeArea：避开刘海/状态栏/底部导航条（本质是用 MediaQuery.padding 做 Padding）'),
          const CodeBlock(
            r'''// MediaQuery（全局屏幕信息）
final mq = MediaQuery.of(context);
final w = mq.size.width;        // 屏幕宽度
final h = mq.size.height;       // 屏幕高度
final ori = mq.orientation;     // portrait / landscape
final scale = mq.textScaleFactor; // 系统字体缩放
final topPad = mq.padding.top;   // 状态栏高度
final bottomPad = mq.padding.bottom; // 手势指示条

if (w > 600) return WideLayout(); else return NarrowLayout();

// LayoutBuilder（父容器约束）
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return Row(children: [Sidebar(), Content()]);
    } else {
      return Column(children: [Header(), Content()]);
    }
  },
);

// SafeArea（避开系统 UI）
SafeArea(
  top: true, bottom: false,  // 底部不避开（延伸到导航条）
  child: Column(children: [/* 内容自动避开 notch/status bar */]),
);''',
            language: 'Dart'),
          const Paragraph('拖动滑块改变容器宽度，观察 LayoutBuilder 的响应：'),
          Slider(value: _sliderW, min: 100, max: 400, divisions: 30,
            label: '${_sliderW.toInt()}px', onChanged: (v) => setState(() => _sliderW = v)),
          Container(width: _sliderW, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
            child: LayoutBuilder(builder: (c, constraints) {
              final wide = constraints.maxWidth > 250;
              return Column(children: [
                Icon(wide ? Icons.weekend : Icons.phone_iphone, size: 32, color: Colors.blue),
                Text(wide ? '宽屏模式' : '窄屏模式', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (wide) Text('宽度: ${constraints.maxWidth.toStringAsFixed(0)}px', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ]);
            }),
          ),
          const SizedBox(height: 8),
          const OutputBox('宽度 > 250px 显示宽屏内容，< 250px 显示精简内容。LayoutBuilder 基于父容器约束。'),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('当前设备信息：', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('屏幕: ${mq.size.width.toStringAsFixed(0)} x ${mq.size.height.toStringAsFixed(0)}  '
                  '方向: ${mq.orientation == Orientation.portrait ? "竖屏" : "横屏"}  字体倍率: ${mq.textScaleFactor.toStringAsFixed(1)}x',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              Text('顶部安全区: ${mq.padding.top.toStringAsFixed(0)}px  底部安全区: ${mq.padding.bottom.toStringAsFixed(0)}px',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ]),
          ),
          const TipBox('MediaQuery 读全屏信息，LayoutBuilder 读父容器约束（已被 Padding 削减后的宽度）。SafeArea 本质是用 MediaQuery.padding 做 Padding。', type: TipType.tip),

          // ── 5. 手势检测 ──
          const DividerLine(),
          const SectionHeader('5. GestureDetector / InteractiveViewer', icon: Icons.touch_app),
          const Paragraph('GestureDetector 支持：onTap（单击）、onDoubleTap（双击）、onLongPress（长按）、'
              'onPanUpdate（拖动）、onScaleUpdate（缩放）。InteractiveViewer 封装了缩放和拖动，可直接实现捏合缩放。'
              'InkWell 有涟漪效果适合按钮，GestureDetector 功能更全面。'),
          const CodeBlock(
            r'''// GestureDetector
GestureDetector(
  onTap: () => print('单击'),
  onDoubleTap: () => print('双击'),
  onLongPress: () => print('长按'),
  onPanUpdate: (d) => setState(() => offset += d.delta),
  onScaleUpdate: (d) => setState(() => scale = d.scale),
  child: Container(width: 100, height: 100, color: Colors.blue),
);

// InteractiveViewer（一键缩放平移）
InteractiveViewer(
  minScale: 0.5,
  maxScale: 4.0,
  constrained: false,
  boundaryMargin: const EdgeInsets.all(100),
  child: Image.asset('assets/map.png'),
);

// 自定义控制器
InteractiveViewer(
  transformationController: TransformationController(),
  minScale: 1.0, maxScale: 5.0,
  child: Container(
    width: 300, height: 300,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
    ),
    child: const Center(child: Text('捏合缩放我')),
  ),
);''',
            language: 'Dart'),
          Center(child: GestureDetector(
            onPanUpdate: (d) { setState(() { _dx += d.delta.dx; _dy += d.delta.dy; _gestureInfo = '位置 (${_dx.toStringAsFixed(0)}, ${_dy.toStringAsFixed(0)})'; _gestureEvent = '拖动中'; }); },
            onDoubleTap: () => setState(() { _dx = 0; _dy = 0; _gestureInfo = '双击重置到原点！'; _gestureEvent = '双击'; }),
            onTap: () => setState(() { _tapCount++; _gestureInfo = '第 $_tapCount 次单击'; _gestureEvent = '单击'; }),
            onLongPress: () => setState(() { _gestureInfo = '长按触发！'; _gestureEvent = '长按'; }),
            child: Transform.translate(offset: Offset(_dx, _dy), child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8)]),
              child: const Center(child: Text('拖我', style: TextStyle(color: Colors.white, fontSize: 16))),
            )),
          )),
          const SizedBox(height: 8),
          OutputBox('事件: $_gestureEvent\n$_gestureInfo\n拖动：移动  双击：重置  单击：计数  长按：触发'),

          // InteractiveViewer 演示
          const SectionHeader('🧪 InteractiveViewer 演示', icon: Icons.pan_tool),
          const Paragraph('InteractiveViewer 内置平移和缩放手势。下面方块可双指缩放和单指拖动（模拟器用 Ctrl+点击模拟双指）。'),
          Container(height: 200,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: InteractiveViewer(
              minScale: 0.5, maxScale: 4.0, constrained: false, boundaryMargin: const EdgeInsets.all(50),
              child: Center(child: Container(width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.pink], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('缩放我', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              )),
            )),
          ),
          const OutputBox('双指捏合缩放（Ctrl+点击模拟双指）。InteractiveViewer 自动处理手势冲突。'),
          const TipBox('GestureDetector vs InkWell：GestureDetector 功能更全（双击/长按/拖动/缩放），InkWell 有涟漪效果适合按钮场景。', type: TipType.info),

          const DividerLine(),
          const SectionHeader('📝 本章核心概念', icon: Icons.summarize),
          const Paragraph('🔹 Form = 表单容器，GlobalKey 连接验证逻辑\n'
              '🔸 弹窗三兄弟：AlertDialog（阻断）> BottomSheet（轻量）> SnackBar（一闪而过）\n'
              '🔹 CustomPaint + CustomPainter = 画板 + 画家，Canvas 是画笔\n'
              '🔸 MediaQuery = 屏幕信息，LayoutBuilder = 父容器约束，SafeArea = 避让安全区\n'
              '🔹 GestureDetector = 全能手势检测，InteractiveViewer = 一键缩放'),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph('1. 给表单加「确认密码」字段，验证两次密码一致\n'
              '2. 用 CustomPaint 画柱状图（drawRect）和折线图（drawPath）\n'
              '3. 用 LayoutBuilder + MediaQuery 实现响应式卡片网格（手机1列/平板2列）\n'
              '4. 用 GestureDetector 实现画板：手指滑动在 Canvas 上画线\n'
              '5. 用 InteractiveViewer 实现图片查看器：pinch-to-zoom + 双击放大'),
          const TipBox('双指缩放用 onScaleUpdate 而非 onPanUpdate。details.scale 获取比例，details.focalPoint 获取焦点。InteractiveViewer 更推荐。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAlert(BuildContext ctx) => showDialog(context: ctx, barrierDismissible: true, builder: (c) => AlertDialog(
    title: const Row(children: [Icon(Icons.info_outline, color: Colors.blue), SizedBox(width: 8), Text('提示')]),
    content: const Text('AlertDialog：用于重要提示或确认操作。\n点击外部可关闭（barrierDismissible: true）。'),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
      TextButton(onPressed: () { Navigator.pop(c); ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('已确认！'))); }, child: const Text('确定'))],
  ));

  void _showSheet(BuildContext ctx) => showModalBottomSheet(context: ctx,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    isScrollControlled: true,
    builder: (c) => DraggableScrollableSheet(
      initialChildSize: 0.35, minChildSize: 0.15, maxChildSize: 0.6, expand: false,
      builder: (ctx, scrollCtl) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('选择操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(leading: const Icon(Icons.share, color: Colors.blue), title: const Text('分享'), subtitle: const Text('分享到社交媒体'), onTap: () => Navigator.pop(c)),
        ListTile(leading: const Icon(Icons.edit, color: Colors.green), title: const Text('编辑'), subtitle: const Text('修改内容'), onTap: () => Navigator.pop(c)),
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('删除'), subtitle: const Text('永久删除'), onTap: () => Navigator.pop(c)),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

// ── Smiley CustomPainter ──
class _SmileyPainter extends CustomPainter {
  const _SmileyPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;

    // 脸（黄色填充圆）
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFC107)..style = PaintingStyle.fill);

    // 眼睛（两个棕色小圆）
    final eyePaint = Paint()..color = const Color(0xFF795548)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx - 25, c.dy - 15), 6, eyePaint);
    canvas.drawCircle(Offset(c.dx + 25, c.dy - 15), 6, eyePaint);

    // 嘴（棕色弧形，stroke 模式）
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 10), width: 50, height: 30),
      0, 3.14, false,
      Paint()..color = const Color(0xFF795548)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round,
    );

    // 腮红（半透明粉色圆）
    final blush = Paint()..color = const Color(0x33FF4081)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx - 35, c.dy + 5), 8, blush);
    canvas.drawCircle(Offset(c.dx + 35, c.dy + 5), 8, blush);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
