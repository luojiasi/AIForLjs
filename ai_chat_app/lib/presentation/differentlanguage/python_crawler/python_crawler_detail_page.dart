import 'package:flutter/material.dart';
import 'package:ai_chat_app/presentation/shared/tutorial_widgets.dart';
import 'python_crawler_data.dart';

class PythonCrawlerDetailPage extends StatefulWidget {
  final int projectIndex;

  const PythonCrawlerDetailPage({super.key, required this.projectIndex});

  @override
  State<PythonCrawlerDetailPage> createState() => _PythonCrawlerDetailPageState();
}

class _PythonCrawlerDetailPageState extends State<PythonCrawlerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  CrawlerProject get _project {
    final idx = widget.projectIndex;
    if (idx >= 0 && idx < crawlerProjects.length) {
      return crawlerProjects[idx];
    }
    return crawlerProjects[0];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '项目概览'),
            Tab(text: '教程内容'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(project, theme),
          _buildTutorialTab(project, theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(CrawlerProject project, ThemeData theme) {
    final difficultyColor = project.difficulty == '入门'
        ? Colors.green
        : project.difficulty == '中级'
            ? Colors.orange
            : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [project.color.withValues(alpha: 0.8), project.color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.difficulty,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Icon(project.icon, color: Colors.white.withValues(alpha: 0.7), size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  project.description,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: project.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _OverviewStat(
                icon: Icons.menu_book,
                label: '${project.sections.length} 个章节',
                color: project.color,
              ),
              const SizedBox(width: 12),
              _OverviewStat(
                icon: Icons.schedule,
                label: '约 ${project.sections.length * 20} 分钟',
                color: project.color,
              ),
              const SizedBox(width: 12),
              _OverviewStat(
                icon: Icons.school,
                label: project.difficulty,
                color: difficultyColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Overview section
          SectionHeader('项目概述', icon: Icons.info_outline),
          const SizedBox(height: 8),
          _buildMarkdownContent(project.overview, theme),

          const SizedBox(height: 20),

          // Why learn section
          SectionHeader('为什么学这个？', icon: Icons.lightbulb_outline),
          const SizedBox(height: 8),
          _buildMarkdownContent(project.whyLearn, theme),

          const SizedBox(height: 24),

          // Tutorial outline
          SectionHeader('教程大纲', icon: Icons.list_alt),
          const SizedBox(height: 8),
          ...project.sections.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: project.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: project.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Icon(entry.value.icon, size: 18, color: project.color.withValues(alpha: 0.6)),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Study tips
          TipBox(
            '建议按顺序学习 4 个项目：Requests+BS4 → Scrapy → Playwright → Crawl4AI。\n'
            '每个项目的代码都可以直接复制运行。',
            type: TipType.tip,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialTab(CrawlerProject project, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: project.sections.length + 1, // +1 for the tip at the top
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TipBox(
              '下方代码均可直接复制运行。点击代码块右上角的复制图标即可复制完整代码到剪贴板。',
              type: TipType.info,
            ),
          );
        }

        final section = project.sections[index - 1];
        return _buildTutorialSection(section, project.color, theme);
      },
    );
  }

  Widget _buildTutorialSection(CrawlerTutorialSection section, Color accentColor, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(section.icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildMarkdownContent(section.content, theme),
        const SizedBox(height: 24),
        Divider(color: Colors.grey[200]),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Simple markdown-like content renderer
  Widget _buildMarkdownContent(String content, ThemeData theme) {
    final lines = content.split('\n');
    final widgets = <Widget>[];
    final codeLines = <String>[];
    bool inCode = false;
    String? codeLang;

    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          // End of code block
          if (codeLines.isNotEmpty) {
            widgets.add(CodeBlock(
              codeLines.join('\n').trimRight(),
              language: codeLang ?? 'python',
            ));
            codeLines.clear();
          }
          inCode = false;
          codeLang = null;
        } else {
          // Start of code block
          inCode = true;
          final lang = line.trimLeft().replaceAll('`', '').trim();
          codeLang = lang.isNotEmpty ? lang : null;
        }
        continue;
      }

      if (inCode) {
        codeLines.add(line);
        continue;
      }

      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Headers (##, ###)
      if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(
            trimmed.replaceAll(RegExp(r'^###\s*'), ''),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
        ));
        continue;
      }

      if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            trimmed.replaceAll(RegExp(r'^##\s*'), ''),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ));
        continue;
      }

      // Bold text (for emphasis like **text**)
      if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
        final boldText = trimmed.substring(2, trimmed.length - 2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(boldText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ));
        continue;
      }

      // Table rows (| ... |)
      if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
        // Skip separator rows (|---|---|)
        if (RegExp(r'^\|[\s\-:]+\|').hasMatch(trimmed)) continue;

        final cells = trimmed.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
        if (cells.isEmpty) continue;

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: cells.map((cell) {
              // Bold cells
              final isBold = cell.startsWith('**') && cell.endsWith('**');
              final cellText = isBold ? cell.substring(2, cell.length - 2) : cell;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    cellText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                      color: isBold ? theme.colorScheme.onSurface : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
        continue;
      }

      // List items (- or 1.)
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final text = trimmed.replaceAll(RegExp(r'^[-*]\s*'), '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(child: _buildInlineText(text)),
            ],
          ),
        ));
        continue;
      }

      // Numbered list
      final numberedMatch = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(trimmed);
      if (numberedMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${numberedMatch.group(1)}. ', style: const TextStyle(fontSize: 14)),
              Expanded(child: _buildInlineText(numberedMatch.group(2)!)),
            ],
          ),
        ));
        continue;
      }

      // Regular text
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _buildInlineText(trimmed),
      ));
    }

    if (inCode && codeLines.isNotEmpty) {
      widgets.add(CodeBlock(
        codeLines.join('\n').trimRight(),
        language: codeLang ?? 'python',
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  /// Handle inline code (text between backticks)
  Widget _buildInlineText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'`([^`]+)`');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.6),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.red.shade700,
          backgroundColor: Colors.grey.shade100,
          height: 1.4,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.6),
      ));
    }

    if (spans.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.6));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _OverviewStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _OverviewStat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
