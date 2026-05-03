import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 互动演示：Todo CLI 模拟器
// ─────────────────────────────────────────────────────────────
class _TodoCliDemo extends StatefulWidget {
  const _TodoCliDemo();
  @override
  State<_TodoCliDemo> createState() => _TodoCliDemoState();
}

class _TodoCliDemoState extends State<_TodoCliDemo> {
  final List<String> _todos = ['学Python', '做项目', '复习Dart'];
  String _newTask = '';
  final Set<int> _completedIdx = {};
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: 'Todo CLI 模拟器',
      subtitle: '模拟 Python 命令行待办事项管理器',
      children: [
        // 输入区
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '新任务',
                  hintText: '输入任务名称...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _newTask = v),
                onSubmitted: (_) => _addTask(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _newTask.trim().isEmpty ? null : _addTask,
              child: const Text('添加任务'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 任务列表
        if (_todos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('暂无任务', style: TextStyle(color: Colors.grey)),
          )
        else
          Column(
            children: List.generate(_todos.length, (i) {
              final done = _completedIdx.contains(i);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: done,
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _completedIdx.add(i);
                      } else {
                        _completedIdx.remove(i);
                      }
                    }),
                  ),
                  title: Text(
                    _todos[i],
                    style: TextStyle(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? Colors.grey : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    onPressed: () => setState(() {
                      _todos.removeAt(i);
                      _completedIdx.removeWhere((idx) => idx == i);
                      // Re-map indices above the removed one
                      final updated = _completedIdx
                          .map((idx) => idx > i ? idx - 1 : idx)
                          .toSet();
                      _completedIdx
                        ..clear()
                        ..addAll(updated);
                    }),
                  ),
                ),
              );
            }),
          ),
        const SizedBox(height: 8),
        // Python 代码示例
        const LiveCodeBlock(
          '''import argparse, json, os

TODO_FILE = "todos.json"

def load_todos():
    if os.path.exists(TODO_FILE):
        with open(TODO_FILE) as f:
            return json.load(f)
    return []

def save_todos(todos):
    with open(TODO_FILE, "w") as f:
        json.dump(todos, f, ensure_ascii=False)

def add_task(task):
    todos = load_todos()
    todos.append({"task": task, "done": False})
    save_todos(todos)
    print(f"已添加: {task}")

parser = argparse.ArgumentParser(description="Todo CLI")
parser.add_argument("command", choices=["add","list","done","delete"])
parser.add_argument("--task", help="任务名称")
parser.add_argument("--id", type=int, help="任务ID")''',
          language: 'python',
        ),
        const SizedBox(height: 8),
        LiveOutputBox(
          '${_todos.length} 个任务，${_completedIdx.length} 个已完成',
          label: '任务统计',
        ),
      ],
    );
  }

  void _addTask() {
    final task = _newTask.trim();
    if (task.isEmpty) return;
    setState(() {
      _todos.add(task);
      _newTask = '';
      _controller.clear();
    });
  }
}

/// Python 第12章：综合实战项目
/// 三个完整实战项目：
///   1. 命令行待办事项管理器 (Todo CLI)
///   2. 文件批量处理工具
///   3. 简易数据爬虫 + 分析
class PythonProjectPractice extends StatelessWidget {
  const PythonProjectPractice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第12章 综合实战'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 本章概览 ──
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① 项目一：命令行待办事项管理器（Todo CLI）\n'
            '② 项目二：文件批量处理工具\n'
            '③ 项目三：简易数据爬虫 + 分析',
          ),
          const TipBox(
            '本章通过三个完整的实战项目，综合运用 Python 的核心知识点：'
            '文件操作、数据处理、网络请求、命令行交互等。'
            '建议亲手敲一遍代码并运行，效果远好于只看不练。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ══════════════════════════════════════════════════════════════
          // PROJECT 1: 命令行待办事项管理器
          // ══════════════════════════════════════════════════════════════
          const SectionHeader('项目一：命令行待办事项管理器', icon: Icons.checklist),
          const Paragraph(
            '一个基于命令行的待办事项管理工具。用户可以通过终端命令添加、查看、'
            '完成和删除待办事项。数据通过 JSON 文件持久化存储，'
            '即使关闭终端再打开，数据也不会丢失。',
          ),
          const Paragraph(
            '涉及知识点：argparse（命令行解析）、json（数据持久化）、'
            'datetime（时间处理）、pathlib（文件路径）',
          ),

          const SectionHeader('需求分析', icon: Icons.lightbulb),
          const StepItem(
            step: 1,
            title: '支持四种操作',
            description: 'add（添加待办）、list（列出事项）、done（标记完成）、delete（删除任务）',
          ),
          const StepItem(
            step: 2,
            title: '命令行参数解析',
            description: '使用 argparse 模块定义子命令和参数，支持 --all 等可选标志',
          ),
          const StepItem(
            step: 3,
            title: '数据持久化',
            description: '用 JSON 文件存储在用户目录下，程序启动时自动加载，修改后自动保存',
          ),
          const StepItem(
            step: 4,
            title: '友好的输出',
            description: '带表格线和 Emoji 图标的终端输出，提升用户体验',
          ),

          const SectionHeader('设计思路', icon: Icons.architecture),
          const Paragraph(
            '1. 用 argparse 的 subparsers 定义四个子命令\n'
            '2. 设计 TaskManager 类，封装所有操作逻辑\n'
            '3. 用 json.dumps / json.loads 读写 tasks.json\n'
            '4. 每个任务用字典表示，包含 id / title / created_at / done 四个字段\n'
            '5. _next_id() 自动递增生成唯一 ID\n'
            '6. 主函数根据解析到的子命令名称调用相应方法',
          ),

          const SectionHeader('完整代码', icon: Icons.code),
          const CodeBlock(r'''
import argparse
import json
from datetime import datetime
from pathlib import Path

DATA_FILE = Path.home() / ".todo_tasks.json"


class TaskManager:
    """待办事项管理器"""

    def __init__(self):
        self.tasks = self._load()

    def _load(self):
        """从 JSON 文件加载任务"""
        if DATA_FILE.exists():
            return json.loads(DATA_FILE.read_text(encoding="utf-8"))
        return []

    def _save(self):
        """保存任务到 JSON 文件"""
        DATA_FILE.write_text(
            json.dumps(self.tasks, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    def _next_id(self):
        """生成下一个任务 ID"""
        if not self.tasks:
            return 1
        return max(t["id"] for t in self.tasks) + 1

    def add(self, title):
        """添加待办事项"""
        task = {
            "id": self._next_id(),
            "title": title,
            "created_at": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "done": False,
        }
        self.tasks.append(task)
        self._save()
        print(f"已添加: [{task['id']}] {title}")

    def list_tasks(self, show_all=False):
        """列出待办事项"""
        if not self.tasks:
            print("暂无待办事项")
            return

        tasks = self.tasks if show_all else [t for t in self.tasks if not t["done"]]

        if not tasks:
            print("所有任务都已完成！")
            return

        print(f"\n{'='*55}")
        print(f"{'ID':<4} {'状态':<8} {'标题':<25} {'创建时间'}")
        print(f"{'='*55}")
        for t in tasks:
            status = "已完成" if t["done"] else "待办"
            print(f"{t['id']:<4} {status:<8} {t['title']:<25} {t['created_at']}")
        print(f"{'='*55}")
        print(f"共 {len(tasks)} 项\n")

    def done(self, task_id):
        """标记任务为已完成"""
        for t in self.tasks:
            if t["id"] == task_id:
                t["done"] = True
                self._save()
                print(f"任务 [{task_id}] 已标记为完成: {t['title']}")
                return
        print(f"未找到 ID 为 {task_id} 的任务")

    def delete(self, task_id):
        """删除任务"""
        for i, t in enumerate(self.tasks):
            if t["id"] == task_id:
                removed = self.tasks.pop(i)
                self._save()
                print(f"已删除: [{removed['id']}] {removed['title']}")
                return
        print(f"未找到 ID 为 {task_id} 的任务")


def main():
    parser = argparse.ArgumentParser(
        description="命令行待办事项管理器",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", help="可用命令")

    # add 子命令
    add_parser = subparsers.add_parser("add", help="添加待办事项")
    add_parser.add_argument("title", help="待办事项内容")

    # list 子命令
    list_parser = subparsers.add_parser("list", help="列出待办事项")
    list_parser.add_argument("-a", "--all", action="store_true",
                             help="显示所有任务（包括已完成）")

    # done 子命令
    done_parser = subparsers.add_parser("done", help="标记任务完成")
    done_parser.add_argument("id", type=int, help="任务 ID")

    # delete 子命令
    delete_parser = subparsers.add_parser("delete", help="删除任务")
    delete_parser.add_argument("id", type=int, help="任务 ID")

    args = parser.parse_args()
    manager = TaskManager()

    if args.command == "add":
        manager.add(args.title)
    elif args.command == "list":
        manager.list_tasks(show_all=args.all)
    elif args.command == "done":
        manager.done(args.id)
    elif args.command == "delete":
        manager.delete(args.id)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
''', language: 'Python'),

          const SectionHeader('运行示例', icon: Icons.terminal),
          const OutputBox(r'''
$ python todo.py add "学习 Python 综合实战"
已添加: [1] 学习 Python 综合实战

$ python todo.py add "整理笔记"
已添加: [2] 整理笔记

$ python todo.py list

=======================================================
ID   状态      标题                       创建时间
=======================================================
1    待办      学习 Python 综合实战        2025-03-20 10:30
2    待办      整理笔记                    2025-03-20 10:31
=======================================================
共 2 项

$ python todo.py done 1
任务 [1] 已标记为完成: 学习 Python 综合实战

$ python todo.py list -a

=======================================================
ID   状态      标题                       创建时间
=======================================================
1    已完成    学习 Python 综合实战        2025-03-20 10:30
2    待办      整理笔记                    2025-03-20 10:31
=======================================================
共 2 项

$ python todo.py delete 2
已删除: [2] 整理笔记
'''),

          const SectionHeader('扩展思路', icon: Icons.extension),
          const Paragraph(
            '• 增加优先级字段（高/中/低），支持按优先级排序\n'
            '• 增加截止日期功能，到期自动提醒\n'
            '• 支持分类/标签功能，按分类筛选\n'
            '• 添加交互式模式（REPL），不用每次输完整命令\n'
            '• 导出为 CSV / Markdown / HTML 格式\n'
            '• 增加搜索功能：按关键词查找任务',
          ),
          const DividerLine(),

          // ══════════════════════════════════════════════════════════════
          // PROJECT 2: 文件批量处理工具
          // ══════════════════════════════════════════════════════════════
          const SectionHeader('项目二：文件批量处理工具', icon: Icons.folder_special),
          const Paragraph(
            '一个批量文件处理工具，能够递归遍历目录树、按多种条件筛选文件、'
            '执行批量重命名/移动/压缩等操作。特别适用于整理下载文件夹、'
            '归档旧文件、批量处理照片等场景。',
          ),
          const Paragraph(
            '涉及知识点：pathlib（路径操作）、os.walk / Path.rglob（目录遍历）、'
            'shutil（复制/移动/压缩）、datetime（时间计算）',
          ),

          const SectionHeader('需求分析', icon: Icons.lightbulb),
          const StepItem(
            step: 1,
            title: '递归遍历目录',
            description: '遍历指定目录下所有文件和子目录，收集完整的文件列表',
          ),
          const StepItem(
            step: 2,
            title: '多条件筛选',
            description: '支持按扩展名、文件大小范围、修改日期范围组合筛选',
          ),
          const StepItem(
            step: 3,
            title: '三种操作模式',
            description: '预览模式（仅显示不执行）、批量重命名、按分类移动到子目录',
          ),
          const StepItem(
            step: 4,
            title: '压缩归档',
            description: '将筛选结果打包为 ZIP / tar 格式的归档文件',
          ),

          const SectionHeader('设计思路', icon: Icons.architecture),
          const Paragraph(
            '1. 设计 FileFilter 类，构造时收集所有文件，之后用链式调用筛选\n'
            '2. 每个筛选方法（by_extension / by_size / by_date）返回 self，支持链式\n'
            '3. 批量重命名支持：添加前缀/后缀、文本替换、序号化命名\n'
            '4. 移动操作按扩展名自动归类到不同子目录（如 .jpg -> JPG/ 目录）\n'
            '5. 用 shutil.make_archive 和 shutil.rmtree 实现临时打包清理',
          ),

          const SectionHeader('完整代码', icon: Icons.code),
          const CodeBlock(r'''
import shutil
from pathlib import Path
from datetime import datetime, timedelta


class FileFilter:
    """文件筛选器 - 链式调用"""

    def __init__(self, base_dir):
        self.base_dir = Path(base_dir)
        if not self.base_dir.is_dir():
            raise NotADirectoryError(f"目录不存在: {base_dir}")
        # 递归收集所有文件
        self.files = [f for f in self.base_dir.rglob("*") if f.is_file()]

    def by_extension(self, *exts):
        """按扩展名筛选，传入 .txt, .jpg, .py 等"""
        exts = tuple(e.lower() if e.startswith(".") else f".{e}"
                     for e in exts)
        self.files = [f for f in self.files
                      if f.suffix.lower() in exts]
        return self

    def by_size(self, min_bytes=0, max_bytes=None):
        """按文件大小筛选（字节）"""
        self.files = [f for f in self.files
                      if f.stat().st_size >= min_bytes]
        if max_bytes is not None:
            self.files = [f for f in self.files
                          if f.stat().st_size <= max_bytes]
        return self

    def by_date(self, days=None, before=None, after=None):
        """按修改日期筛选"""
        now = datetime.now()
        if days is not None:
            cutoff = now - timedelta(days=days)
            self.files = [
                f for f in self.files
                if datetime.fromtimestamp(f.stat().st_mtime) >= cutoff
            ]
        if before is not None:
            dt = datetime.strptime(before, "%Y-%m-%d")
            self.files = [
                f for f in self.files
                if datetime.fromtimestamp(f.stat().st_mtime) <= dt
            ]
        if after is not None:
            dt = datetime.strptime(after, "%Y-%m-%d")
            self.files = [
                f for f in self.files
                if datetime.fromtimestamp(f.stat().st_mtime) >= dt
            ]
        return self

    def preview(self):
        """预览筛选结果（不执行任何修改）"""
        total_size = sum(f.stat().st_size for f in self.files)
        print(f"\n目录: {self.base_dir}")
        print(f"匹配文件数: {len(self.files)}")
        print(f"总大小: {total_size / 1024:.1f} KB\n")
        for f in self.files:
            size_kb = f.stat().st_size / 1024
            mtime = datetime.fromtimestamp(f.stat().st_mtime)
            rel = f.relative_to(self.base_dir)
            print(f"  {rel}  ({size_kb:.1f} KB, {mtime:%Y-%m-%d})")
        return self

    def rename_batch(self, prefix="", suffix="",
                     old_text="", new_text="", sequential=False):
        """批量重命名文件"""
        for i, f in enumerate(self.files, 1):
            stem = f.stem
            if old_text and new_text:
                stem = stem.replace(old_text, new_text)
            if sequential:
                stem = f"{prefix or 'file'}_{i:03d}"
            else:
                stem = prefix + stem + suffix

            new_path = f.with_name(stem + f.suffix)
            if new_path != f:
                if new_path.exists():
                    print(f"  跳过（目标已存在）: {new_path.name}")
                    continue
                f.rename(new_path)
                print(f"  重命名: {f.name} -> {new_path.name}")
        print(f"重命名完成，共处理 {len(self.files)} 个文件")
        return self

    def move_by_category(self, target_dir):
        """按扩展名分类移动到子目录"""
        target = Path(target_dir)
        target.mkdir(parents=True, exist_ok=True)

        for f in self.files:
            ext = f.suffix.lower().lstrip(".") or "no_ext"
            cat_dir = target / ext.upper()
            cat_dir.mkdir(exist_ok=True)
            dest = cat_dir / f.name

            # 处理重名文件
            if dest.exists():
                counter = 1
                while True:
                    dest = cat_dir / f"{f.stem}_{counter}{f.suffix}"
                    if not dest.exists():
                        break
                    counter += 1

            shutil.move(str(f), str(dest))
            print(f"  移动: {f.name} -> {dest}")

        print(f"分类完成，共移动 {len(self.files)} 个文件")
        return self

    def archive(self, output_name="archive", fmt="zip"):
        """压缩匹配的文件到归档文件"""
        if not self.files:
            print("没有文件可压缩")
            return self

        temp_dir = Path(output_name + "_temp")
        temp_dir.mkdir(exist_ok=True)

        for f in self.files:
            shutil.copy2(str(f), str(temp_dir / f.name))

        archive_path = shutil.make_archive(output_name, fmt, str(temp_dir))
        shutil.rmtree(str(temp_dir))

        archive_size = Path(archive_path).stat().st_size / 1024
        print(f"已创建归档: {archive_path}")
        print(f"归档大小: {archive_size:.1f} KB")
        print(f"包含文件: {len(self.files)} 个")
        return self


def main():
    """交互式演示"""
    import sys

    base = input("请输入目标目录路径: ").strip()
    try:
        filter_ = FileFilter(base)
    except (NotADirectoryError, FileNotFoundError) as e:
        print(f"错误: {e}")
        sys.exit(1)

    # 示例1：查找所有图片文件（5MB 以内）
    print("\n--- 示例1: 查找所有图片文件 (5MB以内) ---")
    (filter_
     .by_extension(".jpg", ".png", ".gif")
     .by_size(max_bytes=5 * 1024 * 1024)
     .preview())

    # 示例2：查找最近7天修改的文本文件
    print("\n--- 示例2: 最近7天修改的文本文件 ---")
    (FileFilter(base)
     .by_extension(".txt", ".md", ".py", ".json")
     .by_date(days=7)
     .preview())

    # 示例3：压缩所有 PDF 文件
    print("\n--- 示例3: 压缩所有 PDF 文件 ---")
    (FileFilter(base)
     .by_extension(".pdf")
     .archive("pdf_backup", "zip"))


if __name__ == "__main__":
    main()
''', language: 'Python'),

          const SectionHeader('运行示例', icon: Icons.terminal),
          const OutputBox(r'''
$ python file_batch.py
请输入目标目录路径: /home/user/Downloads/test

--- 示例1: 查找所有图片文件 (5MB以内) ---

目录: /home/user/Downloads/test
匹配文件数: 3
总大小: 4770.6 KB

  photo1.jpg  (245.6 KB, 2025-03-18)
  screenshot.png  (1024.8 KB, 2025-03-19)
  animation.gif  (3500.2 KB, 2025-03-15)

--- 示例2: 最近7天修改的文本文件 ---

目录: /home/user/Downloads/test
匹配文件数: 2
总大小: 15.7 KB

  notes.md  (12.5 KB, 2025-03-20)
  script.py  (3.2 KB, 2025-03-18)

--- 示例3: 压缩所有 PDF 文件 ---
已创建归档: /home/user/Downloads/test/pdf_backup.zip
归档大小: 15280.3 KB
包含文件: 5 个
'''),

          const SectionHeader('扩展思路', icon: Icons.extension),
          const Paragraph(
            '• 添加 --dry-run / --verbose 等命令行选项\n'
            '• 支持正则表达式匹配文件名\n'
            '• 增加按文件创建时间、访问时间筛选\n'
            '• 支持递归深度限制（--max-depth）\n'
            '• 集成 MD5/SHA256 去重功能，查找重复文件\n'
            '• 添加进度条显示（集成 tqdm 库）\n'
            '• 支持解压归档文件（unpack_archive）',
          ),
          const DividerLine(),

          // ══════════════════════════════════════════════════════════════
          // PROJECT 3: 简易数据爬虫 + 分析
          // ══════════════════════════════════════════════════════════════
          const SectionHeader('项目三：简易数据爬虫 + 分析', icon: Icons.travel_explore),
          const Paragraph(
            '一个简单的网络数据抓取与分析工具。从指定网页获取 HTML 内容，'
            '提取标题、链接、正文等信息，保存为结构化 CSV 文件，'
            '并做基本的词频统计分析。',
          ),
          const Paragraph(
            '涉及知识点：requests（HTTP 请求）、re（正则解析）、'
            'csv（数据导出）、collections.Counter（统计）、'
            'urllib.parse（URL 处理）',
          ),

          const SectionHeader('需求分析', icon: Icons.lightbulb),
          const StepItem(
            step: 1,
            title: '网页抓取',
            description: '用 requests 库发起 HTTP GET 请求，设置合理的请求头和超时时间',
          ),
          const StepItem(
            step: 2,
            title: '内容解析',
            description: '用正则表达式提取页面标题、链接、各级标题文本和纯文本内容',
          ),
          const StepItem(
            step: 3,
            title: '数据导出',
            description: '将爬取结果按结构化字段写入 CSV 文件（UTF-8 with BOM 编码）',
          ),
          const StepItem(
            step: 4,
            title: '统计分析',
            description: '用 Counter 统计页面词频、链接域名分布等，输出 TOP N 结果',
          ),

          const SectionHeader('设计思路', icon: Icons.architecture),
          const Paragraph(
            '1. 设计 Spider 类封装爬虫逻辑，使用 requests.Session 复用连接\n'
            '2. 设置 User-Agent 模拟真实浏览器，避免被简单屏蔽\n'
            '3. 用 re.DOTALL 模式处理跨行 HTML 标签匹配\n'
            '4. 提取纯文本时先移除 script/style 标签，再剥离 HTML 标签\n'
            '5. 用 csv.writer 写入 UTF-8 with BOM，Excel 可直接打开\n'
            '6. 多个页面之间自动延时，避免请求过于频繁',
          ),

          const SectionHeader('完整代码', icon: Icons.code),
          const CodeBlock(r'''
import re
import csv
import time
from collections import Counter
from urllib.parse import urljoin

try:
    import requests
except ImportError:
    print("请先安装 requests 库: pip install requests")
    raise SystemExit(1)


class Spider:
    """简易网络爬虫"""

    def __init__(self, base_url, headers=None, delay=1):
        self.base_url = base_url.rstrip("/")
        self.delay = delay
        self.session = requests.Session()
        self.session.headers.update(headers or {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            ),
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "zh-CN,zh;q=0.9",
        })
        self.data = []

    def fetch(self, path=""):
        """获取页面 HTML 内容"""
        url = urljoin(self.base_url + "/", path)
        try:
            print(f"正在抓取: {url}")
            resp = self.session.get(url, timeout=10)
            resp.raise_for_status()
            # 自动检测编码
            resp.encoding = resp.apparent_encoding
            return resp.text
        except requests.RequestException as e:
            print(f"请求失败: {e}")
            return None

    def extract_title(self, html):
        """提取页面标题"""
        match = re.search(r"<title[^>]*>(.*?)</title>", html, re.DOTALL)
        return match.group(1).strip() if match else "无标题"

    def extract_links(self, html):
        """提取页面中的所有链接"""
        raw_links = re.findall(r'href=["\'](.*?)["\']', html)
        links = set()
        for link in raw_links:
            link = link.strip()
            if not link or link.startswith(("#", "javascript:", "mailto:")):
                continue
            full_url = urljoin(self.base_url + "/", link)
            links.add(full_url)
        return sorted(links)

    def extract_headlines(self, html):
        """提取 h1-h3 标题及其文本"""
        headlines = []
        for tag in ["h1", "h2", "h3"]:
            pattern = rf"<{tag}[^>]*>(.*?)</{tag}>"
            matches = re.findall(pattern, html, re.DOTALL)
            for match in matches:
                text = re.sub(r"<[^>]+>", "", match).strip()
                if text:
                    headlines.append({"tag": tag, "text": text})
        return headlines

    def extract_text(self, html):
        """提取页面中的纯文本"""
        text = re.sub(r"<script[^>]*>.*?</script>", "", html,
                      flags=re.DOTALL)
        text = re.sub(r"<style[^>]*>.*?</style>", "", text,
                      flags=re.DOTALL)
        text = re.sub(r"<[^>]+>", " ", text)
        text = re.sub(r"\s+", " ", text).strip()
        return text

    def word_frequency(self, text, top_n=20):
        """统计词频（中英文）"""
        words = re.findall(r"[a-zA-Z]+|[一-鿿]+", text.lower())
        return Counter(words).most_common(top_n)

    def scrape_page(self, path=""):
        """爬取单个页面的完整信息"""
        html = self.fetch(path)
        if html is None:
            return None

        page_info = {
            "url": urljoin(self.base_url + "/", path),
            "title": self.extract_title(html),
            "headlines": self.extract_headlines(html),
            "links": self.extract_links(html),
            "word_count": len(self.extract_text(html)),
            "top_words": self.word_frequency(
                self.extract_text(html), 10
            ),
        }
        self.data.append(page_info)
        return page_info

    def save_to_csv(self, filename="output.csv"):
        """将爬取结果保存为 CSV 文件"""
        if not self.data:
            print("没有数据可保存")
            return

        with open(filename, "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.writer(f)
            writer.writerow([
                "序号", "URL", "标题",
                "标题数", "链接数", "总字数", "高频词TOP5",
            ])

            for i, item in enumerate(self.data, 1):
                top_words = "; ".join(
                    f"{w}({c})" for w, c in item["top_words"][:5]
                )
                writer.writerow([
                    i,
                    item["url"],
                    item["title"],
                    len(item["headlines"]),
                    len(item["links"]),
                    item["word_count"],
                    top_words,
                ])

        print(f"数据已保存到 {filename}")

    def crawl(self, paths=None):
        """爬取多个页面"""
        if paths is None:
            paths = [""]
        for path in paths:
            self.scrape_page(path)
            if len(paths) > 1:
                time.sleep(self.delay)
        return self


def analyze_links(links):
    """分析链接的域名分布"""
    domains = Counter()
    for link in links:
        match = re.search(r"https?://([^/]+)", link)
        if match:
            domains[match.group(1)] += 1
    return domains


def main():
    """主函数：爬取页面并分析"""
    spider = Spider("https://example.com", delay=0.5)

    # 爬取首页
    print("=== 开始爬取 ===\n")
    result = spider.scrape_page()

    if result:
        print(f"\n页面标题: {result['title']}")
        print(f"页面链接数: {len(result['links'])}")
        print(f"纯文本字数: {result['word_count']}")
        print(f"页面标题数: {len(result['headlines'])}")

        print(f"\n高频词 TOP 10:")
        for word, count in result["top_words"]:
            print(f"  {word}: {count}")

        if result["headlines"]:
            print(f"\n页面标题列表:")
            for h in result["headlines"]:
                print(f"  [{h['tag']}] {h['text']}")

        # 链接域名分析
        domains = analyze_links(result["links"])
        print(f"\n链接域名分布 TOP 5:")
        for domain, count in domains.most_common(5):
            print(f"  {domain}: {count}")

        # 保存结果
        spider.save_to_csv("crawl_result.csv")
        print("\n爬取完成！")

    else:
        print("爬取失败")


if __name__ == "__main__":
    main()
''', language: 'Python'),

          const SectionHeader('运行示例', icon: Icons.terminal),
          const OutputBox(r'''
=== 开始爬取 ===

正在抓取: https://example.com

页面标题: Example Domain
页面链接数: 8
纯文本字数: 1250
页面标题数: 2

高频词 TOP 10:
  example: 5
  domain: 3
  this: 3
  web: 2
  use: 2
  documentation: 2
  more: 1
  information: 1
  illustrative: 1
  wikipedia: 1

页面标题列表:
  [h1] Example Domain
  [h2] More information...

链接域名分布 TOP 5:
  www.iana.org: 4
  example.com: 2
  www.w3.org: 1
  wikipedia.org: 1

数据已保存到 crawl_result.csv

爬取完成！
'''),

          const SectionHeader('使用 BeautifulSoup 优化', icon: Icons.auto_fix_high),
          const Paragraph(
            '正则表达式解析 HTML 虽然灵活，但在处理复杂、不规范页面时容易出错。'
            'BeautifulSoup 是专业的 HTML 解析库，CSS 选择器语法更直观。',
          ),
          const CodeBlock(r'''
# 安装: pip install beautifulsoup4 lxml

from bs4 import BeautifulSoup

html = "<html><body><h1>标题</h1><p>正文</p></body></html>"
soup = BeautifulSoup(html, "lxml")

# CSS 选择器提取
print(soup.select_one("h1").text)     # 标题
print(soup.select("p")[0].text)       # 正文

# 提取所有链接
for a in soup.select("a[href]"):
    print(a["href"], a.text)

# 提取纯文本
print(soup.get_text(strip=True))

# BeautifulSoup 的优势：
# 1. 自动修复不规范的 HTML
# 2. 支持 CSS 选择器和 DOM 遍历
# 3. 比正则表达式更稳定、更易读
# 4. 支持多种解析器（lxml / html.parser）
''', language: 'Python'),

          const SectionHeader('扩展思路', icon: Icons.extension),
          const Paragraph(
            '• 使用 BeautifulSoup 替代正则解析 HTML，提高鲁棒性\n'
            '• 支持深度/广度优先的多页面爬取（BFS/DFS）\n'
            '• 添加数据可视化（matplotlib / pyecharts 生成图表）\n'
            '• 使用 asyncio + aiohttp 实现异步并发爬取\n'
            '• 爬取结果保存到 SQLite / MySQL 数据库\n'
            '• 添加爬取进度条（tqdm）和断点续爬功能\n'
            '• 遵守 robots.txt 协议，做文明爬虫',
          ),
          const DividerLine(),

          // ── 互动演示 ──
          const _TodoCliDemo(),
          const DividerLine(),

          // ── 本章总结 ──
          const SectionHeader('本章总结', icon: Icons.summarize),
          const Paragraph(
            '通过三个完整的实战项目，我们综合运用了 Python 的多个核心模块：\n\n'
            '  【项目一：Todo CLI】\n'
            '    - argparse 命令行参数解析\n'
            '    - json 数据持久化存储\n'
            '    - datetime 时间处理\n\n'
            '  【项目二：文件批量处理】\n'
            '    - pathlib 路径操作与目录遍历\n'
            '    - shutil 文件复制/移动/压缩\n'
            '    - 链式调用的 API 设计模式\n\n'
            '  【项目三：数据爬虫 + 分析】\n'
            '    - requests 网络请求与异常处理\n'
            '    - re 正则表达式解析 HTML\n'
            '    - csv 模块导出结构化数据\n'
            '    - collections.Counter 词频统计\n\n'
            '这些项目覆盖了日常开发中最常见的需求场景。'
            '编程能力的提升来自于动手实践——选一个最感兴趣的项目，'
            '从零开始自己写一遍，然后加入自己的扩展功能！',
          ),
          const TipBox(
            '完整的项目源码可以在 GitHub 上搜索相关关键词找到参考。'
            '但强烈建议先自己写，遇到困难再参考他人代码——'
            '这样才能真正内化知识，形成自己的编程思维。',
            type: TipType.tip,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
