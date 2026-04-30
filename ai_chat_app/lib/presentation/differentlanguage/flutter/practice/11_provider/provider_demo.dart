import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第十一章：Provider 状态管理
/// 从 setState 到 Provider，构建可维护的应用状态
class ProviderDemo extends StatelessWidget {
  const ProviderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _CartProvider(),
      child: const _ProviderDemoPage(),
    );
  }
}

class _ProviderDemoPage extends StatelessWidget {
  const _ProviderDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第11章 · Provider 状态管理'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① setState 的问题\n② ChangeNotifier —— 数据模型\n③ ChangeNotifierProvider —— 注入数据\n'
            '④ context.watch / context.read\n⑤ Consumer —— 精确刷新\n'
            '⑥ MultiProvider —— 多个 Provider\n⑦ Provider vs setState',
          ),
          const DividerLine(),

          // ── 1. setState 的问题 ──
          const SectionHeader('1. setState 有什么问题？', icon: Icons.warning_amber),
          const Paragraph(
            '前一章我们用 setState + StatefulWidget 管理状态，这在简单场景下够用。'
            '但随着应用变大，问题就来了：\n\n'
            '🔴 问题 1：状态不能跨组件共享\n'
            '  └── 两个不相关的组件想用同一份数据怎么办？\n\n'
            '🔴 问题 2：状态提升导致 Widget 树臃肿\n'
            '  └── 把数据提到父组件 → 父组件变得巨大\n\n'
            '🔴 问题 3：setState 刷新整棵树\n'
            '  └── 数据变了，整个 Widget 全部重建\n\n'
            'Provider 专门解决这些问题！',
          ),
          const TipBox(
            '一句话总结：setState 适合「组件内部的自用状态」；'
            'Provider 适合「需要跨组件共享的应用状态」。',
            type: TipType.info,
          ),

          // ── 2. ChangeNotifier ──
          const DividerLine(),
          const SectionHeader('2. ChangeNotifier —— 状态容器', icon: Icons.notifications),
          const Paragraph(
            'ChangeNotifier 是 Provider 体系中最核心的类。它就是一个「会通知」的数据模型：\n'
            '• 继承 ChangeNotifier\n'
            '• 数据变化时调用 notifyListeners()\n'
            '• 所有监听者会自动收到通知',
          ),
          const CodeBlock(
            "import 'package:flutter/foundation.dart';\n\n"
            '// 1. 创建数据模型，继承 ChangeNotifier\n'
            'class CartProvider extends ChangeNotifier {\n'
            '  // 2. 私有数据\n'
            "  final List<String> _items = ['苹果', '香蕉'];\n\n"
            '  // 3. 公开的 getter（只读方式暴露数据）\n'
            '  List<String> get items => List.unmodifiable(_items);\n'
            '  int get count => _items.length;\n\n'
            '  // 4. 修改数据的方法\n'
            '  void add(String item) {\n'
            '    _items.add(item);\n'
            '    notifyListeners();  // 👈 通知所有监听者刷新！\n'
            '  }\n\n'
            '  void removeAt(int index) {\n'
            '    _items.removeAt(index);\n'
            '    notifyListeners();\n'
            '  }\n'
            '}',
            language: 'Dart',
          ),
          const TipBox(
            '类名叫 ChangeNotifier，不是 ChangeNotifier！\n'
            '这是一个很容易拼错的单词：Notifier（通知者）。',
            type: TipType.caution,
          ),

          // ── 3. ChangeNotifierProvider ──
          const DividerLine(),
          const SectionHeader('3. ChangeNotifierProvider —— 注入数据', icon: Icons.input),
          const Paragraph(
            'ChangeNotifierProvider 是 Provider 包提供的组件。它把数据模型注入到 Widget 树中，'
            '让所有子组件都能访问到同一份数据。',
          ),
          const CodeBlock(
            "import 'package:provider/provider.dart';\n\n"
            '// ChangeNotifierProvider 包裹在顶层，注入数据\n'
            "ChangeNotifierProvider(\n"
            "  create: (_) => CartProvider(),  // 创建数据实例\n"
            '  child: MaterialApp(...),           // 子组件都能访问\n'
            ')\n\n'
            '// 如果整个 App 都需要，就放在 MaterialApp 外面\n'
            '// 如果只需要某个页面用，就放在页面的 build 里',
            language: 'Dart',
          ),
          const Paragraph(
            'create 在 Provider 首次被访问时调用，Provider 会自动管理实例的生命周期'
            '——不需要时自动销毁，避免内存泄漏。',
          ),

          // ── 4. context.watch / context.read ──
          const DividerLine(),
          const SectionHeader('4. context.watch 和 context.read', icon: Icons.touch_app),
          const Paragraph(
            '访问 Provider 中的数据有两种方式：\n\n'
            '🔹 context.watch<T>() —— 监听模式\n'
            '  └── 数据变化时，当前 Widget 自动重建\n\n'
            '🔸 context.read<T>() —— 读取模式\n'
            '  └── 只拿数据，不监听变化\n\n'
            '经验法则：\n'
            '• build() 方法中用 watch —— 界面需要随数据刷新\n'
            '• 事件回调中用 read —— 点击按钮等操作只用拿一次',
          ),
          const CodeBlock(r'''
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // watch：监听购物车数量变化，自动刷新
    final cart = context.watch<CartProvider>();

    return Column(children: [
      Text('购物车: ${cart.count} 件'),
      ElevatedButton(
        onPressed: () {
          // read：只拿数据，不监听
          context.read<CartProvider>().add('新商品');
        },
        child: Text('添加'),
      ),
    ]);
  }
}
''', language: 'Dart'),
          const TipBox(
            'watch 让 StatelessWidget 也能拥有动态界面！'
            '这是 Provider 最强大的特性——不需要 StatefulWidget 也能响应数据变化。',
            type: TipType.tip,
          ),

          // ── 5. Consumer ──
          const DividerLine(),
          const SectionHeader('5. Consumer —— 精确刷新', icon: Icons.zoom_in),
          const Paragraph(
            'watch 会刷新整个 Widget，但有时我们只想刷新一小部分。\n'
            'Consumer 可以「只刷新它包裹的部分」，让性能更好。',
          ),
          const CodeBlock(
            "// ❌ watch 刷新整个组件\n"
            "final cart = context.watch<CartProvider>();\n"
            "return Column(children: [\n"
            "  Header(),               // 也被刷新了（浪费）\n"
            "  Text('\${cart.count}'),  // 只需要刷新这里\n"
            "  Footer(),               // 也被刷新了（浪费）\n"
            "]);\n\n"
            "// ✅ Consumer 只刷新需要变化的部分\n"
            "Column(children: [\n"
            "  const Header(),           // 永远不会被刷新\n"
            "  Consumer<CartProvider>(\n"
            "    builder: (_, cart, __) =>\n"
            "       Text('\${cart.count}'),  // 只刷新 Consumer 内部\n"
            "  ),\n"
            "  const Footer(),           // 永远不会被刷新\n"
            "]);\n\n"
            "// Consumer 的三个参数：\n"
            '// builder: (context, 数据模型, child) => Widget\n'
            '// child: 可选的不变部分（放在 builder 外面，只创建一次）',
            language: 'Dart',
          ),
          const Paragraph(
            'Consumer 的第三个参数 child 在多次重建时保持不变，适合放不变的子组件，'
            '避免每次 rebuild 都重新创建。',
          ),

          // ── 6. MultiProvider ──
          const DividerLine(),
          const SectionHeader('6. MultiProvider —— 多个 Provider', icon: Icons.multiple_stop),
          const Paragraph(
            '当应用有多个数据模型时，用 MultiProvider 把它们组合在一起。'
            '阅读顺序：从上到下，后面的 Provider 能访问前面的。',
          ),
          const CodeBlock(
            "MultiProvider(\n"
            "  providers: [\n"
            "    ChangeNotifierProvider(create: (_) => CartProvider()),\n"
            "    ChangeNotifierProvider(create: (_) => UserProvider()),\n"
            "    Provider(create: (_) => ApiClient()),  // 非 ChangeNotifier\n"
            '  ],\n'
            '  child: MaterialApp(...),\n'
            ')',
            language: 'Dart',
          ),
          const Paragraph(
            'MultiProvider 的 providers 列表按顺序创建。如果 ApiClient 需要 CartProvider，'
            '就把 CartProvider 放在前面。',
          ),

          // ── 7. 交互演示 ──
          const DividerLine(),
          const SectionHeader('🧪 交互演示：购物车', icon: Icons.shopping_cart),
          const Paragraph(
            '下面是一个完整的 Provider 示例。'
            '注意这个组件是 StatelessWidget —— 但它能响应数据变化。'
          ),
          const SizedBox(height: 8),
          const _CartDemo(),

          const OutputBox(
            'cart.count 由 Provider 管理，Consumer 精确刷新计数。\n'
            '点击「添加商品」→ 数据变 → Consumer 自动 rebuild。',
          ),

          // ── 8. Provider vs setState ──
          const DividerLine(),
          const SectionHeader('8. Provider vs setState：怎么选？', icon: Icons.compare_arrows),
          const Paragraph(
            '📌 用 setState（组件内部状态）：\n'
            '  • 开关、折叠、展开等 UI 状态\n'
            '  • 某个输入框的当前值\n'
            '  • 只有这个组件需要的数据\n\n'
            '📌 用 Provider（应用共享状态）：\n'
            '  • 用户登录信息（多个页面都要用）\n'
            '  • 购物车数据（页面 A 加，页面 B 显示）\n'
            '  • 主题、语言偏好（全局生效）\n'
            '  • 任何需要跨组件共享的数据',
          ),
          const TipBox(
            '小项目用 setState 完全够，项目大了再用 Provider。'
            '不要一上来就用 Provider——过度的「架构」也是负担。',
            type: TipType.tip,
          ),

          // ── 小练习 ──
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 创建一个 CounterProvider（ChangeNotifier），提供 increment/decrement/reset 方法\n'
            '2. 用 ChangeNotifierProvider 注入，用 context.watch 读取\n'
            '3. 用 Consumer 精确刷新，外面套 const 组件\n'
            '4. 把 SettingsProvider 改造成 Provider 架构（参考项目中已有的 settings_provider.dart）',
          ),
          const TipBox(
            '提示：context.watch 必须在 build 方法中调用，不能在 initState 或回调中使用。',
            type: TipType.tip,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// ── 交互演示：Provider 购物车 ──
class _CartProvider extends ChangeNotifier {
  final List<String> _items = ['苹果', '香蕉'];

  List<String> get items => List.unmodifiable(_items);
  int get count => _items.length;

  void add(String item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
}

class _CartDemo extends StatelessWidget {
  const _CartDemo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 + 计数（Consumer 精确刷新）
          Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('购物车', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Consumer<_CartProvider>(
                builder: (_, cart, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cart.count} 件',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 商品列表（Consumer 精确刷新）
          Consumer<_CartProvider>(
            builder: (_, cart, __) {
              if (cart.items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('🛒 购物车是空的', style: TextStyle(color: Colors.grey))),
                );
              }
              return Column(
                children: cart.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.shopping_bag, size: 18, color: Colors.blue),
                    ),
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                      onPressed: () => context.read<_CartProvider>().removeAt(i),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AddButton(item: '西瓜', icon: Icons.water_drop),
              const SizedBox(width: 8),
              _AddButton(item: '牛奶', icon: Icons.local_drink),
              const SizedBox(width: 8),
              _AddButton(item: '面包', icon: Icons.bakery_dining),
              const SizedBox(width: 8),
              _AddButton(item: '鸡蛋', icon: Icons.egg),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String item;
  final IconData icon;

  const _AddButton({required this.item, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加 $item',
      child: Material(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.read<_CartProvider>().add(item),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(icon, color: Colors.green, size: 22),
                const SizedBox(height: 2),
                Text(item, style: const TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
