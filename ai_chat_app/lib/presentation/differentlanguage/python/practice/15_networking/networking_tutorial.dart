import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 第15章：网络编程（Network Programming）
/// 涵盖：Socket 基础、TCP/UDP、HTTP 客户端、Web 服务器、SSL/TLS、多路复用等
class PythonNetworkingTutorial extends StatelessWidget {
  const PythonNetworkingTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第15章 网络编程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader('本章内容', icon: Icons.list),
          Paragraph(
            '① Socket 基础与 TCP/UDP  ② socket 模块详解  ③ TCP 服务器与客户端\n'
            '④ Echo 服务器实战  ⑤ UDP 通信  ⑥ 多连接处理（threading / selectors）\n'
            '⑦ HTTP 客户端（http.client / urllib / requests）  ⑧ 简易 Web 服务器\n'
            '⑨ URL 解析与 DNS 查询  ⑩ SSL/TLS 安全连接  ⑪ 非阻塞 Socket\n'
            '⑫ selectors 模块  ⑬ 聊天服务器实战  ⑭ IP 地址处理\n'
            '⑮ 最佳实践与安全注意事项',
          ),
          TipBox(
            '网络编程是 Python 最强大的能力之一。从简单的 HTTP 请求到复杂的并发服务器，'
            'Python 的标准库提供了丰富的工具。本章将带你系统掌握这些技能。',
            type: TipType.info,
          ),
          DividerLine(),

          // ===== 1. Socket 简介 =====
          SectionHeader('1. Socket 简介', icon: Icons.lan),
          Paragraph(
            'Socket（套接字）是网络通信的端点。它提供了一种进程间通信的机制，'
            '允许不同主机上的程序通过网络交换数据。Python 的 socket 模块封装了'
            '底层的 Berkeley Socket API，使用起来非常直观。',
          ),
          Paragraph(
            'TCP（Transmission Control Protocol）：面向连接、可靠、基于字节流的传输协议。\n'
            '  • 建立连接需要三次握手\n'
            '  • 保证数据按序到达，无丢失、无重复\n'
            '  • 适用于 HTTP、FTP、SMTP 等需要可靠传输的场景\n\n'
            'UDP（User Datagram Protocol）：无连接、不可靠、基于数据报的传输协议。\n'
            '  • 无需建立连接，直接发送数据\n'
            '  • 不保证到达顺序，可能丢包\n'
            '  • 适用于 DNS、VoIP、视频直播等实时性要求高的场景',
          ),
          TipBox(
            'TCP 虽然可靠，但存在"队头阻塞"问题——一个丢包会阻塞后续所有包的接收。'
            'UDP 虽然不可靠，但配合应用层的重传和纠错机制（如 QUIC），可以实现更高的效率。',
            type: TipType.tip,
          ),
          DividerLine(),

          // ===== 2. socket 模块基础 =====
          SectionHeader('2. socket 模块基础', icon: Icons.settings_ethernet),
          Paragraph(
            'Python 的 socket 模块提供了创建和操作套接字的接口。核心函数是 socket.socket()，'
            '它创建一个新的套接字对象。',
          ),
          CodeBlock(
            r'''import socket

# 创建一个 TCP 套接字
tcp_sock = socket.socket(
    socket.AF_INET,      # IPv4 地址族
    socket.SOCK_STREAM,  # TCP 流式套接字
)

# 创建一个 UDP 套接字
udp_sock = socket.socket(
    socket.AF_INET,
    socket.SOCK_DGRAM,   # UDP 数据报套接字
)

# 创建一个 IPv6 TCP 套接字
tcp6_sock = socket.socket(
    socket.AF_INET6,     # IPv6 地址族
    socket.SOCK_STREAM,
)''',
            language: 'Python',
          ),
          Paragraph(
            '地址族（Address Family）选项：\n'
            '  • AF_INET：IPv4（最常用）\n'
            '  • AF_INET6：IPv6\n'
            '  • AF_UNIX：Unix 域套接字（同一台机器的进程间通信）\n\n'
            '套接字类型（Socket Type）选项：\n'
            '  • SOCK_STREAM：TCP 可靠流式传输\n'
            '  • SOCK_DGRAM：UDP 不可靠数据报\n'
            '  • SOCK_RAW：原始套接字（需要管理员权限）',
          ),
          DividerLine(),

          // ===== 3. TCP 服务器 =====
          SectionHeader('3. TCP 服务器', icon: Icons.dns),
          Paragraph(
            'TCP 服务器的创建遵循固定的步骤模式：创建套接字 -> 绑定地址 -> '
            '开始监听 -> 接受连接 -> 处理数据 -> 关闭连接。',
          ),
          CodeBlock(
            r'''import socket

# 1. 创建 TCP 套接字
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 2. 允许地址重用（防止 "Address already in use" 错误）
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# 3. 绑定到主机和端口
host = '127.0.0.1'  # localhost
port = 12345
server.bind((host, port))

# 4. 开始监听，最大挂起连接数为 5
server.listen(5)
print(f'服务器正在监听 {host}:{port}...')

# 5. 接受客户端连接
client_sock, client_addr = server.accept()
print(f'收到来自 {client_addr} 的连接')

# 6. 接收数据（最大 1024 字节）
data = client_sock.recv(1024)
print(f'收到: {data.decode("utf-8")}')

# 7. 发送响应
client_sock.send(b'Hello from server!')

# 8. 清理
client_sock.close()
server.close()''',
            language: 'Python',
          ),
          Paragraph(
            '关键方法说明：\n'
            '  • bind((host, port))：绑定套接字到指定地址和端口\n'
            '  • listen(backlog)：开始监听，backlog 是最大挂起连接数\n'
            '  • accept()：阻塞等待客户端连接，返回 (socket, address) 元组\n'
            '  • recv(bufsize)：接收数据，最多 bufsize 字节\n'
            '  • send(bytes)：发送数据（不保证一次发完所有数据）',
          ),
          TipBox(
            'bind() 的地址参数是一个元组 (host, port)。host 可以是空字符串 \'\'，'
            '表示绑定到所有可用的网络接口。port 建议使用 1024 以上的端口号（1024 以下需要管理员权限）。',
            type: TipType.warning,
          ),
          DividerLine(),

          // ===== 4. TCP 客户端 =====
          SectionHeader('4. TCP 客户端', icon: Icons.router),
          Paragraph(
            'TCP 客户端的步骤更加简单：创建套接字 -> 连接服务器 -> 收发数据 -> 关闭连接。',
          ),
          CodeBlock(
            r'''import socket

# 1. 创建 TCP 套接字
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 2. 连接到服务器
host = '127.0.0.1'
port = 12345
client.connect((host, port))

# 3. 发送数据
client.send(b'Hello from client!')

# 4. 接收响应
response = client.recv(1024)
print(f'服务器响应: {response.decode("utf-8")}')

# 5. 关闭连接
client.close()''',
            language: 'Python',
          ),
          Paragraph(
            '客户端方法说明：\n'
            '  • connect(address)：连接到远程服务器\n'
            '  • connect_ex(address)：带错误码的 connect（成功返回 0，失败返回 errno）\n'
            '  • sendall(bytes)：完整发送所有数据（自动重试直到全部发完）\n'
            '  • shutdown(how)：关闭读/写通道（SHUT_RD、SHUT_WR、SHUT_RDWR）',
          ),
          DividerLine(),

          // ===== 5. Echo 服务器完整示例 =====
          SectionHeader('5. Echo 服务器完整示例', icon: Icons.repeat),
          Paragraph(
            '下面是一个完整的 TCP Echo 服务器和客户端示例。服务器将客户端发送的数据原样返回。'
            '这是一个理解 Socket 编程基本流程的经典入门例子。',
          ),
          Paragraph('Echo 服务器端代码：',),
          CodeBlock(
            r'''# echo_server.py
import socket

def run_echo_server(host='127.0.0.1', port=8888):
    """运行一个简单的 Echo 服务器"""
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen(5)
    print(f'Echo 服务器已启动: {host}:{port}')

    try:
        while True:
            client, addr = server.accept()
            print(f'客户端连接: {addr}')
            try:
                while True:
                    data = client.recv(1024)
                    if not data:
                        # 空数据表示客户端已关闭连接
                        break
                    print(f'收到: {data.decode("utf-8")}')
                    # 原样返回
                    client.sendall(data)
            except ConnectionResetError:
                print(f'客户端 {addr} 连接重置')
            finally:
                client.close()
                print(f'客户端 {addr} 已断开')
    except KeyboardInterrupt:
        print('\n服务器关闭')
    finally:
        server.close()

if __name__ == '__main__':
    run_echo_server()''',
            language: 'Python',
          ),
          Paragraph('Echo 客户端代码：',),
          CodeBlock(
            r'''# echo_client.py
import socket

def run_echo_client(host='127.0.0.1', port=8888):
    """连接到 Echo 服务器并发送消息"""
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((host, port))

    messages = ['Hello!', 'How are you?', 'Echo test!', 'exit']
    for msg in messages:
        client.sendall(msg.encode('utf-8'))
        response = client.recv(1024)
        print(f'发送: {msg}')
        print(f'收到: {response.decode("utf-8")}')
        print('---')

    client.close()

if __name__ == '__main__':
    run_echo_client()''',
            language: 'Python',
          ),
          OutputBox(
            r'''Echo 服务器已启动: 127.0.0.1:8888
客户端连接: ('127.0.0.1', 54321)
收到: Hello!
收到: How are you?
收到: Echo test!
收到: exit
客户端 ('127.0.0.1', 54321) 已断开''',
          ),
          TipBox(
            'recv() 返回空字节串 b\'\' 表示对方已经关闭了连接。这是一个重要的信号，'
            '一定要检查并处理这个条件，否则会陷入无限循环。',
            type: TipType.caution,
          ),
          DividerLine(),

          // ===== 6. UDP 服务器与客户端 =====
          SectionHeader('6. UDP 服务器与客户端', icon: Icons.wifi),
          Paragraph(
            'UDP 是无连接的协议，服务器不需要 accept()，客户端不需要 connect()。'
            '使用 recvfrom() 和 sendto() 方法来收发数据，同时获取对方的地址信息。',
          ),
          Paragraph('UDP 服务器端：',),
          CodeBlock(
            r'''import socket

# UDP 服务器
server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind(('127.0.0.1', 9999))
print('UDP 服务器正在监听 9999 端口...')

while True:
    # recvfrom 返回 (data, address)
    data, addr = server.recvfrom(1024)
    print(f'收到来自 {addr} 的消息: {data.decode("utf-8")}')
    # 回复客户端
    server.sendto(b'Message received!', addr)''',
            language: 'Python',
          ),
          Paragraph('UDP 客户端：',),
          CodeBlock(
            r'''import socket

# UDP 客户端
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# 直接发送，不需要 connect
message = b'Hello UDP server!'
client.sendto(message, ('127.0.0.1', 9999))

# 接收回复
data, server_addr = client.recvfrom(1024)
print(f'来自 {server_addr}: {data.decode("utf-8")}')
client.close()''',
            language: 'Python',
          ),
          TipBox(
            'UDP 发送的数据报有大小限制。IPv4 下最大为 65507 字节（65535 - 20(IP头) - 8(UDP头)）。'
            '超过此限制的数据会被静默丢弃或导致 EMSGSIZE 错误。',
            type: TipType.warning,
          ),
          DividerLine(),

          // ===== 7. 处理多连接 =====
          SectionHeader('7. 处理多连接', icon: Icons.multiple_stop),
          Paragraph(
            '基础的 TCP 服务器一次只能处理一个客户端连接。要支持多个客户端并发，'
            '常用的方法有两种：多线程（threading）和 I/O 多路复用（selectors）。',
          ),
          Paragraph('使用 threading 处理多连接：',),
          CodeBlock(
            r'''import socket
import threading

def handle_client(client_sock, addr):
    """处理单个客户端的通信"""
    print(f'新线程处理客户端: {addr}')
    try:
        while True:
            data = client_sock.recv(1024)
            if not data:
                break
            client_sock.sendall(data)
    except ConnectionResetError:
        pass
    finally:
        client_sock.close()
        print(f'客户端 {addr} 断开')

def start_threaded_server(host='127.0.0.1', port=8888):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen(10)
    print(f'多线程服务器启动: {host}:{port}')

    try:
        while True:
            client, addr = server.accept()
            # 为每个客户端创建一个新线程
            thread = threading.Thread(
                target=handle_client,
                args=(client, addr),
                daemon=True  # 主线程退出时自动结束
            )
            thread.start()
    except KeyboardInterrupt:
        print('服务器关闭')
    finally:
        server.close()

if __name__ == '__main__':
    start_threaded_server()''',
            language: 'Python',
          ),
          Paragraph(
            '使用 daemon=True 可以让守护线程随着主线程退出而自动结束。'
            '但是当客户端数量非常多时（数千个），为每个连接创建线程会消耗大量资源。'
            '此时应当考虑使用线程池（ThreadPoolExecutor）或 I/O 多路复用。',
          ),
          DividerLine(),

          // ===== 8. HTTP 客户端 =====
          SectionHeader('8. HTTP 客户端', icon: Icons.http),
          Paragraph(
            'Python 提供了多种方式进行 HTTP 请求：内置的 http.client 和 urllib 模块，'
            '以及第三方库 requests（业界标准）。',
          ),
          Paragraph('使用 http.client：',),
          CodeBlock(
            r'''from http.client import HTTPConnection

conn = HTTPConnection('httpbin.org')

# 发送 GET 请求
conn.request('GET', '/get')
response = conn.getresponse()
print(f'状态码: {response.status}')
print(f'原因: {response.reason}')
data = response.read().decode('utf-8')
print(f'响应体: {data[:200]}...')
conn.close()

# 发送 POST 请求
conn = HTTPConnection('httpbin.org')
import json
payload = json.dumps({'name': 'Alice', 'age': 30})
conn.request('POST', '/post', body=payload,
             headers={'Content-Type': 'application/json'})
response = conn.getresponse()
print(f'POST 状态: {response.status}')
conn.close()''',
            language: 'Python',
          ),
          Paragraph('使用 urllib.request：',),
          CodeBlock(
            r'''from urllib import request, parse

# GET 请求
resp = request.urlopen('https://httpbin.org/get')
print(f'状态码: {resp.status}')
print(f'响应: {resp.read().decode("utf-8")[:200]}')

# POST 请求——带参数
data = parse.urlencode({'key1': 'value1', 'key2': 'value2'}).encode()
req = request.Request(
    'https://httpbin.org/post',
    data=data,
    headers={'User-Agent': 'Python urllib'},
)
resp = request.urlopen(req)
print(f'POST 响应: {resp.read().decode("utf-8")[:200]}')''',
            language: 'Python',
          ),
          Paragraph('使用 requests 库（第三方，需要安装）：',),
          CodeBlock(
            r'''import requests

# GET 请求
resp = requests.get('https://httpbin.org/get')
print(f'状态码: {resp.status_code}')
print(f'JSON: {resp.json()}')

# POST 请求
resp = requests.post(
    'https://httpbin.org/post',
    json={'name': 'Bob', 'score': 95},
    headers={'Authorization': 'Bearer mytoken'},
)
print(f'POST JSON: {resp.json()}')

# 其他便捷功能
params = {'key1': 'value1', 'key2': 'value2'}
resp = requests.get('https://httpbin.org/get', params=params)
print(f'带参数的 URL: {resp.url}')

# 超时设置（必须设置！）
try:
    resp = requests.get('https://httpbin.org/delay/5', timeout=3)
except requests.Timeout:
    print('请求超时！')''',
            language: 'Python',
          ),
          TipBox(
            '在生产环境中，始终为 HTTP 请求设置超时。如果不设置超时，网络故障可能导致'
            '程序永远挂起。requests 库的默认行为是不设置超时，这是一个常见陷阱！',
            type: TipType.caution,
          ),
          DividerLine(),

          // ===== 9. 简易 Web 服务器 =====
          SectionHeader('9. 简易 Web 服务器', icon: Icons.web),
          Paragraph(
            'Python 内置的 http.server 模块可以快速创建一个简易的 Web 服务器。'
            '它非常适合开发和测试环境。',
          ),
          Paragraph('一行命令启动静态文件服务器：',),
          CodeBlock(
            r'''# 在终端中运行，将在当前目录启动一个 HTTP 文件服务器
python -m http.server 8000
# 访问 http://localhost:8000 即可浏览文件''',
            language: 'Python',
          ),
          Paragraph('自定义请求处理器：',),
          CodeBlock(
            r'''from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class SimpleHandler(BaseHTTPRequestHandler):
    """自定义 HTTP 请求处理器"""

    def do_GET(self):
        """处理 GET 请求"""
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'<h1>Hello, Python Web!</h1>')
        elif self.path == '/api/status':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            status = {'status': 'ok', 'version': '1.0'}
            self.wfile.write(json.dumps(status).encode('utf-8'))
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'404 Not Found')

    def do_POST(self):
        """处理 POST 请求"""
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        data = json.loads(body.decode('utf-8'))
        print(f'收到 POST 数据: {data}')

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        response = {'received': data, 'message': 'Thank you!'}
        self.wfile.write(json.dumps(response).encode('utf-8'))

    def log_message(self, format, *args):
        """自定义日志格式"""
        print(f'[{self.address_string()}] {args[0]} {args[1]} {args[2]}')

# 启动服务器
server = HTTPServer(('127.0.0.1', 8080), SimpleHandler)
print('服务器已启动: http://127.0.0.1:8080')
print('按 Ctrl+C 停止服务器')

try:
    server.serve_forever()
except KeyboardInterrupt:
    print('服务器已停止')
    server.server_close()''',
            language: 'Python',
          ),
          OutputBox(
            r'''服务器已启动: http://127.0.0.1:8080
[127.0.0.1] GET / HTTP/1.1
[127.0.0.1] GET /api/status HTTP/1.1
[127.0.0.1] POST / HTTP/1.1
服务器已停止''',
          ),
          DividerLine(),

          // ===== 10. URL 解析 =====
          SectionHeader('10. URL 解析', icon: Icons.link),
          Paragraph(
            'urllib.parse 模块提供了丰富的 URL 解析和构建功能，'
            '包括 URL 分解、参数编码、相对 URL 拼接等。',
          ),
          CodeBlock(
            r'''from urllib.parse import (
    urlparse, urlencode, quote, unquote,
    urljoin, parse_qs, parse_qsl
)

# 1. URL 解析
url = 'https://user:pass@example.com:8080/path/to/page?key1=a&key2=b#section'
parsed = urlparse(url)
print(f'协议: {parsed.scheme}')       # https
print(f'主机: {parsed.hostname}')     # example.com
print(f'端口: {parsed.port}')         # 8080
print(f'路径: {parsed.path}')         # /path/to/page
print(f'查询: {parsed.query}')        # key1=a&key2=b
print(f'片段: {parsed.fragment}')     # section
print(f'用户名: {parsed.username}')   # user
print(f'密码: {parsed.password}')     # pass

# 2. 参数编码
params = {
    'name': '张三',
    'city': '北京',
    'tags': ['python', 'network'],
}
encoded = urlencode(params, doseq=True)
print(f'编码后的查询字符串: {encoded}')
# name=%E5%BC%A0%E4%B8%89&city=%E5%8C%97%E4%BA%AC&tags=python&tags=network

# 3. URL 编码 / 解码
chinese_text = '你好世界'
encoded_text = quote(chinese_text)
print(f'编码: {encoded_text}')
print(f'解码: {unquote(encoded_text)}')

# 4. 拼接 URL
base = 'https://example.com/api/'
relative = 'v1/users'
full_url = urljoin(base, relative)
print(f'完整 URL: {full_url}')
# https://example.com/api/v1/users

# 5. 解析查询字符串
query = 'name=alice&age=25&city=beijing'
parsed_qs = parse_qs(query)
print(f'解析结果 (值作为列表): {parsed_qs}')
# {'name': ['alice'], 'age': ['25'], 'city': ['beijing']}

parsed_qsl = parse_qsl(query)
print(f'解析结果 (键值对列表): {parsed_qsl}')
# [('name', 'alice'), ('age', '25'), ('city', 'beijing')]''',
            language: 'Python',
          ),
          TipBox(
            "quote() 默认不会编码 '/' 字符，适合编码 URL 路径中的片段。"
            "如果需要严格编码所有特殊字符，使用 quote(text, safe='')。"
            "使用 urlencode 的 doseq=True 参数可以正确处理列表类型的参数值。",
            type: TipType.tip,
          ),
          DividerLine(),

          // ===== 11. DNS 查询 =====
          SectionHeader('11. DNS 查询', icon: Icons.dns_outlined),
          Paragraph(
            'Python 的 socket 模块提供了基本的 DNS 查询功能，'
            '可以将域名解析为 IP 地址，也可以反向查找域名。',
          ),
          CodeBlock(
            r'''import socket

# 1. 域名 -> IP 地址（正向解析）
domain = 'www.python.org'
ip = socket.gethostbyname(domain)
print(f'{domain} 的 IP 地址: {ip}')

# 获取所有 IP 地址（一个域名可能对应多个 IP）
ips = socket.gethostbyname_ex(domain)
print(f'完整信息: {ips}')
# ('python.org', [], ['199.232.68.223', '2a04:4e42:36::223'])

# 2. IP 地址 -> 域名（反向解析）
try:
    hostname, aliases, addresses = socket.gethostbyaddr('199.232.68.223')
    print(f'IP 199.232.68.223 对应的域名: {hostname}')
except socket.herror:
    print('反向解析失败（PTR 记录不存在）')

# 3. 获取本机主机名
hostname = socket.gethostname()
print(f'本机主机名: {hostname}')

# 4. 获取本机 IP 地址
local_ip = socket.gethostbyname(hostname)
print(f'本机 IP: {local_ip}')

# 5. 获取服务端口号
print(f'HTTP 端口: {socket.getservbyname("http")}')    # 80
print(f'HTTPS 端口: {socket.getservbyname("https")}')  # 443
print(f'SSH 端口: {socket.getservbyname("ssh")}')      # 22
print(f'服务 80 的名称: {socket.getservbyport(80)}')    # http''',
            language: 'Python',
          ),
          TipBox(
            'gethostbyaddr() 反向查询可能失败，因为不是所有 IP 地址都有 PTR 记录。'
            '务必捕获 socket.herror 异常。另外，DNS 查询是阻塞的，如果在 UI 线程中调用，'
            '可能会卡住程序，建议放在线程池中执行。',
            type: TipType.warning,
          ),
          DividerLine(),

          // ===== 12. SSL/TLS =====
          SectionHeader('12. SSL/TLS 安全连接', icon: Icons.lock),
          Paragraph(
            'SSL（Secure Sockets Layer）和 TLS（Transport Layer Security）是网络安全协议，'
            '为 TCP 连接提供加密、身份验证和数据完整性保护。Python 的 ssl 模块可以轻松地为 '
            'Socket 添加 SSL/TLS 支持。',
          ),
          CodeBlock(
            r'''import socket
import ssl

# 方法一：包装现有 Socket（客户端）
def create_secure_client(host, port):
    """创建 SSL 加密的客户端连接"""
    context = ssl.create_default_context()
    # 标准库提供的 HTTPS 连接示例
    raw_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    secure_sock = context.wrap_socket(raw_sock, server_hostname=host)
    secure_sock.connect((host, port))
    return secure_sock

# 使用示例：连接 HTTPS 服务器
secure_sock = create_secure_client('httpbin.org', 443)
secure_sock.sendall(b'GET /get HTTP/1.1\r\nHost: httpbin.org\r\n\r\n')
response = secure_sock.recv(4096)
print(response.decode('utf-8'))
secure_sock.close()

# 方法二：简易 SSL 服务器
def create_secure_server(certfile, keyfile, host='127.0.0.1', port=8443):
    """创建 SSL 加密的服务器"""
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile, keyfile)

    raw_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    raw_server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    raw_server.bind((host, port))
    raw_server.listen(5)

    secure_server = context.wrap_socket(raw_server, server_side=True)
    print(f'SSL 服务器已启动: {host}:{port}')
    return secure_server

# 生成自签名证书的命令行方法（供参考）：
# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes''',
            language: 'Python',
          ),
          Paragraph(
            'SSL/TLS 最佳实践：\n'
            '  • 使用 create_default_context() 而不是手动创建 SSLContext（自动应用安全默认值）\n'
            '  • 始终设置 server_hostname 参数以启用主机名验证\n'
            '  • 在服务器端加载证书链（certfile + keyfile）\n'
            '  • 使用 PROTOCOL_TLS_SERVER / PROTOCOL_TLS_CLIENT 而不是过时的版本\n'
            '  • 定期更新证书，使用 Let\'s Encrypt 等免费 CA 服务',
          ),
          TipBox(
            'ssl.wrap_socket() 在 Python 3.12 中已被弃用，请使用 SSLContext.wrap_socket() 替代。'
            'create_default_context() 会自动配置安全的密码套件和协议版本。',
            type: TipType.caution,
          ),
          DividerLine(),

          // ===== 13. 非阻塞 Socket =====
          SectionHeader('13. 非阻塞 Socket', icon: Icons.timer),
          Paragraph(
            '默认情况下，Socket 操作是阻塞的：recv() 会一直等待数据到达，'
            'accept() 会一直等待新连接。通过设置非阻塞模式或超时，'
            '可以让这些操作立即返回，避免线程被长时间挂起。',
          ),
          CodeBlock(
            r'''import socket
import time

# 方法一：设置超时
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(5.0)  # 5 秒超时

try:
    sock.connect(('example.com', 80))
    sock.sendall(b'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n')
    data = sock.recv(4096)
    print(f'收到 {len(data)} 字节')
except socket.timeout:
    print('操作超时！')
except socket.error as e:
    print(f'Socket 错误: {e}')
finally:
    sock.close()

# 方法二：完全非阻塞模式
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setblocking(False)  # 设置为非阻塞

try:
    sock.connect(('example.com', 80))
except BlockingIOError:
    # 非阻塞模式下 connect 立即返回这个异常
    # 但实际上连接正在后台建立
    print('连接正在后台建立...')

# 在非阻塞模式下，需要轮询检查连接状态
# 或者使用 select/poll/epoll 等待可写事件
import select

# 等待套接字变为可写（表示连接完成）
_, ready_to_write, _ = select.select([], [sock], [], 5.0)

if ready_to_write:
    print('连接已建立！')
    sock.sendall(b'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n')
    sock.setblocking(True)  # 切换回阻塞模式以便 recv
    data = sock.recv(4096)
    print(f'收到 {len(data)} 字节')
else:
    print('连接超时')

sock.close()

# 方法三：使用默认超时
print(f'默认超时: {socket.getdefaulttimeout()}')  # None 表示阻塞模式
socket.setdefaulttimeout(10)  # 设置全局默认超时（10 秒）''',
            language: 'Python',
          ),
          TipBox(
            '非阻塞 Socket 编程比阻塞模式复杂得多。除非你需要极高性能，否则建议优先使用'
            '线程 + 阻塞 Socket 的模式。对于需要处理大量并发连接的场景，'
            '推荐使用 asyncio 库，它提供了更优雅的异步 I/O 方案。',
            type: TipType.tip,
          ),
          DividerLine(),

          // ===== 14. selectors 模块 =====
          SectionHeader('14. selectors 模块', icon: Icons.swap_horiz),
          Paragraph(
            'selectors 模块是 Python 3.4 引入的高层 I/O 多路复用接口。'
            '它在不同的平台上自动选择最高效的实现（select/poll/epoll/kqueue），'
            '使得编写跨平台的并发网络程序更加简便。',
          ),
          CodeBlock(
            r'''import socket
import selectors

# 创建默认的 Selector（自动选择最佳实现）
sel = selectors.DefaultSelector()

def setup_server(host='127.0.0.1', port=8888):
    """设置服务器并注册到 selector"""
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.setblocking(False)  # 非阻塞
    server.bind((host, port))
    server.listen(10)
    print(f'Selector 服务器启动: {host}:{port}')

    # 注册读事件（有新连接时触发）
    sel.register(server, selectors.EVENT_READ, data=None)
    return server

def accept_connection(server):
    """接受新连接"""
    client, addr = server.accept()
    print(f'接受新连接: {addr}')
    client.setblocking(False)

    # 为客户端注册读事件
    sel.register(client, selectors.EVENT_READ, data=addr)

def handle_client(client, addr):
    """处理客户端数据"""
    try:
        data = client.recv(1024)
        if data:
            print(f'[{addr}] 收到: {data.decode("utf-8")}')
            client.sendall(data)  # Echo
        else:
            print(f'[{addr}] 断开连接')
            sel.unregister(client)
            client.close()
    except ConnectionResetError:
        print(f'[{addr}] 连接重置')
        sel.unregister(client)
        client.close()

def event_loop(server):
    """事件循环"""
    while True:
        # 阻塞等待事件，超时设为 None（无限等待）
        events = sel.select(timeout=None)

        for key, mask in events:
            if key.data is None:
                # 服务器套接字有事件 -> 新连接
                accept_connection(key.fileobj)
            else:
                # 客户端套接字有事件 -> 可读
                handle_client(key.fileobj, key.data)

if __name__ == '__main__':
    server = setup_server()
    try:
        event_loop(server)
    except KeyboardInterrupt:
        print('服务器关闭')
    finally:
        sel.close()
        server.close()''',
            language: 'Python',
          ),
          Paragraph(
            'selectors 模块的核心概念：\n'
            '  • DefaultSelector：自动选择当前平台最高效的实现\n'
            '  • register(fileobj, events, data)：注册要监视的文件对象和事件\n'
            '  • unregister(fileobj)：取消注册\n'
            '  • select(timeout)：阻塞直到有事件发生，返回 (key, mask) 列表\n'
            '  • EVENT_READ / EVENT_WRITE：可读和可写事件掩码',
          ),
          TipBox(
            'selectors 模块是构建高性能网络应用的良好起点。但对于更复杂的场景，'
            '建议直接使用 asyncio（内置的异步 I/O 框架），它在 selectors 之上提供了更高级的抽象，'
            '包括协程、任务、传输和协议等。',
            type: TipType.tip,
          ),
          DividerLine(),

          // ===== 15. 聊天服务器 =====
          SectionHeader('15. 聊天服务器实战', icon: Icons.chat),
          Paragraph(
            '下面是一个使用 threading 实现的多客户端聊天服务器。'
            '服务器负责转发消息：当一个客户端发送消息时，服务器将其广播给所有其他客户端。',
          ),
          CodeBlock(
            r'''# chat_server.py
import socket
import threading

class ChatServer:
    """多客户端聊天服务器"""

    def __init__(self, host='127.0.0.1', port=9999):
        self.host = host
        self.port = port
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((host, port))
        self.server.listen(10)

        # 存储所有已连接的客户端
        self.clients = {}  # {socket: nickname}
        self.lock = threading.Lock()

    def broadcast(self, message, sender_sock=None):
        """向所有客户端广播消息（可选排除发送者）"""
        with self.lock:
            for sock in self.clients:
                if sock != sender_sock:
                    try:
                        sock.sendall(message.encode('utf-8'))
                    except:
                        pass

    def handle_client(self, sock, addr):
        """处理单个客户端的消息"""
        nickname = self.clients.get(sock, 'Unknown')
        try:
            while True:
                data = sock.recv(1024)
                if not data:
                    break
                message = data.decode('utf-8')
                print(f'[{nickname}]: {message}')

                # 广播消息（带上发送者昵称）
                formatted = f'[{nickname}]: {message}'
                self.broadcast(formatted, sender_sock=sock)
        except (ConnectionResetError, ConnectionAbortedError):
            pass
        finally:
            with self.lock:
                if sock in self.clients:
                    del self.clients[sock]
                sock.close()
            self.broadcast(f'[系统] {nickname} 离开了聊天室')
            print(f'客户端 {addr} ({nickname}) 断开')

    def start(self):
        """启动聊天服务器"""
        print(f'聊天服务器启动: {self.host}:{self.port}')
        print('等待客户端连接...')

        try:
            while True:
                client, addr = self.server.accept()

                # 首先接收昵称
                nickname = client.recv(1024).decode('utf-8')
                with self.lock:
                    self.clients[client] = nickname

                print(f'新用户加入: {nickname} ({addr})')
                self.broadcast(f'[系统] {nickname} 加入了聊天室')

                # 启动处理线程
                thread = threading.Thread(
                    target=self.handle_client,
                    args=(client, addr),
                    daemon=True,
                )
                thread.start()
        except KeyboardInterrupt:
            print('聊天服务器关闭')
        finally:
            self.server.close()

if __name__ == '__main__':
    server = ChatServer()
    server.start()''',
            language: 'Python',
          ),
          Paragraph('聊天客户端代码：',),
          CodeBlock(
            r'''# chat_client.py
import socket
import threading

class ChatClient:
    """聊天客户端"""

    def __init__(self, host='127.0.0.1', port=9999):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((host, port))
        self.running = True

    def receive_messages(self):
        """在后台线程中接收消息"""
        while self.running:
            try:
                data = self.sock.recv(1024)
                if not data:
                    break
                print(data.decode('utf-8'))
            except:
                break

    def start(self, nickname):
        """启动客户端"""
        # 发送昵称
        self.sock.sendall(nickname.encode('utf-8'))

        # 启动接收线程
        recv_thread = threading.Thread(
            target=self.receive_messages,
            daemon=True,
        )
        recv_thread.start()

        print('输入消息（输入 /quit 退出）:')
        try:
            while True:
                message = input()
                if message.strip() == '/quit':
                    break
                self.sock.sendall(message.encode('utf-8'))
        except (KeyboardInterrupt, EOFError):
            pass
        finally:
            self.running = False
            self.sock.close()

if __name__ == '__main__':
    client = ChatClient()
    nickname = input('请输入你的昵称: ')
    client.start(nickname)''',
            language: 'Python',
          ),
          OutputBox(
            r'''聊天服务器启动: 127.0.0.1:9999
等待客户端连接...
新用户加入: Alice (('127.0.0.1', 54321))
新用户加入: Bob (('127.0.0.1', 54322))
[系统] Alice 加入了聊天室
[系统] Bob 加入了聊天室
[Alice]: 大家好！
[Bob]: 你好 Alice！
[系统] Bob 离开了聊天室''',
          ),
          TipBox(
            '此聊天服务器使用了线程锁来保护共享的 clients 字典，避免并发修改问题。'
            '广播时必须先获取锁，以防止在遍历字典时其他线程修改它（导致 RuntimeError）。'
            '这是多线程编程中常见的竞态条件问题。',
            type: TipType.caution,
          ),
          DividerLine(),

          // ===== 16. IP 地址处理 =====
          SectionHeader('16. IP 地址处理', icon: Icons.network_check),
          Paragraph(
            'Python 3.3 引入的 ipaddress 模块提供了创建、操作和验证 IP 地址和网络的工具。'
            '它同时支持 IPv4 和 IPv6，是处理网络地址的首选方式。',
          ),
          CodeBlock(
            r'''import ipaddress

# 1. 创建 IP 地址
ipv4 = ipaddress.IPv4Address('192.168.1.1')
ipv6 = ipaddress.IPv6Address('::1')
print(f'IPv4: {ipv4}')
print(f'IPv6: {ipv6}')

# 自动选择版本
ip1 = ipaddress.ip_address('10.0.0.1')
ip2 = ipaddress.ip_address('2001:db8::1')
print(f'{ip1} 版本: {ip1.version}')  # 4
print(f'{ip2} 版本: {ip2.version}')  # 6

# 2. 地址验证
def is_valid_ip(address):
    try:
        ipaddress.ip_address(address)
        return True
    except ValueError:
        return False

print(is_valid_ip('192.168.1.1'))     # True
print(is_valid_ip('256.1.1.1'))       # False
print(is_valid_ip('not-an-ip'))       # False

# 3. IP 运算
ip = ipaddress.IPv4Address('192.168.1.10')
print(f'反向指针: {ip.reverse_pointer}')     # 10.1.168.192.in-addr.arpa
print(f'是否为私有: {ip.is_private}')         # True
print(f'是否为全局: {ip.is_global}')          # False
print(f'是否为多播: {ip.is_multicast}')       # False
print(f'是否为环回: {ip.is_loopback}')        # False

# 4. 网络 / 子网
network = ipaddress.IPv4Network('192.168.1.0/24', strict=False)
print(f'网络地址: {network.network_address}')
print(f'广播地址: {network.broadcast_address}')
print(f'网络掩码: {network.netmask}')
print(f'前缀长度: {network.prefixlen}')
print(f'主机数量: {network.num_addresses}')  # 256

# 5. 遍历子网中的主机
print('前 5 个可用主机:')
for host in list(network.hosts())[:5]:
    print(f'  {host}')

# 6. 子网划分
subnets = list(network.subnets(prefixlen_diff=2))
print(f'子网数量: {len(subnets)}')  # 4
for subnet in subnets:
    print(f'  子网: {subnet}')

# 7. 判断 IP 是否在网络中
print(ipaddress.IPv4Address('192.168.1.5') in network)   # True
print(ipaddress.IPv4Address('10.0.0.1') in network)      # False''',
            language: 'Python',
          ),
          TipBox(
            'ipaddress 模块在 strict=False 时可以接受非严格格式（如 192.168.1.0/24 传入 192.168.1.1/24）。'
            '使用 strict=True（默认值）时，网络地址必须是子网的起始地址，否则会抛出 ValueError。',
            type: TipType.info,
          ),
          DividerLine(),

          // ===== 17. 最佳实践 =====
          SectionHeader('17. 最佳实践', icon: Icons.checklist),
          Paragraph(
            '网络编程中有许多容易忽视的细节。遵循以下最佳实践可以避免常见的陷阱，'
            '编写出更加健壮和安全的网络应用。',
          ),
          StepItem(
            step: 1,
            title: '处理部分数据',
            description:
                'send() 不保证一次发送所有数据：即使数据很短，也可能只发送了一部分。'
                '始终使用 sendall() 或在循环中调用 send() 直到所有数据发送完毕。'
                'recv() 也不保证返回请求的全部字节：TCP 是流协议，可能需要多次 recv() '
                '才能接收完整消息。建议使用固定长度的消息头或特殊分隔符来标记消息边界。',
          ),
          StepItem(
            step: 2,
            title: '正确处理关闭',
            description:
                '使用 shutdown() 优雅关闭：先调用 shutdown(socket.SHUT_WR) 表示停止发送，'
                '然后继续 recv() 直到收到空数据表示对方也关闭了。最后再 close()。'
                '这样可以确保所有未读取的数据都被处理完毕。',
          ),
          StepItem(
            step: 3,
            title: '设置合理的超时',
            description:
                '始终为网络操作设置超时，避免程序永久挂起。超时值应根据应用场景调整：'
                '局域网内可设为 2-5 秒，互联网请求可设为 10-30 秒。'
                '使用 setdefaulttimeout() 可以统一设置所有新创建的 Socket 的超时。',
          ),
          StepItem(
            step: 4,
            title: '资源清理',
            description:
                '使用 try/finally 或 with 语句确保 Socket 总是被正确关闭。'
                'Python 的 socket 对象支持 with 语句（上下文管理器），'
                '可以在退出 with 块时自动关闭。未及时关闭的 Socket 会导致端口泄漏。',
          ),
          StepItem(
            step: 5,
            title: '编码与数据格式',
            description:
                '网络传输的是字节，不是字符串。发送时使用 encode() 将字符串转为字节，'
                '接收后使用 decode() 转回字符串。明确指定编码（推荐 UTF-8）。'
                '对于结构化数据，考虑使用 JSON、Protocol Buffers 或 MessagePack 来序列化。',
          ),
          CodeBlock(
            r'''import socket

# 使用 with 语句自动管理资源
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.settimeout(5)
    sock.connect(('example.com', 80))
    sock.sendall(b'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n')

    # 循环接收直到超时或连接关闭
    data = b''
    try:
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            data += chunk
    except socket.timeout:
        # 超时是正常的——我们假设数据已经接收完毕
        pass

print(f'共接收 {len(data)} 字节')

# 消息分帧示例：4 字节长度前缀 + 消息体
import struct

def send_frame(sock, message):
    """发送带长度前缀的消息帧"""
    data = message.encode('utf-8')
    length = struct.pack('!I', len(data))  # 4 字节大端无符号整数
    sock.sendall(length + data)

def recv_frame(sock):
    """接收一个完整的消息帧"""
    # 先接收 4 字节长度
    raw_length = b''
    while len(raw_length) < 4:
        chunk = sock.recv(4 - len(raw_length))
        if not chunk:
            return None
        raw_length += chunk

    length = struct.unpack('!I', raw_length)[0]

    # 再接收消息体
    data = b''
    while len(data) < length:
        chunk = sock.recv(length - len(data))
        if not chunk:
            return None
        data += chunk

    return data.decode('utf-8')''',
            language: 'Python',
          ),
          DividerLine(),

          // ===== 18. 安全注意事项 =====
          SectionHeader('18. 安全注意事项', icon: Icons.security),
          Paragraph(
            '网络编程中安全性是重中之重。不安全的 Socket 代码可能导致信息泄露、'
            '拒绝服务攻击甚至远程代码执行。以下是需要特别注意的安全问题。',
          ),
          TipBox(
            '安全风险 1 - 拒绝服务（DoS）：\n'
            '不要在没有超时的情况下 accept() 或 recv()。攻击者可以创建大量连接但不发送数据，'
            '耗尽服务器的线程池和内存。解决方案：设置连接超时，限制最大连接数，使用连接池。',
            type: TipType.caution,
          ),
          TipBox(
            '安全风险 2 - 数据泄露：\n'
            '永远不要在未加密的连接上传输敏感信息（密码、Token、个人数据）。'
            '使用 SSL/TLS 加密所有网络通信。即使是在局域网内，也可能存在中间人攻击。',
            type: TipType.caution,
          ),
          TipBox(
            '安全风险 3 - 注入攻击：\n'
            '不要直接拼接用户输入到命令或查询中。对网络接收到的数据进行严格验证和清理，'
            '特别是当这些数据被用于文件路径、Shell 命令或数据库查询时。'
            '始终假设网络数据是恶意的。',
            type: TipType.caution,
          ),
          TipBox(
            '安全风险 4 - 整数溢出与缓冲区：\n'
            '当使用 struct 解包长度前缀时，验证接收到的长度值是否合理。'
            '攻击者可能发送一个巨大的长度值（如 4GB），导致服务器耗尽内存。'
            '在分配缓冲区前始终验证长度值在合理范围内。',
            type: TipType.caution,
          ),
          CodeBlock(
            r'''import socket

class SecureServer:
    """一个安全意识更强的服务器框架"""

    MAX_CONNECTIONS = 128      # 最大并发连接数
    MAX_MESSAGE_SIZE = 65536   # 最大消息大小（64KB）
    BUFFER_SIZE = 4096         # 缓冲区大小
    CONNECTION_TIMEOUT = 30    # 连接超时（秒）

    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.active_connections = 0
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((host, port))
        self.server.listen(self.MAX_CONNECTIONS)

    def validate_and_handle(self, client, addr):
        """安全地处理客户端连接"""
        try:
            # 1. 设置超时
            client.settimeout(self.CONNECTION_TIMEOUT)

            # 2. 检查连接数量
            if self.active_connections >= self.MAX_CONNECTIONS:
                client.sendall(b'Server busy, try later.\n')
                return

            # 3. 验证数据长度
            data = client.recv(self.BUFFER_SIZE)
            if len(data) > self.MAX_MESSAGE_SIZE:
                client.sendall(b'Message too large.\n')
                return

            # 4. 验证数据内容（仅允许可打印的 ASCII 和中文）
            try:
                text = data.decode('utf-8')
                # 在此处添加更多验证逻辑
            except UnicodeDecodeError:
                client.sendall(b'Invalid encoding.\n')
                return

            # 5. 安全处理数据
            sanitized = self.sanitize_input(text)
            response = f'OK: {sanitized}'.encode('utf-8')
            client.sendall(response)

        except socket.timeout:
            print(f'[{addr}] 连接超时')
        except Exception as e:
            print(f'[{addr}] 错误: {e}')
        finally:
            client.close()
            self.active_connections -= 1

    def sanitize_input(self, text):
        """清理用户输入，防止注入"""
        # 移除控制字符
        import re
        cleaned = re.sub(r'[\x00-\x1f\x7f]', '', text)
        # 限制长度
        return cleaned[:1024]''',
            language: 'Python',
          ),
          Paragraph(
            '其他安全要点：\n'
            '  • 永远不要使用 AF_UNIX 套接字绑定到可预测的路径（/tmp/ 目录下的竞争条件攻击）\n'
            '  • 在生产环境中禁用 SO_REUSEADDR 的调试用途，了解其安全影响\n'
            '  • 使用容器或沙箱隔离网络服务，限制其系统权限\n'
            '  • 定期审计网络服务的日志，监控异常连接模式\n'
            '  • 及时更新 Python 版本和依赖库，修复已知的安全漏洞',
          ),
          DividerLine(),

          // ===== 总结 =====
          SectionHeader('总结', icon: Icons.summarize),
          Paragraph(
            '本章全面介绍了 Python 网络编程的核心知识。从基本的 Socket 概念、TCP/UDP 协议，'
            '到高级的并发处理、SSL/TLS 加密和安全性考虑。网络编程是构建分布式系统的基石，'
            '掌握这些技能将为你开发网络应用打下坚实的基础。',
          ),
          Paragraph(
            '学习建议：\n'
            '  • 动手实践：自己实现 Echo 服务器和聊天服务器，理解每一步的含义\n'
            '  • 逐步深入：先掌握阻塞式 Socket，再学习非阻塞和 selectors 模块\n'
            '  • 阅读源码：查看 Python 标准库中 http.server 和 socketserver 的源码\n'
            '  • 学习进阶：进一步学习 asyncio 异步网络编程和 WebSocket 协议\n'
            '  • 安全第一：在任何网络项目中都要有安全意识，保护用户数据',
          ),
          TipBox(
            '推荐学习资源：\n'
            '  • 《Python 网络编程》（Foundations of Python Network Programming）\n'
            '  • Python 官方文档：socket、ssl、selectors、asyncio 模块\n'
            '  • Real Python 的 Socket 编程教程\n'
            '  • 尝试使用 Twisted、Tornado 或 aiohttp 等第三方网络框架',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
