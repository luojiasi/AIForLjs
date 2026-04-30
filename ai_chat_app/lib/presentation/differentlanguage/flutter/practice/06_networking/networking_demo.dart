import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第六章：网络请求 (Networking)
class NetworkingDemo extends StatefulWidget {
  const NetworkingDemo({super.key});
  @override
  State<NetworkingDemo> createState() => _NetworkingDemoState();
}

class _NetworkingDemoState extends State<NetworkingDemo> {
  String _data = '点击下方按钮体验不同 HTTP 方法的请求效果';
  bool _loading = false;

  Future<void> _simGet() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final json = {'userId': 1, 'id': 101, 'title': 'Flutter 入门教程',
      'body': 'GET 用于获取资源。数据通过 URL 参数传递，不应携带请求体。'};
    setState(() {
      _data = 'GET 200 OK\n${const JsonEncoder.withIndent("  ").convert(json)}';
      _loading = false;
    });
  }

  Future<void> _simPost() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _data = 'POST 201 Created\n{\n  "id": 101,\n  "status": "success",\n  "message": "资源创建成功"\n}';
      _loading = false;
    });
  }

  Future<void> _simPut() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _data = 'PUT 200 OK\n{\n  "id": 1,\n  "title": "已更新",\n  "status": "updated"\n}';
      _loading = false;
    });
  }

  Future<void> _simDelete() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _data = 'DELETE 204 No Content\n{}  // 删除成功，无响应体';
      _loading = false;
    });
  }

  Future<void> _simError() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _data = 'HTTP 408 Request Timeout\n\n[原因] 服务器在时限内未收到完整请求\n[建议] 检查网络或稍后重试';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第6章 · 网络请求'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph('① HTTP 请求解剖 ② Uri 构建 ③ http 包 ④ Dio 包 ⑤ JSON 序列化 ⑥ 错误处理 ⑦ 加载状态 ⑧ API 密钥管理 ⑨ CORS 与 Web ⑩ RESTful & GraphQL'),
          const DividerLine(),

          // ── 1. HTTP 请求解剖 ──
          const SectionHeader('1. HTTP 请求解剖', icon: Icons.call_split),
          const Paragraph('一个 HTTP 请求包含：URL(协议+域名+路径)、Method(GET/POST/PUT/DELETE)、Headers(认证/内容类型)、Body(POST/PUT 时携带)。响应包含：状态码、响应头、响应体。'),
          const CodeBlock(
            r'''GET https://api.example.com/users/1 HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
{"id":1,"name":"Alice","email":"alice@example.com"}''',
            language: 'HTTP',
          ),
          const Paragraph('状态码速记：2xx 成功 | 3xx 重定向 | 4xx 客户端错误 | 5xx 服务器错误'),
          const TipBox('HTTP 是「无状态」协议 —— 每次请求独立。JWT/Token 用于保持用户登录态。', type: TipType.info),
          const DividerLine(),

          // ── 2. Uri 构建 ──
          const SectionHeader('2. Uri 构建', icon: Icons.link),
          const Paragraph('Uri.parse 解析完整 URL；Uri.https/Uri.http 安全构造带参数的 URL，自动编码特殊字符。'),
          const CodeBlock(
            r'''// Uri.parse —— 解析完整 URL
final uri = Uri.parse('https://api.example.com/users?id=1');

// Uri.https —— 安全构造（推荐！自动编码）
final uri = Uri.https('api.example.com', '/users', {'id': '1', 'page': '2'});

// 动态路径
final uri = Uri.https('api.example.com', '/users/$userId');

// Uri.http 用于本地开发（不带 SSL）
final uri = Uri.http('localhost:8080', '/api/users');''',
            language: 'Dart',
          ),
          const Paragraph('永远使用 Uri.https/Uri.http 而非字符串拼接 —— 避免编码遗漏导致含特殊字符的参数出错。'),
          const DividerLine(),

          // ── 3. http 包 ──
          const SectionHeader('3. http 包详解', icon: Icons.http),
          const Paragraph('Dart 官方轻量级网络包。pubspec.yaml 添加 http: ^1.2.0。语法简洁，适合简单请求。'),
          const CodeBlock(
            r'''import 'package:http/http.dart' as http;

// GET
final res = await http.get(
  Uri.https('jsonplaceholder.typicode.com', '/posts/1'),
  headers: {'Authorization': 'Bearer token123'},
);

// POST（带 JSON body）
final res = await http.post(
  Uri.https('jsonplaceholder.typicode.com', '/posts'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'title': 'Hello', 'userId': 1}),
);

// PUT / PATCH / DELETE 同上
await http.put(uri, headers: {...}, body: '...');
await http.delete(uri, headers: {...});

if (res.statusCode == 200) {
  final data = jsonDecode(res.body) as Map<String, dynamic>;
}''',
            language: 'Dart',
          ),
          const TipBox('简单请求用 http，复杂项目用 Dio。需要拦截器、重试、取消时选 Dio。', type: TipType.tip),
          const DividerLine(),

          // ── 4. Dio 包 ──
          const SectionHeader('4. Dio —— 企业级网络框架', icon: Icons.rocket_launch),
          const Paragraph('Dio 功能全面：拦截器(Interceptor)、自动重试、请求取消、文件上传下载、超时配置。pubspec.yaml 添加 dio: ^5.4.0。'),
          const CodeBlock(
            r'''final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {'Content-Type': 'application/json'},
));

// 拦截器 —— 日志、认证
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer $token';
    print('[请求] ${options.method} ${options.path}');
    handler.next(options);
  },
  onResponse: (response, handler) {
    print('[响应] ${response.statusCode}');
    handler.next(response);
  },
  onError: (error, handler) {
    print('[错误] ${error.message}');
    if (error.type == DioExceptionType.connectionTimeout) {
      // 处理超时
    }
    handler.next(error);
  },
));

// 请求取消
final cancelToken = CancelToken();
dio.get('/posts', cancelToken: cancelToken);
cancelToken.cancel('用户取消了请求');

// 重试（使用 dio_smart_retry）
// dio.interceptors.add(RetryInterceptor(dio: dio, retries: 3));''',
            language: 'Dart',
          ),
          const Paragraph('拦截器极为强大 —— 日志记录、自动刷新 Token、统一错误处理都可在此完成。团队项目建议封装 Dio 单例。'),
          const TipBox('团队项目封装 Dio 单例，统一配置 baseUrl、超时、拦截器，避免到处 new Dio()。', type: TipType.tip),
          const DividerLine(),

          // ── 5. JSON 序列化 ──
          const SectionHeader('5. JSON 序列化 —— fromJson / toJson', icon: Icons.data_object),
          const Paragraph('服务器返回 JSON 字符串，先用 jsonDecode 转为 Map/List，再通过 fromJson 转为类型安全的 Dart 对象。'),
          const CodeBlock(
            r'''// 手动序列化
class User {
  final int id; final String name; final String email;
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
final user = User.fromJson(jsonDecode(response.body));  // 类型安全''',
            language: 'Dart',
          ),
          const Paragraph('大型项目推荐 json_serializable 自动生成序列化代码：pubspec.yaml 添加 json_annotation、json_serializable、build_runner。'),
          const CodeBlock(
            r'''@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'user_name') final String name;  // 字段名映射
  final String? email;
  const User({required this.id, required this.name, this.email});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
// flutter pub run build_runner build 生成 .g.dart''',
            language: 'Dart',
          ),
          const TipBox('json_serializable 自动处理字段重命名、默认值、嵌套序列化，大型项目必用。', type: TipType.tip),
          const DividerLine(),

          // ── 6. 错误处理 ──
          const SectionHeader('6. 错误处理全攻略', icon: Icons.shield),
          const Paragraph('网络请求不可靠，必须有全面的错误处理策略：'),
          const CodeBlock(
            r'''try {
  final res = await http.get(uri).timeout(const Duration(seconds: 15));
  if (res.statusCode == 200) {
    return User.fromJson(jsonDecode(res.body));
  } else if (res.statusCode == 401) {
    throw AuthException('登录已过期');
  } else if (res.statusCode == 404) {
    throw NotFoundException('资源不存在');
  } else if (res.statusCode >= 500) {
    throw ServerException('服务器繁忙');
  }
} on SocketException {
  showError('网络连接失败，请检查网络设置');
} on TimeoutException {
  showError('请求超时，请稍后重试');
} on FormatException {
  showError('数据格式异常');
} catch (e) {
  showError('发生意外错误');
} finally {
  setState(() => _loading = false);
}''',
            language: 'Dart',
          ),
          const Paragraph('常见异常：SocketException(断网) | TimeoutException(超时) | HttpException(HTTP 层) | FormatException(JSON 解析失败) | DioException(Dio 统一封装)'),
          const TipBox('用户可见的错误信息要友好：「网络开小差了」而不是 SocketException。永远不要把异常堆栈展示给用户！', type: TipType.caution),
          const DividerLine(),

          // ── 7. 加载状态 ──
          const SectionHeader('7. 加载状态与用户体验', icon: Icons.motion_photos_on),
          const Paragraph('三种常见模式：简单加载指示器、骨架屏 Skeleton、下拉刷新+加载更多。'),
          const CodeBlock(
            r'''// 1. 加载指示器（简单场景）
if (loading) return const Center(child: CircularProgressIndicator());

// 2. 骨架屏（使用 shimmer 包）
Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
  child: Column(children: [
    Container(height: 16, color: Colors.white),   // 占位条
    SizedBox(height: 8),
    Container(height: 100, color: Colors.white),  // 图片占位
  ]),
);

// 3. 下拉刷新 + 加载更多
RefreshIndicator(
  onRefresh: _fetchData,
  child: ListView.builder(
    itemCount: items.length + (hasMore ? 1 : 0),
    itemBuilder: (_, i) => i == items.length
      ? const Center(child: CircularProgressIndicator())
      : ListTile(title: Text(items[i].name)),
  ),
);''',
            language: 'Dart',
          ),
          const Paragraph('推荐策略：初次加载用骨架屏(Skeleton)，刷新用 RefreshIndicator，加载更多用底部 Indicator。'),
          const TipBox('初次加载用骨架屏比 CircularProgressIndicator 用户体验好很多。shimmer 包轻松实现。', type: TipType.tip),
          const DividerLine(),

          // ── 8. API 密钥管理 ──
          const SectionHeader('8. API 密钥管理', icon: Icons.key),
          const Paragraph('绝不硬编码 API Key！密钥会被反编译泄露。'),
          const CodeBlock(
            r'''// ❌ 错误：硬编码（危险！反编译即泄露）
final apiKey = 'sk-abc123...';

// ✅ 正确：flutter_dotenv + .env 文件（加入 .gitignore!）
await dotenv.load(fileName: '.env');
final apiKey = dotenv.env['API_KEY'] ?? '';

// ✅ 更安全：后端代理转发，API Key 只在服务端''',
            language: 'Dart',
          ),
          const Paragraph('.env 文件必须加入 .gitignore。生产环境用 CI/CD 的环境变量注入。最安全的方式是后端代理转发密钥。'),
          const TipBox('不要把 .env 提交到 git！使用混淆构建 release：flutter build apk --obfuscate。', type: TipType.warning),
          const DividerLine(),

          // ── 9. CORS ──
          const SectionHeader('9. CORS 与 Web 平台', icon: Icons.web),
          const Paragraph('CORS 是浏览器的安全机制。Flutter Web 跨域请求时服务器必须明确允许。移动端没有此限制。'),
          const CodeBlock(
            r'''// 服务器端 CORS (Node.js/Express)
app.use(cors({
  origin: 'https://your-app.com',
  methods: ['GET','POST','PUT','DELETE'],
  allowedHeaders: ['Content-Type','Authorization'],
}));

// Flutter Web 策略：后端配 CORS | 开发环境代理 | nginx 反向代理''',
            language: 'JavaScript',
          ),
          const Paragraph('调试：DevTools -> Network 面板，看 Response Headers 是否有 Access-Control-Allow-Origin。检查 Preflight 请求(OPTIONS)是否成功。'),
          const TipBox('CORS 错误只在浏览器中发生。localhost 开发也需要后端配合配置 CORS。', type: TipType.tip),
          const DividerLine(),

          // ── 10. RESTful & GraphQL ──
          const SectionHeader('10. RESTful 最佳实践 & GraphQL 简介', icon: Icons.account_tree),
          const Paragraph('RESTful 规范：资源用名词复数, HTTP 方法对应操作, 查询参数筛选过滤, 版本控制, 统一返回格式。'),
          const CodeBlock(
            r'''GET    /api/v1/users          // 用户列表
POST   /api/v1/users          // 创建用户
GET    /api/v1/users/:id      // 用户详情
PUT    /api/v1/users/:id      // 更新用户
DELETE /api/v1/users/:id      // 删除用户
GET    /api/v1/users?page=1&per_page=20  // 分页

// GraphQL —— 按需查询，单一端点
// query { user(id: 1) { name email } }
// 只返回你需要的字段，避免 over-fetching''',
            language: 'Text',
          ),
          const Paragraph('GraphQL 优势：按需查询(不多不少)、单一端点、强类型 Schema、适合复杂数据关系。Flutter 中推荐 graphql_flutter 包。'),
          const TipBox('REST 简单直观，适合 CRUD 为主。GraphQL 灵活强大，适合复杂数据聚合。小型项目从 REST 开始。', type: TipType.tip),
          const DividerLine(),

          // ── 🧪 交互演示 ──
          const SectionHeader('🧪 模拟 HTTP 请求演示', icon: Icons.wifi),
          const Paragraph('点击按钮体验 HTTP 方法的请求效果（使用 Future.delayed 模拟网络延迟）：'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            ElevatedButton.icon(onPressed: _loading ? null : _simGet, icon: const Icon(Icons.download), label: const Text('GET (200)')),
            ElevatedButton.icon(onPressed: _loading ? null : _simPost, icon: const Icon(Icons.upload), label: const Text('POST (201)')),
            ElevatedButton.icon(onPressed: _loading ? null : _simPut, icon: const Icon(Icons.edit), label: const Text('PUT (200)')),
            ElevatedButton.icon(onPressed: _loading ? null : _simDelete, icon: const Icon(Icons.delete_outline), label: const Text('DELETE (204)')),
            ElevatedButton.icon(onPressed: _loading ? null : _simError, icon: const Icon(Icons.error_outline), label: const Text('错误 (408)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100])),
          ]),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Container(width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: SelectableText(_data,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent, height: 1.5)),
            ),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph('1. 写 User 类(id, name, email, avatarUrl)实现 fromJson/toJson\n'
              '2. 用 http 请求 https://jsonplaceholder.typicode.com/posts 解析为 List<Post>\n'
              '3. 添加 15 秒超时和完整 try/catch 错误处理\n'
              '4. 用 Dio 拦截器自动添加 Authorization header + 打印日志\n'
              '5. 用 flutter_dotenv 管理 API Key，封装 Dio 单例\n'
              '6. 实现带骨架屏加载效果的列表页面'),
          const TipBox('jsonplaceholder.typicode.com 是免费测试 API。开发时打开 DevTools -> Network 观察请求。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
