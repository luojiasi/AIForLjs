import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// pip 包管理交互式演示
class _PipPackageDemo extends StatefulWidget {
  const _PipPackageDemo();
  @override
  State<_PipPackageDemo> createState() => _PipPackageDemoState();
}

class _PipPackageDemoState extends State<_PipPackageDemo> {
  String _category = 'data';
  String _package = 'numpy';
  String _version = '1.24.3';
  bool _installed = false;
  bool _upgraded = false;

  static const _packages = <String, List<(String, String, String)>>{
    'data': [('numpy', '1.24.3', '科学计算核心库，提供高效的多维数组'), ('pandas', '2.0.1', '数据分析库，DataFrame 表格操作'), ('matplotlib', '3.7.1', '数据可视化，绘制各种图表')],
    'web': [('requests', '2.31.0', '简洁的 HTTP 请求库'), ('flask', '2.3.2', '轻量级 Web 框架'), ('fastapi', '0.95.0', '现代高性能 Web API 框架')],
    'tools': [('pillow', '9.5.0', 'Python 图像处理库'), ('pytest', '7.3.1', 'Python 测试框架'), ('black', '23.3.0', 'Python 代码格式化工具')],
  };

  List<(String, String, String)> get _options => _packages[_category]!;
  (String, String, String) get _pkgInfo => _options.firstWhere((p) => p.$1 == _package);

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '📦 pip 包管理演示',
      subtitle: '探索不同类别的 Python 第三方包和安装命令',
      children: [
        ParamChoiceChips<String>(
          label: '包类别',
          value: _category,
          options: [('data', '数据科学'), ('web', 'Web开发'), ('tools', '开发工具')],
          onChanged: (v) => setState(() { _category = v; _package = _packages[v]!.first.$1; _installed = false; _upgraded = false; }),
        ),
        ParamChoiceChips<String>(
          label: '选择包',
          value: _package,
          options: _options.map((p) => (p.$1, '${p.$1} v${p.$2}')).toList(),
          onChanged: (v) => setState(() { _package = v; _installed = false; _upgraded = false; final info = _options.firstWhere((p) => p.$1 == v); _version = info.$2; }),
        ),
        // 包信息卡
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_package, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('v$_version', style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
            ]),
            const SizedBox(height: 4),
            Text(_pkgInfo.$3, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: () => setState(() { _installed = true; _upgraded = false; }),
            icon: const Icon(Icons.download, size: 14),
            label: const Text('模拟安装'),
          ),
          const SizedBox(width: 8),
          if (_installed)
            OutlinedButton.icon(
              onPressed: () => setState(() => _upgraded = true),
              icon: const Icon(Icons.upload, size: 14),
              label: const Text('模拟升级'),
            ),
        ]),
        if (_installed) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_upgraded ? '$_package 已升级到最新版' : '$_package v$_version 已安装', style: const TextStyle(fontSize: 13, color: Colors.green))),
            ])),
        ],
        LiveCodeBlock(
          '${_installed ? '# 已安装\n' : ''}'
          'pip install $_package==$_version\n'
          '${_upgraded ? '\n# 升级到最新版\npip install --upgrade $_package' : ''}'
          '\n\n# 查看已安装包\npip list\n\n'
          '# 导出依赖\npip freeze > requirements.txt',
        ),
      ],
    );
  }
}

class PythonThirdPartyTutorial extends StatelessWidget {
  const PythonThirdPartyTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第21章 常用第三方模块'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // 21.1 requests — HTTP请求库
          // ==========================================
          const SectionHeader('21.1 requests — HTTP请求库', icon: Icons.http),
          const Paragraph(
            'requests 是 Python 中最流行的 HTTP 库，它以简洁优雅的 API 著称。'
            '相比 Python 标准库中的 urllib，requests 让 HTTP 请求变得异常简单直观。'
            '它支持 GET、POST、PUT、DELETE 等所有常见 HTTP 方法，'
            '并自动处理 Cookie、重定向、编码等细节，是网络爬虫和 API 调用的首选库。',
          ),
          const TipBox(
            '使用 requests 前需要先安装：在终端执行 pip install requests',
            type: TipType.info,
          ),
          const DividerLine(),

          // GET请求
          const Paragraph(
            '1. GET 请求 — 获取资源\n'
            'requests.get() 是最常用的方法，用于从服务器获取资源。'
            '可以通过 params 参数传递 URL 查询参数，通过 headers 参数设置自定义请求头。'
            '服务器返回的 Response 对象包含所有响应信息。',
          ),
          const CodeBlock(
            r'''import requests

# 基本 GET 请求
response = requests.get('https://httpbin.org/get')
print('状态码:', response.status_code)

# 带查询参数的 GET 请求
params = {'keyword': 'python', 'page': 1}
response = requests.get('https://httpbin.org/get', params=params)
print('实际请求 URL:', response.url)

# 自定义请求头
headers = {'User-Agent': 'Mozilla/5.0', 'Accept-Language': 'zh-CN,zh;q=0.9'}
response = requests.get('https://httpbin.org/headers', headers=headers)
print('请求头信息:', response.json())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''状态码: 200
实际请求 URL: https://httpbin.org/get?keyword=python&page=1
请求头信息: {'headers': {'User-Agent': 'Mozilla/5.0', 'Accept-Language': 'zh-CN,zh;q=0.9', ...}}''',
          ),

          // POST请求
          const DividerLine(),
          const Paragraph(
            '2. POST 请求 — 提交数据\n'
            'requests.post() 用于向服务器提交数据。'
            '使用 data 参数发送表单格式数据，使用 json 参数自动发送 JSON 格式数据并设置正确的 Content-Type。'
            '文件上传可以使用 files 参数。',
          ),
          const CodeBlock(
            r'''import requests

# 发送表单数据
form_data = {'username': 'alice', 'password': '123456'}
response = requests.post('https://httpbin.org/post', data=form_data)
print('表单数据:', response.json()['form'])

# 发送 JSON 数据
json_data = {'name': 'Alice', 'age': 25, 'skills': ['Python', 'Flutter']}
response = requests.post('https://httpbin.org/post', json=json_data)
print('JSON 数据:', response.json()['json'])
print('Content-Type:', response.headers['Content-Type'])

# 上传文件
# files = {'file': open('report.txt', 'rb')}
# response = requests.post('https://httpbin.org/post', files=files)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''表单数据: {'username': 'alice', 'password': '123456'}
JSON 数据: {'name': 'Alice', 'age': 25, 'skills': ['Python', 'Flutter']}
Content-Type: application/json''',
          ),

          // 响应对象详解
          const DividerLine(),
          const Paragraph(
            '3. 响应对象 — Response 详解\n'
            'Response 对象包含服务器返回的所有信息。'
            '.text 返回文本内容，.content 返回字节内容，.json() 将 JSON 响应解析为字典。'
            '.status_code 获取 HTTP 状态码，.headers 获取响应头字典，.url 获取最终请求 URL。'
            '.encoding 可以获取或设置编码方式。',
          ),
          const CodeBlock(
            r'''import requests

response = requests.get('https://httpbin.org/get')

# 文本和字节内容
print('文本内容 (前50字符):', response.text[:50])
print('字节内容 (前50字节):', response.content[:50])
print('编码方式:', response.encoding)

# JSON 解析
data = response.json()
print('解析为 JSON:', data)

# 状态码
print('状态码:', response.status_code)
if response.status_code == 200:
    print('请求成功!')

# 响应头
print('服务器:', response.headers.get('Server'))
print('内容类型:', response.headers.get('Content-Type'))
print('所有响应头:', dict(response.headers))

# 其他信息
print('最终 URL:', response.url)
print('请求耗时:', response.elapsed.total_seconds(), '秒')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''文本内容 (前50字符): {
  "args": {},
  "headers": {
字节内容 (前50字节): b'{\n  "args": {},\n  "headers": {\n    '
编码方式: utf-8
解析为 JSON: {'args': {}, 'headers': {...}, 'origin': '...', 'url': '...'}
状态码: 200
请求成功!
服务器: gunicorn
内容类型: application/json
所有响应头: {'Content-Type': 'application/json', ...}
最终 URL: https://httpbin.org/get
请求耗时: 0.35 秒''',
          ),

          // Session 会话对象
          const DividerLine(),
          const Paragraph(
            '4. Session 会话对象\n'
            'requests.Session() 可以在多个请求之间保持会话状态，自动管理 Cookie。'
            '它复用底层 TCP 连接（连接池），显著提高连续请求的性能。'
            '可以在 Session 对象上设置默认的 headers、cookies 等参数，'
            '该 Session 发起的所有请求都会自动携带这些默认值。',
          ),
          const CodeBlock(
            r'''import requests

# 创建 Session 对象
session = requests.Session()

# 设置会话级默认值
session.headers.update({'User-Agent': 'MyApp/1.0'})
session.cookies.update({'session_id': 'abc123'})

# 使用 Session 发起请求
response1 = session.get('https://httpbin.org/cookies')
print('第一次请求 Cookies:', response1.json())

response2 = session.get('https://httpbin.org/headers')
print('第二次请求 User-Agent:', response2.json()['headers']['User-Agent'])

# 关闭 Session 释放连接
session.close()

# 推荐使用上下文管理器 (with 语句)
with requests.Session() as s:
    s.headers.update({'Authorization': 'Bearer token123'})
    resp = s.get('https://httpbin.org/bearer')
    print('Bearer 认证:', resp.json())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''第一次请求 Cookies: {'cookies': {'session_id': 'abc123'}}
第二次请求 User-Agent: MyApp/1.0
Bearer 认证: {'authenticated': True, 'token': 'token123'}''',
          ),

          // 超时设置
          const DividerLine(),
          const Paragraph(
            '5. 超时设置\n'
            'requests 默认不会设置超时时间，如果服务器无响应，程序可能永久挂起。'
            '通过 timeout 参数可以设置等待秒数，超过指定时间未响应则抛出 requests.Timeout 异常。'
            '也可以传入元组分别设置连接超时和读取超时。',
          ),
          const CodeBlock(
            r'''import requests

# 设置总超时 5 秒
try:
    response = requests.get('https://httpbin.org/delay/3', timeout=5)
    print('请求成功:', response.status_code)
except requests.Timeout:
    print('请求超时!')

# 单独设置连接超时和读取超时
try:
    response = requests.get(
        'https://httpbin.org/delay/3',
        timeout=(2, 5)  # (连接超时秒数, 读取超时秒数)
    )
    print('请求成功:', response.status_code)
except requests.Timeout:
    print('请求超时!')
except requests.ConnectionError:
    print('连接失败!')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''请求成功: 200
请求成功: 200''',
          ),

          // SSL 验证
          const DividerLine(),
          const Paragraph(
            '6. SSL 证书验证\n'
            'requests 默认验证 SSL 证书以确保连接安全。'
            '对于测试环境或使用自签名证书的情况，可设置 verify=False 跳过验证，'
            '但会显示 InsecureRequestWarning 警告。也可以指定自定义 CA 证书路径。',
          ),
          const CodeBlock(
            r'''import requests
import urllib3

# 跳过 SSL 验证（仅用于测试环境）
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
response = requests.get('https://httpbin.org/get', verify=False)
print('已跳过 SSL 验证，状态码:', response.status_code)

# 指定 CA 证书文件
# response = requests.get('https://example.com', verify='/path/to/cert.pem')

# 正常验证（默认行为）
response = requests.get('https://httpbin.org/get')
print('正常验证，状态码:', response.status_code)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''已跳过 SSL 验证，状态码: 200
正常验证，状态码: 200''',
          ),

          // 代理设置
          const DividerLine(),
          const Paragraph(
            '7. 代理设置\n'
            'requests 支持通过 proxies 参数为 HTTP 和 HTTPS 分别设置代理服务器。'
            '也可以通过环境变量 HTTP_PROXY 和 HTTPS_PROXY 设置全局代理，'
            '这种方式对所有使用 requests 的代码自动生效。',
          ),
          const CodeBlock(
            r'''import requests

# 通过参数设置代理
proxies = {
    'http': 'http://10.10.1.10:3128',
    'https': 'http://10.10.1.10:1080',
}
try:
    response = requests.get(
        'https://httpbin.org/get',
        proxies=proxies,
        timeout=5
    )
    print('通过代理请求成功:', response.status_code)
except requests.ConnectionError:
    print('代理连接失败（代理地址仅为示例）')

# 通过环境变量设置代理
# import os
# os.environ['HTTP_PROXY'] = 'http://10.10.1.10:3128'
# os.environ['HTTPS_PROXY'] = 'http://10.10.1.10:1080'
# response = requests.get('https://httpbin.org/get')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''代理连接失败（代理地址仅为示例）''',
          ),
          const TipBox(
            '在生产环境中，推荐使用 Session + 超时 + 重试机制的组合方式，'
            '同时通过环境变量配置代理，避免将敏感信息硬编码在代码中。',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.2 beautifulsoup4 — HTML/XML解析
          // ==========================================
          const SectionHeader('21.2 beautifulsoup4 — HTML/XML解析库', icon: Icons.web),
          const Paragraph(
            'Beautiful Soup 是 Python 最流行的 HTML 和 XML 解析库，'
            '它可以将复杂的 HTML 文档转换为 Python 对象树，'
            '提供了简单直观的 API 来搜索、导航和修改解析树。'
            '常与 requests 配合用于网络爬虫开发，从网页中提取结构化数据。',
          ),
          const TipBox(
            '安装 beautifulsoup4：pip install beautifulsoup4\n'
            '推荐同时安装 lxml 解析器以获得更好性能：pip install lxml',
            type: TipType.info,
          ),
          const DividerLine(),

          // 创建 BeautifulSoup 对象
          const Paragraph(
            '1. 创建 BeautifulSoup 对象\n'
            'BeautifulSoup() 构造函数接受 HTML 字符串和解析器名称。'
            '常用解析器：html.parser（标准库内置，无需额外安装）、'
            'lxml（速度快，需安装）、html5lib（容错性最强，需安装）。',
          ),
          const CodeBlock(
            r'''from bs4 import BeautifulSoup

# 示例 HTML 文档
html_doc = """
<html>
  <head><title>我的页面</title></head>
  <body>
    <h1 id="title">欢迎光临</h1>
    <p class="content">这是一段介绍文字。</p>
    <p class="content">这是第二段文字。</p>
    <a href="http://example.com">链接1</a>
    <a href="http://example2.com">链接2</a>
    <div id="footer">
      <p>版权信息 &copy; 2024</p>
    </div>
  </body>
</html>
"""

# 使用标准库解析器
soup = BeautifulSoup(html_doc, 'html.parser')
print('页面标题:', soup.title.text)

# prettify() 美化输出
print('格式化 HTML:')
print(soup.prettify()[:300])''',
            language: 'Python',
          ),
          const OutputBox(
            r'''页面标题: 我的页面
格式化 HTML:
<html>
 <head>
  <title>
   我的页面
  </title>
 </head>
 <body>
  <h1 id="title">
   欢迎光临
  </h1>
  <p class="content">
   这是一段介绍文字。
  </p>
  <p class="content">
   这是第二段文字。
  </p>
  ...''',
          ),

          // find() 和 find_all()
          const DividerLine(),
          const Paragraph(
            '2. find() 和 find_all() 方法\n'
            'find(name, attrs, recursive, string, **kwargs) 返回第一个匹配的元素。'
            'find_all(name, attrs, recursive, string, limit, **kwargs) 返回所有匹配元素的列表。'
            '可以通过标签名、属性字典、CSS 类名、文本内容等多种方式搜索。',
          ),
          const CodeBlock(
            r'''from bs4 import BeautifulSoup

html = """
<html><body>
  <h1 id="title">文章标题</h1>
  <p class="content">第一段文字</p>
  <p class="content highlight">第二段文字（高亮）</p>
  <p class="content">第三段文字</p>
  <a href="http://example.com" id="link1">示例链接</a>
  <a href="http://test.com" class="external">测试链接</a>
</body></html>
"""
soup = BeautifulSoup(html, 'html.parser')

# find() - 返回第一个匹配
h1 = soup.find('h1')
print('第一个h1:', h1.text)

# find_all() - 返回列表
paragraphs = soup.find_all('p')
print('p标签数量:', len(paragraphs))
for i, p in enumerate(paragraphs):
    print(f'  第{i+1}段: {p.text}')

# 按属性搜索
link = soup.find('a', id='link1')
print('ID搜索:', link.text, '->', link['href'])

# 按 CSS 类名搜索
highlight_ps = soup.find_all('p', class_='highlight')
print('高亮段落:', [p.text for p in highlight_ps])

# 按文本内容搜索
import re
has_link = soup.find_all('a', string=re.compile(r'示例'))
print('文本匹配:', [a.text for a in has_link])''',
            language: 'Python',
          ),
          const OutputBox(
            r'''第一个h1: 文章标题
p标签数量: 3
  第1段: 第一段文字
  第2段: 第二段文字（高亮）
  第3段: 第三段文字
ID搜索: 示例链接 -> http://example.com
高亮段落: ['第二段文字（高亮）']
文本匹配: ['示例链接']''',
          ),

          // CSS 选择器 select()
          const DividerLine(),
          const Paragraph(
            '3. CSS 选择器 — select() 方法\n'
            'select() 方法支持使用 CSS 选择器语法查找元素，非常直观。'
            '支持标签选择器、类选择器、ID 选择器、属性选择器、'
            '后代选择器、子选择器等标准 CSS 选择器。',
          ),
          const CodeBlock(
            r'''from bs4 import BeautifulSoup

html = """
<div class="container">
  <ul id="nav">
    <li class="active">首页</li>
    <li><a href="/about">关于</a></li>
    <li><a href="/contact" class="link">联系我们</a></li>
  </ul>
  <div class="content">
    <p>第一段文字</p>
    <p>第二段文字</p>
  </div>
</div>
"""
soup = BeautifulSoup(html, 'html.parser')

# 标签选择器
print('所有li:', [li.text for li in soup.select('li')])

# 类选择器
print('.active元素:', soup.select('.active')[0].text)

# ID选择器
print('#nav:', soup.select('#nav')[0].name)

# 后代选择器
print('ul中的a:', [a.text for a in soup.select('ul a')])

# 子选择器
print('div > p:', [p.text for p in soup.select('div > p')])

# 属性选择器
print('[href]:', [a['href'] for a in soup.select('[href]')])
print('a.link:', [a.text for a in soup.select('a.link')])

# 组合选择器
print('li.active:', [li.text for li in soup.select('li.active')])''',
            language: 'Python',
          ),
          const OutputBox(
            r'''所有li: ['首页', '关于', '联系我们']
.active元素: 首页
#nav: ul
ul中的a: ['关于', '联系我们']
div > p: ['第一段文字', '第二段文字']
[href]: ['/about', '/contact']
a.link: ['联系我们']
li.active: ['首页']''',
          ),

          // 遍历解析树
          const DividerLine(),
          const Paragraph(
            '4. 遍历解析树\n'
            'Beautiful Soup 将 HTML 解析为树形结构，可以通过属性在树中导航。'
            '.parent 获取父节点，.children 获取子节点迭代器，'
            '.next_sibling 获取下一个兄弟节点，.contents 获取子节点列表。',
          ),
          const CodeBlock(
            r'''from bs4 import BeautifulSoup

html = """
<html>
  <body>
    <div id="main">
      <h1>标题</h1>
      <p>段落1</p>
      <p>段落2</p>
      <span>备注</span>
    </div>
  </body>
</html>
"""
soup = BeautifulSoup(html, 'html.parser')

h1 = soup.h1
print('当前元素:', h1.text)

# parent 父节点
print('父节点:', h1.parent.name)
print('父节点ID:', h1.parent.get('id'))

# parents 所有祖先节点
print('所有祖先:', [p.name for p in h1.parents])

# children 子节点
main_div = soup.find('div', id='main')
print('子节点列表:')
for child in main_div.children:
    if child.name:
        print(f'  <{child.name}>: {child.text.strip()}')

# next_sibling 和 previous_sibling
p1 = soup.find('p')
print('第一个p:', p1.text)
print('下一个兄弟:', p1.next_sibling.next_sibling.text)
print('上一个兄弟:', p1.previous_sibling.previous_sibling.text if p1.previous_sibling else '无')

# contents 子节点列表
print('子节点数量:', len(main_div.contents))''',
            language: 'Python',
          ),
          const OutputBox(
            r'''当前元素: 标题
父节点: div
父节点ID: main
所有祖先: ['div', 'body', 'html', '[document]']
子节点列表:
  <h1>: 标题
  <p>: 段落1
  <p>: 段落2
  <span>: 备注
第一个p: 段落1
下一个兄弟: 段落2
上一个兄弟: 标题
子节点数量: 9''',
          ),

          // 修改与美化
          const DividerLine(),
          const Paragraph(
            '5. 修改解析树与美化输出\n'
            'Beautiful Soup 不仅支持读取，还支持修改解析树。'
            '可以修改标签的文本内容、属性，添加或删除标签，'
            '最后用 prettify() 方法输出格式化的 HTML。',
          ),
          const CodeBlock(
            r'''from bs4 import BeautifulSoup

html = '<html><body><h1>旧标题</h1><p class="old">旧内容</p></body></html>'
soup = BeautifulSoup(html, 'html.parser')

# 修改标签文本
soup.h1.string = '新标题'
print('修改后标题:', soup.h1.text)

# 修改属性
soup.p['class'] = 'new'
soup.p['id'] = 'first-p'
print('修改后p标签:', soup.p)

# 添加新标签
from bs4 import Tag
new_tag = soup.new_tag('a', href='http://example.com')
new_tag.string = '新链接'
soup.body.append(new_tag)
print('添加链接后:', soup.body)

# 删除标签
soup.p.decompose()
print('删除p标签后:', soup.body)

# prettify() 美化输出
print('美化后的HTML:')
print(soup.prettify())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''修改后标题: 新标题
修改后p标签: <p class="new" id="first-p">旧内容</p>
添加链接后: <body><h1>新标题</h1><p class="new" id="first-p">旧内容</p><a href="http://example.com">新链接</a></body>
删除p标签后: <body><h1>新标题</h1><a href="http://example.com">新链接</a></body>
美化后的HTML:
<html>
 <body>
  <h1>
   新标题
  </h1>
  <a href="http://example.com">
   新链接
  </a>
 </body>
</html>''',
          ),
          const TipBox(
            '在网络爬虫中，推荐使用 lxml 作为解析器（速度最快），'
            '对于不规范的 HTML 页面则使用 html5lib（容错性最强）。'
            '解析器作为第二个参数传入：BeautifulSoup(html, "lxml")',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.3 Pillow (PIL) — 图像处理
          // ==========================================
          const SectionHeader('21.3 Pillow (PIL) — 图像处理库', icon: Icons.image),
          const Paragraph(
            'Pillow 是 Python 图像处理的标准库，它是 PIL (Python Imaging Library) 的活跃分支。'
            'Pillow 支持打开、操作和保存多种图像格式，包括 PNG、JPEG、GIF、BMP、TIFF 等。'
            '它提供了图像缩放、裁剪、旋转、滤镜应用、绘图等丰富的功能。',
          ),
          const TipBox(
            '安装 Pillow：pip install Pillow\n'
            '注意：导入时使用 from PIL import ...，而不是 from Pillow import ...',
            type: TipType.info,
          ),
          const DividerLine(),

          // 打开与保存图像
          const Paragraph(
            '1. 打开与保存图像\n'
            'Image.open() 打开图像文件，返回 Image 对象。'
            'Image 对象包含图像的基本信息：.size（宽高元组）、.mode（颜色模式）、'
            '.format（图像格式）。.save() 方法保存图像到文件，格式由文件扩展名决定。',
          ),
          const CodeBlock(
            r'''from PIL import Image

# 打开图像
img = Image.open('example.jpg')
print('图像大小:', img.size)      # (宽度, 高度)
print('颜色模式:', img.mode)      # RGB, RGBA, L 等
print('图像格式:', img.format)    # JPEG, PNG, GIF 等
print('图像信息:', img.info)

# 显示图像（调用系统默认图片查看器）
# img.show()

# 转换格式并保存
img.save('output.png')          # JPEG -> PNG
print('已保存为 PNG 格式')

# 保存为不同质量的 JPEG
img.save('output_high.jpg', quality=95)   # 高质量
img.save('output_low.jpg', quality=30)    # 低质量（文件更小）

print('所有图像已保存')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''图像大小: (1920, 1080)
颜色模式: RGB
图像格式: JPEG
图像信息: {'jfif': 257, 'jfif_version': (1, 1), ...}
已保存为 PNG 格式
所有图像已保存''',
          ),

          // 调整大小
          const DividerLine(),
          const Paragraph(
            '2. 调整图像大小\n'
            'resize(size, resample) 将图像缩放到指定尺寸，接受 (width, height) 元组。'
            'thumbnail(size) 创建缩略图，保持宽高比且不超过指定尺寸。'
            'resample 参数可选 Image.NEAREST（最近邻）、Image.BILINEAR（双线性）、'
            'Image.BICUBIC（双三次）、Image.LANCZOS（最佳质量）。',
          ),
          const CodeBlock(
            r'''from PIL import Image

img = Image.open('example.jpg')
print('原始大小:', img.size)

# resize() - 精确指定尺寸（可能变形）
resized = img.resize((800, 600))
print('resize后:', resized.size)
resized.save('resized_800x600.jpg')

# resize() 指定重采样算法（推荐 LANCZOS）
resized_quality = img.resize((800, 600), Image.LANCZOS)
resized_quality.save('resized_lanczos.jpg')

# thumbnail() - 保持宽高比的缩略图
thumb = img.copy()
thumb.thumbnail((200, 200))
print('thumbnail后:', thumb.size)
thumb.save('thumbnail_200.jpg')

# 等比缩放到固定宽度
width_percent = 0.5
new_width = int(img.size[0] * width_percent)
new_height = int(img.size[1] * width_percent)
half_size = img.resize((new_width, new_height), Image.LANCZOS)
print('等比缩放50%:', half_size.size)
half_size.save('half_size.jpg')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''原始大小: (1920, 1080)
resize后: (800, 600)
thumbnail后: (200, 112)
等比缩放50%: (960, 540)''',
          ),

          // 裁剪与旋转
          const DividerLine(),
          const Paragraph(
            '3. 裁剪与旋转\n'
            'crop(box) 裁剪图像，box 为 (left, top, right, bottom) 的四元组。'
            'rotate(angle, expand, fill) 旋转图像，expand=True 时会扩展画布以适应旋转后的图像。'
            'transpose(method) 可以执行翻转操作，如 FLIP_LEFT_RIGHT 水平翻转。',
          ),
          const CodeBlock(
            r'''from PIL import Image

img = Image.open('example.jpg')
print('原始大小:', img.size)

# crop() - 裁剪区域 (left, top, right, bottom)
box = (100, 100, 500, 400)
cropped = img.crop(box)
print('裁剪区域:', box)
print('裁剪后大小:', cropped.size)
cropped.save('cropped.jpg')

# rotate() - 旋转
rotated_45 = img.rotate(45, expand=True, fill=(255, 255, 255))
print('旋转45度后:', rotated_45.size)
rotated_45.save('rotated_45.jpg')

rotated_90 = img.rotate(90, expand=True)
print('旋转90度后:', rotated_90.size)
rotated_90.save('rotated_90.jpg')

# transpose() - 翻转操作
flipped = img.transpose(Image.FLIP_LEFT_RIGHT)
flipped.save('flipped_horizontal.jpg')

mirrored = img.transpose(Image.FLIP_TOP_BOTTOM)
mirrored.save('flipped_vertical.jpg')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''原始大小: (1920, 1080)
裁剪区域: (100, 100, 500, 400)
裁剪后大小: (400, 300)
旋转45度后: (1358, 1358)
旋转90度后: (1080, 1920)''',
          ),

          // 图像滤镜
          const DividerLine(),
          const Paragraph(
            '4. 图像滤镜\n'
            'ImageFilter 模块提供了多种内置滤镜。'
            'BLUR 模糊、CONTOUR 轮廓、DETAIL 细节增强、EDGE_ENHANCE 边缘增强、'
            'EMBOSS 浮雕、SHARPEN 锐化、SMOOTH 平滑等。'
            'filter() 方法应用滤镜到图像。',
          ),
          const CodeBlock(
            r'''from PIL import Image, ImageFilter

img = Image.open('example.jpg')

# 应用各种滤镜
blurred = img.filter(ImageFilter.BLUR)
blurred.save('filter_blur.jpg')
print('已应用模糊滤镜')

contour = img.filter(ImageFilter.CONTOUR)
contour.save('filter_contour.jpg')
print('已应用轮廓滤镜')

emboss = img.filter(ImageFilter.EMBOSS)
emboss.save('filter_emboss.jpg')
print('已应用浮雕滤镜')

sharpen = img.filter(ImageFilter.SHARPEN)
sharpen.save('filter_sharpen.jpg')
print('已应用锐化滤镜')

# 自定义模糊半径（使用 GaussianBlur）
gaussian = img.filter(ImageFilter.GaussianBlur(radius=5))
gaussian.save('filter_gaussian_5.jpg')
print('已应用高斯模糊(radius=5)')

# 边缘增强
edge = img.filter(ImageFilter.EDGE_ENHANCE)
edge.save('filter_edge.jpg')
print('已应用边缘增强滤镜')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''已应用模糊滤镜
已应用轮廓滤镜
已应用浮雕滤镜
已应用锐化滤镜
已应用高斯模糊(radius=5)
已应用边缘增强滤镜''',
          ),

          // 图像模式与颜色
          const DividerLine(),
          const Paragraph(
            '5. 图像模式与颜色处理\n'
            'Pillow 支持多种颜色模式：RGB（真彩色）、RGBA（带透明通道）、'
            'L（灰度）、CMYK（印刷色彩）、HSV 等。'
            'convert() 方法可以在不同模式间转换。'
            'split() 可以分离颜色通道，merge() 可以合并通道。',
          ),
          const CodeBlock(
            r'''from PIL import Image

img = Image.open('example.jpg')
print('原始模式:', img.mode)

# 转换为灰度图
gray = img.convert('L')
print('灰度模式:', gray.mode)
gray.save('grayscale.jpg')

# 转换为 RGBA（带透明通道）
rgba = img.convert('RGBA')
print('RGBA模式:', rgba.mode)
rgba.save('rgba_output.png')

# 分离和合并颜色通道
if img.mode == 'RGB':
    r, g, b = img.split()
    print('红色通道大小:', r.size)
    print('绿色通道大小:', g.size)
    print('蓝色通道大小:', b.size)

    # 合并时交换通道（创建特殊效果）
    swapped = Image.merge('RGB', (b, g, r))
    swapped.save('channel_swapped.jpg')
    print('已保存通道交换后的图像')

    # 单独保存红色通道
    r.save('red_channel.jpg')
    print('已保存红色通道')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''原始模式: RGB
灰度模式: L
RGBA模式: RGBA
红色通道大小: (1920, 1080)
绿色通道大小: (1920, 1080)
蓝色通道大小: (1920, 1080)
已保存通道交换后的图像
已保存红色通道''',
          ),

          // ImageDraw 绘图
          const DividerLine(),
          const Paragraph(
            '6. ImageDraw 绘图\n'
            'ImageDraw 模块提供了在图像上绘制图形和文字的功能。'
            '可以绘制矩形、椭圆、线段、弧线、多边形等基本形状，'
            '也可以绘制文字。fill 参数设置填充颜色，outline 参数设置边框颜色。',
          ),
          const CodeBlock(
            r'''from PIL import Image, ImageDraw, ImageFont

# 创建新图像（白色背景）
img = Image.new('RGB', (600, 400), 'white')
draw = ImageDraw.Draw(img)

# 绘制矩形
draw.rectangle([50, 50, 250, 150], fill='blue', outline='black', width=3)

# 绘制椭圆（在矩形区域内）
draw.ellipse([300, 50, 550, 200], fill='red', outline='black', width=2)

# 绘制圆角矩形
draw.rounded_rectangle([50, 200, 250, 350], radius=20, fill='green', outline='black')

# 绘制线条
draw.line([300, 250, 550, 350], fill='purple', width=5)

# 绘制多边形（三角形）
draw.polygon([(450, 250), (400, 350), (550, 350)], fill='orange', outline='black')

# 绘制文字
try:
    font = ImageFont.truetype('arial.ttf', 24)
    draw.text((50, 360), 'Hello, Pillow!', fill='black', font=font)
except IOError:
    draw.text((50, 360), 'Hello, Pillow!', fill='black')

img.save('drawing_demo.jpg')
print('绘图完成，已保存为 drawing_demo.jpg')

# 显示图像
img.show()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''绘图完成，已保存为 drawing_demo.jpg''',
          ),
          const TipBox(
            'ImageDraw 的坐标系统以左上角为原点 (0,0)，'
            'x 轴向右增加，y 轴向下增加。'
            '绘制文字时，如果没有可用的 TrueType 字体，Pillow 会使用默认位图字体。',
            type: TipType.info,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.4 numpy — 数值计算
          // ==========================================
          const SectionHeader('21.4 numpy — 数值计算库', icon: Icons.calculate),
          const Paragraph(
            'NumPy 是 Python 数值计算的基础库，提供了高性能的多维数组对象 ndarray '
            '以及丰富的数组运算函数。它是 pandas、scikit-learn、TensorFlow 等'
            '众多数据科学和机器学习库的基石。NumPy 的核心是用 C 语言实现的，'
            '因此在处理大规模数据时比纯 Python 代码快几个数量级。',
          ),
          const TipBox(
            '安装 numpy：pip install numpy\n'
            '导入约定：import numpy as np',
            type: TipType.info,
          ),
          const DividerLine(),

          // 创建数组
          const Paragraph(
            '1. 创建数组 — np.array()\n'
            'np.array() 从 Python 列表或元组创建 ndarray 对象。'
            '.shape 属性返回数组的形状（维度元组），.dtype 属性返回元素的数据类型。'
            'ndim 属性返回数组的维度数，size 属性返回元素总数。',
          ),
          const CodeBlock(
            r'''import numpy as np

# 一维数组
arr1d = np.array([1, 2, 3, 4, 5])
print('一维数组:', arr1d)
print('形状:', arr1d.shape)
print('数据类型:', arr1d.dtype)
print('维度:', arr1d.ndim)
print('元素个数:', arr1d.size)

# 二维数组（矩阵）
arr2d = np.array([[1, 2, 3], [4, 5, 6]])
print('\n二维数组:')
print(arr2d)
print('形状:', arr2d.shape)
print('维度:', arr2d.ndim)

# 指定数据类型
arr_float = np.array([1, 2, 3], dtype=np.float64)
print('\n浮点数组:', arr_float)
print('数据类型:', arr_float.dtype)

# 三维数组
arr3d = np.array([[[1, 2], [3, 4]], [[5, 6], [7, 8]]])
print('\n三维数组形状:', arr3d.shape)
print('三维数组:')
print(arr3d)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''一维数组: [1 2 3 4 5]
形状: (5,)
数据类型: int64
维度: 1
元素个数: 5

二维数组:
[[1 2 3]
 [4 5 6]]
形状: (2, 3)
维度: 2

浮点数组: [1. 2. 3.]
数据类型: float64

三维数组形状: (2, 2, 2)
三维数组:
[[[1 2]
  [3 4]]

 [[5 6]
  [7 8]]]''',
          ),

          // reshape 重塑
          const DividerLine(),
          const Paragraph(
            '2. reshape() — 重塑数组形状\n'
            'reshape() 方法可以在不改变数据的前提下改变数组的形状。'
            '-1 作为维度参数时，NumPy 会自动计算该维度的大小。'
            'resize() 方法可以原地修改形状（与 reshape 返回新数组不同）。',
          ),
          const CodeBlock(
            r'''import numpy as np

# 将一维数组重塑为二维
arr = np.array([1, 2, 3, 4, 5, 6])
reshaped = arr.reshape(2, 3)
print('原始:', arr)
print('重塑为(2,3):')
print(reshaped)

# 使用 -1 自动计算维度
auto = arr.reshape(3, -1)
print('\n使用-1自动计算:', auto.shape)
print(auto)

# 展平多维数组
flat = reshaped.flatten()
print('\n展平:', flat)

# ravel() 返回视图（不是副本）
raveled = reshaped.ravel()
print('ravel:', raveled)
raveled[0] = 999  # 修改视图会影响原数组
print('修改ravel后原数组:')
print(reshaped)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''原始: [1 2 3 4 5 6]
重塑为(2,3):
[[1 2 3]
 [4 5 6]]

使用-1自动计算: (3, 2)
[[1 2]
 [3 4]
 [5 6]]

展平: [1 2 3 4 5 6]
ravel: [1 2 3 4 5 6]
修改ravel后原数组:
[[999   2   3]
 [  4   5   6]]''',
          ),

          // 数组运算
          const DividerLine(),
          const Paragraph(
            '3. 数组运算 — 向量化操作\n'
            'NumPy 数组支持向量化运算，即对整个数组进行逐元素操作，无需编写循环。'
            '支持加法、减法、乘法、除法、幂运算、比较运算等。'
            '向量化运算比 Python 循环快数十倍到数百倍。',
          ),
          const CodeBlock(
            r'''import numpy as np

a = np.array([1, 2, 3, 4])
b = np.array([10, 20, 30, 40])

# 基本算术运算
print('a:', a)
print('b:', b)
print('a + b:', a + b)
print('a - b:', a - b)
print('a * b:', a * b)
print('b / a:', b / a)
print('a ** 2:', a ** 2)

# 比较运算
print('a > 2:', a > 2)
print('a == 3:', a == 3)

# 聚合运算
print('a.sum():', a.sum())
print('a.mean():', a.mean())
print('a.max():', a.max())
print('a.min():', a.min())
print('a.std():', a.std())   # 标准差
print('a.argmax():', a.argmax())  # 最大值的索引

# 矩阵乘法
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])
print('\n矩阵乘法:')
print(A @ B)   # 等价于 np.dot(A, B)
print(np.dot(A, B))''',
            language: 'Python',
          ),
          const OutputBox(
            r'''a: [1 2 3 4]
b: [10 20 30 40]
a + b: [11 22 33 44]
a - b: [ -9 -18 -27 -36]
a * b: [10 40 90 160]
b / a: [10. 10. 10. 10.]
a ** 2: [ 1  4  9 16]
a > 2: [False False  True  True]
a == 3: [False False  True False]
a.sum(): 10
a.mean(): 2.5
a.max(): 4
a.min(): 1
a.std(): 1.118033988749895
a.argmax(): 3

矩阵乘法:
[[19 22]
 [43 50]]
[[19 22]
 [43 50]]''',
          ),

          // 广播机制
          const DividerLine(),
          const Paragraph(
            '4. 广播机制 (Broadcasting)\n'
            '广播是 NumPy 的一种强大机制，允许不同形状的数组进行算术运算。'
            'NumPy 会自动扩展较小数组的维度以匹配较大数组的形状。'
            '广播规则：从尾部维度开始比较，维度相同或其中一个为 1 即可广播。',
          ),
          const CodeBlock(
            r'''import numpy as np

# 标量广播
arr = np.array([1, 2, 3, 4])
print('数组 + 标量:', arr + 10)
print('数组 * 2:', arr * 2)

# 一维数组与二维数组广播
matrix = np.array([[1, 2, 3], [4, 5, 6]])
row = np.array([10, 20, 30])
print('\n矩阵 (2,3):')
print(matrix)
print('行向量 (3,):', row)
print('矩阵 + 行向量:')
print(matrix + row)

# 列向量广播
col = np.array([[100], [200]])
print('\n列向量 (2,1):')
print(col)
print('矩阵 + 列向量:')
print(matrix + col)

# 不符合广播规则时会报错
try:
    wrong = np.array([1, 2])
    matrix + wrong  # 形状不匹配
except ValueError as e:
    print('\n广播错误:', e)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''数组 + 标量: [11 12 13 14]
数组 * 2: [2 4 6 8]

矩阵 (2,3):
[[1 2 3]
 [4 5 6]]
行向量 (3,): [10 20 30]
矩阵 + 行向量:
[[11 22 33]
 [14 25 36]]

列向量 (2,1):
[[100]
 [200]]
矩阵 + 列向量:
[[101 102 103]
 [204 205 206]]

广播错误: operands could not be broadcast together with shapes (2,3) (2,)''',
          ),

          // 常用函数
          const DividerLine(),
          const Paragraph(
            '5. 常用数组创建函数\n'
            'np.arange(start, stop, step) 类似于 range()，返回等差数组。'
            'np.linspace(start, stop, num) 在指定区间内生成等间隔的 num 个数。'
            'np.zeros(shape) 创建全零数组，np.ones(shape) 创建全一数组。'
            'np.eye(N) 创建单位矩阵，np.random.rand() 创建随机数组。',
          ),
          const CodeBlock(
            r'''import numpy as np

# arange - 类似 Python range
print('arange(0, 10, 2):', np.arange(0, 10, 2))
print('arange(5):', np.arange(5))

# linspace - 等间隔数列
print('linspace(0, 1, 5):', np.linspace(0, 1, 5))
print('linspace(0, np.pi, 4):', np.linspace(0, np.pi, 4))

# zeros 和 ones
print('zeros(3):', np.zeros(3))
print('zeros((2,3)):')
print(np.zeros((2, 3)))
print('ones((2,2)):')
print(np.ones((2, 2)))

# 单位矩阵
print('eye(3):')
print(np.eye(3))

# 随机数组
print('random.rand(3):', np.random.rand(3))
print('random.randint(0, 10, 5):', np.random.randint(0, 10, 5))
print('random.randn(3):', np.random.randn(3))  # 标准正态分布

# 空数组（未初始化）
empty = np.empty((3, 3))
print('empty((3,3)):')
print(empty)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''arange(0, 10, 2): [0 2 4 6 8]
arange(5): [0 1 2 3 4]
linspace(0, 1, 5): [0.   0.25 0.5  0.75 1.  ]
linspace(0, np.pi, 4): [0.         1.04719755 2.0943951  3.14159265]
zeros(3): [0. 0. 0.]
zeros((2,3)):
[[0. 0. 0.]
 [0. 0. 0.]]
ones((2,2)):
[[1. 1.]
 [1. 1.]]
eye(3):
[[1. 0. 0.]
 [0. 1. 0.]
 [0. 0. 1.]]
random.rand(3): [0.456 0.782 0.123]
random.randint(0, 10, 5): [3 7 2 9 1]
random.randn(3): [0.123 -0.456 1.789]
empty((3,3)):
[[... ... ...]
 [... ... ...]
 [... ... ...]]''',
          ),
          const TipBox(
            'NumPy 的索引从 0 开始，支持切片操作 arr[1:3] 和花式索引 arr[[0, 2, 4]]。'
            '布尔索引 arr[arr > 3] 可以根据条件筛选元素。'
            '熟练掌握 NumPy 是学习 pandas 和机器学习的基础。',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.5 pandas — 数据分析
          // ==========================================
          const SectionHeader('21.5 pandas — 数据分析库', icon: Icons.table_chart),
          const Paragraph(
            'pandas 是 Python 最核心的数据分析库，提供了两种主要数据结构：'
            'Series（一维标签数组）和 DataFrame（二维表格数据）。'
            'pandas 让数据读取、清洗、转换、分析和可视化变得异常高效，'
            '是数据科学工作流程中不可或缺的工具。',
          ),
          const TipBox(
            '安装 pandas：pip install pandas\n'
            '导入约定：import pandas as pd',
            type: TipType.info,
          ),
          const DividerLine(),

          // Series
          const Paragraph(
            '1. Series — 一维序列\n'
            'Series 类似于带标签的一维数组，由索引（index）和值（values）组成。'
            '可以从列表、字典或 NumPy 数组创建。'
            '通过标签访问数据，支持向量化运算和缺失数据处理。',
          ),
          const CodeBlock(
            r'''import pandas as pd

# 从列表创建 Series（默认整数索引）
s1 = pd.Series([10, 20, 30, 40])
print('从列表创建:')
print(s1)
print('值:', s1.values)
print('索引:', s1.index)

# 指定索引
s2 = pd.Series([10, 20, 30, 40], index=['a', 'b', 'c', 'd'])
print('\n指定索引:')
print(s2)

# 从字典创建（键自动成为索引）
s3 = pd.Series({'Alice': 85, 'Bob': 92, 'Charlie': 78})
print('\n从字典创建:')
print(s3)

# 访问数据
print('\n访问数据:')
print('s2[b]:', s2['b'])
print('s2[0]:', s2[0])
print('s2[b:d]:')
print(s2['b':'d'])

# 运算
print('s2 * 2:')
print(s2 * 2)
print('s2 > 25:')
print(s2 > 25)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''从列表创建:
0    10
1    20
2    30
3    40
dtype: int64
值: [10 20 30 40]
索引: RangeIndex(start=0, stop=4, step=1)

指定索引:
a    10
b    20
c    30
d    40
dtype: int64

从字典创建:
Alice      85
Bob        92
Charlie    78
dtype: int64

访问数据:
s2[b]: 20
s2[0]: 20
s2[b:d]:
b    20
c    30
d    40
dtype: int64
s2 * 2:
a    20
b    40
c    60
d    80
dtype: int64
s2 > 25:
a    False
b    False
c     True
d     True
dtype: bool''',
          ),

          // DataFrame 创建
          const DividerLine(),
          const Paragraph(
            '2. DataFrame — 二维表格\n'
            'DataFrame 是 pandas 的核心数据结构，类似于电子表格或 SQL 表。'
            '可以从字典、列表、NumPy 数组或 CSV 文件创建。'
            '每列可以是不同的数据类型，每行有唯一的索引标签。',
          ),
          const CodeBlock(
            r'''import pandas as pd

# 从字典创建 DataFrame
data = {
    '姓名': ['Alice', 'Bob', 'Charlie', 'David'],
    '年龄': [25, 30, 35, 28],
    '城市': ['北京', '上海', '深圳', '广州'],
    '薪资': [15000, 20000, 25000, 18000],
}
df = pd.DataFrame(data)
print('从字典创建:')
print(df)
print()

# 指定列顺序
df2 = pd.DataFrame(data, columns=['姓名', '城市', '年龄', '薪资'])
print('指定列顺序:')
print(df2)
print()

# 指定行索引
df3 = pd.DataFrame(data, index=['A', 'B', 'C', 'D'])
print('指定行索引:')
print(df3)
print()

# 从列表的列表创建
data_list = [
    ['Alice', 25, '北京'],
    ['Bob', 30, '上海'],
    ['Charlie', 35, '深圳'],
]
df4 = pd.DataFrame(data_list, columns=['姓名', '年龄', '城市'])
print('从嵌套列表创建:')
print(df4)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''从字典创建:
       姓名  年龄   城市    薪资
0    Alice  25   北京  15000
1      Bob  30   上海  20000
2  Charlie  35   深圳  25000
3    David  28   广州  18000

指定列顺序:
       姓名   城市  年龄    薪资
0    Alice   北京  25  15000
1      Bob   上海  30  20000
2  Charlie   深圳  35  25000
3    David   广州  28  18000

指定行索引:
       姓名  年龄   城市    薪资
A    Alice  25   北京  15000
B      Bob  30   上海  20000
C  Charlie  35   深圳  25000
D    David  28   广州  18000

从嵌套列表创建:
       姓名  年龄   城市
0    Alice  25   北京
1      Bob  30   上海
2  Charlie  35   深圳''',
          ),

          // 读取 CSV/Excel
          const DividerLine(),
          const Paragraph(
            '3. 读取 CSV 和 Excel 文件\n'
            'pd.read_csv() 读取 CSV 文件，常用参数：filepath、sep（分隔符）、'
            'encoding（编码）、header（表头行）、index_col（索引列）。'
            'pd.read_excel() 读取 Excel 文件，需安装 openpyxl 或 xlrd。'
            'pandas 还支持读取 JSON、SQL、HTML 等多种格式。',
          ),
          const CodeBlock(
            r'''import pandas as pd

# 读取 CSV 文件
# df = pd.read_csv('data.csv')
# print(df.head())

# 读取 CSV 常用参数
# df = pd.read_csv(
#     'data.csv',
#     sep=',',              # 分隔符
#     encoding='utf-8',     # 编码
#     header=0,             # 表头在第0行
#     index_col='ID',       # 将ID列设为索引
#     na_values=['NA', ''], # 缺失值标记
#     parse_dates=['日期'],  # 自动解析日期
# )

# 读取 Excel 文件
# df = pd.read_excel('data.xlsx', sheet_name='Sheet1')
# print(df.head())

# 演示：从 CSV 字符串读取
from io import StringIO
csv_data = StringIO("""
姓名,年龄,城市,薪资
Alice,25,北京,15000
Bob,30,上海,20000
Charlie,35,深圳,25000
""")
df = pd.read_csv(csv_data)
print('从 CSV 字符串读取:')
print(df)
print()
print('列名:', df.columns.tolist())
print('形状:', df.shape)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''从 CSV 字符串读取:
       姓名  年龄   城市    薪资
0    Alice  25   北京  15000
1      Bob  30   上海  20000
2  Charlie  35   深圳  25000

列名: ['姓名', '年龄', '城市', '薪资']
形状: (3, 4)''',
          ),

          // 数据查看
          const DividerLine(),
          const Paragraph(
            '4. 数据查看与基本信息\n'
            '.head(n) 查看前 n 行，.tail(n) 查看后 n 行。'
            '.info() 显示数据集的列信息、非空数量、数据类型和内存使用。'
            '.describe() 对数值列进行统计描述（计数、均值、标准差、分位数等）。'
            '.shape 返回行数和列数。',
          ),
          const CodeBlock(
            r'''import pandas as pd
import numpy as np

# 创建示例数据集
np.random.seed(42)
data = {
    'A': np.random.randint(1, 100, 20),
    'B': np.random.randn(20),
    'C': np.random.choice(['X', 'Y', 'Z'], 20),
    'D': np.random.rand(20) * 100,
}
df = pd.DataFrame(data)

# head() 和 tail()
print('前5行:')
print(df.head())
print('\n后3行:')
print(df.tail(3))

# info() 基本信息
print('\n数据集信息:')
print(df.info())

# describe() 统计描述
print('\n数值列统计描述:')
print(df.describe())

# 基本属性
print('\n形状:', df.shape)
print('列名:', df.columns.tolist())
print('行索引范围:', df.index.min(), '-', df.index.max())
print('数据类型:\n', df.dtypes)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''前5行:
    A         B  C          D
0  52  0.496714  X  54.495919
1  93 -0.138264  Y  98.210035
2  15  0.647689  Z  60.789989
3  72  0.978618  X  86.193659
4  61  1.523030  Y  90.588868

后3行:
     A         B  C          D
17  77  0.144044  Z  70.530427
18  65  2.454273  X  48.576618
19  38  0.761038  Y  33.023297

数据集信息:
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 20 entries, 0 to 19
Data columns (total 4 columns):
 #   Column  Non-Null Count  Dtype
---  ------  --------------  -----
 0   A       20 non-null     int64
 1   B       20 non-null     float64
 2   C       20 non-null     object
 3   D       20 non-null     float64
dtypes: float64(2), int64(1), object(1)
memory usage: 768.0 bytes
None

数值列统计描述:
               A         B          D
count  20.000000  20.00000  20.000000
mean   53.250000   0.70392  61.302496
std    23.749431   1.07627  28.126367
min    13.000000  -0.54438  11.808478
25%    35.000000  -0.12683  33.594212
50%    57.000000   0.75797  66.765651
75%    70.500000   1.24722  86.193659
max    93.000000   2.45427  98.210035

形状: (20, 4)
列名: ['A', 'B', 'C', 'D']
行索引范围: 0 - 19
数据类型:
 A     int64
B    float64
C     object
D    float64
dtype: object''',
          ),

          // 数据筛选
          const DividerLine(),
          const Paragraph(
            '5. 数据筛选与过滤\n'
            'pandas 提供了灵活的数据筛选方式：布尔索引、'
            'loc（基于标签的索引）、iloc（基于整数位置的索引）。'
            '还可以使用 query() 方法进行类 SQL 查询。',
          ),
          const CodeBlock(
            r'''import pandas as pd

data = {
    '姓名': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    '年龄': [25, 30, 35, 28, 22],
    '城市': ['北京', '上海', '深圳', '北京', '上海'],
    '薪资': [15000, 20000, 25000, 18000, 12000],
}
df = pd.DataFrame(data)

# 布尔索引 - 筛选年龄大于 28 的
print('年龄 > 28:')
print(df[df['年龄'] > 28])
print()

# 多条件筛选
print('年龄 > 25 且 薪资 > 15000:')
print(df[(df['年龄'] > 25) & (df['薪资'] > 15000)])
print()

# loc - 基于标签
print('loc 筛选行1-2，列姓名-年龄:')
print(df.loc[1:2, '姓名':'年龄'])
print()

# iloc - 基于整数位置
print('iloc 筛选前3行前2列:')
print(df.iloc[:3, :2])
print()

# query - 类SQL查询
print('query 筛选:')
print(df.query('年龄 >= 30 and 城市 == "上海"'))
print()

# 选择列
print('选择单列:', df['姓名'].tolist())
print('选择多列:')
print(df[['姓名', '薪资']])''',
            language: 'Python',
          ),
          const OutputBox(
            r'''年龄 > 28:
       姓名  年龄  城市    薪资
1      Bob  30  上海  20000
2  Charlie  35  深圳  25000

年龄 > 25 且 薪资 > 15000:
       姓名  年龄  城市    薪资
1      Bob  30  上海  20000
2  Charlie  35  深圳  25000
3    David  28  北京  18000

loc 筛选行1-2，列姓名-年龄:
       姓名  年龄
1      Bob  30
2  Charlie  35

iloc 筛选前3行前2列:
       姓名  年龄
0    Alice  25
1      Bob  30
2  Charlie  35

query 筛选:
   姓名  年龄  城市    薪资
1  Bob  30  上海  20000

选择单列: ['Alice', 'Bob', 'Charlie', 'David', 'Eve']
选择多列:
       姓名    薪资
0    Alice  15000
1      Bob  20000
2  Charlie  25000
3    David  18000
4      Eve  12000''',
          ),

          // groupby 分组
          const DividerLine(),
          const Paragraph(
            '6. groupby 分组聚合\n'
            'groupby() 按指定列分组，然后对每组进行聚合运算。'
            '支持多种聚合函数：mean()、sum()、count()、max()、min()、'
            'std()、var() 等。也可以使用 agg() 方法同时进行多种聚合。',
          ),
          const CodeBlock(
            r'''import pandas as pd

data = {
    '部门': ['技术', '市场', '技术', '市场', '技术', '人事'],
    '姓名': ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank'],
    '薪资': [15000, 18000, 22000, 16000, 20000, 14000],
    '年龄': [25, 30, 35, 28, 27, 32],
}
df = pd.DataFrame(data)
print('原始数据:')
print(df)
print()

# 按部门分组计算平均薪资
print('各部门平均薪资:')
print(df.groupby('部门')['薪资'].mean())
print()

# 多列聚合
print('各部门薪资统计:')
print(df.groupby('部门')['薪资'].agg(['mean', 'sum', 'max', 'min', 'count']))
print()

# 多列不同聚合
print('各部门多维度统计:')
stats = df.groupby('部门').agg({
    '薪资': 'mean',
    '年龄': 'mean',
    '姓名': 'count',
})
print(stats)
print()

# 遍历分组
print('遍历分组:')
for dept, group in df.groupby('部门'):
    print(f'\n部门: {dept}')
    print(group[['姓名', '薪资']])''',
            language: 'Python',
          ),
          const OutputBox(
            r'''原始数据:
   部门     姓名    薪资  年龄
0  技术    Alice  15000  25
1  市场      Bob  18000  30
2  技术  Charlie  22000  35
3  市场    David  16000  28
4  技术      Eve  20000  27
5  人事    Frank  14000  32

各部门平均薪资:
部门
人事    14000.0
市场    17000.0
技术    19000.0
Name: 薪资, dtype: float64

各部门薪资统计:
      mean    sum    max    min  count
部门
人事  14000.0  14000  14000  14000      1
市场  17000.0  34000  18000  16000      2
技术  19000.0  57000  22000  15000      3

各部门多维度统计:
       薪资    年龄  姓名
部门
人事  14000.0  32.0    1
市场  17000.0  29.0    2
技术  19000.0  29.0    3

遍历分组:

部门: 人事
    姓名    薪资
5  Frank  14000

部门: 市场
    姓名    薪资
1    Bob  18000
3  David  16000

部门: 技术
      姓名    薪资
0    Alice  15000
2  Charlie  22000
4      Eve  20000''',
          ),
          const TipBox(
            'pandas 的数据筛选推荐使用 .loc 和 .iloc 方法，'
            '链式操作时使用 .copy() 避免 SettingWithCopyWarning 警告。'
            '处理大型数据集时可以分块读取：pd.read_csv("file.csv", chunksize=10000)',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.6 matplotlib — 数据可视化
          // ==========================================
          const SectionHeader('21.6 matplotlib — 数据可视化库', icon: Icons.bar_chart),
          const Paragraph(
            'Matplotlib 是 Python 最经典的数据可视化库，可以生成各种静态、'
            '动态和交互式图表。它的设计类似 MATLAB 的绘图系统，'
            '提供了线图、散点图、柱状图、直方图、饼图等丰富的图表类型。'
            'pyplot 模块提供了类似 MATLAB 的简洁 API。',
          ),
          const TipBox(
            '安装 matplotlib：pip install matplotlib\n'
            '导入约定：import matplotlib.pyplot as plt\n'
            '在 Jupyter Notebook 中需执行 %matplotlib inline 以在单元格内显示图表。',
            type: TipType.info,
          ),
          const DividerLine(),

          // 折线图
          const Paragraph(
            '1. 折线图 — plot()\n'
            'plt.plot(x, y, format_string, **kwargs) 绘制折线图。'
            'format_string 指定颜色、线型和标记样式，如 r-- 表示红色虚线。'
            '可以同时绘制多条曲线，plt.legend() 添加图例。',
          ),
          const CodeBlock(
            r'''import matplotlib.pyplot as plt
import numpy as np

# 数据准备
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

# 绘制折线图
plt.figure(figsize=(10, 6))
plt.plot(x, y1, 'b-', label='sin(x)', linewidth=2)
plt.plot(x, y2, 'r--', label='cos(x)', linewidth=2)

# 添加标签和标题
plt.xlabel('X 轴', fontsize=12)
plt.ylabel('Y 轴', fontsize=12)
plt.title('正弦和余弦曲线', fontsize=14)
plt.legend()
plt.grid(True, alpha=0.3)

# 设置坐标轴范围
plt.xlim(0, 10)
plt.ylim(-1.5, 1.5)

plt.show()

# 保存图表
# plt.savefig('sine_cosine.png', dpi=300, bbox_inches='tight')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[显示一个包含蓝色正弦曲线和红色虚线余弦曲线的折线图，
 X轴标签为"X 轴"，Y轴标签为"Y 轴"，
 标题为"正弦和余弦曲线"，包含图例和网格]''',
          ),

          // 散点图
          const DividerLine(),
          const Paragraph(
            '2. 散点图 — scatter()\n'
            'plt.scatter(x, y, s, c, marker, alpha) 绘制散点图。'
            's 控制点的大小，c 控制颜色，marker 控制标记样式，'
            'alpha 控制透明度。散点图适合展示两个变量之间的关系。',
          ),
          const CodeBlock(
            r'''import matplotlib.pyplot as plt
import numpy as np

# 生成随机数据
np.random.seed(42)
n = 100
x = np.random.randn(n)
y = 2 * x + np.random.randn(n) * 0.5
colors = np.random.rand(n)
sizes = np.random.randint(20, 200, n)

plt.figure(figsize=(10, 6))

# 散点图
scatter = plt.scatter(
    x, y,
    c=colors,
    s=sizes,
    alpha=0.7,
    cmap='viridis',
    marker='o',
    edgecolors='black',
    linewidth=0.5,
)

# 颜色条
plt.colorbar(scatter, label='颜色值')

plt.xlabel('X 变量', fontsize=12)
plt.ylabel('Y 变量', fontsize=12)
plt.title('散点图示例', fontsize=14)
plt.grid(True, alpha=0.3)
plt.show()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[显示一个散点图，点的大小和颜色各不相同，
 颜色使用 viridis 色图，点边缘为黑色，
 右侧显示颜色条，X/Y 轴有标签，有标题和网格]''',
          ),

          // 柱状图
          const DividerLine(),
          const Paragraph(
            '3. 柱状图 — bar()\n'
            'plt.bar(x, height, width, color) 绘制垂直柱状图。'
            'plt.barh(y, width, height, color) 绘制水平柱状图。'
            '适合展示分类数据的对比，可以通过并列或堆叠展示多组数据。',
          ),
          const CodeBlock(
            r'''import matplotlib.pyplot as plt
import numpy as np

# 数据
categories = ['A', 'B', 'C', 'D', 'E']
values1 = [23, 45, 56, 78, 33]
values2 = [18, 35, 48, 62, 28]

# 垂直柱状图
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
x = np.arange(len(categories))
width = 0.35

bars1 = plt.bar(x - width/2, values1, width, label='组1', color='steelblue')
bars2 = plt.bar(x + width/2, values2, width, label='组2', color='coral')

plt.xlabel('类别', fontsize=12)
plt.ylabel('数值', fontsize=12)
plt.title('并列柱状图', fontsize=14)
plt.xticks(x, categories)
plt.legend()

# 在柱子上显示数值
for bar in bars1:
    plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
             str(int(bar.get_height())), ha='center', fontsize=10)
for bar in bars2:
    plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
             str(int(bar.get_height())), ha='center', fontsize=10)

# 水平柱状图
plt.subplot(1, 2, 2)
plt.barh(categories, values1, color='steelblue')
plt.xlabel('数值', fontsize=12)
plt.ylabel('类别', fontsize=12)
plt.title('水平柱状图', fontsize=14)

plt.tight_layout()
plt.show()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[显示两个子图：左侧为并列柱状图展示两组数据对比，
 柱子上显示具体数值；右侧为水平柱状图展示单组数据]''',
          ),

          // 直方图
          const DividerLine(),
          const Paragraph(
            '4. 直方图 — hist()\n'
            'plt.hist(x, bins, density, cumulative, color) 绘制直方图。'
            'bins 控制分组数量，density=True 显示概率密度，'
            'cumulative=True 显示累积分布。直方图适合展示数据分布特征。',
          ),
          const CodeBlock(
            r'''import matplotlib.pyplot as plt
import numpy as np

# 生成正态分布和均匀分布数据
np.random.seed(42)
normal_data = np.random.randn(1000)
uniform_data = np.random.rand(1000)

plt.figure(figsize=(12, 5))

# 普通直方图
plt.subplot(1, 2, 1)
plt.hist(normal_data, bins=30, color='steelblue', edgecolor='white', alpha=0.7)
plt.xlabel('数值', fontsize=12)
plt.ylabel('频数', fontsize=12)
plt.title('正态分布直方图', fontsize=14)
plt.grid(True, alpha=0.3)

# 多个分布对比
plt.subplot(1, 2, 2)
plt.hist(normal_data, bins=30, alpha=0.6, label='正态分布', color='steelblue')
plt.hist(uniform_data, bins=30, alpha=0.6, label='均匀分布', color='coral')
plt.xlabel('数值', fontsize=12)
plt.ylabel('频数', fontsize=12)
plt.title('多个分布对比', fontsize=14)
plt.legend()
plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# 概率密度直方图
plt.figure(figsize=(8, 5))
plt.hist(normal_data, bins=30, density=True, alpha=0.7,
         color='steelblue', edgecolor='white', label='概率密度')

# 绘制理论正态分布曲线
x = np.linspace(-4, 4, 100)
y = 1/(np.sqrt(2*np.pi)) * np.exp(-x**2/2)
plt.plot(x, y, 'r-', linewidth=2, label='理论曲线')

plt.xlabel('数值', fontsize=12)
plt.ylabel('概率密度', fontsize=12)
plt.title('概率密度直方图与理论曲线', fontsize=14)
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[显示三个子图：
 1. 正态分布直方图（30个分组，蓝色柱状）
 2. 正态分布和均匀分布对比直方图
 3. 概率密度直方图叠加理论正态分布曲线]''',
          ),

          // 图表装饰与保存
          const DividerLine(),
          const Paragraph(
            '5. 图表装饰与保存\n'
            'plt.xlabel()、plt.ylabel() 设置坐标轴标签。'
            'plt.title() 设置图表标题。plt.legend() 显示图例。'
            'plt.grid() 显示网格。plt.savefig() 保存图表到文件。'
            'plt.figure(figsize=(w, h)) 设置图表尺寸。'
            'plt.subplot() 在同一个图中创建多个子图。',
          ),
          const CodeBlock(
            r'''import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 2 * np.pi, 100)
y1 = np.sin(x)
y2 = np.cos(x)

plt.figure(figsize=(10, 6))

# 绘制图表
plt.plot(x, y1, 'b-', label='sin(x)', linewidth=2)
plt.plot(x, y2, 'r--', label='cos(x)', linewidth=2)

# 图表装饰
plt.xlabel('角度 (弧度)', fontsize=13, fontweight='bold')
plt.ylabel('函数值', fontsize=13, fontweight='bold')
plt.title('正弦与余弦函数', fontsize=16, fontweight='bold')
plt.legend(fontsize=12, loc='upper right', framealpha=0.9)
plt.grid(True, linestyle='--', alpha=0.5)

# 添加注释
plt.annotate('峰值', xy=(np.pi/2, 1), xytext=(np.pi/2, 1.3),
             arrowprops=dict(arrowstyle='->', color='black'),
             fontsize=11, ha='center')

# 添加水平参考线
plt.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
plt.axvline(x=np.pi, color='green', linestyle=':', alpha=0.5, label='x=pi')
plt.legend()

# 设置坐标轴范围
plt.xlim(0, 2 * np.pi)
plt.ylim(-1.5, 1.5)

# 保存图表（支持多种格式）
plt.savefig('trig_functions.png', dpi=300, bbox_inches='tight')
print('已保存 PNG 格式')

plt.savefig('trig_functions.pdf', bbox_inches='tight')
print('已保存 PDF 格式')

plt.savefig('trig_functions.svg', bbox_inches='tight')
print('已保存 SVG 格式')

plt.show()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''已保存 PNG 格式
已保存 PDF 格式
已保存 SVG 格式
[显示一个包含正弦和余弦曲线的图表，有标题、标签、图例、
 网格、注释和参考线]''',
          ),
          const TipBox(
            'Matplotlib 支持保存为 PNG、PDF、SVG、EPS 等多种格式。'
            'dpi 参数控制分辨率，bbox_inches="tight" 自动去除多余空白。'
            '中文显示问题可通过 plt.rcParams["font.sans-serif"] = ["SimHei"] 解决。',
            type: TipType.tip,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.7 tqdm — 进度条
          // ==========================================
          const SectionHeader('21.7 tqdm — 进度条库', icon: Icons.hourglass_bottom),
          const Paragraph(
            'tqdm 是 Python 中最流行的进度条库，名字来自阿拉伯语 taqaddum（意为"进展"）。'
            '它可以为任何可迭代对象自动显示进度条，'
            '包括循环迭代时间、剩余时间、速率等信息。'
            '只需在迭代器外层包裹 tqdm() 即可。',
          ),
          const TipBox(
            '安装 tqdm：pip install tqdm\n'
            '导入方式：from tqdm import tqdm',
            type: TipType.info,
          ),
          const DividerLine(),

          // 基本用法
          const Paragraph(
            '1. 基本用法\n'
            'tqdm(iterable) 包装任意可迭代对象，自动显示进度条。'
            '支持列表、range、文件行等所有可迭代类型。'
            '进度条自动显示完成百分比、已用时间、预计剩余时间和迭代速率。',
          ),
          const CodeBlock(
            r'''from tqdm import tqdm
import time

# 基本用法 - 包装 range
print('基本进度条:')
for i in tqdm(range(100)):
    time.sleep(0.01)  # 模拟耗时操作

# 包装列表
print('\n处理列表:')
items = ['文件1.txt', '文件2.txt', '文件3.txt', '文件4.txt', '文件5.txt']
for item in tqdm(items):
    time.sleep(0.2)  # 模拟处理每个文件

# 包装文件行
# from tqdm import tqdm
# with open('large_file.txt', 'r') as f:
#     for line in tqdm(f, desc='读取文件'):
#         process(line)

# 手动更新进度条
print('\n手动更新:')
pbar = tqdm(total=50)
for i in range(50):
    time.sleep(0.02)
    pbar.update(1)  # 每次更新1步
pbar.close()''',
            language: 'Python',
          ),
          const OutputBox(
            r'''基本进度条:
100%|████████████████████| 100/100 [00:01<00:00, 98.56it/s]

处理列表:
100%|████████████████████| 5/5 [00:01<00:00,  4.99it/s]

手动更新:
100%|████████████████████| 50/50 [00:01<00:00, 49.85it/s]''',
          ),

          // 自定义描述
          const DividerLine(),
          const Paragraph(
            '2. 自定义描述信息\n'
            'desc 参数设置进度条前缀描述文字。'
            'leave 参数控制进度条完成后是否保留（True 保留 / False 消失）。'
            'position 参数设置进度条在终端中的行位置。'
            'ncols 参数设置进度条的宽度。',
          ),
          const CodeBlock(
            r'''from tqdm import tqdm
import time

# 带描述的进度条
print('带描述的进度条:')
for i in tqdm(range(80), desc='下载进度', leave=True):
    time.sleep(0.02)

# 不同描述
print('\n多个阶段:')
for i in tqdm(range(60), desc='数据加载', leave=True):
    time.sleep(0.02)

for i in tqdm(range(40), desc='数据处理', leave=True):
    time.sleep(0.03)

for i in tqdm(range(20), desc='保存结果', leave=True):
    time.sleep(0.05)

# 设置进度条宽度
print('\n自定义宽度:')
for i in tqdm(range(50), desc='宽进度条', ncols=100):
    time.sleep(0.02)

# 不保留进度条（完成后消失）
print('\n不保留进度条:')
for i in tqdm(range(30), desc='临时任务', leave=False):
    time.sleep(0.03)
print('进度条已消失')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''带描述的进度条:
下载进度: 100%|████████████████████| 80/80 [00:01<00:00, 49.87it/s]

多个阶段:
数据加载: 100%|████████████████████| 60/60 [00:01<00:00, 49.85it/s]
数据处理: 100%|████████████████████| 40/40 [00:01<00:00, 33.22it/s]
保存结果: 100%|████████████████████| 20/20 [00:01<00:00, 19.98it/s]

自定义宽度:
宽进度条:  50%|█████████████████           | 25/50 [00:00<00:00, 49.87it/s]''',
          ),

          // 进阶用法
          const DividerLine(),
          const Paragraph(
            '3. 进阶用法\n'
            'tqdm 还支持嵌套进度条、设置单位、自定义格式、'
            '在 Jupyter Notebook 中显示等高级功能。'
            'postfix 参数可以在进度条末尾显示动态信息。',
          ),
          const CodeBlock(
            r'''from tqdm import tqdm
import time

# 嵌套进度条
print('嵌套进度条（外层 + 内层）:')
for i in tqdm(range(5), desc='外层循环'):
    for j in tqdm(range(20), desc='内层循环', leave=False):
        time.sleep(0.01)

# 显示动态信息
print('\n动态信息:')
pbar = tqdm(range(50), desc='处理')
for i in pbar:
    # 更新后缀信息
    pbar.set_postfix({'当前值': i, '状态': '运行中'})
    time.sleep(0.02)
pbar.set_postfix({'状态': '完成'})
pbar.close()

# 自定义单位
print('\n自定义单位:')
from tqdm import tqdm
for i in tqdm(range(100), desc='下载', unit='B', unit_scale=True):
    time.sleep(0.01)

# 使用 trange 简写
from tqdm import trange
print('\ntrange 简写:')
for i in trange(50, desc='简写形式'):
    time.sleep(0.02)''',
            language: 'Python',
          ),
          const OutputBox(
            r'''嵌套进度条（外层 + 内层）:
外层循环: 100%|████████████████████| 5/5 [00:01<00:00,  4.98it/s]

动态信息:
处理: 100%|████████████████████| 50/50 [00:01<00:00, 49.85it/s, 当前值=49, 状态=完成]

自定义单位:
下载: 100%|████████████████████| 100/100 [00:01<00:00, 98.56B/s]

trange 简写:
简写形式: 100%|████████████████████| 50/50 [00:01<00:00, 49.85it/s]''',
          ),

          // Jupyter 支持
          const DividerLine(),
          const Paragraph(
            '4. Jupyter Notebook 支持\n'
            'tqdm.notebook 模块提供了针对 Jupyter Notebook 优化的进度条组件，'
            '具有更美观的视觉样式和更丰富的交互功能。',
          ),
          const CodeBlock(
            r'''from tqdm.notebook import tqdm
import time

# 注意：以下代码在 Jupyter Notebook 中运行
# tqdm.notebook 会自动检测环境，pyCharm 等 IDE 也可使用

# 基本使用（和标准 tqdm 完全一致）
for i in tqdm(range(100), desc='Jupyter 进度条'):
    time.sleep(0.01)

# 手动控制
with tqdm(total=50, desc='手动控制') as pbar:
    for i in range(50):
        time.sleep(0.02)
        pbar.update(1)
        pbar.set_postfix({'进度': f'{i+1}/50'})

# 在标准 Python 环境中也可以使用
# from tqdm import tqdm  # 自动选择合适版本
# 在 Notebook 中，tqdm.notebook.tqdm 会覆盖标准 tqdm''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[在 Jupyter Notebook 中显示带有 HTML/CSS 样式的彩色进度条]''',
          ),
          const TipBox(
            'tqdm 在 Jupyter Notebook 中可能会与标准输出产生冲突。'
            '解决方法：在 Notebook 开头执行 from tqdm import tqdm，'
            '或者使用 tqdm.notebook.tqdm 获得更好的 Notebook 体验。',
            type: TipType.caution,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 21.8 python-dotenv — 环境变量管理
          // ==========================================
          const SectionHeader('21.8 python-dotenv — 环境变量管理库', icon: Icons.settings_applications),
          const Paragraph(
            'python-dotenv 是一个轻量级的环境变量管理库，'
            '它可以从 .env 文件中读取配置到环境变量中。'
            '这使得敏感信息（如数据库密码、API 密钥）可以独立于代码管理，'
            '是 12-Factor App 方法论中"配置与环境分离"原则的最佳实践。',
          ),
          const TipBox(
            '安装 python-dotenv：pip install python-dotenv',
            type: TipType.info,
          ),
          const DividerLine(),

          // 基本使用
          const Paragraph(
            '1. 创建 .env 文件\n'
            '在项目根目录创建 .env 文件，每行一个 KEY=VALUE 格式的配置项。'
            '字符串值不需要引号，注释以 # 开头。'
            '.env 文件应添加到 .gitignore 中以避免敏感信息泄露。',
          ),
          const CodeBlock(
            r'''# .env 文件示例
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASSWORD=secret123

# API 密钥
API_KEY=sk-abcdefghijklmnopqrst
API_SECRET=abc123def456ghi789

# 应用配置
DEBUG=True
APP_ENV=development
SECRET_KEY=your-secret-key-here

# 第三方服务
REDIS_URL=redis://localhost:6379/0
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587''',
            language: 'Python',
          ),
          const OutputBox(
            r'''[.env 文件内容，包含数据库配置、API密钥和应用配置]''',
          ),

          // load_dotenv 和 os.getenv
          const DividerLine(),
          const Paragraph(
            '2. 加载与读取环境变量\n'
            'load_dotenv() 函数加载 .env 文件中的配置到 os.environ 环境变量中。'
            'os.getenv(key, default) 读取环境变量值，第二个参数指定默认值。'
            'os.environ.get(key) 也可以读取，但 getenv 语法更简洁。'
            'dotenv_values() 可以读取 .env 文件而不注入到环境变量中。',
          ),
          const CodeBlock(
            r'''from dotenv import load_dotenv, dotenv_values
import os

# 加载 .env 文件（默认在当前目录查找）
load_dotenv()
print('环境变量已加载')

# 读取环境变量
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')

print('数据库配置:')
print(f'  主机: {db_host}')
print(f'  端口: {db_port}')
print(f'  数据库: {db_name}')
print(f'  用户: {db_user}')
print(f'  密码: {"*" * len(db_password) if db_password else "未设置"}')

# 使用默认值
debug = os.getenv('DEBUG', 'False')
print(f'\n调试模式: {debug}')

# 读取 API 密钥
api_key = os.getenv('API_KEY')
print(f'API密钥: {api_key[:10]}...' if api_key else 'API密钥未设置')

# dotenv_values() 不注入到环境变量
config = dotenv_values('.env')
print(f'\ndotenv_values 读取到的键: {list(config.keys())}')
print(f'应用环境: {config.get("APP_ENV")}')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''环境变量已加载
数据库配置:
  主机: localhost
  端口: 5432
  数据库: myapp
  用户: admin
  密码: *******
调试模式: True
API密钥: sk-abcdefg...
dotenv_values 读取到的键: ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'API_KEY', 'API_SECRET', 'DEBUG', 'APP_ENV', 'SECRET_KEY', 'REDIS_URL', 'EMAIL_HOST', 'EMAIL_PORT']
应用环境: development''',
          ),

          // 进阶用法
          const DividerLine(),
          const Paragraph(
            '3. 进阶用法\n'
            'load_dotenv() 支持指定 .env 文件路径，覆盖已有环境变量，'
            '以及处理多个 .env 文件的优先级。'
            '还有 find_dotenv() 函数可以自动查找项目根目录的 .env 文件。',
          ),
          const CodeBlock(
            r'''from dotenv import load_dotenv, find_dotenv
import os

# 自动查找 .env 文件（从当前目录向上搜索）
dotenv_path = find_dotenv()
print('找到 .env 文件:', dotenv_path)

# 加载指定路径的 .env 文件
load_dotenv(dotenv_path, override=True)
print('已重新加载环境变量')

# 加载不同的环境配置文件
# 开发环境
load_dotenv('.env.development', override=True)
# 生产环境
# load_dotenv('.env.production', override=True)

# 多个 .env 文件的优先级用法
# .env.defaults  <-- 基础默认值（应提交到 Git）
# .env           <-- 本地覆盖（不提交到 Git）
# .env.local     <-- 本地特定（最高优先级）

# 读取环境变量并转换类型
debug = os.getenv('DEBUG', 'False').lower() == 'true'
port = int(os.getenv('PORT', '8000'))

print(f'调试模式: {debug}')
print(f'服务端口: {port}')

# 检查必要的环境变量
required_vars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD']
missing = [v for v in required_vars if not os.getenv(v)]
if missing:
    print(f'缺少必要的环境变量: {missing}')
else:
    print('所有必要的环境变量已设置')''',
            language: 'Python',
          ),
          const OutputBox(
            r'''找到 .env 文件: /path/to/project/.env
已重新加载环境变量
调试模式: True
服务端口: 8000
所有必要的环境变量已设置''',
          ),
          const TipBox(
            '安全建议：\n'
            '1. .env 文件包含敏感信息，务必添加到 .gitignore\n'
            '2. 提供 .env.example 模板文件，包含所有配置项但值为空\n'
            '3. 生产环境建议使用真正的环境变量（如 Docker/K8s），而非 .env 文件\n'
            '4. 不要将 .env 文件中的密码提交到任何版本控制系统',
            type: TipType.warning,
          ),
          const SizedBox(height: 16),

          // ==========================================
          // chardet — 字符编码检测
          // ==========================================
          const DividerLine(),
          const SectionHeader('chardet — 字符编码检测', icon: Icons.text_fields),
          const Paragraph(
            'chardet 是一个强大的字符编码检测库，可以自动识别文本文件的编码格式。'
            '它基于 Mozilla 的字符编码检测算法，支持 UTF-8、GB2312、Shift_JIS、'
            'Big5、ISO-8859-1 等多种编码。这在处理来源未知的文本文件时非常有用。',
          ),
          const Paragraph(
            '安装：pip install chardet\n'
            '使用方式：读取文件的二进制内容，传给 detect() 即可获得编码信息。',
          ),
          const CodeBlock(
            r'''import chardet

# 检测字节流的编码
data = b'\xe4\xb8\xad\xe6\x96\x87'  # "中文" 的 UTF-8 编码
result = chardet.detect(data)
print(result)
# 输出: {'encoding': 'utf-8', 'confidence': 0.9690625, 'language': ''}

# 检测文件编码
with open('unknown_file.txt', 'rb') as f:
    raw_data = f.read()
    result = chardet.detect(raw_data)
    print(f'编码: {result["encoding"]}')
    print(f'置信度: {result["confidence"]}')

# 根据检测结果正确读取文件
encoding = result['encoding'] if result['confidence'] > 0.7 else 'utf-8'
try:
    with open('unknown_file.txt', 'r', encoding=encoding) as f:
        content = f.read()
        print(content[:200])
except UnicodeDecodeError:
    print(f'使用 {encoding} 解码失败，尝试其他编码...')''',
            language: 'Python',
          ),
          const Paragraph(
            'chardet 的典型应用场景：\n'
            '1. 批量处理未知编码的文本文件\n'
            '2. 网页爬虫中检测响应内容的编码\n'
            '3. CSV/日志等文件导入时的编码预处理\n'
            '4. 文件编码格式转换（检测 → 解码 → 重新编码）',
          ),
          const CodeBlock(
            r'''# 批量检测目录下所有文本文件的编码
import os
import chardet

def detect_file_encoding(filepath: str) -> dict:
    with open(filepath, 'rb') as f:
        raw = f.read(10000)  # 通常读取前 10KB 就足够了
        return chardet.detect(raw)

def batch_detect(directory: str, extensions=('.txt', '.csv', '.log')):
    results = {}
    for filename in os.listdir(directory):
        if filename.endswith(extensions):
            path = os.path.join(directory, filename)
            result = detect_file_encoding(path)
            results[filename] = result
            print(f'{filename:30s} -> {result["encoding"]:15s} '
                  f'(置信度: {result["confidence"]:.2%})')
    return results

# 使用
batch_detect('./data_files')
# 输出示例:
# data_utf8.txt     -> utf-8           (置信度: 99.00%)
# data_gbk.csv      -> gb2312          (置信度: 87.50%)
# old_log.log       -> ISO-8859-1      (置信度: 73.00%)''',
            language: 'Python',
          ),
          const TipBox(
            'chardet 检测大文件时建议只读取前 10-100KB，效果基本不变但速度快很多。'
            '对于极短的文本（几字节），编码检测的置信度会很低，属于正常情况。',
            type: TipType.tip,
          ),

          // ==========================================
          // psutil — 系统监控
          // ==========================================
          const DividerLine(),
          const SectionHeader('psutil — 系统信息与进程管理', icon: Icons.monitor_heart),
          const Paragraph(
            'psutil（process and system utilities）是一个跨平台的系统监控库，'
            '可以获取 CPU、内存、磁盘、网络等信息，以及管理进程。'
            '它支持 Windows、macOS 和 Linux，API 统一，'
            '是系统管理工具和性能监控工具的首选库。',
          ),
          const Paragraph(
            '安装：pip install psutil\n'
            'psutil 提供了进程和系统两大类 API，覆盖了运维监控的常见需求。',
          ),
          const CodeBlock(
            r'''import psutil

# CPU 信息
print(f'CPU 物理核心数: {psutil.cpu_count(logical=False)}')
print(f'CPU 逻辑核心数: {psutil.cpu_count(logical=True)}')
print(f'CPU 使用率: {psutil.cpu_percent(interval=1)}%')
print(f'CPU 每核使用率: {psutil.cpu_percent(percpu=True)}')

# 内存信息
mem = psutil.virtual_memory()
print(f'内存总计: {mem.total / 1024**3:.1f} GB')
print(f'内存可用: {mem.available / 1024**3:.1f} GB')
print(f'内存使用率: {mem.percent}%')

# 磁盘信息
print(f'磁盘分区: {psutil.disk_partitions()}')
for part in psutil.disk_partitions():
    usage = psutil.disk_usage(part.mountpoint)
    print(f'  {part.device}: {usage.percent}% 已使用')

# 网络信息
net = psutil.net_io_counters()
print(f'发送字节: {net.bytes_sent / 1024**2:.1f} MB')
print(f'接收字节: {net.bytes_recv / 1024**2:.1f} MB')''',
            language: 'Python',
          ),
          const Paragraph(
            'psutil 还提供了强大的进程管理功能，可以列出、过滤和操作进程。',
          ),
          const CodeBlock(
            r'''import psutil

# 列出所有进程
for proc in psutil.process_iter(['pid', 'name', 'memory_percent']):
    try:
        print(f'PID: {proc.info["pid"]:6d} | '
              f'名称: {proc.info["name"]:20s} | '
              f'内存: {proc.info["memory_percent"]:.1f}%')
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass

# 按条件过滤进程（例如查找 Chrome 进程）
chrome_procs = [p for p in psutil.process_iter(['pid', 'name', 'cpu_percent'])
                if 'chrome' in p.info['name'].lower()]
print(f'\nChrome 进程数: {len(chrome_procs)}')
for p in chrome_procs:
    print(f'  PID: {p.info["pid"]} | CPU: {p.info["cpu_percent"]}%')

# 获取特定进程的详细信息
pid = 12345  # 替换为实际 PID
try:
    proc = psutil.Process(pid)
    print(f'进程名称: {proc.name()}')
    print(f'进程状态: {proc.status()}')
    print(f'CPU 使用率: {proc.cpu_percent()}%')
    print(f'内存使用: {proc.memory_info().rss / 1024**2:.1f} MB')
    print(f'创建时间: {proc.create_time()}')
    print(f'打开的文件: {len(proc.open_files())}')
except psutil.NoSuchProcess:
    print(f'进程 {pid} 不存在')''',
            language: 'Python',
          ),
          const Paragraph(
            'psutil 常用功能一览：\n'
            '1. sensors_temperatures() — 获取硬件温度（Linux/macOS）\n'
            '2. users() — 查看当前登录用户\n'
            '3. boot_time() — 系统启动时间\n'
            '4. net_connections() — 查看网络连接\n'
            '5. Process(pid).children() — 查看子进程\n'
            '6. Process(pid).terminate() — 终止进程',
          ),
          const CodeBlock(
            r'''# 制作一个简单的系统监控面板
import psutil
import time
from datetime import datetime

def system_monitor(duration: int = 10, interval: int = 2):
    """简单的系统监控器"""
    print(f'系统监控启动 ({duration} 秒, 每 {interval}s 刷新)')
    print('=' * 60)

    start = time.time()
    while time.time() - start < duration:
        now = datetime.now().strftime('%H:%M:%S')
        cpu = psutil.cpu_percent()
        mem = psutil.virtual_memory()
        disk = psutil.disk_usage('/')

        print(f'[{now}] CPU: {cpu:5.1f}% | '
              f'内存: {mem.percent:5.1f}% | '
              f'磁盘: {disk.percent:5.1f}%')

        time.sleep(interval)

# 运行
system_monitor(duration=6, interval=2)
# 输出示例:
# [10:30:01] CPU:  12.3% | 内存:  45.6% | 磁盘:  67.8%
# [10:30:03] CPU:   8.9% | 内存:  45.8% | 磁盘:  67.8%
# [10:30:05] CPU:  15.2% | 内存:  46.1% | 磁盘:  67.8%''',
            language: 'Python',
          ),
          const TipBox(
            'psutil 是系统监控工具最常用的 Python 库，搭配 matplotlib 可以实现'
            '图形化监控面板。生产环境中常用于编写自定义的健康检查脚本或'
            '发送告警（当 CPU/内存/磁盘超过阈值时）。',
            type: TipType.tip,
          ),

          const _PipPackageDemo(),
          const DividerLine(),

          // ==========================================
          // 总结
          // ==========================================
          const SectionHeader('本章总结', icon: Icons.summarize),
          const Paragraph(
            '本章介绍了 Python 生态中 10 个常用的第三方模块，它们覆盖了'
            'HTTP 通信、网页解析、图像处理、数值计算、数据分析、'
            '数据可视化、编码检测、系统监控和配置管理等常见开发需求。',
          ),
          const Paragraph(
            '各模块安装命令总结：\n'
            '  pip install requests              # HTTP 请求\n'
            '  pip install beautifulsoup4         # HTML 解析\n'
            '  pip install Pillow                 # 图像处理\n'
            '  pip install numpy                  # 数值计算\n'
            '  pip install pandas                 # 数据分析\n'
            '  pip install matplotlib             # 数据可视化\n'
            '  pip install tqdm                   # 进度条\n'
            '  pip install python-dotenv           # 环境变量管理\n'
            '  pip install chardet                # 编码检测\n'
            '  pip install psutil                 # 系统监控',
          ),
          const TipBox(
            '建议按照以下顺序学习：requests（最常用）-> beautifulsoup4（爬虫基础）'
            '-> numpy（数据基础）-> pandas（数据分析核心）-> matplotlib（可视化）'
            '-> Pillow（图像处理）-> tqdm（实用工具）-> python-dotenv（项目规范）'
            '-> chardet（编码检测）-> psutil（系统监控）。'
            '其中 numpy + pandas + matplotlib 是数据分析三件套，建议重点掌握。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
