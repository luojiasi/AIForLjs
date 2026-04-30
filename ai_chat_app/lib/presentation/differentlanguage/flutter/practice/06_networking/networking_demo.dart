import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第六章：网络请求完全指南
/// 从 HTTP 基础到企业级网络架构
/// 涵盖：http 包、Dio、JSON 序列化、错误处理、WebSocket、
///       拦截器、缓存策略、安全最佳实践
/// ============================================================

class NetworkingDemo extends StatefulWidget {
  const NetworkingDemo({super.key});
  @override
  State<NetworkingDemo> createState() => _NetworkingDemoState();
}

class _NetworkingDemoState extends State<NetworkingDemo> {
  String _data = '点击下方按钮体验不同 HTTP 方法的请求效果';
  bool _loading = false;
  final List<String> _requestLog = [];

  void _addLog(String msg) {
    setState(() {
      _requestLog.add('[${DateTime.now().toString().substring(11, 19)}] $msg');
      if (_requestLog.length > 30) _requestLog.removeAt(0);
    });
  }

  Future<void> _simGet() async {
    _addLog('发起 GET 请求...');
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final json = {'userId': 1, 'id': 101, 'title': 'Flutter 入门教程', 'body': 'GET 用于获取资源。数据通过 URL 参数传递，不应携带请求体。'};
    setState(() {
      _data = 'GET 200 OK\n${const JsonEncoder.withIndent("  ").convert(json)}';
      _loading = false;
    });
    _addLog('GET 请求完成 (200 OK)');
  }

  Future<void> _simPost() async {
    _addLog('发起 POST 请求，Body: {"title":"Hello"}');
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _data = 'POST 201 Created\n{\n  "id": 101,\n  "status": "success"\n}'; _loading = false; });
    _addLog('POST 请求完成 (201 Created)');
  }

  Future<void> _simPut() async {
    _addLog('发起 PUT 请求（全量更新）');
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() { _data = 'PUT 200 OK\n{\n  "id": 1,\n  "title": "已更新"\n}'; _loading = false; });
  }

  Future<void> _simDelete() async {
    _addLog('发起 DELETE 请求');
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() { _data = 'DELETE 204 No Content\n{}  // 删除成功，无响应体'; _loading = false; });
  }

  Future<void> _simError() async {
    _addLog('模拟超时错误...');
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _data = 'HTTP 408 Request Timeout\n\n请求超时。可能原因：网络慢、服务器过载、DNS 解析慢。'; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第6章 · 网络请求'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① HTTP 协议基础：请求/响应结构\n'
            '② Uri 构建：安全构造 URL\n'
            '③ http 包完整指南\n'
            '④ Dio 企业级框架详解\n'
            '⑤ 拦截器（Interceptor）体系\n'
            '⑥ JSON 序列化完整方案\n'
            '⑦ 错误处理全攻略\n'
            '⑧ 加载状态与用户体验\n'
            '⑨ 文件上传与下载\n'
            '⑩ WebSocket 实时通信\n'
            '⑪ 网络缓存策略\n'
            '⑫ API 安全管理\n'
            '⑬ RESTful vs GraphQL\n'
            '⑭ 测试与调试',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. HTTP 协议基础
          // ════════════════════════════════════════════════
          const SectionHeader('1. HTTP 协议基础', icon: Icons.call_split),
          const Paragraph(
            'HTTP（HyperText Transfer Protocol）是客户端和服务端通信的协议。每次交互由"请求"和"响应"组成。\n\n'
            '请求结构（四个部分）：\n'
            '① 请求行：GET /api/users/1 HTTP/1.1\n'
            '② 请求头（Headers）：Host、Authorization、Content-Type、Accept、User-Agent\n'
            '③ 空行：分隔请求头和请求体\n'
            '④ 请求体（Body）：POST/PUT/PATCH 时携带的数据（JSON、Form、Multipart）\n\n'
            '响应结构（四个部分）：\n'
            '① 状态行：HTTP/1.1 200 OK\n'
            '② 响应头：Content-Type、Content-Length、Set-Cookie、Cache-Control\n'
            '③ 空行\n'
            '④ 响应体：服务器返回的数据\n\n'
            'HTTP 方法（动词）：\n'
            '• GET —— 获取资源（幂等、无请求体、可缓存）\n'
            '• POST —— 创建资源（不幂等、有请求体）\n'
            '• PUT —— 全量更新资源（幂等、有请求体）\n'
            '• PATCH —— 部分更新资源（不幂等、有请求体）\n'
            '• DELETE —— 删除资源（幂等）\n'
            '• HEAD —— 只获取响应头（无响应体）\n'
            '• OPTIONS —— 查询服务器支持的方法（CORS 预检请求）',
          ),
          const CodeBlock(
            r'''┌── 请求 ──┐
GET /api/users/1 HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Accept: application/json

┌── 响应 ──┐
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: max-age=3600
Content-Length: 85

{"id":1,"name":"Alice","email":"alice@example.com"}''',
            language: 'HTTP',
          ),
          const Paragraph('状态码速记：2xx 成功 | 3xx 重定向 | 4xx 客户端错误 | 5xx 服务器错误。'),
          const TipBox('HTTP 是无状态协议，每次请求互相独立。Token/JWT/Cookie 用于保持用户登录态。', type: TipType.info),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 2. Uri
          // ════════════════════════════════════════════════
          const SectionHeader('2. Uri 构建', icon: Icons.link),
          const Paragraph(
            '所有网络请求的第一步是构造 Uri。Flutter 中多种构造方式各有适用场景。\n\n'
            'Uri.parse() —— 解析完整 URL 字符串\n'
            '• 最简单直接\n'
            '• 需要手动编码特殊字符\n\n'
            'Uri.https() / Uri.http() —— 安全工厂方法（推荐）\n'
            '• 自动编码查询参数（空格变 %20，中文变 UTF-8 编码）\n'
            '• 避免注入风险和格式错误\n\n'
            'Uri 组成部分：scheme + authority(host+port) + path + query + fragment\n'
            '例如：https://api.example.com:443/users?id=1#section',
          ),
          const CodeBlock(
            r'''// ❌ 字符串拼接（不安全！特殊字符会出错）
final url = 'https://api.com/search?q=$keyword';  // keyword 含空格时出错

// ✅ Uri.parse —— 完整 URL
final uri = Uri.parse('https://api.example.com/users?id=1&page=2');

// ✅ Uri.https —— 推荐！自动编码参数
final uri = Uri.https(
  'api.example.com',
  '/users',
  {'id': '1', 'page': '2', 'q': 'hello world'},  // 空格自动编码
);

// ✅ 动态路径
final userId = 42;
final uri = Uri.https('api.example.com', '/users/$userId/posts');

// ✅ 本地开发
final uri = Uri.http('localhost:8080', '/api/users');

// 解析返回的 Uri
print(uri.scheme);      // https
print(uri.host);        // api.example.com
print(uri.path);        // /users
print(uri.query);       // id=1&page=2
print(uri.queryParams); // {id: 1, page: 2}''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 3. http 包
          // ════════════════════════════════════════════════
          const SectionHeader('3. http 包完整使用指南', icon: Icons.http),
          const Paragraph(
            'http 是 Dart 官方提供的轻量级网络包（pubspec: http: ^1.2.0）。适合简单到中等复杂度的应用。\n\n'
            '能力清单：\n'
            '• 支持所有 HTTP 方法\n'
            '• 自定义 Headers\n'
            '• multipart 文件上传\n'
            '• Client 类复用连接（性能更好）\n'
            '• StreamedResponse 用于大文件下载\n\n'
            '不足：\n'
            '• 没有内置拦截器\n'
            '• 没有自动重试\n'
            '• 没有请求取消（需配合 CancelableOperation）',
          ),
          const CodeBlock(
            r'''import 'package:http/http.dart' as http;

// ─ 基础用法 ─
final response = await http.get(
  Uri.https('jsonplaceholder.typicode.com', '/posts/1'),
  headers: {'Authorization': 'Bearer $token'},
);
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
}

// ─ POST with JSON body ─
final response = await http.post(
  Uri.https('jsonplaceholder.typicode.com', '/posts'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'title': 'Hello', 'userId': 1}),
);

// ─ 使用 Client 复用连接（推荐用于多次请求）──
final client = http.Client();
try {
  final res1 = await client.get(uri1);
  final res2 = await client.get(uri2);
} finally {
  client.close();  // 必须关闭！
}

// ─ Multipart 文件上传 ─
final request = http.MultipartRequest('POST', uri);
request.fields['title'] = 'My Image';
request.files.add(await http.MultipartFile.fromPath('file', '/path/to/photo.jpg'));
final streamedResponse = await request.send();
final response = await http.Response.fromStream(streamedResponse);''',
            language: 'Dart',
          ),
          const TipBox('频繁发请求时用 Client 类复用底层连接，而不是每次 get/post 都创建新的连接。用完后必须 close()。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 4. Dio
          // ════════════════════════════════════════════════
          const SectionHeader('4. Dio —— 企业级 HTTP 框架', icon: Icons.rocket_launch),
          const Paragraph(
            'Dio 是目前 Flutter 生态中最强大的 HTTP 库（pubspec: dio: ^5.4.0）。几乎所有中大型项目都使用它。\n\n'
            'Dio 的核心优势：\n'
            '① 拦截器链（Interceptor）—— 统一的请求/响应/错误处理\n'
            '② 请求取消（CancelToken）—— 页面销毁时取消未完成的请求\n'
            '③ 自动超时 + 重试 —— connectTimeout / receiveTimeout / sendTimeout\n'
            '④ 文件上传/下载进度 —— onSendProgress / onReceiveProgress 回调\n'
            '⑤ Transformer —— 自动转换请求/响应数据\n'
            '⑥ 并发请求 —— Future.wait 模式\n'
            '⑦ BaseOptions —— 统一的全局配置',
          ),
          const CodeBlock(
            r'''// ─ Dio 初始化 ─
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  sendTimeout: const Duration(seconds: 10),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  // 自动跟随重定向
  followRedirects: true,
  // 最大重定向次数
  maxRedirects: 5,
));

// ─ GET ─
final response = await dio.get(
  '/users',
  queryParameters: {'page': 1, 'limit': 20},
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);

// ─ POST ─
final response = await dio.post('/users', data: {'name': 'John', 'email': 'john@test.com'});

// ─ 请求取消 ─
final cancelToken = CancelToken();
dio.get('/slow-endpoint', cancelToken: cancelToken);
// 页面 dispose 时取消：
cancelToken.cancel('页面已销毁');

// ─ 文件下载（带进度）──
await dio.download(
  'https://example.com/file.pdf',
  '/storage/file.pdf',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      print('下载进度: ${(received / total * 100).toStringAsFixed(1)}%');
    }
  },
);''',
            language: 'Dart',
          ),
          const TipBox('团队项目建议封装 Dio 单例：集中管理 baseUrl、超时、拦截器，避免在业务代码中散落 Dio 配置。', type: TipType.tip),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 5. 拦截器
          // ════════════════════════════════════════════════
          const SectionHeader('5. 拦截器（Interceptor）体系', icon: Icons.settings_input_component),
          const Paragraph(
            '拦截器是 Dio 最强大的功能。它像一个"管道过滤器"，每个请求和响应都会经过拦截器链。\n\n'
            '拦截器类型：\n'
            '• onRequest —— 在请求发送前修改配置（加 Token、加密、日志）\n'
            '• onResponse —— 在响应返回后预处理（解密、数据转换、日志）\n'
            '• onError —— 统一错误处理（Token 过期刷新、网络异常重试）\n\n'
            '拦截器执行顺序：先添加的先执行（栈模式：队列中有多个拦截器按顺序执行）\n'
            '拦截器回调参数中的 handler：\n'
            '• handler.next(modified) —— 传递给下一个拦截器\n'
            '• handler.resolve(response) —— 跳过后续拦截器，直接返回结果\n'
            '• handler.reject(error) —— 跳过后续拦截器，直接进入错误处理',
          ),
          const CodeBlock(
            r'''// ─ 三个核心拦截器 ─

// 1. 认证拦截器
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${AuthService.token}';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token 过期 → 尝试刷新
      AuthService.refreshToken().then((newToken) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        handler.resolve(dio.fetch(err.requestOptions));  // 重试原请求
      }).catchError((e) {
        handler.reject(err);  // 刷新失败，抛出错误
      });
      return;
    }
    handler.next(err);
  }
}

// 2. 日志拦截器
class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, handler) {
    print('→ ${options.method} ${options.path}');
    handler.next(options);
  }
  @override
  void onResponse(Response response, handler) {
    print('← ${response.statusCode} (${response.requestOptions.path})');
    handler.next(response);
  }
  @override
  void onError(DioException err, handler) {
    print('✗ ${err.message} (${err.requestOptions.path})');
    handler.next(err);
  }
}

// 3. 缓存拦截器
class CacheInterceptor extends Interceptor {
  final _cache = <String, Response>{};

  @override
  void onRequest(RequestOptions options, handler) {
    final key = options.uri.toString();
    if (_cache.containsKey(key) && options.method == 'GET') {
      return handler.resolve(_cache[key]!);  // 直接返回缓存
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, handler) {
    _cache[response.requestOptions.uri.toString()] = response;
    handler.next(response);
  }
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 6. JSON 序列化
          // ════════════════════════════════════════════════
          const SectionHeader('6. JSON 序列化完整方案', icon: Icons.data_object),
          const Paragraph(
            '服务器返回的 JSON 是字符串，需要转为 Dart 对象才能类型安全地使用。\n\n'
            '方案对比：\n\n'
            '手动序列化（小项目）：\n'
            '• 手写 fromJson / toJson\n'
            '• 优点：无依赖、代码清晰、零生成\n'
            '• 缺点：字段多了写到手酸、嵌套复杂时容易出错\n\n'
            'json_serializable（中大型项目推荐）：\n'
            '• 通过注解 + build_runner 自动生成序列化代码\n'
            '• 优点：零手写、防止拼写错误、支持嵌套\n'
            '• 缺点：需要额外依赖、需要运行 code generation\n\n'
            'freezed（大型项目）：\n'
            '• 结合 json_serializable + 不可变数据类\n'
            '• 优点：完备的类型系统、copyWith、模式匹配\n'
            '• 缺点：学习曲线',
          ),
          const CodeBlock(
            r'''// ─ 手动序列化（基础）──
class User {
  final int id;
  final String name;
  final String? email;  // 可空字段

  const User({required this.id, required this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String?,  // as String? 处理字段缺失
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (email != null) 'email': email,  // 条件序列化（不序列化 null）
  };
}

// ─ json_serializable（推荐）──
// pubspec.yaml:
// dependencies: json_annotation: ^4.8.0
// dev_dependencies: json_serializable: ^6.7.0, build_runner: ^2.4.0

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'user_name')  // ← 字段名映射
  final String name;
  @JsonKey(defaultValue: '')    // ← 默认值
  final String email;
  @JsonKey(ignore: true)        // ← 不参与序列化
  final bool isSelected;

  const User({required this.id, required this.name, required this.email, this.isSelected = false});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// 运行代码生成：
// dart run build_runner build --delete-conflicting-outputs''',
            language: 'Dart',
          ),
          const TipBox('fromJson 中每个字段都必须强转类型：json["id"] as int。漏掉类型断言会导致运行时类型错误。', type: TipType.caution),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 7. 错误处理
          // ════════════════════════════════════════════════
          const SectionHeader('7. 错误处理全攻略', icon: Icons.shield),
          const Paragraph(
            '网络请求是不可靠的。一个好的错误处理策略是应用质量的基石。\n\n'
            '错误层级：\n'
            '第1层：DioException（Dio 统一异常）\n'
            '第2层：HTTP 状态码错误（401/403/404/500）\n'
            '第3层：业务逻辑错误（code != 0）\n'
            '第4层：未知异常（兜底）',
          ),
          const CodeBlock(
            r'''// ─ 完整的错误处理模式 ─
Future<Result<User>> fetchUser(int id) async {
  try {
    final response = await dio.get('/users/$id');

    // 第1层：HTTP 状态码检查
    if (response.statusCode == 200) {
      return Result.success(User.fromJson(response.data));
    } else if (response.statusCode == 401) {
      return Result.error('请重新登录');
    } else if (response.statusCode == 404) {
      return Result.error('用户不存在');
    } else if (response.statusCode == 403) {
      return Result.error('无权限访问');
    } else if (response.statusCode! >= 500) {
      return Result.error('服务器繁忙，请稍后重试');
    }
  } on DioException catch (e) {
    // 第2层：Dio 异常分类处理
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Result.error('网络连接超时');
      case DioExceptionType.connectionError:
        return Result.error('网络连接失败，请检查网络');
      case DioExceptionType.cancel:
        return Result.error('请求已取消');  // 通常不需要提示用户
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) { /* Token 过期处理 */ }
        return Result.error('服务器错误 ($statusCode)');
      default:
        return Result.error('发生未知错误');
    }
  } catch (e) {
    return Result.error('程序异常: $e');  // 兜底
  }
}

// ─ Result 类型（避免用异常控制流）──
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Error<T> extends Result<T> {
  final String message;
  const Error(this.message);
}''',
            language: 'Dart',
          ),
          const TipBox('用户看到的错误信息要友好："网络开小差了"而不是 "SocketException: Connection refused"。永远不要把异常堆栈展示给用户！', type: TipType.caution),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 8. 加载状态
          // ════════════════════════════════════════════════
          const SectionHeader('8. 加载状态与 UX', icon: Icons.motion_photos_on),
          const Paragraph(
            '网络请求的加载体验直接影响用户留存。常见的三种加载模式：\n\n'
            '① 加载指示器（Loading Indicator）\n'
            '• 最简单：CircularProgressIndicator / LinearProgressIndicator\n'
            '• 适合：短时间加载（<1秒）\n\n'
            '② 骨架屏（Skeleton Screen）\n'
            '• 用灰色占位块模拟即将加载的内容\n'
            '• 适合：首次加载、内容较重时\n'
            '• 推荐 shimmer 包实现\n\n'
            '③ 下拉刷新 + 上拉加载更多\n'
            '• RefreshIndicator 包裹可滚动组件\n'
            '• 列表底部放加载指示器',
          ),
          const CodeBlock(
            r'''// ─ 骨架屏（shimmer 包）──
import 'package:shimmer/shimmer.dart';

Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Column(children: [
    Container(height: 200, color: Colors.white), // 大图占位
    const SizedBox(height: 16),
    Container(height: 16, color: Colors.white),  // 标题占位
    const SizedBox(height: 8),
    Container(height: 14, width: 200, color: Colors.white), // 描述占位
  ]),
);

// ─ 下拉刷新 + 加载更多 ─
RefreshIndicator(
  onRefresh: _fetchData,  // 返回 Future<void>
  child: ListView.builder(
    controller: _scrollCtrl,
    itemCount: items.length + (_hasMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == items.length) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListTile(title: Text(items[index].name));
    },
  ),
);

// ─ 监听滚动到底部 ─
_scrollCtrl.addListener(() {
  if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
    if (!_loading && _hasMore) _loadMore();
  }
});''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 9. WebSocket
          // ════════════════════════════════════════════════
          const SectionHeader('9. WebSocket —— 实时双向通信', icon: Icons.swap_calls),
          const Paragraph(
            'HTTP 是"请求-响应"模式，客户端发起请求服务器才能返回数据。\n'
            '但很多场景需要服务器主动推送数据：聊天消息、实时行情、游戏状态等。\n'
            'WebSocket 解决了这个问题：建立连接后，双方随时可以发送消息。\n\n'
            'Flutter 中 WebSocket 方案：\n'
            '• dart:io WebSocket —— Dart 原生支持\n'
            '• web_socket_channel 包 —— 跨平台统一 API\n'
            '• Socket.IO —— 高级封装（自动重连、房间、广播）',
          ),
          const CodeBlock(
            r'''// ─ web_socket_channel 用法 ─
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('wss://echo.websocket.org'),
);

// 发送消息
channel.sink.add('Hello, WebSocket!');

// 接收消息
channel.stream.listen(
  (message) {
    print('收到: $message');
  },
  onError: (error) => print('WebSocket 错误: $error'),
  onDone: () => print('WebSocket 连接关闭'),
);

// 关闭连接（dispose 中）
channel.sink.close();''',
            language: 'Dart',
          ),
          const TipBox('WebSocket 连接是很昂贵的资源。页面进入后台时考虑断开，回到前台时重连。dispose 中必须关闭。', type: TipType.info),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 10. 缓存策略
          // ════════════════════════════════════════════════
          const SectionHeader('10. 网络请求缓存策略', icon: Icons.cached),
          const Paragraph(
            '缓存是提升 App 体验的关键：减少网络请求、离线可用、响应更快。\n\n'
            '三级缓存策略（网络 → 本地存储 → 内存）：\n'
            '• 第1层（内存）：Map/Dictionary，进程重启即失，速度最快\n'
            '• 第2层（本地存储）：Hive/sqflite/SharedPreferences，持久化\n'
            '• 第3层（网络）：最后的数据源\n\n'
            '常见缓存模式：\n'
            '• Cache-Aside：先查缓存 → 命中返回 → 未命中则请求网络并写入缓存\n'
            '• Write-Through：写入时同时更新缓存和网络\n'
            '• Stale-While-Revalidate：先返回缓存，同时在后台更新',
          ),
          const CodeBlock(
            r'''// ─ Cache-Aside 模式 ─
Future<User> fetchUser(int id) async {
  final cacheKey = 'user_$id';

  // 1. 先查内存缓存
  if (_memoryCache.containsKey(cacheKey)) {
    return _memoryCache[cacheKey]!;
  }

  // 2. 再查本地存储
  final cached = await prefs.getString(cacheKey);
  if (cached != null) {
    final user = User.fromJson(jsonDecode(cached));
    _memoryCache[cacheKey] = user;  // 回填内存
    // 后台更新
    _fetchFromNetworkAndCache(id, cacheKey);
    return user;
  }

  // 3. 最后查网络
  return await _fetchFromNetworkAndCache(id, cacheKey);
}''',
            language: 'Dart',
          ),

          // ════════════════════════════════════════════════
          // 11. API 安全
          // ════════════════════════════════════════════════
          const SectionHeader('11. API 密钥与安全管理', icon: Icons.key),
          const Paragraph(
            'API 密钥（Key/Token/Secret）是应用的"钥匙"，泄露会导致严重安全后果。\n\n'
            '安全最佳实践：\n'
            '① 永远不要硬编码密钥到代码中（反编译即可获取）\n'
            '② 使用 flutter_dotenv + .env 文件，且 .env 加入 .gitignore\n'
            '③ 最安全的方式：后端代理转发，密钥只存在服务器上\n'
            '④ Release 构建启用混淆：flutter build apk --obfuscate --split-debug-info\n'
            '⑤ 敏感 Token 使用 flutter_secure_storage 而非 SharedPreferences',
          ),
          const CodeBlock(
            r'''// ─ 使用 flutter_dotenv ─
// 1. pubspec.yaml: flutter_dotenv: ^5.0.0
// 2. assets 添加 .env 文件（.gitignore 要包含它）
// 3. main.dart 最开头加载
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

// 4. 使用
final apiKey = dotenv.env['API_KEY'] ?? '';
final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.example.com';

// ─ .env 示例 ─
// API_KEY=sk_live_abc123xyz
// BASE_URL=https://api.example.com

// Flutter 3.7+ 可用 --dart-define 注入编译时常量
// flutter run --dart-define=API_KEY=sk_live_abc123
// 代码中：const String.fromEnvironment('API_KEY')''',
            language: 'Dart',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 12. REST vs GraphQL
          // ════════════════════════════════════════════════
          const SectionHeader('12. RESTful API 设计 & GraphQL', icon: Icons.account_tree),
          const Paragraph(
            'RESTful 规范：\n'
            '• 资源用名词复数：/users, /posts\n'
            '• HTTP 方法对应 CRUD 操作\n'
            '• 嵌套资源：/users/1/posts\n'
            '• 查询参数过滤：?status=active&page=1&limit=20\n'
            '• API 版本化：/api/v1/users\n'
            '• 统一响应格式：{code, message, data}\n\n'
            'GraphQL 的特点：\n'
            '• 单一端点，按需查询（不多不少）\n'
            '• 客户端指定需要的字段 → 避免 over-fetching\n'
            '• 强类型 Schema\n'
            '• 一次请求获取多个关联资源\n'
            'Flutter 中推荐 graphql_flutter 包',
          ),
          const CodeBlock(
            r'''// RESTful API 设计示例
GET    /api/v1/users                 // 用户列表 ?page=1&per_page=20
POST   /api/v1/users                 // 创建用户
GET    /api/v1/users/:id             // 用户详情
PUT    /api/v1/users/:id             // 全量更新
PATCH  /api/v1/users/:id             // 部分更新
DELETE /api/v1/users/:id             // 删除用户
GET    /api/v1/users/:id/posts       // 用户帖子（嵌套资源）

// GraphQL 查询示例
// query {
//   user(id: 1) {
//     name
//     email
//     posts(limit: 5) {
//       title
//       createdAt
//     }
//   }
// }
// 一次请求拿到用户信息 + 最近5篇文章 → 对比 REST 需要两次请求''',
            language: 'Plaintext',
          ),

          // ════════════════════════════════════════════════
          // 13. 交互演示
          // ════════════════════════════════════════════════
          const SectionHeader('🧪 模拟 HTTP 请求演示', icon: Icons.wifi),
          const Paragraph('点击按钮体验不同 HTTP 方法的请求效果（使用 Future.delayed 模拟网络延迟）。观察请求日志了解完整的请求/响应流程。'),
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
              child: SelectableText(_data, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent, height: 1.5)),
            ),
          const SizedBox(height: 8),
          const Text('请求日志', style: TextStyle(fontWeight: FontWeight.w600)),
          Container(
            width: double.infinity, height: 150, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
            child: ListView(
              children: _requestLog.map((log) => Text(log, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.amberAccent, height: 1.4))).toList(),
            ),
          ),

          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 写 User 类(id, name, email, avatarUrl)实现 fromJson/toJson\n'
            '2. 用 http 请求 jsonplaceholder.typicode.com/posts 并解析为 List<Post>\n'
            '3. 用 Dio 封装一个 ApiClient 单例，配置 baseUrl 和 15 秒超时\n'
            '4. 写一个 AuthInterceptor 自动添加 Token 和 401 自动刷新\n'
            '5. 用 dio 下载一个大文件并显示下载进度\n'
            '6. 用 web_socket_channel 连接到 wss://echo.websocket.org 并收发消息\n'
            '7. 实现网络缓存策略：本地数据优先展示 + 后台更新',
          ),
          const TipBox('jsonplaceholder.typicode.com 是免费测试 API。开发时用 DevTools → Network 面板观察请求详情。', type: TipType.tip),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
