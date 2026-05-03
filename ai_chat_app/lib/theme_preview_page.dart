import 'package:flutter/material.dart';
import 'theme/palettes.dart';
import 'theme/theme_factory.dart';

class ThemePreviewPage extends StatefulWidget {
  const ThemePreviewPage({super.key});

  @override
  State<ThemePreviewPage> createState() => _ThemePreviewPageState();
}

class _ThemePreviewPageState extends State<ThemePreviewPage> {
  bool _dark = false;
  bool _pureBg = false;
  String _selectedPaletteId = ThemePalettes.defaultId;

  @override
  Widget build(BuildContext context) {
    final palette = ThemePalettes.byId(_selectedPaletteId);
    final cs = _dark ? palette.dark : palette.light;
    final theme = _dark
        ? buildDarkThemeForScheme(cs, pureBackground: _pureBg)
        : buildLightThemeForScheme(cs, pureBackground: _pureBg);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('🎨 主题预览 — ${palette.displayNameZh}'),
          actions: [
            IconButton(
              icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _dark = !_dark),
              tooltip: '切换深浅',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Palette selector ----
            _section('色板选择'),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ThemePalettes.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final p = ThemePalettes.all[i];
                  final selected = p.id == _selectedPaletteId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaletteId = p.id),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: p.light.primary,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: selected
                            ? [BoxShadow(color: p.light.primary.withValues(alpha: 0.5), blurRadius: 8)]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          p.zhName[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ---- Options ----
            _section('选项'),
            Row(
              children: [
                const Text('纯色背景'),
                const SizedBox(width: 8),
                Switch(value: _pureBg, onChanged: (v) => setState(() => _pureBg = v)),
                const Spacer(),
                Text(_dark ? '深色' : '浅色'),
              ],
            ),

            // ---- Color swatches ----
            _section('ColorScheme'),
            _colorRow('Primary', cs.primary, cs.onPrimary),
            _colorRow('OnPrimary', cs.onPrimary, cs.primary),
            _colorRow('PrimaryContainer', cs.primaryContainer, cs.onPrimaryContainer),
            _colorRow('Secondary', cs.secondary, cs.onSecondary),
            _colorRow('SecondaryContainer', cs.secondaryContainer, cs.onSecondaryContainer),
            _colorRow('Tertiary', cs.tertiary, cs.onTertiary),
            _colorRow('Error', cs.error, cs.onError),
            _colorRow('Surface', cs.surface, cs.onSurface),
            _colorRow('SurfaceVariant', cs.surfaceContainerHighest, cs.onSurfaceVariant),

            const SizedBox(height: 12),
            _section('UI 组件预览'),

            // ---- Buttons ----
            _group('按钮'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: null, child: const Text('禁用')),
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
              ],
            ),

            // ---- Chips ----
            _group('Chip'),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: const Text('标签')),
                InputChip(label: const Text('输入'), selected: true),
                ActionChip(label: const Text('操作'), onPressed: () {}),
              ],
            ),

            // ---- Card ----
            _group('Card'),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(cs.primary == cs.onPrimary ? Icons.person : Icons.person)),
                title: const Text('Card Title'),
                subtitle: const Text('Card subtitle with description'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),

            // ---- Dialog preview ----
            _group('Dialog'),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('对话框标题'),
                  content: const Text('这是对话框内容。'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                    FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('确认')),
                  ],
                ),
              ),
              child: const Text('打开对话框'),
            ),

            // ---- SnackBar preview ----
            _group('SnackBar'),
            OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('这是一条 SnackBar 消息'), action: SnackBarAction(label: '撤销', onPressed: () {})),
              ),
              child: const Text('弹出 SnackBar'),
            ),

            // ---- Slider ----
            _group('Slider'),
            const Slider(value: 0.6, onChanged: null),
            const Slider(value: 0.6, onChanged: null, divisions: 4),

            // ---- Switch + Checkbox ----
            _group('Switch / Checkbox / Radio'),
            Row(
              children: [
                const Switch(value: true, onChanged: null),
                const Checkbox(value: true, onChanged: null),
                const Icon(Icons.radio_button_checked),
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Badge(child: IconButton(icon: const Icon(Icons.notifications), onPressed: null)),
              ],
            ),

            // ---- Text preview ----
            _group('字体层级'),
            Text('Display Large', style: theme.textTheme.displayLarge),
            Text('Headline Medium', style: theme.textTheme.headlineMedium),
            Text('Title Large', style: theme.textTheme.titleLarge),
            Text('Title Medium', style: theme.textTheme.titleMedium),
            Text('Body Large', style: theme.textTheme.bodyLarge),
            Text('Body Medium', style: theme.textTheme.bodyMedium),
            Text('Label Large', style: theme.textTheme.labelLarge),
            Text('Label Small', style: theme.textTheme.labelSmall),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
    );
  }

  Widget _group(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _colorRow(String name, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fg)),
            const Spacer(),
            Text(bg.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase(), style: TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
