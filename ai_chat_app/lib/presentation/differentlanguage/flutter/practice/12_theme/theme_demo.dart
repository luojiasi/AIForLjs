import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// ============================================================
/// Flutter 教程 · 第十二章：主题与样式完全指南
/// 涵盖：ThemeData、ColorScheme、Material 3、暗黑模式、
///       TextTheme、ThemeExtension、Dynamic Color、组件主题
/// ============================================================

class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  bool _useDark = false;
  MaterialColor _primaryColor = Colors.blue;
  double _fontScale = 1.0;
  bool _useM3 = true;
  int _selectedRadius = 1; // 0=squircle, 1=default, 2=round

  @override
  Widget build(BuildContext context) {
    final radiusValues = [4.0, 12.0, 28.0];
    final theme = ThemeData(
      colorSchemeSeed: _primaryColor,
      brightness: _useDark ? Brightness.dark : Brightness.light,
      useMaterial3: _useM3,
      fontFamily: null, // 使用系统默认
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (innerContext) {
          final t = Theme.of(innerContext);
          final scheme = t.colorScheme;
          final isDark = t.brightness == Brightness.dark;

          return Scaffold(
            appBar: AppBar(
              title: const Text('第12章 · 主题与样式'),
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ═══════════════════════════════════════
                // 章节目录
                // ═══════════════════════════════════════
                const SectionHeader('本章内容', icon: Icons.list),
                const Paragraph(
                  '① 理解 Theme（主题）—— 应用的视觉规范\n'
                  '② ThemeData —— 主题的配置中心\n'
                  '③ Material 3 颜色系统（ColorScheme）\n'
                  '④ Theme.of(context) —— 访问主题的标准方式\n'
                  '⑤ 暗黑模式适配 —— light theme + dark theme\n'
                  '⑥ TextTheme —— 文字层级系统\n'
                  '⑦ ThemeExtension —— 自定义主题扩展\n'
                  '⑧ Dynamic Color —— 跟随系统壁纸取色\n'
                  '⑨ 组件主题（Component Themes）\n'
                  '⑩ 主题切换实战',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 1. 理解 Theme
                // ═══════════════════════════════════════
                const SectionHeader('1. 什么是主题（Theme）？', icon: Icons.palette),
                const Paragraph(
                  '主题是应用的"视觉设计规范"的集中表达。它定义了一套设计 Token，让整个应用的 UI 保持视觉一致性。\n\n'
                  '类比理解：\n'
                  '  • HTML/CSS → Flutter\n'
                  '  • CSS 变量（--primary-color） → ColorScheme.primary\n'
                  '  • CSS 类（.btn, .card） → Component Theme\n'
                  '  • CSS @media (prefers-color-scheme) → darkTheme + ThemeMode.system\n'
                  '  • design-tokens.json → ThemeData\n\n'
                  '主题管理的核心价值：\n'
                  '① 改一处，全局生效 —— 修改主色，所有按钮/标题/选中态自动更新\n'
                  '② 亮暗自动切换 —— 一套代码，自动适配亮色和暗色\n'
                  '③ 品牌一致性 —— 确保所有页面使用相同的颜色/字体/圆角\n'
                  '④ 可测试 —— 主题数据是纯数据，可独立于 UI 进行单元测试\n\n'
                  'Flutter 的主题系统是 InheritedWidget 的经典应用：\n'
                  'MaterialApp 在根部创建一个 InheritedWidget 包裹 ThemeData，\n'
                  '任何后代 Widget 都可以通过 Theme.of(context) 读取。',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 2. ThemeData
                // ═══════════════════════════════════════
                const SectionHeader('2. ThemeData —— 主题配置中心', icon: Icons.settings),
                const Paragraph(
                  'ThemeData 是 Flutter 中最大的配置类之一，包含 200+ 个属性。\n'
                  '分为以下几个大类：\n\n'
                  '🎨 颜色类（最重要）：\n'
                  '  • colorScheme —— ColorScheme（Material 3 推荐，替代旧的颜色属性）\n'
                  '  • colorSchemeSeed —— 种子色（Material 3 一键生成全套颜色）\n'
                  '  • primaryColor / primarySwatch —— 旧版主色（M2 风格）\n'
                  '  • scaffoldBackgroundColor —— 页面背景色\n'
                  '  • canvasColor —— 默认容器背景色\n'
                  '  • dividerColor —— 分割线颜色\n'
                  '  • shadowColor —— 阴影颜色\n'
                  '  • splashColor / highlightColor —— 点击涟漪颜色\n\n'
                  '📝 文字类：\n'
                  '  • textTheme —— TextTheme（13 级文字层级）\n'
                  '  • primaryTextTheme —— 主色背景上的文字主题\n'
                  '  • fontFamily —— 全局字体\n'
                  '  • fontFamilyFallback —— 备用字体列表\n\n'
                  '🎯 视觉类：\n'
                  '  • brightness —— Brightness.light/dark\n'
                  '  • useMaterial3 —— 是否使用 Material 3 设计（默认 true）\n'
                  '  • visualDensity —— VisualDensity（紧凑/标准/舒适）\n'
                  '  • platform —— TargetPlatform（控制原生风格）\n\n'
                  '🔘 组件主题类（每个组件都有独立的 theme 属性）：\n'
                  '  • appBarTheme、cardTheme、chipTheme、dialogTheme\n'
                  '  • elevatedButtonTheme、outlinedButtonTheme、textButtonTheme\n'
                  '  • inputDecorationTheme、floatingActionButtonTheme\n'
                  '  • bottomNavigationBarTheme、tabBarTheme、snackBarTheme\n'
                  '  • ...共 30+ 个组件主题',
                ),
                const CodeBlock(
                  r'''// ── ThemeData 标准配置（Material 3）──
MaterialApp(
  theme: ThemeData(
    // ① 种子色：一键生成 ColorScheme（最重要！）
    colorSchemeSeed: Colors.blue,

    // ② 亮度
    brightness: Brightness.light,

    // ③ Material 3 开关（默认 true）
    useMaterial3: true,

    // ④ 字体
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      // 自定义文字层级（见后续章节）
    ),

    // ⑤ 视觉密度
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // ⑥ 组件主题（每个组件都有）
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ⑦ 页面过渡动画
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  ),

  // 暗黑主题（独立配置）
  darkTheme: ThemeData(
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.dark,
    useMaterial3: true,
  ),

  // 主题切换模式
  themeMode: ThemeMode.system,  // system / light / dark
);''',
                  language: 'Dart',
                ),
                const TipBox(
                  'Material 3 中，使用 colorSchemeSeed 比手动指定 primaryColor 更好。种子色会自动计算全套颜色，包括 onPrimary、primaryContainer 等衍生色，确保亮暗模式下都可读。',
                  type: TipType.info,
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 3. Material 3 ColorScheme
                // ═══════════════════════════════════════
                const SectionHeader('3. Material 3 颜色系统（ColorScheme）', icon: Icons.color_lens),
                const Paragraph(
                  'Material 3 的颜色系统围绕"种子色"（Seed Color）自动生成完整的色调调色板（Tonal Palette）。\n\n'
                  'ColorScheme 包含 30+ 个颜色角色，分为以下层级：\n\n'
                  '🎯 核心颜色（4 个）：\n'
                  '  • primary —— 主色，用于按钮、选中态、关键元素\n'
                  '  • secondary —— 辅色，用于浮层、辅助按钮、非关键强调\n'
                  '  • tertiary —— 第三色，用于高亮、对比强调\n'
                  '  • error —— 错误色，用于错误提示、删除按钮\n\n'
                  '📌 "on-" 系列（前景色，保证文字对比度）：\n'
                  '  • onPrimary —— 主色上的文字/图标色\n'
                  '  • onSecondary —— 辅色上的文字/图标色\n'
                  '  • onTertiary —— 第三色上的文字色\n'
                  '  • onError —— 错误色上的文字色\n'
                  '  • onSurface —— 背景色上的文字色\n'
                  '  • onSurfaceVariant —— 背景色上的次要文字色\n\n'
                  '📦 "Container" 系列（半透明容器背景）：\n'
                  '  • primaryContainer —— 主色的容器背景（比 primary 浅/暗）\n'
                  '  • onPrimaryContainer —— 容器上的文字色\n'
                  '  • secondaryContainer、tertiaryContainer、errorContainer\n\n'
                  '🏠 表面色：\n'
                  '  • surface —— 基础表面色\n'
                  '  • surfaceVariant —— 变体表面色\n'
                  '  • surfaceTint —— 表面色调覆盖\n'
                  '  • surfaceContainerHighest → surfaceContainerLowest（5 级容器色）\n'
                  '  • inverseSurface / onInverseSurface —— 反转表面色\n\n'
                  '🔒 其他：\n'
                  '  • outline / outlineVariant —— 轮廓/分割线\n'
                  '  • shadow / scrim —— 阴影/遮罩\n'
                  '  • inversePrimary —— 反转的主色',
                ),
                const CodeBlock(
                  r'''// ── ColorScheme 自动生成原理 ──
// 给定种子色（如 Colors.blue），Material 3 引擎会：
// 1. 计算 HCT（Hue-Chroma-Tone）色彩空间中的色调调色板
// 2. 基于亮度（light/dark）自动分配颜色角色
// 3. 保证每个 "on-" 颜色与其背景色的对比度 ≥ 4.5:1（WCAG AA）

// ── 手动构建 ColorScheme（高级用法）──
ColorScheme.fromSeed(
  seedColor: Colors.blue,              // 种子色
  brightness: Brightness.light,        // 亮度
  primary: Colors.indigo,              // 覆盖主色（可选）
  dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot, // 调色板变体
  // tonalSpot / fidelity / content / vibrant / expressive / neutral / monochrome
);

// ── 直接构造 ColorScheme（完全自定义）──
const ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6750A4),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFEADDFF),
  onPrimaryContainer: Color(0xFF21005D),
  secondary: Color(0xFF625B71),
  onSecondary: Color(0xFFFFFFFF),
  // ... 必须提供全部 30+ 个颜色（推荐用 fromSeed 代替）
);''',
                  language: 'Dart',
                ),
                const TipBox(
                  '手动构造 ColorScheme 时，必须确保前景色（on*）和背景色的对比度足够。Material 3 规范要求正文对比度 ≥ 4.5:1（WCAG AA）。用 fromSeed 可以自动保证对比度。',
                  type: TipType.warning,
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 4. Theme.of(context)
                // ═══════════════════════════════════════
                const SectionHeader('4. Theme.of(context) —— 访问主题的标准方式', icon: Icons.search),
                const Paragraph(
                  '在任何 Widget 的 build 方法中，都可以通过 Theme.of(context) 获取当前主题。\n'
                  '这是 InheritedWidget 模式的标准应用。\n\n'
                  'Theme.of(context) 返回的是距离最近的 Theme Widget 的数据。\n'
                  '这意味着你可以用 Theme Widget 包裹局部子树，覆盖该子树的主题！\n\n'
                  '三种访问方式：\n'
                  '  • Theme.of(context) —— 返回 ThemeData（全局主题）\n'
                  '  • Theme.of(context).colorScheme —— 返回 ColorScheme（推荐）\n'
                  '  • Theme.of(context).textTheme —— 返回 TextTheme\n\n'
                  'Theme Widget 的局部覆盖原理：\n'
                  '  Theme(data: Theme.of(context).copyWith(...), child: ...) —— 只覆盖指定属性\n'
                  '  Theme(data: newTheme, child: ...) —— 完全替换子树的主题',
                ),
                const CodeBlock(
                  r'''// ── 标准用法 ──
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Column(children: [
    // 用 colorScheme 取色
    Container(
      color: scheme.primaryContainer,
      child: Text('标题', style: TextStyle(color: scheme.onPrimaryContainer)),
    ),
    // 用 textTheme 取文字样式
    Text('正文内容', style: textTheme.bodyLarge),
  ]);
}

// ── 局部覆盖主题 ──
// 场景：某个页面需要特殊的背景色
Theme(
  data: Theme.of(context).copyWith(
    scaffoldBackgroundColor: Colors.black,
  ),
  child: Scaffold(
    body: ... // 这个 Scaffold 的背景色变成黑色
  ),
);

// ── 完全替换某个组件的主题 ──
// 场景：某个页面的按钮都是圆角 = 0
Theme(
  data: Theme.of(context).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: const BeveledRectangleBorder()),
    ),
  ),
  child: SomePage(),
);''',
                  language: 'Dart',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 5. 暗黑模式
                // ═══════════════════════════════════════
                const SectionHeader('5. 暗黑模式适配', icon: Icons.dark_mode),
                const Paragraph(
                  '暗黑模式是现代应用的标配。Flutter 通过 MaterialApp 的 darkTheme + themeMode 实现：\n\n'
                  '① MaterialApp 的两个主题属性：\n'
                  '  • theme —— 亮色主题（Brightness.light）\n'
                  '  • darkTheme —— 暗色主题（Brightness.dark）\n'
                  '  • themeMode —— 切换模式（system/light/dark）\n\n'
                  '② ThemeMode 枚举：\n'
                  '  • ThemeMode.system —— 跟随系统设置（推荐默认值）\n'
                  '  • ThemeMode.light —— 始终亮色\n'
                  '  • ThemeMode.dark —— 始终暗色\n\n'
                  '③ 暗黑适配的核心原则：\n'
                  '  用 colorScheme 取色，不要硬编码颜色。\n'
                  '  理由：colorScheme 在亮暗切换时自动给出合适的色值。\n'
                  '  Colors.blue 在亮色下是蓝色，在暗色下仍然是蓝色（可能对比度不足）；\n'
                  '  colorScheme.primary 在亮色下是浅蓝，在暗色下是深蓝（自动适配）。',
                ),
                const CodeBlock(
                  r'''// ── 正确做法：用 colorScheme ──
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
);
// 亮色：白底黑字  →  暗色：深灰底白字（自动！）

// ── 错误做法：硬编码颜色 ──
Container(
  color: Colors.white,  // ❌ 暗色下仍然白色，刺眼
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),  // ❌ 暗色下黑字看不清
  ),
);

// ── 判断当前是否为暗色模式 ──
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isDarkByPlatform = MediaQuery.of(context).platformBrightness == Brightness.dark;

  // 根据暗色模式做特殊布局
  return Container(
    decoration: BoxDecoration(
      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: ...,
  );
}''',
                  language: 'Dart',
                ),
                const TipBox(
                  '测试暗黑模式：开发时用 ThemeMode.dark 临时锁定暗黑，或者用 Flutter DevTools 切换主题。发布前务必 test 三种模式（light/dark/system）下的 UI。',
                  type: TipType.caution,
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 6. 交互演示
                // ═══════════════════════════════════════
                const SectionHeader('🧪 交互演示：主题切换实验室', icon: Icons.touch_app),
                const Paragraph('切换下面的主题参数，观察下方预览卡片的实时变化：'),
                const SizedBox(height: 8),

                // 控制面板
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    // 亮暗切换
                    SwitchListTile(
                      title: const Text('暗黑模式'),
                      subtitle: Text(_useDark ? '当前：暗色主题' : '当前：亮色主题'),
                      secondary: Icon(_useDark ? Icons.dark_mode : Icons.light_mode),
                      value: _useDark,
                      onChanged: (v) => setState(() => _useDark = v),
                    ),
                    const Divider(),
                    // M3 开关
                    SwitchListTile(
                      title: const Text('Material 3'),
                      subtitle: Text(_useM3 ? 'M3 风格（圆润、大色块）' : 'M2 风格（扁平、锐利）'),
                      value: _useM3,
                      onChanged: (v) => setState(() => _useM3 = v),
                    ),
                    const Divider(),
                    // 主题色选择
                    const Text('选择种子色（Seed Color）', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        Colors.blue, Colors.teal, Colors.green,
                        Colors.orange, Colors.pink, Colors.purple,
                        Colors.indigo, Colors.cyan, Colors.red,
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
                              boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null,
                            ),
                            child: selected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // 预览卡片
                _PreviewCard(useDark: _useDark, primaryColor: _primaryColor, useM3: _useM3),
                const SizedBox(height: 8),
                OutputBox(
                  '种子色: ${_primaryColor.toString().split('(').last.replaceAll(')', '')}\n'
                  '主题: ${_useDark ? "暗色" : "亮色"} | M3: ${_useM3 ? "开启" : "关闭"}\n'
                  'colorScheme.primary: ${scheme.primary.toHexString()}\n'
                  'colorScheme.onPrimary: ${scheme.onPrimary.toHexString()}\n'
                  'colorScheme.surface: ${scheme.surface.toHexString()}',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 7. TextTheme
                // ═══════════════════════════════════════
                const SectionHeader('7. TextTheme —— 文字层级系统', icon: Icons.text_fields),
                const Paragraph(
                  'Flutter 的 TextTheme 定义了 15 个文字层级（Type Scale）。这是 Material 3 规范的一部分：\n\n'
                  '📌 Display（展示级，最大）：\n'
                  '  • displayLarge (57sp) —— 超大标题，首页主标题\n'
                  '  • displayMedium (45sp) —— 大标题\n'
                  '  • displaySmall (36sp) —— 中标题\n\n'
                  '📌 Headline（标题级）：\n'
                  '  • headlineLarge (32sp) —— 页面主标题\n'
                  '  • headlineMedium (28sp) —— 区块标题\n'
                  '  • headlineSmall (24sp) —— 小标题\n\n'
                  '📌 Title（标题级）：\n'
                  '  • titleLarge (22sp) —— AppBar 标题、卡片标题\n'
                  '  • titleMedium (16sp) —— 列表标题、标签标题\n'
                  '  • titleSmall (14sp) —— 小标签标题\n\n'
                  '📌 Body（正文级）：\n'
                  '  • bodyLarge (16sp) —— 强调正文\n'
                  '  • bodyMedium (14sp) —— 标准正文（最常用）\n'
                  '  • bodySmall (12sp) —— 次要正文\n\n'
                  '📌 Label（标签级，最小）：\n'
                  '  • labelLarge (14sp) —— 按钮文字\n'
                  '  • labelMedium (12sp) —— 辅助标签\n'
                  '  • labelSmall (11sp) —— 最小标签（禁用提示等）',
                ),
                const CodeBlock(
                  r'''// ── 获取 TextTheme ──
final textTheme = Theme.of(context).textTheme;

// 使用预定义样式
Text('页面标题', style: textTheme.headlineMedium);
Text('卡片标题', style: textTheme.titleLarge);
Text('标准正文，用于大段文字描述。这是最常用的文字样式，适合阅读。',
  style: textTheme.bodyMedium,
);
Text('次要说明信息', style: textTheme.bodySmall);

// ── 自定义 TextTheme ──
ThemeData(
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  ),
);

// ── 扩展已有 TextTheme（基于默认值修改）──
ThemeData(
  textTheme: Theme.of(context).textTheme.copyWith(
    bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.8,  // 行高倍数
    ),
  ),
);''',
                  language: 'Dart',
                ),
                // TextTheme 预览
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                    color: scheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('displayLarge — 超大展示标题', style: t.textTheme.displayLarge?.copyWith(fontSize: 28, color: scheme.onSurface)),
                      Text('headlineMedium — 区块标题', style: t.textTheme.headlineMedium?.copyWith(fontSize: 22, color: scheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('titleLarge — 卡片/页面标题', style: t.textTheme.titleLarge?.copyWith(color: scheme.onSurface)),
                      Text('titleMedium — 列表项标题', style: t.textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
                      const SizedBox(height: 6),
                      Text('bodyLarge — 强调正文，适合重要段落的第一句话或简短强调内容。', style: t.textTheme.bodyLarge?.copyWith(color: scheme.onSurface)),
                      Text('bodyMedium — 标准正文。这是最常用的文字样式，适合大段阅读。Lorem ipsum dolor sit amet, consectetur adipiscing elit.', style: t.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      Text('bodySmall — 次要说明文字，适合脚注、附加信息等不重要的内容。', style: t.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text('labelLarge — 按钮文字', style: t.textTheme.labelLarge?.copyWith(color: scheme.primary)),
                      Text('labelSmall — 最小标签', style: t.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 8. ThemeExtension
                // ═══════════════════════════════════════
                const SectionHeader('8. ThemeExtension —— 自定义主题扩展', icon: Icons.extension),
                const Paragraph(
                  '除了 Flutter 内置的 ThemeData 属性，你还可以通过 ThemeExtension 扩展自己的主题数据。\n'
                  '这在团队项目中非常实用——可以定义品牌的颜色 Token、间距系统、圆角系统等。\n\n'
                  'ThemeExtension 的优势：\n'
                  '① 类型安全 —— 通过泛型获取，无需手动 cast\n'
                  '② 自动支持亮暗切换 —— 只需实现 lerp 方法\n'
                  '③ 动画过渡 —— lerp 让主题切换有平滑动画\n'
                  '④ 统一管理 —— 通过 Theme.of(context).extension<T>() 获取\n\n'
                  '实现步骤：\n'
                  '① 创建类，继承 ThemeExtension<T>\n'
                  '② 实现 copyWith 方法\n'
                  '③ 实现 lerp 方法（线性插值，用于主题动画）\n'
                  '④ 在 ThemeData.extensions 中注册',
                ),
                const CodeBlock(
                  r'''// ── 完整示例：品牌色扩展 ──
class BrandColors extends ThemeExtension<BrandColors> {
  final Color success;
  final Color warning;
  final Color info;
  final double borderRadius;
  final double spacing;

  const BrandColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.borderRadius,
    required this.spacing,
  });

  // copyWith：返回修改后的新实例（不可变模式）
  @override
  BrandColors copyWith({
    Color? success, Color? warning, Color? info,
    double? borderRadius, double? spacing,
  }) {
    return BrandColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
    );
  }

  // lerp：线性插值（用于亮暗切换动画）
  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      spacing: lerpDouble(spacing, other.spacing, t)!,
    );
  }
}

// ── 注册到主题 ──
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.blue,
    extensions: const [
      BrandColors(
        success: Color(0xFF4CAF50),
        warning: Color(0xFFFF9800),
        info: Color(0xFF2196F3),
        borderRadius: 12.0,
        spacing: 16.0,
      ),
    ],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [
      BrandColors(
        success: Color(0xFF66BB6A),   // 暗色下更亮
        warning: Color(0xFFFFB74D),
        info: Color(0xFF64B5F6),
        borderRadius: 12.0,
        spacing: 16.0,
      ),
    ],
  ),
);

// ── 使用 ──
Widget build(BuildContext context) {
  final brand = Theme.of(context).extension<BrandColors>()!;
  return Container(
    decoration: BoxDecoration(
      color: brand.success,
      borderRadius: BorderRadius.circular(brand.borderRadius),
    ),
    padding: EdgeInsets.all(brand.spacing),
    child: Text('成功！'),
  );
}''',
                  language: 'Dart',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 9. Dynamic Color
                // ═══════════════════════════════════════
                const SectionHeader('9. Dynamic Color —— 动态取色', icon: Icons.auto_awesome),
                const Paragraph(
                  'Android 12+ 引入了 Material You 动态取色功能——系统根据用户壁纸自动提取种子色，'
                  '应用可以使用这个颜色作为主题色。\n\n'
                  'Flutter 通过 dynamic_color 包支持此功能：\n'
                  '  • 在 Android 12+ 上：读取系统壁纸颜色\n'
                  '  • 在其他平台/版本：fallback 到手动指定的种子色\n\n'
                  '实现原理：\n'
                  '① 系统从壁纸中提取种子色（通过 Palette API）\n'
                  '② 应用通过 DynamicColorBuilder 获取 ColorScheme\n'
                  '③ 如果系统支持 → 使用动态色；否则 → fallback\n\n'
                  '本项目中已集成 dynamic_color，可以在 settings_provider.dart 中看到相关实现。',
                ),
                const CodeBlock(
                  r'''// pubspec.yaml
// dependencies:
//   dynamic_color: ^1.7.0

// ── 使用 DynamicColorBuilder ──
import 'package:dynamic_color/dynamic_color.dart';

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: ThemeData(
            // 优先使用动态色，否则 fallback
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const HomePage(),
        );
      },
    );
  }
}

// ── 动态取色的调色板变体 ──
ColorScheme.fromSeed(
  seedColor: Colors.blue,
  dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  // 可选变体：
  // tonalSpot      — 色调点（默认）
  // fidelity        — 高保真（最接近壁纸颜色）
  // content         — 内容色（适合内容为主的界面）
  // vibrant         — 鲜艳
  // expressive      — 表现力
  // neutral         — 中性
  // monochrome      — 单色
);''',
                  language: 'Dart',
                ),
                const TipBox(
                  '本项目已集成 dynamic_color 包！查看 settings_provider.dart 中的 useDynamicColor 开关，settings_screen.dart 中有完整的动态取色切换逻辑。',
                  type: TipType.tip,
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 10. 组件主题
                // ═══════════════════════════════════════
                const SectionHeader('10. 组件主题（Component Themes）', icon: Icons.widgets),
                const Paragraph(
                  'ThemeData 包含 30+ 个组件主题属性。通过统一配置组件样式，避免在每个 Widget 上重复设置。\n\n'
                  '常用组件主题一览：\n'
                  '  • appBarTheme —— AppBar 的外观\n'
                  '  • cardTheme —— Card 的外观\n'
                  '  • chipTheme —— Chip 的外观\n'
                  '  • dialogTheme —— Dialog 的外观\n'
                  '  • elevatedButtonTheme / outlinedButtonTheme / textButtonTheme —— 按钮\n'
                  '  • inputDecorationTheme —— 输入框外观（最常用）\n'
                  '  • floatingActionButtonTheme —— FAB\n'
                  '  • bottomNavigationBarTheme / navigationBarTheme —— 底部导航\n'
                  '  • tabBarTheme —— TabBar\n'
                  '  • snackBarTheme —— SnackBar\n'
                  '  • drawerTheme —— Drawer\n'
                  '  • dividerTheme —— Divider\n'
                  '  • iconTheme / primaryIconTheme —— 图标\n'
                  '  • listTileTheme —— ListTile\n'
                  '  • progressIndicatorTheme —— 进度条\n'
                  '  • sliderTheme —— Slider\n'
                  '  • switchTheme / checkboxTheme / radioTheme —— 开关/复选框',
                ),
                const CodeBlock(
                  r'''// ── 组件主题配置示例 ──
ThemeData(
  // AppBar：统一背景色和高度
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 2,
  ),

  // 卡片：统一圆角和边距
  cardTheme: CardTheme(
    elevation: 1,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
  ),

  // 输入框：统一外观
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: WidgetStateColor.resolveWith((states) => Colors.grey[100]!),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  // 按钮：统一最小尺寸和圆角
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Chip：统一样式
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(fontSize: 13),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),

  // 底部导航
  navigationBarTheme: NavigationBarThemeData(
    height: 80,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);''',
                  language: 'Dart',
                ),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 11. ColorScheme 色板展示
                // ═══════════════════════════════════════
                const SectionHeader('🧪 ColorScheme 实时色板', icon: Icons.palette),
                const Paragraph('当前主题下 ColorScheme 的所有颜色角色：'),
                const SizedBox(height: 8),
                _ColorSwatchGrid(scheme: scheme),
                const DividerLine(),

                // ═══════════════════════════════════════
                // 12. 最佳实践
                // ═══════════════════════════════════════
                const SectionHeader('11. 主题使用最佳实践', icon: Icons.lightbulb),
                const Paragraph(
                  '① 用 colorSchemeSeed 而不是手动拼 ColorScheme —— 让 Material 3 引擎自动计算\n'
                  '② 用 colorScheme.xxx 而不是 Colors.xxx —— 亮暗自动适配\n'
                  '③ 用 Theme.of(context) 而不是全局变量 —— 支持局部主题覆盖\n'
                  '④ 暗黑测试不要只在模拟器做 —— 真机上 OLED 屏幕和 LCD 屏幕显示效果不同\n'
                  '⑤ 组件主题统一配置 —— 不要在 100 个按钮上重复设置圆角\n'
                  '⑥ ThemeExtension 用于品牌设计 Token —— 颜色/间距/圆角/阴影等\n'
                  '⑦ 设置主题时同时设置 light 和 dark —— 即使用户不会切换，暗黑模式也是基本需求\n'
                  '⑧ 避免在 build 中创建 ThemeData —— 提取到 build 外面或用 const 构造函数',
                ),
                const DividerLine(),

                const SectionHeader('✏️ 小练习', icon: Icons.edit),
                const Paragraph(
                  '1. 创建一个完整的 MaterialApp，设置 colorSchemeSeed 和 light/dark 两套主题\n'
                  '2. 用 Theme.of(context).colorScheme 创建颜色调色板展示页（展示所有 30+ 个颜色角色）\n'
                  '3. 添加 themeMode 切换开关（light/dark/system）并持久化到 SharedPreferences\n'
                  '4. 创建自定义 ThemeExtension —— 存储 brandColors + brandGradient\n'
                  '5. 用 Theme Widget 局部覆盖某个页面的主题（如登录页全屏深色背景）\n'
                  '6. 集成 dynamic_color 包，Android 12+ 设备上自动使用系统壁纸色\n'
                  '7. 自定义 TextTheme，将默认字体替换为 Google Fonts 中的某个字体',
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 预览卡片
// ═══════════════════════════════════════════════
class _PreviewCard extends StatelessWidget {
  final bool useDark;
  final MaterialColor primaryColor;
  final bool useM3;

  const _PreviewCard({
    required this.useDark,
    required this.primaryColor,
    required this.useM3,
  });

  @override
  Widget build(BuildContext context) {
    final previewTheme = ThemeData(
      colorSchemeSeed: primaryColor,
      brightness: useDark ? Brightness.dark : Brightness.light,
      useMaterial3: useM3,
    );

    return Theme(
      data: previewTheme,
      child: Builder(
        builder: (ctx) {
          final t = Theme.of(ctx);
          final s = t.colorScheme;
          final isDark = t.brightness == Brightness.dark;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // 标题行
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: s.primary,
                      borderRadius: BorderRadius.circular(useM3 ? 14 : 4),
                    ),
                    child: Icon(Icons.palette, color: s.onPrimary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('主题预览', style: t.textTheme.titleLarge?.copyWith(color: s.onSurface)),
                      Text(
                        isDark ? '暗色模式' : '亮色模式',
                        style: t.textTheme.bodySmall?.copyWith(color: s.onSurfaceVariant),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 16),
                // 颜色 Chips
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: const Text('Primary'), backgroundColor: s.primary, labelStyle: TextStyle(color: s.onPrimary, fontSize: 12)),
                  Chip(label: const Text('Secondary'), backgroundColor: s.secondary, labelStyle: TextStyle(color: s.onSecondary, fontSize: 12)),
                  Chip(label: const Text('Tertiary'), backgroundColor: s.tertiary, labelStyle: TextStyle(color: s.onTertiary, fontSize: 12)),
                  Chip(label: const Text('Error'), backgroundColor: s.error, labelStyle: TextStyle(color: s.onError, fontSize: 12)),
                  Chip(label: const Text('Surface'), backgroundColor: s.surface, labelStyle: TextStyle(color: s.onSurface, fontSize: 12)),
                ]),
                const SizedBox(height: 16),
                // 按钮
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                  OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                  FilledButton(onPressed: () {}, child: const Text('Filled')),
                  TextButton(onPressed: () {}, child: const Text('Text')),
                ]),
                const SizedBox(height: 12),
                // 输入框
                TextField(
                  decoration: InputDecoration(
                    labelText: '示例输入框',
                    hintText: '观察边框和颜色',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(useM3 ? 12 : 4)),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ColorScheme 色板 Grid
// ═══════════════════════════════════════════════
class _ColorSwatchGrid extends StatelessWidget {
  final ColorScheme scheme;
  const _ColorSwatchGrid({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final colors = <_SwatchItem>[
      _SwatchItem('primary', scheme.primary, scheme.onPrimary),
      _SwatchItem('onPrimary', scheme.onPrimary, scheme.primary),
      _SwatchItem('primaryContainer', scheme.primaryContainer, scheme.onPrimaryContainer),
      _SwatchItem('secondary', scheme.secondary, scheme.onSecondary),
      _SwatchItem('onSecondary', scheme.onSecondary, scheme.secondary),
      _SwatchItem('secondaryContainer', scheme.secondaryContainer, scheme.onSecondaryContainer),
      _SwatchItem('tertiary', scheme.tertiary, scheme.onTertiary),
      _SwatchItem('error', scheme.error, scheme.onError),
      _SwatchItem('errorContainer', scheme.errorContainer, scheme.onErrorContainer),
      _SwatchItem('surface', scheme.surface, scheme.onSurface),
      _SwatchItem('onSurface', scheme.onSurface, scheme.surface),
      _SwatchItem('surfaceVariant', scheme.surfaceVariant, scheme.onSurfaceVariant),
      _SwatchItem('surfaceContainer', scheme.surfaceContainerHighest, scheme.onSurface),
      _SwatchItem('outline', scheme.outline, scheme.surface),
      _SwatchItem('outlineVariant', scheme.outlineVariant, scheme.surface),
    ];

    return Wrap(
      spacing: 6, runSpacing: 6,
      children: colors.map((item) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(children: [
            Text(item.label, style: TextStyle(fontSize: 9, color: item.fg, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.bg.toHexString(), style: TextStyle(fontSize: 8, color: item.fg.withOpacity(0.7))),
          ]),
        );
      }).toList(),
    );
  }
}

class _SwatchItem {
  final String label;
  final Color bg;
  final Color fg;
  const _SwatchItem(this.label, this.bg, this.fg);
}

// ═══════════════════════════════════════════════
// 扩展方法
// ═══════════════════════════════════════════════
extension ColorToHex on Color {
  String toHexString() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
