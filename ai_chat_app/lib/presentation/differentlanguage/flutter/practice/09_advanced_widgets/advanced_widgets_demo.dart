import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第九章：高级 Widget 完全指南
/// 涵盖：表单验证、弹窗体系、自定义绘制、响应式布局、手势系统
/// ============================================================

class AdvancedWidgetsDemo extends StatefulWidget {
  const AdvancedWidgetsDemo({super.key});
  @override
  State<AdvancedWidgetsDemo> createState() => _AdvancedWidgetsDemoState();
}

class _AdvancedWidgetsDemoState extends State<AdvancedWidgetsDemo> {
  // ── 表单状态 ──
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _confirmPwdCtl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _formStatus = '等待输入...';
  AutovalidateMode _validateMode = AutovalidateMode.onUserInteraction;
  bool _agreeTerms = false;

  // ── 响应式 ──
  double _sliderW = 200;

  // ── 手势 ──
  double _dx = 0, _dy = 0;
  String _gestureInfo = '拖动下面的方块试试';
  int _tapCount = 0;
  String _gestureEvent = '等待手势...';
  double _scale = 1.0;
  double _rotation = 0.0;

  // ── 自定义绘制 ──
  double _smileLevel = 0.5; // 0=难过, 1=开心
  Color _paintColor = Colors.blue;

  // ── 弹出菜单选择 ──
  String _selectedFruit = '未选择';

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _confirmPwdCtl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _formStatus = '验证通过！邮箱: ${_emailCtl.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证通过！'), backgroundColor: Colors.green),
      );
    } else {
      setState(() => _formStatus = '验证未通过，请检查红色提示');
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _emailCtl.clear();
    _pwdCtl.clear();
    _confirmPwdCtl.clear();
    setState(() {
      _agreeTerms = false;
      _formStatus = '表单已重置';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('第9章 · 高级 Widget'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════
          // 章节目录
          // ═══════════════════════════════════════
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① Form 表单验证 —— 从基础到高级\n'
            '② TextFormField 深度解析 —— 每个属性的作用\n'
            '③ 弹窗体系 —— AlertDialog / BottomSheet / SnackBar / 自定义弹窗\n'
            '④ CustomPaint 自定义绘制 —— Canvas API 完全指南\n'
            '⑤ LayoutBuilder / MediaQuery / SafeArea —— 响应式三剑客\n'
            '⑥ GestureDetector 手势系统 —— 从单击到缩放的完整手势\n'
            '⑦ InteractiveViewer —— 一键实现缩放平移\n'
            '⑧ 综合实战 —— 注册表单 + 签名画板',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 1. Form 表单系统深度解析
          // ═══════════════════════════════════════
          const SectionHeader('1. Form 表单系统深度解析', icon: Icons.assignment),
          const Paragraph(
            'Flutter 的表单系统由三个核心角色组成：\n\n'
            '① Form —— 表单容器，管理所有字段的验证状态\n'
            '  • key: GlobalKey<FormState> —— 表单的"身份证"，用于在外部调用 validate()/save()/reset()\n'
            '  • autovalidateMode —— 控制何时触发验证\n'
            '  • onChanged —— 任意字段变化时回调\n'
            '  • onWillPop —— 用户尝试返回时的拦截（可用于"有未保存更改"提示）\n\n'
            '② TextFormField —— 带验证功能的文本输入框\n'
            '  • validator —— 验证函数：(String?) → String?，返回 null 表示通过\n'
            '  • onSaved —— 验证通过后保存值的回调\n'
            '  • onFieldSubmitted —— 用户按回车/完成键时触发\n'
            '  • autovalidateMode —— 单独覆盖 Form 的验证时机\n'
            '  • initialValue —— 初始值（与 controller 互斥！）\n\n'
            '③ FormField<T> —— 通用表单字段基类，可创建自定义表单控件（如日期选择器、下拉框）',
          ),
          const CodeBlock(
            r'''// ── Form 的完整 API ──
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  // 验证时机（Material 3 推荐 onUserInteraction）
  autovalidateMode: AutovalidateMode.onUserInteraction,
  // 任意子字段变化时触发
  onChanged: () => print('表单有变化'),
  // 拦截返回操作
  onWillPop: () async {
    if (_hasUnsavedChanges) {
      final ok = await showDialog<bool>(context: context,
        builder: (c) => AlertDialog(
          title: const Text('放弃编辑？'),
          content: const Text('有未保存的更改，确定离开吗？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('离开')),
          ],
        ),
      );
      return ok ?? false;
    }
    return true;
  },
  child: Column(children: [
    // TextFormField 详解见下文
  ]),
);

// ── FormState 的关键方法 ──
_formKey.currentState!.validate();   // 触发所有字段的 validator，返回 bool
_formKey.currentState!.save();       // 触发所有字段的 onSaved
_formKey.currentState!.reset();      // 重置所有字段到 initialValue（不会清空 controller！）''',
            language: 'Dart',
          ),
          const TipBox(
            '重要区分：reset() 重置的是 initialValue，不会清空 TextEditingController。'
            '如果你用了 controller，必须手动 controller.clear()。这就是为什么项目中两者都调。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 2. TextFormField 深度解析
          // ═══════════════════════════════════════
          const SectionHeader('2. TextFormField 每个属性详解', icon: Icons.text_fields),
          const Paragraph(
            'TextFormField 继承自 TextField，拥有 TextField 的全部能力 + 表单验证能力。\n\n'
            '核心属性分类：\n\n'
            '📝 文本控制：\n'
            '  • controller —— TextEditingController，管理文本内容\n'
            '  • initialValue —— 初始值（与 controller 互斥，同时使用报错）\n'
            '  • onChanged —— 每次文本变化时回调，参数是当前文本\n'
            '  • onFieldSubmitted —— 用户提交时回调（按回车/完成）\n\n'
            '🎨 外观装饰：\n'
            '  • decoration —— InputDecoration，控制边框/标签/图标/错误提示等外观\n'
            '    - labelText —— 浮动标签文字\n'
            '    - hintText —— 占位提示（输入后消失）\n'
            '    - prefixIcon / suffixIcon —— 前后图标\n'
            '    - border —— 边框样式（OutlineInputBorder/UnderlineInputBorder）\n'
            '    - errorText —— 手动设置错误信息（不走 validator）\n'
            '    - helperText / counterText —— 帮助文字/计数器\n\n'
            '🔐 输入控制：\n'
            '  • keyboardType —— 键盘类型（text/number/email/phone/url/multiline）\n'
            '  • obscureText —— 是否隐藏文本（密码）\n'
            '  • maxLength —— 最大字符数\n'
            '  • maxLines / minLines —— 多行文本行数\n'
            '  • enabled —— 是否可编辑\n'
            '  • readOnly —— 只读（可选中复制但不可编辑）\n'
            '  • textInputAction —— 键盘右下角按钮（done/go/search/send/next）\n'
            '  • inputFormatters —— 输入过滤器（限制数字/长度/格式）\n\n'
            '✅ 验证：\n'
            '  • validator —— (String?) → String? 返回 null 通过\n'
            '  • onSaved —— (String?) → void 验证通过后保存\n'
            '  • autovalidateMode —— 该字段的验证时机',
          ),
          const CodeBlock(
            r'''// ── TextFormField 完整配置示例 ──
TextFormField(
  // 文本控制
  controller: _emailCtl,
  // initialValue: '默认值',  // ⚠️ 与 controller 互斥！

  // 键盘配置
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,  // 键盘显示"下一项"
  textCapitalization: TextCapitalization.none,  // 不自动大写

  // 外观
  decoration: InputDecoration(
    labelText: '邮箱地址',
    hintText: '请输入您的邮箱',
    prefixIcon: const Icon(Icons.email_outlined),
    suffixIcon: _emailCtl.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => _emailCtl.clear(),
          )
        : null,
    border: const OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    helperText: '我们将发送验证邮件到此地址',
    helperMaxLines: 2,
  ),

  // 验证
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return '邮箱不能为空';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '请输入有效的邮箱地址';
    }
    return null;  // null = 验证通过
  },

  // 保存
  onSaved: (value) {
    _savedEmail = value?.trim() ?? '';
  },

  // 实时监听
  onChanged: (value) {
    print('当前输入: $value');
  },

  // 提交
  onFieldSubmitted: (value) {
    // 自动跳到下一个字段（常用 pattern）
    FocusScope.of(context).nextFocus();
  },
);''',
            language: 'Dart',
          ),
          const TipBox(
            'controller 和 initialValue 只能二选一！如果你需要程序化控制文本（如清空、预设值），用 controller；如果只是给个默认值且不需要操作它，用 initialValue。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 3. 表单验证时机详解
          // ═══════════════════════════════════════
          const SectionHeader('3. AutovalidateMode —— 验证时机', icon: Icons.timer),
          const Paragraph(
            'AutovalidateMode 枚举控制表单何时触发字段验证。Material 3 推荐 onUserInteraction。\n\n'
            '① AutovalidateMode.disabled —— 永不自动验证，只有手动调用 validate() 才验证\n'
            '  适用：提交按钮触发的表单（传统 Web 表单模式）\n\n'
            '② AutovalidateMode.always —— 每次 rebuild 都验证\n'
            '  适用：需要即时反馈的表单，但性能开销大\n\n'
            '③ AutovalidateMode.onUserInteraction —— 用户交互后验证（Material 3 推荐）\n'
            '  行为：字段获得焦点 + 用户做过修改 + 失去焦点 → 触发验证\n'
            '  好处：不会一打开就满屏红字，只在用户"完成输入"后检查\n\n'
            '④ AutovalidateMode.onUnfocus —— 失去焦点时验证（仅 Material 2）\n'
            '  行为：任何字段失去焦点时触发所有字段验证',
          ),
          const CodeBlock(
            r'''// ── 验证时机对比 ──
// 全局设置（Form 级别）
Form(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: ...
);

// 单个字段覆盖（字段级别优先）
TextFormField(
  autovalidateMode: AutovalidateMode.always,  // 此字段总是验证
  validator: ...,
);

// 手动触发验证（如点击提交按钮）
void _submit() {
  // validate() 返回 true 表示所有字段通过
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();  // 通过后保存
    // 提交数据...
  } else {
    // 验证失败，红字已自动显示
    print('请修正错误后再提交');
  }
}

// 手动设置某个字段的错误（不经过 validator）
_formKey.currentState!.fields['email']?.didChange(_emailCtl.text);
// 或直接用 TextFormField 的 decoration.errorText 也可以控制''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 4. 交互演示：完整注册表单
          // ═══════════════════════════════════════
          const SectionHeader('🧪 交互演示：完整注册表单', icon: Icons.touch_app),
          const Paragraph(
            '下面是一个包含多种验证规则的注册表单。尝试：\n'
            '① 输入无效邮箱 → 失去焦点时触发错误\n'
            '② 密码少于6位 → 显示错误\n'
            '③ 两次密码不一致 → 显示密码不匹配\n'
            '④ 不勾选协议 → 提交按钮不可点击\n'
            '⑤ 切换验证模式 → 观察验证行为变化',
          ),
          // 验证模式切换
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('验证时机：', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('手动'),
                      selected: _validateMode == AutovalidateMode.disabled,
                      onSelected: (_) => setState(() => _validateMode = AutovalidateMode.disabled),
                    ),
                    ChoiceChip(
                      label: const Text('交互后'),
                      selected: _validateMode == AutovalidateMode.onUserInteraction,
                      onSelected: (_) => setState(() => _validateMode = AutovalidateMode.onUserInteraction),
                    ),
                    ChoiceChip(
                      label: const Text('总是'),
                      selected: _validateMode == AutovalidateMode.always,
                      onSelected: (_) => setState(() => _validateMode = AutovalidateMode.always),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 表单
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _validateMode,
              child: Column(children: [
                // 邮箱
                TextFormField(
                  controller: _emailCtl,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: 'example@mail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入邮箱';
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                  onSaved: (v) => print('邮箱: ${v?.trim()}'),
                ),
                const SizedBox(height: 16),
                // 密码
                TextFormField(
                  controller: _pwdCtl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: '密码（至少6位，含数字和字母）',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    helperText: '必须包含至少一个数字和一个字母',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请输入密码';
                    if (v.length < 6) return '密码至少6位';
                    if (!v.contains(RegExp(r'[0-9]'))) return '密码必须包含数字';
                    if (!v.contains(RegExp(r'[a-zA-Z]'))) return '密码必须包含字母';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 确认密码
                TextFormField(
                  controller: _confirmPwdCtl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请确认密码';
                    if (v != _pwdCtl.text) return '两次密码不一致';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 同意协议
                CheckboxListTile(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                  title: const Text('我已阅读并同意《用户协议》', style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 12),
                // 按钮
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetForm,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重置'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _agreeTerms ? _submit : null,
                      icon: const Icon(Icons.check),
                      label: const Text('注册'),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          OutputBox('$_formStatus\n\n提示：输入后移开焦点触发验证。密码要求：≥6位 + 含数字 + 含字母。确认密码需与密码一致。'),
          const TipBox(
            '生产环境的注册表单通常还需要：密码强度指示器（实时计算分数+颜色条）、防重复提交（loading 状态禁用按钮）、人机验证（验证码）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 5. 弹窗体系
          // ═══════════════════════════════════════
          const SectionHeader('5. 弹窗体系 —— Dialog / BottomSheet / SnackBar', icon: Icons.quiz_outlined),
          const Paragraph(
            'Flutter 提供四类弹窗，从重到轻依次为：\n\n'
            '🔴 FullScreenDialog —— 全屏页面，用于复杂表单（如编辑个人资料）\n'
            '🟠 AlertDialog —— 居中阻断弹窗，用于重要确认（删除、退出）\n'
            '🟡 BottomSheet —— 底部滑出面板，用于选项菜单（分享、排序）\n'
            '🟢 SnackBar —— 底部轻提示，自动消失，用于操作反馈（已保存）\n\n'
            '选择原则：操作越"重"（不可逆），弹窗越"重"（阻断性越强）。\n'
            '删除 = AlertDialog（阻断确认），排序 = BottomSheet（轻量选择），保存 = SnackBar（一闪而过）。',
          ),
          const CodeBlock(
            r'''// ── 1. AlertDialog（阻断确认）──
showDialog<String>(
  context: context,
  barrierDismissible: true,     // 点击遮罩是否关闭
  barrierColor: Colors.black54, // 遮罩颜色
  builder: (ctx) => AlertDialog(
    title: const Text('删除确认'),
    content: const Text('此操作不可撤销，确定删除吗？'),
    icon: const Icon(Icons.warning_amber, color: Colors.red, size: 40),
    actionsAlignment: MainAxisAlignment.spaceBetween,
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx, 'cancel'),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(ctx, 'confirm'),
        style: FilledButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('删除'),
      ),
    ],
  ),
).then((result) {
  if (result == 'confirm') {
    // 执行删除
  }
});

// ── 2. SimpleDialog（简单选项）──
showDialog<int>(
  context: context,
  builder: (ctx) => SimpleDialog(
    title: const Text('选择颜色'),
    children: ['红色', '绿色', '蓝色'].asMap().entries.map((e) =>
      SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, e.key),
        child: Text(e.value),
      ),
    ).toList(),
  ),
);

// ── 3. ModalBottomSheet（底部面板）──
showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,           // 允许全高
  isDismissible: true,                // 点击外部关闭
  enableDrag: true,                   // 手势下拉关闭
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (ctx) => DraggableScrollableSheet(
    initialChildSize: 0.4,            // 初始占屏幕 40%
    minChildSize: 0.2,                // 最小 20%
    maxChildSize: 0.8,                // 最大 80%
    expand: false,
    builder: (ctx, scrollCtl) => ListView(
      controller: scrollCtl,
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(width: 40, height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
        ),
        // 选项列表...
      ],
    ),
  ),
);

// ── 4. SnackBar（轻量反馈）──
ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()             // 隐藏当前
  ..showSnackBar(SnackBar(
    content: const Row(children: [
      Icon(Icons.check_circle, color: Colors.white, size: 18),
      SizedBox(width: 8),
      Text('保存成功'),
    ]),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () => _undo(),
    ),
  ));''',
            language: 'Dart',
          ),
          // 弹窗演示按钮
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => _showAlert(context),
              icon: const Icon(Icons.warning),
              label: const Text('AlertDialog'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showSheet(context),
              icon: const Icon(Icons.vertical_align_bottom),
              label: const Text('BottomSheet'),
            ),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => _showSimpleDialog(context),
              icon: const Icon(Icons.list),
              label: const Text('SimpleDialog'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showSnack(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('SnackBar'),
            ),
          ]),
          const SizedBox(height: 4),
          Text('已选择: $_selectedFruit', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 8),
          OutputBox('AlertDialog 阻断操作需用户回应。\n'
              'BottomSheet 底部滑入，可手势下拉关闭。\n'
              'SimpleDialog 选项列表弹窗。\n'
              'SnackBar 自动消失，适合操作反馈。'),
          const TipBox(
            '使用 showDialog 而非 showGeneralDialog 在绝大多数情况下已经足够。showGeneralDialog 提供更底层控制（自定义动画/位置），但一般不需要。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 6. CustomPaint
          // ═══════════════════════════════════════
          const SectionHeader('6. CustomPaint 自定义绘制', icon: Icons.brush),
          const Paragraph(
            'CustomPaint 是 Flutter 的"画板"，CustomPainter 是"画家"，Canvas 是"画笔"。\n\n'
            '核心类关系：CustomPaint（Widget）→ CustomPainter（绘制逻辑）→ Canvas（API）→ Paint（样式）\n\n'
            'Canvas 核心方法速查：\n'
            '  • drawCircle(Offset center, double radius, Paint) —— 画圆\n'
            '  • drawRect(Rect, Paint) —— 画矩形\n'
            '  • drawRRect(RRect, Paint) —— 画圆角矩形\n'
            '  • drawPath(Path, Paint) —— 画路径（最强大，可实现任意形状）\n'
            '  • drawLine(Offset p1, Offset p2, Paint) —— 画线\n'
            '  • drawArc(Rect, startAngle, sweepAngle, useCenter, Paint) —— 画弧/扇形\n'
            '  • drawOval(Rect, Paint) —— 画椭圆\n'
            '  • drawPoints(PointMode, List<Offset>, Paint) —— 画点集\n'
            '  • drawImage(Image, Offset, Paint) —— 画图片\n'
            '  • drawShadow(Path, Color, double, bool) —— 画阴影\n'
            '  • clipRect/clipRRect/clipPath —— 裁剪区域\n'
            '  • save/restore —— 保存/恢复画布状态\n'
            '  • translate/rotate/scale —— 画布变换\n\n'
            'Paint 核心属性：\n'
            '  • color —— 颜色\n'
            '  • style —— PaintingStyle.fill（填充） / PaintingStyle.stroke（描边）\n'
            '  • strokeWidth —— 线宽（stroke 模式）\n'
            '  • strokeCap —— 线端点（round/square/butt）\n'
            '  • strokeJoin —— 线连接处（round/miter/bevel）\n'
            '  • shader —— 渐变/纹理（LinearGradient/RadialGradient/SweepGradient）\n'
            '  • blendMode —— 混合模式（28种，如 multiply/screen/overlay）\n'
            '  • maskFilter —— 模糊效果（BlurStyle.normal/inner/outer/solid）\n'
            '  • imageFilter —— 图像滤镜\n'
            '  • isAntiAlias —— 抗锯齿（默认 true）',
          ),
          const Paragraph(
            'CustomPainter 生命周期：\n'
            '① 构造函数 → 创建画家\n'
            '② paint(Canvas, Size) → 每一帧调用，执行绘制\n'
            '③ shouldRepaint(old) → 判断是否需要重绘，返回 true 触发重绘\n'
            '④ 如果返回 false 且 Widget 没重建 → 缓存上次结果不重绘（性能优化）',
          ),
          const CodeBlock(
            r'''// ── CustomPainter 模板 ──
class MyPainter extends CustomPainter {
  final double progress;  // 外部传入参数

  MyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 画笔1：填充蓝色
    final fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // 画笔2：红色描边
    final strokePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // 画笔3：渐变色
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.orange, Colors.pink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // 画实心圆
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, fillPaint);

    // 画矩形(左上角x, 左上角y, 宽, 高)
    canvas.drawRect(const Rect.fromLTWH(10, 10, 80, 80), strokePaint);

    // 画圆角矩形
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 10, 80, 80),
        const Radius.circular(16),
      ),
      gradientPaint,
    );

    // 画弧（扇形，useCenter=true）
    canvas.drawArc(
      const Rect.fromLTWH(220, 10, 80, 80),
      0,           // 起始角度（弧度）
      1.5,         // 扫过角度（弧度）
      true,        // 是否连接到圆心
      fillPaint,
    );

    // 画线
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      strokePaint,
    );

    // 画路径（三角形 + 贝塞尔曲线）
    final path = Path()
      ..moveTo(50, 120)                          // 移到起点
      ..lineTo(100, 80)                          // 直线到
      ..lineTo(150, 120)                         // 直线到
      ..quadraticBezierTo(100, 200, 50, 120)    // 二次贝塞尔曲线
      ..close();                                 // 闭合路径
    canvas.drawPath(path, gradientPaint);

    // 画阴影
    final shadowPath = Path()..addOval(Rect.fromCircle(center: Offset(200, 150), radius: 30));
    canvas.drawShadow(shadowPath, Colors.black, 8, false);

    // 画文字
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Flutter', style: TextStyle(color: Colors.red, fontSize: 20)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(250, 130));
  }

  @override
  bool shouldRepaint(covariant MyPainter old) {
    // 只有 progress 变了才重绘
    return old.progress != progress;
  }
}

// 使用
CustomPaint(
  size: Size(350, 200),  // 指定画布大小
  painter: MyPainter(progress: 0.7),
  // foregroundPainter: ...,  // 前景画家（在 child 上面画）
  // child: ...,               // 子组件（在 painter 下面）
);''',
            language: 'Dart',
          ),
          const SizedBox(height: 8),
          // 交互：笑脸表情调节
          const SectionHeader('🧪 交互演示：心情调节笑脸', icon: Icons.mood),
          const Paragraph('拖动滑块改变笑脸心情（0=难过，1=开心），点击色块改变颜色：'),
          Row(children: [
            const Text('😢', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Slider(
                value: _smileLevel,
                onChanged: (v) => setState(() => _smileLevel = v),
              ),
            ),
            const Text('😄', style: TextStyle(fontSize: 20)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ...[Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red].map((c) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _paintColor = c),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: _paintColor == c ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: CustomPaint(
                painter: _MoodPainter(
                  mood: _smileLevel,
                  color: _paintColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const OutputBox(
            '拖动滑块改变嘴巴弧度（0=向下弧/难过，1=向上弧/开心）。\n'
            '点击色块改变脸部颜色。CustomPainter 接收外部参数实现动态绘制。',
          ),
          const TipBox(
            'shouldRepaint 返回 true 导致每次 setState 都重绘整个画布。内容不变时应返回 false——对比新旧参数，只有变了才重绘。这是 CustomPaint 性能优化的关键。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 7. 响应式布局
          // ═══════════════════════════════════════
          const SectionHeader('7. LayoutBuilder / MediaQuery / SafeArea', icon: Icons.phone_iphone),
          const Paragraph(
            '三个工具解决响应式布局的不同层面：\n\n'
            '🔹 MediaQuery —— "屏幕有多大？"—— 读设备全局信息\n'
            '  • MediaQuery.of(context).size —— 屏幕宽高（逻辑像素）\n'
            '  • MediaQuery.of(context).orientation —— 横竖屏\n'
            '  • MediaQuery.of(context).padding —— 系统 UI 侵入区域（刘海/状态栏/导航条）\n'
            '  • MediaQuery.of(context).textScaleFactor —— 系统字体缩放倍率\n'
            '  • MediaQuery.of(context).platformBrightness —— 系统亮暗模式\n'
            '  • MediaQuery.of(context).devicePixelRatio —— 设备像素比\n'
            '  • MediaQuery.of(context).viewInsets —— 键盘高度（软键盘弹出时 bottom 变大）\n\n'
            '🔸 LayoutBuilder —— "给我多少空间？"—— 读父容器约束\n'
            '  • constraints.maxWidth —— 父容器给的最大宽度\n'
            '  • constraints.maxHeight —— 父容器给的最大高度\n'
            '  • constraints.minWidth / minHeight —— 最小约束\n'
            '  • 关键区别：MediaQuery.size 是全屏尺寸，LayoutBuilder.constraints 是已被裁剪后的可用空间\n\n'
            '🔹 SafeArea —— "安全区域在哪里？"—— 自动避让系统 UI\n'
            '  • top: bool —— 避开顶部（刘海/状态栏）\n'
            '  • bottom: bool —— 避开底部（Home 指示条）\n'
            '  • left/right: bool —— 避开左右\n'
            '  • minimum: EdgeInsets —— 额外的最小内边距\n'
            '  • 本质：SafeArea = MediaQuery.of(context).padding + Padding\n\n'
            '三者区别一句话：\n'
            'MediaQuery 问设备 → LayoutBuilder 问父容器 → SafeArea 自动避让',
          ),
          const CodeBlock(
            r'''// ── MediaQuery 完整用法 ──
Widget build(BuildContext context) {
  final mq = MediaQuery.of(context);
  final screenWidth = mq.size.width;
  final screenHeight = mq.size.height;
  final isPortrait = mq.orientation == Orientation.portrait;
  final isDark = mq.platformBrightness == Brightness.dark;
  final topSafeArea = mq.padding.top;       // 状态栏/刘海高度
  final bottomSafeArea = mq.padding.bottom;  // 手势指示条高度
  final keyboardHeight = mq.viewInsets.bottom; // 键盘弹出高度
  final textScale = mq.textScaleFactor;     // 字体缩放倍数
  final pixelRatio = mq.devicePixelRatio;   // 物理像素/逻辑像素

  // 经典断点：手机/平板/桌面
  if (screenWidth < 600) return MobileLayout();
  if (screenWidth < 1024) return TabletLayout();
  return DesktopLayout();
}

// ── LayoutBuilder 完整用法 ──
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;
    final isConstrained = constraints.hasBoundedWidth;  // 是否有界

    // 响应式列数（网格）
    final cols = maxW > 900 ? 4 : maxW > 600 ? 3 : maxW > 400 ? 2 : 1;

    // 条件渲染
    if (maxW > 600) {
      return Row(children: [Sidebar(width: 200), Expanded(child: Content())]);
    }
    return Column(children: [Header(), Expanded(child: Content())]);
  },
);

// ── SafeArea 完整用法 ──
SafeArea(
  top: true,            // 避开顶部安全区
  bottom: true,         // 避开底部安全区
  left: false,          // 不避左右
  right: false,
  minimum: const EdgeInsets.all(8),  // 在安全区基础上再加 8px
  maintainBottomViewPadding: false,  // 键盘弹出时不调整
  child: Column(children: [...]),
);''',
            language: 'Dart',
          ),
          const Paragraph('拖动滑块改变容器宽度，观察 LayoutBuilder 的响应行为：'),
          Slider(
            value: _sliderW,
            min: 100, max: 400, divisions: 30,
            label: '${_sliderW.toInt()}px',
            onChanged: (v) => setState(() => _sliderW = v),
          ),
          const SizedBox(height: 8),
          Container(
            width: _sliderW,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: LayoutBuilder(
              builder: (c, constraints) {
                final wide = constraints.maxWidth > 250;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(wide),
                    children: [
                      Icon(wide ? Icons.weekend : Icons.phone_iphone, size: 32, color: Colors.blue),
                      Text(wide ? '宽屏模式' : '窄屏模式',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (wide)
                        Text('宽度: ${constraints.maxWidth.toStringAsFixed(0)}px\n'
                            '已切换到双列布局',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                        )
                      else
                        Text('宽度: ${constraints.maxWidth.toStringAsFixed(0)}px\n'
                            '单列紧凑布局',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const OutputBox('宽度 > 250px → 宽屏模式（图标变大，显示双列提示）\n宽度 ≤ 250px → 窄屏模式（紧凑布局，单列）'),
          const SizedBox(height: 8),
          // MediaQuery 信息展示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('当前设备信息（MediaQuery）：', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('屏幕尺寸: ${mq.size.width.toStringAsFixed(0)} × ${mq.size.height.toStringAsFixed(0)} 逻辑像素',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                Text('屏幕方向: ${mq.orientation == Orientation.portrait ? "竖屏" : "横屏"}  |  '
                    '像素比: ${mq.devicePixelRatio.toStringAsFixed(1)}x  |  '
                    '字体倍率: ${mq.textScaleFactor.toStringAsFixed(1)}x',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                Text('顶部安全区: ${mq.padding.top.toStringAsFixed(0)}px  |  '
                    '底部安全区: ${mq.padding.bottom.toStringAsFixed(0)}px  |  '
                    '键盘高度: ${mq.viewInsets.bottom.toStringAsFixed(0)}px',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
          const TipBox(
            'MediaQuery.size 是整屏大小，LayoutBuilder.constraints 是被父容器（如 AppBar、Padding）削减后的剩余空间。做布局决策时优先用 LayoutBuilder——它反映的是"你能用的空间"，不是"屏幕有多大"。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 8. GestureDetector
          // ═══════════════════════════════════════
          const SectionHeader('8. GestureDetector 手势系统', icon: Icons.touch_app),
          const Paragraph(
            'GestureDetector 是 Flutter 的手势检测器。支持完整的触摸事件体系：\n\n'
            '📌 基础手势（单一操作）：\n'
            '  • onTap —— 单击（手指按下 + 抬起，未移动）\n'
            '  • onDoubleTap —— 双击（两次快速点击）\n'
            '  • onLongPress —— 长按（按住超过 500ms）\n'
            '  • onSecondaryTap —— 右键/双指点击\n'
            '  • onTertiaryTap —— 三指点击\n\n'
            '📌 移动手势（持续追踪）：\n'
            '  • onPanStart / onPanUpdate / onPanEnd —— 单指拖动\n'
            '  • onHorizontalDragStart/Update/End —— 水平拖动\n'
            '  • onVerticalDragStart/Update/End —— 垂直拖动\n'
            '  • onScaleStart / onScaleUpdate / onScaleEnd —— 双指缩放（包含平移+缩放+旋转）\n\n'
            '📌 事件回调细节：\n'
            '  • onTapDown —— 手指按下时（TapDownDetails 含全局/本地坐标）\n'
            '  • onTapUp —— 手指抬起时\n'
            '  • onTapCancel —— 点击被取消（如滑动导致）\n'
            '  • onLongPressStart/onLongPressMove/onLongPressUp —— 长按的完整生命周期\n\n'
            '📌 高级配置：\n'
            '  • behavior —— HitTestBehavior（手势命中测试行为）\n'
            '    - deferToChild（默认）：只有子组件不处理时自己才处理\n'
            '    - opaque：自己总是处理（阻止事件向下传递）\n'
            '    - translucent：自己处理但不阻止向下传递\n'
            '  • excludeFromSemantics —— 是否从无障碍树排除\n'
            '  • dragStartBehavior —— DragStartBehavior.down（按下就拖）/ DragStartBehavior.start（移动才拖）',
          ),
          const CodeBlock(
            r'''// ── GestureDetector 常用模式 ──

// 模式1：点击 + 长按
GestureDetector(
  onTap: () => print('单击'),
  onDoubleTap: () => print('双击'),
  onLongPress: () => print('长按'),
  child: Container(width: 100, height: 100, color: Colors.blue),
);

// 模式2：拖动
GestureDetector(
  onPanUpdate: (details) {
    setState(() {
      _offset += details.delta;  // delta = 本次移动增量
    });
  },
  child: Transform.translate(offset: _offset, child: ...),
);

// 模式3：缩放 + 旋转（最常用）
GestureDetector(
  onScaleStart: (details) {
    _initialScale = _scale;
    _initialRotation = _rotation;
  },
  onScaleUpdate: (details) {
    setState(() {
      _scale = _initialScale * details.scale;
      _rotation = _initialRotation + details.rotation;
    });
  },
  child: Transform(
    transform: Matrix4.identity()
      ..scale(_scale)
      ..rotateZ(_rotation),
    child: ...
  ),
);

// 模式4：区分水平和垂直拖动
GestureDetector(
  onHorizontalDragUpdate: (d) => _x += d.delta.dx,
  onVerticalDragUpdate: (d) => _y += d.delta.dy,
  child: ...
);

// 模式5：带事件坐标的点击
GestureDetector(
  onTapDown: (d) => print('按下位置: ${d.localPosition}'),  // 相对组件
  onTapUp: (d) => print('抬起位置: ${d.globalPosition}'),   // 屏幕坐标
  child: ...
);''',
            language: 'Dart',
          ),
          const TipBox(
            'GestureDetector vs InkWell：GestureDetector 手势全面（双击/长按/拖动/缩放），InkWell 有涟漪效果 + 语义更好（无障碍）。按钮场景用 InkWell/ElevatedButton，自定义交互用 GestureDetector。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 9. 手势交互演示
          // ═══════════════════════════════════════
          const SectionHeader('🧪 交互演示：手势实验室', icon: Icons.pan_tool),
          const Paragraph('对下面的方块使用不同手势，观察事件变化：\n'
              '• 单击 → 计数  •  双击 → 重置  •  长按 → 触发\n'
              '• 拖动 → 移动  •  双指缩放 → 缩放+旋转'),
          Center(
            child: GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _dx += d.delta.dx;
                  _dy += d.delta.dy;
                  _gestureInfo = '位置 (${_dx.toStringAsFixed(0)}, ${_dy.toStringAsFixed(0)})';
                  _gestureEvent = '拖动中';
                });
              },
              onScaleUpdate: (d) {
                setState(() {
                  if (d.pointerCount >= 2) {
                    _scale = (_scale * d.scale).clamp(0.5, 3.0);
                    _rotation += d.rotation;
                    _gestureInfo = '缩放: ${_scale.toStringAsFixed(2)}x  旋转: ${(_rotation * 180 / 3.14159).toStringAsFixed(0)}°';
                    _gestureEvent = '双指缩放';
                  }
                });
              },
              onDoubleTap: () => setState(() {
                _dx = 0; _dy = 0; _scale = 1.0; _rotation = 0.0;
                _gestureInfo = '双击重置到原点！'; _gestureEvent = '双击';
              }),
              onTap: () => setState(() {
                _tapCount++;
                _gestureInfo = '第 $_tapCount 次单击';
                _gestureEvent = '单击';
              }),
              onLongPress: () => setState(() {
                _gestureInfo = '长按触发！';
                _gestureEvent = '长按';
              }),
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(_dx, _dy)
                  ..rotateZ(_rotation)
                  ..scale(_scale),
                alignment: Alignment.center,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8)],
                  ),
                  child: const Center(
                    child: Text('拖我', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutputBox('事件: $_gestureEvent\n$_gestureInfo\n\n'
              '拖动：移动方块 | 双击：重置位置和缩放\n'
              '单击：计数+1 | 长按：触发 | 双指：缩放+旋转'),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 10. InteractiveViewer
          // ═══════════════════════════════════════
          const SectionHeader('10. InteractiveViewer —— 一键缩放平移', icon: Icons.zoom_in),
          const Paragraph(
            'InteractiveViewer 是 GestureDetector + 缩放/平移逻辑的封装。内部自动处理双指缩放、单指拖动、边界限制。\n\n'
            '核心属性：\n'
            '  • minScale / maxScale —— 缩放范围（默认 0.8 ~ 2.5）\n'
            '  • scaleEnabled / panEnabled —— 是否允许缩放/平移\n'
            '  • constrained —— 是否限制在视口内（false 时内容可拖出视野）\n'
            '  • boundaryMargin —— 边界留白（constrained=false 时有意义）\n'
            '  • transformationController —— 控制器（可程序化控制缩放/平移/旋转）\n'
            '  • onInteractionStart/Update/End —— 交互回调\n'
            '  • alignPanAxis —— 是否对齐到水平/垂直拖动（false=自由拖动）\n'
            '  • panAxis —— PanAxis.horizontal/vertical/free/aligned（限制拖动方向）\n'
            '  • child —— 被缩放平移的内容\n\n'
            '适用场景：图片查看器、地图浏览、图表放大、PDF 阅读器',
          ),
          const CodeBlock(
            r'''// ── InteractiveViewer 基础用法 ──
InteractiveViewer(
  minScale: 0.5,
  maxScale: 4.0,
  constrained: false,        // 允许拖出视野
  boundaryMargin: const EdgeInsets.all(100), // 拖出 100px 边界
  child: Image.asset('assets/map.png'),
);

// ── 带控制器（程序化控制）──
final _controller = TransformationController();

// 重置
_controller.value = Matrix4.identity();

// 缩放到 2x
_controller.value = Matrix4.identity()..scale(2.0);

// 平移到 (100, 50)
_controller.value = Matrix4.identity()..translate(100.0, 50.0);

InteractiveViewer(
  transformationController: _controller,
  minScale: 0.1,
  maxScale: 10.0,
  onInteractionEnd: (details) {
    // 用户交互结束，可在此保存缩放位置
    print('最终缩放: ${_controller.value.getMaxScaleOnAxis()}');
  },
  child: child,
);''',
            language: 'Dart',
          ),
          const SectionHeader('🧪 交互演示', icon: Icons.pan_tool_alt),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(50),
                child: Center(
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: Text('缩放我', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const OutputBox('双指捏合缩放（模拟器用 Ctrl+点击模拟双指）。单指拖动平移。InteractiveViewer 自动处理手势冲突，不会和外部 ListView 滚动冲突。'),

          const DividerLine(),
          const SectionHeader('📝 本章核心概念', icon: Icons.summarize),
          const Paragraph(
            '🔹 Form = 表单容器，GlobalKey 连接外部操作。validator 返回 null=通过。\n'
            '🔸 TextFormField = TextField + 验证，controller 和 initialValue 互斥。\n'
            '🔹 验证时机：disabled(手动) / onUserInteraction(交互后,推荐) / always(总是)\n'
            '🔸 弹窗家族：AlertDialog(阻断确认) > BottomSheet(选项菜单) > SnackBar(操作反馈)\n'
            '🔹 CustomPaint：CustomPainter.paint() 每帧调用，shouldRepaint 控制重绘。\n'
            '🔸 Canvas 路径方法：moveTo→lineTo→quadraticBezierTo→close 构成 Path。\n'
            '🔹 MediaQuery = 设备信息，LayoutBuilder = 父容器约束，SafeArea = 系统UI避让。\n'
            '🔸 GestureDetector：onTap/onDoubleTap/onLongPress/onPanUpdate/onScaleUpdate。\n'
            '🔹 InteractiveViewer：一键缩放平移，封装了双指手势和边界限制。',
          ),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 在前面的注册表单中增加"用户名"字段（2-20位字母数字），并实现实时唯一性检查提示\n'
            '2. 用 CustomPaint 画饼图：三个扇形，每个不同颜色，用 drawArc 实现\n'
            '3. 用 LayoutBuilder + GridView 实现响应式网格：手机 2 列，平板 4 列\n'
            '4. 用 GestureDetector 实现可拖动排序列表（onPanUpdate + AnimatedContainer）\n'
            '5. 用 InteractiveViewer 实现图片查看器，支持双击放大到 2x，再双击恢复\n'
            '6. 实现一个自定义 FormField<DateTime>，用 DatePicker 作为输入控件\n'
            '7. 用 CustomPaint 画一个实时时钟（用 Timer 每秒更新角度，drawLine 做指针）',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── 弹窗方法 ──
  void _showAlert(BuildContext ctx) => showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (c) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.info_outline, color: Colors.blue), SizedBox(width: 8), Text('提示'),
      ]),
      content: const Text('AlertDialog：用于重要提示或确认操作。\n点击外部可关闭（barrierDismissible: true）。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            ScaffoldMessenger.of(c).showSnackBar(
              const SnackBar(content: Text('已确认！')),
            );
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );

  void _showSimpleDialog(BuildContext ctx) => showDialog(
    context: ctx,
    builder: (c) => SimpleDialog(
      title: const Text('选择水果'),
      children: [
        _FruitOption(label: '苹果', icon: Icons.apple, c: c),
        _FruitOption(label: '香蕉', icon: Icons.breakfast_dining, c: c),
        _FruitOption(label: '橙子', icon: Icons.local_drink, c: c),
        _FruitOption(label: '葡萄', icon: Icons.wine_bar, c: c),
      ],
    ),
  ).then((result) {
    if (result != null && mounted) {
      setState(() => _selectedFruit = result.toString());
    }
  });

  void _showSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (c) => DraggableScrollableSheet(
      initialChildSize: 0.35, minChildSize: 0.15, maxChildSize: 0.6, expand: false,
      builder: (ctx, scrollCtl) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('选择操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text('分享'),
            subtitle: const Text('分享到社交媒体'),
            onTap: () => Navigator.pop(c),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.green),
            title: const Text('编辑'),
            subtitle: const Text('修改内容'),
            onTap: () => Navigator.pop(c),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除'),
            subtitle: const Text('永久删除'),
            onTap: () => Navigator.pop(c),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  void _showSnack(BuildContext ctx) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('操作成功！'),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(label: '撤销', onPressed: () {}),
      ));
  }
}

// ── 心情画家 ──
class _MoodPainter extends CustomPainter {
  final double mood; // 0.0 = 难过, 1.0 = 开心
  final Color color;

  const _MoodPainter({required this.mood, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 脸（圆形填充）
    final facePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // 脸轮廓
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, strokePaint);

    // 眼睛（两个小圆）
    final eyePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 25, center.dy - 15), 6, eyePaint);
    canvas.drawCircle(Offset(center.dx + 25, center.dy - 15), 6, eyePaint);

    // 嘴巴：弧度随 mood 变化
    final mouthPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 从向下弧 (难过) 到向上弧 (开心)
    final startAngle = 3.14159 * 0.2 + mood * 3.14159 * 0.6; // 0.2π ~ 0.8π
    final sweepAngle = -3.14159 + mood * 2 * 3.14159; // -π 到 +π
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 10), width: 50, height: 30),
      startAngle,
      -sweepAngle,
      false,
      mouthPaint,
    );

    // 腮红（mood 高时更红）
    final blushColor = Color.lerp(
      color.withOpacity(0.05),
      Colors.pink.withOpacity(0.3),
      mood,
    )!;
    final blushPaint = Paint()
      ..color = blushColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 35, center.dy + 5), 10, blushPaint);
    canvas.drawCircle(Offset(center.dx + 35, center.dy + 5), 10, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _MoodPainter old) {
    return old.mood != mood || old.color != color;
  }
}

// ── 水果选项 ──
class _FruitOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final BuildContext c;
  const _FruitOption({required this.label, required this.icon, required this.c});

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(c, label),
      child: Row(children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 16)),
      ]),
    );
  }
}
