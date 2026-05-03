import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonProblemsHome extends StatelessWidget {
  const CommonProblemsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('常见问题'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '选择设备型号',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 8),
          Text(
            '查看参数说明与故障处理',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('INOVANCE（汇川）'),
          _DeviceCard(
            name: 'SV630C',
            onTap: () => context.push('/commonproblems/INOVANCE/SV630C'),
          ),
          _DeviceCard(
            name: 'SV630N',
            onTap: () => context.push('/commonproblems/INOVANCE/SV630N'),
          ),
          _DeviceCard(
            name: 'SV630P',
            onTap: () => context.push('/commonproblems/INOVANCE/SV630P'),
          ),
          _DeviceCard(
            name: 'SV660A',
            onTap: () => context.push('/commonproblems/INOVANCE/SV660A'),
          ),
          _DeviceCard(
            name: 'SV660C',
            onTap: () => context.push('/commonproblems/INOVANCE/SV660C'),
          ),
          _DeviceCard(
            name: 'SV660F',
            onTap: () => context.push('/commonproblems/INOVANCE/SV660F'),
          ),
          _DeviceCard(
            name: 'SV660P',
            onTap: () => context.push('/commonproblems/INOVANCE/SV660P'),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('JMC（杰美康）'),
          _DeviceCard(
            name: 'JAND4002',
            onTap: () => context.push('/commonproblems/JMC/JAND4002'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const _DeviceCard({required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.memory, color: Color(0xFF1565C0)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('参数说明 / 故障处理'),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
