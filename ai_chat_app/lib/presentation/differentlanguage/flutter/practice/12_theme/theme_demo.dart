import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Flutter 教程 · 第十二章：主题与样式
/// 掌握 Theme、Colors、Typography、暗黑模式、动态取色
class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  bool _useDark = false;
  MaterialColor _primaryColor = Colors.blue;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: _primaryColor,
        brightness: _useDark ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('第12章 · 主题与样式'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader('本章内容', icon: Icons.list),
            const Paragraph(
              '① 什么是主题（Theme）\n'
              '② Material 3 颜色系统\n'
              '③ Theme.of(context) 读取主题\n'
              '④ 暗黑模式适配\n'
              '⑤ 自定义主题\n'
              '⑥ 动态取色（Dynamic Color）\n'
              '⑦ 字体与排版',
            ),
            const TipBox(
              '主题是 Flutter 应用「换皮肤」的核心机制。'
              '一套好的主题让应用看起来专业、统一，修改起来也非常方便。',
              type: TipType.info,
            ),
            const DividerLine(),

            // ── 1. 什么是 Theme ──
            const SectionHeader('1. 什么是主题（Theme）？', icon: Icons.palette),
            const Paragraph(
              'Theme 是应用的「视觉设计规范」。它集中管理：\n'
              '• 颜色系统 —— 主色、辅色、背景色、错误色\n'
              '• 文字样式 —— 标题、正文、按钮的文字大小和字重\n'
              '• 组件样式 —— 按钮、卡片、输入框的默认外观\n\n'
              '好处：改一个地方，整个应用都跟着变。\n'
              '就像 CSS 变量——定义一次，处处使用。',
            ),
            const CodeBlock(
              '// ThemeData 是整个应用的主题配置\n'
              "MaterialApp(\n"
              "  theme: ThemeData(\n"
              "    colorSchemeSeed: Colors.blue,  // 种子色 → 生成全套颜色\n"
              "    useMaterial3: true,            // Material 3 设计\n"
              "    brightness: Brightness.light,  // 明亮模式\n"
              "  ),\n"
              "  darkTheme: ThemeData(\n"
              "    colorSchemeSeed: Colors.blue,\n"
              "    brightness: Brightness.dark,   // 暗黑模式\n"
              "    useMaterial3: true,\n"
              "  ),\n"
              "  themeMode: ThemeMode.system,      // 跟随系统\n"
              ')',
              language: 'Dart',
            ),
            const Paragraph(
              'ThemeData 通过 colorSchemeSeed 自动生成 20+ 种颜色，'
              '不需要你一个个指定。这就是 Material 3 的「种子色」体系。',
            ),

            // ── 2. Material 3 颜色系统 ──
            const DividerLine(),
            const SectionHeader('2. Material 3 颜色系统 🎨', icon: Icons.color_lens),
            const Paragraph(
              'Material 3 围绕「种子色」自动生成完整的色板：\n\n'
              '🔹 primary —— 主色（按钮、标题、选中状态）\n'
              '🔸 secondary —— 辅色（浮层、辅助按钮）\n'
              '🔹 tertiary —— 第三色（强调、高亮）\n'
              '🔸 error —— 错误色\n'
              '🔹 surface —— 背景色\n'
              '🔸 onPrimary —— 主色上的文字色（确保对比度）',
            ),
            const CodeBlock(
              "// 用 ColorScheme 取色（推荐方式）\n"
              "final scheme = Theme.of(context).colorScheme;\n\n"
              "Container(\n"
              "  color: scheme.primary,    // 主色背景\n"
              "  child: Text(\n"
              "    'Hello',\n"
              "    style: TextStyle(\n"
              "      color: scheme.onPrimary, // 自动可读的文字色\n"
              "    ),\n"
              "  ),\n"
              ");\n\n"
              "// 背景色：适合卡片、列表\n"
              "Container(color: scheme.surface);\n\n"
              "// 辅色：适合次要操作\n"
              "Icon(..., color: scheme.secondary);",
              language: 'Dart',
            ),
            const TipBox(
              'Flutter 旧代码常用 Theme.of(context).primaryColor，'
              '新代码推荐用 colorScheme.primary。ColorScheme 的色值会随亮暗模式自动切换。',
              type: TipType.tip,
            ),

            // ── 3. Theme.of(context) ──
            const DividerLine(),
            const SectionHeader('3. Theme.of(context) 读取主题', icon: Icons.search),
            const Paragraph(
              '在任何 Widget 中都能用 Theme.of(context) 拿到当前主题。'
              '这是 Flutter 中最常用的设计模式之一。',
            ),
            const CodeBlock(
              "Widget build(BuildContext context) {\n"
              "  final theme = Theme.of(context);\n"
              "  final scheme = theme.colorScheme;\n"
              "  final textTheme = theme.textTheme;\n\n"
              "  return Column(children: [\n"
              "    // 使用 colorScheme\n"
              "    Container(color: scheme.primary),\n\n"
              "    // 使用 textTheme（预定义的文字样式）\n"
              "    Text('标题', style: textTheme.titleLarge),\n"
              "    Text('正文', style: textTheme.bodyMedium),\n\n"
              "    // 使用组件主题\n"
              "    Card(color: scheme.surface),  // 自动适配暗黑\n"
              "  ]);\n"
              '}',
              language: 'Dart',
            ),
            const Paragraph(
              'Theme.of(context) 必须在有 MaterialApp 包裹的地方调用。'
              '如果你的 Widget 在 MaterialApp 外面，会报错。',
            ),

            // ── 4. 暗黑模式 ──
            const DividerLine(),
            const SectionHeader('4. 暗黑模式适配', icon: Icons.dark_mode),
            const Paragraph(
              '暗黑模式是现代应用的标配。Flutter 支持三种模式：\n\n'
              '• ThemeMode.light —— 只显示亮色\n'
              '• ThemeMode.dark —— 只显示暗色\n'
              '• ThemeMode.system —— 跟随系统设置（推荐）\n\n'
              '关键原则：用 colorScheme 取色，而不是硬编码颜色。'
              '因为亮暗切换时 colorScheme 会自动给出合适的色值。',
            ),
            const CodeBlock(
              "// 正确做法：颜色自动适配亮暗\n"
              "Text(\n"
              "  'Hello',\n"
              "  style: TextStyle(\n"
              "    color: Theme.of(context).colorScheme.primary,\n"
              "  ),\n"
              ");\n\n"
              "// 错误做法：硬编码颜色，暗黑模式下不可读\n"
              "Text(\n"
              "  'Hello',\n"
              "  style: TextStyle(color: Colors.blue),  // ❌ 暗黑还是蓝\n"
              ");\n\n"
              "// 检测当前是否为暗黑模式\n"
              "final isDark = Theme.of(context).brightness == Brightness.dark;",
              language: 'Dart',
            ),
            const TipBox(
              '测试暗黑模式：用 ThemeData(brightness: Brightness.dark) 包裹你的页面，'
              '或者直接用 Flutter Inspector 切换主题预览。',
              type: TipType.caution,
            ),

            // ── 5. 交互演示 ──
            const DividerLine(),
            const SectionHeader('🧪 交互演示：主题切换', icon: Icons.touch_app),
            const Paragraph('切换下面的主题和颜色，观察 UI 如何自动响应。'),
            const SizedBox(height: 8),

            // 控制面板
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 亮暗切换
                  SwitchListTile(
                    title: const Text('暗黑模式'),
                    subtitle: const Text('切换亮色/暗色主题'),
                    secondary: Icon(_useDark ? Icons.dark_mode : Icons.light_mode),
                    value: _useDark,
                    onChanged: (v) => setState(() => _useDark = v),
                  ),
                  const Divider(),

                  // 主题色选择
                  const Text('选择主题色', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Colors.blue, Colors.teal, Colors.green,
                      Colors.orange, Colors.pink, Colors.purple,
                      Colors.indigo, Colors.cyan,
                    ].map((color) {
                      final selected = _primaryColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _primaryColor = color),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: selected ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: selected
                              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                              : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 预览卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.palette, color: theme.colorScheme.onPrimary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('主题预览', style: theme.textTheme.titleLarge),
                            Text(
                              isDark ? '当前：暗黑模式' : '当前：亮色模式',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: const Text('Primary'), backgroundColor: theme.colorScheme.primary, labelStyle: TextStyle(color: theme.colorScheme.onPrimary)),
                        Chip(label: const Text('Secondary'), backgroundColor: theme.colorScheme.secondary, labelStyle: TextStyle(color: theme.colorScheme.onSecondary)),
                        Chip(label: const Text('Tertiary'), backgroundColor: theme.colorScheme.tertiary, labelStyle: TextStyle(color: theme.colorScheme.onTertiary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                        FilledButton(onPressed: () {}, child: const Text('Filled')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const OutputBox(
              '切换主题色和暗黑模式，上面的按钮、卡片、文字颜色都会自动更新。\n'
              'colorScheme 自动处理颜色对比度，确保文字可读性。',
            ),

            // ── 6. Text Theme ──
            const DividerLine(),
            const SectionHeader('6. 文字主题（TextTheme）', icon: Icons.text_fields),
            const Paragraph(
              'Flutter 预定义了一套完整的文字层级（Type Scale），'
              '从 displayLarge（超大标题）到 labelSmall（小标签），共 13 个级别。'
            ),
            const CodeBlock(
              "final tt = Theme.of(context).textTheme;\n\n"
              "Text('displayLarge', style: tt.displayLarge),  // 57sp 大屏展示\n"
              "Text('headlineMedium', style: tt.headlineMedium), // 45sp 章节标题\n"
              "Text('titleLarge', style: tt.titleLarge),   // 22sp 页面标题\n"
              "Text('titleMedium', style: tt.titleMedium),   // 16sp 中等标题\n"
              "Text('bodyLarge', style: tt.bodyLarge),    // 16sp 正文\n"
              "Text('bodyMedium', style: tt.bodyMedium),   // 14sp 小字\n"
              "Text('labelLarge', style: tt.labelLarge),   // 14sp 按钮文字\n"
              "Text('labelSmall', style: tt.labelSmall),   // 11sp 小标签",
              language: 'Dart',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('displayLarge — 超大展示', style: theme.textTheme.displayLarge?.copyWith(fontSize: 22)),
                  Text('headlineMedium — 章节标题', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
                  Text('titleLarge — 页面标题', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('bodyLarge — 正文内容，这是最常用的文字样式，适合长段落阅读。',
                    style: theme.textTheme.bodyLarge),
                  Text('bodyMedium — 辅助文字，适合说明、注释等次要信息。',
                    style: theme.textTheme.bodyMedium),
                  Text('labelSmall — 小标签', style: theme.textTheme.labelSmall),
                ],
              ),
            ),

            // ── 7. Dynamic Color ──
            const DividerLine(),
            const SectionHeader('7. 动态取色（Dynamic Color）', icon: Icons.auto_awesome),
            const Paragraph(
              'Android 12+ 支持「Material You」动态取色——'
              '系统根据你的壁纸自动生成主题色。Flutter 的 dynamic_color 包可以读取这个颜色。',
            ),
            const CodeBlock(
              "// 在 pubspec.yaml 添加依赖：\n"
              "// dynamic_color: ^1.7.0\n\n"
              "// 导入\n"
              "import 'package:dynamic_color/dynamic_color.dart';\n\n"
              "// 包裹 MaterialApp\n"
              "DynamicColorBuilder(\n"
              "  builder: (lightDynamic, darkDynamic) {\n"
              "    return MaterialApp(\n"
              "      theme: lightDynamic != null\n"
              "        ? ThemeData(colorScheme: lightDynamic, useMaterial3: true)\n"
              "        : ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),\n"
              "    );\n"
              "  },\n"
              ");\n\n"
              "// 动态取色 fallback：设备不支持时用种子色方案",
              language: 'Dart',
            ),
            const TipBox(
              '本项目已集成 dynamic_color 包！在 settings_provider.dart 中可以看到 useDynamicColor 开关。',
              type: TipType.tip,
            ),

            // ── 8. 自定义扩展 ──
            const DividerLine(),
            const SectionHeader('8. 自定义主题扩展', icon: Icons.extension),
            const Paragraph(
              '除了 Flutter 内置的主题，还可以扩展自己的主题数据。'
              '用 ThemeData.extensions 可以注入自定义主题对象。',
            ),
            const CodeBlock(
              "// 1. 定义自定义主题类\n"
              "class AppColors extends ThemeExtension<AppColors> {\n"
              "  final Color success;\n"
              "  final Color warning;\n"
              "  const AppColors({required this.success, required this.warning});\n\n"
              "  @override\n"
              "  AppColors copyWith({Color? success, Color? warning}) =>\n"
              "    AppColors(success: success ?? this.success, warning: warning ?? this.warning);\n\n"
              "  @override\n"
              "  AppColors lerp(AppColors? other, double t) => AppColors(\n"
              "    success: Color.lerp(success, other?.success, t)!,\n"
              "    warning: Color.lerp(warning, other?.warning, t)!,\n"
              "  );\n"
              '}\n\n'
              "// 2. 在 ThemeData 中注册\n"
              "ThemeData(\n"
              "  extensions: const [AppColors(success: Colors.green, warning: Colors.orange)],\n"
              ");\n\n"
              "// 3. 使用\n"
              "final appColors = Theme.of(context).extension<AppColors>()!;\n"
              "Container(color: appColors.success);",
              language: 'Dart',
            ),

            // ── 小练习 ──
            const DividerLine(),
            const SectionHeader('✏️ 小练习', icon: Icons.edit),
            const Paragraph(
              '1. 创建一个 MaterialApp，设置 colorSchemeSeed 和亮暗两套主题\n'
              '2. 用 Theme.of(context).colorScheme 创建颜色调色板页面\n'
              '3. 添加 themeMode 切换开关（light/dark/system）\n'
              '4. 创建一个自定义 ThemeExtension 存储应用的 brandGradient',
            ),
            const TipBox(
              'flutter_theme_extension 是一个很强大的模式——它可以让你扩展任何自定义属性，并且自动支持亮暗切换和动画过渡。',
              type: TipType.tip,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
