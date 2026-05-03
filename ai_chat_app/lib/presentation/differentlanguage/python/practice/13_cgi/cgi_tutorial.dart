import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python CGI 编程教程 —— 第13章（完整扩展版）
class PythonCGITutorial extends StatelessWidget {
  const PythonCGITutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第13章 CGI编程')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Paragraph(
              'CGI（Common Gateway Interface，通用网关接口）是 Web 服务器与外部程序（如 Python 脚本）'
              '之间通信的标准协议。当用户访问某个 URL 时，Web 服务器调用对应的 CGI 脚本，'
              '将请求信息通过环境变量传递给脚本，脚本处理后将结果（通常是 HTML）返回给服务器。',
            ),
            const DividerLine(),

            // ===== 1. 什么是 CGI =====
            const SectionHeader('什么是 CGI', icon: Icons.info_outline),
            const Paragraph(
              'CGI 是一种让 Web 服务器能够运行动态程序并生成动态页面的技术。'
              '在 CGI 模型中：用户的浏览器发送 HTTP 请求到 Web 服务器，'
              '服务器识别出请求的是 CGI 资源后，创建新进程执行该脚本，'
              '脚本读取环境变量和标准输入获取请求数据，处理后将结果写入标准输出返回给服务器。',
            ),
            const Paragraph(
              'CGI 的核心优势是简单、语言无关——任何能读写标准输入输出的语言都可以写 CGI 程序。'
              'Python、Perl、C、Shell 脚本等都可以。缺点是每个请求都需要创建新进程，性能较差。',
            ),
            const TipBox(
              'CGI 是早期动态网页方案（1993 年提出），如今已被 WSGI/ASGI 等更高效的方案取代。'
              '但学习 CGI 有助于理解 HTTP 请求-响应模型和 Web 编程基础原理。',
              type: TipType.info,
            ),
            const DividerLine(),

            // ===== 2. CGI 架构 =====
            const SectionHeader('CGI 架构', icon: Icons.account_tree),
            const Paragraph(
              'CGI 的工作流程遵循一个清晰的请求-响应周期：浏览器发起 HTTP 请求，'
              'Web 服务器（Apache/Nginx）根据 URL 路由规则定位到 CGI 脚本，'
              '服务器为脚本设置环境变量（如 QUERY_STRING、REQUEST_METHOD），'
              '如果是 POST 请求，还会将请求体通过标准输入（stdin）传递给脚本，'
              '脚本处理后通过标准输出（stdout）返回响应（含 HTTP 头 + 内容体）。',
            ),
            CodeBlock(
              r'''浏览器 ←→ Web服务器 ←→ CGI脚本
  │                    │
  │  ① HTTP请求        │
  │─────────────────►  │
  │                    │  ② 创建进程 & 设置环境变量
  │                    │─────────────────►
  │                    │  ③ 执行脚本 (Python)
  │                    │◄────────────────
  │                    │  ④ 读取 stdout 响应
  │  ⑤ HTTP响应        │
  │◄─────────────────  │
''',
              language: 'Python',
            ),
            const Paragraph(
              '流程总结：用户请求 → Web 服务器解析 → 环境变量传递 → 脚本执行 → '
              '标准输出返回 → 服务器转发给浏览器。每一步都有明确的分工。',
            ),
            const DividerLine(),

            // ===== 3. 搭建 CGI 环境 =====
            const SectionHeader('搭建 CGI 环境', icon: Icons.settings),
            const Paragraph(
              '要在本地测试 Python CGI，需要安装 Apache 或 Nginx 等 Web 服务器，'
              '配置好 cgi-bin 目录。这里以 Python 内置的 http.server 模块为例，'
              '它支持简单的 CGI 处理，适合学习和测试。',
            ),
            CodeBlock(
              r'''# 在项目目录创建 cgi-bin 文件夹
mkdir cgi-bin

# 在该目录下编写 Python CGI 脚本，确保有执行权限
# hello.py
#!/usr/bin/env python3
print("Content-Type: text/html\n")
print("<h1>Hello, CGI!</h1>")

# 使用 Python 内置服务器启动 CGI 支持
# 终端执行：
python -m http.server --cgi 8000

# 访问 http://localhost:8000/cgi-bin/hello.py
''',
              language: 'Bash',
            ),
            const Paragraph(
              '对于 Apache 服务器，需要在配置文件中启用 CGI 模块并指定 cgi-bin 目录：'
              '通过 LoadModule cgi_module 启用模块，使用 ScriptAlias 指令映射 URL 路径到脚本目录。'
              'Nginx 本身不直接支持 CGI，需要使用 uWSGI 或 FastCGI 中间件来桥接。',
            ),
            const TipBox(
              'CGI 脚本**必须**放在配置的 cgi-bin 目录中，并且要有可执行权限。'
              'Linux/Mac 上使用 chmod +x 设置，Windows 上需要配置脚本映射。',
              type: TipType.caution,
            ),
            const DividerLine(),

            // ===== 4. CGI 模块与调试 =====
            const SectionHeader('CGI 模块与调试', icon: Icons.bug_report),
            const Paragraph(
              'Python 标准库提供了 cgi 和 cgitb 模块来处理 CGI 编程。'
              'cgi.FieldStorage 用于读取表单数据，cgitb 则提供强大的错误调试功能。'
              '开发阶段建议启用 cgitb，它会在浏览器中显示详细的错误信息和调用栈。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb

# 启用 CGI 错误追踪（开发环境使用）
# 会在浏览器页面中显示详细的错误信息和回溯
cgitb.enable()

# 创建 FieldStorage 实例，自动解析 GET/POST 数据
form = cgi.FieldStorage()

# 获取表单字段值
name = form.getvalue('name', '访客')
print("Content-Type: text/html\n")
print(f"<h1>你好，{name}！</h1>")
''',
              language: 'Python',
            ),
            const TipBox(
              'cgitb.enable() 会捕获未处理的异常并在浏览器中显示详细的 HTML 格式错误报告，'
              '包含变量值和调用栈——对调试非常有帮助。但生产环境务必关闭，'
              '否则会泄露敏感信息给用户。',
              type: TipType.warning,
            ),
            const DividerLine(),

            // ===== 5. 处理 GET 请求 =====
            const SectionHeader('处理 GET 请求', icon: Icons.arrow_downward),
            const Paragraph(
              'GET 请求的数据附加在 URL 的查询字符串中（?key=value&key2=value2）。'
              'CGI 脚本可以通过 os.environ["QUERY_STRING"] 获取原始查询字符串，'
              '也可以使用 cgi.FieldStorage 自动解析。推荐使用后一种方式。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import os
import cgi
import cgitb
cgitb.enable()

# 方法一：手动解析 QUERY_STRING
query = os.environ.get('QUERY_STRING', '')
print(f"<!-- 原始查询字符串: {query} -->")

# 方法二：使用 FieldStorage 自动解析（推荐）
form = cgi.FieldStorage()
name = form.getvalue('name', '匿名')
age = form.getvalue('age', '未知')

print("Content-Type: text/html\n")
print(f"""
<html><body>
  <h2>GET 请求处理结果</h2>
  <p>姓名: {name}</p>
  <p>年龄: {age}</p>
  <p>完整查询: {query}</p>
</body></html>
""")

# 访问示例: http://localhost:8000/cgi-bin/get_demo.py?name=张三&age=25
''',
              language: 'Python',
            ),
            const OutputBox(
              '访问 http://localhost:8000/cgi-bin/get_demo.py?name=张三&age=25\n'
              '页面显示:\n'
              'GET 请求处理结果\n'
              '姓名: 张三\n'
              '年龄: 25\n'
              '完整查询: name=张三&age=25',
            ),
            const DividerLine(),

            // ===== 6. 处理 POST 请求 =====
            const SectionHeader('处理 POST 请求', icon: Icons.arrow_upward),
            const Paragraph(
              'POST 请求的数据通过请求体（Body）发送，长度更大，更安全。'
              'CGI 脚本通过标准输入（stdin）读取 POST 数据，'
              'Content-Length 头告诉脚本要读多少字节。cgi.FieldStorage 同样能处理 POST。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
cgitb.enable()

print("Content-Type: text/html\n")
print("<html><body>")

# 判断请求方法
form = cgi.FieldStorage()
if form.getvalue('username'):
    username = form.getvalue('username')
    password = form.getvalue('password')
    print(f"<h2>欢迎, {username}!</h2>")
    print("<p>登录成功（密码已安全处理）</p>")
else:
    # 显示登录表单
    print("""
    <form method="post">
        用户名: <input type="text" name="username"><br>
        密码: <input type="password" name="password"><br>
        <input type="submit" value="登录">
    </form>
    """)

print("</body></html>")
''',
              language: 'Python',
            ),
            const TipBox(
              'cgi.FieldStorage 自动处理 GET 和 POST 两种请求方式。'
              '当请求方法是 GET 时，它从 QUERY_STRING 读取数据；'
              '当是 POST 时，它从标准输入读取。开发者不需要手动区分。',
              type: TipType.tip,
            ),
            const DividerLine(),

            // ===== 7. CGI HTTP 头 =====
            const SectionHeader('CGI HTTP 头', icon: Icons.list_alt),
            const Paragraph(
              'CGI 脚本的第一部分输出是 HTTP 头，以空行（两个换行符）与内容体分隔。'
              '最常见的头是 Content-Type，但还有其他重要头信息。'
              '每个头占据一行，格式为 "头名: 头值"。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
cgitb.enable()

# Content-Type：告诉浏览器返回内容的类型
print("Content-Type: text/html; charset=utf-8")

# Set-Cookie：设置 Cookie
print("Set-Cookie: user=guest; path=/; max-age=3600")

# Refresh：定时刷新/跳转
# print("Refresh: 5; url=https://example.com")

# 空行分隔头和体
print()

# 正文部分
print("""
<html><body>
  <h1>HTTP 头演示</h1>
  <p>本页响应包含: Content-Type 和 Set-Cookie 头</p>
</body></html>
""")
''',
              language: 'Python',
            ),
            const Paragraph(
              '常用的 CGI 响应头：Content-Type 指定 MIME 类型（text/html、text/plain、image/jpeg 等）；'
              'Location 用于重定向（设置后浏览器自动跳转到指定 URL）；'
              'Set-Cookie 在客户端设置 Cookie；Status 指定 HTTP 状态码（如 404 Not Found）；'
              'Refresh 用于定时刷新或跳转。注意：所有头必须在空行之前输出。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
# 重定向示例 —— 使用 Location 头
print("Location: /new-page.html")
print()  # 空行必须

# 注意：使用 Location 后不需要输出 Content-Type
''',
              language: 'Python',
            ),
            const TipBox(
              'HTTP 头之后**必须**有一个空行（两个换行符 \\n\\n），否则浏览器会将头也当作内容显示。'
              'Headers 和 Body 之间永远需要这个空行分隔。',
              type: TipType.caution,
            ),
            const DividerLine(),

            // ===== 8. 从 CGI 生成 HTML =====
            const SectionHeader('从 CGI 生成 HTML', icon: Icons.code),
            const Paragraph(
              'Python CGI 最常用的方式就是动态生成 HTML。'
              '通过 print() 输出带 Content-Type: text/html 头的 HTML 内容，'
              '浏览器会将其渲染为网页。可以结合 Python 的字符串格式化'
              '或 f-string 来插入动态数据。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
import datetime
cgitb.enable()

form = cgi.FieldStorage()
name = form.getvalue('name', '访客')

# 获取当前时间
now = datetime.datetime.now()
hour = now.hour

# 根据时段生成问候
if hour < 6:
    greeting = '夜深了'
elif hour < 12:
    greeting = '早上好'
elif hour < 18:
    greeting = '下午好'
else:
    greeting = '晚上好'

print("Content-Type: text/html\n")
print(f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <title>动态问候页</title>
    <style>
        body {{ font-family: Arial, sans-serif; text-align: center; margin-top: 100px; }}
        h1 {{ color: #2c3e50; }}
        .time {{ color: #7f8c8d; font-size: 14px; }}
    </style>
</head>
<body>
    <h1>{greeting}，{name}！</h1>
    <p class="time">当前时间：{now.strftime('%Y-%m-%d %H:%M:%S')}</p>
    <p>这是一段由 Python CGI 动态生成的 HTML 页面。</p>
</body>
</html>""")
''',
              language: 'Python',
            ),
            const OutputBox(
              '<!DOCTYPE html>\n'
              '<html lang="zh-CN">\n'
              '<head><meta charset="utf-8"><title>动态问候页</title></head>\n'
              '<body>\n'
              '  <h1>下午好，访客！</h1>\n'
              '  <p class="time">当前时间：2025-01-15 14:30:00</p>\n'
              '  <p>这是一段由 Python CGI 动态生成的 HTML 页面。</p>\n'
              '</body>\n'
              '</html>',
            ),
            const DividerLine(),

            // ===== 9. 表单处理 =====
            const SectionHeader('表单处理', icon: Icons.input),
            const Paragraph(
              'CGI 脚本可以处理各种 HTML 表单控件：文本输入框、复选框、单选按钮、'
              '下拉选择框、文本域等。每个控件的值通过 form.getvalue() 获取，'
              '对于多值控件（如多选复选框）使用 form.getlist()。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
cgitb.enable()

form = cgi.FieldStorage()

print("Content-Type: text/html\n")
print("<html><body>")

if form.getvalue('submit'):
    # 处理表单提交
    username = form.getvalue('username', '')
    gender = form.getvalue('gender', '未选择')
    # 复选框：可能多选，用 getlist()
    hobbies = form.getlist('hobby')
    city = form.getvalue('city', '')
    bio = form.getvalue('bio', '')

    print(f"<h2>提交结果</h2>")
    print(f"<p><b>用户名：</b>{username}</p>")
    print(f"<p><b>性别：</b>{gender}</p>")
    print(f"<p><b>爱好：</b>{', '.join(hobbies) or '无'}</p>")
    print(f"<p><b>城市：</b>{city}</p>")
    print(f"<p><b>简介：</b>{bio}</p>")
    print('<a href="">返回表单</a>')
else:
    # 显示表单
    print("""
    <form method="post">
        <p>用户名: <input type="text" name="username"></p>
        <p>性别:
            <input type="radio" name="gender" value="男">男
            <input type="radio" name="gender" value="女">女
        </p>
        <p>爱好:
            <input type="checkbox" name="hobby" value="阅读">阅读
            <input type="checkbox" name="hobby" value="音乐">音乐
            <input type="checkbox" name="hobby" value="运动">运动
        </p>
        <p>城市:
            <select name="city">
                <option value="北京">北京</option>
                <option value="上海">上海</option>
                <option value="广州">广州</option>
            </select>
        </p>
        <p>简介:<br><textarea name="bio" rows="4" cols="40"></textarea></p>
        <p><input type="submit" name="submit" value="提交"></p>
    </form>
    """)

print("</body></html>")
''',
              language: 'Python',
            ),
            const TipBox(
              '对于复选框等可能提交多个值的控件，务必使用 form.getlist() 而不是 '
              'form.getvalue()，否则只会得到最后一个值。'
              'getlist() 始终返回列表，即使用户只选一项。',
              type: TipType.warning,
            ),
            const DividerLine(),

            // ===== 10. 文件上传 =====
            const SectionHeader('文件上传', icon: Icons.upload_file),
            const Paragraph(
              'CGI 也支持文件上传。表单需要设置 enctype="multipart/form-data"，'
              '脚本通过 FieldStorage 读取上传的文件数据。'
              '上传的文件在 FieldStorage 中有 file 属性用于读取文件内容，'
              'filename 属性获取原始文件名。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
import os
cgitb.enable()

# 上传文件保存目录
UPLOAD_DIR = '/tmp/uploads'
os.makedirs(UPLOAD_DIR, exist_ok=True)

form = cgi.FieldStorage()

print("Content-Type: text/html\n")
print("<html><body>")

# 检查是否有文件上传
if 'file' in form and form['file'].filename:
    file_item = form['file']
    filename = os.path.basename(file_item.filename)
    file_data = file_item.file.read()
    file_size = len(file_data)

    # 保存文件
    save_path = os.path.join(UPLOAD_DIR, filename)
    with open(save_path, 'wb') as f:
        f.write(file_data)

    print(f"<h2>上传成功！</h2>")
    print(f"<p>文件名: {filename}</p>")
    print(f"<p>大小: {file_size} 字节</p>")
    print(f"<p>保存位置: {save_path}</p>")
else:
    print("""
    <form method="post" enctype="multipart/form-data">
        <p>选择文件: <input type="file" name="file"></p>
        <p><input type="submit" value="上传"></p>
    </form>
    """)

print("</body></html>")
''',
              language: 'Python',
            ),
            const TipBox(
              '处理文件上传时务必注意：对大文件设置大小限制，使用 os.path.basename() '
              '清理文件名防止路径遍历攻击，生产环境建议使用专门的框架（如 Django）处理上传。',
              type: TipType.caution,
            ),
            const DividerLine(),

            // ===== 11. Cookie 处理 =====
            const SectionHeader('Cookie 处理', icon: Icons.cookie),
            const Paragraph(
              'Cookie 是服务器存储在浏览器中的小数据片段，用于维持状态信息。'
              'CGI 脚本通过 HTTP 头的 Set-Cookie 字段设置 Cookie，'
              '通过 os.environ["HTTP_COOKIE"] 读取浏览器发送的 Cookie。'
              'Cookie 通常用于会话管理、个性化设置和追踪。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import os
import cgi
import cgitb
cgitb.enable()

form = cgi.FieldStorage()

# 设置新 Cookie（如果有提交）
new_theme = form.getvalue('theme')
new_username = form.getvalue('set_user')

headers = []
if new_theme:
    # max-age: Cookie 有效期（秒）, path: 生效路径
    headers.append(f"Set-Cookie: theme={new_theme}; path=/; max-age=86400")
if new_username:
    headers.append(f"Set-Cookie: username={new_username}; path=/; max-age=3600")

# 读取已有 Cookie
cookies = {}
cookie_str = os.environ.get('HTTP_COOKIE', '')
if cookie_str:
    for pair in cookie_str.split('; '):
        if '=' in pair:
            key, value = pair.split('=', 1)
            cookies[key] = value

current_theme = cookies.get('theme', '默认')
current_user = cookies.get('username', '访客')

# 输出头
for h in headers:
    print(h)
print("Content-Type: text/html\n")

print(f"""
<html><body>
  <h2>Cookie 演示</h2>
  <p>当前用户: {current_user}</p>
  <p>当前主题: {current_theme}</p>
  <form method="post">
    <p>设置用户名: <input type="text" name="set_user"></p>
    <p>选择主题:
      <select name="theme">
        <option value="浅色">浅色</option>
        <option value="深色">深色</option>
      </select>
    </p>
    <p><input type="submit" value="保存设置"></p>
  </form>
</body></html>""")
''',
              language: 'Python',
            ),
            const TipBox(
              'Cookie 有大小限制（通常 4KB），不要存储大量数据。'
              '敏感信息不要明文存储在 Cookie 中。设置 HttpOnly 标志可以防止 JavaScript 读取 Cookie，'
              '增强安全性。',
              type: TipType.warning,
            ),
            const DividerLine(),

            // ===== 12. 会话管理 =====
            const SectionHeader('会话管理基础', icon: Icons.folder_shared),
            const Paragraph(
              'HTTP 是无状态协议，每个请求相互独立。会话管理通过在多个请求间'
              '维持用户状态来实现"登录保持"等功能。CGI 中常见的会话实现方式：'
              '基于 Cookie 的会话 ID + 服务端存储。收到请求时，根据 Cookie 中的会话 ID '
              '从文件或数据库中查找对应的会话数据。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import os
import cgi
import cgitb
import uuid
import json
import tempfile
cgitb.enable()

SESSION_DIR = os.path.join(tempfile.gettempdir(), 'cgi_sessions')
os.makedirs(SESSION_DIR, exist_ok=True)

def get_session():
    """获取或创建会话"""
    cookie_str = os.environ.get('HTTP_COOKIE', '')
    session_id = None

    # 从 Cookie 中提取 session_id
    for pair in cookie_str.split('; '):
        if pair.startswith('SESSION_ID='):
            session_id = pair.split('=', 1)[1]
            break

    # 无有效会话，创建新会话
    if not session_id or not os.path.exists(
            os.path.join(SESSION_DIR, session_id)):
        session_id = str(uuid.uuid4())
        session_data = {'visits': 0}
    else:
        with open(os.path.join(SESSION_DIR, session_id), 'r') as f:
            session_data = json.load(f)

    session_data['visits'] = session_data.get('visits', 0) + 1

    with open(os.path.join(SESSION_DIR, session_id), 'w') as f:
        json.dump(session_data, f)

    return session_id, session_data

session_id, session = get_session()

print(f"Set-Cookie: SESSION_ID={session_id}; path=/; max-age=3600")
print("Content-Type: text/html\n")
print(f"""
<html><body>
  <h2>会话管理演示</h2>
  <p>会话 ID: {session_id[:8]}...</p>
  <p>您已访问本页 <b>{session['visits']}</b> 次</p>
</body></html>""")
''',
              language: 'Python',
            ),
            const Paragraph(
              '这个简单的文件会话系统演示了基本原理：首次访问时创建新会话 ID 并通过 Cookie '
              '发给浏览器；后续请求从 Cookie 中读取会话 ID 并加载对应的会话文件。'
              '生产环境应使用数据库（如 Redis、MySQL）存储会话，并设置过期机制。',
            ),
            const DividerLine(),

            // ===== 13. 错误处理 =====
            const SectionHeader('错误处理', icon: Icons.error_outline),
            const Paragraph(
              'CGI 程序出错时，服务器可能返回 HTTP 500（内部服务器错误）。'
              'Python 的 cgitb 模块可以捕获异常并生成详细的 HTML 错误报告，'
              '包含异常类型、发生位置、调用栈和各作用域的变量值。'
              '还可以通过 try/except 捕获特定异常并返回友好的错误页面。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
import traceback

# 开发环境：开启详细错误信息
cgitb.enable()

# 生产环境：自定义错误处理
def handle_error():
    """生成友好错误页面"""
    print("Content-Type: text/html")
    print("Status: 500 Internal Server Error\n")
    print("""
    <!DOCTYPE html>
    <html>
    <head><title>服务器错误</title></head>
    <body>
        <h1>500 - 服务器内部错误</h1>
        <p>抱歉，处理请求时出现错误。请稍后重试。</p>
    </body>
    </html>
    """)

try:
    # 故意制造错误（仅用于演示）
    form = cgi.FieldStorage()
    num = form.getvalue('num', '0')
    result = 100 / int(num)  # 如果 num=0 会触发 ZeroDivisionError

    print("Content-Type: text/html\n")
    print(f"<h2>计算结果: 100 / {num} = {result}</h2>")

except Exception as e:
    # 记录错误到日志文件
    with open('/tmp/cgi_error.log', 'a') as log:
        log.write(f"Error: {e}\n{traceback.format_exc()}\n")
    handle_error()
''',
              language: 'Python',
            ),
            const TipBox(
              '开发时使用 cgitb.enable() 方便调试，部署时务必注释掉。'
              '在生产环境中：1) 记录错误到日志文件而非显示给用户；'
              '2) 返回自定义的友好错误页面；3) 使用 try/except 处理可预见的异常。',
              type: TipType.caution,
            ),
            const DividerLine(),

            // ===== 14. 安全考虑 =====
            const SectionHeader('安全注意事项', icon: Icons.security),
            const Paragraph(
              'CGI 程序直接暴露在网络上，安全至关重要。常见的安全风险包括：'
              '命令注入（通过用户输入执行系统命令）、路径遍历（访问非授权文件）、'
              'XSS（跨站脚本攻击）和 SQL 注入。每条用户输入都可能是攻击向量。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
import cgi
import cgitb
import html
import subprocess  # 危险模块，使用需谨慎
cgitb.enable()

form = cgi.FieldStorage()
user_input = form.getvalue('input', '')

# 错误示例：直接拼接用户输入到系统命令
# 危险！用户输入 "; rm -rf /" 会执行删除命令
# result = os.popen(f"echo {user_input}").read()

# 正确做法：使用参数列表而非 shell=True
safe_cmd = ['echo', user_input]
result = subprocess.run(safe_cmd, capture_output=True, text=True)

# 输出到 HTML 时进行转义，防止 XSS
safe_output = html.escape(result.stdout)

# 同时验证输入内容
allowed_chars = set('abcdefghijklmnopqrstuvwxyz0123456789_-. ')
if not all(c in allowed_chars for c in user_input):
    safe_output = '输入包含非法字符，已拒绝'

print("Content-Type: text/html\n")
print(f"<h2>安全处理结果</h2>")
print(f"<p>原始输入: {html.escape(user_input)}</p>")
print(f"<p>安全输出: {safe_output}</p>")
''',
              language: 'Python',
            ),
            const Paragraph(
              '核心安全原则：永远不要信任用户输入。对所有输入进行验证和转义；'
              '使用参数化查询防止 SQL 注入；设置合适的文件权限；'
              '避免使用 shell=True 执行命令；对输出到 HTML 的内容使用 html.escape()；'
              '限制上传文件大小和类型；使用 HTTPS 加密传输。',
            ),
            CodeBlock(
              r'''# 输入验证辅助函数
import re

def validate_username(name):
    """只允许字母、数字和下划线，长度2-20"""
    return bool(re.match(r'^[a-zA-Z0-9_]{2,20}$', name))

def validate_email(email):
    """简单的邮箱格式验证"""
    return bool(re.match(r'^[^@]+@[^@]+\.[^@]+$', email))

def sanitize_filename(filename):
    """清理文件名，防止路径遍历"""
    # 移除路径分隔符
    clean = re.sub(r'[\\/]', '', filename)
    # 只保留安全的字符
    clean = re.sub(r'[^\w\.\-]', '_', clean)
    return clean
''',
              language: 'Python',
            ),
            const TipBox(
              '安全 Checklist：HTML 输出前做 html.escape()；执行命令用参数列表模式；'
              '验证所有输入的长度和格式；文件上传限制类型和大小；'
              '不在错误信息中泄露路径、SQL、堆栈等敏感信息。',
              type: TipType.warning,
            ),
            const DividerLine(),

            // ===== 15. 完整示例：简易留言板 =====
            const SectionHeader('完整示例：简易留言板', icon: Icons.forum),
            const Paragraph(
              '下面是一个完整的 CGI 留言板示例。它使用 JSON 文件存储留言数据，'
              '支持显示留言列表和提交新留言。展示了 CGI 程序的完整结构：'
              '请求处理、数据存储、HTML 生成和错误处理。',
            ),
            CodeBlock(
              r'''#!/usr/bin/env python3
"""guestbook.py —— 简易 CGI 留言板"""
import cgi
import cgitb
import json
import os
import html
from datetime import datetime

cgitb.enable()

# 数据文件
DATA_FILE = '/tmp/guestbook_data.json'
MAX_MESSAGES = 50

def load_messages():
    """加载留言数据"""
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def save_message(name, content):
    """保存新留言"""
    messages = load_messages()
    messages.insert(0, {
        'name': html.escape(name[:20]),
        'content': html.escape(content[:500]),
        'time': datetime.now().strftime('%Y-%m-%d %H:%M')
    })
    # 限制留言数量
    messages = messages[:MAX_MESSAGES]
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(messages, f, ensure_ascii=False, indent=2)

# ----- 主逻辑 -----
form = cgi.FieldStorage()

# 处理表单提交
if form.getvalue('action') == 'post':
    name = form.getvalue('name', '匿名')
    content = form.getvalue('content', '')
    if content.strip():
        save_message(name, content)

messages = load_messages()

# 输出页面
print("Content-Type: text/html; charset=utf-8\n")
print("""<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="utf-8"><title>简易留言板</title>
<style>
    body { font-family: Arial; max-width: 600px; margin: 20px auto; }
    .msg { border: 1px solid #ddd; padding: 10px; margin: 8px 0; }
    .msg .meta { color: #888; font-size: 12px; }
    textarea { width: 100%; }
</style>
</head><body>
    <h1>📋 留言板</h1>
    <form method="post">
        <input type="hidden" name="action" value="post">
        <p>昵称: <input type="text" name="name" maxlength="20"></p>
        <p><textarea name="content" rows="4" placeholder="说点什么..."></textarea></p>
        <p><input type="submit" value="发表留言"></p>
    </form>
    <hr>""")

if messages:
    for msg in messages:
        print(f"""
    <div class="msg">
        <strong>{msg['name']}</strong>
        <span class="meta">{msg['time']}</span>
        <p>{msg['content']}</p>
    </div>""")
else:
    print("<p>还没有留言，来发表第一条吧！</p>")

print("</body></html>")
''',
              language: 'Python',
            ),
            const OutputBox(
              '访问 http://localhost:8000/cgi-bin/guestbook.py\n'
              '显示留言板页面，可填写昵称和内容提交留言。\n'
              '留言以 JSON 格式持久化存储在 /tmp/guestbook_data.json 中。',
            ),
            const TipBox(
              '这个留言板示例展示了完整的 CGI 应用程序结构。实际部署时建议：'
              '1) 增加 CSRF 防护；2) 使用数据库替代 JSON 文件；'
              '3) 添加管理员删除功能；4) 对输入做更严格的验证和清洗。',
              type: TipType.tip,
            ),
            const DividerLine(),

            // ===== 16. 现代替代方案 =====
            const SectionHeader('现代替代方案：WSGI 与 ASGI', icon: Icons.update),
            const Paragraph(
              'CGI 的"每个请求创建新进程"模式性能较差。现代 Python Web 开发'
              '使用 WSGI（Web Server Gateway Interface）或 ASGI（异步版本）标准。'
              '它们定义了 Web 服务器与 Python 应用之间更高效的接口协议。',
            ),
            CodeBlock(
              r'''# WSGI 示例（使用 Flask 框架）
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def hello():
    name = request.args.get('name', 'World')
    return f'<h1>Hello, {name}!</h1>'

if __name__ == '__main__':
    app.run()

# ASGI 示例（使用 FastAPI 框架）
from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def hello(name: str = 'World'):
    return {'message': f'Hello, {name}!'}
''',
              language: 'Python',
            ),
            const Paragraph(
              'WSGI 与 CGI 的主要区别：WSGI 应用是长期运行的进程（而非每个请求新进程），'
              '通过函数调用传递请求/响应对象（而非环境变量+标准输入输出），'
              '性能大幅提升。WSGI 服务器有 Gunicorn、uWSGI、Waitress 等。',
            ),
            const Paragraph(
              'ASGI 是 WSGI 的异步演进，支持 WebSocket、SSE 等长连接协议。'
              '常见 ASGI 框架有 FastAPI、Starlette、Django Channels。'
              'Uvicorn 是最流行的 ASGI 服务器。',
            ),
            CodeBlock(
              r'''# 对比：CGI vs WSGI vs ASGI

# CGI —— 每个请求新进程
# 请求 → Apache 创建进程 → 脚本执行 → 返回 → 进程销毁

# WSGI —— 同步多请求复用进程
# 请求 → Gunicorn → Python 应用函数调用 → 返回

# ASGI —— 异步事件驱动
# 请求 → Uvicorn → 异步协程处理 → 返回（支持 WebSocket）

# 选择建议：
# ✅ 学习/小项目 → CGI（直接 Python 内置服务器）
# ✅ 标准 Web 应用 → WSGI（Flask/Django + Gunicorn）
# ✅ 高并发/实时 → ASGI（FastAPI + Uvicorn）
''',
              language: 'Python',
            ),
            const TipBox(
              '虽然 CGI 已经"过时"，但理解 CGI 是掌握 Web 编程基础的重要一步。'
              '它直观地展示了 HTTP 请求-响应模型的核心机制。'
              '建议学习路径：CGI 原理 → WSGI 框架（Flask）→ ASGI 框架（FastAPI）。',
              type: TipType.tip,
            ),
            const DividerLine(),

            // ===== 总结 =====
            const SectionHeader('本章总结', icon: Icons.summarize),
            const Paragraph(
              '本章学习了 CGI（通用网关接口）的核心概念和 Python 实现：'
              '从 CGI 的工作原理、环境搭建，到 GET/POST 请求处理、表单解析、'
              '文件上传、Cookie 和会话管理，再到安全注意事项和完整的留言板示例。'
              '虽然 CGI 已经逐步被 WSGI/ASGI 取代，但它所体现的 HTTP 编程思想'
              '——请求解析、响应构造、状态管理——是 Web 开发的基石。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
