import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第八章：路由导航 (Navigation)
class NavigationDemo extends StatelessWidget {
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第8章 · 路由导航'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph('① Navigator  ② 命名路由 / onGenerateRoute  ③ GoRouter  ④ 路由传参  '
              '⑤ ShellRoute  ⑥ Deep Linking  ⑦ 转场动画  ⑧ 路由守卫'),
          const DividerLine(),

          // ── 1. 什么是路由 ──
          const SectionHeader('1. 什么是路由？', icon: Icons.help_outline),
          const Paragraph('路由 = 页面跳转管理。App 像一本书，每个页面是一页，路由就是翻页动作。\n'
              '🔹 命令式（Navigator）：手动 push/pop，你告诉 App 怎么做\n'
              '🔸 声明式（GoRouter）：基于 URL，「/profile 时显示 Profile 页」，你告诉 App 长什么样\n'
              '路由栈是后进先出的堆栈结构。push 向栈顶添加页面，pop 移除栈顶。'),
          const TipBox('命令式 = 你告诉 App 怎么做。声明式 = 你告诉 App 长什么样。声明式更适合 Web/Deep Linking。', type: TipType.tip),

          const DividerLine(),

          // ── 2. Navigator ──
          const SectionHeader('2. Navigator —— 命令式路由', icon: Icons.navigation),
          const Paragraph('Navigator 维护路由栈（页面堆栈）。push 放新页，pop 弹出最上层。就像一叠盘子。'),
          const CodeBlock(
            r'''// push —— 跳转新页面，可返回
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => const DetailPage()),
);
// result 接收 pop 传回来的数据

// pushReplacement —— 替换当前页（登录后不能再回登录页）
Navigator.pushReplacement(
  context, MaterialPageRoute(builder: (context) => const HomePage()),
);

// pushAndRemoveUntil —— 清栈跳转（退出登录回首页）
Navigator.pushAndRemoveUntil(
  context, MaterialPageRoute(builder: (context) => const LoginPage()),
  (route) => false,  // false 清除所有
);

// pop —— 返回上一页，可选传数据
Navigator.pop(context);
Navigator.pop(context, '返回数据');

// popUntil —— 一直回到某路由
Navigator.popUntil(context, ModalRoute.withName('/home'));''',
            language: 'Dart'),
          Center(child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const _PushDemoPage()));
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('返回数据: $result')));
              }
            },
            icon: const Icon(Icons.open_in_new), label: const Text('打开详情页（push + pop 传数据）'),
          )),
          const OutputBox('点击按钮 → Navigator.push 打开详情页 → pop 携带字符串返回'),
          const TipBox('pushAndRemoveUntil 的 predicate 传 (route) => false 清除所有，传 (route) => route.isFirst 保留首页。', type: TipType.tip),

          const DividerLine(),

          // ── 3. 命名路由 ──
          const SectionHeader('3. 命名路由 + onGenerateRoute', icon: Icons.signpost),
          const Paragraph('给路由起名字用名字跳转。onGenerateRoute 支持动态创建页面，适合需要传参的路由。新版 Flutter 推荐 GoRouter。'),
          const CodeBlock(
            r'''// 静态 routes
MaterialApp(
  routes: {
    '/': (context) => const HomePage(),
    '/detail': (context) => const DetailPage(),
  },
);
Navigator.pushNamed(context, '/detail');

// onGenerateRoute（动态传参）
MaterialApp(
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => DetailPage(id: args['id']),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
    }
  },
);''',
            language: 'Dart'),
          const TipBox('onGenerateRoute 返回 null 时会尝试 onUnknownRoute，可用于显示 404 页面。', type: TipType.info),

          const DividerLine(),

          // ── 4. GoRouter ──
          const SectionHeader('4. GoRouter —— 声明式路由（推荐）', icon: Icons.route),
          const Paragraph('官方推荐的路由方案。基于 URL，支持路径参数、查询参数、重定向、嵌套路由、Deep Linking。'),
          const CodeBlock(
            r'''final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) => UserPage(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);

MaterialApp.router(routerConfig: router);

// 导航
context.go('/user/123');          // 替换（不增加栈）
context.push('/user/456');        // 压栈（可返回）
context.go('/search?q=flutter');  // 带查询参数
context.pop();                    // 返回

// 读取参数
// 路径参数: state.pathParameters['id']
// 查询参数: state.uri.queryParameters['q']
// extra:    state.extra''',
            language: 'Dart'),
          Center(child: Wrap(spacing: 12, runSpacing: 8, children: [
            ElevatedButton.icon(onPressed: () => context.push('/flutter/08/profile/1'), icon: const Icon(Icons.person), label: const Text('用户 1')),
            ElevatedButton.icon(onPressed: () => context.push('/flutter/08/profile/2'), icon: const Icon(Icons.person), label: const Text('用户 2')),
          ])),
          const SizedBox(height: 8),
          const OutputBox('路径参数 /user/:id → id 被解析为 "1" 或 "2"'),
          const SizedBox(height: 8),
          Center(child: ElevatedButton.icon(
            onPressed: () => context.push('/flutter/08/search?q=flutter&page=1'),
            icon: const Icon(Icons.search), label: const Text('查询参数演示'),
          )),
          const OutputBox('查询参数 /search?q=flutter&page=1 → q="flutter", page="1"'),

          const DividerLine(),

          // ── 5. 路由传参 ──
          const SectionHeader('5. 路由传参的四种方式', icon: Icons.send),
          const Paragraph('① 构造函数传参（推荐）→ 类型安全\n'
              '② GoRouter extra → context.push(path, extra: data)，在 state.extra 读取\n'
              '③ 路径参数 → /user/:id\n'
              '④ 查询参数 → /search?q=flutter'),
          const CodeBlock(
            r'''// 构造函数传参（最推荐、类型安全）
GoRoute(
  path: '/detail',
  builder: (context, state) => DetailPage(data: state.extra as MyData),
);
context.push('/detail', extra: MyData(id: 1));

// 路径参数
GoRoute(
  path: '/user/:id',
  builder: (context, state) => UserPage(id: state.pathParameters['id']!),
);

// 查询参数
context.go('/search?q=flutter&sort=newest');
// state.uri.queryParameters['q'] 读取

// Navigator pop 回传
final result = await Navigator.push<String>(context, route);
Navigator.pop(context, '回传数据');''',
            language: 'Dart'),
          const TipBox('构造函数传参最安全（编译时检查）。extra 和路径参数是运行时解析，注意判空。', type: TipType.tip),

          const DividerLine(),

          // ── 6. 路由守卫 ──
          const SectionHeader('6. redirect —— 路由守卫', icon: Icons.shield),
          const Paragraph('GoRouter 的 redirect 回调在每次导航时触发。返回 null 放行，返回新路径则重定向。'
              '常用于：未登录跳登录页、已登录用户在登录页跳首页、权限不足跳 403。'),
          const CodeBlock(
            r'''GoRouter(
  redirect: (context, state) {
    final isLoggedIn = AuthManager.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';

    // 未登录 → 跳登录页（保留原始路径以便登录后跳回）
    if (!isLoggedIn && !isLoginRoute) {
      return '/login?redirect=${state.matchedLocation}';
    }

    // 已登录用户在登录页 → 跳回首页
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }

    return null;  // 放行
  },
  routes: [...],
);''',
            language: 'Dart'),
          const TipBox('redirect 中不要做异步操作（await）！GoRouter redirect 是同步的。需异步检查时在初始化时预加载状态。', type: TipType.caution),

          const DividerLine(),

          // ── 7. ShellRoute ──
          const SectionHeader('7. ShellRoute —— 嵌套布局', icon: Icons.layers),
          const Paragraph('ShellRoute 创建「共用外壳」包裹子页面。最典型：底部导航栏切换 Tab 时外壳不变，只替换内容区域。'
              'StatefulShellRoute.indexedStack 为每个 Tab 维护独立 Navigator，切换时保持页面状态（滚动位置、输入内容）。'),
          const CodeBlock(
            r'''// 普通 ShellRoute
ShellRoute(
  builder: (context, state, child) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _calcIndex(state.matchedLocation),
      onTap: (index) => _onTabTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
      ],
    ),
  ),
  routes: [
    GoRoute(path: '/home', builder: (c, s) => const HomePage()),
    GoRoute(path: '/search', builder: (c, s) => const SearchPage()),
  ],
);

// StatefulShellRoute（保留 Tab 状态）
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
      ],
    ),
  ),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (c, s) => const HomePage())]),
    StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (c, s) => const SearchPage())]),
  ],
);''',
            language: 'Dart'),
          const TipBox('StatefulShellRoute 内部用 IndexedStack，每个 branch 独立路由栈。切 Tab 不丢失滚动位置或输入内容。', type: TipType.info),

          const DividerLine(),

          // ── 8. Deep Linking ──
          const SectionHeader('8. Deep Linking（深度链接）', icon: Icons.link),
          const Paragraph('从 App 外部直接打开某个页面。点击短信链接打开订单详情、扫码进入商品页。GoRouter 天然支持。'),
          const CodeBlock(
            r'''<!-- Android: android/app/src/main/AndroidManifest.xml -->
<activity ...>
  <!-- 自定义 scheme -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="open" />
  </intent-filter>
</activity>

<!-- iOS: ios/Runner/Info.plist -->
<key>FlutterDeepLinking</key>
<true/>

<!-- 点击 myapp://open/user/123 → 导航到 /user/:id -->''',
            language: 'XML'),
          const Paragraph('Android 需配置 intent-filter，iOS 需配置 Associated Domains。配置后 GoRouter 自动解析路径导航。'),
          const TipBox('开发用自定义 scheme（myapp://）测试方便。生产用 Universal Links / App Links 体验更好（无弹窗）。', type: TipType.tip),

          const DividerLine(),

          // ── 9. URL 策略 + 转场动画 ──
          const SectionHeader('9. Web URL 策略 & 转场动画', icon: Icons.animation),
          const Paragraph('Flutter Web 两种 URL 策略：PathUrlStrategy（ /home ）和 HashUrlStrategy（ #/home ）。'
              'Path 更美观但需服务器配置 fallback。GoRouter 默认 Path。'),
          const CodeBlock(
            r'''// main.dart 配置 URL 策略
import 'package:flutter_web_plugins/url_strategy.dart';
void main() {
  usePathUrlStrategy(); // 默认 Path，地址栏无 # 号
  runApp(MyApp());
}
// Path: http://localhost/home  (需服务器 try_files 到 index.html)
// Hash: http://localhost/#/home (任何服务器均可)''',
            language: 'Dart'),
          const Paragraph('GoRouter 支持自定义转场动画。使用 pageBuilder 替代 builder + CustomTransitionPage：'),
          const CodeBlock(
            r'''GoRoute(
  path: '/detail',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const DetailPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);

// 常用效果:
// FadeTransition(opacity: animation, child: child)    — 渐变
// ScaleTransition(scale: animation, child: child)      — 缩放
// SlideTransition(position: ..., child: child)         — 滑动''',
            language: 'Dart'),
          const TipBox('Path 策略部署到 Vercel/Nginx 必须配置 fallback 到 index.html，否则刷新 404。', type: TipType.warning),

          const DividerLine(),

          // ── 总结 ──
          const SectionHeader('📝 命令式 vs 声明式', icon: Icons.compare),
          const Paragraph('Navigator：简单直观，不利于 Web/Deep Linking\n'
              'GoRouter：支持 URL、ShellRoute、重定向、转场动画，学习曲线稍陡\n'
              '建议：新项目 / 复杂路由用 GoRouter，简单 Demo 用 Navigator'),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph('1. 用 Navigator.push/pop 实现「选择城市」页面，传回城市名\n'
              '2. 用 GoRouter + StatefulShellRoute 创建 3 Tab 应用\n'
              '3. 用 redirect 实现未登录跳转登录页，登录后跳回原始页面\n'
              '4. 用 CustomTransitionPage 实现从左向右滑入的页面过渡\n'
              '5. 配置 Deep Linking：点击 myapp://product/42 打开商品详情'),
          const TipBox('路由守卫（redirect）中注意避免无限重定向循环——加路由位置判断。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Push Demo Page ──
class _PushDemoPage extends StatelessWidget {
  const _PushDemoPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('详情页'), centerTitle: true),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Paragraph('通过 Navigator.push 打开的页面。'),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: () => Navigator.pop(context, '来自详情页的数据'), icon: const Icon(Icons.arrow_back), label: const Text('返回并传数据')),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('直接返回')),
    ])),
  );
}

// ── Profile Page ──
class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('用户详情'), centerTitle: true),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.person, size: 80, color: Colors.blue),
      const SizedBox(height: 16),
      Text('用户 ID: $userId', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text('路径参数: /user/$userId', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('返回')),
    ])),
  );
}

// ── Search Page ──
class SearchPage extends StatelessWidget {
  final String query;
  final String page;
  const SearchPage({super.key, required this.query, required this.page});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('搜索'), centerTitle: true),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      Text('搜索: $query', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text('第 $page 页 · ?q=$query&page=$page', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('返回')),
    ])),
  );
}
