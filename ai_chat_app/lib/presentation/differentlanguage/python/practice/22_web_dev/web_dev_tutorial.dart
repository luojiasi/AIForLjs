import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flask 路由与响应演示
class _FlaskRouteDemo extends StatefulWidget {
  const _FlaskRouteDemo();
  @override
  State<_FlaskRouteDemo> createState() => _FlaskRouteDemoState();
}

class _FlaskRouteDemoState extends State<_FlaskRouteDemo> {
  String _framework = 'flask';
  String _route = '/users';
  String _method = 'GET';
  String _name = '张三';

  String get _responseBody {
    switch (_method) {
      case 'GET':
        return _route == '/users' ? '[{"id":1,"name":"$_name"}, {"id":2,"name":"李四"}]' : '{"id":1,"name":"$_name","email":"zhang@example.com"}';
      case 'POST':
        return '{"status":"created","id":3,"name":"$_name"}';
      case 'DELETE':
        return '{"status":"deleted","message":"用户已删除"}';
      default:
        return '{}';
    }
  }

  String get _statusCode => _method == 'POST' ? '201 Created' : _method == 'DELETE' ? '204 No Content' : '200 OK';

  String _code() {
    final getBody = r'return jsonify([{"id":1,"name":"' '$_name' r'"}])';
    final postBody = r'data = request.json' '\n' r'    return jsonify({"status":"created"}), 201';
    final deleteBody = r'return "", 204';
    String body;
    switch (_method) {
      case 'GET': body = getBody; break;
      case 'POST': body = postBody; break;
      default: body = deleteBody; break;
    }
    switch (_framework) {
      case 'flask':
        return 'from flask import Flask, jsonify, request\n\n'
            'app = Flask(__name__)\n\n'
            '@app.route("$_route", methods=["$_method"])\n'
            'def users():\n'
            '    $body';
      case 'django':
        final djGet = r'return JsonResponse([{"id":1,"name":"' '$_name' r'"}], safe=False)';
        final djPost = r'return JsonResponse({"status":"created"}, status=201)';
        final djDel = r'return JsonResponse({}, status=204)';
        String djBody;
        switch (_method) {
          case 'GET': djBody = djGet; break;
          case 'POST': djBody = djPost; break;
          default: djBody = djDel; break;
        }
        return '# urls.py\nurlpatterns = [\n    path("$_route", views.users),\n]\n\n# views.py\nfrom django.http import JsonResponse\n\ndef users(request):\n    $djBody';
      case 'fastapi':
        final faGet = r'return [{"id":1,"name":"' '$_name' r'"}]';
        final faPost = r'return {"status":"created"}';
        final faDel = r'return {}';
        String faBody;
        switch (_method) {
          case 'GET': faBody = faGet; break;
          case 'POST': faBody = faPost; break;
          default: faBody = faDel; break;
        }
        return 'from fastapi import FastAPI\n\napp = FastAPI()\n\n@app.${_method.toLowerCase()}("$_route")\n'
            'def users():\n'
            '    $faBody';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🌐 Flask/Django/FastAPI 路由演示',
      subtitle: '切换框架和路由，观察请求/响应模式',
      children: [
        ParamChoiceChips<String>(
          label: '框架',
          value: _framework,
          options: [('flask', 'Flask'), ('django', 'Django'), ('fastapi', 'FastAPI')],
          onChanged: (v) => setState(() => _framework = v),
        ),
        ParamChoiceChips<String>(
          label: '路由',
          value: _route,
          options: [('/users', '/users（列表）'), ('/users/1', '/users/1（详情）')],
          onChanged: (v) => setState(() => _route = v),
        ),
        ParamChoiceChips<String>(
          label: 'HTTP 方法',
          value: _method,
          options: [('GET', 'GET'), ('POST', 'POST'), ('DELETE', 'DELETE')],
          onChanged: (v) => setState(() => _method = v),
        ),
        ParamTextField(label: '用户名', value: _name, onChanged: (v) => setState(() => _name = v.isEmpty ? '张三' : v), maxLength: 10),
        const SizedBox(height: 8),
        // Response 展示
        Container(width: double.infinity, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent)),
              const SizedBox(width: 8),
              Expanded(child: Text(_route, style: const TextStyle(fontSize: 13, color: Colors.white))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: _statusCode.startsWith('2') ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(3)),
                child: Text(_statusCode, style: TextStyle(fontSize: 10, color: _statusCode.startsWith('2') ? Colors.greenAccent : Colors.redAccent))),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 3), child: Divider(color: Colors.grey)),
            SelectableText('Content-Type: application/json\n\n$_responseBody', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent)),
          ]),
        ),
        LiveCodeBlock(_code()),
        LiveOutputBox('$_method $_route → $_statusCode\n$_responseBody'),
      ],
    );
  }
}

class PythonWebDevTutorial extends StatelessWidget {
  const PythonWebDevTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第22章 Web开发'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // 22.1 HTTP协议简介
          // ==========================================
          const SectionHeader('22.1 HTTP协议简介', icon: Icons.lan),
          const Paragraph(
            'HTTP（HyperText Transfer Protocol，超文本传输协议）是互联网上应用最广泛的网络协议。'
            '它定义了客户端（通常是浏览器）与服务器之间通信的规则，'
            '是万维网（World Wide Web）数据通信的基础。'
            'HTTP 基于"请求-响应"模型：客户端发送请求，服务器返回响应。'
            '理解 HTTP 协议是进行 Web 开发的前提条件。',
          ),
          const DividerLine(),

          // HTTP请求格式
          const Paragraph(
            '1. HTTP 请求格式\n'
            '一个 HTTP 请求由请求行（Request Line）、请求头（Headers）和请求体（Body）三部分组成。'
            '请求行包含请求方法（GET/POST 等）、请求路径和协议版本。'
            '请求头以键值对形式传递元信息，如浏览器类型、可接受的内容类型等。'
            '请求体在 GET 请求中通常为空，在 POST 请求中包含提交的数据。',
          ),
          const CodeBlock(
            r'''GET /index.html HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0 (Windows NT 10.0)
Accept: text/html, application/json
Accept-Language: zh-CN,zh;q=0.9
Accept-Encoding: gzip, deflate
Connection: keep-alive
Cookie: session_id=abc123; user=alice

（GET请求没有请求体）

---

POST /api/login HTTP/1.1
Host: www.example.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 29
User-Agent: Mozilla/5.0

username=alice&password=123456''',
            language: 'HTTP',
          ),
          const OutputBox(
            r'''GET /index.html HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html, application/json
...''',
          ),

          // HTTP响应格式
          const DividerLine(),
          const Paragraph(
            '2. HTTP 响应格式\n'
            '服务器返回的 HTTP 响应由状态行（Status Line）、响应头（Response Headers）和响应体（Body）组成。'
            '状态行包含协议版本、状态码和状态描述。'
            '响应头包含 Content-Type（内容类型）、Content-Length（内容长度）、'
            'Set-Cookie（设置 Cookie）、Server（服务器信息）等。'
            '响应体包含实际返回的数据，可能是 HTML 页面、JSON 数据或文件内容。',
          ),
          const CodeBlock(
            r'''HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 1234
Server: nginx/1.24.0
Date: Mon, 15 Jan 2024 10:30:00 GMT
Set-Cookie: token=xyz789; Path=/
Cache-Control: max-age=3600

<!DOCTYPE html>
<html>
<head><title>首页</title></head>
<body>
  <h1>欢迎访问!</h1>
  <p>这是服务器返回的 HTML 页面。</p>
</body>
</html>''',
            language: 'HTTP',
          ),
          const OutputBox(
            r'''HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 1234
Server: nginx/1.24.0
...''',
          ),

          // HTTP请求方法
          const DividerLine(),
          const Paragraph(
            '3. HTTP 请求方法\n'
            'HTTP 定义了一组请求方法，最常用的是 GET 和 POST。'
            'GET 用于获取资源，参数附加在 URL 的查询字符串中，有长度限制，不适合传输敏感数据。'
            'POST 用于提交数据，参数放在请求体中，没有长度限制，相对更安全。'
            '其他方法还包括 PUT（更新资源）、DELETE（删除资源）、'
            'HEAD（获取响应头）、PATCH（部分更新）等。',
          ),
          const CodeBlock(
            r'''# GET 请求 — 获取资源
# 浏览器访问: https://api.example.com/users?id=123
# 实际发送的请求:
GET /users?id=123&page=1 HTTP/1.1
Host: api.example.com

# 特点:
# - 参数在 URL 中（查询字符串）
# - 可被浏览器缓存和收藏
# - 有长度限制（通常 2048 字符）
# - 不应用于敏感数据
# - 幂等（多次请求结果相同）

# POST 请求 — 提交数据
POST /users HTTP/1.1
Host: api.example.com
Content-Type: application/json
Content-Length: 48

{"name": "Alice", "age": 25, "email": "alice@example.com"}

# 特点:
# - 参数在请求体中
# - 不会出现在浏览器历史
# - 无长度限制
# - 可传输大量数据和文件
# - 非幂等（多次可能创建多个资源）''',
            language: 'HTTP',
          ),
          const OutputBox(
            r'''GET 请求: 参数在 URL 中，可缓存，有长度限制
POST 请求: 参数在请求体中，不可缓存，无长度限制''',
          ),

          // HTTP状态码
          const DividerLine(),
          const Paragraph(
            '4. HTTP 状态码\n'
            '服务器通过状态码告诉客户端请求的处理结果。状态码分为五类：'
            '1xx（信息性状态码）、2xx（成功）、3xx（重定向）、'
            '4xx（客户端错误）、5xx（服务器错误）。'
            '开发中最常见的是 200（成功）、301/302（重定向）、'
            '400（请求错误）、404（资源未找到）、500（服务器内部错误）。',
          ),
          const CodeBlock(
            r'''# 2xx 成功
200 OK                    # 请求成功，返回请求的资源
201 Created               # POST 创建资源成功
204 No Content            # 删除成功，无返回内容

# 3xx 重定向
301 Moved Permanently     # 资源已永久移动到新 URL
302 Found                 # 资源临时重定向
304 Not Modified          # 资源未修改（使用缓存）

# 4xx 客户端错误
400 Bad Request           # 请求格式错误
401 Unauthorized          # 未认证（需要登录）
403 Forbidden             # 无权限访问
404 Not Found             # 资源不存在
405 Method Not Allowed    # 请求方法不允许
429 Too Many Requests     # 请求频率超限

# 5xx 服务器错误
500 Internal Server Error # 服务器内部错误
502 Bad Gateway           # 网关错误
503 Service Unavailable   # 服务暂时不可用
504 Gateway Timeout       # 网关超时''',
            language: 'HTTP',
          ),
          const OutputBox(
            r'''常见状态码:
200 OK     — 请求成功
301/302    — 重定向
400        — 请求错误
401/403    — 认证/权限问题
404        — 资源不存在
500        — 服务器内部错误''',
          ),

          // HTTP请求头
          const DividerLine(),
          const Paragraph(
            '5. 重要的 HTTP 请求头\n'
            '请求头是客户端发送给服务器的元数据，用于传递附加信息。'
            'Content-Type 告诉服务器请求体的格式（如 JSON、表单数据）。'
            'User-Agent 标识客户端类型（浏览器、爬虫、移动端等）。'
            'Cookie 携带会话标识，实现状态管理。'
            'Authorization 用于身份认证（如 Bearer Token）。'
            'Referer 标识请求来源页面，常用于防盗链和统计。',
          ),
          const CodeBlock(
            r'''import requests

# 设置请求头
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIs...',
    'Cookie': 'session_id=abc123; theme=dark',
    'Referer': 'https://example.com/previous-page',
}

response = requests.get(
    'https://httpbin.org/headers',
    headers=headers
)
print('服务器收到的请求头:')
for key, value in response.json()['headers'].items():
    if key != 'Host':
        print(f'  {key}: {value}')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''服务器收到的请求头:
  Accept: application/json, text/plain, */*
  Accept-Language: zh-CN,zh;q=0.9,en;q=0.8
  Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
  Cookie: session_id=abc123; theme=dark
  Referer: https://example.com/previous-page
  User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...''',
          ),

          // 无状态特性
          const DividerLine(),
          const Paragraph(
            '6. HTTP 的无状态特性\n'
            'HTTP 协议是无状态的（Stateless），即服务器不会自动记住客户端之前的请求。'
            '每次请求都是独立的，服务器无法直接判断两次请求是否来自同一用户。'
            '为了解决无状态带来的问题，Web 开发中引入了 Cookie 和 Session 机制。'
            'Cookie 是存储在客户端的小数据片段，Session 将用户数据存储在服务器端。'
            'Token 认证（如 JWT）是现代 Web 应用常用的另一种状态管理方案。',
          ),
          const CodeBlock(
            r'''# HTTP 的无状态特性示意图

# 请求1: 用户登录
POST /login HTTP/1.1
Content-Type: application/json

{"username": "alice", "password": "123456"}

# 响应1: 服务器验证身份，返回 Session ID
HTTP/1.1 200 OK
Set-Cookie: session_id=xyz789; HttpOnly; Path=/

# 请求2: 访问个人资料（携带 Cookie）
GET /profile HTTP/1.1
Cookie: session_id=xyz789

# 响应2: 服务器通过 Cookie 识别用户
HTTP/1.1 200 OK
Content-Type: application/json

{"username": "alice", "email": "alice@example.com"}

# 说明: 如果请求2 不携带 Cookie，服务器会认为这是一个新用户，
# 返回 401 Unauthorized 或重定向到登录页。''',
            language: 'HTTP',
          ),
          const OutputBox(
            r'''HTTP 是无状态协议 -> 引入 Cookie/Session -> 实现用户身份识别
无 Cookie 请求 -> 服务器不认识你
有 Cookie 请求 -> 服务器通过 session_id 找到你的信息''',
          ),
          const TipBox(
            'HTTP 的无状态特性是其设计优点（简化服务器、提高可扩展性），'
            '但也带来了状态管理的挑战。现代 Web 应用常使用 JWT（JSON Web Token）'
            '在客户端存储用户状态，避免服务器端 Session 的存储压力。',
            type: TipType.info,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 22.2 HTML简介
          // ==========================================
          const SectionHeader('22.2 HTML简介', icon: Icons.code),
          const Paragraph(
            'HTML（HyperText Markup Language，超文本标记语言）是创建网页的标准语言。'
            '它使用标签（Tag）来标记内容的结构和语义，告诉浏览器如何显示页面。'
            'HTML 文档由元素（Element）组成，元素由开始标签、内容和结束标签构成。'
            'Python Web 开发中，HTML 通常作为模板由服务器动态生成，而非编写静态文件。',
          ),
          const DividerLine(),

          // HTML基本结构
          const Paragraph(
            '1. HTML 文档基本结构\n'
            '每个 HTML 文档都遵循相同的骨架结构。'
            '<!DOCTYPE html> 声明文档类型为 HTML5。'
            '<html> 是根元素，<head> 包含元数据（标题、字符编码、样式引用等），'
            '<body> 包含页面可见内容。'
            '理解这个结构是编写任何 HTML 页面的基础。',
          ),
          const CodeBlock(
            r'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的第一个网页</title>
    <style>
        /* CSS 样式可以放在 style 标签中 */
        body { font-family: Arial, sans-serif; }
    </style>
</head>
<body>
    <!-- 页面可见内容放在 body 中 -->
    <h1>欢迎来到我的网站</h1>
    <p>这是一个用 HTML 编写的网页。</p>
</body>
</html>''',
            language: 'HTML',
          ),

          // 常用HTML标签
          const DividerLine(),
          const Paragraph(
            '2. 常用 HTML 标签\n'
            'HTML 提供了丰富的标签来组织页面内容。'
            '<h1>~<h6> 定义标题（h1 最大，h6 最小）。'
            '<p> 定义段落，<a> 定义超链接，<img> 嵌入图片。'
            '<ul>/<ol> 定义无序/有序列表，<li> 定义列表项。'
            '<div> 是块级容器，<span> 是行内容器，常用于布局和样式控制。'
            '<table> 创建表格，<form> 创建表单。',
          ),
          const CodeBlock(
            r'''<!DOCTYPE html>
<html>
<head><title>HTML标签示例</title></head>
<body>
    <!-- 标题 -->
    <h1>一级标题</h1>
    <h2>二级标题</h2>
    <h3>三级标题</h3>

    <!-- 段落和文本 -->
    <p>这是一个段落，包含
        <strong>加粗文本</strong>、
        <em>斜体文本</em>和
        <a href="https://example.com">超链接</a>。
    </p>

    <!-- 图片 -->
    <img src="image.jpg" alt="描述文字" width="300">

    <!-- 列表 -->
    <h3>无序列表:</h3>
    <ul>
        <li>Python</li>
        <li>JavaScript</li>
        <li>Flutter</li>
    </ul>

    <h3>有序列表:</h3>
    <ol>
        <li>第一步：打开编辑器</li>
        <li>第二步：编写代码</li>
        <li>第三步：运行程序</li>
    </ol>

    <!-- 表格 -->
    <table border="1">
        <tr>
            <th>姓名</th>
            <th>年龄</th>
            <th>城市</th>
        </tr>
        <tr>
            <td>Alice</td>
            <td>25</td>
            <td>北京</td>
        </tr>
        <tr>
            <td>Bob</td>
            <td>30</td>
            <td>上海</td>
        </tr>
    </table>
</body>
</html>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''[页面显示各级标题、段落、图片、列表和表格等元素]''',
          ),

          // HTML表单
          const DividerLine(),
          const Paragraph(
            '3. HTML 表单 — form 标签\n'
            '表单是网页与服务器交互的核心方式。'
            '<form> 标签的 action 属性指定数据提交的 URL，'
            'method 属性指定提交方式（GET 或 POST）。'
            '<input> 是最常用的表单控件，通过 type 属性定义不同输入类型。'
            '<textarea> 多行文本输入，<select> 下拉选择框。'
            '<button> 或 <input type="submit"> 用于提交表单。'
            '每个输入控件需要有 name 属性，服务器通过 name 获取对应值。',
          ),
          const CodeBlock(
            r'''<!-- GET 方式提交（参数在 URL 中） -->
<form action="/search" method="GET">
    <label>关键词:</label>
    <input type="text" name="q" placeholder="请输入搜索关键词">
    <button type="submit">搜索</button>
</form>
<!-- 提交后 URL: /search?q=python -->

<!-- POST 方式提交（参数在请求体中） -->
<form action="/login" method="POST">
    <label>用户名:</label>
    <input type="text" name="username" required>

    <label>密码:</label>
    <input type="password" name="password" required>

    <label>记住我:</label>
    <input type="checkbox" name="remember" value="1">

    <button type="submit">登录</button>
</form>

<!-- 丰富的输入控件 -->
<form action="/register" method="POST">
    <label>邮箱:</label>
    <input type="email" name="email" required>

    <label>年龄:</label>
    <input type="number" name="age" min="1" max="150">

    <label>出生日期:</label>
    <input type="date" name="birthday">

    <label>个人简介:</label>
    <textarea name="bio" rows="4" cols="50"></textarea>

    <label>国家:</label>
    <select name="country">
        <option value="CN">中国</option>
        <option value="US">美国</option>
        <option value="JP">日本</option>
    </select>

    <label>性别:</label>
    <input type="radio" name="gender" value="male"> 男
    <input type="radio" name="gender" value="female"> 女

    <label>上传头像:</label>
    <input type="file" name="avatar">

    <button type="submit">注册</button>
</form>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''GET 表单: 参数在 URL 中，适合搜索等幂等操作
POST 表单: 参数在请求体中，适合登录、注册等操作
input type: text, password, email, number, date, file, checkbox, radio''',
          ),

          // 简单网页示例
          const DividerLine(),
          const Paragraph(
            '4. 完整网页示例\n'
            '下面是一个包含页面结构、导航、内容区域和表单的完整 HTML 页面示例。'
            '这个页面同时支持 GET（搜索）和 POST（登录）两种表单提交方式。'
            '使用 <nav> 创建导航菜单，<main> 标记主要内容区域，'
            '<footer> 定义页脚，这些语义化标签有助于 SEO 和可访问性。',
          ),
          const CodeBlock(
            r'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Python 学习平台</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Microsoft YaHei", sans-serif;
               background: #f5f5f5; color: #333; }
        .header { background: #4A90D9; color: white;
                  padding: 20px; text-align: center; }
        .nav { background: #333; overflow: hidden; }
        .nav a { float: left; color: white; padding: 14px 20px;
                 text-decoration: none; }
        .nav a:hover { background: #4A90D9; }
        .container { max-width: 900px; margin: 20px auto;
                     padding: 20px; background: white;
                     border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .footer { text-align: center; padding: 20px;
                  background: #333; color: white; }
        input, button { padding: 8px 12px; margin: 5px 0;
                        border: 1px solid #ddd; border-radius: 4px; }
        button { background: #4A90D9; color: white;
                 border: none; cursor: pointer; }
        button:hover { background: #357ABD; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Python 学习平台</h1>
        <p>从入门到精通</p>
    </div>

    <div class="nav">
        <a href="/">首页</a>
        <a href="/courses">课程</a>
        <a href="/about">关于</a>
        <a href="/contact">联系我们</a>
    </div>

    <div class="container">
        <h2>欢迎来到 Python 学习平台!</h2>
        <p>本平台提供从基础到高级的 Python 教程，包括 Web 开发、数据分析、机器学习等方向。</p>

        <h3>搜索课程 (GET)</h3>
        <form action="/search" method="GET">
            <input type="text" name="keyword" placeholder="输入课程名称">
            <button type="submit">搜索</button>
        </form>

        <h3>用户登录 (POST)</h3>
        <form action="/login" method="POST">
            <input type="text" name="username" placeholder="用户名" required>
            <br>
            <input type="password" name="password" placeholder="密码" required>
            <br>
            <button type="submit">登录</button>
            <a href="/register">没有账号? 注册</a>
        </form>
    </div>

    <div class="footer">
        <p>&copy; 2024 Python 学习平台. 保留所有权利.</p>
    </div>
</body>
</html>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''[一个完整的网页，包含蓝色头部导航、深色导航栏、
中央白色内容区域（搜索表单和登录表单）以及深色页脚]''',
          ),
          const TipBox(
            'HTML 表单的 method 属性决定了数据如何发送到服务器：'
            'method="GET" 时数据在 URL 查询字符串中（?key=value），'
            'method="POST" 时数据在 HTTP 请求体中。'
            '实际 Web 开发中，搜索用 GET，数据修改用 POST。',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 22.3 WSGI接口
          // ==========================================
          const SectionHeader('22.3 WSGI接口', icon: Icons.api),
          const Paragraph(
            'WSGI（Web Server Gateway Interface，Web 服务器网关接口）'
            '是 Python 定义的一套 Web 服务器与 Web 应用程序之间的标准接口。'
            '它由 PEP 3333 规范定义，目的是将 Web 服务器与 Web 应用程序解耦。'
            '只要遵循 WSGI 规范，任何 Web 服务器都可以运行任何 WSGI 应用，'
            '这也是 Flask、Django 等框架能够兼容不同服务器（Gunicorn、uWSGI等）的原因。',
          ),
          const DividerLine(),

          // WSGI规范
          const Paragraph(
            '1. WSGI 规范\n'
            'WSGI 应用程序是一个可调用的 Python 对象（函数或类），'
            '接受两个参数：environ（包含所有请求信息的字典）和 '
            'start_response（用于发送 HTTP 状态码和响应头的回调函数）。'
            '应用返回一个可迭代对象作为响应体。'
            'environ 字典包含请求方法、路径、查询字符串、请求头、输入流等信息。',
          ),
          const CodeBlock(
            r"""# WSGI 应用程序的基本结构

def simple_app(environ, start_response):
    '''
    environ: dict — 包含所有请求信息的环境字典
    start_response: callable — 用于发送状态码和响应头的函数
    返回值: iterable — 响应体的可迭代对象（通常是字节串列表）
    '''
    # 解析请求信息
    method = environ['REQUEST_METHOD']       # GET, POST 等
    path = environ['PATH_INFO']              # 请求路径, 如 /index
    query = environ.get('QUERY_STRING', '')  # 查询字符串

    # 构造响应体
    response_body = f'''
    <html>
    <body>
        <h1>WSGI 应用</h1>
        <p>请求方法: {method}</p>
        <p>请求路径: {path}</p>
        <p>查询参数: {query}</p>
    </body>
    </html>
    '''.encode('utf-8')

    # 发送 HTTP 状态码和响应头
    status = '200 OK'
    headers = [
        ('Content-Type', 'text/html; charset=utf-8'),
        ('Content-Length', str(len(response_body))),
    ]
    start_response(status, headers)

    # 返回响应体
    return [response_body]""",
            language: 'Python',
          ),

          // environ详解
          const DividerLine(),
          const Paragraph(
            '2. environ 字典详解\n'
            'environ 字典是 WSGI 应用获取请求信息的主要途径。'
            '它包含了 CGI 风格的环境变量：'
            'REQUEST_METHOD（请求方法）、PATH_INFO（请求路径）、'
            'QUERY_STRING（查询字符串）、CONTENT_TYPE（请求体类型）、'
            'CONTENT_LENGTH（请求体长度）。'
            'HTTP_ 开头的键对应 HTTP 请求头（如 HTTP_USER_AGENT、HTTP_COOKIE）。'
            'wsgi.input 是输入流，用于读取 POST 请求体。'
            'wsgi.errors 是错误输出流。',
          ),
          const CodeBlock(
            r'''# 打印 WSGI environ 的所有键值

def debug_app(environ, start_response):
    output = []

    # 基本信息
    output.append(f'请求方法: {environ["REQUEST_METHOD"]}')
    output.append(f'请求路径: {environ["PATH_INFO"]}')
    output.append(f'查询字符串: {environ.get("QUERY_STRING", "")}')
    output.append(f'内容类型: {environ.get("CONTENT_TYPE", "")}')
    output.append(f'内容长度: {environ.get("CONTENT_LENGTH", "0")}')
    output.append(f'服务器协议: {environ["SERVER_PROTOCOL"]}')
    output.append(f'服务器软件: {environ.get("SERVER_SOFTWARE", "")}')
    output.append(f'客户端IP: {environ.get("REMOTE_ADDR", "")}')
    output.append(f'客户端端口: {environ.get("REMOTE_PORT", "")}')
    output.append('')

    # HTTP 请求头
    output.append('--- 请求头 ---')
    for key, value in environ.items():
        if key.startswith('HTTP_'):
            # HTTP_USER_AGENT -> User-Agent
            header_name = key[5:].replace('_', '-').title()
            output.append(f'{header_name}: {value}')

    # Cookie
    if 'HTTP_COOKIE' in environ:
        output.append(f'\nCookie: {environ["HTTP_COOKIE"]}')

    # 拼接响应
    response = '\n'.join(output)
    response_body = response.encode('utf-8')

    start_response('200 OK', [
        ('Content-Type', 'text/plain; charset=utf-8'),
        ('Content-Length', str(len(response_body))),
    ])
    return [response_body]''',
            language: 'Python',
          ),
          const OutputBox(
            r'''请求方法: GET
请求路径: /hello
查询字符串: name=python
内容类型:
内容长度: 0
服务器协议: HTTP/1.1
服务器软件: WSGIServer/0.2
客户端IP: 127.0.0.1
客户端端口: 54321

--- 请求头 ---
Host: localhost:8000
User-Agent: Mozilla/5.0 ...
Accept: text/html,application/xhtml+xml
Accept-Language: zh-CN,zh;q=0.9''',
          ),

          // wsgiref.simple_server
          const DividerLine(),
          const Paragraph(
            '3. 使用 wsgiref.simple_server 运行 WSGI 应用\n'
            'Python 标准库中的 wsgiref 模块提供了 WSGI 参考实现，'
            '其中的 simple_server 可以快速启动一个 WSGI 兼容的 HTTP 服务器。'
            'make_server(host, port, app) 创建服务器实例。'
            'serve_forever() 启动服务器持续监听请求。'
            '这是一个开发和测试用的轻量服务器，不适合生产环境使用。',
          ),
          const CodeBlock(
            r'''from wsgiref.simple_server import make_server

# 定义 WSGI 应用
def hello_app(environ, start_response):
    path = environ['PATH_INFO']
    method = environ['REQUEST_METHOD']

    # 根据不同路径返回不同内容
    if path == '/':
        body = b'<h1>首页</h1><p>欢迎访问 WSGI 服务器!</p>'
    elif path == '/about':
        body = b'<h1>关于</h1><p>这是一个 WSGI 示例应用。</p>'
    else:
        body = b'<h1>404</h1><p>页面未找到</p>'
        start_response('404 Not Found', [
            ('Content-Type', 'text/html; charset=utf-8'),
        ])
        return [body]

    start_response('200 OK', [
        ('Content-Type', 'text/html; charset=utf-8'),
        ('Content-Length', str(len(body))),
    ])
    return [body]

# 启动服务器
if __name__ == '__main__':
    server = make_server('127.0.0.1', 8000, hello_app)
    print('服务器已启动: http://127.0.0.1:8000')
    print('按 Ctrl+C 停止服务器')
    server.serve_forever()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''服务器已启动: http://127.0.0.1:8000
按 Ctrl+C 停止服务器

# 浏览器访问 http://127.0.0.1:8000/ 看到:
# 首页
# 欢迎访问 WSGI 服务器!

# 访问 http://127.0.0.1:8000/about 看到:
# 关于
# 这是一个 WSGI 示例应用。

# 访问 http://127.0.0.1:8000/xxx 看到:
# 404
# 页面未找到''',
          ),

          // 路由处理
          const DividerLine(),
          const Paragraph(
            '4. WSGI 路由处理\n'
            '在 WSGI 应用中实现路由（根据不同的 URL 调用不同的处理函数）'
            '需要手动解析 PATH_INFO 并进行匹配。'
            '可以定义一个路由表（字典），将路径映射到处理函数。'
            '同时还需要处理查询参数解析和 POST 请求体的读取。'
            '这正是 Web 框架（如 Flask）要帮我们解决的问题。',
          ),
          const CodeBlock(
            r'''from wsgiref.simple_server import make_server
from urllib.parse import parse_qs
import json

# 路由表: 路径 -> (处理函数, 允许的方法)
routes = {}

def route(path, methods=['GET']):
    """路由装饰器"""
    def wrapper(handler):
        routes[path] = (handler, methods)
        return handler
    return wrapper

@route('/', methods=['GET'])
def home(environ):
    return b'<h1>首页</h1><p>欢迎来到 WSGI 路由示例!</p>'

@route('/hello', methods=['GET'])
def hello(environ):
    # 解析查询参数
    query = parse_qs(environ.get('QUERY_STRING', ''))
    name = query.get('name', ['World'])[0]
    body = f'<h1>Hello, {name}!</h1>'.encode('utf-8')
    return body

@route('/api/data', methods=['GET', 'POST'])
def api_data(environ):
    if environ['REQUEST_METHOD'] == 'POST':
        # 读取 POST 请求体
        content_length = int(environ.get('CONTENT_LENGTH', 0))
        if content_length > 0:
            body = environ['wsgi.input'].read(content_length)
            data = json.loads(body)
            response = {'received': data, 'status': 'success'}
        else:
            response = {'error': 'empty body'}
    else:
        response = {'message': 'This is a GET request', 'data': [1, 2, 3]}

    body = json.dumps(response, ensure_ascii=False).encode('utf-8')
    return body

# WSGI 应用入口
def application(environ, start_response):
    path = environ['PATH_INFO']
    method = environ['REQUEST_METHOD']

    if path in routes:
        handler, methods = routes[path]
        if method in methods:
            body = handler(environ)
            status = '200 OK'
        else:
            body = b'<h1>405 Method Not Allowed</h1>'
            status = '405 Method Not Allowed'
    else:
        body = b'<h1>404 Not Found</h1>'
        status = '404 Not Found'

    start_response(status, [
        ('Content-Type', 'text/html; charset=utf-8'
         if isinstance(body, bytes) and b'<' in body
         else 'application/json'),
        ('Content-Length', str(len(body))),
    ])
    return [body]

# 启动
if __name__ == '__main__':
    server = make_server('127.0.0.1', 8000, application)
    print('路由服务器启动: http://127.0.0.1:8000')
    print('可用路由:')
    for path, (_, methods) in routes.items():
        print(f'  {methods[0]} {path}')
    server.serve_forever()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''路由服务器启动: http://127.0.0.1:8000
可用路由:
  GET /
  GET /hello
  GET /api/data
  POST /api/data

# GET /hello?name=Python
# 显示: Hello, Python!

# POST /api/data 带 JSON 请求体 {"key": "value"}
# 返回: {"received": {"key": "value"}, "status": "success"}''',
          ),
          const TipBox(
            'WSGI 是 Python Web 开发的底层接口标准。理解了 WSGI，'
            '就能更深入地理解 Flask、Django 等框架的工作原理。'
            '所有 Python Web 框架本质上都是在 WSGI 之上提供了便捷的封装。'
            '生产环境中常用 Gunicorn 或 uWSGI 作为 WSGI 服务器。',
            type: TipType.info,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 22.4 使用Web框架
          // ==========================================
          const SectionHeader('22.4 使用Web框架', icon: Icons.web),
          const Paragraph(
            '从上一节可以看到，直接使用 WSGI 接口开发 Web 应用需要处理很多底层细节：'
            '路由分发、请求参数解析、响应构造、Cookie 管理等。'
            'Web 框架（Web Framework）正是在 WSGI 之上提供更高层次的抽象，'
            '让开发者可以专注于业务逻辑而非底层协议。'
            'Python 最流行的 Web 框架包括 Flask（轻量灵活）、'
            'Django（功能完整）、FastAPI（高性能异步）等。',
          ),
          const DividerLine(),

          // Flask安装与基础
          const Paragraph(
            '1. Flask 基础\n'
            'Flask 是一个轻量级的 Python Web 框架，以其简洁优雅著称。'
            '创建 Flask 应用只需实例化 Flask 类，传入当前模块名 __name__。'
            '使用 @app.route() 装饰器定义路由和对应的视图函数。'
            'app.run() 启动开发服务器。'
            'Flask 的设计哲学是"微内核 + 扩展"，核心只包含最基本的功能，'
            '其他功能通过扩展（如 Flask-SQLAlchemy、Flask-Login）实现。',
          ),
          const CodeBlock(
            r'''# 安装 Flask
# pip install flask

from flask import Flask

# 创建 Flask 应用实例
# __name__ 告诉 Flask 从当前模块查找资源
app = Flask(__name__)

# 定义路由 — @app.route() 装饰器
@app.route('/')
def index():
    """首页视图函数"""
    return '<h1>Hello, Flask!</h1><p>这是第一个 Flask 应用。</p>'

@app.route('/about')
def about():
    """关于页面"""
    return '<h1>关于我们</h1><p>Flask 是一个轻量级 Python Web 框架。</p>'

# 启动服务器
if __name__ == '__main__':
    # debug=True 开启调试模式（代码修改后自动重启）
    app.run(host='127.0.0.1', port=5000, debug=True)''',
            language: 'Python',
          ),
          const OutputBox(
            r''' * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://127.0.0.1:5000 (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!

# 浏览器访问 http://127.0.0.1:5000/ 看到:
# Hello, Flask!
# 这是第一个 Flask 应用。''',
          ),

          // 路由进阶
          const DividerLine(),
          const Paragraph(
            '2. 高级路由技巧\n'
            'Flask 的路由支持动态 URL，使用 <variable_name> 语法捕获 URL 中的变量。'
            '可以指定转换器类型：<int:id> 匹配整数，<float:price> 匹配浮点数，'
            '<path:subpath> 匹配包含斜杠的路径。'
            '同一个视图可以绑定多个路由，也可以通过 methods 参数指定允许的 HTTP 方法。'
            'url_for() 函数通过视图函数名称生成对应的 URL，避免硬编码。',
          ),
          const CodeBlock(
            r"""from flask import Flask, url_for

app = Flask(__name__)

# 动态路由: <username> 捕获 URL 中的用户名
@app.route('/user/<username>')
def user_profile(username):
    return f'<h1>用户资料</h1><p>用户名: {username}</p>'

# 带类型转换的动态路由
@app.route('/post/<int:post_id>')
def show_post(post_id):
    return f'<h1>文章详情</h1><p>文章ID: {post_id} (整数)</p>'

@app.route('/product/<float:price>')
def show_price(price):
    return f'<h1>商品价格</h1><p>价格: ¥{price:.2f}</p>'

# 多路由绑定到同一视图
@app.route('/hello')
@app.route('/hello/<name>')
def hello(name=None):
    if name:
        return f'<h1>Hello, {name}!</h1>'
    return '<h1>Hello, World!</h1>'

# 指定 HTTP 方法
@app.route('/login', methods=['GET', 'POST'])
def login():
    if __name__ == '__main__':
        pass  # 实际逻辑在后续示例中
    return '<h1>登录页面</h1>'

# url_for() 生成 URL
@app.route('/test-url')
def test_url():
    profile_url = url_for('user_profile', username='alice')
    post_url = url_for('show_post', post_id=123)
    return f'''
    <h1>URL 生成测试</h1>
    <p>用户资料URL: {profile_url}</p>
    <p>文章URL: {post_url}</p>
    <p>注意: url_for() 会自动处理参数编码</p>
    '''

if __name__ == '__main__':
    app.run(debug=True)""",
            language: 'Python',
          ),
          const OutputBox(
            r'''访问 /user/alice       -> 用户资料: 用户名: alice
访问 /post/42           -> 文章详情: 文章ID: 42
访问 /product/99.9      -> 商品价格: ¥99.90
访问 /hello/Python      -> Hello, Python!
访问 /test-url          -> 用户资料URL: /user/alice
                          文章URL: /post/123

注意: /post/abc 会返回 404，因为 post_id 声明为 <int:post_id>''',
          ),

          // 获取请求参数
          const DividerLine(),
          const Paragraph(
            '3. 获取请求参数\n'
            'Flask 通过全局的 request 对象获取请求数据。'
            'request.args 获取 GET 查询参数（类似字典）。'
            'request.form 获取 POST 表单数据。'
            'request.json 获取 JSON 请求体（Content-Type 需为 application/json）。'
            'request.method 获取请求方法。'
            'request.headers 获取请求头字典。'
            'request.cookies 获取 Cookie 字典。'
            'request.files 获取上传的文件。',
          ),
          const CodeBlock(
            r"""from flask import Flask, request

app = Flask(__name__)

@app.route('/search', methods=['GET'])
def search():
    '''搜索功能 — 使用 GET 参数'''
    keyword = request.args.get('keyword', '')
    page = request.args.get('page', 1, type=int)

    return f'''
    <h1>搜索结果</h1>
    <p>关键词: {keyword}</p>
    <p>页码: {page}</p>
    '''

@app.route('/login', methods=['GET', 'POST'])
def login():
    '''登录功能 — GET 显示表单，POST 处理提交'''
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        if username == 'admin' and password == '123456':
            return f'<h1>登录成功!</h1><p>欢迎, {username}!</p>'
        else:
            return '<h1>登录失败</h1><p>用户名或密码错误</p>'

    # GET 请求显示登录表单
    return '''
    <form method="POST">
        <input type="text" name="username" placeholder="用户名">
        <br>
        <input type="password" name="password" placeholder="密码">
        <br>
        <button type="submit">登录</button>
    </form>
    '''

@app.route('/api/data', methods=['POST'])
def api_data():
    '''接收 JSON 数据'''
    data = request.json
    if not data:
        return {'error': '请发送 JSON 数据'}, 400

    return {
        'received': data,
        'message': '数据接收成功',
        'keys': list(data.keys()),
    }

@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    '''文件上传'''
    if request.method == 'POST':
        file = request.files.get('file')
        if file:
            filename = file.filename
            return f'<h1>上传成功!</h1><p>文件名: {filename}</p>'
        return '<h1>请选择文件</h1>'

    return '''
    <form method="POST" enctype="multipart/form-data">
        <input type="file" name="file">
        <button type="submit">上传</button>
    </form>
    '''

if __name__ == '__main__':
    app.run(debug=True)""",
            language: 'Python',
          ),
          const OutputBox(
            r'''GET /search?keyword=flask&page=2
  -> 搜索结果: 关键词=flask, 页码=2

POST /login 提交 username=admin&password=123456
  -> 登录成功! 欢迎, admin!

POST /api/data 发送 JSON {"name": "Flask", "version": 3.0}
  -> {"received": {"name": "Flask", "version": 3.0},
      "message": "数据接收成功",
      "keys": ["name", "version"]}''',
          ),

          // 重定向和响应
          const DividerLine(),
          const Paragraph(
            '4. 重定向与响应对象\n'
            'redirect(url) 将客户端重定向到另一个 URL，返回 302 状态码。'
            'abort(code) 立即终止请求并返回指定错误码。'
            'Flask 视图函数默认返回的是 Response 对象，但也可以返回字符串或元组。'
            '返回元组格式为 (body, status_code, headers)，'
            '或者使用 make_response() 显式创建 Response 对象。',
          ),
          const CodeBlock(
            r'''from flask import Flask, redirect, url_for, abort, make_response

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>首页</h1><p>Flask 重定向示例</p>'

# 使用 redirect() 进行重定向
@app.route('/old-page')
def old_page():
    """旧页面 — 重定向到新页面"""
    return redirect(url_for('new_page'))

@app.route('/new-page')
def new_page():
    return '<h1>新页面</h1><p>你已从旧页面重定向过来。</p>'

# 带参数的重定向
@app.route('/user/<username>')
def user_profile(username):
    return f'<h1>{username} 的个人主页</h1>'

@app.route('/profile')
def profile_redirect():
    """默认重定向到 alice 的用户页"""
    return redirect(url_for('user_profile', username='alice'))

# 使用 abort() 返回错误
@app.route('/admin')
def admin_panel():
    """只有管理员可以访问"""
    # abort(403)  # 返回 403 Forbidden
    return redirect(url_for('login'))

@app.route('/login')
def login():
    return '<h1>请先登录</h1>'

# 自定义响应对象
@app.route('/custom-response')
def custom_response():
    # 创建自定义响应
    resp = make_response('<h1>自定义响应</h1><p>设置了 Cookie</p>')
    resp.status_code = 200
    resp.headers['X-Custom-Header'] = 'custom-value'
    resp.set_cookie('user_token', 'abc123', max_age=3600)
    resp.content_type = 'text/html'
    return resp

# 返回元组 (body, status_code, headers)
@app.route('/api/status')
def api_status():
    return {'status': 'ok', 'version': '1.0'}, 200, {
        'X-API-Version': '1.0'
    }

if __name__ == '__main__':
    app.run(debug=True)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''访问 /old-page -> 302 重定向到 /new-page
访问 /profile  -> 302 重定向到 /user/alice
访问 /admin    -> 302 重定向到 /login
访问 /custom-response -> 设置 Cookie: user_token=abc123
访问 /api/status -> {"status": "ok", "version": "1.0"}''',
          ),

          // 简单的CRUD应用
          const DividerLine(),
          const Paragraph(
            '5. 简单 CRUD 应用示例\n'
            '下面是一个完整的待办事项管理应用（Todo App），演示了 Flask 的增删改查功能。'
            '使用内存列表存储数据（实际项目中会用数据库）。'
            '包含创建（Create）、读取（Read）、更新（Update）、删除（Delete）四个核心操作。'
            '这个例子展示了 Flask 在实际开发中的典型用法。',
          ),
          const CodeBlock(
            r"""from flask import Flask, request, redirect, url_for

app = Flask(__name__)

# 内存数据库（列表）
todos = [
    {'id': 1, 'title': '学习 Flask', 'done': False},
    {'id': 2, 'title': '写一个 Web 应用', 'done': False},
    {'id': 3, 'title': '部署到服务器', 'done': True},
]
next_id = 4


@app.route('/')
def index():
    '''首页 — 显示所有待办事项'''
    html = '<h1>📋 待办事项</h1>'

    # 过滤条件
    filter_by = request.args.get('filter', 'all')

    # 筛选列表
    if filter_by == 'active':
        items = [t for t in todos if not t['done']]
    elif filter_by == 'completed':
        items = [t for t in todos if t['done']]
    else:
        items = todos

    # 显示待办事项
    html += '<ul>'
    for todo in items:
        status = '✅' if todo['done'] else '⬜'
        html += f'''
        <li>
            {status}
            <a href="/toggle/{todo['id']}">
                {todo['title']}
            </a>
            <a href="/delete/{todo['id']}"
               style="color:red;text-decoration:none;"> [删除]</a>
        </li>
        '''
    html += '</ul>'

    # 添加待办事项表单
    html += '''
    <h3>添加新事项:</h3>
    <form method="POST" action="/add">
        <input type="text" name="title" placeholder="输入待办事项" required>
        <button type="submit">添加</button>
    </form>
    '''

    # 筛选链接
    html += f'''
    <p>
        <a href="/?filter=all">全部</a> |
        <a href="/?filter=active">未完成</a> |
        <a href="/?filter=completed">已完成</a>
    </p>
    '''

    return html


@app.route('/add', methods=['POST'])
def add_todo():
    '''添加新待办事项'''
    global next_id
    title = request.form.get('title', '').strip()
    if title:
        todos.append({'id': next_id, 'title': title, 'done': False})
        next_id += 1
    return redirect(url_for('index'))


@app.route('/toggle/<int:todo_id>')
def toggle_todo(todo_id):
    '''切换待办事项的完成状态'''
    for todo in todos:
        if todo['id'] == todo_id:
            todo['done'] = not todo['done']
            break
    return redirect(url_for('index'))


@app.route('/delete/<int:todo_id>')
def delete_todo(todo_id):
    '''删除待办事项'''
    global todos
    todos = [t for t in todos if t['id'] != todo_id]
    return redirect(url_for('index'))


if __name__ == '__main__':
    app.run(debug=True)""",
            language: 'Python',
          ),
          const OutputBox(
            r'''# 📋 待办事项
#   ✅ 部署到服务器 [删除]
#   ⬜ 学习 Flask [删除]
#   ⬜ 写一个 Web 应用 [删除]
#
# 添加新事项:
# [输入框...] [添加按钮]
#
# 全部 | 未完成 | 已完成

功能说明:
- GET / 显示待办列表（支持 ?filter=active/completed 筛选）
- POST /add 添加新待办事项
- GET /toggle/<id> 切换完成状态
- GET /delete/<id> 删除待办事项''',
          ),
          const TipBox(
            'Flask 开发中的最佳实践：'
            '1. 使用 app.config 管理配置（SECRET_KEY、数据库连接等）'
            '2. 大型应用使用蓝图（Blueprint）组织路由'
            '3. 使用 Flask-SQLAlchemy 操作数据库'
            '4. 使用 Jinja2 模板分离页面逻辑'
            '5. 生产环境使用 Gunicorn + Nginx 部署',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 22.5 使用模板
          // ==========================================
          const SectionHeader('22.5 使用模板', icon: Icons.dashboard),
          const Paragraph(
            '在之前的示例中，我们直接在 Python 代码中拼接 HTML 字符串。'
            '这种方式的问题显而易见：业务逻辑和页面展示混杂在一起，'
            '代码难以维护和扩展。'
            '模板引擎（Template Engine）通过将 HTML 代码分离到独立的模板文件中，'
            '实现了业务逻辑与表现层的分离。'
            'Flask 默认集成了 Jinja2 模板引擎，这是 Python 生态中最流行的模板系统。',
          ),
          const DividerLine(),

          // Jinja2模板基础
          const Paragraph(
            '1. Jinja2 模板基础\n'
            'Jinja2 模板是包含特殊占位符和标签的文本文件（通常是 HTML）。'
            '{{ variable }} 输出变量值，可以执行表达式和函数调用。'
            '{% tag %} 执行控制语句（for 循环、if 判断、block 继承等）。'
            '{# comment #} 模板注释，不会出现在渲染结果中。'
            'Flask 使用 render_template() 函数渲染模板，模板文件放在 templates 目录下。',
          ),
          const CodeBlock(
            r'''# Flask 代码: app.py
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html',
                          title='首页',
                          username='Alice',
                          age=25,
                          skills=['Python', 'Flask', 'HTML', 'CSS'])

@app.route('/user/<name>')
def user(name):
    return render_template('user.html',
                          name=name,
                          greeting=f'Hello, {name}!')

if __name__ == '__main__':
    app.run(debug=True)''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''{# templates/index.html #}
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>{{ title }} - Python学习平台</title>
</head>
<body>
    <h1>欢迎, {{ username }}!</h1>
    <p>你的年龄是: {{ age }} 岁</p>

    <h3>你的技能:</h3>
    <ul>
        {% for skill in skills %}
        <li>{{ skill }}</li>
        {% endfor %}
    </ul>

    {% if age >= 18 %}
    <p>你是成年人。</p>
    {% else %}
    <p>你是未成年人。</p>
    {% endif %}
</body>
</html>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''渲染结果:
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>首页 - Python学习平台</title>
</head>
<body>
    <h1>欢迎, Alice!</h1>
    <p>你的年龄是: 25 岁</p>

    <h3>你的技能:</h3>
    <ul>
        <li>Python</li>
        <li>Flask</li>
        <li>HTML</li>
        <li>CSS</li>
    </ul>

    <p>你是成年人。</p>
</body>
</html>''',
          ),

          // Jinja2过滤器
          const DividerLine(),
          const Paragraph(
            '2. Jinja2 过滤器\n'
            '过滤器通过管道符 | 应用于变量，对变量进行变换处理。'
            '常用过滤器：|upper 转换为大写、|lower 转换为小写、'
            '|capitalize 首字母大写、|title 每个单词首字母大写、'
            '|trim 去除首尾空白、|length 获取长度、'
            '|default("默认值") 设置默认值、|safe 标记为安全 HTML。'
            '|join(", ") 连接列表为字符串。'
            '还可以链式使用过滤器。',
          ),
          const CodeBlock(
            r'''{# templates/filters_demo.html #}
<!DOCTYPE html>
<html>
<head><title>过滤器演示</title></head>
<body>
    <h1>Jinja2 过滤器演示</h1>

    {% set message = "  hello, Flask World!  " %}

    <h3>字符串过滤器:</h3>
    <table border="1" cellpadding="5">
        <tr><th>过滤器</th><th>结果</th></tr>
        <tr><td>原始值</td><td>"{{ message }}"</td></tr>
        <tr><td>|upper</td><td>"{{ message|upper }}"</td></tr>
        <tr><td>|lower</td><td>"{{ message|lower }}"</td></tr>
        <tr><td>|capitalize</td><td>"{{ message|capitalize }}"</td></tr>
        <tr><td>|title</td><td>"{{ message|title }}"</td></tr>
        <tr><td>|trim</td><td>"{{ message|trim }}"</td></tr>
        <tr><td>|length</td><td>{{ message|length }} 字符</td></tr>
        <tr><td>|reverse</td><td>"{{ message|reverse }}"</td></tr>
    </table>

    {% set items = ["Python", "Flask", "Jinja2"] %}

    <h3>列表过滤器:</h3>
    <p>原始: {{ items }}</p>
    <p>|first: {{ items|first }}</p>
    <p>|last: {{ items|last }}</p>
    <p>|length: {{ items|length }} 项</p>
    <p>|join(", "): {{ items|join(" | ") }}</p>
    <p>|sort: {{ items|sort|join(", ") }}</p>

    <h3>默认值过滤器:</h3>
    <p>|default: "{{ undefined_var|default('无值') }}"</p>
    <p>|default 空字符串: "{{ ''|default('空', boolean=true) }}"</p>
</body>
</html>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''|upper  -> "  HELLO, FLASK WORLD!  "
|lower  -> "  hello, flask world!  "
|title  -> "  Hello, Flask World!  "
|trim   -> "hello, Flask World!"
|length -> 22 字符
|join   -> Python | Flask | Jinja2
|default -> "无值"（变量未定义时）''',
          ),

          // for循环和if判断
          const DividerLine(),
          const Paragraph(
            '3. 模板中的控制语句\n'
            'Jinja2 的 {% for %} 标签支持遍历列表和字典。'
            '循环内部可以使用特殊变量：loop.index（从1开始计数）、'
            'loop.index0（从0开始计数）、loop.first（是否第一个元素）、'
            'loop.last（是否最后一个元素）、loop.length（循环总长度）。'
            '{% if %} 标签支持条件判断，可以使用 and、or、not 等逻辑运算符。'
            '注意：模板中保持逻辑简单，复杂逻辑放在 Python 视图函数中。',
          ),
          const CodeBlock(
            r'''{# templates/loop_if_demo.html #}
<!DOCTYPE html>
<html>
<head><title>循环与判断</title></head>
<body>
    <h1>用户列表</h1>

    {% set users = [
        {'name': 'Alice', 'age': 25, 'active': True},
        {'name': 'Bob', 'age': 30, 'active': False},
        {'name': 'Charlie', 'age': 35, 'active': True},
        {'name': 'David', 'age': 28, 'active': True},
    ] %}

    <table border="1" cellpadding="8">
        <tr>
            <th>#</th>
            <th>姓名</th>
            <th>年龄</th>
            <th>状态</th>
            <th>年龄分类</th>
        </tr>

        {% for user in users %}
        <tr>
            <td>{{ loop.index }}</td>
            <td>
                {% if loop.first %}
                <strong>{{ user.name }} (首位)</strong>
                {% elif loop.last %}
                <em>{{ user.name }} (末位)</em>
                {% else %}
                {{ user.name }}
                {% endif %}
            </td>
            <td>{{ user.age }}</td>
            <td>
                {% if user.active %}
                <span style="color:green;">活跃</span>
                {% else %}
                <span style="color:gray;">未激活</span>
                {% endif %}
            </td>
            <td>
                {% if user.age < 18 %}
                未成年人
                {% elif user.age < 35 %}
                青年人
                {% elif user.age < 60 %}
                中年人
                {% else %}
                老年人
                {% endif %}
            </td>
        </tr>
        {% else %}
        <tr>
            <td colspan="5">暂无用户数据</td>
        </tr>
        {% endfor %}
    </table>

    <h3>统计信息</h3>
    <p>总用户数: {{ users|length }}</p>
    <p>活跃用户: {{ users|selectattr('active')|list|length }}</p>
    <p>平均年龄:
        {{ (users|sum(attribute='age') / users|length)|round(1) }}
    </p>
</body>
</html>''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''#   姓名          年龄  状态   年龄分类
1   Alice (首位)   25  活跃   青年人
2   Bob            30  未激活 青年人
3   Charlie        35  活跃   中年人
4   David (末位)   28  活跃   青年人

统计信息:
总用户数: 4
活跃用户: 3
平均年龄: 29.5''',
          ),

          // 模板继承
          const DividerLine(),
          const Paragraph(
            '4. 模板继承 — {% extends %} 和 {% block %}\n'
            '模板继承是 Jinja2 最强大的功能之一，它允许创建一个基础模板（父模板），'
            '其他子模板可以继承基础模板的结构并覆盖特定的区块。'
            '基础模板使用 {% block block_name %}...{% endblock %} 定义可被覆盖的区域。'
            '子模板使用 {% extends "base.html" %} 声明继承关系，'
            '然后使用同名的 {% block %} 覆盖父模板中的内容。'
            '这避免了在每个页面中重复写相同的结构代码。',
          ),
          const CodeBlock(
            r'''{# templates/base.html — 基础模板 #}
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}默认标题{% endblock %}</title>
    <link rel="stylesheet" href="/static/style.css">
    {% block extra_head %}{% endblock %}
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar">
        <div class="nav-brand">Python学习平台</div>
        <div class="nav-links">
            <a href="/">首页</a>
            <a href="/courses">课程</a>
            <a href="/about">关于</a>
            {% if current_user %}
            <a href="/profile">{{ current_user }}</a>
            <a href="/logout">退出</a>
            {% else %}
            <a href="/login">登录</a>
            {% endif %}
        </div>
    </nav>

    <!-- 页面主要内容 -->
    <main class="container">
        {% block content %}
        <!-- 子模板覆盖此区域 -->
        {% endblock %}
    </main>

    <!-- 页脚 -->
    <footer class="footer">
        <p>&copy; 2024 Python学习平台. 保留所有权利.</p>
        {% block footer_extra %}{% endblock %}
    </footer>

    <script src="/static/main.js"></script>
    {% block extra_scripts %}{% endblock %}
</body>
</html>''',
            language: 'HTML',
          ),
          const CodeBlock(
            r'''{# templates/home.html — 首页子模板 #}
{% extends "base.html" %}

{% block title %}首页 - Python学习平台{% endblock %}

{% block content %}
<div class="hero">
    <h1>欢迎来到 Python 学习平台!</h1>
    <p>从入门到精通，成为 Python 高手。</p>
    <a href="/courses" class="btn btn-primary">开始学习</a>
</div>

<div class="features">
    <div class="feature-card">
        <h3>系统教程</h3>
        <p>涵盖 Python 基础到高级的完整知识体系</p>
    </div>
    <div class="feature-card">
        <h3>实战项目</h3>
        <p>通过实际项目巩固所学知识</p>
    </div>
    <div class="feature-card">
        <h3>在线编程</h3>
        <p>内置在线编程环境，边学边练</p>
    </div>
</div>
{% endblock %}

{% block footer_extra %}
<p class="text-muted">今日访问: {{ visit_count }} 次</p>
{% endblock %}''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''基础模板 base.html 定义了页面骨架:
  - <head> 区块: 子模板可覆盖 title 和添加 extra_head
  - <nav> 导航栏: 所有页面共享
  - {% block content %}: 核心内容区，每个页面可不同
  - <footer> 页脚: 所有页面共享
  - {% block extra_scripts %}: 页面独享脚本

子模板只需要:
1. {% extends "base.html" %} 声明继承
2. 覆盖需要的 {% block %} 区域
3. 编写页面独有的内容

最终渲染结果 = 基础模板结构 + 子模板内容''',
          ),
          const TipBox(
            '模板继承的最佳实践：'
            '1. 基础模板中定义尽可能多的区块（block），给子模板最大的灵活性'
            '2. 使用 {{ super() }} 在子模板中保留父模板区块的内容'
            '3. 不要在模板中写复杂逻辑，保持模板简洁'
            '4. 收藏常用代码片段（导航栏、分页等）到单独的模板文件中，用 {% include %} 引用',
            type: TipType.tip,
          ),

          // include包含
          const DividerLine(),
          const Paragraph(
            '5. 模板包含 — {% include %}\n'
            '{% include "filename" %} 可以将另一个模板文件的内容包含进来。'
            '这适用于在多个页面中复用小段代码，如按钮组件、警告框、分页导航等。'
            '被包含的模板可以访问父模板的上下文变量。'
            '{% include %} 不会创建新的作用域，可以直接使用当前上下文中的所有变量。',
          ),
          const CodeBlock(
            r'''{# templates/_alert.html — 警告框组件 #}
{% if type == 'success' %}
<div class="alert alert-success">{{ message }}</div>
{% elif type == 'warning' %}
<div class="alert alert-warning">{{ message }}</div>
{% elif type == 'error' %}
<div class="alert alert-danger">{{ message }}</div>
{% else %}
<div class="alert alert-info">{{ message }}</div>
{% endif %}''',
            language: 'HTML',
          ),
          const CodeBlock(
            r'''{# templates/user_register.html #}
{% extends "base.html" %}

{% block title %}用户注册{% endblock %}

{% block content %}
<h1>用户注册</h1>

{% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}
        {% for category, message in messages %}
            {% include "_alert.html" %}
        {% endfor %}
    {% endif %}
{% endwith %}

<form method="POST" action="/register">
    <div class="form-group">
        <label>用户名:</label>
        <input type="text" name="username" required>
    </div>
    <div class="form-group">
        <label>邮箱:</label>
        <input type="email" name="email" required>
    </div>
    <div class="form-group">
        <label>密码:</label>
        <input type="password" name="password" required>
    </div>
    <button type="submit" class="btn btn-primary">注册</button>
</form>

{% endblock %}

{% block extra_scripts %}
<script src="/static/validate.js"></script>
{% endblock %}''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''使用 {% include "_alert.html" %} 时传入不同参数:
{% include "_alert.html" with context %}
  # 传递参数: type='success', message='注册成功!'
  # 渲染: <div class="alert alert-success">注册成功!</div>

{% include "_alert.html" with context %}
  # 传递参数: type='error', message='用户名已存在'
  # 渲染: <div class="alert alert-danger">用户名已存在</div>''',
          ),

          // 综合示例
          const DividerLine(),
          const Paragraph(
            '6. 综合示例：Flask + Jinja2 完整 CRUD\n'
            '下面是一个将之前待办事项应用改造为使用 Jinja2 模板的完整例子。'
            '通过模板继承和组件化，代码更加清晰和可维护。'
            '模板文件放在 templates/ 目录下，静态文件放在 static/ 目录下。'
            '这是实际项目中推荐的组织方式。',
          ),
          const CodeBlock(
            r'''# app.py — 使用 Jinja2 模板的 Flask 应用
from flask import (
    Flask, render_template, request,
    redirect, url_for, flash
)

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'  # 用于 flash 消息

# 模拟数据库
posts = [
    {'id': 1, 'title': 'Flask入门教程', 'content': 'Flask是一个轻量级Web框架...',
     'author': 'Alice', 'created': '2024-01-15', 'views': 120},
    {'id': 2, 'title': 'Jinja2模板指南', 'content': 'Jinja2是Python最流行的模板引擎...',
     'author': 'Bob', 'created': '2024-01-20', 'views': 85},
]
next_id = 3


@app.route('/')
def index():
    """首页 — 显示文章列表"""
    return render_template(
        'blog/index.html',
        posts=posts,
        total_posts=len(posts)
    )


@app.route('/post/<int:post_id>')
def show_post(post_id):
    """文章详情页"""
    post = next((p for p in posts if p['id'] == post_id), None)
    if post is None:
        flash('文章不存在!', 'error')
        return redirect(url_for('index'))

    # 增加浏览次数
    post['views'] += 1
    return render_template('blog/post.html', post=post)


@app.route('/create', methods=['GET', 'POST'])
def create_post():
    """创建文章"""
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        author = request.form.get('author', '').strip()

        if not title or not content:
            flash('标题和内容不能为空!', 'warning')
            return render_template('blog/create.html')

        global next_id
        posts.append({
            'id': next_id,
            'title': title,
            'content': content,
            'author': author or '匿名',
            'created': '2024-02-01',
            'views': 0,
        })
        next_id += 1
        flash('文章发布成功!', 'success')
        return redirect(url_for('index'))

    return render_template('blog/create.html')


@app.route('/delete/<int:post_id>')
def delete_post(post_id):
    """删除文章"""
    global posts
    posts = [p for p in posts if p['id'] != post_id]
    flash('文章已删除', 'info')
    return redirect(url_for('index'))


if __name__ == '__main__':
    app.run(debug=True)''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''{# templates/base.html #}
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}我的博客{% endblock %}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Microsoft YaHei", sans-serif;
               background: #f0f2f5; color: #333; }
        .navbar { background: #2c3e50; color: white;
                  padding: 16px 32px; display: flex;
                  justify-content: space-between; align-items: center; }
        .navbar a { color: white; text-decoration: none; margin-left: 20px; }
        .container { max-width: 900px; margin: 20px auto;
                     padding: 20px; }
        .flash { padding: 12px 20px; border-radius: 6px;
                 margin-bottom: 16px; }
        .flash-success { background: #d4edda; color: #155724;
                         border: 1px solid #c3e6cb; }
        .flash-error { background: #f8d7da; color: #721c24;
                        border: 1px solid #f5c6cb; }
        .flash-warning { background: #fff3cd; color: #856404;
                          border: 1px solid #ffeeba; }
        .flash-info { background: #d1ecf1; color: #0c5460;
                       border: 1px solid #bee5eb; }
        .btn { display: inline-block; padding: 8px 16px;
               background: #3498db; color: white; text-decoration: none;
               border-radius: 4px; border: none; cursor: pointer; }
        .btn-danger { background: #e74c3c; }
        .footer { text-align: center; padding: 20px;
                  color: #666; font-size: 14px; }
    </style>
    {% block extra_head %}{% endblock %}
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <a href="/" style="font-size:20px;font-weight:bold;">我的博客</a>
        </div>
        <div>
            <a href="/">首页</a>
            <a href="/create">写文章</a>
        </div>
    </nav>

    <div class="container">
        {% with msgs = get_flashed_messages(with_categories=true) %}
            {% if msgs %}
                {% for category, msg in msgs %}
                <div class="flash flash-{{ category }}">{{ msg }}</div>
                {% endfor %}
            {% endif %}
        {% endwith %}

        {% block content %}{% endblock %}
    </div>

    <div class="footer">
        <p>&copy; 2024 我的博客. 使用 Flask + Jinja2 构建.</p>
    </div>
</body>
</html>''',
            language: 'HTML',
          ),
          const CodeBlock(
            r'''{# templates/blog/index.html #}
{% extends "base.html" %}

{% block title %}首页 - 我的博客{% endblock %}

{% block content %}
<h1 style="margin-bottom:20px;">最新文章
    <small style="font-size:14px;color:#666;">
        (共 {{ total_posts }} 篇)
    </small>
</h1>

{% if posts %}
    {% for post in posts %}
    <div style="background:white;padding:20px;margin-bottom:16px;
                border-radius:8px;box-shadow:0 2px 4px rgba(0,0,0,0.1);">
        <h2>
            <a href="/post/{{ post.id }}"
               style="color:#2c3e50;text-decoration:none;">
                {{ post.title }}
            </a>
        </h2>
        <p style="color:#666;margin:8px 0;">
            {{ post.content[:100] }}{% if post.content|length > 100 %}...{% endif %}
        </p>
        <div style="display:flex;justify-content:space-between;
                    color:#999;font-size:13px;">
            <span>
                作者: {{ post.author }} |
                发布于: {{ post.created }}
            </span>
            <span>
                浏览: {{ post.views }} 次 |
                <a href="/delete/{{ post.id }}"
                   style="color:#e74c3c;text-decoration:none;"
                   onclick="return confirm('确认删除?')">删除</a>
            </span>
        </div>
    </div>
    {% endfor %}
{% else %}
    <div style="text-align:center;padding:60px;color:#999;">
        <h2>暂无文章</h2>
        <p style="margin:16px 0;">还没有发布任何文章。</p>
        <a href="/create" class="btn">写第一篇</a>
    </div>
{% endif %}
{% endblock %}''',
            language: 'HTML',
          ),
          const CodeBlock(
            r'''{# templates/blog/post.html #}
{% extends "base.html" %}

{% block title %}{{ post.title }} - 我的博客{% endblock %}

{% block content %}
<article style="background:white;padding:30px;border-radius:8px;
                box-shadow:0 2px 4px rgba(0,0,0,0.1);">
    <h1 style="margin-bottom:8px;">{{ post.title }}</h1>

    <div style="color:#999;font-size:13px;margin-bottom:20px;
                padding-bottom:16px;border-bottom:1px solid #eee;">
        作者: {{ post.author }} |
        发布于: {{ post.created }} |
        浏览: {{ post.views }} 次
    </div>

    <div style="line-height:1.8;font-size:15px;">
        {{ post.content|safe }}
    </div>

    <div style="margin-top:30px;padding-top:20px;
                border-top:1px solid #eee;">
        <a href="/" class="btn">&larr; 返回首页</a>
        <a href="/delete/{{ post.id }}"
           class="btn btn-danger"
           onclick="return confirm('确认删除?')"
           style="margin-left:10px;">删除本文</a>
    </div>
</article>
{% endblock %}''',
            language: 'HTML',
          ),
          const CodeBlock(
            r'''{# templates/blog/create.html #}
{% extends "base.html" %}

{% block title %}写文章 - 我的博客{% endblock %}

{% block content %}
<h1 style="margin-bottom:20px;">写新文章</h1>

<div style="background:white;padding:30px;border-radius:8px;
            box-shadow:0 2px 4px rgba(0,0,0,0.1);">
    <form method="POST" action="/create">
        <div style="margin-bottom:16px;">
            <label style="display:block;margin-bottom:6px;font-weight:bold;">
                文章标题:
            </label>
            <input type="text" name="title" required
                   style="width:100%;padding:10px;border:1px solid #ddd;
                          border-radius:4px;font-size:15px;"
                   placeholder="请输入文章标题">
        </div>

        <div style="margin-bottom:16px;">
            <label style="display:block;margin-bottom:6px;font-weight:bold;">
                作者:
            </label>
            <input type="text" name="author"
                   style="width:100%;padding:10px;border:1px solid #ddd;
                          border-radius:4px;font-size:15px;"
                   placeholder="可选，默认为匿名">
        </div>

        <div style="margin-bottom:16px;">
            <label style="display:block;margin-bottom:6px;font-weight:bold;">
                文章内容:
            </label>
            <textarea name="content" required rows="12"
                      style="width:100%;padding:10px;border:1px solid #ddd;
                             border-radius:4px;font-size:15px;
                             font-family:inherit;resize:vertical;"
                      placeholder="请输入文章内容..."></textarea>
        </div>

        <div>
            <button type="submit" class="btn">发布文章</button>
            <a href="/" style="margin-left:10px;color:#666;">取消</a>
        </div>
    </form>
</div>
{% endblock %}''',
            language: 'HTML',
          ),
          const OutputBox(
            r'''综合示例功能概览:

1. 模板继承: base.html 定义页面骨架，子模板覆盖 content 区块
2. 组件复用: flash 消息组件在 base.html 中统一处理
3. 数据展示: index.html 遍历文章列表，显示摘要
4. 详情页面: post.html 展示文章全文
5. 表单处理: create.html 提供文章创建表单
6. 消息闪回: flash() 传递操作状态信息
7. 安全删除: JavaScript confirm() 确认删除操作

运行效果:
  访问 /         -> 文章列表（按卡片布局显示）
  访问 /post/1  -> 查看文章详情
  访问 /create  -> 创建新文章
  点击删除      -> 确认后删除文章''',
          ),
          const TipBox(
            'Jinja2 模板最佳实践总结：'
            '1. 模板继承实现页面结构复用，避免重复代码'
            '2. 使用 {% include %} 抽取可复用的组件（按钮、卡片、分页等）'
            '3. 在模板中只做简单的变量输出和基本控制流，复杂逻辑放在 Python 视图函数中'
            '4. 使用 {{ super() }} 在子模板中保留父模板 block 的原始内容'
            '5. 使用 |safe 过滤器时要确保内容是可信的，避免 XSS 攻击'
            '6. 善用过滤器简化模板代码，如 |default、|join、|round 等',
            type: TipType.tip,
          ),
          const _FlaskRouteDemo(),
          const DividerLine(),

          // ==========================================
          // 本章总结
          // ==========================================
          const SectionHeader('本章总结', icon: Icons.summarize),
          const Paragraph(
            '本章全面介绍了 Python Web 开发的核心知识体系。'
            '从最底层的 HTTP 协议开始，理解了 Web 通信的基本机制；'
            '然后学习了 HTML 这个 Web 页面的构建语言；'
            '接着深入 WSGI 接口，揭示了 Python Web 框架的工作基础；'
            '之后掌握了 Flask 框架，体验了现代 Web 框架的便捷高效；'
            '最后学习了 Jinja2 模板引擎，实现了业务逻辑与表现层的清晰分离。',
          ),
          const Paragraph(
            '学习路径建议：\n'
            '1. 深入理解 HTTP 协议的请求-响应模型和各种状态码含义\n'
            '2. 掌握 HTML 基本标签和表单提交的 GET/POST 差异\n'
            '3. 理解 WSGI 规范，有助于理解 Flask/Django 框架原理\n'
            '4. 熟练使用 Flask 框架构建 Web 应用\n'
            '5. 掌握 Jinja2 模板语言，实现优雅的页面渲染\n'
            '6. 进阶学习：数据库集成、用户认证、RESTful API、部署上线',
          ),
          const TipBox(
            'Web 开发的学习是一个持续深入的过程。建议从简单的静态页面开始，'
            '逐步加入动态功能、数据库、用户系统，最终构建完整的 Web 应用。'
            '多动手实践是掌握 Web 开发的最佳途径。',
            type: TipType.info,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
