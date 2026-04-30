import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ============================================================
/// 学习中心 - 编程语言教程总入口
/// 提供 Flutter / Python / Dart 三大语言的教程入口
/// ============================================================

class StudyHome extends StatelessWidget {
  const StudyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习中心'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          _LanguageCard(
            icon: Icons.code,
            color: const Color(0xFF306998),
            gradient: const LinearGradient(
              colors: [Color(0xFF306998), Color(0xFFFFD43B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            title: 'Python',
            subtitle: '最易学的编程语言 · 22 个章节',
            description: '从零开始学 Python：基础语法、数据结构、函数、\n面向对象到 IO编程、调试测试、正则、标准库、\n实战项目与专题进阶（CGI/MySQL/SQLite+ORM/网络/SMTP/多线程/XML/GUI+turtle/异步IO/第三方模块/Web开发）。',
            onTap: () => context.push('/python'),
          ),
          const SizedBox(height: 24),
          _LanguageCard(
            icon: Icons.phone_android,
            color: const Color(0xFF0553B1),
            gradient: const LinearGradient(
              colors: [Color(0xFF0553B1), Color(0xFF027DFD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            title: 'Flutter',
            subtitle: '跨平台 UI 框架 · 12 个章节',
            description: '从状态管理、动画、布局到网络请求、本地存储，\n全面掌握 Flutter 开发技能（含 Widget 基础）。',
            onTap: () => context.push('/flutter'),
          ),
          
          const SizedBox(height: 16),
          _LanguageCard(
            icon: Icons.flutter_dash,
            color: const Color(0xFF0175C2),
            gradient: const LinearGradient(
              colors: [Color(0xFF0175C2), Color(0xFF13B9FD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            title: 'Dart',
            subtitle: 'Flutter 的编程语言 · 7 个章节',
            description: '深入 Dart 语言：Null Safety、集合操作、\n面向对象、异步编程与 Dart 3 新特性。',
            onTap: () => context.push('/dart'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择学习语言',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '每种语言都提供从零基础到精通的完整教程',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.icon,
    required this.color,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部渐变色条
            Container(
              height: 8,
              decoration: BoxDecoration(gradient: gradient),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
