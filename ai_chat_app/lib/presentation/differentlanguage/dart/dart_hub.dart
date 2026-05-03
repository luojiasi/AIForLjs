import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DartHub extends StatelessWidget {
  const DartHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dart 教程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(color: Color(0xFF0175C2), title: 'Dart', subtitle: 'Flutter 的编程语言 · 从基础到 Dart 3 新特性'),
          const SizedBox(height: 16),
          const Text('🎯 Dart 学习路线：基础语法 → 控制流程 → 函数 → 集合 → OOP → 异步 → Dart 3', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),

          _ChapterCard(num: '01', title: '基础语法', desc: '变量、Null Safety、final/const、数据类型、Records', route: '/dart/01', color: const Color(0xFF0175C2)),
          _ChapterCard(num: '02', title: '控制流程', desc: 'if/switch、for/while、try-catch、assert', route: '/dart/02', color: const Color(0xFF0175C2)),
          _ChapterCard(num: '03', title: '函数', desc: '命名参数、可选参数、lambda、闭包、高阶函数', route: '/dart/03', color: const Color(0xFF0175C2)),
          _ChapterCard(num: '04', title: '集合类型', desc: 'List、Set、Map、泛型、spread/collection-if', route: '/dart/04', color: const Color(0xFF0175C2)),
          _ChapterCard(num: '05', title: '面向对象', desc: 'class、继承、抽象类、Mixin 独有特性、枚举', route: '/dart/05', color: const Color(0xFF0175C2)),
          _ChapterCard(num: '06', title: '异步编程', desc: 'Future、async/await、Stream、Isolate', route: '/dart/06', color: const Color(0xFF0175C2)),

          const SizedBox(height: 16),
          const _SectionLabel(label: '📕 扩展补充'),
          _ChapterCard(num: '07', title: 'Dart 3 新特性', desc: 'Records、Patterns、Sealed Class、Switch 表达式', route: '/dart/07', color: const Color(0xFF0175C2)),
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
  final String route;
  final Color color;
  const _ChapterCard({required this.num, required this.title, required this.desc, required this.route, required this.color});

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
        onTap: () => context.push(route),
      ),
    );
  }
}
