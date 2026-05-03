import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Email 构建演示
class _EmailBuilderDemo extends StatefulWidget {
  const _EmailBuilderDemo();
  @override
  State<_EmailBuilderDemo> createState() => _EmailBuilderDemoState();
}

class _EmailBuilderDemoState extends State<_EmailBuilderDemo> {
  String _to = 'recipient@example.com';
  String _subject = '你好，来自Python!';
  String _body = '这是一封用 Python smtplib 发送的邮件。\n\n祝好！';
  bool _useHtml = false;
  bool _hasCc = false;
  String _cc = 'cc@example.com';

  String get _htmlBody => '<html><body>'
      '<h2>$_subject</h2>'
      '<p>${_body.replaceAll('\n', '<br>')}</p>'
      '<hr><small>由 Python smtplib 发送</small>'
      '</body></html>';

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '📧 邮件构建演示',
      subtitle: '填写邮件内容，观察 Python smtplib 的代码结构',
      children: [
        ParamTextField(label: '收件人 (To)', value: _to, onChanged: (v) => setState(() => _to = v), maxLength: 40),
        if (_hasCc)
          ParamTextField(label: '抄送 (CC)', value: _cc, onChanged: (v) => setState(() => _cc = v), maxLength: 40),
        ParamTextField(label: '主题 (Subject)', value: _subject, onChanged: (v) => setState(() => _subject = v), maxLength: 40),
        ParamTextField(label: '正文 (Body)', value: _body, onChanged: (v) => setState(() => _body = v), maxLength: 100),
        ParamSwitch(label: '使用 HTML 格式', value: _useHtml, onChanged: (v) => setState(() => _useHtml = v), trueLabel: 'HTML', falseLabel: '纯文本'),
        ParamSwitch(label: '添加抄送 (CC)', value: _hasCc, onChanged: (v) => setState(() => _hasCc = v), trueLabel: '是', falseLabel: '否'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('邮件预览:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('To: $_to', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_hasCc) Text('CC: $_cc', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            Text('Subject: $_subject', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            const Divider(height: 8),
            Text(_useHtml ? _htmlBody : _body, style: const TextStyle(fontSize: 12)),
          ]),
        ),
        LiveCodeBlock(
          'import smtplib\n'
          'from email.mime.${_useHtml ? 'text import MIMEText\nfrom email.mime.multipart import MIMEMultipart' : 'text import MIMEText'}\n\n'
          '${_useHtml ? 'msg = MIMEMultipart("alternative")\n' : 'msg = MIMEText("$_body", "plain", "utf-8")\n'}'
          'msg["From"] = "sender@gmail.com"\n'
          'msg["To"] = "$_to"\n'
          '${_hasCc ? 'msg["Cc"] = "$_cc"\n' : ''}'
          'msg["Subject"] = "$_subject"\n\n'
          'with smtplib.SMTP_SSL("smtp.gmail.com", 465) as s:\n'
          '    s.login("sender@gmail.com", "app_password")\n'
          '    s.sendmail("sender@gmail.com", ["$_to"${_hasCc ? ', "$_cc"' : ''}], msg.as_string())',
        ),
      ],
    );
  }
}

/// Python 第16章：SMTP教程 —— 电子邮件发送
/// 涵盖 smtplib、email 模块、纯文本/HTML邮件、附件、SSL/TLS、编码等
class PythonSMTpTutorial extends StatelessWidget {
  const PythonSMTpTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第16章 SMTP邮件'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 电子邮件协议概述 —— SMTP / POP3 / IMAP\n'
            '② smtplib 模块 —— 连接、登录、发送\n'
            '③ 邮件结构 —— 信封、头部、正文\n'
            '④ email 模块 —— MIMEText / MIMEImage / MIMEMultipart\n'
            '⑤ 纯文本邮件 —— 创建与发送\n'
            '⑥ HTML 邮件 —— MIMEText 的 html 子类型\n'
            '⑦ 附件 —— MIMEBase / Content-Disposition\n'
            '⑧ 多收件人 —— To / CC / BCC\n'
            '⑨ 常见 SMTP 服务器配置（Gmail / QQ / 163）\n'
            '⑩ 安全连接 —— SMTP_SSL 与 starttls()\n'
            '⑪ 中文编码 —— Header / base64 / quoted-printable\n'
            '⑫ 内嵌图片 —— Content-ID (CID) 嵌入\n'
            '⑬ 错误处理 —— SMTPException / 超时\n'
            '⑭ 完整示例 —— 发送带附件的格式化邮件\n'
            '⑮ 邮件模板 —— string.Template 动态内容\n'
            '⑯ 批量发送 —— 频率控制与反垃圾邮件\n'
            '⑰ 最佳实践 —— 应用密码与端口选择',
          ),
          const TipBox(
            'SMTP 是互联网上发送电子邮件的核心协议。Python 的 smtplib 和 email '
            '模块提供了完整的邮件发送能力，从简单的文本邮件到复杂的带附件和 HTML 格式的邮件。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 1. 电子邮件协议概述
          // ════════════════════════════════════════════════
          const SectionHeader('1. 电子邮件协议概述', icon: Icons.lan),
          const Paragraph(
            '电子邮件系统涉及三种核心协议：\n\n'
            'SMTP (Simple Mail Transfer Protocol)：负责发送邮件,将邮件从客户端传输到服务器,'
            '以及服务器之间的中继转发。默认端口 25。\n\n'
            'POP3 (Post Office Protocol v3)：负责接收邮件,将邮件从服务器下载到本地,'
            '下载后服务器上的邮件通常会被删除。默认端口 110。\n\n'
            'IMAP (Internet Message Access Protocol)：也负责接收邮件,但邮件保留在服务器上,'
            '客户端只操作副本。支持文件夹管理。默认端口 143。\n\n'
            'Python 的 smtplib 专门处理发送(即 SMTP 客户端),而收取邮件则使用 poplib 或 imaplib。'
            '本章聚焦于 smtplib 和 email 模块。',
          ),
          const TipBox(
            '简单来说：SMTP 是"寄信"，POP3/IMAP 是"收信"。IMAP 比 POP3 更现代，'
            '因为它保持邮件在服务器上同步，多设备访问体验更好。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 2. smtplib 模块
          // ════════════════════════════════════════════════
          const SectionHeader('2. smtplib 模块', icon: Icons.send),
          const Paragraph(
            'smtplib 是 Python 内置的 SMTP 客户端模块，提供了 SMTP、SMTP_SSL 两个核心类。'
            '基本流程是：创建连接 → 登录 → 发送邮件 → 关闭连接。',
          ),
          const CodeBlock(r'''
import smtplib

# ---- SMTP 类：明文或 STARTTLS 连接 ----
# server = smtplib.SMTP(host, port)
# server = smtplib.SMTP('smtp.gmail.com', 587)  # 587 是 STARTTLS 端口

# ---- SMTP_SSL 类：SSL 加密连接 ----
# server = smtplib.SMTP_SSL(host, port)
# server = smtplib.SMTP_SSL('smtp.gmail.com', 465)  # 465 是 SSL 端口

# ---- 标准发送流程 ----
def send_simple_email():
    """演示最简邮件发送流程"""
    smtp_server = 'smtp.example.com'
    port = 587
    sender = 'sender@example.com'
    password = 'your_password'
    receiver = 'receiver@example.com'

    # 1. 创建连接
    server = smtplib.SMTP(smtp_server, port)

    # 2. 启用 TLS 加密（端口 587 需要）
    server.starttls()

    # 3. 登录
    server.login(sender, password)

    # 4. 发送邮件（参数：发件人、收件人列表、邮件内容）
    subject = 'Hello'
    body = 'This is a test email.'
    msg = f'Subject: {subject}\n\n{body}'
    server.sendmail(sender, [receiver], msg)

    # 5. 关闭连接
    server.quit()

# 注意：上面的 send_simple_email 仅用于演示流程，
# 实际发送复杂邮件需要使用 email 模块构造 MIME 格式内容。
''', language: 'Python'),
          const TipBox(
            '务必使用 587 端口 + STARTTLS 或 465 端口 + SSL，不要使用 25 端口。'
            '25 端口常被 ISP 或云服务商屏蔽，且不适合客户端发送。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 3. 邮件结构
          // ════════════════════════════════════════════════
          const SectionHeader('3. 邮件结构', icon: Icons.email),
          const Paragraph(
            '一封电子邮件由三部分组成：\n\n'
            '信封 (Envelope)：SMTP 传输时使用的实际发件人和收件人地址,'
            '由 MAIL FROM 和 RCPT TO 命令决定。\n\n'
            '头部 (Headers)：包含邮件的元数据,如 From、To、Subject、Date、'
            'Message-ID、Content-Type、MIME-Version 等,以 key: value 格式表示。\n\n'
            '正文 (Body)：邮件的实际内容,可以是纯文本、HTML 或包含附件的多部分消息。\n\n'
            '在 Python 中,邮件头部直接作为字符串拼接到邮件内容的最前面。'
            'sendmail() 的前两个参数就是信封地址,而邮件头部的 From/To 可以不同(但通常一致)。',
          ),
          const CodeBlock(r'''
# 邮件头部格式示例
headers = """From: 张三 <zhangsan@example.com>
To: 李四 <lisi@example.com>
Subject: =?utf-8?B?5rWL6K+V6YKu5Lu2?=
Date: Thu, 30 Apr 2026 10:00:00 +0800
Message-ID: <20260430100000@example.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"

这里是邮件正文内容。
"""

# 注意：Subject 中的 =?utf-8?B?...?= 是 Base64 编码的中文标题
# 手工构造很麻烦，下一节用 email 模块自动处理
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 4. email 模块
          // ════════════════════════════════════════════════
          const SectionHeader('4. email 模块', icon: Icons.description),
          const Paragraph(
            'email 模块提供了构造和解析邮件的类。最核心的几个类：\n\n'
            'MIMEText：纯文本或 HTML 文本内容\n'
            'MIMEImage：图片附件/内嵌图片\n'
            'MIMEMultipart：组合多种内容的容器(mixed / alternative / related)\n'
            'MIMEBase：其他类型的附件(如 PDF、Word)\n'
            'Header：处理非 ASCII 编码的头部字段',
          ),
          const CodeBlock(r'''
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.header import Header
from email import encoders
from email.utils import formatdate, formataddr

# ---- MIMEMultipart 的子类型 ----
# mixed:      最常用，包含正文和附件
# alternative: 包含同一内容的不同格式（纯文本 + HTML）
# related:     包含内嵌资源（图片、样式等）

# ---- 基本构造 ----
# 纯文本
msg = MIMEText('邮件正文', 'plain', 'utf-8')

# HTML
msg = MIMEText('<h1>标题</h1><p>正文</p>', 'html', 'utf-8')

# 带附件
msg = MIMEMultipart()
msg.attach(MIMEText('正文', 'plain', 'utf-8'))
# 再附加文件...
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 5. 纯文本邮件
          // ════════════════════════════════════════════════
          const SectionHeader('5. 纯文本邮件', icon: Icons.text_fields),
          const Paragraph(
            '创建纯文本邮件只需使用 MIMEText 并指定 "plain" 子类型。'
            '然后设置头部字段并从 smtplib 发送即可。',
          ),
          const CodeBlock(r'''
import smtplib
from email.mime.text import MIMEText
from email.utils import formataddr, formatdate

def send_plain_text_email():
    # 构造邮件
    msg = MIMEText(
        '这是一封纯文本测试邮件。\n\n'
        '你可以包含多行内容。\n'
        '---\n'
        '来自 Python 的问候',
        'plain',
        'utf-8'
    )

    # 设置头部
    msg['From'] = formataddr(('张三', 'zhangsan@example.com'))
    msg['To'] = formataddr(('李四', 'lisi@example.com'))
    msg['Subject'] = '纯文本测试邮件'
    msg['Date'] = formatdate(localtime=True)

    # 发送
    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.starttls()
        server.login('zhangsan@example.com', 'password')
        server.send_message(msg)
        # send_message() 自动处理头部和正文编码
        # 等效于低级的 sendmail()
        print('邮件发送成功！')

# formataddr 安全处理中文名称
# formatdate 生成 RFC 2822 格式的日期字符串
''', language: 'Python'),
          const OutputBox(
            '邮件发送成功！',
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 6. HTML 邮件
          // ════════════════════════════════════════════════
          const SectionHeader('6. HTML 邮件', icon: Icons.code),
          const Paragraph(
            'MIMEText 第二个参数传 "html" 即可创建 HTML 邮件。'
            '最佳实践是同时提供纯文本和 HTML 两种版本（MIMEMultipart/alternative），'
            '这样客户端可以选择显示哪种。',
          ),
          const CodeBlock(r'''
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# ---- 纯 HTML 版本 ----
html = """
<html>
<body>
    <h1 style="color: #2c3e50;">欢迎使用 Python 邮件</h1>
    <p>这是一封 <b>HTML 邮件</b> 测试。</p>
    <ul>
        <li>支持格式化文本</li>
        <li>支持 <a href="https://python.org">超链接</a></li>
        <li>支持样式</li>
    </ul>
    <hr>
    <p style="color: #888; font-size: 12px;">此邮件由 Python 自动发送</p>
</body>
</html>
"""

msg = MIMEText(html, 'html', 'utf-8')
msg['Subject'] = 'HTML 邮件测试'
msg['From'] = 'sender@example.com'
msg['To'] = 'receiver@example.com'

# ---- 推荐：纯文本 + HTML 双版本 ----
msg_alt = MIMEMultipart('alternative')
msg_alt['Subject'] = '双版本邮件测试'
msg_alt['From'] = 'sender@example.com'
msg_alt['To'] = 'receiver@example.com'

# 纯文本版本（优先显示 HTML 版本）
plain_text = MIMEText('请使用支持 HTML 的邮件客户端查看。', 'plain', 'utf-8')
html_text = MIMEText(html, 'html', 'utf-8')

# 按优先级添加：纯文本在前，HTML 在后
msg_alt.attach(plain_text)   # 备选
msg_alt.attach(html_text)    # 首选

# 邮件客户端会优先显示 HTML 版本
# 如果不支持 HTML，则退回到纯文本版本
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 7. 附件
          // ════════════════════════════════════════════════
          const SectionHeader('7. 添加附件', icon: Icons.attach_file),
          const Paragraph(
            '附件需要使用 MIMEMultipart("mixed") 作为容器，'
            '然后使用 MIMEBase 或相应子类添加文件。'
            '关键是要设置 Content-Disposition 和 Content-Type 头。',
          ),
          const CodeBlock(r'''
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import os

def send_email_with_attachment(file_path):
    # 创建 multipart 容器
    msg = MIMEMultipart('mixed')
    msg['Subject'] = '带附件的邮件'
    msg['From'] = 'sender@example.com'
    msg['To'] = 'receiver@example.com'

    # 添加正文
    body = MIMEText('请查收附件。', 'plain', 'utf-8')
    msg.attach(body)

    # 添加附件
    filename = os.path.basename(file_path)
    with open(file_path, 'rb') as f:
        # 创建 MIMEBase 对象
        attachment = MIMEBase('application', 'octet-stream')
        attachment.set_payload(f.read())
        encoders.encode_base64(attachment)  # Base64 编码
        attachment.add_header(
            'Content-Disposition',
            'attachment',
            filename=('utf-8', '', filename)  # 支持中文文件名
        )
        msg.attach(attachment)

    # 发送
    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.starttls()
        server.login('sender@example.com', 'password')
        server.send_message(msg)

# ---- 便捷函数：添加任意附件 ----
def attach_file(msg, file_path):
    """向邮件消息对象添加附件"""
    filename = os.path.basename(file_path)
    with open(file_path, 'rb') as f:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(f.read())
        encoders.encode_base64(part)
        part.add_header(
            'Content-Disposition',
            'attachment',
            filename=('utf-8', '', filename)
        )
        msg.attach(part)
''', language: 'Python'),
          const TipBox(
            'encoders.encode_base64() 将二进制数据编码为 Base64 文本，'
            '这样附件就可以安全地通过 SMTP 传输。对于 PDF、图片、Office 文档等，'
            '使用 "application/octet-stream" 通用 MIME 类型即可。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 8. 多收件人
          // ════════════════════════════════════════════════
          const SectionHeader('8. 多收件人：To / CC / BCC', icon: Icons.group),
          const Paragraph(
            'To 是主要收件人，CC (Carbon Copy) 是抄送人，'
            'BCC (Blind Carbon Copy) 是密送人——BCC 地址对其他收件人不可见。'
            '在头部中只设置 To 和 CC，BCC 只传给 sendmail/send_message 的第二个参数。',
          ),
          const CodeBlock(r'''
from email.mime.text import MIMEText
from email.utils import formataddr

def send_multiple_recipients():
    # 收件人列表
    to_list = ['alice@example.com', 'bob@example.com']
    cc_list = ['manager@example.com']
    bcc_list = ['archive@example.com']

    msg = MIMEText('这是全体会议通知。', 'plain', 'utf-8')
    msg['From'] = 'sender@example.com'
    msg['To'] = ', '.join(to_list)           # 以逗号分隔
    msg['Cc'] = ', '.join(cc_list)           # 抄送
    msg['Subject'] = '会议通知'

    # 合并所有收件人（BCC 也要传，但不在头部出现）
    all_recipients = to_list + cc_list + bcc_list
    # BCC 地址只出现在信封收件人中，不会出现在邮件头部

    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.starttls()
        server.login('sender@example.com', 'password')
        # send_message 会自动从 msg['To'] 和 msg['Cc'] 提取收件人
        # 但 BCC 只通过第二个参数传递
        server.send_message(msg, to_addrs=all_recipients)

# 注意：send_message 的 to_addrs 参数指定所有实际接收者
# 包括 To、CC 和 BCC 收件人
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 9. 常见 SMTP 服务器配置
          // ════════════════════════════════════════════════
          const SectionHeader('9. 常见 SMTP 服务器配置', icon: Icons.dns),
          const Paragraph(
            '不同邮件服务商的 SMTP 配置参数不同。以下是国内最常用的配置：',
          ),
          const CodeBlock(r'''
# === Gmail ===
# SMTP 服务器: smtp.gmail.com
# SSL 端口: 465
# STARTTLS 端口: 587
# 需要 Google 应用专用密码（开启两步验证后生成）

# === QQ 邮箱 ===
# SMTP 服务器: smtp.qq.com
# SSL 端口: 465
# STARTTLS 端口: 587
# 密码: 使用授权码（在 QQ 邮箱设置中生成），不是 QQ 密码

# === 163 邮箱 ===
# SMTP 服务器: smtp.163.com
# SSL 端口: 465
# STARTTLS 端口: 587
# 密码: 使用客户端授权码

# === Outlook / Hotmail ===
# SMTP 服务器: smtp.office365.com
# STARTTLS 端口: 587
# 需要 OAuth2 或应用密码

# === QQ 企业邮箱 ===
# SMTP 服务器: smtp.exmail.qq.com
# SSL 端口: 465
# STARTTLS 端口: 587

# ---- 通用发送函数 ----
def send_via_qq(sender, auth_code, receiver, subject, body):
    """使用 QQ 邮箱发送"""
    msg = MIMEText(body, 'plain', 'utf-8')
    msg['From'] = sender
    msg['To'] = receiver
    msg['Subject'] = subject

    with smtplib.SMTP_SSL('smtp.qq.com', 465) as server:
        server.login(sender, auth_code)  # 授权码！
        server.send_message(msg)
''', language: 'Python'),
          const TipBox(
            '千万不要在代码中硬编码邮箱密码！使用环境变量或配置文件存储。'
            '且大多数邮箱需要申请"授权码"或"应用专用密码"才能通过 SMTP 发送，'
            '不是直接使用登录密码。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 10. 安全连接 SSL/TLS
          // ════════════════════════════════════════════════
          const SectionHeader('10. SSL/TLS 安全连接', icon: Icons.lock),
          const Paragraph(
            'SMTP 有两种安全连接方式：\n\n'
            'SMTP_SSL：从一开始就建立 SSL 加密连接，使用端口 465。\n'
            'STARTTLS：先建立明文连接，再升级为 TLS 加密，使用端口 587。\n\n'
            '两种方式都提供传输加密，防止中间人攻击。推荐优先使用 STARTTLS（端口 587），'
            '因为它被更广泛地支持。',
          ),
          const CodeBlock(r'''
import smtplib

# ---- 方式一：SMTP_SSL（端口 465）----
def send_with_ssl():
    """全程 SSL 加密"""
    server = smtplib.SMTP_SSL('smtp.qq.com', 465)
    server.set_debuglevel(1)        # 开启调试输出
    server.login('user@qq.com', 'auth_code')
    # ... 发送操作
    server.quit()

# ---- 方式二：STARTTLS（端口 587）----
def send_with_starttls():
    """先明文后升级 TLS"""
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()                   # 打招呼（ESMTP 扩展）
    server.starttls()               # 升级到 TLS
    server.ehlo()                   # 再次打招呼（TLS 模式下）
    server.login('user@gmail.com', 'app_password')
    # ... 发送操作
    server.quit()

# ---- 简化写法（推荐）----
def send_concise():
    """使用 with 语句自动管理连接"""
    with smtplib.SMTP_SSL('smtp.qq.com', 465) as server:
        server.login('user@qq.com', 'auth_code')
        server.send_message(msg)
    # with 块结束自动调用 quit()

# ---- 调试模式 ----
# set_debuglevel(1) 会在控制台输出 SMTP 通信细节
# 包括发送的命令和服务器的响应，便于排查问题
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 11. 中文编码
          // ════════════════════════════════════════════════
          const SectionHeader('11. 中文编码处理', icon: Icons.translate),
          const Paragraph(
            '电子邮件头部默认只支持 ASCII 字符。中文（及其他非 ASCII 文本）'
            '需要使用 RFC 2047 编码格式进行编码。Python 的 email.header.Header 类'
            '可以自动处理这一编码过程。',
          ),
          const CodeBlock(r'''
from email.header import Header
from email.mime.text import MIMEText
from email.utils import formataddr

# ---- 使用 Header 编码中文字符 ----
msg = MIMEText('中文邮件正文', 'plain', 'utf-8')

# 方法一：直接传字符串（推荐）
msg['Subject'] = Header('中文主题', 'utf-8')
# 自动编码为: =?utf-8?b?5Lit5paH5Li76aKY?=

# 方法二：使用 formataddr 处理发件人名称
msg['From'] = formataddr((
    str(Header('张三', 'utf-8')),
    'zhangsan@example.com'
))
msg['To'] = formataddr((
    str(Header('李四', 'utf-8')),
    'lisi@example.com'
))

# ---- 查看编码结果 ----
print(msg['Subject'])
# =?utf-8?b?5Lit5paH5Li76aKY?=

# ---- 编码方式说明 ----
# Base64 编码: =?charset?B?base64_string?=
#   适合 ASCII 字符较少的中文文本
# Quoted-Printable: =?charset?Q?encoded_text?=
#   适合 ASCII 字符较多的混合文本
# Header 类会自动选择较优的编码方式
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 12. 内嵌图片
          // ════════════════════════════════════════════════
          const SectionHeader('12. 内嵌图片（CID 嵌入）', icon: Icons.image),
          const Paragraph(
            '内嵌图片是指图片直接包含在邮件中，收件人无需下载即可看到。'
            '使用 MIMEMultipart("related") 容器，为图片分配一个唯一的 Content-ID，'
            '然后在 HTML 中以 <img src="cid:content_id"> 引用。',
          ),
          const CodeBlock(r'''
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage

def send_inline_image():
    """发送内嵌图片的 HTML 邮件"""
    msg = MIMEMultipart('related')
    msg['Subject'] = '内嵌图片测试'
    msg['From'] = 'sender@example.com'
    msg['To'] = 'receiver@example.com'

    # HTML 正文中引用图片
    html = """
    <html>
    <body>
        <h1>看！图片内嵌在邮件中</h1>
        <img src="cid:logo_img" width="200">
        <p>图片来源: Content-ID = logo_img</p>
    </body>
    </html>
    """
    msg.attach(MIMEText(html, 'html', 'utf-8'))

    # 添加图片附件（设置 Content-ID）
    with open('logo.png', 'rb') as f:
        img = MIMEImage(f.read())
        # Content-ID 的值对应 HTML 中的 cid:xxx
        img.add_header('Content-ID', '<logo_img>')
        img.add_header('Content-Disposition', 'inline')
        msg.attach(img)

    # 发送
    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.starttls()
        server.login('sender@example.com', 'password')
        server.send_message(msg)
    print('内嵌图片邮件已发送')

# 关键点：
#   1. Content-ID 值要包含尖括号: <logo_img>
#   2. HTML 中用 cid:logo_img（不含尖括号）引用
#   3. Content-Disposition: inline 表示内嵌显示
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 13. 错误处理
          // ════════════════════════════════════════════════
          const SectionHeader('13. 错误处理', icon: Icons.error),
          const Paragraph(
            'SMTP 发送过程中可能遇到多种异常，主要包括：\n'
            '- SMTPAuthenticationError：登录认证失败（密码/授权码错误）\n'
            '- SMTPRecipientsRefused：收件人被服务器拒绝\n'
            '- SMTPSenderRefused：发件人被服务器拒绝\n'
            '- SMTPDataError：数据发送错误\n'
            '- SMTPConnectError：连接失败（服务器地址/端口不对）\n'
            '- SMTPHeloError：HELO 命令失败\n'
            '- smtplib.SMTPException：所有异常的基类\n'
            '- socket.timeout / ConnectionRefusedError：网络层面错误',
          ),
          const CodeBlock(r'''
import smtplib
import socket

def safe_send_email(sender, password, receiver, msg):
    """带错误处理的邮件发送函数"""
    try:
        with smtplib.SMTP_SSL('smtp.qq.com', 465, timeout=30) as server:
            server.login(sender, password)
            server.send_message(msg)
        print('发送成功')
        return True

    except smtplib.SMTPAuthenticationError:
        print('认证失败：请检查用户名和授权码')
        print('提示：QQ 邮箱需要使用授权码而非密码')

    except smtplib.SMTPRecipientsRefused as e:
        print(f'收件人被拒绝: {e.recipients}')

    except smtplib.SMTPConnectError:
        print('连接 SMTP 服务器失败')
        print('请检查服务器地址和端口是否正确')

    except smtplib.SMTPException as e:
        print(f'SMTP 错误: {e}')

    except socket.timeout:
        print('连接超时，请检查网络')

    except ConnectionRefusedError:
        print('连接被拒绝，端口可能被屏蔽')

    except Exception as e:
        print(f'未知错误: {e}')

    return False

# ---- 重试机制 ----
import time

def send_with_retry(sender, password, receiver, msg, retries=3):
    """带重试机制的邮件发送"""
    for attempt in range(retries):
        try:
            safe_send_email(sender, password, receiver, msg)
            return True
        except Exception:
            if attempt < retries - 1:
                wait = 2 ** attempt  # 指数退避
                print(f'第 {attempt + 1} 次失败，{wait} 秒后重试...')
                time.sleep(wait)
            else:
                print('所有重试均已失败')
    return False
''', language: 'Python'),
          const TipBox(
            'SMTPAuthenticationError 是最常见的错误。请确认：1) 不是使用登录密码，'
            '而是从邮箱设置中获取的授权码/应用密码；2) 邮箱已开通 SMTP 服务权限。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 14. 完整示例
          // ════════════════════════════════════════════════
          const SectionHeader('14. 完整示例：发送带附件的格式化邮件', icon: Icons.integration_instructions),
          const Paragraph(
            '综合前面所有知识点，编写一个完整的邮件发送函数，'
            '支持 HTML 正文、附件、多收件人、中文编码等。',
          ),
          const CodeBlock(r'''
import smtplib
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.header import Header
from email.utils import formataddr, formatdate
from email import encoders

def send_formatted_email(
    smtp_host, smtp_port, use_ssl,
    sender, password,
    to_list, cc_list, bcc_list,
    subject, html_body,
    attachments=None
):
    """
    发送格式化邮件的完整函数

    参数:
        smtp_host: SMTP 服务器地址
        smtp_port: 端口号
        use_ssl: 是否使用 SSL
        sender: 发件人地址
        password: 授权码/密码
        to_list: 收件人列表
        cc_list: 抄送列表
        bcc_list: 密送列表
        subject: 邮件主题
        html_body: HTML 正文
        attachments: 附件路径列表
    """
    # 创建 multipart 容器
    msg = MIMEMultipart('mixed')
    msg['Subject'] = Header(subject, 'utf-8')
    msg['From'] = sender
    msg['To'] = ', '.join(to_list)
    if cc_list:
        msg['Cc'] = ', '.join(cc_list)
    msg['Date'] = formatdate(localtime=True)
    msg['Message-ID'] = (
        f'<{os.path.basename(__file__)}.'
        f'{formatdate(localtime=True).replace(" ", "_")}'
        f'@{smtp_host.split(".")[-2]}.{smtp_host.split(".")[-1]}>'
    )

    # 添加 HTML 正文
    msg.attach(MIMEText(html_body, 'html', 'utf-8'))

    # 添加附件
    if attachments:
        for file_path in attachments:
            if not os.path.exists(file_path):
                print(f'附件不存在: {file_path}')
                continue
            with open(file_path, 'rb') as f:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(f.read())
                encoders.encode_base64(part)
                filename = os.path.basename(file_path)
                part.add_header(
                    'Content-Disposition',
                    'attachment',
                    filename=('utf-8', '', filename)
                )
                msg.attach(part)

    # 发送
    all_recipients = to_list + cc_list + bcc_list
    smtp_class = smtplib.SMTP_SSL if use_ssl else smtplib.SMTP

    with smtp_class(smtp_host, smtp_port, timeout=30) as server:
        if not use_ssl:
            server.starttls()
        server.login(sender, password)
        server.send_message(msg, to_addrs=all_recipients)

    print(f'邮件已成功发送给 {len(all_recipients)} 位收件人')

# 使用示例
# send_formatted_email(
#     smtp_host='smtp.qq.com',
#     smtp_port=465,
#     use_ssl=True,
#     sender='you@qq.com',
#     password='your_auth_code',
#     to_list=['alice@example.com'],
#     cc_list=['manager@example.com'],
#     bcc_list=['archive@example.com'],
#     subject='季度报告',
#     html_body='<h1>季度报告</h1><p>请查收附件。</p>',
#     attachments=['report.pdf', 'data.xlsx']
# )
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 15. 邮件模板
          // ════════════════════════════════════════════════
          const SectionHeader('15. 邮件模板（string.Template）', icon: Icons.auto_awesome),
          const Paragraph(
            'string.Template 是 Python 标准库中的简单模板引擎，'
            '适合替换邮件内容中的占位符。对于更复杂的模板需求，可以使用 Jinja2。',
          ),
          const CodeBlock(r'''
from string import Template

# ---- 定义模板 ----
email_template = Template("""
<html>
<body>
    <h2>尊敬的 $name，您好！</h2>

    <p>感谢您注册我们的服务。您的账户信息如下：</p>

    <table border="1" cellpadding="8" style="border-collapse:collapse;">
        <tr><td>用户名</td><td>$username</td></tr>
        <tr><td>注册邮箱</td><td>$email</td></tr>
        <tr><td>注册时间</td><td>$register_time</td></tr>
    </table>

    <p>请点击以下链接完成邮箱验证：</p>
    <p><a href="$verify_url">立即验证</a></p>

    <hr>
    <p style="color: #888;">此邮件由系统自动发送，请勿回复。</p>
</body>
</html>
""")

# ---- 填充模板 ----
def send_welcome_email(user_info):
    """发送注册欢迎邮件"""
    html_content = email_template.substitute(
        name=user_info['name'],
        username=user_info['username'],
        email=user_info['email'],
        register_time=user_info['register_time'],
        verify_url=user_info['verify_url'],
    )

    msg = MIMEText(html_content, 'html', 'utf-8')
    msg['Subject'] = f'欢迎加入，{user_info["name"]}！'
    msg['From'] = 'noreply@example.com'
    msg['To'] = user_info['email']

    # ... 发送

# 注意：使用 substitute() 时，如果模板中有未提供的变量会报 KeyError
# 使用 safe_substitute() 则不会报错，未提供的变量保留原样

# ---- 批量生成 ----
users = [
    {'name': '张三', 'username': 'zhangsan', 'email': 'zs@example.com'},
    {'name': '李四', 'username': 'lisi', 'email': 'ls@example.com'},
]

for user in users:
    personalized = email_template.safe_substitute(
        name=user['name'],
        username=user['username'],
        email=user['email'],
        register_time='2026-04-30',
        verify_url=f'https://example.com/verify/{user["username"]}',
    )
    print(f'已生成 {user["name"]} 的邮件内容')
''', language: 'Python'),
          const TipBox(
            r'string.Template 使用 $$ 表示字面量美元符号，$var 或 ${var} 表示变量。'
            '安全方面注意：不要在模板中插入用户提供的 HTML 片段，防止邮件内容注入。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 16. 批量发送
          // ════════════════════════════════════════════════
          const SectionHeader('16. 批量发送与频率控制', icon: Icons.speed),
          const Paragraph(
            '发送大量邮件时需要注意：避免被 SMTP 服务器限流、触发反垃圾机制、'
            '以及被列入黑名单。以下是批量发送的实践策略。',
          ),
          const CodeBlock(r'''
import time
import smtplib
from email.mime.text import MIMEText

# ---- 频率控制 ----
def send_bulk_email(sender, password, recipients, subject, body):
    """
    批量发送邮件，带频率控制

    参数:
        recipients: [(name, email), ...] 格式的收件人列表
    """
    sent_count = 0
    failed_count = 0
    batch_size = 50          # 每批最多 50 封
    delay_between = 1.0      # 每封间隔 1 秒
    delay_batch = 10.0       # 每批间隔 10 秒

    for i, (name, email) in enumerate(recipients):
        try:
            # 个性化邮件
            personalized = body.replace('{name}', name)
            msg = MIMEText(personalized, 'plain', 'utf-8')
            msg['Subject'] = subject
            msg['From'] = sender
            msg['To'] = email

            with smtplib.SMTP_SSL('smtp.example.com', 465) as server:
                server.login(sender, password)
                server.send_message(msg)

            sent_count += 1
            print(f'[{i + 1}/{len(recipients)}] 已发送: {email}')

            # 每封之间延时
            time.sleep(delay_between)

            # 每批后额外延时
            if (i + 1) % batch_size == 0:
                print(f'--- 已发送 {sent_count} 封，暂停 {delay_batch} 秒 ---')
                time.sleep(delay_batch)

        except Exception as e:
            failed_count += 1
            print(f'[{i + 1}/{len(recipients)}] 发送失败: {email} - {e}')

    print(f'\n发送完成：成功 {sent_count} 封，失败 {failed_count} 封')

# ---- 反垃圾邮件注意事项 ----
# 1. 不要发送未经许可的商业邮件
# 2. 在邮件中加入退订链接
# 3. 使用有意义的主题行，避免垃圾词
# 4. 确保发件人信誉良好（配置 SPF、DKIM、DMARC 记录）
# 5. 控制发送频率，避免短时间大量发送
''', language: 'Python'),
          const DividerLine(),

          // ════════════════════════════════════════════════
          // 17. 最佳实践
          // ════════════════════════════════════════════════
          const SectionHeader('17. 最佳实践总结', icon: Icons.star),
          const Paragraph(
            '以下是在 Python 中安全、规范地发送电子邮件的核心建议：',
          ),
          const StepItem(
            step: 1,
            title: '使用应用专用密码而非登录密码',
            description: 'Gmail 需要应用密码，QQ/163 需要 SMTP 授权码。'
                '这些可以在邮箱的安全设置中生成，并可以随时撤销。',
          ),
          const StepItem(
            step: 2,
            title: '端口选择：优先 587 (STARTTLS)',
            description: '端口 587 支持 STARTTLS 安全升级，是被 IANA 注册的'
                '邮件提交端口。端口 465 是 SSL 加密，虽然常用但不是标准端口。'
                '避免使用端口 25。',
          ),
          const StepItem(
            step: 3,
            title: '始终使用安全连接',
            description: '无论是 SMTP_SSL(465) 还是 STARTTLS(587)，'
                '传输加密都是必须的。不要在无加密连接中传输密码或邮件内容。',
          ),
          const StepItem(
            step: 4,
            title: '敏感信息使用环境变量',
            description: '不在代码中硬编码邮箱地址和密码，使用 os.environ 读取环境变量，'
                '或使用 .env 文件配合 python-dotenv 管理。',
          ),
          const StepItem(
            step: 5,
            title: '添加退订链接和友好的发送频率',
            description: '批量发送时包含退订选项，控制发送间隔（每封至少 0.5-1 秒），'
                '避免触发反垃圾机制。配置 SPF 和 DKIM 记录可以提高送达率。',
          ),
          const StepItem(
            step: 6,
            title: '正确设置邮件头部',
            description: '包含完整的 From、To、Date、Subject、Message-ID、'
                'MIME-Version 等头部信息。中文主题和名称使用 Header 类编码。',
          ),
          const StepItem(
            step: 7,
            title: '区分 sendmail 和 send_message',
            description: 'sendmail 需要手动构造原始邮件字符串，'
                'send_message 接受 email.message.Message 对象并自动编码。'
                '推荐使用 send_message。',
          ),
          const CodeBlock(r'''
import os
import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr

# ---- 最佳实践示例 ----
def send_best_practice():
    """遵循最佳实践的邮件发送函数"""
    # 从环境变量读取敏感信息
    sender = os.environ.get('SMTP_USER', '')
    password = os.environ.get('SMTP_PASS', '')

    if not sender or not password:
        raise ValueError('请设置 SMTP_USER 和 SMTP_PASS 环境变量')

    # 构造邮件
    msg = MIMEText('这是一封遵循最佳实践发送的测试邮件。', 'plain', 'utf-8')
    msg['From'] = formataddr((
        str(Header('技术支持', 'utf-8')),
        sender
    ))
    msg['To'] = 'user@example.com'
    msg['Subject'] = Header('测试邮件（请勿回复）', 'utf-8')
    msg['Date'] = formatdate(localtime=True)

    # 使用 STARTTLS 端口 587
    with smtplib.SMTP('smtp.qq.com', 587, timeout=30) as server:
        server.starttls()
        server.login(sender, password)
        server.send_message(msg)
    print('邮件已按最佳实践发送成功')
''', language: 'Python'),

          const _EmailBuilderDemo(),
          const DividerLine(),
          const SectionHeader('✏️ 小练习', icon: Icons.edit),
          const Paragraph(
            '1. 使用 smtplib 和 QQ 邮箱发送一封纯文本测试邮件\n'
            '2. 创建一个 HTML 邮件，包含标题、段落和列表\n'
            '3. 发送一封带 PDF 附件的邮件\n'
            '4. 使用 string.Template 生成 5 封个性化的邀请邮件\n'
            '5. 实现一个健壮的邮件发送函数，处理常见的异常情况\n'
            '6. 发送一封同时包含纯文本和 HTML 版本（alternative）的邮件\n'
            '7. 使用 SMTP_SSL 连接到 163 邮箱并发送一封带图片的邮件',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
