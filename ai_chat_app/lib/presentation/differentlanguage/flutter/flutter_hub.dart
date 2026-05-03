import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlutterHub extends StatelessWidget {
  const FlutterHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 教程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(color: Color(0xFF0553B1), title: 'Flutter', subtitle: '跨平台 UI 框架 · 从入门到进阶'),
          const SizedBox(height: 16),
          const Text('🛠️ Flutter 学习路线：基础 Widget → 布局 → 状态 → 网络 → 存储 → 动画 → 进阶', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),

          // 基础篇
          const _SectionLabel(label: '📘 核心基础'),
          _ChapterCard(num: '01', title: '状态管理', desc: 'StatefulWidget、setState、为什么状态是核心', route: '/flutter/01'),
          _ChapterCard(num: '02', title: '动画大全', desc: '隐式动画、显式动画、Hero、交错动画', route: '/flutter/02'),
          _ChapterCard(num: '03', title: '框架核心类', desc: 'Widget、Element、RenderObject 三者关系', route: '/flutter/03'),
          _ChapterCard(num: '04', title: '生命周期', desc: 'initState → build → dispose 全流程', route: '/flutter/04'),
          _ChapterCard(num: '05', title: '布局 Widget 大全', desc: 'Row/Column/Stack/ListView/GridView', route: '/flutter/05'),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📗 进阶必备'),
          _ChapterCard(num: '06', title: '网络请求', desc: 'http 包、Dio、拦截器、JSON 解析', route: '/flutter/06'),
          _ChapterCard(num: '07', title: '本地存储', desc: 'SharedPreferences、Hive、sqflite', route: '/flutter/07'),
          _ChapterCard(num: '08', title: '路由导航', desc: 'Navigator、GoRouter、ShellRoute', route: '/flutter/08'),
          _ChapterCard(num: '09', title: '进阶 Widget', desc: '表单/弹窗/CustomPaint/响应式布局', route: '/flutter/09'),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📕 扩展补充'),
          _ChapterCard.ext(
            num: '10', title: 'Widget 基础', desc: 'Text、Image、Icon、Button、Container 详解',
            route: '/flutter/10',
          ),
          _ChapterCard.ext(
            num: '11', title: 'Provider 状态管理', desc: 'ChangeNotifier、Consumer、跨组件状态共享',
            route: '/flutter/11',
          ),
          _ChapterCard.ext(
            num: '12', title: '主题与样式', desc: 'Theme、ColorScheme、暗黑模式、动态取色',
            route: '/flutter/12',
          ),

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

  const _ChapterCard({
    required this.num, required this.title, required this.desc, this.route,
  });

  const _ChapterCard.ext({
    required this.num, required this.title, required this.desc, this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0553B1),
          child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: route != null ? () => context.push(route!) : null,
      ),
    );
  }
}
