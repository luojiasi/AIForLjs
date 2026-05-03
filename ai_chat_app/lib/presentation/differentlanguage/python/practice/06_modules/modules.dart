import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// random 模块演示
class _RandomModuleDemo extends StatefulWidget {
  const _RandomModuleDemo();
  @override
  State<_RandomModuleDemo> createState() => _RandomModuleDemoState();
}

class _RandomModuleDemoState extends State<_RandomModuleDemo> {
  int _min = 1;
  int _max = 100;
  int _count = 5;
  List<int> _results = [];
  final _rng = dart_math.Random();
  String _function = 'randint';

  void _generate() {
    setState(() {
      switch (_function) {
        case 'randint':
          _results = List.generate(_count, (_) => _min + _rng.nextInt(_max - _min + 1));
        case 'sample':
          final pool = List.generate(_max - _min + 1, (i) => i + _min);
          pool.shuffle(_rng);
          _results = pool.take(_count.clamp(0, pool.length)).toList();
        case 'shuffle':
          _results = List.generate(_count, (i) => i + _min);
          _results.shuffle(_rng);
        default:
          _results = List.generate(_count, (_) => _min + _rng.nextInt(_max - _min + 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🎲 random 模块演示',
      subtitle: '点击生成，观察不同 random 函数的行为',
      children: [
        ParamIntSlider(label: '最小值', value: _min, min: 1, max: 50, onChanged: (v) => setState(() => _min = v.clamp(1, _max - 1))),
        ParamIntSlider(label: '最大值', value: _max, min: 10, max: 100, onChanged: (v) => setState(() => _max = v.clamp(_min + 1, 100))),
        ParamIntSlider(label: '数量', value: _count, min: 1, max: 10, onChanged: (v) => setState(() => _count = v)),
        ParamChoiceChips<String>(
          label: '函数',
          value: _function,
          options: [('randint', 'randint'), ('sample', 'sample（不重复）'), ('shuffle', 'shuffle')],
          onChanged: (v) => setState(() => _function = v),
        ),
        const SizedBox(height: 8),
        if (_results.isNotEmpty)
          Wrap(spacing: 6, runSpacing: 6, children: _results.map((n) =>
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
              child: Center(child: Text('$n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary))),
            )
          ).toList()),
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: _generate, icon: const Icon(Icons.casino, size: 16), label: const Text('生成')),
        LiveCodeBlock(
          'import random\n\n'
          '# randint: 包含两端的整数\n'
          'random.randint($_min, $_max)\n\n'
          '# sample: 不重复抽取\n'
          'random.sample(range($_min, $_max+1), $_count)\n\n'
          '# shuffle: 打乱列表\n'
          'nums = list(range($_min, $_min+$_count))\n'
          'random.shuffle(nums)',
        ),
        LiveOutputBox(_results.isEmpty ? '点击"生成"查看结果' : '结果: ${_results.join(', ')}'),
      ],
    );
  }
}

/// json 模块演示
class _JsonModuleDemo extends StatefulWidget {
  const _JsonModuleDemo();
  @override
  State<_JsonModuleDemo> createState() => _JsonModuleDemoState();
}

class _JsonModuleDemoState extends State<_JsonModuleDemo> {
  String _name = '张三';
  int _age = 25;
  List<String> _hobbies = ['编程', '读书'];
  bool _prettyPrint = true;

  String get _jsonStr {
    final hobbiesStr = _hobbies.map((h) => '"$h"').join(', ');
    if (_prettyPrint) {
      return '{\n'
          '  "name": "$_name",\n'
          '  "age": $_age,\n'
          '  "hobbies": [$hobbiesStr]\n'
          '}';
    }
    return '{"name":"$_name","age":$_age,"hobbies":[$hobbiesStr]}';
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '📋 json 模块演示',
      subtitle: '修改数据，观察 JSON 序列化（dumps）和格式化输出',
      children: [
        ParamTextField(label: '姓名', value: _name, onChanged: (v) => setState(() => _name = v.isEmpty ? '张三' : v), maxLength: 10),
        ParamIntSlider(label: '年龄', value: _age, min: 1, max: 99, unit: '岁', onChanged: (v) => setState(() => _age = v)),
        ParamSwitch(label: '格式化输出 indent=2', value: _prettyPrint, onChanged: (v) => setState(() => _prettyPrint = v), trueLabel: '开', falseLabel: '关'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
          child: SelectableText(_jsonStr, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent)),
        ),
        LiveCodeBlock(
          'import json\n\n'
          'data = {"name": "$_name", "age": $_age, "hobbies": ${_hobbies.map((h) => '"$h"').toList()}}\n\n'
          '# 序列化（Python对象 → JSON字符串）\n'
          '${_prettyPrint ? 'json_str = json.dumps(data, ensure_ascii=False, indent=2)' : 'json_str = json.dumps(data, ensure_ascii=False)'}\n\n'
          '# 反序列化（JSON字符串 → Python对象）\n'
          'obj = json.loads(json_str)\n'
          'print(obj["name"])  # $_name',
        ),
        LiveOutputBox(_jsonStr),
      ],
    );
  }
}

/// Python 模块与包 —— 第六课
class PythonModules extends StatelessWidget {
  const PythonModules({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第6章 模块与包')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Paragraph(
              '模块（Module）就是一个 .py 文件，包（Package）就是包含多个模块的文件夹。'
              'Python 之所以强大，很大程度上归功于它丰富的模块生态——'
              '别人写好的功能，你直接拿来用就行，不用自己从头造轮子。'
              '本章系统学习：导入方式、包的组织、pip 管理依赖、常用标准库和自定义模块。',
            ),
            DividerLine(),

            // ===== 1. 模块基础：import 详解 =====
            SectionHeader('模块基础：import 详解', icon: Icons.import_export),
            CodeBlock(
              '# ========== 方式1：import 模块名 ==========\n'
              'import math\n'
              'print(math.sqrt(16))   # 通过模块名.函数名调用：4.0\n'
              'print(math.pi)         # 3.1415926\n'
              '\n'
              '# ========== 方式2：from 模块 import 具体功能 ==========\n'
              'from math import pi, sin\n'
              'print(pi)               # 直接使用，不用写 math.pi\n'
              'print(sin(0))           # 0.0\n'
              '\n'
              '# ========== 方式3：import ... as 别名 ==========\n'
              'import numpy as np     # 给模块起简短别名\n'
              'arr = np.array([1, 2, 3])\n'
              '\n'
              '# ========== 不推荐：from module import * ==========\n'
              '# from math import *  容易导致命名冲突',
              language: 'Python',
            ),
            OutputBox('4.0\n3.141592653589793\n3.141592653589793\n0.0'),
            TipBox(
              '核心原则：导入要"明确"。from x import y 比 import x 更精确，'
              'import x as alias 比 from x import * 更安全。',
              type: TipType.tip,
            ),

            // ----- sys.path -----
            SectionHeader('模块搜索路径：sys.path', icon: Icons.route),
            Paragraph(
              '执行 import xxx 时，Python 按 sys.path 中的顺序查找 xxx.py。'
              '顺序为：当前目录 -> PYTHONPATH -> 标准库目录 -> site-packages。',
            ),
            CodeBlock(
              'import sys\n'
              '# 查看模块搜索路径\n'
              'for p in sys.path:\n'
              '    print(p)\n'
              '\n'
              '# 动态添加搜索路径（仅本次运行有效）\n'
              'sys.path.append("C:/my_modules")\n'
              'import my_custom_module  # 现在可以导入该目录下的模块了',
              language: 'Python',
            ),
            OutputBox(
              'C:/Users/me/my_project\n'
              'C:/Python311/Lib\n'
              'C:/Python311/Lib/site-packages',
            ),
            TipBox(
              'import 报 ModuleNotFoundError 时，先 print(sys.path) 检查'
              '模块所在目录是否在搜索路径中。',
              type: TipType.warning,
            ),
            DividerLine(),

            // ===== 2. __name__ == '__main__' =====
            SectionHeader("__name__ 与 __main__", icon: Icons.play_circle_outline),
            Paragraph(
              '每个 .py 文件都有 __name__ 变量。直接运行时值为 "__main__"，'
              '被导入时值为模块名。利用它可以让一个文件既可被导入、又可独立运行测试。',
            ),
            CodeBlock(
              '# 文件名：calculator.py\n'
              'def add(a, b): return a + b\n'
              'def subtract(a, b): return a - b\n'
              '\n'
              '# 只有直接运行时才执行下面的代码\n'
              '# 被 import 时不会执行\n'
              'if __name__ == "__main__":\n'
              '    print("=== 测试 ====")\n'
              '    print(f"3 + 5 = {add(3, 5)}")\n'
              '    print(f"10 - 4 = {subtract(10, 4)}")',
              language: 'Python',
            ),
            OutputBox('=== 测试 ===\n3 + 5 = 8\n10 - 4 = 6'),
            TipBox(
              '所有 .py 文件都建议加上 if __name__ == "__main__" 保护。'
              '这是一个好习惯，代码既可被导入使用，又可独立运行测试。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 3. 包（Package）=====
            SectionHeader('包（Package）', icon: Icons.folder),
            Paragraph(
              '包是包含 __init__.py 的文件夹，用于组织多个相关模块。'
              '__init__.py 标记文件夹为包，包被导入时会执行它的代码。'
              '支持嵌套子包形成层次化结构。',
            ),
            CodeBlock(
              '# ===== 包的目录结构 =====\n'
              '# my_package/           <-- 包（文件夹）\n'
              '#     __init__.py       <-- 包初始化文件\n'
              '#     module_a.py       <-- 模块A\n'
              '#     sub_package/      <-- 子包\n'
              '#         __init__.py\n'
              '#         module_c.py\n'
              '\n'
              '# ===== 使用方式 =====\n'
              '# 绝对导入（推荐）：\n'
              'import my_package.module_a\n'
              'from my_package.sub_package import module_c\n'
              '\n'
              '# 相对导入（只能在包内部.py文件中使用）：\n'
              '# from . import module_a           # 导入同级模块\n'
              '# from ..sub_package import module_c  # 导入上级包中的模块',
              language: 'Python',
            ),
            TipBox(
              '绝对导入比相对导入更清晰。__init__.py 中不要放太多代码，保持简洁。'
              'Python 3.3+ 支持隐式命名空间包（可以没有 __init__.py），'
              '但显式写出来更规范。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 4. pip 包管理 =====
            SectionHeader('pip 包管理', icon: Icons.download),
            Paragraph(
              'pip 是 Python 官方包管理工具，从 PyPI（Python Package Index）'
              '安装第三方包。PyPI 上有超过 40 万个包。',
            ),
            CodeBlock(
              '# ===== 常用命令（在终端中运行）=====\n'
              '# pip install requests              # 安装最新版\n'
              '# pip install requests==2.28.0      # 指定版本\n'
              '# pip install requests flask numpy  # 一次安装多个\n'
              '# pip uninstall requests -y         # 卸载\n'
              '# pip list                          # 列出已安装包\n'
              '# pip list --outdated               # 列出有过期版本的包\n'
              '# pip show requests                 # 查看包详细信息\n'
              '# pip install --upgrade pip         # 升级 pip 自身\n'
              '\n'
              '# ===== requirements.txt =====\n'
              '# 生成依赖清单：pip freeze > requirements.txt\n'
              '# 安装所有依赖： pip install -r requirements.txt\n'
              '\n'
              '# requirements.txt 内容示例：\n'
              '# requests==2.28.0\n'
              '# numpy>=1.24.0\n'
              '# flask~=2.2.0',
              language: 'Python',
            ),
            OutputBox(
              '# pip list 输出示例：\n'
              'Package         Version\n'
              'pip             24.0\n'
              'requests        2.28.0\n'
              'numpy           1.24.0',
            ),
            TipBox(
              '先激活虚拟环境再 pip install！下载慢可配置清华镜像源：'
              'pip install -i https://pypi.tuna.tsinghua.edu.cn/simple 包名。'
              '记得把 venv 文件夹加到 .gitignore。',
              type: TipType.caution,
            ),
            DividerLine(),

            // ===== 4.1 虚拟环境 venv =====
            SectionHeader('虚拟环境：venv', icon: Icons.workspace_premium),
            Paragraph(
              '虚拟环境为每个项目创建独立的 Python 环境，避免不同项目的依赖冲突。'
              '这是 Python 开发中最重要的实践之一。',
            ),
            CodeBlock(
              '# ===== 完整工作流 =====\n'
              '# 1. 创建：python -m venv venv\n'
              '# 2. 激活（Windows）：venv\\Scripts\\activate\n'
              '# 2. 激活（Mac/Linux）：source venv/bin/activate\n'
              '# 3. 激活后提示符出现 (venv)，安装的包只在此环境生效\n'
              '# 4. 安装依赖：pip install flask\n'
              '# 5. 导出依赖：pip freeze > requirements.txt\n'
              '# 6. 退出：deactivate\n'
              '\n'
              '# 团队协作工作流：\n'
              '# git clone -> python -m venv venv -> 激活 -> pip install -r requirements.txt',
              language: 'Python',
            ),
            OutputBox('# 激活后提示符变化：\n(venv) C:\\Users\\me\\project>'),
            TipBox(
              '新手最容易犯的错误：忘记激活虚拟环境直接 pip install，包装到了全局。'
              '每次打开终端先确认虚拟环境已激活。',
              type: TipType.caution,
            ),
            DividerLine(),

            // ===== 5. 常用标准库 =====
            SectionHeader('常用标准库', icon: Icons.library_books),
            Paragraph(
              'Python 自带"电池"——安装时就带了大量标准库。以下是最常用的六个：'
              'os（操作系统）、sys（解释器）、json（JSON 处理）、'
              'random（随机数）、math（数学）、datetime（日期时间）。',
            ),

            // --- os ---
            SectionHeader('os：操作系统交互', icon: Icons.folder_open),
            CodeBlock(
              'import os\n'
              'print(os.getcwd())              # 当前工作目录\n'
              'print(os.listdir("."))          # 列出目录下文件\n'
              '# os.mkdir("new_folder")\n'
              '# os.makedirs("a/b/c")          # 递归创建\n'
              '# os.remove("temp.txt")\n'
              'path = os.path.join("a", "b", "c.txt")  # 路径拼接\n'
              'print(os.path.exists(path))     # 路径是否存在\n'
              'print(os.environ.get("PATH"))   # 获取环境变量',
              language: 'Python',
            ),
            OutputBox(
              'C:/Users/me/project\n'
              '["main.py", "data.json", "folder"]\n'
              'a/b/c.txt\n'
              'False',
            ),

            // --- sys ---
            SectionHeader('sys：Python 解释器', icon: Icons.memory),
            CodeBlock(
              'import sys\n'
              'print(sys.argv)         # 命令行参数列表\n'
              'print(sys.version)      # Python 版本\n'
              'print(sys.platform)     # 操作系统（win32/darwin/linux）\n'
              'print(sys.path)         # 模块搜索路径\n'
              '# sys.exit(0)           # 退出程序',
              language: 'Python',
            ),
            OutputBox(
              '["script.py", "arg1", "arg2"]\n'
              '3.11.0\n'
              'win32\n'
              '["C:\\\\project", "C:\\\\Python311\\\\Lib", ...]',
            ),

            // --- json ---
            SectionHeader('json：JSON 数据处理', icon: Icons.data_object),
            CodeBlock(
              'import json\n'
              'data = {"name": "小明", "age": 18, "scores": [95, 88]}\n'
              '\n'
              '# Python 对象 -> JSON 字符串\n'
              'json_str = json.dumps(data, ensure_ascii=False, indent=2)\n'
              'print(json_str)\n'
              '\n'
              '# JSON 字符串 -> Python 对象\n'
              'obj = json.loads(\'{"name": "小红"}\')\n'
              'print(obj["name"])\n'
              '\n'
              '# 读写文件：json.dump() / json.load()（不带 s）',
              language: 'Python',
            ),
            OutputBox(
              '{\n'
              '  "name": "小明",\n'
              '  "age": 18,\n'
              '  "scores": [95, 88]\n'
              '}\n'
              '小红',
            ),

            // --- random ---
            SectionHeader('random：随机数', icon: Icons.shuffle),
            CodeBlock(
              'import random\n'
              'print(random.random())           # [0, 1) 随机浮点数\n'
              'print(random.randint(1, 100))    # [1, 100] 随机整数\n'
              'print(random.choice(["石头", "剪刀", "布"]))  # 随机选一个\n'
              'fruits = ["苹果", "香蕉", "橘子"]\n'
              'random.shuffle(fruits)           # 打乱顺序\n'
              'print(fruits)',
              language: 'Python',
            ),
            OutputBox(
              '0.7251\n'
              '42\n'
              '剪刀\n'
              '["橘子", "苹果", "香蕉"]',
            ),

            // --- math ---
            SectionHeader('math：数学函数', icon: Icons.calculate),
            CodeBlock(
              'import math\n'
              'print(math.pi)           # 3.1415926\n'
              'print(math.sqrt(25))     # 5.0  平方根\n'
              'print(math.factorial(5)) # 120  阶乘\n'
              'print(math.floor(3.7))   # 3    向下取整\n'
              'print(math.ceil(3.2))    # 4    向上取整\n'
              'print(math.sin(math.pi / 2))  # 1.0\n'
              'print(math.log(100, 10)) # 2.0  对数',
              language: 'Python',
            ),
            OutputBox('3.1415926\n5.0\n120\n3\n4\n1.0\n2.0'),

            // --- datetime ---
            SectionHeader('datetime：日期时间', icon: Icons.calendar_today),
            CodeBlock(
              'from datetime import datetime, date, timedelta\n'
              '\n'
              'now = datetime.now()\n'
              'print(now)                               # 当前时间\n'
              'print(now.strftime("%Y年%m月%d日"))       # 格式化\n'
              '\n'
              '# 字符串解析为日期\n'
              'd = datetime.strptime("2024-03-15", "%Y-%m-%d")\n'
              '\n'
              '# 时间差计算\n'
              'delta = now - datetime(2000, 1, 1)\n'
              'print(f"从2000年至今过去了 {delta.days} 天")\n'
              '\n'
              '# 时间的加减\n'
              'tomorrow = now + timedelta(days=1)\n'
              'print(f"明天：{tomorrow.date()}")',
              language: 'Python',
            ),
            OutputBox(
              '2024-01-15 14:30:00.123456\n'
              '2024年01月15日\n'
              '从2000年至今过去了 8779 天\n'
              '明天：2024-01-16',
            ),
            TipBox(
              'strftime 格式码：%Y(4位年)、%m(月)、%d(日)、%H(时)、%M(分)、%S(秒)。'
              '记不住查文档即可。',
              type: TipType.tip,
            ),
            DividerLine(),

            // ===== 6. 第三方库 =====
            SectionHeader('第三方库：PyPI 生态', icon: Icons.extension),
            Paragraph(
              'Python 最强之处在于丰富的第三方库生态。从 Web 开发到机器学习，'
              '从爬虫到图像处理，都有成熟库可用。所有库都托管在 PyPI（pypi.org）上。',
            ),
            CodeBlock(
              '# ===== 热门第三方库 =====\n'
              '# Web：flask / django / fastapi\n'
              '# 数据科学：numpy / pandas / matplotlib\n'
              '# 机器学习：scikit-learn / tensorflow / pytorch\n'
              '# 爬虫：requests / beautifulsoup4 / scrapy\n'
              '# 图像：pillow / opencv-python\n'
              '# 测试：pytest\n'
              '\n'
              '# ===== 安装与使用 =====\n'
              '# pip install requests numpy pandas\n'
              '\n'
              'import requests\n'
              'resp = requests.get("https://api.github.com")\n'
              'print(f"状态码：{resp.status_code}")\n'
              '\n'
              'import numpy as np\n'
              'arr = np.array([[1, 2], [3, 4]])\n'
              'print(f"形状：{arr.shape}，总和：{arr.sum()}")',
              language: 'Python',
            ),
            OutputBox(
              '状态码：200\n'
              '形状：(2, 2)，总和：10',
            ),
            TipBox(
              '安装第三方库前先激活虚拟环境！下载慢可配置国内镜像源，'
              '如清华：pip install -i https://pypi.tuna.tsinghua.edu.cn/simple 包名。',
              type: TipType.info,
            ),
            DividerLine(),

            // ===== 7. 自定义模块 =====
            SectionHeader('自定义模块', icon: Icons.create),
            Paragraph(
              '任何 .py 文件都是一个模块。把功能拆分到不同模块中是实现代码复用的基础。'
              '好的模块设计遵循"一个模块只做一类事情"的原则。',
            ),
            CodeBlock(
              '# 文件1：my_utils.py（自定义模块）\n'
              '"""工具模块：提供数学和字符串工具"""\n'
              '\n'
              'def add(a, b):\n'
              '    return a + b\n'
              '\n'
              'def reverse_string(s):\n'
              '    return s[::-1]\n'
              '\n'
              'PI = 3.14159\n'
              '\n'
              'if __name__ == "__main__":\n'
              '    print(reverse_string("Python"))  # nohtyP\n'
              '\n'
              '# 文件2：main.py（使用自定义模块）\n'
              'import my_utils\n'
              'print(my_utils.add(3, 5))            # 8\n'
              'print(my_utils.PI)                   # 3.14159\n'
              '\n'
              'from my_utils import reverse_string\n'
              'print(reverse_string("Hello"))       # olleH',
              language: 'Python',
            ),
            OutputBox('8\n3.14159\nolleH'),
            TipBox(
              '避免命名冲突：①不要创建和标准库同名的文件（如 math.py、json.py）；'
              '②模块名用下划线不用连字符；③优先用 import module 而非 from module import *。',
              type: TipType.caution,
            ),
            const _RandomModuleDemo(),
            const _JsonModuleDemo(),
            DividerLine(),

            // ===== 小练习 =====
            SectionHeader('章节练习', icon: Icons.edit_note),
            StepItem(
              step: 1,
              title: 'random 猜数字',
              description: '用 random.randint() 生成1~100的随机数，让用户循环输入猜测，'
                  '程序提示"大了"或"小了"，直到猜中。',
            ),
            StepItem(
              step: 2,
              title: 'datetime 生日计算',
              description: '输入生日日期，用 datetime 计算从出生到今天共活了多少天，'
                  '以及下一个生日还有多少天。',
            ),
            StepItem(
              step: 3,
              title: 'json 通讯录 + 自定义模块',
              description: '创建自定义模块 my_contacts.py，包含添加、删除、查找联系人功能，'
                  '数据用 json 保存到文件。然后在主程序中导入使用。',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
