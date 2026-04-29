import 'package:flutter/material.dart';

/// ============================================================
/// 03_Flutter 框架类大全
/// 本文件详细介绍 Flutter 框架中所有核心类的定义及用法
/// 包含：定义说明、使用教程、代码示例、交互演示
/// 覆盖范围：Material组件、文本输入、图片图标、导航路由、
///          手势交互、异步数据、主题样式、核心框架类
/// ============================================================

class FrameworkClassesDemo extends StatelessWidget {
  const FrameworkClassesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 框架类大全'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: '一、Material Design 组件'),
          _Explainer(
            text: 'Material Design 是 Google 推出的设计语言。Flutter 提供了一套完整的 Material 组件，'
                '覆盖了 AppBar、按钮、卡片、对话框等常见 UI 元素。下面逐一介绍每个组件的定义和用法。',
          ),

          // ========== 1. AppBar ==========
          _WidgetTitle(title: '1. AppBar —— 顶部导航栏'),
          _Explainer(
            text: 'AppBar 是 Material 应用的顶部导航栏。'
                '包含 leading（左侧图标）、title（标题）、actions（右侧操作区）、'
                'bottom（底部 Tab 栏）等区域。'
                '通常作为 Scaffold 的 appBar 属性使用。',
          ),
          _CodeBlock(code: 'AppBar(\n'
              '  leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),\n'
              '  title: Text("页面标题"),\n'
              '  actions: [\n'
              '    IconButton(icon: Icon(Icons.search), onPressed: () {}),\n'
              '    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),\n'
              '  ],\n'
              '  bottom: TabBar(tabs: [Tab(text: "Tab1"), Tab(text: "Tab2")]),\n'
              '  backgroundColor: Colors.blue,\n'
              '  elevation: 4, // 阴影高度\n'
              '  centerTitle: true, // 标题居中\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                // 模拟 AppBar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: null),
                        const Expanded(child: Text('页面标题', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
                        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: null),
                        IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: null),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  color: Colors.white,
                  child: const Row(
                    children: [
                      Expanded(child: Center(child: Text('Tab 1', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue))),),
                      Expanded(child: Center(child: Text('Tab 2'))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _TipText(text: 'AppBar 支持 flexibleSpace（可伸缩背景）、bottom（TabBar）、自动返回按钮等特性。'),
          _DividerLine(),

          // ========== 2. Buttons ==========
          _WidgetTitle(title: '2. Button 家族 —— 按钮'),
          _Explainer(
            text: 'Flutter 提供了多种按钮组件，各自有不同的样式和用途：\n\n'
                '❶ ElevatedButton — 填充按钮，有背景色和阴影，最常用\n'
                '❷ TextButton — 文本按钮，无背景边框，适合次要操作\n'
                '❸ OutlinedButton — 边框按钮，有边框无背景\n'
                '❹ IconButton — 图标按钮，圆形点击区域\n'
                '❺ FloatingActionButton — 浮动按钮，Material 风格圆形突出按钮\n'
                '❻ CloseButton / BackButton — 关闭/返回专用按钮\n\n'
                '所有按钮都可以通过 styleFrom 或 style 参数自定义样式。',
          ),
          _CodeBlock(code: 'ElevatedButton(\n'
              '  onPressed: () {},\n'
              '  child: Text("填充按钮"),\n'
              ')\n'
              'TextButton(onPressed: () {}, child: Text("文本按钮"))\n'
              'OutlinedButton(onPressed: () {}, child: Text("边框按钮"))\n'
              'IconButton(icon: Icon(Icons.add), onPressed: () {})\n'
              'FloatingActionButton(onPressed: () {}, child: Icon(Icons.add))'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(onPressed: null, child: Text('禁用')),
                ElevatedButton(onPressed: null, child: Text('Elevated')),
                TextButton(onPressed: null, child: Text('TextButton')),
                OutlinedButton(onPressed: null, child: Text('Outlined')),
                IconButton(icon: Icon(Icons.favorite_border), onPressed: null),
                SizedBox(width: 56, height: 56,
                  child: FloatingActionButton.small(onPressed: null, child: Icon(Icons.add)),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 3. Card ==========
          _WidgetTitle(title: '3. Card —— 卡片'),
          _Explainer(
            text: 'Card 是 Material Design 的卡片组件，自带圆角、阴影和内边距。\n'
                '★ elevation — 阴影高度\n'
                '★ shape — 卡片形状（默认 RoundedRectangleBorder）\n'
                '★ margin — 外边距\n'
                '★ clipBehavior — 裁剪行为\n'
                '★ 内部通常放置 ListTile、Column、Image 等内容',
          ),
          _CodeBlock(code: 'Card(\n'
              '  elevation: 4,\n'
              '  shape: RoundedRectangleBorder(\n'
              '    borderRadius: BorderRadius.circular(16),\n'
              '  ),\n'
              '  child: Padding(\n'
              '    padding: EdgeInsets.all(16),\n'
              '    child: Text("卡片内容"),\n'
              '  ),\n'
              ')'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('elevation: 2', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.star, size: 48, color: Colors.amber[400]),
                        const SizedBox(height: 8),
                        Text('圆角16 elevation:8', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _DividerLine(),

          // ========== 4. NavigationBar / BottomNavigationBar ==========
          _WidgetTitle(title: '4. NavigationBar / BottomNavigationBar —— 底部导航'),
          _Explainer(
            text: '底部导航栏用于在应用的几个主要页面之间切换。\n\n'
                '❶ NavigationBar（Material 3 推荐）— 支持图标+标签+徽标\n'
                '❷ BottomNavigationBar（经典）— 支持图标+文字\n\n'
                '两者都通过 currentIndex 和 onTap 控制页面切换。',
          ),
          _CodeBlock(code: 'NavigationBar(\n'
              '  selectedIndex: _index,\n'
              '  onDestinationSelected: (i) => setState(() => _index = i),\n'
              '  destinations: [\n'
              '    NavigationDestination(icon: Icon(Icons.home), label: "首页"),\n'
              '    NavigationDestination(icon: Icon(Icons.search), label: "搜索"),\n'
              '    NavigationDestination(icon: Icon(Icons.person), label: "我的"),\n'
              '  ],\n'
              ')'),
          const SizedBox(height: 8),
          const _BottomNavDemo(),
          _DividerLine(),

          // ========== 5. TabBar + TabBarView ==========
          _WidgetTitle(title: '5. TabBar + TabBarView —— 标签页'),
          _Explainer(
            text: 'TabBar 和 TabBarView 配合实现标签页切换。\n'
                'TabBar 显示标签头，TabBarView 显示对应的页面内容。\n'
                '★ 使用 TabController 控制联动（或 DefaultTabController）\n'
                '★ TabBar 可放在 AppBar.bottom 或独立使用\n'
                '★ Tab 支持文本、图标、文本+图标',
          ),
          _CodeBlock(code: 'DefaultTabController(\n'
              '  length: 3,\n'
              '  child: Column(\n'
              '    children: [\n'
              '      TabBar(\n'
              '        tabs: [\n'
              '          Tab(text: "聊天", icon: Icon(Icons.chat)),\n'
              '          Tab(text: "状态", icon: Icon(Icons.circle)),\n'
              '          Tab(text: "设置", icon: Icon(Icons.settings)),\n'
              '        ],\n'
              '      ),\n'
              '      TabBarView(\n'
              '        children: [ChatPage(), StatusPage(), SettingsPage()],\n'
              '      ),\n'
              '    ],\n'
              '  ),\n'
              ')'),
          const SizedBox(height: 8),
          const _TabBarDemo(),
          _DividerLine(),

          // ========== 6. Drawer ==========
          _WidgetTitle(title: '6. Drawer —— 侧边抽屉'),
          _Explainer(
            text: 'Drawer 是从屏幕左侧滑出的导航面板。\n'
                '通常作为 Scaffold 的 drawer 参数使用。\n'
                '★ DrawerHeader — 头部区域（头像、背景等）\n'
                '★ ListTile 或 MenuItems — 导航项\n'
                '★ 拉动边缘或点击汉堡图标打开',
          ),
          _CodeBlock(code: 'Scaffold(\n'
              '  drawer: Drawer(\n'
              '    child: ListView(\n'
              '      children: [\n'
              '        DrawerHeader(\n'
              '          decoration: BoxDecoration(color: Colors.blue),\n'
              '          child: Text("抽屉头部"),\n'
              '        ),\n'
              '        ListTile(leading: Icon(Icons.home), title: Text("首页")),\n'
              '        ListTile(leading: Icon(Icons.settings), title: Text("设置")),\n'
              '      ],\n'
              '    ),\n'
              '  ),\n'
              '  body: ...,\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Drawer 通过 Scaffold.drawer 触发。在移动端手指从左侧边缘右滑即可打开。'
                  '通常配合 AppBar 的 leading 汉堡菜单按钮使用。',
                  style: TextStyle(color: Colors.blue[800], fontSize: 13),
                )),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 7. Dialog & AlertDialog ==========
          _WidgetTitle(title: '7. Dialog / AlertDialog —— 对话框'),
          _Explainer(
            text: '对话框用于显示重要信息或获取用户确认。\n\n'
                '❶ AlertDialog — 标准提示对话框，含标题、内容、操作按钮\n'
                '❷ SimpleDialog — 简单选项对话框\n'
                '❸ Dialog — 自定义对话框（任意内容）\n'
                '❹ showDatePicker / showTimePicker — 日期/时间选择\n\n'
                '★ 通过 showDialog() 函数弹出',
          ),
          _CodeBlock(code: '// 显示 AlertDialog\n'
              'showDialog(\n'
              '  context: context,\n'
              '  builder: (context) => AlertDialog(\n'
              '    title: Text("提示"),\n'
              '    content: Text("确定要删除吗？"),\n'
              '    actions: [\n'
              '      TextButton(onPressed: () => Navigator.pop(context), child: Text("取消")),\n'
              '      TextButton(onPressed: () { /*确认操作*/ }, child: Text("确定")),\n'
              '    ],\n'
              '  ),\n'
              ');'),
          const SizedBox(height: 8),
          const _DialogDemo(),
          _DividerLine(),

          // ========== 8. SnackBar ==========
          _WidgetTitle(title: '8. SnackBar —— 底部提示条'),
          _Explainer(
            text: 'SnackBar 是在屏幕底部短暂出现的提示信息。\n'
                '★ 通过 ScaffoldMessenger.of(context).showSnackBar() 显示\n'
                '★ 可包含文本和操作按钮\n'
                '★ 自动消失（默认 4 秒），可滑动关闭\n'
                '★ 适合显示操作结果反馈',
          ),
          _CodeBlock(code: 'ScaffoldMessenger.of(context).showSnackBar(\n'
              '  SnackBar(\n'
              '    content: Text("操作成功"),\n'
              '    action: SnackBarAction(label: "撤销", onPressed: () {}),\n'
              '    duration: Duration(seconds: 2),\n'
              '    behavior: SnackBarBehavior.floating, // 浮动样式\n'
              '  ),\n'
              ');'),
          const SizedBox(height: 8),
          const _SnackBarDemo(),
          _DividerLine(),

          // ========== 9. BottomSheet ==========
          _WidgetTitle(title: '9. BottomSheet —— 底部弹窗'),
          _Explainer(
            text: 'BottomSheet 是从屏幕底部弹出的面板。\n'
                '★ showBottomSheet() — 在 Scaffold 内嵌的面板\n'
                '★ showModalBottomSheet() — 模态面板（遮挡背景）\n'
                '★ 常用于分享菜单、操作列表、筛选面板等场景',
          ),
          _CodeBlock(code: 'showModalBottomSheet(\n'
              '  context: context,\n'
              '  shape: RoundedRectangleBorder(\n'
              '    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),\n'
              '  ),\n'
              '  builder: (context) => Column(\n'
              '    mainAxisSize: MainAxisSize.min,\n'
              '    children: [\n'
              '      ListTile(leading: Icon(Icons.share), title: Text("分享")),\n'
              '      ListTile(leading: Icon(Icons.copy), title: Text("复制")),\n'
              '    ],\n'
              '  ),\n'
              ');'),
          const SizedBox(height: 8),
          const _BottomSheetDemo(),
          _DividerLine(),

          // ========== 10. Chip 家族 ==========
          _WidgetTitle(title: '10. Chip 家族 —— 标签/筹码'),
          _Explainer(
            text: 'Chip 系列组件用于显示标签、选项或输入内容。\n\n'
                '❶ Chip — 基础标签，可包含图标和文字\n'
                '❷ InputChip — 输入型标签，常用于标签输入\n'
                '❸ ChoiceChip — 单选标签，用于一组选项\n'
                '❹ FilterChip — 多选标签，用于过滤条件\n'
                '❺ ActionChip — 动作型标签，带点击回调',
          ),
          _CodeBlock(code: 'Chip(label: Text("标签"))\n'
              'InputChip(label: Text("输入标签"), onDeleted: () {})\n'
              'ChoiceChip(label: Text("选项"), selected: _selected)\n'
              'FilterChip(label: Text("过滤"), selected: _selected)\n'
              'ActionChip(label: Text("操作"), onPressed: () {})'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Chip'), avatar: Icon(Icons.star, size: 18)),
                InputChip(label: Text('InputChip'), onDeleted: null),
                FilterChip(label: Text('FilterChip'), selected: false, onSelected: null),
                ChoiceChip(label: Text('ChoiceChip'), selected: true),
                ActionChip(label: Text('ActionChip'), onPressed: null),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 11. Progress Indicators ==========
          _WidgetTitle(title: '11. 进度指示器 —— Linear / Circular'),
          _Explainer(
            text: 'Flutter 提供了两种进度指示器：\n\n'
                '❶ LinearProgressIndicator — 水平进度条\n'
                '❷ CircularProgressIndicator — 圆形进度圈\n\n'
                '两种模式：\n'
                '★ 确定模式（传入 value 0.0~1.0）— 显示具体进度\n'
                '★ 不确定模式（不传 value）— 循环动画，表示"加载中"',
          ),
          _CodeBlock(code: '// 确定模式 — 传入 0.0~1.0 的值\n'
              'LinearProgressIndicator(value: 0.7)\n'
              'CircularProgressIndicator(value: 0.7)\n\n'
              '// 不确定模式 — 不传 value，显示循环动画\n'
              'LinearProgressIndicator()\n'
              'CircularProgressIndicator()'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                LinearProgressIndicator(value: 0.7, minHeight: 8, borderRadius: BorderRadius.all(Radius.circular(4))),
                SizedBox(height: 12),
                LinearProgressIndicator(minHeight: 6),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 48, height: 48, child: CircularProgressIndicator(value: 0.7)),
                    SizedBox(width: 48, height: 48, child: CircularProgressIndicator()),
                  ],
                ),
              ],
            ),
          ),
          _TipText(text: '确定模式(左)和不确定模式(右)的对比。确定模式展示具体进度，不确定模式表示正在加载。'),
          _DividerLine(),

          // ========== 12. Switch / Checkbox / Radio ==========
          _WidgetTitle(title: '12. Switch / Checkbox / Radio —— 选择组件'),
          _Explainer(
            text: '三种 Material 风格的选择组件：\n\n'
                '❶ Switch — 开关，用于二元切换（开/关）\n'
                '❷ Checkbox — 复选框，用于多选\n'
                '❸ Radio — 单选按钮，用于一组互斥选项\n\n'
                '三者都需要 value + onChanged 组合。'
                'SwitchListTile / CheckboxListTile / RadioListTile 是带标题的便捷版本。',
          ),
          _CodeBlock(code: 'Switch(value: _on, onChanged: (v) => setState(() => _on = v))\n'
              'Checkbox(value: _checked, onChanged: (v) => setState(() => _checked = v))\n'
              'Radio<String>(value: "a", groupValue: _group, onChanged: (v) => setState(() => _group = v))'),
          const SizedBox(height: 8),
          const _SelectionDemo(),
          _DividerLine(),

          // ========== 13. DropdownButton ==========
          _WidgetTitle(title: '13. DropdownButton —— 下拉菜单'),
          _Explainer(
            text: 'DropdownButton 让用户从一组选项中选择一个值。\n'
                '★ value — 当前选中的值\n'
                '★ items — DropdownMenuItem 列表\n'
                '★ onChanged — 选中回调\n'
                '★ hint — 未选择时的提示文字\n'
                '★ elevation — 下拉菜单的阴影高度',
          ),
          _CodeBlock(code: 'String _selected = "flutter";\n\n'
              'DropdownButton<String>(\n'
              '  value: _selected,\n'
              '  onChanged: (v) => setState(() => _selected = v!),\n'
              '  items: const [\n'
              '    DropdownMenuItem(value: "flutter", child: Text("Flutter")),\n'
              '    DropdownMenuItem(value: "dart", child: Text("Dart")),\n'
              '  ],\n'
              ')'),
          const SizedBox(height: 8),
          const _DropdownDemo(),
          _DividerLine(),

          // ========== 14. ExpansionTile ==========
          _WidgetTitle(title: '14. ExpansionTile —— 可展开列表项'),
          _Explainer(
            text: 'ExpansionTile 是一个可展开/折叠的列表项。\n'
                '★ title — 始终显示的标题\n'
                '★ leading — 标题左侧图标\n'
                '★ children — 展开后显示的内容\n'
                '★ initiallyExpanded — 初始是否展开\n'
                '★ ExpansionPanelList — 多个 ExpansionTile 的管理器',
          ),
          _CodeBlock(code: 'ExpansionTile(\n'
              '  title: Text("展开标题"),\n'
              '  leading: Icon(Icons.settings),\n'
              '  initiallyExpanded: false,\n'
              '  children: [Text("展开后的内容区域")],\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const ExpansionTile(
              leading: Icon(Icons.info_outline, color: Colors.blue),
              title: Text('什么是 Flutter？'),
              subtitle: Text('点击展开了解更多'),
              childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flutter 是 Google 开源的 UI 工具包，用于从单份代码构建高性能、高保真的跨平台应用。'
                    '支持 Android、iOS、Web、Windows、macOS、Linux。',
                    style: TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 15. Tooltip ==========
          _WidgetTitle(title: '15. Tooltip —— 长按提示'),
          _Explainer(
            text: 'Tooltip 为 Widget 提供长按（或桌面端悬停）时的文字提示。\n'
                '★ message — 提示文本\n'
                '★ preferBelow — 优先在下方显示\n'
                '★ verticalOffset — 垂直偏移\n'
                '★ padding — 内边距\n'
                '★ decoration — 背景装饰',
          ),
          _CodeBlock(code: 'Tooltip(\n'
              '  message: "这是提示文字",\n'
              '  child: Icon(Icons.info),\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Wrap(
              spacing: 24,
              children: [
                Tooltip(message: '收藏', child: Icon(Icons.favorite, color: Colors.red, size: 32)),
                Tooltip(message: '分享', child: Icon(Icons.share, color: Colors.blue, size: 32)),
                Tooltip(message: '删除', child: Icon(Icons.delete, color: Colors.grey, size: 32)),
                Tooltip(message: '设置', child: Icon(Icons.settings, color: Colors.grey, size: 32)),
              ],
            ),
          ),
          _TipText(text: '在 Web/桌面端悬停图标查看提示；移动端长按图标触发。'),
          _DividerLine(),

          // ========== 16. DataTable ==========
          _WidgetTitle(title: '16. DataTable —— 数据表格'),
          _Explainer(
            text: 'DataTable 以表格形式展示数据。\n'
                '★ columns — DataColumn 列表（列定义）\n'
                '★ rows — DataRow 列表（每行数据）\n'
                '★ sortColumnIndex — 排序列索引\n'
                '★ sortAscending — 排序方向\n'
                '★ DataCell 可包含任意 Widget 作为单元格内容',
          ),
          _CodeBlock(code: 'DataTable(\n'
              '  columns: [\n'
              '    DataColumn(label: Text("姓名")),\n'
              '    DataColumn(label: Text("年龄")),\n'
              '  ],\n'
              '  rows: [\n'
              '    DataRow(cells: [\n'
              '      DataCell(Text("张三")),\n'
              '      DataCell(Text("28")),\n'
              '    ]),\n'
              '  ],\n'
              ')'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('姓名', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('年龄', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('城市', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('职业', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('张三')), DataCell(Text('28')), DataCell(Text('北京')), DataCell(Text('工程师'))]),
                DataRow(cells: [DataCell(Text('李四')), DataCell(Text('32')), DataCell(Text('上海')), DataCell(Text('设计师'))]),
                DataRow(cells: [DataCell(Text('王五')), DataCell(Text('24')), DataCell(Text('深圳')), DataCell(Text('产品经理'))]),
              ],
            ),
          ),
          _DividerLine(),
          _TipText(text: 'DataTable 适合数据量较少的场景。大数据量推荐使用 DataSource + DataTableSource。'),

          // ==================== 二、文本与输入 ====================
          _SectionTitle(title: '二、文本与输入'),
          _Explainer(
            text: 'Flutter 提供了强大的文本展示和用户输入组件。'
                '从简单的 Text 到功能丰富的 TextField，覆盖了大部分文本处理需求。',
          ),

          // ========== 17. Text / RichText ==========
          _WidgetTitle(title: '17. Text / RichText —— 文本展示'),
          _Explainer(
            text: 'Text 是最常用的文本展示组件。\n'
                '★ style — 文字样式（TextStyle）\n'
                '★ textAlign — 对齐方式\n'
                '★ overflow — 溢出处理（TextOverflow.ellipsis/clip/fade）\n'
                '★ maxLines — 最大行数\n'
                '★ softWrap — 是否换行\n\n'
                'RichText 支持混排样式（不同颜色、字体、手势的文本片段）。',
          ),
          _CodeBlock(code: 'Text(\n'
              '  "Hello Flutter",\n'
              '  style: TextStyle(\n'
              '    fontSize: 24,\n'
              '    fontWeight: FontWeight.bold,\n'
              '    color: Colors.blue,\n'
              '    letterSpacing: 2,\n'
              '  ),\n'
              '  textAlign: TextAlign.center,\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('基础文本 (14px)', style: TextStyle(fontSize: 14)),
                SizedBox(height: 4),
                Text('大号加粗蓝色文字', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                SizedBox(height: 4),
                Text('斜体文本', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.green)),
                SizedBox(height: 4),
                Text('溢出省略演示这是一段很长的文本会被截断',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(text: 'RichText '),
                      TextSpan(text: '混排', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      TextSpan(text: '不同'),
                      TextSpan(text: '样式', style: TextStyle(color: Colors.blue, fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 18. TextField ==========
          _WidgetTitle(title: '18. TextField —— 文本输入框'),
          _Explainer(
            text: 'TextField 是 Material 风格的文本输入框。\n'
                '★ controller — TextEditingController（控制文本内容）\n'
                '★ decoration — InputDecoration（标签、提示、边框、图标）\n'
                '★ keyboardType — 键盘类型（TextInputType.email/phone/...) \n'
                '★ obscureText — 密码模式\n'
                '★ validator — 验证器（需在 Form 中使用）\n'
                '★ onChanged / onSubmitted — 输入变化/提交回调',
          ),
          _CodeBlock(code: 'TextField(\n'
              '  controller: _controller,\n'
              '  decoration: InputDecoration(\n'
              '    labelText: "用户名",\n'
              '    hintText: "请输入用户名",\n'
              '    prefixIcon: Icon(Icons.person),\n'
              '    border: OutlineInputBorder(),\n'
              '  ),\n'
              '  keyboardType: TextInputType.text,\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: '邮箱', hintText: '请输入邮箱地址',
                    prefixIcon: Icon(Icons.email), border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: '密码', hintText: '请输入密码',
                    prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: '搜索', prefixIcon: Icon(Icons.search),
                    border: InputBorder.none, filled: true, fillColor: Color(0xFFE8E8E8),
                  ),
                ),
              ],
            ),
          ),
          _TipText(text: 'TextField 支持多种 InputDecoration 样式：OutlineInputBorder、UnderlineInputBorder、无边框。'),
          _DividerLine(),

          // ========== 19. Form ==========
          _WidgetTitle(title: '19. Form —— 表单'),
          _Explainer(
            text: 'Form 用于管理多个表单字段的验证和提交。\n'
                '★ key: GlobalKey<FormState> — 用于访问 Form 状态\n'
                '★ child — 通常是一个 Column 包含多个 TextFormField\n'
                '★ formKey.currentState.validate() — 触发表单验证\n'
                '★ formKey.currentState.save() — 触发所有字段的 onSaved\n\n'
                'TextFormField 是专为 Form 设计的输入框，集成了验证功能。',
          ),
          _CodeBlock(code: 'final _formKey = GlobalKey<FormState>();\n\n'
              'Form(\n'
              '  key: _formKey,\n'
              '  child: Column(\n'
              '    children: [\n'
              '      TextFormField(\n'
              '        validator: (v) => v!.isEmpty ? "不能为空" : null,\n'
              '      ),\n'
              '      ElevatedButton(\n'
              '        onPressed: () => _formKey.currentState!.validate(),\n'
              '        child: Text("提交"),\n'
              '      ),\n'
              '    ],\n'
              '  ),\n'
              ')'),
          const SizedBox(height: 8),
          const _FormDemo(),
          _DividerLine(),

          // ==================== 三、图片与图标 ====================
          _SectionTitle(title: '三、图片与图标'),

          // ========== 20. Image ==========
          _WidgetTitle(title: '20. Image —— 图片加载'),
          _Explainer(
            text: 'Image 组件支持从多种来源加载图片：\n\n'
                '❶ Image.network(url) — 从网络加载\n'
                '❷ Image.asset(path) — 从项目资源加载\n'
                '❸ Image.file(path) — 从本地文件加载\n'
                '❹ Image.memory(bytes) — 从内存字节加载\n\n'
                '★ fit — BoxFit 适配模式（cover/contain/fill/fitWidth/fitHeight）\n'
                '★ loadingBuilder — 加载中的占位图\n'
                '★ errorBuilder — 加载失败时的显示',
          ),
          _CodeBlock(code: 'Image.network(\n'
              '  "https://example.com/image.jpg",\n'
              '  fit: BoxFit.cover,\n'
              '  loadingBuilder: (ctx, child, chunk) {\n'
              '    if (chunk == null) return child;\n'
              '    return Center(child: CircularProgressIndicator());\n'
              '  },\n'
              '  errorBuilder: (ctx, error, stack) {\n'
              '    return Icon(Icons.broken_image, size: 64);\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text('cover', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text('contain', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.teal, Colors.green]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text('fill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TagText('BoxFit.cover'),
                    _TagText('BoxFit.contain'),
                    _TagText('BoxFit.fill'),
                  ],
                ),
              ],
            ),
          ),
          _TipText(text: 'Image.network, Image.asset, Image.file, Image.memory 四种构造方式。'),
          _DividerLine(),

          // ========== 21. Icon ==========
          _WidgetTitle(title: '21. Icon —— 图标'),
          _Explainer(
            text: 'Icon 用于显示 Material Design 图标。\n'
                '★ size — 图标尺寸\n'
                '★ color — 图标颜色\n'
                '★ weight — 图标粗细（仅支持可变字体图标）\n\n'
                'Flutter 内置数千个 Material Icons 图标，通过 Icons.xxx 使用。'
                '也支持自定义图标（IconData）。',
          ),
          _CodeBlock(code: 'Icon(\n'
              '  Icons.favorite,\n'
              '  size: 48,\n'
              '  color: Colors.red,\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Wrap(
              spacing: 16, runSpacing: 16,
              children: [
                Column(children: [Icon(Icons.home, size: 32, color: Colors.blue), Text('home', style: TextStyle(fontSize: 11))]),
                Column(children: [Icon(Icons.favorite, size: 32, color: Colors.red), Text('favorite', style: TextStyle(fontSize: 11))]),
                Column(children: [Icon(Icons.settings, size: 32, color: Colors.grey), Text('settings', style: TextStyle(fontSize: 11))]),
                Column(children: [Icon(Icons.person, size: 32, color: Colors.green), Text('person', style: TextStyle(fontSize: 11))]),
                Column(children: [Icon(Icons.star, size: 32, color: Colors.amber), Text('star', style: TextStyle(fontSize: 11))]),
                Column(children: [Icon(Icons.search, size: 32, color: Colors.purple), Text('search', style: TextStyle(fontSize: 11))]),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 22. CircleAvatar ==========
          _WidgetTitle(title: '22. CircleAvatar —— 圆形头像'),
          _Explainer(
            text: 'CircleAvatar 用于显示圆形头像或用户首字母。\n'
                '★ backgroundImage — 头像图片（ImageProvider）\n'
                '★ backgroundColor — 背景色（无图片时显示）\n'
                '★ child — 放在中心的子 Widget（通常是文字首字母）\n'
                '★ radius — 半径大小',
          ),
          _CodeBlock(code: 'CircleAvatar(\n'
              '  radius: 30,\n'
              '  backgroundImage: NetworkImage("url"),\n'
              '  child: Text("张"),\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(radius: 24, backgroundColor: Colors.blue, child: Text('张', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                CircleAvatar(radius: 24, backgroundColor: Colors.green, child: Text('李', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                CircleAvatar(radius: 24, backgroundColor: Colors.orange, child: Text('王', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                CircleAvatar(radius: 24, backgroundColor: Colors.purple, child: Icon(Icons.person, color: Colors.white)),
              ],
            ),
          ),
          _DividerLine(),

          // ==================== 四、导航与路由 ====================
          _SectionTitle(title: '四、导航与路由'),

          // ========== 23. Navigator ==========
          _WidgetTitle(title: '23. Navigator —— 导航管理器'),
          _Explainer(
            text: 'Navigator 是 Flutter 的路由导航核心，使用栈式管理页面。\n\n'
                '★ Navigator.push() — 推入新页面\n'
                '★ Navigator.pop() — 返回上一页\n'
                '★ Navigator.pushReplacement() — 替换当前页面\n'
                '★ Navigator.pushAndRemoveUntil() — 推入并移除之前所有页面\n'
                '★ Navigator.popUntil() — 一直返回到指定页面',
          ),
          _CodeBlock(code: '// 推入新页面\n'
              'Navigator.push(\n'
              '  context,\n'
              '  MaterialPageRoute(builder: (c) => DetailPage(id: 1)),\n'
              ');\n\n'
              '// 返回上一页并传回数据\n'
              'Navigator.pop(context, result);\n\n'
              '// 替换当前页面（不能返回）\n'
              'Navigator.pushReplacement(\n'
              '  context,\n'
              '  MaterialPageRoute(builder: (c) => HomePage()),\n'
              ');\n\n'
              '// 一直返回到根页面\n'
              'Navigator.popUntil(context, (route) => route.isFirst);'),
          const SizedBox(height: 8),
          const _NavigatorDemo(),
          _DividerLine(),

          // ========== 24. MaterialPageRoute ==========
          _WidgetTitle(title: '24. MaterialPageRoute —— 页面路由'),
          _Explainer(
            text: 'MaterialPageRoute 是 Material 风格的页面路由。\n'
                '它提供平台自适应的页面切换动画（iOS 从右滑入，Android 从底滑入）。\n\n'
                '★ builder — 构建页面的回调\n'
                '★ fullscreenDialog — 是否全屏对话框样式\n'
                '★ maintainState — 切走后是否保持状态',
          ),
          _CodeBlock(code: 'MaterialPageRoute(\n'
              '  builder: (context) => DetailPage(),\n'
              '  fullscreenDialog: true,\n'
              '  maintainState: true,\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text('MaterialPageRoute 自动适配平台动画：'
                'iOS 使用 CupertinoPageRoute 风格的右滑动画，Android 使用自底向上的动画。',
                style: TextStyle(color: Colors.blue[800], fontSize: 13)),
          ),
          _DividerLine(),

          // ========== 25. IndexedStack ==========
          _WidgetTitle(title: '25. IndexedStack —— 索引栈（页面保持状态）'),
          _Explainer(
            text: 'IndexedStack 在多个子 Widget 之间切换，并保持所有子 Widget 的状态。\n'
                '★ index — 当前显示的 child 索引\n'
                '★ children — 所有子 Widget 列表\n\n'
                '与 PageView 不同，IndexedStack 不提供滑动切换，所有页面共存。'
                '非常适合底部导航栏的页面切换场景。',
          ),
          _CodeBlock(code: 'IndexedStack(\n'
              '  index: _currentIndex,\n'
              '  children: [\n'
              '    HomePage(), SearchPage(), ProfilePage(),\n'
              '  ],\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'IndexedStack 让所有页面共存于 Widget 树中，切换时不会丢失滚动位置、输入内容等状态。'
                  '比 PageView 更适合底部导航场景。',
                  style: TextStyle(color: Colors.amber[900], fontSize: 13),
                )),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 26. PopScope ==========
          _WidgetTitle(title: '26. PopScope —— 拦截返回'),
          _Explainer(
            text: 'PopScope（Flutter 3.16+ 替代 WillPopScope）用于拦截系统返回按钮事件。\n'
                '★ canPop — false 时拦截返回，true 时允许返回\n'
                '★ onPopInvokedWithResult — 返回被调用时的回调\n\n'
                '典型场景：编辑页面提示保存、游戏暂停确认退出等。',
          ),
          _CodeBlock(code: 'PopScope(\n'
              '  canPop: false,\n'
              '  onPopInvokedWithResult: (didPop, _) {\n'
              '    if (!didPop) showConfirmDialog(context);\n'
              '  },\n'
              '  child: Scaffold(...),\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text('⚠️ WillPopScope 已弃用，Flutter 3.16+ 请使用 PopScope。'
                'PopScope 提供了更明确的双参数回调机制。',
                style: TextStyle(color: Colors.red[800], fontSize: 13)),
          ),
          _DividerLine(),

          // ==================== 五、手势与交互 ====================
          _SectionTitle(title: '五、手势与交互'),

          // ========== 27. GestureDetector ==========
          _WidgetTitle(title: '27. GestureDetector —— 手势识别器'),
          _Explainer(
            text: 'GestureDetector 是最通用的手势识别组件，能检测多种手势：\n\n'
                '❶ 点击 — onTap / onDoubleTap / onLongPress\n'
                '❷ 拖动 — onPanStart / onPanUpdate / onPanEnd\n'
                '❸ 缩放 — onScaleStart / onScaleUpdate / onScaleEnd\n'
                '❹ 滑动 — onHorizontalDrag / onVerticalDrag\n\n'
                '⭐ 注意事件冲突：一个 GestureDetector 不能同时监听 onPan 和 onVerticalDrag。',
          ),
          _CodeBlock(code: 'GestureDetector(\n'
              '  onTap: () => print("点击"),\n'
              '  onDoubleTap: () => print("双击"),\n'
              '  onLongPress: () => print("长按"),\n'
              '  child: Container(width: 100, height: 100, color: Colors.blue),\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                _GestureDemo(),
                SizedBox(height: 8),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 28. InkWell ==========
          _WidgetTitle(title: '28. InkWell —— 水波纹效果'),
          _Explainer(
            text: 'InkWell 为子 Widget 添加 Material Design 水波纹点击效果。\n'
                '★ onTap — 点击回调\n'
                '★ onLongPress — 长按回调\n'
                '★ borderRadius — 水波纹形状\n'
                '★ splashColor — 水波纹颜色\n\n'
                'InkWell 必须在 Material Widget 内才能显示水波纹效果。',
          ),
          _CodeBlock(code: 'Material(\n'
              '  child: InkWell(\n'
              '    onTap: () => print("点击"),\n'
              '    borderRadius: BorderRadius.circular(8),\n'
              '    child: Container(padding: EdgeInsets.all(16), child: Text("有水波纹")),\n'
              '  ),\n'
              ')'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: const Text('点击查看水波纹效果', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          _TipText(text: 'InkWell 必须在 Material Widget 的子树中，否则水波纹不会显示。'),
          _DividerLine(),

          // ========== 29. Dismissible ==========
          _WidgetTitle(title: '29. Dismissible —— 滑动删除'),
          _Explainer(
            text: 'Dismissible 允许用户通过滑动来移除列表项。\n'
                '★ key — 每个 Dismissible 必须有一个唯一 Key\n'
                '★ onDismissed — 滑动完成后的回调\n'
                '★ background — 滑动时左侧显示的背景\n'
                '★ secondaryBackground — 滑动时右侧显示的背景\n'
                '★ confirmDismiss — 确认是否删除\n'
                '★ direction — 允许滑动的方向',
          ),
          _CodeBlock(code: 'Dismissible(\n'
              '  key: ValueKey(item.id),\n'
              '  onDismissed: (_) => _removeItem(item),\n'
              '  background: Container(color: Colors.red, child: Icon(Icons.delete)),\n'
              '  child: ListTile(title: Text(item.title)),\n'
              ')'),
          const SizedBox(height: 8),
          const _DismissibleDemo(),
          _DividerLine(),

          // ========== 30. InteractiveViewer ==========
          _WidgetTitle(title: '30. InteractiveViewer —— 交互式查看器'),
          _Explainer(
            text: 'InteractiveViewer 让子 Widget 支持缩放和平移手势。\n'
                '★ minScale — 最小缩放比例\n'
                '★ maxScale — 最大缩放比例\n'
                '★ boundaryMargin — 边界溢出距离\n'
                '★ panEnabled — 是否允许平移\n'
                '★ scaleEnabled — 是否允许缩放\n\n'
                '常用于查看大图、地图等需要缩放操作的场景。',
          ),
          _CodeBlock(code: 'InteractiveViewer(\n'
              '  minScale: 0.5,\n'
              '  maxScale: 3.0,\n'
              '  child: Image.network("url"),\n'
              ')'),
          const SizedBox(height: 8),
          const _InteractiveViewerDemo(),
          _DividerLine(),

          // ==================== 六、异步与数据 ====================
          _SectionTitle(title: '六、异步与数据'),

          // ========== 31. FutureBuilder ==========
          _WidgetTitle(title: '31. FutureBuilder —— 异步构建'),
          _Explainer(
            text: 'FutureBuilder 根据 Future 的状态自动重建 UI。\n\n'
                '⭐ connectionState 状态：\n'
                '• none — 未开始执行\n'
                '• waiting — 正在等待结果\n'
                '• done — 已完成（成功或失败）\n\n'
                '⭐ snapshot 包含：hasData、hasError、data、error',
          ),
          _CodeBlock(code: 'FutureBuilder<String>(\n'
              '  future: _fetchData(),\n'
              '  builder: (context, snapshot) {\n'
              '    if (snapshot.connectionState == ConnectionState.waiting)\n'
              '      return CircularProgressIndicator();\n'
              '    if (snapshot.hasError)\n'
              '      return Text("错误: \${snapshot.error}");\n'
              '    return Text("数据: \${snapshot.data}");\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _FutureBuilderDemo(),
          _DividerLine(),

          // ========== 32. StreamBuilder ==========
          _WidgetTitle(title: '32. StreamBuilder —— 流式构建'),
          _Explainer(
            text: 'StreamBuilder 根据 Stream（数据流）的实时状态构建 UI。\n'
                '与 FutureBuilder 类似，但可以处理多次数据推送。\n\n'
                '⭐ snapshot.connectionState：\n'
                '• none — 未监听\n'
                '• waiting — 监听中，无数据\n'
                '• active — 收到数据\n'
                '• done — Stream 已关闭\n\n'
                '典型场景：实时数据、聊天消息、位置更新。',
          ),
          _CodeBlock(code: 'StreamBuilder<int>(\n'
              '  stream: _timerStream(),\n'
              '  builder: (context, snapshot) {\n'
              '    if (!snapshot.hasData) return Text("等待...");\n'
              '    return Text("值: \");\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _StreamBuilderDemo(),
          _DividerLine(),

          // ========== 33. ValueListenableBuilder ==========
          _WidgetTitle(title: '33. ValueListenableBuilder —— 值监听构建'),
          _Explainer(
            text: 'ValueListenableBuilder 监听 ValueNotifier 的值变化并重建 UI。\n'
                '相比 setState，它更精确——只重建需要更新的部分 Widget。\n\n'
                '★ ValueNotifier — 可监听的值容器\n'
                '★ ValueListenableBuilder — 监听并构建 UI',
          ),
          _CodeBlock(code: 'final counter = ValueNotifier<int>(0);\n\n'
              'ValueListenableBuilder<int>(\n'
              '  valueListenable: counter,\n'
              '  builder: (context, value, child) => Text("计数: \"),\n'
              ')'),
          const SizedBox(height: 8),
          const _ValueListenableDemo(),
          _DividerLine(),

          // ==================== 七、主题与样式 ====================
          _SectionTitle(title: '七、主题与样式'),

          // ========== 34. Theme / ThemeData ==========
          _WidgetTitle(title: '34. Theme —— 主题管理'),
          _Explainer(
            text: 'Theme 是 Flutter 的主题管理核心。\n\n'
                '⭐ ThemeData 定义整个应用的颜色、字体、形状等视觉风格：\n'
                '• colorScheme — 颜色方案（M3 推荐）\n'
                '• textTheme — 文本样式\n'
                '• useMaterial3 — 是否使用 Material 3\n'
                '• appBarTheme / cardTheme / buttonTheme 等组件主题\n\n'
                '⭐ 使用方法：\n'
                '• Theme.of(context) — 获取当前主题\n'
                '• Theme.of(context).copyWith(...) — 局部覆盖\n'
                '• MaterialApp(theme: ThemeData(...)) — 全局设置',
          ),
          _CodeBlock(code: '// 定义全局主题\n'
              'MaterialApp(\n'
              '  theme: ThemeData(\n'
              '    useMaterial3: true,\n'
              '    colorScheme: ColorScheme.fromSeed(\n'
              '      seedColor: Colors.blue,\n'
              '      brightness: Brightness.light,\n'
              '    ),\n'
              '    appBarTheme: AppBarTheme(centerTitle: true, elevation: 0),\n'
              '  ),\n'
              '  darkTheme: ThemeData.dark(),\n'
              ')'),
          const SizedBox(height: 8),
          const _ThemeDemo(),
          _DividerLine(),

          // ========== 35. MediaQuery ==========
          _WidgetTitle(title: '35. MediaQuery —— 媒体查询'),
          _Explainer(
            text: 'MediaQuery 获取当前设备的屏幕信息。\n\n'
                '★ MediaQuery.of(context).size — 屏幕尺寸\n'
                '★ MediaQuery.of(context).padding — 安全区域（状态栏、刘海）\n'
                '★ MediaQuery.of(context).devicePixelRatio — 设备像素比\n'
                '★ MediaQuery.of(context).textScaleFactor — 字体缩放\n'
                '★ MediaQuery.of(context).orientation — 屏幕方向\n'
                '★ MediaQuery.of(context).platformBrightness — 深浅模式',
          ),
          _CodeBlock(code: 'final media = MediaQuery.of(context);\n'
              'if (media.size.width > 600) { /* 平板布局 */ }\n'
              'final topPadding = media.padding.top;'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const _MediaQueryInfo(),
          ),
          _DividerLine(),

          // ========== 36. LayoutBuilder ==========
          _WidgetTitle(title: '36. LayoutBuilder —— 响应式布局'),
          _Explainer(
            text: 'LayoutBuilder 获取父容器的约束信息，根据可用空间动态构建 UI。\n\n'
                '⭐ BoxConstraints 包含：minWidth/maxWidth/minHeight/maxHeight\n\n'
                '典型用途：响应式布局，根据容器宽度返回不同 Widget。\n'
                'OrientationBuilder 根据设备方向自动调整布局。',
          ),
          _CodeBlock(code: 'LayoutBuilder(\n'
              '  builder: (context, constraints) {\n'
              '    if (constraints.maxWidth > 600) return _WideLayout();\n'
              '    else return _NarrowLayout();\n'
              '  },\n'
              ')'),
          const SizedBox(height: 8),
          const _LayoutBuilderDemo(),
          _DividerLine(),

          // ==================== 八、核心框架类 ====================
          _SectionTitle(title: '八、核心框架类'),

          // ========== 37. StatelessWidget & StatefulWidget ==========
          _WidgetTitle(title: '37. StatelessWidget / StatefulWidget —— 核心组件'),
          _Explainer(
            text: 'Widget 是 Flutter 中一切 UI 的基础。所有界面元素都是 Widget。\n\n'
                '⭐ StatelessWidget — 无状态，属性不可变，只有 build() 方法\n'
                '⭐ StatefulWidget — 有状态，State 对象保存可变状态，通过 setState() 更新\n\n'
                '⭐ 生命周期：createState → initState → build → setState → dispose',
          ),
          _CodeBlock(code: '// StatelessWidget\n'
              'class MyText extends StatelessWidget {\n'
              '  final String text;\n'
              '  const MyText({super.key, required this.text});\n'
              '  @override Widget build(BuildContext context) => Text(text);\n'
              '}\n\n'
              '// StatefulWidget\n'
              'class MyCounter extends StatefulWidget {\n'
              '  @override State<MyCounter> createState() => _MyCounterState();\n'
              '}\n'
              'class _MyCounterState extends State<MyCounter> {\n'
              '  int _count = 0;\n'
              '  @override Widget build(BuildContext context) {\n'
              '    return ElevatedButton(\n'
              '      onPressed: () => setState(() => _count++),\n'
              '      child: Text("Count: \"),\n'
              '    );\n'
              '  }\n'
              '}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const _TipText(text: 'StatelessWidget vs StatefulWidget 选择：\n'
                '• 组件不需要内部状态变化 → StatelessWidget\n'
                '• 需要 setState / AnimationController / 生命周期 → StatefulWidget'),
          ),
          _DividerLine(),

          // ========== 38. BuildContext ==========
          _WidgetTitle(title: '38. BuildContext —— 构建上下文'),
          _Explainer(
            text: 'BuildContext 是 Widget 在 Widget 树中的位置引用。\n\n'
                '⭐ 主要用途：\n'
                '• Theme.of(context) / MediaQuery.of(context)\n'
                '• Navigator.of(context) / ScaffoldMessenger.of(context)\n'
                '• context.watch<T>() 监听 Provider / context.read<T>() 读取\n\n'
                '⭐ 注意：BuildContext 关联到 Widget 树中的特定位置。'
                '异步回调中需检查 mounted 属性。',
          ),
          _CodeBlock(code: '@override\n'
              'Widget build(BuildContext context) {\n'
              '  final theme = Theme.of(context);\n'
              '  final media = MediaQuery.of(context);\n'
              '  return Container(\n'
              '    color: theme.colorScheme.primary,\n'
              '    width: media.size.width,\n'
              '  );\n'
              '}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Text('⚠️ 异步中使用 BuildContext 的风险：Future 回调中 Widget 可能已销毁。'
                '建议使用 mounted 属性检查后再访问。',
                style: TextStyle(color: Colors.amber[900], fontSize: 13)),
          ),
          _DividerLine(),

          // ========== 39. InheritedWidget ==========
          _WidgetTitle(title: '39. InheritedWidget —— 数据透传'),
          _Explainer(
            text: 'InheritedWidget 让数据在 Widget 树中高效传递，无需逐层构造传参。\n\n'
                '⭐ 工作原理：父节点创建，任何子孙节点通过 .of(context) 获取数据\n'
                '⭐ 数据变化时，Flutter 自动重建依赖它的 Widget\n'
                '⭐ Theme、MediaQuery 都是 InheritedWidget\n'
                '⭐ Provider 等状态管理库也基于 InheritedWidget',
          ),
          _CodeBlock(code: 'class MyInherited extends InheritedWidget {\n'
              '  final int data;\n'
              '  const MyInherited({super.key, required this.data, required super.child});\n'
              '  static MyInherited of(BuildContext context) {\n'
              '    return context.dependOnInheritedWidgetOfExactType<MyInherited>()!;\n'
              '  }\n'
              '  @override bool updateShouldNotify(MyInherited old) => data != old.data;\n'
              '}'),
          _DividerLine(),

          // ========== 40. Key ==========
          _WidgetTitle(title: '40. Key —— 身份标识'),
          _Explainer(
            text: 'Key 帮助 Flutter 识别 Widget 的身份，尤其在列表和状态保留场景中至关重要。\n\n'
                '⭐ Key 类型：ValueKey（基于值）、ObjectKey（基于对象引用）\n'
                '  UniqueKey（每次不同，强制重建）、PageStorageKey（保持滚动位置）\n\n'
                '⭐ 何时需要 Key：列表项、需要保留状态的同类型 Widget 切换、Dismissible',
          ),
          _CodeBlock(code: 'ListView.builder(\n'
              '  itemBuilder: (context, index) => ListTile(\n'
              '    key: ValueKey("item_\"),\n'
              '    title: Text("Item \"),\n'
              '  ),\n'
              ');'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Text('💡 Key 的核心作用：Element 复用。'
                '没有 Key 时 Flutter 按位置匹配 Widget；有 Key 时按 Key 匹配。',
                style: TextStyle(color: Colors.purple[800], fontSize: 13)),
          ),
          _DividerLine(),

          // ========== 41. ScrollController ==========
          _WidgetTitle(title: '41. ScrollController —— 滚动控制'),
          _Explainer(
            text: 'ScrollController 控制可滚动组件的滚动行为。\n\n'
                '⭐ 常用方法：\n'
                '• animateTo(offset) — 平滑滚动到指定位置\n'
                '• jumpTo(offset) — 直接跳转\n'
                '• position — 当前滚动位置\n'
                '• offset — 当前偏移量\n\n'
                '⭐ ScrollController 需要 dispose()。',
          ),
          _CodeBlock(code: 'final _scrollController = ScrollController();\n\n'
              '// 滚动到底部\n'
              '_scrollController.animateTo(\n'
              '  _scrollController.position.maxScrollExtent,\n'
              '  duration: Duration(milliseconds: 300),\n'
              '  curve: Curves.easeOut,\n'
              ');\n\n'
              '// 监听滚动位置\n'
              '_scrollController.addListener(() {\n'
              '  if (_scrollController.offset > 200) showButton();\n'
              '});\n\n'
              '@override void dispose() {\n'
              '  _scrollController.dispose();\n'
              '  super.dispose();\n'
              '}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ScrollPhysics 控制滚动行为：', style: TextStyle(color: Colors.teal[800], fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('• BouncingScrollPhysics — iOS 弹性效果\n'
                    '• ClampingScrollPhysics — Android 阻尼效果',
                    style: TextStyle(color: Colors.teal[800], fontSize: 13)),
              ],
            ),
          ),
          _DividerLine(),

          // ========== 42. ChangeNotifier ==========
          _WidgetTitle(title: '42. ChangeNotifier —— 通知器'),
          _Explainer(
            text: 'ChangeNotifier 是 Flutter 内置的简单状态管理类，通过"发布-订阅"模式工作。\n\n'
                '⭐ 工作流程：\n'
                '• 创建一个继承 ChangeNotifier 的类\n'
                '• 状态变化时调用 notifyListeners()\n'
                '• 其他组件通过 addListener 或 ListenableBuilder 监听\n\n'
                '⭐ ChangeNotifier 是 Provider 状态管理的基础。',
          ),
          _CodeBlock(code: 'class CounterModel extends ChangeNotifier {\n'
              '  int _count = 0;\n'
              '  int get count => _count;\n'
              '  void increment() { _count++; notifyListeners(); }\n'
              '}\n\n'
              '// 使用\n'
              'final counter = CounterModel();\n'
              'ListenableBuilder(\n'
              '  listenable: counter,\n'
              '  builder: (context, _) => Text("\"),\n'
              ');'),
          const SizedBox(height: 8),
          const _ChangeNotifierDemo(),
          _DividerLine(),

          // ========== 43. CustomPainter ==========
          _WidgetTitle(title: '43. CustomPaint / CustomPainter —— 自定义绘制'),
          _Explainer(
            text: 'CustomPainter 允许自由绘制任意图形、路径和动画。\n\n'
                '⭐ 核心方法：\n'
                '• paint(Canvas canvas, Size size) — 绘制内容\n'
                '• shouldRepaint() — 是否重绘\n\n'
                '⭐ Canvas API：\n'
                '• drawLine / drawCircle / drawRect — 基本形状\n'
                '• drawPath — 自定义路径\n'
                '• drawArc — 弧线\n\n'
                '⭐ CustomPaint 组件：painter（前景）、foregroundPainter（背景）、size',
          ),
          _CodeBlock(code: 'class MyPainter extends CustomPainter {\n'
              '  @override\n'
              '  void paint(Canvas canvas, Size size) {\n'
              '    final paint = Paint()..color = Colors.blue..strokeWidth = 4;\n'
              '    canvas.drawCircle(\n'
              '      Offset(size.width/2, size.height/2), 50, paint,\n'
              '    );\n'
              '  }\n'
              '  @override bool shouldRepaint(covariant MyPainter old) => false;\n'
              '}'),
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: _DemoPainter(),
              size: const Size(double.infinity, 120),
            ),
          ),
          _TipText(text: 'CustomPainter 通过 Canvas API 实现自定义图形绘制。上方绘制了一个笑脸图案示例。'),
          _DividerLine(),

          // ========== 44. Ticker / TickerProvider ==========
          _WidgetTitle(title: '44. Ticker / TickerProvider —— 帧驱动'),
          _Explainer(
            text: 'Ticker 是 Flutter 动画的底层驱动，每帧都会触发回调。\n\n'
                '⭐ TickerProvider（混入式）：\n'
                '• SingleTickerProviderStateMixin — 一个 Ticker\n'
                '• TickerProviderStateMixin — 多个 Ticker\n\n'
                '⭐ AnimationController 底层依赖 Ticker：\n'
                '• Ticker 每帧调用 AnimationController 的估值方法\n'
                '• 屏幕刷新率 60Hz 时，每秒触发 60 次\n'
                '• Widget 树不显示时 Ticker 暂停（省电）',
          ),
          _CodeBlock(code: 'class _MyWidgetState extends State<MyWidget>\n'
              '    with SingleTickerProviderStateMixin {\n'
              '  late AnimationController _controller;\n'
              '  @override void initState() {\n'
              '    super.initState();\n'
              '    _controller = AnimationController(\n'
              '      vsync: this,\n'
              '      duration: Duration(seconds: 1),\n'
              '    );\n'
              '  }\n'
              '  @override void dispose() {\n'
              '    _controller.dispose();\n'
              '    super.dispose();\n'
              '  }\n'
              '}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo[200]!),
            ),
            child: Text('Ticker 核心价值：在 Widget 树不可见时自动暂停，避免不必要的性能消耗。'
                'vsync: this 将动画与 Widget 生命周期绑定。',
                style: TextStyle(color: Colors.indigo[800], fontSize: 13)),
          ),
          _DividerLine(),

          // ========== 总结 ==========
          _SectionTitle(title: '总结'),
          _Explainer(
            text: 'Flutter 框架类全景回顾：\n\n'
                '1. Material 组件 — AppBar、Button、Card、TabBar、Dialog、BottomSheet 等\n\n'
                '2. 文本与输入 — Text、TextField、Form、TextEditingController\n\n'
                '3. 图片与图标 — Image、Icon、CircleAvatar\n\n'
                '4. 导航与路由 — Navigator、Route、PopScope、IndexedStack\n\n'
                '5. 手势与交互 — GestureDetector、InkWell、Dismissible、InteractiveViewer\n\n'
                '6. 异步与数据 — FutureBuilder、StreamBuilder、ValueListenableBuilder\n\n'
                '7. 主题与样式 — Theme、MediaQuery、LayoutBuilder\n\n'
                '8. 核心框架 — StatelessWidget、StatefulWidget、BuildContext、'
                'InheritedWidget、Key、ScrollController、ChangeNotifier、CustomPainter、Ticker\n\n'
                '💡 深入理解这些类，就能熟练地使用 Flutter 构建任意复杂的应用！',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================================
// 辅助展示组件
// ============================================================

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
        color: Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF90CAF9)),
      ),
      child: Text(text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A237E), height: 1.5)),
    );
  }
}

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
      child: Text(code,
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

class _TipText extends StatelessWidget {
  final String text;
  const _TipText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
    );
  }
}

class _TagText extends StatelessWidget {
  final String text;
  const _TagText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500));
  }
}

// ============================================================
// 一、交互演示组件 — Button 演示
// ============================================================

class _BottomNavDemo extends StatefulWidget {
  const _BottomNavDemo();

  @override
  State<_BottomNavDemo> createState() => _BottomNavDemoState();
}

class _BottomNavDemoState extends State<_BottomNavDemo> {
  int _index = 0;

  static const _pages = ['首页', '搜索', '收藏', '我的'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('当前页面: ${_pages[_index]}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            height: 64,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
              NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: '搜索'),
              NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: '收藏'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 二、TabBar 演示
// ============================================================

class _TabBarDemo extends StatefulWidget {
  const _TabBarDemo();

  @override
  State<_TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<_TabBarDemo> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _controller,
            tabs: const [
              Tab(text: '聊天', icon: Icon(Icons.chat, size: 18)),
              Tab(text: '状态', icon: Icon(Icons.circle, size: 18)),
              Tab(text: '设置', icon: Icon(Icons.settings, size: 18)),
            ],
          ),
          SizedBox(
            height: 80,
            child: TabBarView(
              controller: _controller,
              children: [
                const Center(child: Text('聊天页面')),
                const Center(child: Text('状态页面')),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: const Column(
                    children: [
                      Text('TabBar + TabBarView 实现标签页切换',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 三、Dialog 演示
// ============================================================

class _DialogDemo extends StatelessWidget {
  const _DialogDemo();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.notification_important, size: 18),
      label: const Text('弹窗演示'),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('使用说明'),
            ],
          ),
          content: const Text(
            'AlertDialog 包含 title、content、actions 三个区域。\n\n'
            '• title — 标题区域\n'
            '• content — 内容区域\n'
            '• actions — 操作按钮区域\n\n'
            '通过 showDialog() 函数弹出。',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 四、SnackBar 演示
// ============================================================

class _SnackBarDemo extends StatelessWidget {
  const _SnackBarDemo();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.info_outline, size: 18),
      label: const Text('显示 SnackBar'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('这是一条 SnackBar 提示'),
            action: SnackBarAction(label: '撤销', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }
}

// ============================================================
// 五、BottomSheet 演示
// ============================================================

class _BottomSheetDemo extends StatelessWidget {
  const _BottomSheetDemo();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.arrow_upward, size: 18),
      label: const Text('弹出 BottomSheet'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SizedBox(
            height: 220,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const ListTile(leading: Icon(Icons.share), title: Text('分享到...')),
                const ListTile(leading: Icon(Icons.copy), title: Text('复制链接')),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('取消', style: TextStyle(color: Colors.red)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// 六、Switch / Checkbox / Radio 演示
// ============================================================

class _SelectionDemo extends StatefulWidget {
  const _SelectionDemo();

  @override
  State<_SelectionDemo> createState() => _SelectionDemoState();
}

class _SelectionDemoState extends State<_SelectionDemo> {
  bool _switchOn = true;
  bool _checkboxChecked = true;
  String _radioValue = 'a';

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
          SwitchListTile(
            title: const Text('Wi-Fi'),
            subtitle: Text(_switchOn ? '已开启' : '已关闭'),
            value: _switchOn,
            onChanged: (v) => setState(() => _switchOn = v),
            secondary: Icon(_switchOn ? Icons.wifi : Icons.wifi_off,
                color: _switchOn ? Colors.blue : Colors.grey),
          ),
          CheckboxListTile(
            title: const Text('记住登录状态'),
            value: _checkboxChecked,
            onChanged: (v) => setState(() => _checkboxChecked = v!),
            secondary: Icon(Icons.check_circle_outline,
                color: _checkboxChecked ? Colors.blue : Colors.grey),
          ),
          const Divider(height: 8),
          const Text('性别选择（Radio 组）', style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(child: RadioListTile<String>(
                title: const Text('男'), value: 'a', groupValue: _radioValue,
                onChanged: (v) => setState(() => _radioValue = v!),
              )),
              Expanded(child: RadioListTile<String>(
                title: const Text('女'), value: 'b', groupValue: _radioValue,
                onChanged: (v) => setState(() => _radioValue = v!),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 七、DropdownButton 演示
// ============================================================

class _DropdownDemo extends StatefulWidget {
  const _DropdownDemo();

  @override
  State<_DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<_DropdownDemo> {
  String _selected = 'flutter';

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
          DropdownButton<String>(
            value: _selected,
            items: const [
              DropdownMenuItem(value: 'flutter', child: Text('Flutter')),
              DropdownMenuItem(value: 'dart', child: Text('Dart')),
              DropdownMenuItem(value: 'react', child: Text('React')),
              DropdownMenuItem(value: 'vue', child: Text('Vue')),
            ],
            onChanged: (v) => setState(() => _selected = v!),
            elevation: 2,
          ),
          const SizedBox(height: 8),
          Text('已选择: $_selected', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ============================================================
// 八、Form 演示
// ============================================================

class _FormDemo extends StatefulWidget {
  const _FormDemo();

  @override
  State<_FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<_FormDemo> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '用户名', border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v == null || v.isEmpty ? '请输入用户名' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: '邮箱', border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入邮箱';
                if (!v.contains('@')) return '邮箱格式不正确';
                return null;
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('验证通过！'),
                        behavior: SnackBarBehavior.floating),
                  );
                }
              },
              child: const Text('验证表单'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 九、Navigator 演示
// ============================================================

class _NavigatorDemo extends StatelessWidget {
  const _NavigatorDemo();

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
          const Text('Navigator 演示：点击按钮导航到演示页面',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('push 新页面'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _DemoPage(title: '通过 push 打开的页面')),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('pushReplacement'),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const _DemoPage(title: '替换了上一个页面')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String title;
  const _DemoPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, '返回值'),
              child: const Text('返回上一页 (pop)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 十、GestureDetector 演示
// ============================================================

class _GestureDemo extends StatefulWidget {
  const _GestureDemo();

  @override
  State<_GestureDemo> createState() => _GestureDemoState();
}

class _GestureDemoState extends State<_GestureDemo> {
  String _lastGesture = '点击/双击/长按测试';
  Color _boxColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() { _lastGesture = '单击'; _boxColor = Colors.blue; }),
      onDoubleTap: () => setState(() { _lastGesture = '双击'; _boxColor = Colors.green; }),
      onLongPress: () => setState(() { _lastGesture = '长按'; _boxColor = Colors.orange; }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: _boxColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: _boxColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Center(child: Icon(Icons.touch_app, color: Colors.white, size: 40)),
          ),
          const SizedBox(height: 8),
          Text(_lastGesture, style: TextStyle(color: _boxColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ============================================================
// 十一、Dismissible 演示
// ============================================================

class _DismissibleDemo extends StatefulWidget {
  const _DismissibleDemo();

  @override
  State<_DismissibleDemo> createState() => _DismissibleDemoState();
}

class _DismissibleDemoState extends State<_DismissibleDemo> {
  final _items = List<String>.generate(5, (i) => '项目 ${i + 1}');

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_items.length} 已删除'),
        action: SnackBarAction(label: '撤销', onPressed: () {
          setState(() => _items.insert(index, '项目 ${index + 1}'));
        }),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _items.isEmpty
          ? const Center(child: Text('全部删除完毕', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Dismissible(
                key: ValueKey(_items[index]),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => _removeItem(index),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_items[index]),
                  trailing: const Icon(Icons.swipe, size: 18, color: Colors.grey),
                ),
              ),
            ),
    );
  }
}

// ============================================================
// 十二、InteractiveViewer 演示
// ============================================================

class _InteractiveViewerDemo extends StatelessWidget {
  const _InteractiveViewerDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.orange],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('双指缩放\n平移拖动',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 十三、FutureBuilder 演示
// ============================================================

class _FutureBuilderDemo extends StatefulWidget {
  const _FutureBuilderDemo();

  @override
  State<_FutureBuilderDemo> createState() => _FutureBuilderDemoState();
}

class _FutureBuilderDemoState extends State<_FutureBuilderDemo> {
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
          FutureBuilder<String>(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
            future: _simulateFetch(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('加载中...', style: TextStyle(fontSize: 16)),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text('加载失败: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              }
              return Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(height: 4),
                  const Text('数据加载完成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(snapshot.data ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('重新加载（模拟网络请求）'),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  Future<String> _simulateFetch() async {
    await Future.delayed(const Duration(seconds: 2));
    return '模拟数据加载成功';
  }
}

// ============================================================
// 十四、StreamBuilder 演示
// ============================================================

class _StreamBuilderDemo extends StatefulWidget {
  const _StreamBuilderDemo();

  @override
  State<_StreamBuilderDemo> createState() => _StreamBuilderDemoState();
}

class _StreamBuilderDemoState extends State<_StreamBuilderDemo> {
  late Stream<int> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _createStream();
  }

  Stream<int> _createStream() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

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
          StreamBuilder<int>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('错误: \${snapshot.error}', style: const TextStyle(color: Colors.red));
              }
              return Column(
                children: [
                  Text('最新值: ${snapshot.data ?? "无"}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text('状态: ${snapshot.connectionState.name}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (snapshot.connectionState == ConnectionState.done)
                    const Text('✓ Stream 已关闭', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text('每秒推送一个数字，共发送 10 次。演示 StreamBuilder 的实时数据监听能力。',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ============================================================
// 十五、ValueListenableBuilder 演示
// ============================================================

class _ValueListenableDemo extends StatefulWidget {
  const _ValueListenableDemo();

  @override
  State<_ValueListenableDemo> createState() => _ValueListenableDemoState();
}

class _ValueListenableDemoState extends State<_ValueListenableDemo> {
  final _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

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
          const Text('ValueNotifier + ValueListenableBuilder', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: _counter,
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('计数: $value',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(icon: const Icon(Icons.remove), onPressed: () => _counter.value--),
              const SizedBox(width: 16),
              IconButton.filled(icon: const Icon(Icons.add), onPressed: () => _counter.value++),
            ],
          ),
          const SizedBox(height: 4),
          _TipText(text: 'ValueNotifier 只重建监听它的 Widget，不会造成整棵树重建。比 setState 更精确高效。'),
        ],
      ),
    );
  }
}

// ============================================================
// 十六、Theme 演示
// ============================================================

class _ThemeDemo extends StatelessWidget {
  const _ThemeDemo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前主题色', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _ColorSwatch(color: colorScheme.primary, label: 'primary'),
              _ColorSwatch(color: colorScheme.secondary, label: 'secondary'),
              _ColorSwatch(color: colorScheme.tertiary, label: 'tertiary'),
              _ColorSwatch(color: colorScheme.error, label: 'error'),
              _ColorSwatch(color: colorScheme.surface, label: 'surface'),
            ],
          ),
          const SizedBox(height: 8),
          Text('当前字体主题:',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 4),
          Text('displayLarge', style: theme.textTheme.displayLarge?.copyWith(fontSize: 18)),
          Text('headlineMedium', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16)),
          Text('titleLarge', style: theme.textTheme.titleLarge?.copyWith(fontSize: 14)),
          Text('bodyMedium', style: theme.textTheme.bodyMedium),
          Text('labelSmall', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(height: 32,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
// ============================================================
// 十七、MediaQuery 演示
// ============================================================

class _MediaQueryInfo extends StatelessWidget {
  const _MediaQueryInfo();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MediaQuery 信息:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _InfoRow(label: '屏幕尺寸', value: '${mq.size.width.toStringAsFixed(0)} x ${mq.size.height.toStringAsFixed(0)}'),
        _InfoRow(label: '设备像素比', value: mq.devicePixelRatio.toStringAsFixed(1)),
        _InfoRow(label: '文本缩放', value: mq.textScaleFactor.toStringAsFixed(1)),
        _InfoRow(label: '方向', value: mq.orientation.name),
        _InfoRow(label: '状态栏高度', value: '${mq.padding.top.toStringAsFixed(0)}px'),
        _InfoRow(label: '底部安全区', value: '${mq.padding.bottom.toStringAsFixed(0)}px'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ============================================================
// 十八、LayoutBuilder 演示
// ============================================================

class _LayoutBuilderDemo extends StatelessWidget {
  const _LayoutBuilderDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Column(
            children: [
              Text('容器宽度: ${width.toStringAsFixed(0)}px',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (width > 300)
                Row(
                  children: [
                    Expanded(child: _buildCard('卡片 A', Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCard('卡片 B', Colors.green)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildCard('窄布局卡片 A', Colors.blue),
                    const SizedBox(height: 4),
                    _buildCard('窄布局卡片 B', Colors.green),
                  ],
                ),
              const SizedBox(height: 8),
              _TipText(text: '当前为 ${width > 300 ? "宽布局（Row）" : "窄布局（Column）"}。调整窗口宽度观察切换。'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}

// ============================================================
// 十九、ChangeNotifier 演示
// ============================================================

class _ChangeNotifierDemo extends StatefulWidget {
  const _ChangeNotifierDemo();

  @override
  State<_ChangeNotifierDemo> createState() => _ChangeNotifierDemoState();
}

class _ChangeNotifierDemoState extends State<_ChangeNotifierDemo> {
  final _model = _CounterModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

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
          const Text('ChangeNotifier + ListenableBuilder', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _model,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '计数: ${_model.count}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(icon: const Icon(Icons.remove), onPressed: () => _model.decrement()),
              const SizedBox(width: 16),
              IconButton.filled(icon: const Icon(Icons.add), onPressed: () => _model.increment()),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.exposure_zero), onPressed: () => _model.reset(), tooltip: '归零'),
            ],
          ),
          const SizedBox(height: 4),
          _TipText(text: 'ChangeNotifier + ListenableBuilder 是 Provider 状态管理的底层机制。'),
        ],
      ),
    );
  }
}

class _CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() { _count++; notifyListeners(); }
  void decrement() { _count--; notifyListeners(); }
  void reset() { _count = 0; notifyListeners(); }
}

// ============================================================
// 二十、CustomPainter 演示
// ============================================================

class _DemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final facePaint = Paint()..color = Colors.amber..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = Colors.brown..style = PaintingStyle.stroke..strokeWidth = 2;

    // 脸
    canvas.drawCircle(center, 40, facePaint);
    canvas.drawCircle(center, 40, strokePaint);

    // 眼睛
    canvas.drawCircle(Offset(center.dx - 14, center.dy - 8), 4, Paint()..color = Colors.brown);
    canvas.drawCircle(Offset(center.dx + 14, center.dy - 8), 4, Paint()..color = Colors.brown);

    // 嘴巴（微笑）
    final mouthPath = Path()
      ..moveTo(center.dx - 16, center.dy + 8)
      ..quadraticBezierTo(center.dx, center.dy + 20, center.dx + 16, center.dy + 8);
    canvas.drawPath(mouthPath, Paint()..color = Colors.brown..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
