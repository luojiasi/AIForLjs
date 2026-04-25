import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/presentation/providers/settings_provider.dart';
import 'package:ai_chat_app/di/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = ref.read(settingsProvider.notifier);
      await settings.loadSettings();
      final adapters = ref.read(modelProviderRegistryProvider).allAdapters;
      for (final adapter in adapters) {
        final key = await settings.getApiKey(adapter.providerId);
        _apiKeyControllers[adapter.providerId] = TextEditingController(text: key ?? '');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    for (final c in _apiKeyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final adapters = ref.watch(modelProviderRegistryProvider).allAdapters;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'API 配置'),
          ...adapters.map((adapter) => _ApiKeyTile(
                adapterName: adapter.providerName,
                providerId: adapter.providerId,
                controller: _apiKeyControllers[adapter.providerId] ?? TextEditingController(),
                configured: settings.apiKeyConfigured[adapter.providerId] ?? false,
                onSave: (key) => ref.read(settingsProvider.notifier).saveApiKey(adapter.providerId, key),
              )),
          const SizedBox(height: 24),
          _SectionHeader(title: '外观'),
          _ThemeSelector(
            current: settings.themeMode,
            onChanged: (mode) => ref.read(settingsProvider.notifier).setThemeMode(mode),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}

class _ApiKeyTile extends StatelessWidget {
  final String adapterName;
  final String providerId;
  final TextEditingController controller;
  final bool configured;
  final ValueChanged<String> onSave;

  const _ApiKeyTile({
    required this.adapterName,
    required this.providerId,
    required this.controller,
    required this.configured,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(adapterName, style: Theme.of(context).textTheme.titleSmall)),
                if (configured) const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'API Key',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => onSave(controller.text), child: const Text('保存')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatefulWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  State<_ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<_ThemeSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('跟随系统'),
            value: 'system',
            groupValue: widget.current,
            onChanged: (v) => widget.onChanged(v!),
          ),
          RadioListTile<String>(
            title: const Text('浅色模式'),
            value: 'light',
            groupValue: widget.current,
            onChanged: (v) => widget.onChanged(v!),
          ),
          RadioListTile<String>(
            title: const Text('深色模式'),
            value: 'dark',
            groupValue: widget.current,
            onChanged: (v) => widget.onChanged(v!),
          ),
        ],
      ),
    );
  }
}
