import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 第19章：GUI编程（Tkinter 完整教程）
/// 涵盖：主窗口/核心组件/布局管理/事件绑定/ttk/Canvas/完整项目
class PythonGUITutorial extends StatelessWidget {
  const PythonGUITutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第19章 GUI编程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '① Tkinter 简介\n'
            '② 主窗口设置\n'
            '③ 核心组件一览\n'
            '④ 布局管理器\n'
            '⑤ Grid 布局\n'
            '⑥ Pack 布局\n'
            '⑦ Button 按钮\n'
            '⑧ Label 标签\n'
            '⑨ Entry 输入框\n'
            '⑩ Text 多行文本\n'
            '⑪ Frame 框架\n'
            '⑫ Listbox & Combobox\n'
            '⑬ Checkbutton & Radiobutton\n'
            '⑭ Scale & Spinbox\n'
            '⑮ Messagebox 消息框\n'
            '⑯ Filedialog 文件对话框 \n'
            '⑰ 颜色与字体  \n'
            '⑱ 事件绑定\n'
            '⑲ ttk 主题组件  \n'
            '⑳ Menu 菜单 \n'
            '㉑ Canvas 画布\n'
            '㉒ 完整项目\n'
            '㉓ 最佳实践',
          ),
          const TipBox(
            'Tkinter 是 Python 标准库自带的 GUI 框架，无需额外安装。'
            '它简单易学，适合桌面小工具和管理工具开发。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 1. Tkinter 简介 ──
          const SectionHeader('1. Tkinter 简介', icon: Icons.info_outline),
          const Paragraph(
            'Tkinter 是 Python 内置的 GUI（图形用户界面）库，基于 Tk 工具包。'
            '你不需要 pip install 任何东西——直接 import 就能用。'
            '它提供了创建窗口、按钮、输入框、菜单等所有桌面应用所需的组件。',
          ),
          const Paragraph(
            '为什么学 Tkinter？① 零依赖，Python 自带  ② 跨平台（Windows/Mac/Linux 界面风格一致）'
            ' ③ 上手快，几十行就能做一个实用工具  ④ 适合写内部管理工具、数据录入、小游戏等。',
          ),
          const CodeBlock(
            r'''import tkinter as tk          # 标准写法，tk 作为别名
from tkinter import ttk       # ttk 主题组件
from tkinter import messagebox, filedialog  # 对话框

# 创建主窗口
root = tk.Tk()
root.mainloop()               # 进入事件循环（窗口开始响应）
''',
            language: 'Python',
          ),
          const TipBox(
            'Tkinter 不是 Python 唯一的 GUI 库。PyQt/PySide 功能更强大，'
            '但 Tkinter 胜在简单和"开箱即用"。初学者先学 Tkinter 准没错。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 2. 主窗口 ──
          const SectionHeader('2. 主窗口设置', icon: Icons.window),
          const Paragraph(
            '主窗口是 Tkinter 应用的根容器，所有组件都放在它上面。'
            '创建窗口后，可以设置标题、大小、位置等属性。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()

# ── 窗口基本属性 ──
root.title("我的第一个应用")     # 窗口标题
root.geometry("800x600+100+50") # 宽x高+X偏移+Y偏移
root.minsize(400, 300)          # 最小尺寸
root.maxsize(1200, 900)         # 最大尺寸
root.resizable(True, True)     # 是否允许缩放（宽，高）
root.iconbitmap("app.ico")     # 窗口图标（.ico 文件）

# ── 窗口背景色 ──
root.configure(bg="#f0f0f0")

# ── 属性获取 ──
print(root.winfo_width())      # 窗口宽度
print(root.winfo_height())     # 窗口高度
print(root.winfo_screenwidth()) # 屏幕宽度
print(root.winfo_screenheight())# 屏幕高度

# ── 窗口居中 ──
w, h = 400, 300
sw = root.winfo_screenwidth()
sh = root.winfo_screenheight()
x = (sw - w) // 2
y = (sh - h) // 2
root.geometry(f"{w}x{h}+{x}+{y}")

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'geometry("宽x高+X+Y") 的格式：宽和高之间是小写字母 x，'
            'X 和 Y 是窗口左上角相对于屏幕左上角的偏移量。不填则居中。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 3. 核心组件概览 ──
          const SectionHeader('3. 核心组件一览', icon: Icons.widgets),
          const Paragraph(
            'Tkinter 提供了丰富的组件（Widgets），下面是最常用的几个。'
            '创建组件的通用语法：widget = WidgetClass(父容器, 参数...)。',
          ),
          const CodeBlock(
            r'''import tkinter as tk
from tkinter import ttk

root = tk.Tk()
root.title("组件展示")
root.geometry("500x400")

# 标签 Label：显示文本或图片
label = tk.Label(root, text="这是一个标签")
label.pack()

# 按钮 Button：点击执行命令
btn = tk.Button(root, text="点击我", command=lambda: print("被点击了"))
btn.pack()

# 单行输入 Entry
entry = tk.Entry(root)
entry.pack()

# 多行文本 Text
text = tk.Text(root, height=5)
text.pack()

# 框架 Frame：用于组织其他组件
frame = tk.Frame(root, relief="ridge", bd=2)
frame.pack()

# 列表框 Listbox
listbox = tk.Listbox(root)
listbox.insert(1, "选项A")
listbox.insert(2, "选项B")
listbox.pack()

# 画布 Canvas：绘图
canvas = tk.Canvas(root, width=200, height=100, bg="white")
canvas.pack()

# 滚动条 Scrollbar（需要和另一个组件关联）
scrollbar = tk.Scrollbar(root)
text.config(yscrollcommand=scrollbar.set)
scrollbar.config(command=text.yview)
scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'pack() 是自动布局，它会按照添加顺序从上到下排列。'
            '后面会详细讲 pack()、grid()、place() 三种布局方式。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 4. 布局管理器 ──
          const SectionHeader('4. 布局管理器', icon: Icons.grid_view),
          const Paragraph(
            'Tkinter 有三种布局管理器，每个组件只能使用其中一种。'
            'pack() 简单但不够灵活，grid() 灵活且最常用，place() 可精确定位。',
          ),
          const CodeBlock(
            r'''# ===== 三种布局方式对比 =====

# 1️⃣ pack() —— 按顺序自动排列（从上到下 / 从左到右）
label1 = tk.Label(root, text="上")
label1.pack(side=tk.TOP)        # 靠上排列
label2 = tk.Label(root, text="下")
label2.pack(side=tk.BOTTOM)     # 靠下排列

# 2️⃣ grid() —— 表格布局（最推荐！）
label = tk.Label(root, text="用户名")
label.grid(row=0, column=0)     # 第0行第0列
entry = tk.Entry(root)
entry.grid(row=0, column=1)     # 第0行第1列

# 3️⃣ place() —— 绝对/相对定位
label = tk.Label(root, text="绝对定位")
label.place(x=50, y=100)        # 精确到像素
label2 = tk.Label(root, text="相对定位")
label2.place(relx=0.5, rely=0.5, anchor=tk.CENTER)  # 窗口中心
''',
            language: 'Python',
          ),
          const TipBox(
            '不要在同一个容器中同时使用 pack() 和 grid()！'
            '这会导致程序卡死或者布局错乱。选择一个统一的布局方式。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ── 5. Grid 布局 ──
          const SectionHeader('5. Grid 网格布局', icon: Icons.grid_on),
          const Paragraph(
            'grid() 是 Tkinter 最推荐的布局方式，把容器划分成行和列。'
            '它非常适合表单类界面（标签+输入框一一对应）。',
          ),
          const CodeBlock(
            r'''import tkinter as tk
from tkinter import ttk

root = tk.Tk()
root.title("Grid 演示")
root.geometry("400x300")

# ── 基本 Grid 布局 ──
tk.Label(root, text="用户名:").grid(row=0, column=0, sticky=tk.W)
tk.Entry(root).grid(row=0, column=1, padx=5, pady=5)

tk.Label(root, text="密码:").grid(row=1, column=0, sticky=tk.W)
tk.Entry(root, show="*").grid(row=1, column=1, padx=5, pady=5)

tk.Label(root, text="备注:").grid(row=2, column=0, sticky=tk.NW)
tk.Text(root, height=4, width=25).grid(row=2, column=1, padx=5, pady=5)

# ── 跨列 / 跨行 ──
# columnspan=2 表示跨2列
tk.Button(root, text="提交").grid(row=3, column=0, columnspan=2, pady=10)

# ── sticky 参数 ──
# tk.N / tk.S / tk.E / tk.W / 可组合：tk.N+tk.E
# sticky=tk.W   靠左对齐     sticky=tk.E   靠右对齐
# sticky=tk.EW  水平拉伸     sticky=tk.NSEW 填满整个格子

# ── 权重控制（调整列宽） ──
root.columnconfigure(1, weight=1)   # 第1列可拉伸
root.rowconfigure(3, weight=1)      # 第3行可拉伸

root.mainloop()
''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''# ── grid() 参数速查表 ──
# row         行号（从0开始）
# column      列号（从0开始）
# rowspan     跨几行
# columnspan  跨几列
# sticky      对齐方式：N/S/E/W/NE/NW/SE/SW
# padx/pady   外边距（像素）
# ipadx/ipady 内边距（像素）
''',
            language: 'Python',
          ),
          const TipBox(
            'sticky=tk.W 相当于左对齐，sticky=tk.EW 相当于水平填充。'
            'columnconfigure() 的 weight 参数决定列如何随窗口缩放——'
            'weight 越大，该列占的多余空间越多。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 6. Pack 布局 ──
          const SectionHeader('6. Pack 布局', icon: Icons.view_stream),
          const Paragraph(
            'pack() 按"块"的方式依次排列组件，适合做工具栏、状态栏等线性布局。'
            'side 参数决定排列方向，fill 和 expand 控制填充行为。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("Pack 演示")
root.geometry("400x300")

# ── side 参数 ──
tk.Label(root, text="上", bg="red").pack(side=tk.TOP, fill=tk.X)
tk.Label(root, text="左", bg="green").pack(side=tk.LEFT, fill=tk.Y)
tk.Label(root, text="右", bg="blue").pack(side=tk.RIGHT, fill=tk.Y)
tk.Label(root, text="下", bg="yellow").pack(side=tk.BOTTOM, fill=tk.X)
# 中间区域会自动填满剩余空间

# ── fill 参数 ──
# tk.X      水平填充整个容器宽度
# tk.Y      垂直填充整个容器高度
# tk.BOTH   水平和垂直都填充
# tk.NONE   不填充（默认）

# ── expand 参数 ──
# expand=True 组件会占据额外的空白空间（配合 fill 使用）
tk.Label(root, text="可伸缩区域", bg="lightblue").pack(
    fill=tk.BOTH, expand=True
)

# ── anchor 参数 ──
# 组件在分配空间中的对齐方式
# tk.N / tk.S / tk.E / tk.W / tk.CENTER（默认）
tk.Label(root, text="右下角").pack(anchor=tk.SE)

# ── 创建工具栏 ──
toolbar = tk.Frame(root)
toolbar.pack(side=tk.TOP, fill=tk.X)
tk.Button(toolbar, text="打开").pack(side=tk.LEFT, padx=2)
tk.Button(toolbar, text="保存").pack(side=tk.LEFT, padx=2)
tk.Button(toolbar, text="关于").pack(side=tk.RIGHT, padx=2)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'pack() 的 side 参数只控制"下一个组件往哪个方向排"，'
            '不是"这个组件固定在哪边"。先 pack 的组件先占据位置。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 7. Button 按钮 ──
          const SectionHeader('7. Button 按钮', icon: Icons.smart_button),
          const Paragraph(
            'Button 是用户交互的主要入口。command 参数绑定点击回调函数，'
            'state 控制按钮状态，还可以用图片做个性化按钮。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("按钮演示")
root.geometry("400x300")

# ── 基本用法 ──
count = 0
def on_click():
    global count
    count += 1
    label.config(text=f"点击了 {count} 次")

btn = tk.Button(root, text="点我", command=on_click)
btn.pack(pady=10)
label = tk.Label(root, text="点击了 0 次")
label.pack()

# ── 按钮状态 ──
def toggle():
    if btn2["state"] == tk.NORMAL:
        btn2.config(state=tk.DISABLED, text="已禁用")
    else:
        btn2.config(state=tk.NORMAL, text="可点击")

tk.Button(root, text="启用/禁用下面的按钮",
          command=toggle).pack(pady=5)
btn2 = tk.Button(root, text="可点击", state=tk.NORMAL)
btn2.pack(pady=5)

# ── 图片按钮 ──
# 先创建 PhotoImage 对象
# img = tk.PhotoImage(file="icon.png")
# tk.Button(root, image=img, command=on_click).pack()

# ── 按钮参数 ──
# text         按钮文本
# command      点击回调函数（不带括号！）
# state        tk.NORMAL / tk.DISABLED / tk.ACTIVE
# image        按钮图片
# width/height 按钮尺寸
# bg/fg        背景色/前景色
# font         字体
# relief       边框样式：tk.FLAT / tk.RAISED / tk.SUNKEN / tk.RIDGE

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'command 参数传的是"函数本身"，不带括号！'
            'command=on_click ✅     command=on_click() ❌（这会在创建时立即执行一次）',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ── 8. Label 标签 ──
          const SectionHeader('8. Label 标签', icon: Icons.label),
          const Paragraph(
            'Label 用于显示文本或图片。它是最简单的组件，但也是信息展示的核心。'
            '支持丰富的样式设置：字体、颜色、对齐、自动换行等。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("标签演示")
root.geometry("500x400")

# ── 文本标签 ──
tk.Label(root, text="普通标签").pack()

# ── 字体设置 ──
label_font = tk.Label(root, text="大号红色粗体",
    font=("Arial", 20, "bold"),
    fg="red", bg="yellow")
label_font.pack(pady=5)

# ── 自动换行 ──
long_text = ("这是一段很长的文本，当宽度不够时会自动换行。"
             "wraplength 参数控制每行最大像素宽度。")
tk.Label(root, text=long_text,
    wraplength=300,             # 每行最多300像素宽
    justify=tk.LEFT             # 左对齐
).pack(pady=5)

# ── 图片标签 ──
# img = tk.PhotoImage(file="logo.png")
# tk.Label(root, image=img, text="图片标签",
#          compound=tk.TOP       # 图片在上，文字在下
# ).pack()

# ── 常用参数 ──
# text        显示的文本
# image       显示的图片
# compound    图文组合：tk.TOP/BOTTOM/LEFT/RIGHT/CENTER
# font        字体
# fg          前景色（文字颜色）
# bg          背景色
# wraplength  自动换行的像素宽度
# justify     对齐：tk.LEFT / tk.CENTER / tk.RIGHT
# anchor      位置：tk.N / tk.S / tk.E / tk.W / tk.CENTER

root.mainloop()
''',
            language: 'Python',
          ),
          const DividerLine(),

          // ── 9. Entry 输入框 ──
          const SectionHeader('9. Entry 单行输入框', icon: Icons.input),
          const Paragraph(
            'Entry 用于单行文本输入。支持占位符、密码模式、输入验证等功能。'
            '注意：Entry 的内容用 get() 获取，不是 text 属性！',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("输入框演示")
root.geometry("400x250")

# ── 基本输入框 ──
tk.Label(root, text="普通输入:").pack()
entry1 = tk.Entry(root)
entry1.pack(pady=5)

# ── 密码输入 ──
tk.Label(root, text="密码输入:").pack()
entry2 = tk.Entry(root, show="*")    # 显示为 * 号
entry2.pack(pady=5)

# ── 占位符（通过 bind 实现） ──
entry3 = tk.Entry(root)
entry3.insert(0, "请输入姓名...")     # 插入默认文本
entry3.config(fg="grey")

def on_focus_in(e):
    if entry3.get() == "请输入姓名...":
        entry3.delete(0, tk.END)
        entry3.config(fg="black")

def on_focus_out(e):
    if not entry3.get():
        entry3.insert(0, "请输入姓名...")
        entry3.config(fg="grey")

entry3.bind("<FocusIn>", on_focus_in)
entry3.bind("<FocusOut>", on_focus_out)
entry3.pack(pady=5)

# ── 获取和设置值 ──
def show_value():
    print(f"普通: {entry1.get()}")
    print(f"密码: {entry2.get()}")
    entry1.delete(0, tk.END)      # 清空
    entry2.delete(0, tk.END)

tk.Button(root, text="获取并清空", command=show_value).pack(pady=10)

# ── Entry 参数速查 ──
# show="*"      密码模式
# width         输入框宽度（字符数）
# state         tk.NORMAL / tk.DISABLED（只读）
# validate      验证模式：'focus' / 'key' / 'focusin' / 'focusout'
# validatecommand 验证回调

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Entry 没有 text 属性！用 .get() 获取内容，.delete(0, tk.END) 清空，'
            '.insert(index, text) 插入文本。这和其他框架习惯不同，注意区分。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ── 10. Text 多行文本 ──
          const SectionHeader('10. Text 多行文本', icon: Icons.text_fields),
          const Paragraph(
            'Text 支持多行文本编辑，功能比 Entry 强大得多。'
            '支持插入、删除、获取、标签（Tag）高亮等高级功能。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("多行文本演示")
root.geometry("500x400")

# ── 创建多行文本 ──
text = tk.Text(root, height=10, width=50)
text.pack(pady=10)

# ── 插入内容 ──
text.insert(tk.END, "第一行内容\n")   # 追加到末尾
text.insert(tk.END, "第二行内容\n")
text.insert(1.0, "插到开头\n")        # 1.0 = 第1行第0列

# ── 获取内容 ──
def get_all():
    content = text.get(1.0, tk.END)   # 从第一行到末尾
    print(repr(content))

def get_line():
    line = text.get(2.0, "2.end")     # 获取第2行
    print(line)

tk.Button(root, text="获取全部", command=get_all).pack(side=tk.LEFT)
tk.Button(root, text="获取第2行", command=get_line).pack(side=tk.LEFT)

# ── 删除内容 ──
def delete_all():
    text.delete(1.0, tk.END)

tk.Button(root, text="清空", command=delete_all).pack(side=tk.RIGHT)

# ── Tag 标签（高亮特定文本） ──
text.insert(tk.END, "这是错误信息\n")
text.insert(tk.END, "这是警告信息\n")

# 定义 tag 样式
text.tag_config("error", foreground="red", font=("Arial", 12, "bold"))
text.tag_config("warn", foreground="orange", background="yellow")

# 对特定范围应用 tag
text.tag_add("error", "4.0", "4.end")   # 第4行整行标红
text.tag_add("warn", "5.0", "5.end")    # 第5行标橙色

# ── 关联滚动条 ──
scrollbar = tk.Scrollbar(root)
scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
text.config(yscrollcommand=scrollbar.set)
scrollbar.config(command=text.yview)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Text 的索引格式是 "行.列"，从 1.0 开始（第1行第0列）。'
            '特殊索引：tk.END（末尾）、"行.end"（行尾）、tk.CURRENT（鼠标位置）。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 11. Frame 框架 ──
          const SectionHeader('11. Frame 框架容器', icon: Icons.layers),
          const Paragraph(
            'Frame 是一个容器组件，用来组织和管理其他组件。'
            '你可以把 Frame 想象成"画板"——在里面放置相关的组件组。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("Frame 演示")
root.geometry("500x400")

# ── 用 Frame 分组 ──
# 个人信息组
frame_info = tk.LabelFrame(root, text="个人信息", padx=10, pady=10)
frame_info.pack(padx=10, pady=10, fill=tk.X)

tk.Label(frame_info, text="姓名:").grid(row=0, column=0, sticky=tk.W)
tk.Entry(frame_info).grid(row=0, column=1, padx=5)
tk.Label(frame_info, text="年龄:").grid(row=1, column=0, sticky=tk.W)
tk.Entry(frame_info).grid(row=1, column=1, padx=5)

# 设置组（用 LabelFrame——带标题的 Frame）
frame_setting = tk.LabelFrame(root, text="设置选项", padx=10, pady=10)
frame_setting.pack(padx=10, pady=10, fill=tk.X)

tk.Checkbutton(frame_setting, text="自动保存").pack(anchor=tk.W)
tk.Checkbutton(frame_setting, text="开机启动").pack(anchor=tk.W)

# 按钮组
frame_btn = tk.Frame(root)
frame_btn.pack(pady=10)

tk.Button(frame_btn, text="确定", width=10).pack(side=tk.LEFT, padx=5)
tk.Button(frame_btn, text="取消", width=10).pack(side=tk.LEFT, padx=5)

# ── Frame 边框样式 ──
# relief: tk.FLAT / tk.RAISED / tk.SUNKEN / tk.RIDGE / tk.GROOVE
# bd: 边框宽度（像素）
frame_border = tk.Frame(root, relief=tk.SUNKEN, bd=3, padx=10, pady=10)
frame_border.pack(padx=10, fill=tk.X)
tk.Label(frame_border, text="带边框的 Frame").pack()

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'LabelFrame 是带标题和边框的 Frame，适合做"分组框"。'
            'Frame 可以嵌套——一个 Frame 里放另一个 Frame，'
            '这样就能做出复杂的布局结构。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 12. Listbox 和 Combobox ──
          const SectionHeader('12. Listbox & Combobox', icon: Icons.list_alt),
          const Paragraph(
            'Listbox 显示列表供用户选择，Combobox 是下拉选择框（来自 ttk）。'
            '二者都支持绑定选择事件。',
          ),
          const CodeBlock(
            r'''import tkinter as tk
from tkinter import ttk

root = tk.Tk()
root.title("列表选择演示")
root.geometry("500x350")

# ── Listbox 列表框 ──
tk.Label(root, text="Listbox（列表选择）:").pack(anchor=tk.W)
listbox = tk.Listbox(root, height=5, selectmode=tk.SINGLE)
listbox.pack(fill=tk.X, padx=10)

for item in ["Python", "Java", "Go", "Rust", "TypeScript"]:
    listbox.insert(tk.END, item)

# 绑定选择事件
def on_listbox_select(e):
    selection = listbox.curselection()  # 返回选中索引的元组
    if selection:
        index = selection[0]
        value = listbox.get(index)
        label_list.config(text=f"选择了: {value}")

listbox.bind("<<ListboxSelect>>", on_listbox_select)
label_list = tk.Label(root, text="未选择")
label_list.pack()

# ── Combobox 下拉框 ──
tk.Label(root, text="Combobox（下拉选择）:").pack(anchor=tk.W)
combo = ttk.Combobox(root, values=["小学", "初中", "高中", "大学", "研究生"])
combo.set("请选择学历")          # 默认显示文本
combo.pack(fill=tk.X, padx=10)

def on_combo_select(e):
    label_combo.config(text=f"学历: {combo.get()}")

combo.bind("<<ComboboxSelected>>", on_combo_select)
label_combo = tk.Label(root, text="未选择")
label_combo.pack()

# ── Listbox 多选模式 ──
listbox_multi = tk.Listbox(root, height=4, selectmode=tk.MULTIPLE)
listbox_multi.pack(fill=tk.X, padx=10)
for item in ["选项1", "选项2", "选项3", "选项4"]:
    listbox_multi.insert(tk.END, item)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Listbox 的 selectmode 可选 tk.SINGLE（单选）、tk.BROWSE（单选+鼠标浏览）、'
            'tk.MULTIPLE（多选，点选切换）、tk.EXTENDED（多选，Shift/Ctrl辅助）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 13. Checkbutton 和 Radiobutton ──
          const SectionHeader('13. Checkbutton & Radiobutton', icon: Icons.check_box),
          const Paragraph(
            'Checkbutton（复选框）可以独立开关，Radiobutton（单选框）'
            '在同一组内只能选一个。两者都需要关联 tk.IntVar / tk.StringVar 变量。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("选择按钮演示")
root.geometry("450x350")

# ── Checkbutton 复选框 ──
tk.Label(root, text="兴趣爱好（可多选）:").pack(anchor=tk.W)

var1 = tk.IntVar()  # 存储勾选状态：0或1
var2 = tk.IntVar()
var3 = tk.IntVar()

cb1 = tk.Checkbutton(root, text="编程", variable=var1)
cb1.pack(anchor=tk.W)
cb2 = tk.Checkbutton(root, text="阅读", variable=var2)
cb2.pack(anchor=tk.W)
cb3 = tk.Checkbutton(root, text="运动", variable=var3)
cb3.pack(anchor=tk.W)

def show_hobbies():
    hobbies = []
    if var1.get(): hobbies.append("编程")
    if var2.get(): hobbies.append("阅读")
    if var3.get(): hobbies.append("运动")
    label_hobby.config(text=f"兴趣: {', '.join(hobbies) or '无'}")

tk.Button(root, text="显示选择", command=show_hobbies).pack()
label_hobby = tk.Label(root, text="兴趣: 无")
label_hobby.pack()

# ── Radiobutton 单选框 ──
tk.Label(root, text="性别（单选）:").pack(anchor=tk.W)

gender = tk.StringVar(value="未选择")  # 存储选中值

tk.Radiobutton(root, text="男", variable=gender,
               value="男").pack(anchor=tk.W)
tk.Radiobutton(root, text="女", variable=gender,
               value="女").pack(anchor=tk.W)
tk.Radiobutton(root, text="其他", variable=gender,
               value="其他").pack(anchor=tk.W)

def show_gender():
    label_gender.config(text=f"性别: {gender.get()}")

tk.Button(root, text="确认性别", command=show_gender).pack()
label_gender = tk.Label(root, text="性别: 未选择")
label_gender.pack()

# ── 关键区别 ──
# Checkbutton: 每个独立，variable 是 IntVar(0/1)
# Radiobutton: 同组共享一个 variable，value 区分不同选项

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Radiobutton 的"组"是通过共享同一个 variable 实现的。'
            '同一组中的 Radiobutton 必须使用相同的 tk.StringVar（或 tk.IntVar），'
            '但每个的 value 不同。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 14. Scale 和 Spinbox ──
          const SectionHeader('14. Scale & Spinbox', icon: Icons.tune),
          const Paragraph(
            'Scale（滑块）和 Spinbox（数字微调）用于数值输入。'
            'Scale 适合直观的拖拽选择，Spinbox 适合精确输入。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("数值输入演示")
root.geometry("450x300")

# ── Scale 滑块 ──
tk.Label(root, text="音量控制:").pack()
scale = tk.Scale(root, from_=0, to=100,
                 orient=tk.HORIZONTAL,  # 水平方向
                 length=300,             # 滑块长度
                 tickinterval=10,        # 刻度间隔
                 showvalue=True,         # 显示当前值
                 resolution=1)           # 步长
scale.set(50)  # 默认值
scale.pack(pady=5)

def show_scale():
    label_scale.config(text=f"音量: {scale.get()}")

tk.Button(root, text="获取音量", command=show_scale).pack()
label_scale = tk.Label(root, text="音量: 50")
label_scale.pack()

# ── Spinbox 数字微调 ──
tk.Label(root, text="年龄:").pack()
spinbox = tk.Spinbox(root, from_=0, to=150,
                     increment=1,        # 每次增减1
                     width=10)
spinbox.pack(pady=5)

Spinbox(root, values=("A", "B", "C", "D"),  # 枚举值
        width=10).pack(pady=5)

# ── 实时绑定 ──
def on_scale_change(val):
    """Scale 的 command 回调会自动传入当前值"""
    label_real.config(text=f"值: {val}")

scale2 = tk.Scale(root, from_=0, to=255,
                  orient=tk.HORIZONTAL,
                  command=on_scale_change)
scale2.pack()
label_real = tk.Label(root, text="值: 0")
label_real.pack()

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Scale 的 command 回调会自动接收当前值作为参数，'
            '而 Button 的 command 回调不带参数。这是需要注意的细节差异。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 15. Messagebox ──
          const SectionHeader('15. Messagebox 消息框', icon: Icons.message),
          const Paragraph(
            'messagebox 模块提供各种标准对话框：提示、警告、错误、确认等。'
            '它们会阻塞程序（等用户关闭后才继续执行）。',
          ),
          const CodeBlock(
            r'''from tkinter import messagebox
import tkinter as tk

root = tk.Tk()
root.title("消息框演示")
root.geometry("400x300")

def show_info():
    messagebox.showinfo("提示", "操作成功完成！")

def show_warning():
    messagebox.showwarning("警告", "磁盘空间不足！")

def show_error():
    messagebox.showerror("错误", "文件打开失败！")

def ask_yes_no():
    result = messagebox.askyesno("确认", "确定要删除吗？")
    label_result.config(text=f"结果: {'是' if result else '否'}")

def ask_ok_cancel():
    result = messagebox.askokcancel("确认", "保存修改？")
    label_result.config(text=f"结果: {'确认' if result else '取消'}")

def ask_retry_cancel():
    result = messagebox.askretrycancel("重试", "连接失败，重试？")
    label_result.config(text=f"结果: {'重试' if result else '取消'}")

# ── 不同对话框 ──
tk.Button(root, text="信息提示", command=show_info).pack(pady=2)
tk.Button(root, text="警告", command=show_warning).pack(pady=2)
tk.Button(root, text="错误", command=show_error).pack(pady=2)
tk.Button(root, text="是/否确认", command=ask_yes_no).pack(pady=2)
tk.Button(root, text="确定/取消", command=ask_ok_cancel).pack(pady=2)
tk.Button(root, text="重试/取消", command=ask_retry_cancel).pack(pady=2)

label_result = tk.Label(root, text="结果: ")
label_result.pack(pady=10)

# ── 返回值汇总 ──
# showinfo / showwarning / showerror：返回 "ok"
# askyesno：返回 True/False
# askokcancel：返回 True/False
# askretrycancel：返回 True/False
# askyesnocancel：返回 True/False/None

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'askyesno() 返回布尔值，但 askyesnocancel() 可能返回 None（点取消时）。'
            '所以做三个选项的判断时，要用 if result is None 而不是 if not result。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ── 16. Filedialog ──
          const SectionHeader('16. Filedialog 文件对话框', icon: Icons.folder_open),
          const Paragraph(
            'filedialog 提供打开/保存文件的系统原生对话框。'
            '支持文件类型过滤，返回选中文件的路径字符串。',
          ),
          const CodeBlock(
            r'''from tkinter import filedialog
import tkinter as tk

root = tk.Tk()
root.title("文件对话框演示")
root.geometry("500x350")

def open_file():
    # askopenfilename：打开文件
    filepath = filedialog.askopenfilename(
        title="选择一个文件",
        filetypes=[
            ("文本文件", "*.txt"),
            ("所有文件", "*.*"),
            ("图片", "*.png *.jpg *.gif"),
            ("Python文件", "*.py"),
        ],
        initialdir="/"           # 初始目录
    )
    if filepath:                 # 用户没取消
        label_path.config(text=f"打开: {filepath}")

def open_files():
    # askopenfilenames：多选，返回元组
    files = filedialog.askopenfilenames(title="选择多个文件")
    if files:
        label_path.config(text=f"选择了 {len(files)} 个文件")

def save_file():
    # asksaveasfilename：保存文件
    filepath = filedialog.asksaveasfilename(
        title="保存为",
        defaultextension=".txt",
        filetypes=[("文本文件", "*.txt"), ("所有文件", "*.*")]
    )
    if filepath:
        label_path.config(text=f"保存到: {filepath}")

def open_directory():
    # askdirectory：选择目录
    directory = filedialog.askdirectory(title="选择目录")
    if directory:
        label_path.config(text=f"目录: {directory}")

tk.Button(root, text="打开单个文件", command=open_file).pack(pady=2)
tk.Button(root, text="打开多个文件", command=open_files).pack(pady=2)
tk.Button(root, text="保存文件", command=save_file).pack(pady=2)
tk.Button(root, text="选择目录", command=open_directory).pack(pady=2)

label_path = tk.Label(root, text="未选择", wraplength=400)
label_path.pack(pady=20)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'filedialog 返回的是文件路径字符串。如果用户点击"取消"，'
            '返回空字符串。所以一定要先判断 if filepath: 再使用。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ── 17. 颜色和字体 ──
          const SectionHeader('17. 颜色与字体', icon: Icons.palette),
          const Paragraph(
            'Tkinter 支持多种颜色表示方式：命名颜色、十六进制 RGB、'
            '以及通过 Font 类管理字体。',
          ),
          const CodeBlock(
            r'''import tkinter as tk
from tkinter import font

root = tk.Tk()
root.title("颜色与字体")
root.geometry("500x350")

# ── 颜色表示方式 ──
# 1. 颜色名称（Tk 内置，跨平台）
colors_frame = tk.Frame(root)
colors_frame.pack(pady=5)

tk.Label(colors_frame, text="red", bg="red",
         fg="white", width=10).pack(side=tk.LEFT)
tk.Label(colors_frame, text="green", bg="green",
         fg="white", width=10).pack(side=tk.LEFT)
tk.Label(colors_frame, text="blue", bg="blue",
         fg="white", width=10).pack(side=tk.LEFT)

# 2. 十六进制 RGB（最常用）
tk.Label(root, text="#FF5733 橙色",
         bg="#FF5733", fg="white").pack(pady=2)
tk.Label(root, text="#33FF57 绿色",
         bg="#33FF57", fg="black").pack(pady=2)
tk.Label(root, text="#3357FF 蓝色",
         bg="#3357FF", fg="white").pack(pady=2)

# ── Font 类（推荐！比字符串更灵活） ──
# 创建字体对象
title_font = font.Font(
    family="Arial",
    size=24,
    weight="bold",
    slant="italic",          # "roman" 正常 / "italic" 斜体
    underline=False,
    overstrike=False
)

mono_font = font.Font(
    family="Courier New",
    size=14
)

tk.Label(root, text="标题字体（Arial 24 bold italic）",
         font=title_font).pack(pady=10)
tk.Label(root, text="等宽字体（Courier New 14）",
         font=mono_font).pack(pady=5)

# 字体字符串方式（旧写法）
tk.Label(root, text="字符串字体",
         font=("Times New Roman", 16, "bold")).pack()

# 获取系统可用字体
# available = font.families()
# print(available[:20])  # 打印前20种字体

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            '推荐使用 font.Font() 创建字体对象而不是字符串写法，'
            '因为 Font 对象可以在运行时修改（obj.config(size=30)），'
            '而且多个组件可以共享同一个 Font 对象。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 18. 事件绑定 ──
          const SectionHeader('18. 事件绑定', icon: Icons.touch_app),
          const Paragraph(
            'bind() 方法把事件和处理函数关联起来。'
            'Tkinter 支持鼠标、键盘、窗口等多种事件类型。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("事件绑定演示")
root.geometry("600x400")

label = tk.Label(root, text="在这交互", font=("Arial", 20),
                 width=20, height=3, bg="lightblue")
label.pack(pady=20)

# ── 鼠标事件 ──
def on_click(e):
    label.config(text=f"点击: ({e.x}, {e.y})")
def on_double_click(e):
    label.config(text=f"双击！({e.x},{e.y})", bg="yellow")
def on_right_click(e):
    label.config(text=f"右键: ({e.x}, {e.y})", bg="orange")
def on_enter(e):
    label.config(bg="lightgreen")
def on_leave(e):
    label.config(bg="lightblue")

label.bind("<Button-1>", on_click)           # 鼠标左键点击
label.bind("<Double-Button-1>", on_double_click)  # 双击左键
label.bind("<Button-3>", on_right_click)     # 鼠标右键点击
label.bind("<Enter>", on_enter)              # 鼠标进入
label.bind("<Leave>", on_leave)              # 鼠标离开
label.bind("<B1-Motion>", lambda e:          # 拖动
    label.config(text=f"拖动到: ({e.x},{e.y})"))

# ── 键盘事件 ──
def on_key(e):
    label.config(text=f"按键: {e.char} (keycode={e.keycode})")
def on_special(e):
    label.config(text=f"特殊键: {e.keysym}")

root.bind("<Key>", on_key)                   # 任意按键
root.bind("<Return>", lambda e:              # 回车键
    label.config(text="按了回车！"))
root.bind("<Escape>", lambda e:              # Esc 键
    label.config(text="按了ESC！"))
root.bind("<Control-c>", lambda e:           # Ctrl+C
    label.config(text="Ctrl+C 复制！"))

# ── 常用事件类型 ──
# <Button-1>      鼠标左键      <Button-3>     鼠标右键
# <Double-Button-1> 双击左键    <B1-Motion>    左键拖动
# <Enter>         鼠标进入      <Leave>        鼠标离开
# <Key>           任意按键      <Return>       回车键
# <Escape>        ESC键         <Control-c>    Ctrl+C
# <FocusIn>       获得焦点      <FocusOut>     失去焦点
# <Configure>     组件大小变化   <Destroy>      组件销毁

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            '事件回调函数接收一个 event 参数，包含：'
            'e.x/e.y（鼠标坐标）、e.char（按键字符）、e.keysym（键名）、'
            'e.keycode（键码）、e.widget（触发事件的组件）。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 19. ttk 主题组件 ──
          const SectionHeader('19. ttk 主题组件', icon: Icons.style),
          const Paragraph(
            'ttk（Themed Tkinter）是 Tkinter 的升级版组件集，外观更现代、更美观。'
            'ttk 组件支持主题切换，在不同平台上看起来更"原生"。',
          ),
          const CodeBlock(
            r'''from tkinter import ttk
import tkinter as tk

root = tk.Tk()
root.title("ttk 主题组件演示")
root.geometry("600x450")

# ── 对比 tk vs ttk ──
tk.Label(root, text="传统 Label（tk）").pack()
ttk.Label(root, text="主题 Label（ttk）").pack()

# ── ttk 按钮和组合框 ──
ttk.Button(root, text="ttk 按钮",
           command=lambda: print("点击")).pack(pady=5)

combo = ttk.Combobox(root, values=["选项1", "选项2", "选项3"])
combo.set("ttk 下拉框")
combo.pack(pady=5)

# ── ttk 进度条 ──
progress = ttk.Progressbar(root, length=300, mode="indeterminate")
progress.pack(pady=10)
progress.start()  # 开始动画

# ── ttk Treeview（表格/树形视图） ──
tree = ttk.Treeview(root, columns=("name", "age", "score"),
                    show="headings", height=6)
tree.heading("name", text="姓名")
tree.heading("age", text="年龄")
tree.heading("score", text="分数")
tree.column("name", width=100)
tree.column("age", width=60)
tree.column("score", width=60)

# 插入数据
tree.insert("", tk.END, values=("张三", 20, 95))
tree.insert("", tk.END, values=("李四", 22, 88))
tree.insert("", tk.END, values=("王五", 19, 92))
tree.pack(pady=10)

# ttk 支持的主题
# print(ttk.Style().theme_names())  # 获取所有主题
# ttk.Style().theme_use("clam")     # 切换主题

# ── ttk 可用的组件 ──
# ttk.Label / ttk.Button / ttk.Entry / ttk.Combobox
# ttk.Checkbutton / ttk.Radiobutton
# ttk.Progressbar / ttk.Scale / ttk.Scrollbar
# ttk.Treeview / ttk.Notebook（标签页）
# ttk.Separator / ttk.Sizegrip / ttk.LabelFrame

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'ttk 组件的样式更现代，但有些自定义能力不如 tk 组件（如 bg/fg 参数）。'
            'ttk 用 Style 类配置外观，tk 用 config() 直接设置。'
            '实际开发中建议混合使用：能用 ttk 的尽量用 ttk。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 20. Menu 菜单 ──
          const SectionHeader('20. Menu 菜单', icon: Icons.menu),
          const Paragraph(
            'Tkinter 支持菜单栏（Menu bar）和右键弹出菜单（Popup menu）。'
            '菜单可以嵌套，支持快捷键（accelerator）和分割线。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("菜单演示")
root.geometry("500x400")

# ── 创建菜单栏 ──
menubar = tk.Menu(root)
root.config(menu=menubar)   # 把 menubar 设为窗口菜单栏

# ── 文件菜单 ──
file_menu = tk.Menu(menubar, tearoff=0)  # tearoff=0 去掉虚线
menubar.add_cascade(label="文件", menu=file_menu)

file_menu.add_command(label="新建", accelerator="Ctrl+N",
                      command=lambda: print("新建文件"))
file_menu.add_command(label="打开", accelerator="Ctrl+O",
                      command=lambda: print("打开文件"))
file_menu.add_separator()                # 分割线
file_menu.add_command(label="保存", accelerator="Ctrl+S",
                      command=lambda: print("保存"))
file_menu.add_command(label="另存为...")
file_menu.add_separator()
file_menu.add_command(label="退出", command=root.quit)

# ── 编辑菜单（子菜单） ──
edit_menu = tk.Menu(menubar, tearoff=0)
menubar.add_cascade(label="编辑", menu=edit_menu)
edit_menu.add_command(label="撤销", accelerator="Ctrl+Z")
edit_menu.add_command(label="重做", accelerator="Ctrl+Y")
edit_menu.add_separator()

# 子菜单
sub_menu = tk.Menu(edit_menu, tearoff=0)
sub_menu.add_command(label="复制")
sub_menu.add_command(label="剪切")
sub_menu.add_command(label="粘贴")
edit_menu.add_cascade(label="剪贴板", menu=sub_menu)

# ── 帮助菜单 ──
help_menu = tk.Menu(menubar, tearoff=0)
menubar.add_cascade(label="帮助", menu=help_menu)
help_menu.add_command(label="关于", command=lambda: print("关于"))

# ── 右键弹出菜单 ──
popup = tk.Menu(root, tearoff=0)
popup.add_command(label="复制", command=lambda: print("复制"))
popup.add_command(label="粘贴", command=lambda: print("粘贴"))
popup.add_separator()
popup.add_command(label="删除", command=lambda: print("删除"))

def show_popup(e):
    popup.tk_popup(e.x_root, e.y_root)  # 在鼠标位置弹出

root.bind("<Button-3>", show_popup)     # 绑定右键

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'tearoff=0 去掉菜单顶部的虚线（默认虚线可撕下菜单）。'
            'accelerator 只是显示快捷键文本，真正绑定快捷键需要额外的 bind()。'
            '也可以用 add_radiobutton() 和 add_checkbutton() 添加选择项。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 21. Canvas 画布 ──
          const SectionHeader('21. Canvas 画布', icon: Icons.brush),
          const Paragraph(
            'Canvas 是 Tkinter 的绘图画布，可以画线、矩形、椭圆、弧线、文字，'
            '以及显示图片。它也可以用来制作自定义组件和游戏。',
          ),
          const CodeBlock(
            r'''import tkinter as tk

root = tk.Tk()
root.title("Canvas 画布演示")
root.geometry("600x500")

canvas = tk.Canvas(root, width=550, height=450, bg="white")
canvas.pack(pady=10)

# ── 直线 ──
canvas.create_line(50, 50, 200, 50,          # 起点(x1,y1) 终点(x2,y2)
                   fill="red", width=3)

canvas.create_line(50, 80, 200, 130,         # 斜线
                   fill="blue", width=2, dash=(4, 2))  # 虚线

# ── 矩形 ──
canvas.create_rectangle(50, 150, 200, 250,   # 左上角 + 右下角
                        fill="lightblue",
                        outline="navy",
                        width=3)

# ── 椭圆（在矩形区域内内切） ──
canvas.create_oval(250, 50, 400, 150,        # 外切矩形
                   fill="lightgreen",
                   outline="darkgreen",
                   width=2)

# ── 圆形（正方形内切椭圆 = 圆） ──
canvas.create_oval(250, 180, 350, 280,       # 边长100的正方形
                   fill="pink", outline="red", width=2)

# ── 弧线 ──
canvas.create_arc(420, 50, 520, 150,
                  start=0, extent=120,        # 起始角度 + 角度范围
                  fill="orange", outline="brown")

# ── 多边形 ──
canvas.create_polygon(100, 300, 50, 380, 150, 380,  # 三角形
                      fill="yellow", outline="black")

# ── 文字 ──
canvas.create_text(300, 380, text="Canvas 绘图演示",
                   font=("Arial", 20, "bold"),
                   fill="purple")

# ── 图片 ──
# img = tk.PhotoImage(file="image.png")
# canvas.create_image(100, 100, image=img)

# ── 图形标记和修改 ──
rect = canvas.create_rectangle(400, 300, 500, 400,
                               fill="cyan")
# 修改已有图形
canvas.itemconfig(rect, fill="magenta")

# ── 绑定事件到图形 ──
def on_canvas_click(e):
    # 获取点击位置的图形
    items = canvas.find_closest(e.x, e.y)
    canvas.itemconfig(items, fill="gold")

canvas.bind("<Button-1>", on_canvas_click)

root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            'Canvas 的 create_xxx() 方法返回图形对象的 ID（整数），'
            '可以用 itemconfig(id, ...) 修改、delete(id) 删除、'
            'move(id, dx, dy) 移动。Canvas 是实现自定义绘图的核心。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 22. 完整项目：简易文本编辑器 ──
          const SectionHeader('22. 完整项目：简易文本编辑器', icon: Icons.terminal),
          const Paragraph(
            '综合运用前面学到的知识，做一个简单的文本编辑器。'
            '它支持打开文件、保存文件、编辑文本等功能。',
          ),
          const CodeBlock(
            r'''import tkinter as tk
from tkinter import filedialog, messagebox

class TextEditor:
    """简易文本编辑器"""

    def __init__(self, root):
        self.root = root
        self.root.title("简易文本编辑器")
        self.root.geometry("800x600")
        self.filepath = None

        self._create_menu()
        self._create_widgets()

    def _create_menu(self):
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        # 文件菜单
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="文件", menu=file_menu)
        file_menu.add_command(label="打开", accelerator="Ctrl+O",
                              command=self.open_file)
        file_menu.add_command(label="保存", accelerator="Ctrl+S",
                              command=self.save_file)
        file_menu.add_command(label="另存为...", command=self.save_as)
        file_menu.add_separator()
        file_menu.add_command(label="退出", command=self.root.quit)

        # 绑定快捷键
        self.root.bind("<Control-o>", lambda e: self.open_file())
        self.root.bind("<Control-s>", lambda e: self.save_file())

    def _create_widgets(self):
        # 文本编辑区
        self.text = tk.Text(self.root, wrap=tk.WORD,
                            font=("Consolas", 12))
        self.text.pack(fill=tk.BOTH, expand=True)

        # 状态栏
        self.status = tk.Label(self.root, text="就绪",
                               anchor=tk.W, relief=tk.SUNKEN)
        self.status.pack(fill=tk.X)

    def open_file(self):
        path = filedialog.askopenfilename(
            filetypes=[("文本文件", "*.txt"), ("所有文件", "*.*")]
        )
        if not path:
            return
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            self.text.delete(1.0, tk.END)
            self.text.insert(1.0, content)
            self.filepath = path
            self.root.title(f"简易编辑器 - {path}")
            self.status.config(text=f"已打开: {path}")
        except Exception as e:
            messagebox.showerror("打开失败", str(e))

    def save_file(self):
        if self.filepath:
            self._write_file(self.filepath)
        else:
            self.save_as()

    def save_as(self):
        path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("文本文件", "*.txt"), ("所有文件", "*.*")]
        )
        if path:
            self.filepath = path
            self._write_file(path)

    def _write_file(self, path):
        try:
            content = self.text.get(1.0, tk.END)
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            self.root.title(f"简易编辑器 - {path}")
            self.status.config(text=f"已保存: {path}")
        except Exception as e:
            messagebox.showerror("保存失败", str(e))


if __name__ == "__main__":
    root = tk.Tk()
    app = TextEditor(root)
    root.mainloop()
''',
            language: 'Python',
          ),
          const TipBox(
            '这个项目展示了 Tkinter 开发的最佳实践：'
            '用类封装、分离菜单创建和界面创建、用 filedialog 统一文件操作。'
            '你可以在此基础上添加撤销/重做、查找替换等高级功能。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 23. 最佳实践 ──
          const SectionHeader('23. 最佳实践', icon: Icons.star),
          const Paragraph(
            '写出高质量 Tkinter 应用的核心原则：分离逻辑与 UI、'
            '使用面向对象组织代码、遵循事件驱动模式。',
          ),
          const CodeBlock(
            r'''# ════════════════════════════════════════
#   Tkinter 最佳实践
# ════════════════════════════════════════

# 1️⃣ 始终用类封装（不要写过程式代码）
class MyApp:
    """把每个窗口写成一个类"""
    def __init__(self, root):
        self.root = root
        self._setup_ui()

    def _setup_ui(self):
        """集中创建界面"""
        pass

    def _on_button_click(self):
        """处理方法"""
        pass

# 2️⃣ 分离 UI 搭建和业务逻辑
class Calculator:
    def __init__(self, root):
        self.root = root
        self.result = 0
        self._create_display()    # UI
        self._create_buttons()    # UI
        self._bind_events()       # 事件

    def _calculate(self):         # 业务逻辑
        pass

# 3️⃣ 使用 StringVar/IntVar 自动更新
name_var = tk.StringVar()
entry = tk.Entry(root, textvariable=name_var)
label = tk.Label(root, textvariable=name_var)
# 输入框变了，标签自动更新！

# 4️⃣ 注意生命周期
# tk.PhotoImage 必须保持引用，否则图片不显示
# ✅ 正确：self.img = tk.PhotoImage(file="logo.png")
# ❌ 错误：img = tk.PhotoImage(file="logo.png")  # 方法结束时被回收

# 5️⃣ 异常处理
def safe_open():
    try:
        with open(filepath, "r") as f:
            return f.read()
    except FileNotFoundError:
        messagebox.showerror("错误", "文件不存在")
    except PermissionError:
        messagebox.showerror("错误", "没有读取权限")

# 6️⃣ 配置分离
# 把颜色、字体等常量集中管理
class AppConfig:
    BG_COLOR = "#f0f0f0"
    FONT = ("Arial", 12)
    BTN_COLOR = "#4CAF50"

    @classmethod
    def apply(cls, root):
        root.configure(bg=cls.BG_COLOR)

# 7️⃣ 子窗口用 Toplevel
def open_child():
    child = tk.Toplevel(root)
    child.title("子窗口")
    child.geometry("300x200")
    child.transient(root)      # 依附于父窗口
    child.grab_set()           # 模态：只能操作子窗口
''',
            language: 'Python',
          ),
          const TipBox(
            '最重要的原则：永远不要用"死循环"（while True）阻塞 Tkinter 主线程。'
            'Tkinter 是事件驱动的，用 root.after(ms, callback) 做定时任务，'
            '用 Thread 做后台任务（但不要直接操作 UI 线程外的组件）。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ── 24. 海龟绘图 (turtle) ──
          const SectionHeader('24. 海龟绘图 (turtle)', icon: Icons.auto_awesome),
          const Paragraph(
            'turtle（海龟绘图）是 Python 内置的绘图工具，通过控制屏幕上'
            '的"小海龟"移动来绘制图形。它非常适合初学者学习编程逻辑'
            '（循环、函数、递归），也是 Python 最受欢迎的趣味入门方式之一。',
          ),
          const TipBox(
            'turtle 是 Python 标准库的一部分，无需 pip install。'
            '只需 import turtle 即可使用。'
            '注意：在某些在线 IDE 中可能需要手动安装。',
            type: TipType.info,
          ),
          const CodeBlock(
            r'''import turtle

# 创建画布和海龟
t = turtle.Turtle()       # 创建海龟对象
t.shape("turtle")        # 设置形状为海龟
t.speed(1)               # 设置速度（1-10，0 最快）

# 基本移动
t.forward(100)           # 前进 100 像素
t.left(90)               # 左转 90 度
t.forward(50)
t.right(45)              # 右转 45 度
t.backward(30)           # 后退 30 像素

# 完成后保持窗口打开
turtle.done()            # 或 turtle.exitonclick()
''',
            language: 'Python',
          ),
          const TipBox(
            'turtle.done() 让窗口保持打开；turtle.exitonclick() 则是'
            '"点击窗口关闭"。初学者常用 done() 确保能看到绘制结果。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 24.1 基本移动与方向 ──
          const SectionHeader('24.1 基本移动与方向', icon: Icons.directions_walk),
          const Paragraph(
            'forward(distance) 和 backward(distance) 控制海龟前进/后退，'
            'left(angle) 和 right(angle) 控制海龟左转/右转（角度单位为度）。'
            '这四个函数是所有 turtle 绘图的基础。',
          ),
          const CodeBlock(
            r'''import turtle

t = turtle.Turtle()
t.speed(2)

# 前进与后退
t.forward(100)      # 向前走 100 像素
t.backward(50)      # 向后走 50 像素

# 方向控制
t.left(90)          # 左转 90 度（面朝上）
t.forward(100)
t.right(45)         # 右转 45 度
t.forward(100)

# 查看当前状态
print(t.position())  # 当前位置 (x, y)
print(t.heading())   # 当前方向角度（0=右, 90=上, 180=左, 270=下）

turtle.done()
''',
            language: 'Python',
          ),
          const TipBox(
            '海龟的方向角度：0 度朝右（东），90 度朝上（北），'
            '180 度朝左（西），270 度朝下（南）。'
            '也可用 setheading(angle) 直接设置方向。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 24.2 画笔控制 ──
          const SectionHeader('24.2 画笔控制', icon: Icons.brush),
          const Paragraph(
            'penup() 抬起画笔（移动时不画线），pendown() 落下画笔（恢复绘制）。'
            'color() 设置画笔颜色，begin_fill() / end_fill() 填充封闭图形，'
            'circle() 画圆，speed() 设置速度，goto() 直接跳转到指定坐标。',
          ),
          const CodeBlock(
            r'''import turtle

t = turtle.Turtle()
t.speed(3)

# ── 画笔抬起/落下 ──
t.penup()
t.goto(-100, 100)       # 移动到 (-100, 100)（不画线）
t.pendown()

# ── 颜色设置 ──
t.color("red")
t.forward(50)
t.color("blue")
t.forward(50)

# ── 填充 ──
t.penup()
t.goto(100, 100)
t.pendown()
t.color("green")
t.begin_fill()           # 开始填充
for _ in range(4):
    t.forward(50)
    t.left(90)
t.end_fill()             # 结束填充

# ── 画圆 ──
t.penup()
t.goto(0, -100)
t.pendown()
t.color("purple")
t.circle(50)             # 半径 50 的圆

# ── 清空（取消注释测试） ──
# t.clear()              # 清空绘图，海龟回到原点

turtle.done()
''',
            language: 'Python',
          ),
          const CodeBlock(
            r'''# ── turtle 常用方法速查 ──
# forward(d)   / fd(d)      前进 d 像素
# backward(d)  / bk(d)      后退 d 像素
# left(a)      / lt(a)      左转 a 度
# right(a)     / rt(a)      右转 a 度
# goto(x, y)   / setpos(x, y)  移动到 (x, y)
# setheading(a) / seth(a)   直接设置方向角度
# home()                    回到原点（方向朝右）
# circle(r)                 画半径为 r 的圆
# dot(size)                 画点
# speed(s)                  设置速度（0=最快，1-10）
# color(c)                  设置画笔颜色
# pencolor(c)               设置画笔颜色
# fillcolor(c)              设置填充颜色
# begin_fill()              开始填充
# end_fill()                结束填充
# penup()    / pu()         抬起画笔
# pendown()  / pd()         落下画笔
# pensize(w)                设置画笔粗细
# clear()                   清空绘图
# reset()                   清空并重置所有设置
# hideturtle() / ht()       隐藏海龟
# showturtle() / st()       显示海龟
# write(text)               在当前位置写文字
# undo()                    撤销一步
# stamp()                   盖一个海龟印章
''',
            language: 'Python',
          ),
          const TipBox(
            'turtle 提供了大量简写别名：fd / bk / lt / rt / pu / pd / '
            'ht / st 等。这些别名在写短小的绘图代码时非常方便。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ── 24.3 绘图示例 ──
          const SectionHeader('24.3 经典绘图示例', icon: Icons.palette),
          const Paragraph(
            '下面通过四个经典示例展示 turtle 的强大之处：'
            '正方形（循环）、五角星（角度计算）、彩色螺旋（动态变化）、'
            '分形树（递归）。',
          ),

          // ── 正方形 ──
          const SectionHeader('示例 1：绘制正方形', icon: Icons.crop_square),
          const Paragraph(
            '最简单的图形——用 for 循环重复 4 次前进和左转。'
            '这是学习循环控制的最佳入门示例。',
          ),
          const CodeBlock(
            r'''import turtle

t = turtle.Turtle()
t.speed(2)

# 画正方形：重复 4 次
for _ in range(4):
    t.forward(100)      # 边长 100
    t.left(90)          # 左转 90 度

turtle.done()
''',
            language: 'Python',
          ),
          const OutputBox(
            '输出：一个边长为 100 像素的正方形。\n'
            '多练习：range(3) 是三角形，range(6) 是六边形！'
          ),

          // ── 五角星 ──
          const SectionHeader('示例 2：绘制五角星', icon: Icons.star),
          const Paragraph(
            '五角星的每个外角是 144 度（180 - 180/5）。'
            '通过调整旋转角度和边长，可以画出各种星形图案。',
          ),
          const CodeBlock(
            r'''import turtle

t = turtle.Turtle()
t.speed(3)
t.color("gold")
t.pensize(3)

# 画五角星
for _ in range(5):
    t.forward(150)      # 边长
    t.right(144)        # 五角星外角 = 144 度

turtle.done()
''',
            language: 'Python',
          ),
          const OutputBox(
            '输出：一个金色的五角星。\n'
            '变化：range(11) + right(180 - 180/11) 可以画出 11 角星！'
          ),

          // ── 彩色螺旋 ──
          const SectionHeader('示例 3：彩色螺旋', icon: Icons.autorenew),
          const Paragraph(
            '螺旋图案通过循环中递增边长并循环切换颜色来实现。'
            '配合 speed(0) 让绘制过程更快更流畅。',
          ),
          const CodeBlock(
            r'''import turtle

t = turtle.Turtle()
t.speed(0)             # 最快速度
t.pensize(2)

colors = ["red", "orange", "yellow", "green",
          "blue", "purple", "pink"]

# 彩色螺旋
for i in range(60):
    t.color(colors[i % len(colors)])  # 循环切换颜色
    t.forward(i * 2)                  # 边长递增
    t.left(59)                        # 左转 59 度

turtle.done()
''',
            language: 'Python',
          ),
          const OutputBox(
            '输出：一个绚丽的彩色螺旋图案。\n'
            '调整 range(60) 控制圈数，调整 left(59) 改变螺旋密度！'
          ),

          // ── 分形树 ──
          const SectionHeader('示例 4：分形树（递归）', icon: Icons.nature),
          const Paragraph(
            '分形树是递归的经典案例——每个树枝都递归地生长出更小的树枝。'
            '递归深度决定树的细节丰富程度，深度每 +1 树枝数量翻倍。',
          ),
          const CodeBlock(
            r'''import turtle

def draw_branch(t, length, angle, depth):
    """递归绘制分形树"""
    if depth == 0:                     # 递归终止条件
        t.color("green")               # 叶子颜色
        t.dot(4)                       # 画叶子
        t.color("brown")
        return

    t.forward(length)                  # 画当前树枝
    t.left(angle)                      # 左转
    draw_branch(t, length * 0.7, angle, depth - 1)  # 左分支
    t.right(angle * 2)                # 右转（回正 + 右转）
    draw_branch(t, length * 0.7, angle, depth - 1)  # 右分支
    t.left(angle)                      # 回正
    t.backward(length)                 # 回到起点

# 初始化
t = turtle.Turtle()
t.speed(0)
t.pensize(2)
t.color("brown")
t.left(90)                           # 朝上
t.penup()
t.goto(0, -250)                      # 移到窗口底部
t.pendown()

# 绘制分形树（递归深度 8）
draw_branch(t, 120, 30, 8)
t.hideturtle()
turtle.done()
''',
            language: 'Python',
          ),
          const OutputBox(
            '输出：一棵自然的递归分形树。\n'
            '调整 depth 控制复杂度（推荐 6-10），调整 angle 控制树枝开合角度！'
          ),
          const TipBox(
            '分形树的递归思想：每根树枝"分裂"成两根更短的树枝，'
            '直到长度小于阈值。这是理解递归最直观的视觉化例子之一。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ── 小练习 ──
          const SectionHeader('小练习', icon: Icons.edit_note),
          const StepItem(
            step: 1,
            title: '登录界面',
            description: '用 grid() 做一个登录界面，包含用户名/密码输入和登录按钮。点击登录后通过 messagebox 显示"登录成功"。',
          ),
          const StepItem(
            step: 2,
            title: '简单计算器',
            description: '用 grid() 做一个 4x4 计算器（数字 0-9、+、-、*、/、=）。支持连续运算和清空。',
          ),
          const StepItem(
            step: 3,
            title: '图片查看器',
            description: '用 Canvas 和 filedialog 做一个图片查看器，支持打开图片、显示、缩放。',
          ),
          const StepItem(
            step: 4,
            title: '待办事项应用',
            description: '用 Listbox 和 Entry 做一个待办事项列表。支持添加、删除、标记完成，用 Checkbutton 表示完成状态。',
          ),
          const StepItem(
            step: 5,
            title: '简易画板',
            description: '用 Canvas 实现一个画板。支持鼠标绘图（<B1-Motion>）、选择颜色（Scale 调RGB）、清空画布。',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
