import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第十一章：Provider 状态管理完全指南
/// 从 setState 到 Provider，构建可维护的应用状态体系
/// 涵盖：ChangeNotifier、Consumer、Selector、MultiProvider、
///       ProxyProvider、Context 扩展方法、性能优化
/// ============================================================

class ProviderDemo extends StatelessWidget {
  const ProviderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _CartProvider()),
        ChangeNotifierProvider(create: (_) => _CounterProvider()),
        ChangeNotifierProvider(create: (_) => _UserProvider()),
      ],
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
          // ═══════════════════════════════════════
          // 章节目录
          // ═══════════════════════════════════════
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 为什么需要状态管理？setState 的局限\n'
            '② ChangeNotifier —— 会"通知"的数据模型\n'
            '③ ChangeNotifierProvider —— 将数据注入 Widget 树\n'
            '④ context.watch / context.read / context.select\n'
            '⑤ Consumer —— 精确控制重建范围\n'
            '⑥ Selector —— 更细粒度的性能优化\n'
            '⑦ MultiProvider —— 管理多个数据源\n'
            '⑧ ProxyProvider —— 依赖另一个 Provider\n'
            '⑨ Provider.value —— 注入已存在的实例\n'
            '⑩ 架构建议：何时拆分 Provider',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 1. 为什么需要状态管理
          // ═══════════════════════════════════════
          const SectionHeader('1. 为什么需要状态管理？setState 的局限', icon: Icons.warning_amber),
          const Paragraph(
            '前面的教程中，我们用 StatefulWidget + setState 管理状态。这在简单场景下完全够用。'
            '但应用一旦变大，setState 的四个问题就暴露出来：\n\n'
            '🔴 问题 1：状态无法跨组件共享\n'
            '  场景：购物车页面 A 添加商品，购物车页面 B 显示数量。\n'
            '  setState 方案：把数据提到共同的父组件 → 两个页面通过回调传递\n'
            '  痛点：层级一深，回调地狱，新页面接入成本高\n\n'
            '🔴 问题 2：状态提升导致 Widget 树臃肿\n'
            '  场景：10 个页面需要用户信息。\n'
            '  setState 方案：在 MaterialApp 的上层组件维护用户数据。\n'
            '  痛点：这个组件会越来越庞大，违反单一职责原则\n\n'
            '🔴 问题 3：setState 重建整个子树\n'
            '  场景：一个页面 30 个 Widget，只有 1 个需要刷新。\n'
            '  setState 方案：调用 setState，整个 build 方法重新执行\n'
            '  痛点：30 个 Widget 全部重建，造成不必要的性能开销\n\n'
            '🔴 问题 4：测试困难\n'
            '  setState 逻辑和 UI 绑定在一起，单元测试需要构建 Widget 树\n\n'
            'Provider 就是为了解决这四个问题而生的。它的核心思想是——\n'
            '"数据与 UI 分离，通过依赖注入在需要的任何地方访问数据。"',
          ),
          const TipBox(
            '一句话总结：setState 适合「组件的自用状态」（开关、输入框、动画）；'
            'Provider 适合「应用级共享状态」（用户信息、购物车、主题）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 2. ChangeNotifier
          // ═══════════════════════════════════════
          const SectionHeader('2. ChangeNotifier —— 会"通知"的数据模型', icon: Icons.notifications),
          const Paragraph(
            'ChangeNotifier 是 Provider 体系中最核心的类。它来自 flutter/foundation.dart（Flutter 核心库，无需额外导入）。\n\n'
            '核心机制：\n'
            '① 继承 ChangeNotifier\n'
            '② 私有化数据，通过 getter 暴露只读访问\n'
            '③ 修改数据的方法在末尾调用 notifyListeners()\n'
            '④ notifyListeners() 触发所有监听者重建\n\n'
            '这个模式叫"观察者模式"（Observer Pattern）：\n'
            '  • ChangeNotifier = 被观察者（Observable / Subject）\n'
            '  • 监听它的 Widget = 观察者（Observer）\n'
            '  • notifyListeners() = 发出通知\n\n'
            '关键设计原则：\n'
            '① 数据私有（_prefix）—— 外部不能直接修改\n'
            '② getter 返回不可变对象 —— 防止外部绕过通知修改数据\n'
            '③ 修改方法封装业务逻辑 —— 保证数据一致性\n'
            '④ 有变化才调 notifyListeners —— 避免无意义重建',
          ),
          const CodeBlock(
            r'''// ── ChangeNotifier 模板 ──
import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  // ① 数据私有（下划线前缀）
  final List<CartItem> _items = [];

  // ② 只读 getter（暴露不可变视图）
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  // ③ 修改方法：先改数据，再通知
  void addItem(CartItem item) {
    // 检查是否已存在（合并数量）
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();  // 👈 通知所有监听者
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // ④ 无需通知的纯查询方法（不修改数据时可以不调 notifyListeners）
  bool hasItem(String id) => _items.any((item) => item.id == id);
}

// ── 配合不可变数据模型 ──
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({String? id, String? name, double? price, int? quantity}) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            'ChangeNotifier 而不是 ChangeNotifier！这是一个非常容易拼错的单词。'
            'Notifier = "通知者"（来自 notify），不是 Notifier。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 3. ChangeNotifierProvider
          // ═══════════════════════════════════════
          const SectionHeader('3. ChangeNotifierProvider —— 将数据注入 Widget 树', icon: Icons.input),
          const Paragraph(
            'ChangeNotifierProvider 是 Provider 包提供的 Widget。它做三件事：\n\n'
            '① 创建：通过 create 参数创建数据实例（首次访问时才创建，懒加载）\n'
            '② 注入：将实例放入 Element 树，让所有子组件都能访问\n'
            '③ 管理：自动调用 dispose() 销毁实例（与 Widget 树同生命周期）\n\n'
            'Provider 的层级位置很重要：\n'
            '  • 全局共享（如用户信息）→ 放在 MaterialApp 外面\n'
            '  • 页面共享（如购物车）→ 放在页面路由上面\n'
            '  • 局部共享（如表单状态）→ 放在表单组件上面\n\n'
            '层级越低，重建范围越小，性能越好。',
          ),
          const CodeBlock(
            r'''// ── ChangeNotifierProvider 用法 ──
import 'package:provider/provider.dart';

// 全局级别：整个 App 都能访问
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// 页面级别：仅此页面及其子路由能访问
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider(
      create: (_) => CheckoutProvider(),
      child: const CheckoutPage(),
    ),
  ),
);

// ── create vs lazy 参数 ──
ChangeNotifierProvider(
  create: (_) => MyProvider(),   // 创建实例的函数
  lazy: true,                    // 默认 true：首次 watch/read 时才创建
  // lazy: false → 立即创建（即使没人访问）
  child: ...,
);

// ── 使用 Provider.value（实例已存在时）──
final existingProvider = MyProvider();
Provider<MyProvider>.value(
  value: existingProvider,       // 直接传入已创建的实例
  child: ...,
);
// ⚠️ 注意：Provider.value 不会自动 dispose！''',
            language: 'Dart',
          ),
          const TipBox(
            'create 创建的实例会被 Provider 自动 dispose。如果你自己 new 了实例再用 Provider.value 传入，需要你自己管理生命周期（不会自动 dispose）。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 4. context.watch / read / select
          // ═══════════════════════════════════════
          const SectionHeader('4. context.watch / read / select —— 三种访问方式', icon: Icons.touch_app),
          const Paragraph(
            'Provider 在 BuildContext 上扩展了三个方法。理解它们的区别是正确使用 Provider 的关键：\n\n'
            '① context.watch<T>() —— 监听模式（最常用）\n'
            '  返回值：T（数据实例）\n'
            '  行为：当 T 调用 notifyListeners() 时，当前 Widget 自动 rebuild\n'
            '  使用位置：build() 方法内\n'
            '  限制：不能在 initState / 回调 / dispose 中调用\n\n'
            '② context.read<T>() —— 读取模式\n'
            '  返回值：T（数据实例）\n'
            '  行为：只读取数据，不监听变化\n'
            '  使用位置：事件回调（onPressed 等）、initState、dispose\n'
            '  限制：不要在 build() 中用 read 来显示数据——数据变化了 UI 不会更新！\n\n'
            '③ context.select<T, R>(R Function(T)) —— 选择模式（最精确）\n'
            '  返回值：R（你关心的那部分数据）\n'
            '  行为：只有当选择器返回的值变化时才 rebuild\n'
            '  优势：比 watch 更精确，监听的是某个属性而非整个对象',
          ),
          const CodeBlock(
            r'''// ── 三种访问方式对比 ──

// ① watch：数据变化 → 整个 Widget 重建
class CartBadge extends StatelessWidget {
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>(); // 购物车任何变化都会重建
    return Text('${cart.totalCount}');
  }
}

// ② read：只拿数据，不监听（回调中使用）
class AddButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // ✅ 回调中用 read，不监听
        context.read<CartProvider>().addItem(item);
      },
      child: const Text('添加'),
    );
  }
}

// ③ select：只监听某个属性（推荐！）
class CartBadge extends StatelessWidget {
  Widget build(BuildContext context) {
    // ✅ 只有 totalCount 变化时才重建
    final count = context.select<CartProvider, int>(
      (cart) => cart.totalCount,
    );
    return Text('$count');
  }
}

// ── 错误用法 ──
class MyWidget extends StatefulWidget {
  State<MyWidget> createState() => _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {
  void initState() {
    super.initState();
    // ❌ initState 中不能用 watch！
    // final cart = context.watch<CartProvider>();

    // ✅ 正确：用 read
    final cart = context.read<CartProvider>();
    cart.addListener(_onCartChanged);  // 手动监听
  }
}''',
            language: 'Dart',
          ),
          const TipBox(
            '经验法则：build 中用 watch 或 select，回调中用 read。select 比 watch 更精确，应优先使用——它能避免不必要的重建。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 5. Consumer
          // ═══════════════════════════════════════
          const SectionHeader('5. Consumer —— 精确控制重建范围', icon: Icons.zoom_in),
          const Paragraph(
            'context.watch<T>() 会让整个 build 方法重建。如果你的 Widget 很大，只有一小部分需要刷新，'
            '可以用 Consumer 包裹需要刷新的那一小部分。\n\n'
            'Consumer 的三个参数：\n'
            '  • builder: (BuildContext, T, Widget?) → Widget —— 构建函数，每次数据变化都调用\n'
            '  • child: Widget? —— 不变的部分（放在 builder 外面，只创建一次）\n'
            '  • 也可以不传 child，直接在 builder 中构建所有内容\n\n'
            'child 参数的精妙之处：Consumer 每次 rebuild 时，child 参数直接复用（不会重建），'
            '适合放那些完全不依赖数据的静态内容。',
          ),
          const CodeBlock(
            r'''// ── 对比：watch vs Consumer ──

// ❌ watch：整个 Column 重建（包括 Header、Footer）
class BadExample extends StatelessWidget {
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Column(children: [
      const HeavyHeader(),          // 浪费！每次都重建
      Text('${cart.totalCount}'),  // 只有这里需要更新
      const HeavyFooter(),          // 浪费！每次都重建
    ]);
  }
}

// ✅ Consumer：只有计数部分重建
class GoodExample extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(children: [
      const HeavyHeader(),           // 永远不会被重建 ✨
      Consumer<CartProvider>(
        builder: (_, cart, __) => Text('${cart.totalCount}'),
      ),
      const HeavyFooter(),           // 永远不会被重建 ✨
    ]);
  }
}

// ✅ 更好的写法：用 child 参数
class BetterExample extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(children: [
      const HeavyHeader(),
      Consumer<CartProvider>(
        builder: (_, cart, child) {
          return Row(children: [
            child!,                    // 复用静态的 Icon
            Text('${cart.totalCount}'),
          ]);
        },
        child: const Icon(Icons.shopping_cart),  // 只创建一次
      ),
      const HeavyFooter(),
    ]);
  }
}''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 6. Selector
          // ═══════════════════════════════════════
          const SectionHeader('6. Selector —— 更细粒度的性能优化', icon: Icons.tune),
          const Paragraph(
            'Selector 是 Consumer 的升级版。它允许你指定"我只关心数据的哪一部分"。\n\n'
            '泛型参数：Selector<ProviderType, SelectedType>\n'
            '  • ProviderType —— Provider 的类型\n'
            '  • SelectedType —— 你关心的数据类型\n\n'
            'Selector 的三个关键参数：\n'
            '  • selector: (context, provider) → selected —— 选择函数，提取你关心的值\n'
            '  • builder: (context, selected, child) → Widget —— 构建函数\n'
            '  • shouldRebuild: (prev, next) → bool —— 判断是否需要重建（默认用 != 比较）\n\n'
            '使用场景：\n'
            '  • 只需要 cart.totalCount → 不需要 cart.items 变化时重建\n'
            '  • 只需要 user.isLoggedIn → 不需要 user.profile 变化时重建\n'
            '  • 只需要 settings.themeMode → 不需要 settings.locale 变化时重建',
          ),
          const CodeBlock(
            r'''// ── Selector 完整用法 ──
Selector<CartProvider, int>(
  // selector：只提取 totalCount
  selector: (context, cart) => cart.totalCount,
  // builder：用提取的值构建 UI
  builder: (context, totalCount, child) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: totalCount > 0 ? Colors.red : Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Text('$totalCount'),
    );
  },
);
// 只有当 totalCount 变化时才重建，items 变化不影响！

// ── 自定义 shouldRebuild（更精确的对比）──
Selector<CartProvider, List<CartItem>>(
  selector: (context, cart) => cart.items,
  shouldRebuild: (prevItems, nextItems) {
    // 只有项目数量变化才重建（修改数量不重建）
    return prevItems.length != nextItems.length;
  },
  builder: (context, items, child) => Text('${items.length} 件'),
);

// ── Selector 嵌套使用 ──
Selector<UserProvider, bool>(
  selector: (_, user) => user.isLoggedIn,
  builder: (_, isLoggedIn, _) {
    if (!isLoggedIn) return const LoginButton();
    // 已登录时进一步用 Selector 监听某个属性
    return Selector<UserProvider, String>(
      selector: (_, user) => user.displayName,
      builder: (_, name, __) => Text('你好，$name'),
    );
  },
);''',
            language: 'Dart',
          ),
          const TipBox(
            'Selector 的性能优势：Provider 内部用 == 对比新旧值，所以 selector 返回的对象最好是不可变且正确实现了 == 操作符的。返回 List 时要注意——如果每次都是新 List 实例，会比较内容而非引用。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 7. MultiProvider
          // ═══════════════════════════════════════
          const SectionHeader('7. MultiProvider —— 组合多个 Provider', icon: Icons.multiple_stop),
          const Paragraph(
            '当应用有多个数据模型时，用 MultiProvider 把它们组合在一起。'
            '它解决的问题是：多个 Provider 嵌套导致的丑陋缩进。\n\n'
            '关键点：\n'
            '① providers 列表是顺序创建的——后面的可以依赖前面的\n'
            '② 支持混合类型：ChangeNotifierProvider、Provider、StreamProvider 等\n'
            '③ 内部使用嵌套结构，但代码看起来扁平\n\n'
            'Provider 依赖的典型场景：\n'
            '  ApiClient 需要 UserProvider 的 token → UserProvider 放前面\n'
            '  CartProvider 需要 UserProvider 的 userId → UserProvider 放前面',
          ),
          const CodeBlock(
            r'''// ── MultiProvider 标准用法 ──
MultiProvider(
  providers: [
    // ① 用户信息（最先创建）
    ChangeNotifierProvider(create: (_) => UserProvider()),

    // ② API 客户端（依赖用户的 token）
    // 用 ProxyProvider 实现依赖
    ChangeNotifierProxyProvider<UserProvider, ApiClient>(
      create: (_) => ApiClient(),
      update: (_, user, api) => api!..updateToken(user.token),
    ),

    // ③ 购物车
    ChangeNotifierProvider(create: (_) => CartProvider()),

    // ④ 非 ChangeNotifier 的数据（只读配置等）
    Provider<AppConfig>(create: (_) => AppConfig()),
  ],
  child: const MaterialApp(...),
);

// ── 等效的嵌套写法（不推荐但有助于理解）──
// MultiProvider 内部就是一层层嵌套
ChangeNotifierProvider(
  create: (_) => UserProvider(),
  child: ChangeNotifierProxyProvider<UserProvider, ApiClient>(
    create: (_) => ApiClient(),
    update: (_, user, api) => api!..updateToken(user.token),
    child: ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(...),
    ),
  ),
);''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 8. ProxyProvider
          // ═══════════════════════════════════════
          const SectionHeader('8. ProxyProvider —— 依赖另一个 Provider', icon: Icons.link),
          const Paragraph(
            'ProxyProvider 解决"B 需要 A 的数据"的问题。它有几种变体：\n\n'
            '① ProxyProvider<A, B> —— B 依赖 A，A 变化时重建 B（B 不是 ChangeNotifier）\n'
            '② ChangeNotifierProxyProvider<A, B> —— B 依赖 A，B 是 ChangeNotifier\n'
            '③ ProxyProvider2<A, B, C> —— C 依赖 A 和 B\n'
            '④ ProxyProvider3<A, B, C, D> —— D 依赖 A、B、C\n\n'
            '核心参数：\n'
            '  • create: (_) => B —— 首次创建 B\n'
            '  • update: (_, A?, B) => B —— A 变化时更新 B（A 可能为 null）\n\n'
            '典型场景：\n'
            '  • ApiClient 需要实时更新 token（token 存在 UserProvider 中）\n'
            '  • ViewModel 需要依赖多个数据源聚合数据',
          ),
          const CodeBlock(
            r'''// ── ChangeNotifierProxyProvider 完整示例 ──
// UserProvider 存 token
class UserProvider extends ChangeNotifier {
  String? _token;
  String? get token => _token;

  void login(String token) { _token = token; notifyListeners(); }
  void logout() { _token = null; notifyListeners(); }
}

// ApiClient 需要 token 来发请求
class ApiClient extends ChangeNotifier {
  String? _token;
  List<String> _data = [];

  void updateToken(String? token) {
    if (_token != token) {
      _token = token;
      notifyListeners();  // token 变了也通知 UI
    }
  }

  Future<void> fetchData() async {
    if (_token == null) throw Exception('未登录');
    _data = await http.get('/api/data', headers: {'Authorization': 'Bearer $_token'});
    notifyListeners();
  }
}

// 用 ChangeNotifierProxyProvider 连接二者
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProxyProvider<UserProvider, ApiClient>(
      create: (_) => ApiClient(),
      update: (_, userProvider, apiClient) {
        // userProvider 变化时自动更新 apiClient 的 token
        return apiClient!..updateToken(userProvider.token);
      },
    ),
  ],
  child: const MyApp(),
);
// 用户登录/登出 → UserProvider 变化 → ProxyProvider 自动更新 ApiClient → UI 刷新''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 9. 交互演示
          // ═══════════════════════════════════════
          const SectionHeader('🧪 交互演示：Provider 购物车', icon: Icons.shopping_cart),
          const Paragraph(
            '下面是一个完整的 Provider 示例。注意这几个组件都是 StatelessWidget —— '
            '但它们能响应数据变化！这就是 Provider 最强大的特性。\n\n'
            '这个演示包含三个独立的 Provider：\n'
            '① CartProvider —— 购物车（增删商品）\n'
            '② CounterProvider —— 计数器（增减重置）\n'
            '③ UserProvider —— 用户登录状态',
          ),
          const SizedBox(height: 8),
          const _CartDemo(),
          const SizedBox(height: 16),
          const _CounterDemo(),
          const SizedBox(height: 16),
          const _UserDemo(),
          const OutputBox(
            '三个 Demo 各自使用不同的 Provider，互不影响。\n'
            'Consumer 精确刷新 → 只有数据变化的部分重建。\n'
            'context.read 在按钮回调中使用 → 不触发监听。',
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 10. Provider vs 其他方案
          // ═══════════════════════════════════════
          const SectionHeader('10. Provider vs 其他状态管理方案', icon: Icons.compare_arrows),
          const Paragraph(
            'Flutter 社区有丰富的状态管理方案。了解各方案的特点，才能做出正确的技术选型：\n\n'
            '📌 setState —— 组件内部状态\n'
            '  适用：开关、折叠、表单输入等局部状态\n'
            '  优点：零学习成本，代码简单\n'
            '  缺点：不能跨组件共享，性能差（重建整树）\n\n'
            '📌 Provider —— 推荐方案（官方推荐）\n'
            '  适用：中小型应用的全局/共享状态\n'
            '  优点：官方推荐，理解成本低，性能好\n'
            '  缺点：大型应用（50+ Provider）管理困难\n\n'
            '📌 Riverpod —— Provider 的精神续作\n'
            '  适用：中大型应用，需要编译时安全\n'
            '  优点：编译时检查、自动处理依赖、不依赖 BuildContext\n'
            '  缺点：学习曲线比 Provider 陡\n\n'
            '📌 Bloc/Cubit —— 事件驱动\n'
            '  适用：中大型应用，团队开发，需要严格规范\n'
            '  优点：代码可预测性强，测试友好，事件可追溯\n'
            '  缺点：模板代码多，简单场景过度工程\n\n'
            '📌 Redux —— 单一状态树\n'
            '  适用：React 迁移团队，复杂的状态共享\n'
            '  优点：状态可预测，时间旅行调试\n'
            '  缺点：模板代码极多，Flutter 生态不主流\n\n'
            '📌 GetX —— 一站式方案\n'
            '  适用：快速原型，小团队\n'
            '  优点：路由+状态+依赖注入三合一，开发效率高\n'
            '  缺点：破坏 Flutter 生态约定，大项目维护成本高',
          ),
          const TipBox(
            '选择建议：新手/小项目 → Provider；需要类型安全 → Riverpod；团队协作/严格流程 → Bloc；快速原型 → GetX。本项目使用 Provider 作为主要方案。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ═══════════════════════════════════════
          // 11. 架构建议
          // ═══════════════════════════════════════
          const SectionHeader('11. Provider 架构最佳实践', icon: Icons.architecture),
          const Paragraph(
            '① Provider 粒度原则\n'
            '  一个 Provider 只负责一个领域（用户、购物车、设置），不要一个 Provider 包揽所有。\n'
            '  判断标准：两个数据总是一起变化吗？不是 → 拆开。\n\n'
            '② Provider 层级原则\n'
            '  • 全局（MaterialApp 外）：UserProvider、ThemeProvider、SettingsProvider\n'
            '  • 模块（路由层）：CheckoutProvider、ChatProvider\n'
            '  • 局部（页面内）：FormProvider、AnimationProvider\n'
            '  层级越低越好 → 离开路由自动销毁 → 节省内存\n\n'
            '③ 不可变数据原则\n'
            '  Provider 持有的数据模型推荐用不可变对象（final 字段 + copyWith）。\n'
            '  好处：防止意外修改 + 方便对比 + 易于调试\n\n'
            '④ 异步操作原则\n'
            '  • 异步请求放在 Provider 的方法中\n'
            '  • 用 loading/error 状态字段通知 UI 显示加载/错误界面\n'
            '  • UI 层只负责根据状态展示，不处理异步逻辑\n\n'
            '⑤ 避免循环依赖\n'
            '  如果 A 依赖 B，B 又依赖 A → 拆出一个 C，让 A 和 B 都依赖 C。',
          ),
          const CodeBlock(
            r'''// ── 带异步状态的 Provider 模板 ──
enum LoadState { idle, loading, success, error }

class DataProvider extends ChangeNotifier {
  List<Item> _items = [];
  LoadState _state = LoadState.idle;
  String? _error;

  List<Item> get items => List.unmodifiable(_items);
  LoadState get state => _state;
  String? get error => _error;

  Future<void> fetchItems() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();  // 通知 UI 显示 loading

    try {
      _items = await api.getItems();
      _state = LoadState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();  // 通知 UI 显示结果
  }
}

// UI 层根据状态渲染
Selector<DataProvider, LoadState>(
  selector: (_, p) => p.state,
  builder: (_, state, __) {
    switch (state) {
      case LoadState.loading: return const CircularProgressIndicator();
      case LoadState.error: return Text('错误: ${context.read<DataProvider>().error}');
      case LoadState.success: return const DataList();
      case LoadState.idle: return const Text('点击加载');
    }
  },
);''',
            language: 'Dart',
          ),
          const DividerLine(),

          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 创建 TodoProvider（ChangeNotifier），提供 addTodo/removeTodo/toggleTodo 方法\n'
            '2. 用 ChangeNotifierProvider 注入，用 Selector 精确监听未完成任务数量\n'
            '3. 创建 ThemeProvider，用 ProxyProvider 让 SettingsProvider 的变化自动同步到 ThemeProvider\n'
            '4. 将现有项目中的 SettingsProvider 改造成 Provider 架构（参考项目中已有的实现）\n'
            '5. 实现带异步状态的 UserProvider（登录/注册/登出 + loading/error 状态）\n'
            '6. 用 context.select 替代 context.watch，优化不必要的重建',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Provider 数据模型
// ═══════════════════════════════════════════════

/// ── 购物车 Provider ──
class _CartProvider extends ChangeNotifier {
  final List<_CartItem> _items = [];

  List<_CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void add(String name, double price) {
    final idx = _items.indexWhere((i) => i.name == name);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(_CartItem(name: name, price: price));
    }
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class _CartItem {
  final String name;
  final double price;
  final int quantity;
  const _CartItem({required this.name, required this.price, this.quantity = 1});
  _CartItem copyWith({int? quantity}) => _CartItem(name: name, price: price, quantity: quantity ?? this.quantity);
}

/// ── 计数器 Provider ──
class _CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() { _count++; notifyListeners(); }
  void decrement() { if (_count > 0) _count--; notifyListeners(); }
  void reset() { _count = 0; notifyListeners(); }
}

/// ── 用户 Provider ──
class _UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _name = '';

  bool get isLoggedIn => _isLoggedIn;
  String get name => _name;

  void login() { _isLoggedIn = true; _name = '张三'; notifyListeners(); }
  void logout() { _isLoggedIn = false; _name = ''; notifyListeners(); }
}

// ═══════════════════════════════════════════════
// 交互演示 Widget
// ═══════════════════════════════════════════════

/// ── 购物车 Demo ──
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
          // 标题行
          Row(children: [
            const Icon(Icons.shopping_cart, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('购物车 Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            // 用 Selector 精确监听 totalCount
            Selector<_CartProvider, int>(
              selector: (_, cart) => cart.totalCount,
              builder: (_, count, __) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                child: Text('$count 件', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          // 商品列表（Consumer 监听）
          Consumer<_CartProvider>(
            builder: (_, cart, __) {
              if (cart.items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('购物车是空的', style: TextStyle(color: Colors.grey))),
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
                    title: Text(item.name),
                    subtitle: Text('¥${item.price.toStringAsFixed(2)} x${item.quantity}'),
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
          // 总价（Selector 精确监听）
          Selector<_CartProvider, double>(
            selector: (_, cart) => cart.totalPrice,
            builder: (_, total, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(children: [
                const Text('合计：', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('¥${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.read<_CartProvider>().clear(),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('清空'),
                ),
              ]),
            ),
          ),
          // 添加按钮
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AddBtn(label: '西瓜', price: 3.5, icon: Icons.water_drop),
              _AddBtn(label: '牛奶', price: 5.0, icon: Icons.local_drink),
              _AddBtn(label: '面包', price: 8.0, icon: Icons.bakery_dining),
              _AddBtn(label: '鸡蛋', price: 1.5, icon: Icons.egg),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final String label;
  final double price;
  final IconData icon;
  const _AddBtn({required this.label, required this.price, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加 $label (¥$price)',
      child: Material(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.read<_CartProvider>().add(label, price),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Icon(icon, color: Colors.green, size: 22),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.green)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// ── 计数器 Demo ──
class _CounterDemo extends StatelessWidget {
  const _CounterDemo();

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
          const Row(children: [
            Icon(Icons.plus_one, color: Colors.orange),
            SizedBox(width: 8),
            Text('计数器 Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Center(
            child: Selector<_CounterProvider, int>(
              selector: (_, counter) => counter.count,
              builder: (_, count, __) => Text(
                '$count',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: count > 10 ? Colors.red : Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FilledButton.tonal(
              onPressed: () => context.read<_CounterProvider>().decrement(),
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () => context.read<_CounterProvider>().increment(),
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => context.read<_CounterProvider>().reset(),
              child: const Text('重置'),
            ),
          ]),
        ],
      ),
    );
  }
}

/// ── 用户登录 Demo ──
class _UserDemo extends StatelessWidget {
  const _UserDemo();

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
          const Row(children: [
            Icon(Icons.person, color: Colors.purple),
            SizedBox(width: 8),
            Text('用户登录 Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Selector<_UserProvider, bool>(
            selector: (_, user) => user.isLoggedIn,
            builder: (_, isLoggedIn, __) {
              if (isLoggedIn) {
                final name = context.select<_UserProvider, String>((u) => u.name);
                return Row(children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Text('已登录：$name', style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () => context.read<_UserProvider>().logout(),
                    child: const Text('登出'),
                  ),
                ]);
              }
              return Row(children: [
                const Icon(Icons.login, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('未登录', style: TextStyle(color: Colors.grey)),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.read<_UserProvider>().login(),
                  child: const Text('登录'),
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }
}
