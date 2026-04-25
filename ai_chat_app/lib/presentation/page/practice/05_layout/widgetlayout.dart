import 'package:flutter/material.dart';

/// ============================================================
/// 05_布局 Widget 大全
/// 本文件演示 Flutter 中所有常用布局 Widget 的用法
/// 每个示例都配有中文解释和直观的视觉效果
/// 运行方式：将本页面设为首页，或通过路由导航到此页面
/// ============================================================

class WidgetLayoutDemo extends StatelessWidget {
  const WidgetLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 布局 Widget 大全'),
        centerTitle: true,
      ),
      // 使用 ListView 使所有内容可滚动
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 一、单子布局 Widget ====================
          _SectionTitle(title: '一、单子布局 Widget（一个 child）'),

          // ---------- 1. Center ----------
          _WidgetTitle(title: '1. Center —— 居中布局'),
          _Explainer(
            text: 'Center 将其子 Widget 在水平和垂直方向上都居中。'
                '是最简单的布局 Widget，常用于将内容放在页面中央。',
          ),
          _CodeBlock(code: 'Center(\n  child: Text("我是居中的文本"),\n)'),
          Center(
            child: _DemoBox(
              color: Colors.blue,
              child: const Text('我是居中的文本',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          _DividerLine(),

          // ---------- 2. Padding ----------
          _WidgetTitle(title: '2. Padding —— 内边距'),
          _Explainer(
            text: 'Padding 在子 Widget 周围添加空白区域。\n'
                'EdgeInsets.all() = 四周相同\n'
                'EdgeInsets.symmetric() = 水平/垂直方向\n'
                'EdgeInsets.only(left,top,right,bottom) = 指定单方向',
          ),
          _CodeBlock(code: 'Padding(\n  padding: EdgeInsets.all(16),\n  child: Text("我有边距"),\n)'),
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                color: Colors.orange,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('橙色区域 = 内容，灰色 = 内边距区域',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 展示不同 EdgeInsets 用法
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: _LabelText(text: 'symm(8,16)'),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24, top: 8, right: 4, bottom: 16),
                    child: _LabelText(text: 'only(24,8,4,16)'),
                  ),
                ),
              ),
            ],
          ),
          _DividerLine(),

          // ---------- 3. Align ----------
          _WidgetTitle(title: '3. Align —— 对齐'),
          _Explainer(
            text: 'Align 将子 Widget 在父容器内按指定位置对齐。\n'
                'Alignment.topLeft = 左上，bottomRight = 右下，center = 居中。\n'
                '也可以使用 Alignment(x, y)，范围 -1 到 1。',
          ),
          _CodeBlock(code: 'Align(\n  alignment: Alignment.topRight,\n  child: Text("右上角"),\n)'),
          Container(
            height: 120,
            color: Colors.grey[200],
            child: const Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _DemoTag(text: 'topLeft', color: Colors.red),
                ),
                Align(
                  alignment: Alignment.center,
                  child: _DemoTag(text: 'center', color: Colors.blue),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _DemoTag(text: 'bottomRight', color: Colors.green),
                ),
                Align(
                  alignment: Alignment(-0.5, -0.8),
                  child: _DemoTag(text: '(-0.5,-0.8)', color: Colors.purple),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 4. SizedBox ----------
          _WidgetTitle(title: '4. SizedBox —— 固定尺寸'),
          _Explainer(
            text: 'SizedBox 给子 Widget 一个固定的宽高。'
                '不给 child 时，可以作为"间隔"使用。'
                'SizedBox.expand() 可以撑满父容器。',
          ),
          _CodeBlock(code: 'SizedBox(width: 100, height: 100, child: ...)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60, height: 60, color: Colors.red,
                child: const Center(child: Text('60', style: TextStyle(color: Colors.white))),
              ),
              const SizedBox(width: 16), // 水平间隔
              Container(
                width: 80, height: 80, color: Colors.green,
                child: const Center(child: Text('80', style: TextStyle(color: Colors.white))),
              ),
              const SizedBox(width: 16), // 水平间隔
              Container(
                width: 100, height: 100, color: Colors.blue,
                child: const Center(child: Text('100', style: TextStyle(color: Colors.white))),
              ),
              // const SizedBox(width: 16),
              // Container(
              //   width: 100, color: Colors.yellow,
              //   child: const SizedBox.expand(
              //     child: Center(child: _LabelText(text:"无设高度就是撑满"),),
              // ),)
            ],
          ),
          const SizedBox(height: 8),
          _Explainer(text: 'SizedBox.expand() S只有父级容器设定约束才有意义 撑满剩余宽度：'),
          Container(
            height: 40,
            color: Colors.grey[200],
            child: const SizedBox.expand(
              child: Center(
                child: _LabelText(text: 'SizedBox.expand 撑满了整个区域'),
              ),
            ),
          ),
          _DividerLine(),

          // ---------- 5. ConstrainedBox ----------
          _WidgetTitle(title: '5. ConstrainedBox —— 附加约束'),
          _Explainer(
            text: 'ConstrainedBox 为子 Widget 附加额外的尺寸约束。\n'
                'BoxConstraints 可以设置 minWidth/maxWidth/minHeight/maxHeight。\n'
                '下面的蓝色盒子最小 150x50，最大 300x100。',
          ),
          _CodeBlock(code: 'ConstrainedBox(\n  constraints: BoxConstraints(\n    minWidth: 150, minHeight: 50,\n    maxWidth: 300, maxHeight: 100,\n  ),\n  child: ...,\n)'),
          Container(
            color: Colors.grey[200],
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 150,
                minHeight: 50,
                maxWidth: 300,
                maxHeight: 100,
              ),
              child: _DemoBox(color: Colors.blue, child: const Text('约束: 最小150x50, 最大300x100',
                  style: TextStyle(color: Colors.white))),
            ),
          ),
          _DividerLine(),

          // ---------- 6. DecoratedBox / BoxDecoration ----------
          _WidgetTitle(title: '6. BoxDecoration —— 装饰容器'),
          _Explainer(
            text: 'BoxDecoration 配合 Container 使用，可以实现：'
                '背景色/渐变、边框、圆角、阴影。\n是 Flutter 中最常用的装饰方式。',
          ),
          _CodeBlock(code: 'Container(\n  decoration: BoxDecoration(\n    color: ...,\n    borderRadius: ...,\n    boxShadow: ...,\n    gradient: ...,\n    border: ...,\n  ),\n)'),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(child: Text('圆角+阴影', style: TextStyle(color: Colors.white))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.amber, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('渐变+边框', style: TextStyle(color: Colors.white))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(child: Text('胶囊形', style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
          _DividerLine(),

          // ==================== 二、多子布局 Widget ====================
          _SectionTitle(title: '二、多子布局 Widget（多个 children）'),

          // ---------- 7. Row ----------
          _WidgetTitle(title: '7. Row —— 水平排列'),
          _Explainer(
            text: 'Row 将 children 沿水平方向排列。\n'
                'mainAxisAlignment = 主轴（水平）对齐方式\n'
                'crossAxisAlignment = 交叉轴（垂直）对齐方式\n'
                '★ 对比下面四种对齐效果：',
          ),
          _CodeBlock(code: 'Row(\n  mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n  crossAxisAlignment: CrossAxisAlignment.center,\n  children: [...],\n)'),
          // 不同对齐方式
          _LabelText(text: 'MainAxisAlignment.start（左对齐）：'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _MiniBox(color: Colors.red),
                _MiniBox(color: Colors.green),
                _MiniBox(color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _LabelText(text: 'MainAxisAlignment.center（居中）：'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniBox(color: Colors.red),
                _MiniBox(color: Colors.green),
                _MiniBox(color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _LabelText(text: 'MainAxisAlignment.spaceBetween（两端对齐）：'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniBox(color: Colors.red),
                _MiniBox(color: Colors.green),
                _MiniBox(color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _LabelText(text: 'MainAxisAlignment.spaceEvenly（等距分布）：'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MiniBox(color: Colors.red),
                _MiniBox(color: Colors.green),
                _MiniBox(color: Colors.blue),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 8. Column ----------
          _WidgetTitle(title: '8. Column —— 垂直排列'),
          _Explainer(
            text: 'Column 将 children 沿垂直方向排列。\n'
                '参数与 Row 相同，但主轴（main）方向变为垂直。\n'
                '★ MainAxisAlignment.spaceAround 效果：',
          ),
          _CodeBlock(code: 'Column(\n  mainAxisAlignment: MainAxisAlignment.spaceAround,\n  children: [...],\n)'),
          Container(
            height: 180,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _DemoTag(text: '第一项', color: Colors.red),
                _DemoTag(text: '第二项', color: Colors.green),
                _DemoTag(text: '第三项', color: Colors.blue),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 9. Expanded ----------
          _WidgetTitle(title: '9. Expanded —— 占满剩余空间'),
          _Explainer(
            text: 'Expanded 必须放在 Row、Column 或 Flex 中使用。'
                '它会占满主轴方向的剩余空间。\n'
                '★ 下图中红色和绿色各占 1 份，蓝色占 2 份',
          ),
          _CodeBlock(code: 'Row(\n  children: [\n    Expanded(flex: 1, child: 红色),\n    Expanded(flex: 1, child: 绿色),\n    Expanded(flex: 2, child: 蓝色),\n  ],\n)'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              children: [
                Expanded(flex: 1, child: _MiniLabel(color: Colors.red, label: '1')),
                Expanded(flex: 1, child: _MiniLabel(color: Colors.green, label: '1')),
                Expanded(flex: 2, child: _MiniLabel(color: Colors.blue, label: '2')),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 10. Flexible ----------
          _WidgetTitle(title: '10. Flexible —— 按比例分配（可溢出）'),
          _Explainer(
            text: 'Flexible 与 Expanded 类似，但 Flexible 不强制子 Widget 填满分配的空间。'
                '子 Widget 可以小于分配的空间（fit: FlexFit.loose）。'
                'Expanded 等价于 Flexible(fit: FlexFit.tight)。',
          ),
          _CodeBlock(code: 'Flexible(\n  flex: 1,\n  fit: FlexFit.loose,  // 宽松，不强制填满\n  child: ...,\n)'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              children: [
                Flexible(
                  flex: 1,
                  child: _MiniLabel(color: Colors.red, label: 'flex=1\n宽松'),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _MiniLabel(color: Colors.blue, label: 'Expanded\n填满'),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 11. Spacer ----------
          _WidgetTitle(title: '11. Spacer —— 弹性间距'),
          _Explainer(
            text: 'Spacer 相当于一个空的 Expanded，用于在 Row/Column 中创建弹性空白。\n'
                '★ 下图中 Spacer 把红色和蓝色推向两端：',
          ),
          _CodeBlock(code: 'Row(\n  children: [\n    Text("左"),\n    Spacer(),  // 自动占满中间空间\n    Text("右"),\n  ],\n)'),
          Container(
            color: Colors.grey[200],
            child: const Row(
              children: [
                _DemoTag(text: '靠左', color: Colors.red),
                Spacer(),
                _DemoTag(text: '靠中', color: Colors.green),
                Spacer(),
                _DemoTag(text: '靠右', color: Colors.blue),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 12. Stack + Positioned ----------
          _WidgetTitle(title: '12. Stack —— 层叠布局'),
          _Explainer(
            text: 'Stack 允许子 Widget 重叠。Positioned 可以精确控制子 Widget 位置。\n'
                '★ 红色是底层（Container），绿色在左上角，蓝色在右下角。\n'
                'Stack 常用于：图片上加文字标签、头像叠加等场景。',
          ),
          _CodeBlock(code: 'Stack(\n  children: [\n    Container(...),       // 底层\n    Positioned(\n      top: 10, left: 10,\n      child: Text("浮动"),  // 上层\n    ),\n  ],\n)'),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Stack(
              children: [
                // 底层 - 红色背景
                Positioned.fill(
                  child: _DemoBox(color: Colors.red, child: const Text('底层红色',
                      style: TextStyle(color: Colors.white, fontSize: 20))),
                ),
                // 左上角
                const Positioned(
                  top: 12,
                  left: 12,
                  child: _DemoTag(text: '左上角标签', color: Colors.green),
                ),
                // 右上角
                const Positioned(
                  top: 12,
                  right: 12,
                  child: _DemoTag(text: '右上角', color: Colors.blue),
                ),
                // 底部居中
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _DemoTag(text: '底部居中', color: Colors.black54),
                  ),
                ),
                // 中心
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: const Text('绝对居中', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ==================== 三、滚动与列表 Widget ====================
          _SectionTitle(title: '三、滚动与列表 Widget'),

          // ---------- 13. ListView ----------
          _WidgetTitle(title: '13. ListView —— 可滚动列表'),
          _Explainer(
            text: 'ListView 是 Flutter 中最常用的滚动列表。\n'
                '★ ListView(children: [...]) = 一次性构建所有项目，适合少量内容\n'
                '★ ListView.builder() = 按需构建，适合大量/无限列表（性能更好）\n'
                '下面展示的是 ListView.builder，仅显示前 20 项：',
          ),
          _CodeBlock(code: 'ListView.builder(\n  itemCount: 20,\n  itemBuilder: (context, index) {\n    return ListTile(title: Text("第 \$index 项"));\n  },\n)'),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[index % Colors.primaries.length],
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text('列表项 #${index + 1}'),
                  subtitle: Text('这是第 ${index + 1} 个子项的描述文本'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ),
          _DividerLine(),

          // ---------- 14. GridView ----------
          _WidgetTitle(title: '14. GridView —— 网格布局'),
          _Explainer(
            text: 'GridView 以网格形式排列子 Widget。\n'
                'GridView.count() = 指定列数\n'
                'GridView.extent() = 指定每项最大宽度，自动计算列数\n'
                '★ 下面展示 3 列的网格：',
          ),
          _CodeBlock(code: 'GridView.count(\n  crossAxisCount: 3,\n  children: [...],\n)'),
          SizedBox(
            height: 200,
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 16,
              childAspectRatio: 2,
              children: List.generate(6, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('项 $index',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ),
          ),
          _DividerLine(),

          // ---------- 15. Wrap ----------
          _WidgetTitle(title: '15. Wrap —— 自动换行'),
          _Explainer(
            text: 'Wrap 类似于 Row + Column 的结合体。'
                '当一行放不下时，自动换到下一行。\n'
                'spacing = 行内间距，runSpacing = 行间间距。\n'
                '常用于标签列表、关键词等场景。',
          ),
          _CodeBlock(code: 'Wrap(\n  spacing: 8,\n  runSpacing: 4,\n  children: [Chip(...), ...],\n)'),
          Container(
            color: Colors.grey[200],
            child: const Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('Flutter')),
                Chip(label: Text('Dart')),
                Chip(label: Text('移动开发')),
                Chip(label: Text('跨平台')),
                Chip(label: Text('前端开发')),
                Chip(label: Text('UI 设计')),
                Chip(label: Text('状态管理')),
                Chip(label: Text('Riverpod')),
                Chip(label: Text('GoRouter')),
                Chip(label: Text('Dio')),
                Chip(label: Text('测试')),
                Chip(label: Text('性能优化')),
                Chip(label: Text('打包发布')),
                Chip(label: Text('CI/CD')),
              ],
            ),
          ),
          _DividerLine(),

          // ==================== 四、布局辅助 Widget ====================
          _SectionTitle(title: '四、布局辅助 Widget'),

          // ---------- 16. AspectRatio ----------
          _WidgetTitle(title: '16. AspectRatio —— 宽高比'),
          _Explainer(
            text: 'AspectRatio 强制子 Widget 保持指定的宽高比。\n'
                '★ aspectRatio: 16/9 = 宽屏比例，aspectRatio: 1/1 = 正方形',
          ),
          _CodeBlock(code: 'AspectRatio(\n  aspectRatio: 16 / 9,\n  child: Container(...),\n)'),
          Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                const _LabelText(text: 'aspectRatio: 16/9（宽屏比例）：'),
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _DemoBox(color: Colors.blue, child: Text('16:9',
                      style: TextStyle(color: Colors.white, fontSize: 24))),
                ),
                const SizedBox(height: 8),
                const _LabelText(text: 'aspectRatio: 1/1（正方形）：'),
                const AspectRatio(
                  aspectRatio: 1 / 1,
                  child: _DemoBox(color: Colors.green, child: Text('1:1',
                      style: TextStyle(color: Colors.white, fontSize: 24))),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 17. FractionallySizedBox ----------
          _WidgetTitle(title: '17. FractionallySizedBox —— 百分比尺寸'),
          _Explainer(
            text: 'FractionallySizedBox 按父容器的百分比来设置子 Widget 的尺寸。\n'
                '★ widthFactor: 0.5 = 父容器宽度的一半\n'
                '★ heightFactor: 0.3 = 父容器高度的 30%',
          ),
          _CodeBlock(code: 'FractionallySizedBox(\n  widthFactor: 0.7,\n  heightFactor: 0.5,\n  child: ...,\n)'),
          Container(
            height: 100,
            color: Colors.grey[200],
            child: const FractionallySizedBox(
              widthFactor: 0.7,
              heightFactor: 0.5,
              child: _DemoBox(color: Colors.purple, child: Text('70%宽度, 50%高度',
                  style: TextStyle(color: Colors.white))),
            ),
          ),
          _DividerLine(),

          // ---------- 18. FittedBox ----------
          _WidgetTitle(title: '18. FittedBox —— 缩放适配'),
          _Explainer(
            text: 'FittedBox 自动缩放子 Widget 以适配可用空间。'
                'BoxFit.contain = 保持比例完整显示\n'
                'BoxFit.cover = 填满容器（可能裁剪）\n'
                'BoxFit.fill = 拉伸填满（可能变形）',
          ),
          _CodeBlock(code: 'FittedBox(\n  fit: BoxFit.contain,\n  child: Text("自动缩放"),\n)'),
          Container(
            height: 80,
            color: Colors.grey[200],
            child: const FittedBox(
              fit: BoxFit.contain,
              child: Text('这段文字会自动缩放到合适大小',
                  style: TextStyle(fontSize: 40)),
            ),
          ),
          _DividerLine(),

          // ---------- 19. LimitedBox ----------
          _WidgetTitle(title: '19. LimitedBox —— 最大尺寸限制'),
          _Explainer(
            text: 'LimitedBox 只在父容器没有约束时才施加最大尺寸限制。'
                'maxWidth/maxHeight 限制了子 Widget 的最大尺寸。',
          ),
          _CodeBlock(code: 'LimitedBox(\n  maxWidth: 200,\n  maxHeight: 80,\n  child: ...,\n)'),
          Container(
            color: Colors.grey[200],
            child: const LimitedBox(
              maxWidth: 200,
              maxHeight: 80,
              child: _DemoBox(color: Colors.teal, child: Text('最大 200x80',
                  style: TextStyle(color: Colors.white))),
            ),
          ),
          _DividerLine(),

          // ---------- 20. Card + ListTile ----------
          _WidgetTitle(title: '20. Card + ListTile —— 卡片和列表项'),
          _Explainer(
            text: 'Card 是 Material Design 的卡片组件，自带圆角、阴影和内边距。\n'
                'ListTile 是标准的列表项组件，包含 leading/title/subtitle/trailing。\n'
                '两者经常配合使用。',
          ),
          _CodeBlock(code: 'Card(\n  child: ListTile(\n    leading: Icon(...),\n    title: Text("标题"),\n    subtitle: Text("副标题"),\n    trailing: Icon(Icons.chevron_right),\n  ),\n)'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('张三'),
                  subtitle: Text('在线 · 最后活跃 5 分钟前'),
                  trailing: Icon(Icons.chat_bubble_outline),
                ),
                Divider(height: 1, indent: 72),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('李四'),
                  subtitle: Text('离线 · 2 小时前'),
                  trailing: Icon(Icons.chat_bubble_outline),
                ),
                Divider(height: 1, indent: 72),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('王五'),
                  subtitle: Text('在线 · 刚刚'),
                  trailing: Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 21. Divider ----------
          _WidgetTitle(title: '21. Divider —— 分割线'),
          _Explainer(
            text: 'Divider 是一条水平分割线。常用于分隔列表项或不同区块。\n'
                'VerticalDivider 是垂直分割线。可以设置颜色、粗细、左右边距。',
          ),
          _CodeBlock(code: 'Divider(\n  color: Colors.grey,\n  thickness: 1,\n  indent: 16,\n  endIndent: 16,\n)'),
          Container(
            color: Colors.grey[200],
            child: const Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('上方内容'),
                ),
                Divider(color: Colors.red, thickness: 2, indent: 16, endIndent: 16),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('下方内容（分割线红色, 粗2, 缩进16）'),
                ),
                Divider(color: Colors.blue, thickness: 1),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('再下方（蓝色细线）'),
                ),
              ],
            ),
          ),
          _DividerLine(),

          // ==================== 五、裁剪与效果 Widget ====================
          _SectionTitle(title: '五、裁剪与视觉效果 Widget'),

          // ---------- 22. ClipRRect / ClipOval ----------
          _WidgetTitle(title: '22. ClipRRect / ClipOval —— 裁剪'),
          _Explainer(
            text: 'ClipRRect = 圆角裁剪，ClipOval = 圆形/椭圆裁剪。\n'
                '★ 左：原图（矩形） ★ 中：ClipRRect（圆角） ★ 右：ClipOval（圆形）',
          ),
          _CodeBlock(code: 'ClipRRect(\n  borderRadius: BorderRadius.circular(16),\n  child: ...,\n)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(width: 80, height: 80, color: Colors.blue),
                  const _LabelText(text: '原图'),
                ],
              ),
              Column(
                children: [
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: _MiniBox(color: Colors.blue),
                  ),
                  const _LabelText(text: 'ClipRRect\n圆角16'),
                ],
              ),
              Column(
                children: [
                  const ClipOval(
                    child: _MiniBox(color: Colors.blue),
                  ),
                  const _LabelText(text: 'ClipOval\n圆形'),
                ],
              ),
            ],
          ),
          _DividerLine(),

          // ---------- 23. Opacity ----------
          _WidgetTitle(title: '23. Opacity —— 透明度'),
          _Explainer(
            text: 'Opacity 控制子 Widget 的透明度。0.0 = 完全透明，1.0 = 完全不透明。\n'
                '★ 下面展示了 100%、60%、30% 三种透明度：',
          ),
          _CodeBlock(code: 'Opacity(\n  opacity: 0.5,  // 50% 透明度\n  child: Text("半透明"),\n)'),
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Opacity(opacity: 1.0, child: _MiniBox(color: Colors.red)),
                Opacity(opacity: 0.6, child: _MiniBox(color: Colors.red)),
                Opacity(opacity: 0.3, child: _MiniBox(color: Colors.red)),
              ],
            ),
          ),
          _DividerLine(),

          // ---------- 24. Visibility / Offstage ----------
          _WidgetTitle(title: '24. Visibility / Offstage —— 显隐控制'),
          _Explainer(
            text: 'Visibility 控制子 Widget 的显隐，有三种模式：\n'
                '★ visible = 正常显示\n'
                '★ invisible = 隐藏但占据空间\n'
                '★ gone = 隐藏且不占空间\n'
                'Offstage 隐藏但保持状态（已构建，只是不显示）',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Visibility(visible: true, child: _MiniBox(color: Colors.green)),
                  const _LabelText(text: 'visible'),
                ],
              ),
              Column(
                children: [
                  const Visibility(visible: false, maintainState: true, child: _MiniBox(color: Colors.green)),
                  const _LabelText(text: 'invisible\n(占位)'),
                ],
              ),
              Column(
                children: [
                  const Visibility(visible: false, maintainState: false, child: _MiniBox(color: Colors.green)),
                  const _LabelText(text: 'gone\n(不占位)'),
                ],
              ),
            ],
          ),
          _DividerLine(),

          // ---------- 25. Transform ----------
          _WidgetTitle(title: '25. Transform —— 变换'),
          _Explainer(
            text: 'Transform 可以对子 Widget 进行平移、旋转、缩放、倾斜变换。\n'
                '★ 蓝色 = 原位置，红色 = 旋转 15° 并偏移',
          ),
          _CodeBlock(code: 'Transform(\n  transform: Matrix4.rotationZ(0.3)..translate(10, 10),\n  child: ...,\n)'),
          Container(
            height: 100,
            color: Colors.grey[200],
            child: Stack(children: [
              const Positioned(left: 40, top: 20, child: _DemoTag(text: '原位置', color: Colors.blue)),
              Transform(
                transform: Matrix4.identity()..rotateZ(0.3)..setTranslationRaw(30, 5, 0),
                child: const _DemoTag(text: '旋转+偏移', color: Colors.red),
              ),
            ]),
          ),
          _DividerLine(),

          // ---------- 26. RotatedBox ----------
          _WidgetTitle(title: '26. RotatedBox —— 旋转整倍数'),
          _Explainer(
            text: 'RotatedBox 将子 Widget 旋转 90° 的整倍数。\n'
                'quarterTurns: 1 = 顺时针 90°，2 = 180°，3 = 270°',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                const _MiniLabel(color: Colors.orange, label: '0°'),
                const RotatedBox(quarterTurns: 0, child: _MiniBox(color: Colors.orange)),
              ]),
              Column(children: [
                const _MiniLabel(color: Colors.orange, label: '90°'),
                const RotatedBox(quarterTurns: 1, child: _MiniBox(color: Colors.orange)),
              ]),
              Column(children: [
                const _MiniLabel(color: Colors.orange, label: '180°'),
                const RotatedBox(quarterTurns: 2, child: _MiniBox(color: Colors.orange)),
              ]),
              Column(children: [
                const _MiniLabel(color: Colors.orange, label: '270°'),
                const RotatedBox(quarterTurns: 3, child: _MiniBox(color: Colors.orange)),
              ]),
            ],
          ),
          _DividerLine(),

          // ==================== 六、综合实战 ====================
          _SectionTitle(title: '六、布局综合实战 —— 仿社交卡片'),
          _Explainer(
            text: '下面综合运用多种布局 Widget，实现一个仿社交应用的帖子卡片。\n'
                '用到了：Card, Row, Column, Stack, Expanded, Padding, ClipRRect, Divider, ListTile',
          ),
          _CodeBlock(code: '// 综合运用多种布局 Widget 构建复杂 UI'),
          _SocialCard(
            avatarUrl: null,
            name: '张三',
            time: '2 小时前',
            content: '今天学习了 Flutter 布局，感觉 Stack + Positioned 实现层叠效果非常强大！'
                'Row + Expanded 可以轻松实现自适应布局。',
            imageCount: 3,
          ),
          const SizedBox(height: 8),
          _SocialCard(
            avatarUrl: null,
            name: '李四的旅行日记',
            time: '昨天 14:30',
            content: '分享一张旅途中的照片，风景很美~',
            imageCount: 1,
          ),
          _DividerLine(),

          // ---------- 总结 ----------
          _SectionTitle(title: '总结'),
          _Explainer(
            text: 'Flutter 布局的核心原则：\n\n'
                '1. 约束向下，大小向上 — 父 Widget 告诉子 Widget "你能有多大"'
                '，子 Widget 告诉父 Widget "我有多大"\n\n'
                '2. 单子布局用 Center/Padding/Align/SizedBox\n\n'
                '3. 多子布局用 Row/Column/Stack/Wrap\n\n'
                '4. 弹性布局用 Expanded/Flexible/Spacer\n\n'
                '5. 滚动列表用 ListView/GridView\n\n'
                '6. 装饰效果用 BoxDecoration + Container\n\n'
                '记住：组合这些基础 Widget，就能搭建任意复杂的 UI！',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================================
// 以下是辅助组件（可直接复用到你的项目中）
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

/// 代码块样式的文本
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

/// 演示用彩色盒子
class _DemoBox extends StatelessWidget {
  final Color color;
  final Widget child;
  const _DemoBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}

/// 演示用标签（带背景色的文字块）
class _DemoTag extends StatelessWidget {
  final String text;
  final Color color;
  const _DemoTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

/// 小色块（40x40）
class _MiniBox extends StatelessWidget {
  final Color color;
  const _MiniBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 40, height: 40, color: color);
  }
}

/// 带标签的小色块
class _MiniLabel extends StatelessWidget {
  final Color color;
  final String label;
  const _MiniLabel({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// 标签文本（灰色小字）
class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }
}

/// 分割线（带间距）
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

/// 仿社交卡片（综合布局实战）
class _SocialCard extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String time;
  final String content;
  final int imageCount;

  const _SocialCard({
    this.avatarUrl,
    required this.name,
    required this.time,
    required this.content,
    required this.imageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：头像 + 姓名 + 时间
            Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.primaries[name.hashCode % Colors.primaries.length],
                  child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                // 姓名和时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                // 更多按钮
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            // 正文内容
            Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 12),
            // 图片网格
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImages(),
            ),
            const SizedBox(height: 12),
            // 底部操作栏
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(icon: Icons.thumb_up_outlined, label: '点赞'),
                _ActionButton(icon: Icons.chat_bubble_outline, label: '评论'),
                _ActionButton(icon: Icons.share_outlined, label: '分享'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    if (imageCount == 1) {
      return Container(
        height: 180,
        color: colors[0],
        child: const Center(child: Text('📷 图片示意', style: TextStyle(color: Colors.white, fontSize: 24))),
      );
    }
    if (imageCount == 3) {
      return SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(flex: 2, child: Container(color: colors[0])),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: Container(color: colors[1])),
                  const SizedBox(height: 4),
                  Expanded(child: Container(color: colors[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// 社交卡片底部按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
