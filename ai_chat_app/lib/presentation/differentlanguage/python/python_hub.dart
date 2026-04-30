import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_chat_app/presentation/shared/tutorial_widgets.dart';

class PythonHub extends StatelessWidget {
  const PythonHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Python 教程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(color: Color(0xFF306998), title: 'Python', subtitle: '最易学的编程语言 · 从入门到进阶'),
          const SizedBox(height: 16),
          const Paragraph('🐍 Python 学习路线：基础 → 进阶 → 扩展 → 标准库 → 实战 → 专题进阶'),
          const SizedBox(height: 8),

          // 基础篇
          const _SectionLabel(label: '📘 基础篇'),
          _ChapterCard(num: '01', title: '基础入门', desc: '变量、数据类型、运算符、输入输出', route: '/python/01', color: const Color(0xFF306998)),
          _ChapterCard(num: '02', title: '控制流程', desc: 'if/elif/else、for、while、break/continue', route: '/python/02', color: const Color(0xFF306998)),
          _ChapterCard(num: '03', title: '函数', desc: 'def、参数类型、lambda、装饰器、递归', route: '/python/03', color: const Color(0xFF306998)),
          _ChapterCard(num: '04', title: '数据结构', desc: 'list、tuple、dict、set 四大容器', route: '/python/04', color: const Color(0xFF306998)),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📗 进阶篇'),
          _ChapterCard(num: '05', title: '面向对象', desc: 'class、继承、魔术方法、@property', route: '/python/05', color: const Color(0xFF306998)),
          _ChapterCard(num: '06', title: '模块与包', desc: 'import、pip、标准库、虚拟环境', route: '/python/06', color: const Color(0xFF306998)),
          _ChapterCard(num: '07', title: 'IO编程', desc: '文件IO/StringIO/BytesIO/pickle/CSV/JSON/GLOB', route: '/python/07', color: const Color(0xFF306998)),
          _ChapterCard(num: '08', title: '错误、调试和测试', desc: '错误处理、pdb调试、unittest测试、doctest文档测试', route: '/python/08', color: const Color(0xFF306998)),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📕 扩展补充'),
          _ChapterCard(num: '09', title: '日期与正则', desc: 'datetime 模块、timedelta、正则表达式、实战日志解析', route: '/python/09', color: const Color(0xFF306998)),
          _ChapterCard(num: '10', title: '高级特性', desc: '生成器、迭代器、装饰器深入、上下文管理器、海象运算符', route: '/python/10', color: const Color(0xFF306998)),
          _ChapterCard(num: '11', title: '常用内建模块', desc: 'os/sys/json/datetime/collections/itertools/functools 等详解', route: '/python/11', color: const Color(0xFF306998)),
          _ChapterCard(num: '12', title: '综合实战', desc: 'Todo CLI、文件批量处理、数据爬虫三大项目实战', route: '/python/12', color: const Color(0xFF306998)),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📌 专题扩展篇'),
          _ChapterCard(num: '13', title: 'CGI编程', desc: 'CGI 架构、表单处理、Cookie/Session、安全防护', route: '/python/13', color: const Color(0xFF306998)),
          _ChapterCard(num: '14', title: 'MySQL 数据库', desc: 'MySQL/SQLite 双数据库、SQLAlchemy ORM、CRUD/事务/连接池', route: '/python/14', color: const Color(0xFF306998)),
          _ChapterCard(num: '15', title: '网络编程', desc: 'Socket/TCP-UDP/HTTP服务器/selectors/SSL/TLS', route: '/python/15', color: const Color(0xFF306998)),
          _ChapterCard(num: '16', title: 'SMTP 邮件', desc: 'smtplib/MIMEText/附件/HTML邮件/批量发送', route: '/python/16', color: const Color(0xFF306998)),
          _ChapterCard(num: '17', title: '进程和线程', desc: 'threading/multiprocessing/IPC/ThreadLocal/GIL/分布式', route: '/python/17', color: const Color(0xFF306998)),
          _ChapterCard(num: '18', title: 'XML 处理', desc: 'ElementTree/SAX/DOM/XPath/lxml/命名空间', route: '/python/18', color: const Color(0xFF306998)),
          _ChapterCard(num: '19', title: 'GUI 编程', desc: 'Tkinter 布局/事件绑定 + turtle 海龟绘图', route: '/python/19', color: const Color(0xFF306998)),
	          _ChapterCard(num: '20', title: '异步IO', desc: '协程/asyncio/aiohttp/事件循环/并发最佳实践', route: '/python/20', color: const Color(0xFF306998)),
	          _ChapterCard(num: '21', title: '常用第三方模块', desc: 'requests/bs4/Pillow/numpy/pandas/matplotlib/tqdm/dotenv', route: '/python/21', color: const Color(0xFF306998)),
          _ChapterCard(num: '22', title: 'Web 开发', desc: 'HTTP协议/WSGI接口/Flask框架/Jinja2模板', route: '/python/22', color: const Color(0xFF306998)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  const _Header({required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      SizedBox(height: 4),
      Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
    ]);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final String num;
  final String title;
  final String desc;
  final String? route;
  final VoidCallback? onTap;
  final Color color;
  const _ChapterCard({required this.num, required this.title, required this.desc, this.route, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? (route != null ? () => context.push(route!) : null),
      ),
    );
  }
}
