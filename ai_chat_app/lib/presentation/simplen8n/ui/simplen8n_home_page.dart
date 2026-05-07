import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/workflow_provider.dart';
import '../nodes/node_registry.dart';
import 'workflow_canvas_page.dart';

/// simplen8n 入口页
class Simplen8nHomePage extends StatelessWidget {
  const Simplen8nHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('simplen8n'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.account_tree, size: 40, color: cs.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'simplen8n',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A visual workflow automation engine built with Flutter',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 32),
              // 新建工作流按钮
              FilledButton.icon(
                onPressed: () {
                  final provider = WorkflowProvider(
                    availableTypes: NodeRegistry.instance.types,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: const WorkflowCanvasPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Workflow'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(220, 48),
                ),
              ),
              const SizedBox(height: 48),
              // 快速开始步骤
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepBadge(1, 'Pick nodes from the left panel', cs),
                  _buildArrow(cs),
                  _buildStepBadge(2, 'Connect nodes by dragging', cs),
                  _buildArrow(cs),
                  _buildStepBadge(3, 'Configure parameters → Execute', cs),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBadge(int step, String label, ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(180)),
        ),
      ],
    );
  }

  Widget _buildArrow(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.arrow_forward, size: 14,
          color: cs.onSurface.withAlpha(80)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'simplen8n',
      applicationVersion: 'Phase 0 — Prototype',
      children: const [
        Text(
          'A simplified n8n-like workflow automation engine\n'
          'built in Flutter + Dart.\n\n'
          'Phase 0:\n'
          '  • 3 core nodes (Manual Trigger, HTTP Request, Set)\n'
          '  • Visual canvas with vyuh_node_flow\n'
          '  • Linear execution engine\n'
          '  • JSON export/import',
        ),
      ],
    );
  }
}
