import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第八章：路由导航完全指南
/// 从 Navigator 到 GoRouter，从基础跳转到 Deep Linking
/// 涵盖：Navigator、命名路由、GoRouter、ShellRoute、
///       路由守卫、转场动画、Deep Linking
/// ============================================================

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
          const Paragraph(
            '① 什么是路由？命令式 vs 声明式\n'
            '② Navigator —— 命令式路由完全指南\n'
            '③ 命名路由 + onGenerateRoute\n'
            '④ GoRouter —— 声明式路由（官方推荐）\n'
            '⑤ 路由传参的四种方式\n'
            '⑥ ShellRoute —— 共用外壳布局\n'
            '⑦ 路由守卫（redirect）\n'
            '⑧ Deep Linking（深度链接）\n'
            '⑨ 页面转场动画\n'
            '⑩ URL 策略与 Web 适配',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. 路由概念
          // ════════════════════════════════════════════════
          const SectionHeader('1. 什么是路由？命令式 vs 声明式', icon: Icons.help_outline),
          const Paragraph(
            '路由（Routing）是"根据当前状态决定显示哪个页面"的机制。\n\n'
            '两种路由范式：\n\n'
            '命令式路由（Imperative）—— "你怎么做"\n'
            '• 你手动调用 Navigator.push() / pop() 来切换页面\n'
            '• 路由栈由你手动管理，像操作一叠盘子\n'
            '• 代表：Navigator 1.0\n'
            '• 优点：直观、控制力强\n'
            '• 缺点：难以处理 Deep Link、Web URL 同步\n\n'
            '声明式路由（Declarative）—— "你应该长什么样"\n'
            '• 你声明"当 URL 是 /profile 时显示 Profile 页"\n'
            '• 框架自动管理路由栈和页面切换\n'
            '• 代表：GoRouter（Navigator 2.0 的封装）\n'
            '• 优点：自动支持 Deep Link、Web URL、浏览器前进后退\n'
            '• 缺点：学习曲线稍陡',
          ),
          const TipBox('新项目统一使用 GoRouter。小 Demo 或学习阶段可以用 Navigator。命令式和声明式可以在同一个项目中混合使用。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 2. Navigator
          // ════════════════════════════════════════════════
          const SectionHeader('2. Navigator —— 命令式路由完全指南', icon: Icons.navigation),
          const Paragraph(
            'Navigator 维护一个路由栈（Route Stack），新页面 push 到栈顶，pop 从栈顶移除。\n\n'
            '核心方法详解：\n\n'
            'push —— 把新页面推入栈顶\n'
            '• 返回 Future<T?>，T 是 pop 时传回的数据类型\n'
            '• 等待用户返回后，可以拿到回传的值\n\n'
            'pop —— 从栈顶移除当前页面\n'
            '• 可选传一个参数作为返回值\n'
            '• 返回数据被 push 的调用方 await 拿到\n\n'
            'pushReplacement —— 替换栈顶页面（不改变栈深度）\n'
            '• 典型场景：登录成功后不能返回到登录页\n\n'
            'pushAndRemoveUntil —— 清除栈中所有页面后推进新页\n'
            '• predicate 决定保留哪些页面\n'
            '• (route) => false 清除所有\n'
            '• (route) => route.isFirst 保留首页\n\n'
            'popUntil —— 持续 pop 直到指定条件\n'
            '• 典型场景：多步表单提交后回到首页',
          ),
          const CodeBlock(
            r'''// ─ push：跳转新页面，接收返回数据 ─
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (context) => const DetailPage(),
    fullscreenDialog: true,  // iOS 显示为模态
    maintainState: true,     // 离开页面时保持状态（默认）
  ),
);
if (result != null) print('返回数据: $result');

// ─ pop：返回并传数据 ─
Navigator.pop(context);              // 直接返回
Navigator.pop(context, '返回数据');  // 带数据返回

// ─ pushReplacement：替换当前页 ─
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomePage()),
);

// ─ pushAndRemoveUntil：清栈跳转 ─
// 退出登录 → 回到登录页，清除所有历史
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const LoginPage()),
  (route) => false,  // 全部清除
);

// ─ popUntil：一直返回到指定页面 ─
Navigator.popUntil(context, ModalRoute.withName('/home'));
Navigator.popUntil(context, (route) => route.isFirst);  // 回到首页

// ─ maybePop：安全 pop（防止弹出根路由）──
Navigator.maybePop(context);

// ─ canPop：检查能否 pop ─
final canGoBack = Navigator.canPop(context);''',
            language: 'Dart',
          ),
          Center(child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const _PushDemoPage()));
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('返回数据: $result')));
              }
            },
            icon: const Icon(Icons.open_in_new), label: const Text('打开详情页（push + pop 传数据）'),
          )),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 3. 命名路由
          // ════════════════════════════════════════════════
          const SectionHeader('3. 命名路由 + onGenerateRoute', icon: Icons.signpost),
          const Paragraph(
            '命名路由通过字符串名称跳转页面，相比构造函数传参更"松耦合"。\n\n'
            '静态 routes：\n'
            '• 在 MaterialApp 中预定义路由表\n'
            '• 使用 Navigator.pushNamed(context, "/detail") 跳转\n'
            '• 使用 arguments 参数传递数据\n\n'
            'onGenerateRoute：\n'
            '• 支持动态创建页面\n'
            '• 根据路由名称和参数动态决定创建哪个页面\n'
            '• 可以添加参数校验和权限检查\n\n'
            'onUnknownRoute：\n'
            '• 匹配不到任何路由时的兜底处理\n'
            '• 常用于显示 404 页面',
          ),
          const CodeBlock(
            r'''// ─ 静态路由表 ─
MaterialApp(
  routes: {
    '/': (context) => const HomePage(),
    '/detail': (context) => const DetailPage(),
    '/settings': (context) => const SettingsPage(),
  },
);
Navigator.pushNamed(context, '/detail', arguments: {'id': 42});

// ─ onGenerateRoute（动态路由）──
MaterialApp(
  onGenerateRoute: (RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    switch (uri.path) {
      case '/user':
        final id = uri.queryParameters['id'];
        return MaterialPageRoute(
          builder: (context) => UserPage(id: id ?? ''),
          settings: settings,
        );
      case '/post':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => PostPage(postId: args?['id'] ?? 0),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
    }
  },
);''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 4. GoRouter
          // ════════════════════════════════════════════════
          const SectionHeader('4. GoRouter —— 声明式路由（Flutter 官方推荐）', icon: Icons.route),
          const Paragraph(
            'GoRouter 是 Flutter 团队推荐的声明式路由方案。它基于 URL 路径，天然支持 Deep Link 和 Web URL。\n\n'
            '核心概念：\n'
            '• 路径模式 —— /user/:id（动态参数）、/search?q=xxx（查询参数）\n'
            '• GoRoute —— 单个路由配置（path + builder/redirect）\n'
            '• ShellRoute —— 外壳路由（嵌套布局）\n'
            '• StatefulShellRoute —— 有状态的嵌套路由（IndexedStack 保持状态）\n'
            '• redirect —— 路由守卫\n\n'
            '导航方法区别：\n'
            '• context.go(path) —— 替换当前路由栈（不增加历史）\n'
            '• context.push(path) —— 添加新页面到栈顶（可返回）\n'
            '• context.pop() —— 返回上一页\n'
            '• context.replace(path) —— 替换当前页面',
          ),
          const CodeBlock(
            r'''// ─ GoRouter 初始化 ─
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,  // 开发时启用调试日志
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) => UserPage(
        id: state.pathParameters['id']!,  // 从 /user/123 提取 id=123
      ),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchPage(
        query: state.uri.queryParameters['q'] ?? '',     // 查询参数
        page: state.uri.queryParameters['page'] ?? '1',
      ),
    ),
  ],
);

// 在 MaterialApp 中使用
MaterialApp.router(
  routerConfig: router,
);

// ─ 导航 ─
context.go('/user/123');           // 直接替换
context.push('/user/456');         // 压栈
context.push('/user/789', extra: {'from': 'list'});  // 带额外数据
context.pop();''',
            language: 'Dart',
          ),
          Center(child: Wrap(spacing: 12, runSpacing: 8, children: [
            ElevatedButton.icon(onPressed: () => context.push('/flutter/08/profile/1'), icon: const Icon(Icons.person), label: const Text('用户 1')),
            ElevatedButton.icon(onPressed: () => context.push('/flutter/08/profile/2'), icon: const Icon(Icons.person), label: const Text('用户 2')),
          ])),
          const SizedBox(height: 8),
          Center(child: ElevatedButton.icon(
            onPressed: () => context.push('/flutter/08/search?q=flutter&page=1'),
            icon: const Icon(Icons.search), label: const Text('查询参数演示'),
          )),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 5. 路由传参
          // ════════════════════════════════════════════════
          const SectionHeader('5. 路由传参的四种方式', icon: Icons.send),
          const Paragraph(
            '① 路径参数（Path Parameters）—— /user/:id\n'
            '• 参数是 URL 的一部分，类型安全较差（都是 String）\n'
            '• 适合：资源 ID、slug 等必传参数\n\n'
            '② 查询参数（Query Parameters）—— ?q=flutter&page=1\n'
            '• 参数在 URL 的 ? 后面\n'
            '• 适合：搜索关键词、分页、筛选、排序等可选参数\n\n'
            '③ extra 参数 —— context.push(path, extra: data)\n'
            '• 传递任意类型的数据，不暴露在 URL 中\n'
            '• 适合：复杂对象、列表、回调函数\n\n'
            '④ Navigator pop 回传 —— Navigator.pop(context, data)\n'
            '• 从目标页返回时带数据\n'
            '• 适合：选择器（城市、日期、联系人）',
          ),
          const CodeBlock(
            r'''// ─ 路径参数 ─
GoRoute(
  path: '/product/:categoryId/:productId',
  builder: (context, state) => ProductPage(
    categoryId: state.pathParameters['categoryId']!,
    productId: state.pathParameters['productId']!,
  ),
);

// ─ 查询参数 ─
GoRoute(
  path: '/list',
  builder: (context, state) => ListPage(
    sortBy: state.uri.queryParameters['sort'] ?? 'newest',
    page: int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1,
  ),
);
context.push('/list?sort=popular&page=3');

// ─ extra 参数 ─
GoRoute(
  path: '/edit',
  builder: (context, state) {
    final post = state.extra as Post;  // 类型安全的转换
    return EditPostPage(post: post);
  },
);
context.push('/edit', extra: Post(title: 'Hello', id: 42));

// ─ pop 回传 ─
// 选择页
final result = await Navigator.push<String>(context, ...);
// 返回
Navigator.pop(context, '选中的城市名');''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 6. 路由守卫
          // ════════════════════════════════════════════════
          const SectionHeader('6. redirect —— 路由守卫', icon: Icons.shield),
          const Paragraph(
            'GoRouter 的 redirect 回调在每次导航前执行。返回 null 表示放行，返回 String 表示重定向到该路径。\n\n'
            '典型场景：\n'
            '① 未登录 → 跳转登录页\n'
            '② 已登录用户在登录页 → 跳转首页\n'
            '③ VIP 页面权限检查\n'
            '④ 旧路径兼容重定向\n\n'
            '注意事项：\n'
            '• redirect 是同步执行的，不能 await\n'
            '• 需要在 redirect 外部预加载认证状态\n'
            '• 避免无限重定向循环（检查当前路径目标路径是否相同）',
          ),
          const CodeBlock(
            r'''GoRouter(
  redirect: (context, state) {
    final isLoggedIn = AuthService.isLoggedIn;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final intendedPath = state.matchedLocation;

    // 1. 未登录 + 不在认证页 → 跳转登录
    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login?redirect=$intendedPath';  // 保存意图
    }

    // 2. 已登录 + 在登录页 → 跳转首页
    if (isLoggedIn && isAuthRoute) {
      return state.uri.queryParameters['redirect'] ?? '/';
    }

    // 3. 放行
    return null;
  },
  routes: [
    GoRoute(path: '/auth/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    // ...
  ],
);''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 7. ShellRoute
          // ════════════════════════════════════════════════
          const SectionHeader('7. ShellRoute —— 嵌套布局', icon: Icons.layers),
          const Paragraph(
            'ShellRoute 在多个子路由外面套一个"外壳"。切换子路由时外壳保持不变。\n\n'
            '典型场景：\n'
            '• 底部导航栏（BottomNavigationBar）切换 Tab\n'
            '• 侧边栏导航（NavigationRail）\n'
            '• 带有统一 Header/Footer 的多页面\n\n'
            'StatefulShellRoute.indexedStack：\n'
            '• 每个 Branch 有独立的 Navigator 栈\n'
            '• 切换 Tab 时保持页面状态（滚动位置、输入内容不丢）\n'
            '• 底层使用 IndexedStack 保持所有 Branch 存活',
          ),
          const CodeBlock(
            r'''// ─ StatefulShellRoute（推荐：保持 Tab 状态）──
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Scaffold(
      body: navigationShell,  // 根据当前 index 显示对应 branch
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex, // true=回到根页
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/home', builder: (ctx, state) => const HomePage()),
        // 子路由（在 Tab 内部导航）
        GoRoute(path: '/home/detail/:id', builder: (ctx, state) => const DetailPage(id: '')),
      ],
    ),
    StatefulShellBranch(
      routes: [GoRoute(path: '/search', builder: (ctx, state) => const SearchPage('', ''))],
    ),
    StatefulShellBranch(
      routes: [GoRoute(path: '/profile', builder: (ctx, state) => const ProfilePage(id: ''))],
    ),
  ],
);''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 8. Deep Linking
          // ════════════════════════════════════════════════
          const SectionHeader('8. Deep Linking（深度链接）', icon: Icons.link),
          const Paragraph(
            'Deep Link 让用户从 App 外部直接进入特定页面：\n'
            '• 短信/邮件链接 → 打开订单详情\n'
            '• 扫码 → 进入商品页\n'
            '• 推送通知 → 跳转到消息页\n'
            '• Web URL → 打开 App 对应页面\n\n'
            'GoRouter 天然支持 Deep Link：接收到 URL 后自动解析路径并导航。\n\n'
            '配置步骤：\n'
            '1. 在路由中定义所有需要深度链接的路径\n'
            '2. 配置原生平台的 intent-filter（Android）/ Associated Domains（iOS）\n'
            '3. 测试：模拟器中用 adb 或 xcrun 发送 URL',
          ),
          const CodeBlock(
            r'''<!-- Android: AndroidManifest.xml -->
<activity android:name=".MainActivity">
  <!-- 自定义 scheme: myapp:// -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="open" />
  </intent-filter>

  <!-- Universal Links: https:// -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="example.com" />
  </intent-filter>
</activity>

<!-- iOS: Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>''',
            language: 'XML',
          ),

          // ════════════════════════════════════════════════
          // 9. 转场动画
          // ════════════════════════════════════════════════
          const SectionHeader('9. 页面转场动画', icon: Icons.animation),
          const Paragraph(
            'GoRouter 使用 pageBuilder 替代 builder 可以自定义页面转场动画。\n\n'
            '常用转场效果：\n'
            '• SlideTransition —— 左右滑入滑出（iOS 风格）\n'
            '• FadeTransition —— 淡入淡出\n'
            '• ScaleTransition —— 缩放过渡\n'
            '• RotationTransition —— 旋转过渡\n'
            '• 组合过渡 —— 多个 Transition 嵌套',
          ),
          const CodeBlock(
            r'''GoRoute(
  path: '/fade-page',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const FadeDemoPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);

GoRoute(
  path: '/slide-page',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const SlideDemoPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),  // 从右侧进入
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 10. 总结
          // ════════════════════════════════════════════════
          const SectionHeader('10. 总结与最佳实践', icon: Icons.summarize),
          const Paragraph(
            '路由选择指南：\n'
            '• 新项目 → GoRouter（声明式、Deep Link、Web 友好）\n'
            '• 简单 Demo → Navigator（快速上手）\n'
            '• 复杂 Tab 结构 → StatefulShellRoute（保持 Tab 状态）\n'
            '• 需要权限控制 → redirect 守卫\n'
            '• 自定义过渡效果 → CustomTransitionPage\n\n'
            '核心口诀：\n'
            'push 压栈，pop 弹出\n'
            'go 替换，push 叠加\n'
            'redirect 守卫，extra 传参\n'
            'ShellRoute 嵌套，DeepLink 直通',
          ),

          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 用 Navigator.push/pop 实现「选择城市」页面，返回城市名\n'
            '2. 用 GoRouter + StatefulShellRoute 创建 3 Tab 应用（首页/搜索/我的）\n'
            '3. 用 redirect 实现未登录跳转登录页，登录后跳回到原始目标页面\n'
            '4. 用 CustomTransitionPage 实现从左向右滑入的 iOS 风格过渡\n'
            '5. 配置 Deep Linking：myapp://product/42 → 打开商品详情页\n'
            '6. 用一个 StatefulShellBranch 内实现多级子路由（列表→详情→编辑）',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// 辅助页面
// ════════════════════════════════════════════════════
class _PushDemoPage extends StatelessWidget {
  const _PushDemoPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('详情页'), centerTitle: true),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Paragraph('通过 Navigator.push 打开的页面。点击返回按钮携带数据回去。'),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () => Navigator.pop(context, '来自详情页的数据'),
        icon: const Icon(Icons.arrow_back), label: const Text('返回并传数据')),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('直接返回（不传数据）')),
    ])),
  );
}

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
      Text('第 $page 页 · 查询参数: ?q=$query&page=$page', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('返回')),
    ])),
  );
}
