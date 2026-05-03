import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrandPage extends StatelessWidget {
  final String brand;

  const BrandPage({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final devices = _getDevices();
    return Scaffold(
      appBar: AppBar(
        title: Text(brand), 
        centerTitle: true
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '选择设备型号',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...devices.map((d) => _DeviceCard(
            name: d,
            onTap: () => context.push('/commonproblems/$brand/$d'),
          )),
        ],
      ),
    );
  }

  List<String> _getDevices() {
    if (brand == 'INOVANCE') {
      return [
        'SV630C', 'SV630N', 'SV630P',
        'SV660A', 'SV660C', 'SV660F', 'SV660P',
      ];
    }
    if (brand == 'JMC') {
      return ['JAND4002'];
    }
    return ['（暂无数据）'];
  }
}

class _DeviceCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _DeviceCard({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
