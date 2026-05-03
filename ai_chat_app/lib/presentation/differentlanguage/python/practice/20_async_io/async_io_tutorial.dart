import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// asyncio 任务执行模拟演示
class _AsyncTaskSimDemo extends StatefulWidget {
  const _AsyncTaskSimDemo();
  @override
  State<_AsyncTaskSimDemo> createState() => _AsyncTaskSimDemoState();
}

class _AsyncTaskSimDemoState extends State<_AsyncTaskSimDemo> {
  List<int> _durations = [2, 3, 1];
  String _mode = 'concurrent';
  List<String> _states = ['pending', 'pending', 'pending'];
  bool _running = false;
  int _elapsed = 0;
  int _tick = 0;
  Timer? _timer;

  void _run() {
    setState(() { _running = true; _states = List.filled(_durations.length, 'pending'); _elapsed = 0; _tick = 0; });
    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!mounted) { t.cancel(); return; }
      _tick++;
      setState(() {
        _elapsed = (_tick * 0.5).ceil();
        for (int i = 0; i < _durations.length; i++) {
          if (_mode == 'concurrent') {
            _states[i] = _tick >= _durations[i] * 2 ? 'done' : _tick >= 1 ? 'running' : 'pending';
          } else {
            int startTime = _durations.take(i).fold(0, (a, b) => a + b) * 2;
            _states[i] = _tick >= startTime + _durations[i] * 2 ? 'done' : _tick >= startTime ? 'running' : 'pending';
          }
        }
        if (_states.every((s) => s == 'done')) { t.cancel(); _running = false; _timer = null; }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Color _stateColor(String s) => s == 'done' ? Colors.green : s == 'running' ? Colors.blue : Colors.grey;
  IconData _stateIcon(String s) => s == 'done' ? Icons.check_circle : s == 'running' ? Icons.hourglass_top : Icons.circle_outlined;

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '⏱️ asyncio 任务模拟',
      subtitle: '对比并发（asyncio.gather）和串行（await）的执行效率',
      children: [
        ParamChoiceChips<String>(label: '执行模式', value: _mode,
          options: [('concurrent', 'asyncio.gather（并发）'), ('sequential', 'await（串行）')],
          onChanged: (v) { if (!_running) setState(() => _mode = v); }),
        ParamIntSlider(label: '任务1时长', value: _durations[0], min: 1, max: 5, unit: '秒', onChanged: (v) { if (!_running) setState(() { _durations[0] = v; }); }),
        ParamIntSlider(label: '任务2时长', value: _durations[1], min: 1, max: 5, unit: '秒', onChanged: (v) { if (!_running) setState(() { _durations[1] = v; }); }),
        ParamIntSlider(label: '任务3时长', value: _durations[2], min: 1, max: 5, unit: '秒', onChanged: (v) { if (!_running) setState(() { _durations[2] = v; }); }),
        const SizedBox(height: 8),
        ...List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: _stateColor(_states[i]).withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: _stateColor(_states[i]).withOpacity(0.4))),
          child: Row(children: [
            Icon(_stateIcon(_states[i]), size: 18, color: _stateColor(_states[i])),
            const SizedBox(width: 8),
            Expanded(child: Text('任务 ${i + 1}（${_durations[i]}s）', style: const TextStyle(fontWeight: FontWeight.w500))),
            if (_states[i] == 'running') const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            if (_states[i] == 'done') const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ]),
        )),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(onPressed: _running ? null : _run, icon: const Icon(Icons.play_arrow, size: 16), label: Text(_running ? '运行中...' : '▶ 启动模拟')),
          const SizedBox(width: 8),
          TextButton(onPressed: () => setState(() { _states = List.filled(3, 'pending'); _elapsed = 0; _tick = 0; }), child: const Text('重置')),
        ]),
        LiveCodeBlock(
          _mode == 'concurrent'
              ? 'import asyncio\n\n'
                'async def task(n, delay):\n'
                '    await asyncio.sleep(delay)\n'
                '    return f"task{n} done"\n\n'
                'results = await asyncio.gather(\n'
                '    task(1, ${_durations[0]}),\n'
                '    task(2, ${_durations[1]}),\n'
                '    task(3, ${_durations[2]}),\n'
                ')\n'
                '# 总耗时 = ${_durations.reduce((a,b) => a > b ? a : b)}秒（最慢任务）'
              : 'import asyncio\n\n'
                'async def main():\n'
                '    await asyncio.sleep(${_durations[0]})  # 任务1\n'
                '    await asyncio.sleep(${_durations[1]})  # 任务2\n'
                '    await asyncio.sleep(${_durations[2]})  # 任务3\n'
                '# 总耗时 = ${_durations.fold(0, (a,b) => a+b)}秒（累加）',
        ),
        LiveOutputBox(_states.every((s) => s == 'done')
            ? '全部完成！总耗时: ${_elapsed}秒\n${_mode == 'concurrent' ? '并发优势：3个任务只用了最慢那个的时间' : '串行执行：每个任务依次等待'}'
            : _running ? '执行中... $_elapsed秒' : '点击「启动」观察执行过程'),
      ],
    );
  }
}

class PythonAsyncIOTutorial extends StatelessWidget {
  const PythonAsyncIOTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第20章 异步IO'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =================================================================
          // Chapter Overview
          // =================================================================
          const SectionHeader('第20章 Overview', icon: Icons.menu_book),
          const Paragraph(
            '异步IO是Python中处理高并发IO操作的核心技术。本章将深入探讨协程(Coroutines)、'
            'asyncio标准库以及aiohttp三方库的使用。通过学习本章，你将理解如何在Python中编写高效的异步代码，'
            '处理网络请求、文件操作和其他IO密集型任务。',
          ),
          const Paragraph(
            '异步编程允许程序在等待IO操作完成时暂停当前任务，转而执行其他任务，从而充分利用CPU时间。'
            'Python的asyncio库自3.4版本引入，经过3.5的async/await语法完善，'
            '已成为Python异步编程的事实标准。',
          ),
          const TipBox(
            '本章内容较为进阶，建议先掌握Python函数装饰器、生成器和基本的网络编程概念后再学习。',
            type: TipType.info,
          ),
          const DividerLine(),

          // =================================================================
          // Part 1: 协程 (Coroutines)
          // =================================================================
          const SectionHeader('1. 协程 (Coroutines)', icon: Icons.swap_horiz),

          // --- 1.1 What are coroutines ---
          const SectionHeader('1.1 什么是协程', icon: Icons.help_outline),
          const Paragraph(
            '协程(Coroutine)是一种比线程更轻量级的并发执行单元。与传统的函数调用不同，'
            '协程可以在执行过程中暂停(suspend)，将控制权交还给事件循环，然后在之后的某个'
            '时刻从暂停处恢复(resume)执行。这种"暂停-恢复"能力使得协程非常适合处理IO密集型任务。',
          ),
          const Paragraph(
            '在Python中，协程的发展经历了两个主要阶段：基于生成器的协程(Generator-based coroutines)'
            '和基于async/await的原生协程(Native coroutines)。',
          ),
          const Paragraph(
            '生成器协程使用yield关键字暂停执行，通过yield from委托给其他生成器。自Python 3.5起，'
            'async/await语法成为首选方式，代码更加清晰直观。Python 3.7之后，生成器协程已被废弃，'
            '官方推荐使用async/await。',
          ),
          const CodeBlock(
            r'''# Generator-based coroutine (deprecated)
import asyncio

@asyncio.coroutine
def hello_world():
    yield from asyncio.sleep(1)
    print('Hello, World!')

# Native coroutine (modern, preferred)
async def hello_world_modern():
    await asyncio.sleep(1)
    print('Hello, World!')''',
            language: 'Python',
          ),
          const Paragraph(
            '可以看到，async/await版本的代码更加简洁直观。@asyncio.coroutine装饰器在Python 3.8中已被移除，'
            '所有新项目都应使用async/await语法。',
          ),
          const TipBox(
            '在Python 3.10+中，async/await已经成为异步编程的标准语法。如果你维护旧代码，'
            '建议尽快从yield from迁移到await。',
            type: TipType.tip,
          ),

          // --- 1.2 async def and await ---
          const SectionHeader('1.2 async def 和 await 关键字', icon: Icons.keyboard),
          const Paragraph(
            'async def 用于定义一个协程函数。当你调用一个async def函数时，它不会立即执行，'
            '而是返回一个协程对象(Coroutine Object)。这个协程对象需要在事件循环中运行才能执行。'
            'await 关键字用于挂起当前协程，等待另一个可等待对象(Awaitable)完成后继续执行。',
          ),
          const Paragraph(
            'await 只能出现在 async def 函数内部。await 后面可以跟三种类型的对象：'
            '协程(Coroutine)、任务(Task)或未来对象(Future)。这些统称为可等待对象(Awaitable)。',
          ),
          const CodeBlock(
            r'''import asyncio
import time

async def say_after(delay, message):
    """在指定延时后打印消息"""
    await asyncio.sleep(delay)
    print(message)
    return message

async def main():
    print(f"开始时间: {time.strftime('%X')}")

    # await 一个协程——顺序执行
    await say_after(1, "Hello")
    await say_after(2, "World")

    print(f"结束时间: {time.strftime('%X')}")
    # 总耗时: 约3秒 (1+2)

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '上面的例子中，两个say_after是顺序执行的，总共耗时约3秒。如果我们希望'
            '并发执行它们，需要使用asyncio.create_task将协程包装成任务。',
          ),
          const OutputBox(
            r'''开始时间: 10:00:00
Hello
World
结束时间: 10:00:03''',
          ),
          const Paragraph(
            'await关键字会阻塞当前协程，但不会阻塞整个事件循环。在await期间，'
            '事件循环可以调度其他就绪的协程执行。这就像你去咖啡店点咖啡——你在等待时'
            '可以让其他人点单，但你自己不能再做其他事。而create_task则像是你点了咖啡后'
            '拿到一个呼叫器，可以先去忙别的，等咖啡好了再来取。',
          ),
          const TipBox(
            '牢记：await 挂起当前协程，但不会挂起事件循环。这是异步编程的核心。',
            type: TipType.tip,
          ),

          // --- 1.3 Coroutine vs Task vs Future ---
          const SectionHeader('1.3 Coroutine vs Task vs Future', icon: Icons.compare_arrows),
          const Paragraph(
            '理解Coroutine、Task和Future三者之间的区别是掌握asyncio的关键。它们都是可等待对象，'
            '但用途和行为有所不同。',
          ),
          const Paragraph(
            'Coroutine(协程对象)：调用async def函数时返回的对象。它表示一个尚未开始执行的'
            '异步操作。协程对象必须被调度到事件循环中执行，或者通过await来驱动。',
          ),
          const Paragraph(
            'Task(任务对象)：是Future的子类，它将一个协程包装起来，并自动调度它在事件循环中执行。'
            '一旦创建，任务会立即开始执行(在当前事件循环的下一个迭代中)。你可以通过await task'
            '等待任务完成并获取结果。',
          ),
          const Paragraph(
            'Future(未来对象)：代表一个异步操作的最终结果。它是一个更低层的抽象，表示"将来某个时刻'
            '会有一个值"。当你await一个Future时，你实际上是在等待这个值被设置。Task是Future'
            '的一种具体实现。',
          ),
          const CodeBlock(
            r'''import asyncio

async def my_coro():
    """协程函数"""
    await asyncio.sleep(1)
    return "结果"

async def demonstrate():
    # 1. Coroutine 对象
    coro = my_coro()           # 调用函数返回协程对象
    print(f"Coroutine: {coro}")  # <coroutine object my_coro at 0x...>
    print(f"Type: {type(coro)}") # <class 'coroutine'>

    # 2. Task 对象
    task = asyncio.create_task(my_coro())
    print(f"Task: {task}")       # <Task pending name='Task-2' ...>
    print(f"Type: {type(task)}") # <class '_asyncio.Task'>
    result = await task          # 等待任务完成
    print(f"Task result: {result}")

    # 3. Future 对象 (手动创建)
    future = asyncio.get_event_loop().create_future()
    print(f"Future: {future}")   # <Future pending>
    # 通常在底层库中使用，一般不直接操作

    # 4. 三者都是 awaitable
    import inspect
    print(f"isawaitable(coro): {inspect.isawaitable(coro)}")
    print(f"isawaitable(task): {inspect.isawaitable(task)}")

asyncio.run(demonstrate())''',
            language: 'Python',
          ),
          const Paragraph(
            '这三者的关系可以这样理解：Coroutine是"菜谱"，描述如何做一道菜；'
            '当你把菜谱交给厨师(事件循环)，厨师就开始按步骤做菜，这就是Task；'
            'Future则是"取餐号码"，当菜做好后凭号码取餐(获取结果)。',
          ),
          const OutputBox(
            r'''Coroutine: <coroutine object my_coro at 0x000001F5A3C2C7C0>
Type: <class 'coroutine'>
Task: <Task pending name='Task-2' coro=<my_coro() running ...>>
Type: <class '_asyncio.Task'>
Task result: 结果
Future: <Future pending>
isawaitable(coro): True
isawaitable(task): True''',
          ),
          const TipBox(
            '直接await一个协程和在Task中包装后await的区别在于：直接await是同步等待(顺序执行)，'
            '而Task会在创建时就开始调度执行(并发执行)。',
            type: TipType.caution,
          ),

          // --- 1.4 Creating and running coroutines ---
          const SectionHeader('1.4 创建和运行协程', icon: Icons.play_arrow),
          const Paragraph(
            '运行协程有多种方式，从高层API到底层API都有对应的选择。Python 3.7+推荐使用'
            'asyncio.run()作为入口点，这是最简单也最安全的方式。',
          ),
          const Paragraph(
            'asyncio.run()会自动创建事件循环、运行协程，并在结束后关闭事件循环。'
            '它还会清理所有未完成的任务，避免资源泄漏。注意：在同一个线程中，asyncio.run()'
            '不能被嵌套调用(即不能在运行中的事件循环内再次调用它)。',
          ),
          const CodeBlock(
            r'''import asyncio

# 基本用法：asyncio.run()
async def main():
    print("Hello")
    await asyncio.sleep(1)
    print("World")

asyncio.run(main())

# 获取返回值
async def fetch_data():
    await asyncio.sleep(1)
    return {"data": [1, 2, 3]}

result = asyncio.run(fetch_data())
print(result)  # {'data': [1, 2, 3]}

# 在Jupyter/交互式环境中的用法
# await main()  # 直接在IPython/Jupyter中使用

# 更低层的用法(不推荐在新代码中使用)
# loop = asyncio.new_event_loop()
# try:
#     loop.run_until_complete(main())
# finally:
#     loop.close()''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio.run() 是大多数应用的标准入口点。它会处理事件循环的创建和清理，'
            '确保资源正确释放。对于库代码，更推荐使用asyncio.create_task()来创建任务，'
            '让调用者负责运行事件循环。',
          ),
          const TipBox(
            '在Jupyter Notebook或IPython中，事件循环已经运行，可以直接使用await语法，'
            '不需要调用asyncio.run()。如果在这些环境中调用asyncio.run()会导致错误。',
            type: TipType.warning,
          ),
          const Paragraph(
            '除了asyncio.run()，还有几种运行协程的方式：',
          ),
          const CodeBlock(
            r'''import asyncio

async def task_a():
    print("Task A starting")
    await asyncio.sleep(2)
    print("Task A done")
    return "A"

async def task_b():
    print("Task B starting")
    await asyncio.sleep(1)
    print("Task B done")
    return "B"

async def main():
    # 方式1: 顺序执行 (total: ~3s)
    await task_a()
    await task_b()

    # 方式2: 使用create_task并发执行 (total: ~2s)
    task1 = asyncio.create_task(task_a())
    task2 = asyncio.create_task(task_b())
    result1 = await task1
    result2 = await task2
    print(f"Results: {result1}, {result2}")

    # 方式3: 使用gather并发执行
    results = await asyncio.gather(task_a(), task_b())
    print(f"Gather results: {results}")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '在方式2中，create_task将协程包装成任务并立即开始调度执行，'
            '然后通过await等待任务完成。这样task_a和task_b就是并发执行的，'
            '总耗时由最慢的任务决定(2秒)，而不是两个任务的时间之和(3秒)。',
          ),
          const OutputBox(
            r'''Task A starting
Task B starting
Task B done
Task A done
Results: A, B
Gather results: ['A', 'B']''',
          ),
          const DividerLine(),

          // =================================================================
          // Part 2: asyncio 库
          // =================================================================
          const SectionHeader('2. asyncio 库', icon: Icons.repeat),

          // --- 2.1 Event Loop ---
          const SectionHeader('2.1 事件循环 (Event Loop)', icon: Icons.loop),
          const Paragraph(
            '事件循环是asyncio的核心调度器。它维护着一个任务队列，不断地检查哪些任务已经就绪'
            '(比如socket数据到达、定时器到期)，然后执行这些任务。可以将事件循环理解为一个'
            '高效的"交通指挥员"，它决定下一个该执行哪个协程。',
          ),
          const Paragraph(
            '在Python 3.10+中，事件循环的实现经历了几次变迁。当前推荐的方式是使用'
            'asyncio.run()，它会自动创建并使用最优的事件循环实现。在Unix系统上默认'
            '使用SelectorEventLoop，在Windows上默认使用ProactorEventLoop。',
          ),
          const CodeBlock(
            r'''import asyncio
import sys

async def demo_event_loop():
    # 获取当前运行的事件循环
    loop = asyncio.get_running_loop()
    print(f"事件循环类型: {type(loop).__name__}")
    print(f"是否在运行: {loop.is_running()}")

    # 获取事件循环的策略
    policy = asyncio.get_event_loop_policy()
    print(f"事件循环策略: {type(policy).__name__}")

    # 在Windows上设置ProactorEventLoop (Python 3.8+默认)
    if sys.platform == 'win32':
        print("运行在Windows平台")
        # asyncio.set_event_loop_policy(
        #     asyncio.WindowsProactorEventLoopPolicy()
        # )

async def timer_demo():
    """使用事件循环的定时器功能"""
    loop = asyncio.get_running_loop()

    # 记录开始时间
    start = loop.time()

    await asyncio.sleep(1)

    elapsed = loop.time() - start
    print(f"经过时间: {elapsed:.2f}秒")

    # loop.call_later 和 loop.call_at
    # 在事件循环的下一次迭代中执行回调
    def callback(msg):
        print(f"回调: {msg}")

    loop.call_later(0.5, callback, "0.5秒后执行")
    loop.call_later(1.0, callback, "1.0秒后执行")

    await asyncio.sleep(1.5)

async def main():
    await demo_event_loop()
    await timer_demo()

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '事件循环提供了一系列高级功能：定时器(call_later, call_at)、'
            '文件描述符监控(add_reader, add_writer)、信号处理等。但在日常开发中，'
            '我们很少直接操作事件循环，而是通过asyncio的高级API(如create_task, gather, wait等)来使用它。',
          ),
          const TipBox(
            '在Python 3.10+中，不推荐使用 asyncio.get_event_loop() (无参数版本) 来获取事件循环，'
            '推荐使用 asyncio.get_running_loop() 来获取当前正在运行的事件循环。',
            type: TipType.caution,
          ),

          // --- 2.2 Creating Tasks ---
          const SectionHeader('2.2 创建任务', icon: Icons.add_task),
          const Paragraph(
            'asyncio提供了多种创建和管理任务的方式。最常用的是asyncio.create_task()、'
            'asyncio.gather()和asyncio.wait()。每个函数都有其特定的使用场景。',
          ),

          // asyncio.create_task
          const Paragraph(
            'asyncio.create_task()：将一个协程包装成Task对象并立即调度执行。'
            '这是最基本的任务创建方式。任务创建后会在事件循环的下一个迭代中开始执行，'
            '不需要显式await来启动(但需要await来获取结果)。',
          ),
          const CodeBlock(
            r'''import asyncio

async def worker(name, delay):
    """模拟一个耗时操作"""
    for i in range(3):
        print(f"Worker {name}: step {i}")
        await asyncio.sleep(delay)
    return f"Worker {name} done"

async def main():
    # 创建多个任务并发执行
    tasks = [
        asyncio.create_task(worker("A", 0.5)),
        asyncio.create_task(worker("B", 0.3)),
        asyncio.create_task(worker("C", 0.7)),
    ]

    # 逐个等待
    for task in tasks:
        result = await task
        print(result)

    # 或者使用 asyncio.gather 同时等待
    # results = await asyncio.gather(*tasks)

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio.gather()：并发运行多个可等待对象，返回所有结果的列表。'
            '如果任何一个可等待对象抛出异常，gather会将异常传播给调用者'
            '(除非设置了return_exceptions=True)。',
          ),
          const CodeBlock(
            r'''import asyncio

async def fetch_url(url, delay):
    """模拟网络请求"""
    print(f"开始请求: {url}")
    await asyncio.sleep(delay)
    if "error" in url:
        raise ValueError(f"请求失败: {url}")
    return f"响应数据 from {url}"

async def main():
    urls = [
        ("https://api.example.com/users", 1.0),
        ("https://api.example.com/posts", 1.5),
        ("https://api.example.com/error-test", 0.5),  # 这个会失败
    ]

    # 方式1: 默认行为——第一个异常会中断所有
    try:
        results = await asyncio.gather(
            *(fetch_url(url, delay) for url, delay in urls)
        )
        print(f"成功: {results}")
    except ValueError as e:
        print(f"捕获异常: {e}")

    print("--- 分割线 ---")

    # 方式2: return_exceptions=True——异常作为结果返回
    results = await asyncio.gather(
        *(fetch_url(url, delay) for url, delay in urls),
        return_exceptions=True,
    )
    for i, result in enumerate(results):
        if isinstance(result, Exception):
            print(f"任务{i}失败: {result}")
        else:
            print(f"任务{i}成功: {result}")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio.wait()：等待一组可等待对象完成。与gather返回结果列表不同，'
            'wait返回两个集合：done(已完成的任务)和pending(未完成的任务)。'
            '它还支持不同的等待策略：FIRST_COMPLETED, FIRST_EXCEPTION, ALL_COMPLETED。',
          ),
          const CodeBlock(
            r'''import asyncio
from asyncio import FIRST_COMPLETED, ALL_COMPLETED

async def slow_op():
    await asyncio.sleep(3)
    return "慢操作完成"

async def fast_op():
    await asyncio.sleep(1)
    return "快操作完成"

async def main():
    task_slow = asyncio.create_task(slow_op())
    task_fast = asyncio.create_task(fast_op())

    # 等待第一个完成
    done, pending = await asyncio.wait(
        {task_slow, task_fast},
        return_when=FIRST_COMPLETED,
    )
    print(f"已完成: {len(done)} 个任务")
    for task in done:
        print(f"结果: {task.result()}")
    print(f"待处理: {len(pending)} 个任务")

    # 等待剩余任务
    if pending:
        done2, _ = await asyncio.wait(pending, return_when=ALL_COMPLETED)
        for task in done2:
            print(f"剩余结果: {task.result()}")

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''已完成: 1 个任务
结果: 快操作完成
待处理: 1 个任务
剩余结果: 慢操作完成''',
          ),
          const TipBox(
            'gather vs wait: gather更适合"等所有任务完成并收集结果"的场景，'
            'wait更适合需要精细控制(如超时、取消、等第一个完成)的场景。',
            type: TipType.tip,
          ),
          const Paragraph(
            '除了wait，asyncio还提供了asyncio.as_completed()函数。它返回一个迭代器，'
            '每当一个任务完成时就产生结果，类似于concurrent.futures.as_completed。',
          ),
          const CodeBlock(
            r'''import asyncio

async def main():
    tasks = [
        asyncio.create_task(asyncio.sleep(delay, f"Task {i}"))
        for i, delay in enumerate([2, 1, 3, 0.5])
    ]

    # as_completed 按完成顺序返回结果
    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"完成的: {result}")

    # 输出顺序: Task 3(0.5s), Task 1(1s), Task 0(2s), Task 2(3s)

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''完成的: Task 3
完成的: Task 1
完成的: Task 0
完成的: Task 2''',
          ),

          // --- 2.3 Running in Executor ---
          const SectionHeader('2.3 在Executor中运行阻塞代码', icon: Icons.computer),
          const Paragraph(
            '事件循环是单线程的，如果在协程中执行CPU密集型或阻塞IO操作(如文件读写、'
            '数据库查询、requests库调用)，会阻塞整个事件循环，导致所有并发任务都卡住。'
            '为了解决这个问题，asyncio提供了run_in_executor方法，将阻塞代码放到线程池或进程池中运行。',
          ),
          const CodeBlock(
            r'''import asyncio
import time
from concurrent.futures import ThreadPoolExecutor
import requests

async def async_task(name):
    """正常的异步任务"""
    print(f"异步任务 {name} 开始")
    await asyncio.sleep(1)
    print(f"异步任务 {name} 完成")
    return f"Async {name}"

def blocking_io(url):
    """阻塞的IO操作(使用同步requests库)"""
    print(f"[Blocking] 开始请求: {url}")
    response = requests.get(url, timeout=5)
    print(f"[Blocking] 完成请求: {url}")
    return response.status_code

async def main():
    loop = asyncio.get_running_loop()

    # 方式1: 使用默认的ThreadPoolExecutor
    # run_in_executor(None, func, *args) 使用默认执行器
    print("方式1: 使用默认执行器")
    result = await loop.run_in_executor(
        None,  # None 表示使用默认的 ThreadPoolExecutor
        blocking_io,
        "https://httpbin.org/delay/2",  # 会延迟2秒的测试端点
    )
    print(f"结果: {result}")

    print("--- 分割线 ---")

    # 方式2: 使用自定义ThreadPoolExecutor
    print("方式2: 使用自定义执行器")
    with ThreadPoolExecutor(max_workers=4) as pool:
        urls = [
            "https://httpbin.org/delay/1",
            "https://httpbin.org/delay/2",
            "https://httpbin.org/delay/1",
        ]
        tasks = [
            loop.run_in_executor(pool, blocking_io, url)
            for url in urls
        ]
        results = await asyncio.gather(*tasks)
        print(f"所有结果: {results}")

    # 同时运行异步任务和阻塞任务
    print("--- 分割线 ---")
    print("混合模式: 异步任务 + 阻塞任务并发")
    async_tasks = [
        asyncio.create_task(async_task(f"A{i}"))
        for i in range(3)
    ]
    blocking_tasks = [
        loop.run_in_executor(None, blocking_io, f"https://httpbin.org/delay/{d}")
        for d in [1, 0.5, 1.5]
    ]
    all_results = await asyncio.gather(*(async_tasks + blocking_tasks))
    print(f"所有结果: {all_results}")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'run_in_executor的工作原理：它将同步函数提交到线程池(或进程池)中执行，'
            '并返回一个asyncio.Future对象。当线程池中的函数执行完毕后，Future会被标记为完成，'
            'await future就能获取到结果。这样，阻塞操作就不会阻塞事件循环了。',
          ),
          const TipBox(
            '对于CPU密集型任务，应该使用ProcessPoolExecutor而不是ThreadPoolExecutor，'
            '因为Python的GIL会限制多线程在CPU密集型任务上的性能。使用进程池可以绕过GIL的限制。',
            type: TipType.warning,
          ),
          const TipBox(
            '注意：在使用run_in_executor时传入的函数不应该修改共享状态，除非你使用了线程安全的数据结构。'
            '如果需要修改共享状态，考虑使用asyncio.Lock来保护临界区。',
            type: TipType.caution,
          ),

          // --- 2.4 Synchronization ---
          const SectionHeader('2.4 同步原语', icon: Icons.sync_lock),
          const Paragraph(
            '虽然协程是并发执行的，但在某些场景下我们需要控制对共享资源的访问。'
            'asyncio提供了多种同步原语，其中包括Lock、Semaphore、Event、Condition和Queue。'
            '这些同步原语的用法与threading模块中的对应类型非常相似，但是它们是异步的，'
            '不会阻塞事件循环。',
          ),

          const Paragraph(
            'asyncio.Lock：互斥锁，确保同一时刻只有一个协程访问共享资源。'
            '使用async with语句来获取和释放锁，避免手动管理锁的生命周期。',
          ),
          const CodeBlock(
            r'''import asyncio

# 模拟共享计数器
counter = 0
lock = asyncio.Lock()

async def increment(name, times):
    global counter
    for _ in range(times):
        # 使用 async with 自动管理锁
        async with lock:
            # 临界区开始
            current = counter
            await asyncio.sleep(0.01)  # 模拟一些处理
            counter = current + 1
            # 临界区结束
        # 锁在这�自动释放
    print(f"{name} 完成, 当前counter={counter}")

async def main():
    tasks = [
        asyncio.create_task(increment("A", 10)),
        asyncio.create_task(increment("B", 10)),
        asyncio.create_task(increment("C", 10)),
    ]
    await asyncio.gather(*tasks)
    print(f"最终counter值: {counter}")
    # 如果没有锁，最终值可能小于30（竞态条件）

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''A 完成, 当前counter=28
B 完成, 当前counter=29
C 完成, 当前counter=30
最终counter值: 30''',
          ),

          const Paragraph(
            'asyncio.Semaphore：信号量，限制同时访问某资源的协程数量。'
            '例如，限制同时进行的网络请求数量，避免对服务器造成过大压力。',
          ),
          const CodeBlock(
            r'''import asyncio

# 限制同时只能有3个协程访问
semaphore = asyncio.Semaphore(3)

async def limited_request(request_id):
    """模拟一个受限制的网络请求"""
    async with semaphore:
        print(f"请求 {request_id} 开始 (同时进行中)")
        await asyncio.sleep(1)  # 模拟网络延迟
        print(f"请求 {request_id} 完成")
        return f"Response {request_id}"

async def main():
    # 创建10个任务，但同时只能有3个执行
    tasks = [
        asyncio.create_task(limited_request(i))
        for i in range(10)
    ]
    results = await asyncio.gather(*tasks)
    print(f"完成 {len(results)} 个请求")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio.Queue：异步队列，用于在生产者和消费者之间传递数据。'
            '它是线程安全的，并且支持协程的await操作。Queue的put和get方法都是异步的，'
            '当队列满时put会等待，队列空时get会等待。',
          ),
          const CodeBlock(
            r'''import asyncio
import random

async def producer(queue, id, count):
    """生产者协程"""
    for i in range(count):
        item = f"P{id}-Item{i}"
        await queue.put(item)
        print(f"生产者{id} 生产: {item}")
        await asyncio.sleep(random.uniform(0.1, 0.5))
    # 发送结束信号
    await queue.put(None)

async def consumer(queue, id):
    """消费者协程"""
    while True:
        item = await queue.get()
        if item is None:  # 收到结束信号
            queue.task_done()
            # 放回结束信号，让其他消费者也能收到
            await queue.put(None)
            break
        print(f"消费者{id} 消费: {item}")
        await asyncio.sleep(random.uniform(0.2, 0.8))
        queue.task_done()

async def main():
    queue = asyncio.Queue(maxsize=5)

    # 创建生产者和消费者
    producers = [
        asyncio.create_task(producer(queue, 1, 5)),
        asyncio.create_task(producer(queue, 2, 5)),
    ]
    consumers = [
        asyncio.create_task(consumer(queue, 1)),
        asyncio.create_task(consumer(queue, 2)),
    ]

    # 等待所有生产者完成
    await asyncio.gather(*producers)

    # 等待队列中的所有项目被处理
    await queue.join()

    # 取消消费者
    for c in consumers:
        c.cancel()

    print("所有任务完成")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio还提供了Event(事件通知)和Condition(条件变量)等同步原语。'
            'Event用于简单的广播通知：一个协程设置事件，其他等待该事件的协程被唤醒。'
            'Condition则更复杂，允许在特定条件下等待和通知。',
          ),
          const CodeBlock(
            r'''import asyncio

async def waiter(event, name):
    """等待事件被设置"""
    print(f"{name} 正在等待事件...")
    await event.wait()  # 等待事件被设置
    print(f"{name} 收到事件通知!")

async def setter(event):
    """设置事件"""
    print("设置器: 将在3秒后设置事件")
    await asyncio.sleep(3)
    event.set()
    print("设置器: 事件已设置")

async def main():
    event = asyncio.Event()

    # 多个等待者和一个设置器
    waiters = [
        asyncio.create_task(waiter(event, f"等待者{i}"))
        for i in range(3)
    ]
    setter_task = asyncio.create_task(setter(event))

    await asyncio.gather(*waiters, setter_task)

asyncio.run(main())''',
            language: 'Python',
          ),
          const TipBox(
            'asyncio.Queue是实现生产者-消费者模式的最佳选择。与threading.Queue不同，'
            'asyncio.Queue的put()和get()方法都是异步的，不会阻塞事件循环。',
            type: TipType.tip,
          ),

          // --- 2.5 Timeouts ---
          const SectionHeader('2.5 超时处理', icon: Icons.timer),
          const Paragraph(
            '在网络编程中，超时处理是非常重要的。如果一个网络请求迟迟没有响应，'
            '我们不希望程序无限期地等待下去。asyncio提供了多种超时处理机制。',
          ),
          const Paragraph(
            'asyncio.wait_for()：等待一个可等待对象完成，如果在指定时间内没有完成，'
            '则抛出asyncio.TimeoutError异常。这是最常用的超时处理方式。',
          ),
          const CodeBlock(
            r'''import asyncio

async def slow_operation(delay):
    """一个耗时的操作"""
    print(f"开始操作，预计耗时{delay}秒")
    await asyncio.sleep(delay)
    return f"操作完成，耗时{delay}秒"

async def main():
    # 例1: 操作在规定时间内完成
    try:
        result = await asyncio.wait_for(
            slow_operation(2),
            timeout=5,
        )
        print(f"成功: {result}")
    except asyncio.TimeoutError:
        print("操作超时!")

    print("--- 分割线 ---")

    # 例2: 操作超时
    try:
        result = await asyncio.wait_for(
            slow_operation(5),
            timeout=2,
        )
        print(f"成功: {result}")
    except asyncio.TimeoutError:
        print("操作超时! (超过2秒)")

    print("--- 分割线 ---")

    # 例3: 超时后取消任务
    task = asyncio.create_task(slow_operation(10))
    try:
        result = await asyncio.wait_for(task, timeout=3)
        print(f"成功: {result}")
    except asyncio.TimeoutError:
        print("操作超时，任务将被取消")
        # 检查任务是否已被取消
        print(f"任务已取消: {task.cancelled()}")

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''开始操作，预计耗时2秒
成功: 操作完成，耗时2秒
--- 分割线 ---
开始操作，预计耗时5秒
操作超时! (超过2秒)
--- 分割线 ---
开始操作，预计耗时10秒
操作超时，任务将被取消
任务已取消: True''',
          ),

          const Paragraph(
            'Python 3.11+ 引入了 asyncio.timeout() 异步上下文管理器，提供了更优雅的超时处理方式。'
            '当超出超时时间时，asyncio.CanceledError 会被触发。',
          ),
          const CodeBlock(
            r'''import asyncio

async def main():
    # Python 3.11+ 语法: 使用 asyncio.timeout 上下文管理器
    try:
        async with asyncio.timeout(3):
            print("开始操作...")
            await asyncio.sleep(5)  # 假设是网络请求
            print("操作完成")
    except TimeoutError:
        print("操作超时! (3秒限制)")

    # 也可以使用 asyncio.timeout_at 设置绝对时间
    try:
        deadline = asyncio.get_running_loop().time() + 2
        async with asyncio.timeout_at(deadline):
            print("开始另一个操作...")
            await asyncio.sleep(4)
            print("操作完成")
    except TimeoutError:
        print("另一个操作也超时了")

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'asyncio.shield()：保护任务不被取消。在某些场景下，即使外部超时了，'
            '我们仍然希望某些关键操作能继续执行到完成。shield可以为任务创建一个"防护罩"，'
            '防止取消操作传播到原始任务。',
          ),
          const CodeBlock(
            r'''import asyncio

async def critical_operation():
    """一个关键的、不能中断的操作"""
    print("关键操作: 开始执行...")
    try:
        await asyncio.sleep(3)
        print("关键操作: 完成!")
        return "关键数据"
    except asyncio.CancelledError:
        print("关键操作: 被取消!")
        raise

async def main():
    # 使用 shield 保护关键操作
    task = asyncio.create_task(critical_operation())

    try:
        result = await asyncio.wait_for(
            asyncio.shield(task),
            timeout=1,  # 超时设置为1秒
        )
        print(f"结果: {result}")
    except TimeoutError:
        print("main: 操作超时")
        # 虽然wait_for超时了，但关键操作仍在继续
        print("main: 等待被保护的任务完成...")
        actual_result = await task  # 重新等待
        print(f"main: 最终获取到: {actual_result}")
    except asyncio.CancelledError:
        print("main: 任务被取消")

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''关键操作: 开始执行...
main: 操作超时
main: 等待被保护的任务完成...
关键操作: 完成!
main: 最终获取到: 关键数据''',
          ),
          const TipBox(
            'asyncio.shield() 适用于"即使调用者超时了，某些关键操作(如写入数据库、发送确认邮件)'
            '也必须完成"的场景。但要注意，shield会延迟取消，而不是完全阻止取消。',
            type: TipType.caution,
          ),

          // --- 2.6 Subprocess ---
          const SectionHeader('2.6 异步子进程', icon: Icons.terminal),
          const Paragraph(
            'asyncio支持异步创建和管理子进程，你可以启动外部程序并异步读取其输出。'
            'asyncio.create_subprocess_exec() 和 asyncio.create_subprocess_shell() '
            '是两个主要的API，类似于subprocess模块的Popen类。',
          ),
          const CodeBlock(
            r'''import asyncio

async def run_cmd(cmd, *args):
    """异步执行外部命令并返回输出"""
    print(f"执行命令: {cmd} {' '.join(args)}")

    # 创建子进程
    process = await asyncio.create_subprocess_exec(
        cmd, *args,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    # 异步读取输出
    stdout, stderr = await process.communicate()

    print(f"返回码: {process.returncode}")
    if stdout:
        print(f"标准输出:\n{stdout.decode('utf-8', errors='replace')}")
    if stderr:
        print(f"错误输出:\n{stderr.decode('utf-8', errors='replace')}")

    return process.returncode

async def stream_output():
    """流式读取子进程输出"""
    process = await asyncio.create_subprocess_exec(
        'ping', '-c', '4', '127.0.0.1',
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    # 逐行读取输出 (实时流式)
    print("实时读取ping输出:")
    while True:
        line = await process.stdout.readline()
        if not line:
            break
        print(f"  >> {line.decode('utf-8').strip()}")

    await process.wait()
    print(f"进程退出码: {process.returncode}")

async def main():
    # 执行简单命令
    await run_cmd('echo', 'Hello', 'from', 'asyncio!')

    print("--- 分割线 ---")

    # 查看Python版本
    await run_cmd('python', '--version')

    print("--- 分割线 ---")

    # 流式读取
    await stream_output()

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '使用asyncio.create_subprocess_shell()可以通过shell执行命令(支持管道、重定向等)。'
            '但要注意安全问题，避免shell注入攻击。',
          ),
          const CodeBlock(
            r'''import asyncio

async def shell_example():
    """使用shell执行命令(注意安全!)"""

    # 使用shell执行 (允许管道、通配符等)
    process = await asyncio.create_subprocess_shell(
        'echo "当前目录:" && pwd && ls -la | head -5',
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    stdout, stderr = await process.communicate()
    print(stdout.decode('utf-8'))

    # 危险! 不要直接拼接用户输入!
    # user_input = "'; rm -rf /; echo '"
    # process = await asyncio.create_subprocess_shell(
    #     f"echo {user_input}"  # 危险!
    # )

    # 安全做法: 使用列表形式的exec
    user_input = "safe input"
    process = await asyncio.create_subprocess_exec(
        'echo', user_input,  # 安全，不会解析shell语法
    )

async def main():
    await shell_example()

asyncio.run(main())''',
            language: 'Python',
          ),
          const TipBox(
            '优先使用 create_subprocess_exec() 而不是 create_subprocess_shell()。'
            '前者不接受shell语法，避免了shell注入的风险。只有当确实需要shell功能'
            '(管道、重定向、通配符)时才使用后者。',
            type: TipType.warning,
          ),

          // --- 2.7 Streams ---
          const SectionHeader('2.7 异步流 (Streams)', icon: Icons.stream),
          const Paragraph(
            'asyncio提供了高层级的流API，用于网络通信。asyncio.open_connection()'
            '用于创建TCP客户端连接，asyncio.start_server()用于创建TCP服务端。'
            '这些API基于流(Stream Reader和Stream Writer)的概念，简化了网络编程。',
          ),
          const Paragraph(
            'TCP Echo客户端示例：',
          ),
          const CodeBlock(
            r'''import asyncio

async def tcp_echo_client():
    """TCP Echo客户端"""
    reader, writer = await asyncio.open_connection(
        '127.0.0.1', 8888
    )

    message = 'Hello, World!'
    print(f"发送: {message!r}")

    # 发送数据
    writer.write(message.encode())
    await writer.drain()  # 确保数据被发送

    # 接收响应
    data = await reader.read(100)
    print(f"接收: {data.decode()!r}")

    print("关闭连接")
    writer.close()
    await writer.wait_closed()

# 单独运行客户端时会连接服务器''',
            language: 'Python',
          ),
          const Paragraph(
            'TCP Echo服务端示例：',
          ),
          const CodeBlock(
            r'''import asyncio

async def handle_echo(reader, writer):
    """处理客户端连接的协程"""
    addr = writer.get_extra_info('peername')
    print(f"客户端连接: {addr}")

    while True:
        data = await reader.read(100)
        if not data:
            break

        message = data.decode()
        print(f"接收到: {message!r} from {addr}")

        # 回显
        writer.write(data)
        await writer.drain()

    print(f"客户端断开: {addr}")
    writer.close()
    await writer.wait_closed()

async def main():
    server = await asyncio.start_server(
        handle_echo, '127.0.0.1', 8888
    )

    addr = server.sockets[0].getsockname()
    print(f"服务器启动在: {addr}")

    # 同时处理多个客户端
    async with server:
        await server.serve_forever()

# asyncio.run(main())
# 运行服务器后，可用上方的客户端或telnet连接测试''',
            language: 'Python',
          ),
          const Paragraph(
            'Server的serve_forever()方法会一直运行，直到被取消。也可以使用'
            'server.start_serving()让服务器在后台运行，然后执行其他任务。',
          ),
          const CodeBlock(
            r'''import asyncio

async def main_with_background_server():
    """在后台运行服务器，同时做其他事"""
    async def handle(reader, writer):
        data = await reader.read(100)
        writer.write(b"pong")
        await writer.drain()
        writer.close()

    server = await asyncio.start_server(handle, '127.0.0.1', 0)

    # 在后台启动服务器
    server.start_serving()
    addr = server.sockets[0].getsockname()
    print(f"服务器在后台运行: {addr}")

    # 在此期间可以做其他事情
    for i in range(3):
        print(f"做其他工作... {i}")
        await asyncio.sleep(1)

    # 关闭服务器
    server.close()
    await server.wait_closed()
    print("服务器已关闭")''',
            language: 'Python',
          ),
          const TipBox(
            'asyncio的流API适合构建自定义协议的网络应用。对于HTTP协议，建议使用更高层的库'
            '(如aiohttp)而不是直接使用TCP流。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // =================================================================
          // Part 3: aiohttp
          // =================================================================
          const SectionHeader('3. aiohttp', icon: Icons.http),

          // --- 3.1 Installing ---
          const SectionHeader('3.1 安装 aiohttp', icon: Icons.download),
          const Paragraph(
            'aiohttp是Python最流行的异步HTTP客户端/服务器框架。它基于asyncio构建，'
            '支持HTTP客户端和服务端功能，以及WebSocket协议。安装aiohttp非常简单。',
          ),
          const CodeBlock(
            r'''# 使用 pip 安装 aiohttp
pip install aiohttp

# 如果需要完整的客户端功能(如cookies)
pip install aiohttp[speedups]

# 验证安装
python -c "import aiohttp; print(aiohttp.__version__)"
# 输出: 3.9.x''',
            language: 'Python',
          ),
          const Paragraph(
            'aiohttp依赖于multidict、yarl、async_timeout等库。安装speedups'
            '可选依赖后，可以获得更好的性能(包括cchardet、aiodns等优化)。',
          ),
          const TipBox(
            '在安装aiohttp前，确保你使用的是Python 3.8+版本。aiohttp 3.9+已停止支持Python 3.7。'
            '建议使用Python 3.11+以获得最佳性能。',
            type: TipType.info,
          ),

          // --- 3.2 ClientSession ---
          const SectionHeader('3.2 aiohttp.ClientSession', icon: Icons.link),
          const Paragraph(
            'aiohttp.ClientSession是aiohttp客户端核心类。它管理连接池(cookie、头部等)，'
            '推荐作为上下文管理器使用。一个应用通常只需要创建一个session实例，'
            '并在整个应用生命周期中重用它。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp

async def basic_get_request():
    """基本的GET请求"""
    # 使用 async with 管理 session
    async with aiohttp.ClientSession() as session:
        async with session.get('https://httpbin.org/get') as response:
            print(f"状态码: {response.status}")
            print(f"Content-Type: {response.headers.get('content-type')}")

            # 读取响应体
            text = await response.text()
            print(f"响应体(文本): {text[:200]}...")

            # 或者读取为JSON
            # json_data = await response.json()

async def main():
    await basic_get_request()

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            'ClientSession支持很多配置选项，包括自定义headers、超时设置、'
            'cookie存储、连接池大小等。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp

async def configured_session():
    """配置ClientSession"""
    # 自定义headers
    headers = {
        'User-Agent': 'MyAsyncBot/1.0',
        'Accept': 'application/json',
    }

    # 超时设置
    timeout = aiohttp.ClientTimeout(
        total=30,        # 总超时
        connect=10,      # 连接超时
        sock_read=10,    # socket读取超时
    )

    # CookieJar设置
    jar = aiohttp.CookieJar(unsafe=True)  # unsafe允许跨域cookie

    # 连接限制
    connector = aiohttp.TCPConnector(
        limit=10,          # 同时连接数
        limit_per_host=5,  # 每个主机的最大连接数
        ttl_dns_cache=300, # DNS缓存时间(秒)
        ssl=False,         # 开发时可用，生产环境应该用True
    )

    async with aiohttp.ClientSession(
        headers=headers,
        timeout=timeout,
        cookie_jar=jar,
        connector=connector,
        base_url='https://httpbin.org',  # 基础URL
    ) as session:
        # 使用base_url后，只需提供路径
        async with session.get('/get') as resp:
            print(f"状态: {resp.status}")
            data = await resp.json()
            print(f"Headers: {data['headers']}")

asyncio.run(configured_session())''',
            language: 'Python',
          ),
          const TipBox(
            '强烈推荐为整个应用创建单个ClientSession实例并复用，而不是每次请求都创建新的。'
            '这样可以充分利用连接池，减少连接建立的开销。',
            type: TipType.tip,
          ),

          // --- 3.3 GET and POST ---
          const SectionHeader('3.3 GET 和 POST 请求', icon: Icons.send),
          const Paragraph(
            'aiohttp支持所有常见的HTTP方法：GET、POST、PUT、DELETE、PATCH、HEAD、OPTIONS等。'
            '对于GET请求，可以使用params参数传递URL参数。对于POST请求，可以使用data、json或files参数。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp
import json

async def get_with_params():
    """GET请求带查询参数"""
    params = {
        'key1': 'value1',
        'key2': ['a', 'b', 'c'],  # 会自动编码为 key2=a&key2=b&key2=c
    }

    async with aiohttp.ClientSession() as session:
        async with session.get(
            'https://httpbin.org/get',
            params=params,
        ) as resp:
            data = await resp.json()
            print(f"URL: {data['url']}")
            print(f"Params: {data['args']}")

async def post_form_data():
    """POST表单数据"""
    form_data = aiohttp.FormData()
    form_data.add_field('username', 'admin')
    form_data.add_field('password', 'secret123')
    form_data.add_field(
        'avatar',
        open('avatar.jpg', 'rb'),
        filename='avatar.jpg',
        content_type='image/jpeg',
    )

    async with aiohttp.ClientSession() as session:
        async with session.post(
            'https://httpbin.org/post',
            data=form_data,
        ) as resp:
            data = await resp.json()
            print(f"表单数据: {data['form']}")

async def post_json():
    """POST JSON数据"""
    payload = {
        'title': '异步编程教程',
        'content': '这是一篇关于Python异步IO的文章',
        'tags': ['python', 'async', 'tutorial'],
    }

    async with aiohttp.ClientSession() as session:
        # 方式1: 使用json参数(自动设置Content-Type)
        async with session.post(
            'https://httpbin.org/post',
            json=payload,
        ) as resp:
            data = await resp.json()
            print(f"JSON数据: {json.dumps(data['json'], indent=2)}")

        # 方式2: 手动编码(需要设置Content-Type)
        # async with session.post(
        #     'https://httpbin.org/post',
        #     data=json.dumps(payload),
        #     headers={'Content-Type': 'application/json'},
        # ) as resp:
        #     ...

async def custom_headers():
    """自定义Headers"""
    headers = {
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
        'X-Custom-Header': 'custom_value',
        'Accept-Language': 'zh-CN,zh;q=0.9',
    }

    async with aiohttp.ClientSession() as session:
        async with session.get(
            'https://httpbin.org/headers',
            headers=headers,
        ) as resp:
            data = await resp.json()
            print(f"请求头: {json.dumps(data['headers'], indent=2)}")

async def main():
    await get_with_params()
    print("---")
    await post_json()
    print("---")
    await custom_headers()

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''URL: https://httpbin.org/get?key1=value1&key2=a&key2=b&key2=c
Params: {'key1': 'value1', 'key2': ['a', 'b', 'c']}
---
JSON数据: {
  "title": "异步编程教程",
  "content": "这是一篇关于Python异步IO的文章",
  "tags": ["python", "async", "tutorial"]
}
---''',
          ),
          const Paragraph(
            'aiohttp还支持文件上传、流式下载、分块编码等高级功能。'
            '对于大文件下载，建议使用chunked方式逐块读取，而不是一次性加载到内存。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp
import aiofiles  # 异步文件操作库

async def download_file(url, filename):
    """流式下载大文件"""
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as resp:
            # 检查响应状态
            resp.raise_for_status()

            # 获取文件大小
            total_size = int(resp.headers.get('content-length', 0))
            downloaded = 0

            # 流式写入
            async with aiofiles.open(filename, 'wb') as f:
                async for chunk in resp.content.iter_chunked(8192):
                    await f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        progress = downloaded / total_size * 100
                        print(f"下载进度: {progress:.1f}%")

            print(f"文件已保存: {filename} ({downloaded} bytes)")

# 使用示例
# asyncio.run(download_file(
#     'https://example.com/large-file.zip',
#     'large-file.zip'
# ))''',
            language: 'Python',
          ),
          const TipBox(
            '对于大文件下载，一定要使用流式方式(content.iter_chunked或content.iter_bytes)，'
            '而不是await response.read()(会一次性加载到内存)。',
            type: TipType.caution,
          ),

          // --- 3.4 Concurrent requests ---
          const SectionHeader('3.4 并发请求', icon: Icons.rocket_launch),
          const Paragraph(
            'aiohttp的真正威力在于并发请求。使用asyncio.gather()可以同时发送多个HTTP请求，'
            '显著提高数据采集效率。以下是一个比较顺序和并发性能的例子。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp
import time

async def fetch_one(session, url):
    """发送单个请求"""
    try:
        async with session.get(url) as response:
            data = await response.json()
            return {
                'url': url,
                'status': response.status,
                'data': data,
            }
    except Exception as e:
        return {'url': url, 'error': str(e)}

async def sequential_fetch(urls):
    """顺序请求"""
    print("开始顺序请求...")
    async with aiohttp.ClientSession() as session:
        results = []
        for url in urls:
            result = await fetch_one(session, url)
            results.append(result)
        return results

async def concurrent_fetch(urls):
    """并发请求 (使用gather)"""
    print("开始并发请求...")
    async with aiohttp.ClientSession() as session:
        tasks = [
            fetch_one(session, url)
            for url in urls
        ]
        results = await asyncio.gather(*tasks)
        return results

async def concurrent_limited(urls, limit=3):
    """限制并发数的请求"""
    print(f"限制并发({limit})请求...")
    semaphore = asyncio.Semaphore(limit)

    async def limited_fetch(url):
        async with semaphore:
            async with aiohttp.ClientSession() as session:
                return await fetch_one(session, url)

    tasks = [limited_fetch(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return results

async def main():
    # 测试URL列表
    urls = [
        'https://httpbin.org/delay/2',  # 延迟2秒
        'https://httpbin.org/delay/2',
        'https://httpbin.org/delay/2',
        'https://httpbin.org/delay/2',
        'https://httpbin.org/delay/2',
    ] * 2  # 总共10个请求

    # 顺序执行 (预计: 20秒)
    start = time.time()
    results = await sequential_fetch(urls[:2])  # 只测2个以免太久
    seq_time = time.time() - start
    print(f"顺序请求(2个)耗时: {seq_time:.2f}秒")
    print(f"结果数: {len(results)}")

    print("---")

    # 并发执行 (预计: 2秒)
    start = time.time()
    results = await concurrent_fetch(urls[:6])
    con_time = time.time() - start
    print(f"并发请求(6个)耗时: {con_time:.2f}秒")
    print(f"结果数: {len(results)}")

    print("---")

    # 限制并发数 (预计: 4秒, 因为3个一批)
    start = time.time()
    results = await concurrent_limited(urls[:6], limit=3)
    lim_time = time.time() - start
    print(f"限制并发(limit=3, 6个)耗时: {lim_time:.2f}秒")

    if con_time > 0 and seq_time > 0:
        print(f"\n加速比: {seq_time/con_time:.1f}x")

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''开始顺序请求...
顺序请求(2个)耗时: 4.12秒
结果数: 2
---
开始并发请求...
并发请求(6个)耗时: 2.15秒
结果数: 6
---
限制并发(limit=3, 6个)耗时: 4.18秒

加速比: 1.9x''',
          ),
          const TipBox(
            '并发请求时要注意对目标服务器的礼貌。使用Semaphore限制并发数，'
            '避免对服务器造成过大压力(可能导致IP被封禁)。建议并发数控制在5-50之间。',
            type: TipType.warning,
          ),

          // --- 3.5 Timeout and Error Handling ---
          const SectionHeader('3.5 超时和错误处理', icon: Icons.error_outline),
          const Paragraph(
            '网络请求中，异常处理是必不可少的。aiohttp可能抛出多种异常，'
            '包括连接超时、DNS解析失败、HTTP错误状态码等。合理的错误处理'
            '能让程序更健壮。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp
from aiohttp import ClientTimeout, ClientError

async def robust_request(url, timeout_seconds=5):
    """健壮的网络请求函数"""
    # 配置超时
    timeout = ClientTimeout(
        total=timeout_seconds,
        connect=3,      # 连接超时
        sock_read=5,    # 读取超时
    )

    async with aiohttp.ClientSession(timeout=timeout) as session:
        try:
            async with session.get(url) as response:
                # 检查HTTP状态码
                if response.status == 200:
                    return await response.json()
                elif response.status == 404:
                    print(f"404 资源不存在: {url}")
                    return None
                elif response.status == 429:
                    print(f"429 请求过多，需要等待")
                    return None
                elif response.status >= 500:
                    print(f"服务器错误 {response.status}: {url}")
                    return None
                else:
                    # 其他状态码
                    text = await response.text()
                    print(f"意外状态码 {response.status}: {text[:100]}")
                    return None

        except asyncio.TimeoutError:
            print(f"超时错误: {url} (超过{timeout_seconds}秒)")
        except aiohttp.ClientConnectorError as e:
            print(f"连接错误: {url} - {e}")
        except aiohttp.ClientResponseError as e:
            print(f"响应错误: {url} - {e}")
        except aiohttp.ClientError as e:
            print(f"客户端错误: {url} - {e}")
        except Exception as e:
            print(f"未知错误: {url} - {type(e).__name__}: {e}")

    return None

async def retry_request(url, max_retries=3, base_delay=1):
    """带重试机制的网络请求"""
    timeout = ClientTimeout(total=10)

    async with aiohttp.ClientSession(timeout=timeout) as session:
        for attempt in range(1, max_retries + 1):
            try:
                async with session.get(url) as response:
                    if response.status == 200:
                        return await response.json()
                    else:
                        print(f"尝试{attempt}: HTTP {response.status}")

            except (ClientError, asyncio.TimeoutError) as e:
                print(f"尝试{attempt}失败: {type(e).__name__}")

                if attempt < max_retries:
                    # 指数退避
                    wait_time = base_delay * (2 ** (attempt - 1))
                    print(f"等待{wait_time}秒后重试...")
                    await asyncio.sleep(wait_time)

        print(f"所有{max_retries}次重试均失败: {url}")
        return None

async def main():
    # 测试各种错误场景
    test_urls = [
        'https://httpbin.org/delay/6',      # 会超时 (超过5秒)
        'https://httpbin.org/status/404',    # 404
        'https://nonexistent.domain.test',   # DNS错误
        'https://httpbin.org/get',           # 正常
    ]

    for url in test_urls:
        print(f"\n请求: {url}")
        result = await robust_request(url, timeout_seconds=5)
        if result:
            print(f"成功: {type(result).__name__}")

    print("\n" + "="*50)
    print("测试重试机制:")
    await retry_request('https://httpbin.org/status/503', max_retries=3)

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''请求: https://httpbin.org/delay/6
超时错误: https://httpbin.org/delay/6 (超过5秒)

请求: https://httpbin.org/status/404
404 资源不存在: https://httpbin.org/status/404

请求: https://nonexistent.domain.test
连接错误: https://nonexistent.domain.test - ...

请求: https://httpbin.org/get
成功: dict

==================================================
测试重试机制:
尝试1失败: ClientResponseError 或 TimeoutError
等待1秒后重试...
...''',
          ),
          const Paragraph(
            'aiohttp异常继承体系：ClientError是所有客户端异常的基类，'
            '其子类包括ClientConnectorError(连接错误)、ClientResponseError(响应错误)、'
            'ClientOSError(OS错误)等。TimeoutError则继承自asyncio.TimeoutError。',
          ),

          // --- 3.6 WebSocket ---
          const SectionHeader('3.6 WebSocket with aiohttp', icon: Icons.wifi),
          const Paragraph(
            'aiohttp内置了对WebSocket协议的支持。WebSocket提供了全双工通信通道，'
            '适合实时应用(如聊天、实时数据推送、在线游戏等)。aiohttp既可作为WebSocket'
            '客户端连接服务器，也可作为服务器端接受WebSocket连接。',
          ),
          const CodeBlock(
            r'''import asyncio
import aiohttp
import json
import random

async def websocket_client():
    """WebSocket客户端示例"""
    uri = "wss://echo.websocket.org"
    print(f"正在连接: {uri}")

    try:
        async with aiohttp.ClientSession() as session:
            async with session.ws_connect(uri) as ws:
                print("WebSocket连接已建立!")

                # 发送多条消息
                messages = ["Hello!", "How are you?", "Goodbye!"]
                for msg in messages:
                    print(f"发送: {msg}")
                    await ws.send_str(msg)

                    # 接收响应
                    resp = await ws.receive()
                    if resp.type == aiohttp.WSMsgType.TEXT:
                        print(f"接收: {resp.data}")
                    elif resp.type == aiohttp.WSMsgType.CLOSED:
                        print("连接已关闭")
                        break

                # 发送关闭帧
                print("关闭连接")
                await ws.close()

    except aiohttp.ClientError as e:
        print(f"WebSocket错误: {e}")
    except Exception as e:
        print(f"其他错误: {e}")

async def websocket_ping_pong():
    """WebSocket ping/pong 示例"""
    # 使用更稳定的WebSocket测试服务
    uri = "wss://ws.postman-echo.com/raw"

    async with aiohttp.ClientSession() as session:
        async with session.ws_connect(uri) as ws:
            print("连接成功，开始ping-pong测试")

            # 发送并接收多个消息
            for i in range(5):
                msg = json.dumps({
                    "type": "ping",
                    "seq": i,
                    "timestamp": asyncio.get_event_loop().time(),
                })

                await ws.send_str(msg)
                print(f"发送: ping #{i}")

                # 接收响应(带超时)
                try:
                    resp = await asyncio.wait_for(
                        ws.receive(),
                        timeout=5,
                    )
                    if resp.type == aiohttp.WSMsgType.TEXT:
                        data = json.loads(resp.data)
                        print(f"接收: pong #{data.get('seq', '?')}")
                    elif resp.type == aiohttp.WSMsgType.CLOSED:
                        print("服务器关闭了连接")
                        break
                except asyncio.TimeoutError:
                    print("响应超时")

                await asyncio.sleep(0.5)

asyncio.run(websocket_ping_pong())''',
            language: 'Python',
          ),
          const Paragraph(
            'aiohttp在服务端也可以处理WebSocket连接。以下是一个简单的WebSocket聊天服务器示例：',
          ),
          const CodeBlock(
            r'''from aiohttp import web
import asyncio

# 存储所有连接的客户端
connected_clients = set()

async def websocket_handler(request):
    """处理WebSocket连接"""
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    # 新客户端连接
    addr = request.remote
    connected_clients.add(ws)
    print(f"新客户端连接: {addr} (当前在线: {len(connected_clients)})")

    try:
        async for msg in ws:
            if msg.type == aiohttp.WSMsgType.TEXT:
                # 广播消息给所有客户端
                for client in connected_clients:
                    if client != ws and not client.closed:
                        try:
                            await client.send_str(msg.data)
                        except:
                            pass
            elif msg.type == aiohttp.WSMsgType.ERROR:
                print(f"WebSocket错误: {ws.exception()}")

    finally:
        # 客户端断开
        connected_clients.discard(ws)
        print(f"客户端断开: {addr} (当前在线: {len(connected_clients)})")

    return ws

# 启动服务器
# app = web.Application()
# app.router.add_get('/ws', websocket_handler)
# web.run_app(app, host='localhost', port=8080)''',
            language: 'Python',
          ),
          const TipBox(
            'WebSocket连接应该始终包含超时处理。网络不稳定时，receive()可能'
            '长时间阻塞。使用asyncio.wait_for()为receive()设置超时是一个好习惯。',
            type: TipType.caution,
          ),

          // --- 3.7 Comparison with requests ---
          const SectionHeader('3.7 aiohttp vs requests 对比', icon: Icons.compare),
          const Paragraph(
            'requests是Python最流行的同步HTTP库，而aiohttp是异步HTTP库。'
            '二者的设计理念和使用方式有显著差异。下面从多个维度进行对比。',
          ),
          const CodeBlock(
            r'''# ========== requests (同步) ==========
import requests
import time

urls = [
    'https://httpbin.org/delay/1',
    'https://httpbin.org/delay/2',
    'https://httpbin.org/delay/1',
]

start = time.time()
session = requests.Session()

for url in urls:
    response = session.get(url, timeout=5)
    print(f"[Sync] {url}: {response.status_code}")

sync_time = time.time() - start
print(f"同步耗时: {sync_time:.2f}秒")

# ========== aiohttp (异步) ==========
import asyncio
import aiohttp

async def async_fetch():
    start = time.time()
    async with aiohttp.ClientSession() as session:
        tasks = []
        for url in urls:
            async def fetch(url=url):
                async with session.get(url) as resp:
                    print(f"[Async] {url}: {resp.status}")
                    return resp
            tasks.append(fetch())

        await asyncio.gather(*tasks)

    async_time = time.time() - start
    print(f"异步耗时: {async_time:.2f}秒")
    print(f"加速比: {sync_time/async_time:.1f}x")

asyncio.run(async_fetch())''',
            language: 'Python',
          ),
          const Paragraph(
            '主要区别对比：',
          ),
          const CodeBlock(
            r'''# 对比维度表:
#
# | 特性           | requests          | aiohttp              |
# |---------------|-------------------|----------------------|
# | 类型           | 同步阻塞          | 异步非阻塞           |
# | 并发性能       | 低(需要多线程)    | 高(单线程高并发)     |
# | API风格        | 简单直观          | 需要async/await      |
# | 连接池         | 内置(Session)     | 内置(ClientSession)  |
# | 超时处理       | timeout参数       | ClientTimeout        |
# | WebSocket      | 不支持            | 内置支持             |
# | 流式上传/下载  | 支持              | 支持(原生异步)       |
# | 适用场景       | 简单脚本、小项目  | 高并发、实时应用     |
# | 学习曲线       | 低                | 中等                 |
# | 三方依赖       | 少                | 较多                 |

# requests同步版本的多线程并发
import concurrent.futures

def fetch_url(url):
    resp = requests.get(url, timeout=5)
    return resp.status_code

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    futures = [pool.submit(fetch_url, url) for url in urls]
    for future in concurrent.futures.as_completed(futures):
        print(f"完成: {future.result()}")

# 但是多线程存在GIL问题，且线程开销远大于协程''',
            language: 'Python',
          ),
          const Paragraph(
            '何时使用requests：简单的脚本、API调用次数不多(每秒<10次)、'
            '不需要并发处理、项目简单不需要引入额外依赖的场景。',
          ),
          const Paragraph(
            '何时使用aiohttp：需要高并发(每秒100+请求)、需要WebSocket、'
            '项目中已经在使用asyncio、需要流式处理大量数据的场景。',
          ),
          const TipBox(
            '一个常见的模式是：如果项目中没有其他异步代码，使用requests更合适。'
            '如果已经在使用asyncio，那么aiohttp是自然的选择。不要为了"可能更快"'
            '而在同步项目中强行引入aiohttp。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // =================================================================
          // Part 4: Best Practices
          // =================================================================
          const SectionHeader('4. 最佳实践', icon: Icons.auto_awesome),

          // --- 4.1 When to use async ---
          const SectionHeader('4.1 何时使用 async/threading/multiprocessing', icon: Icons.account_tree),
          const Paragraph(
            'Python中实现并发的三种主要方式：异步(asyncio)、多线程(threading)和多进程(multiprocessing)。'
            '它们各有适用场景，选择正确的工具非常重要。',
          ),
          const CodeBlock(
            r'''# ========== 三种并发方式对比 ==========

# 1. asyncio - 异步IO (协程)
# 适用: 网络IO密集型, 大量并发连接
# 特点: 单线程, 协作式调度, 极小开销
async def async_network_task():
    async with aiohttp.ClientSession() as session:
        async with session.get('http://example.com') as resp:
            return await resp.text()

# 2. threading - 多线程
# 适用: IO密集型, 阻塞式IO调用(如文件读写)
# 特点: 有GIL限制, 适合IO操作, 有线程安全问题
import threading
def io_bound_task():
    with open('large_file.txt', 'r') as f:
        return f.read()

thread = threading.Thread(target=io_bound_task)
thread.start()
thread.join()

# 3. multiprocessing - 多进程
# 适用: CPU密集型计算
# 特点: 无GIL限制, 独立内存空间, 通信开销大
from multiprocessing import Process, Pool
def cpu_bound_task(n):
    total = 0
    for i in range(n):
        total += i ** i
    return total

with Pool(4) as pool:
    results = pool.map(cpu_bound_task, [1000, 2000, 3000])''',
            language: 'Python',
          ),
          const Paragraph(
            '选择指南：',
          ),
          const CodeBlock(
            r'''# 选择决策树:
#
# 任务类型是?
# ├── CPU密集型 (计算)
# │   └── 需要并行? → multiprocessing
# │   └── 单核够用? → threading 可能也行
# │
# ├── IO密集型 (网络请求/数据库/文件)
# │   ├── 大量并发连接 (>100)? → asyncio
# │   ├── 同步库无法替换? → threading + run_in_executor
# │   └── 少量连接? → 简单同步代码就够了
# │
# └── 混合型 (计算+IO)
#     └── asyncio + run_in_executor (最佳组合)
#
# 性能参考 (10000个网络请求):
# - 同步顺序: ~10000秒 (无法接受)
# - 多线程(100线程): ~100秒
# - asyncio: ~2秒

# 实际决策示例:
import asyncio

async def web_scraper_best_practice():
    """
    网页爬虫最佳实践:
    - 使用asyncio处理网络请求 (1000+ URLs)
    - 使用run_in_executor处理解析 (CPU密集型)
    """
    loop = asyncio.get_running_loop()

    async with aiohttp.ClientSession() as session:
        # 异步网络请求
        async def fetch(url):
            async with session.get(url) as resp:
                return await resp.text()

        # 同步解析(在executor中运行)
        def parse_html(html):
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(html, 'html.parser')
            return soup.title.string if soup.title else ""

        # 获取10个页面
        urls = [f'https://example.com/page/{i}' for i in range(10)]
        htmls = await asyncio.gather(*[fetch(url) for url in urls])

        # 并行解析
        tasks = [
            loop.run_in_executor(None, parse_html, html)
            for html in htmls
        ]
        titles = await asyncio.gather(*tasks)
        return titles''',
            language: 'Python',
          ),
          const TipBox(
            '记住黄金法则：IO密集型任务用asyncio，CPU密集型任务用multiprocessing。'
            '混合型任务使用asyncio+run_in_executor(ThreadPoolExecutor)组合。',
            type: TipType.tip,
          ),

          // --- 4.2 Common pitfalls ---
          const SectionHeader('4.2 常见陷阱', icon: Icons.warning_amber),
          const Paragraph(
            '异步编程有许多容易忽视的陷阱。即使是经验丰富的开发者，也可能会犯这些错误。'
            '了解并避免它们，是写出健壮异步代码的关键。',
          ),

          const Paragraph(
            '陷阱1：阻塞事件循环。在协程中调用同步阻塞代码(如time.sleep())会阻塞整个事件循环，'
            '导致所有并发任务暂停。永远不要在协程中使用time.sleep()，改用await asyncio.sleep()。',
          ),
          const CodeBlock(
            r'''import asyncio
import time

async def bad_example():
    """错误示例: 阻塞事件循环"""
    print("任务1: 开始")
    time.sleep(3)  # 错误! 这会阻塞整个事件循环
    print("任务1: 结束")

async def good_example():
    """正确示例: 使用异步sleep"""
    print("任务2: 开始")
    await asyncio.sleep(3)  # 正确! 挂起当前协程，不阻塞事件循环
    print("任务2: 结束")

async def main():
    # 启动两个"并发"任务
    bad1 = asyncio.create_task(bad_example())
    bad2 = asyncio.create_task(bad_example())
    # time.sleep 导致它们实际上是顺序执行的

    # 对比:
    good1 = asyncio.create_task(good_example())
    good2 = asyncio.create_task(good_example())
    # await asyncio.sleep 让它们真正并发执行

    await asyncio.gather(bad1, bad2, good1, good2)

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '陷阱2：忘记await。这是最常见的异步编程错误。调用一个async函数但不加await，'
            '得到的不是结果，而是一个协程对象。这个协程对象永远不会被执行，'
            '代码也不会报错——只是什么都不做。',
          ),
          const CodeBlock(
            r'''import asyncio

async def critical_operation():
    """一个关键操作"""
    await asyncio.sleep(1)
    print("关键操作执行!")
    return "重要数据"

async def main():
    # 陷阱: 忘记await
    result = critical_operation()  # 错误! 没有await
    print(f"结果: {result}")  # 打印: 结果: <coroutine object ...>

    # 正确做法
    result = await critical_operation()  # 正确
    print(f"结果: {result}")  # 打印: 结果: 重要数据

    # 陷阱: 创建了task但没有保存引用
    asyncio.create_task(critical_operation())  # 可能被垃圾回收!
    await asyncio.sleep(2)  # 可能看不到输出

    # 正确: 保存引用
    task = asyncio.create_task(critical_operation())
    await task

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '陷阱3：在非异步函数中调用异步代码。如果在一个普通函数(非async def)中'
            '调用异步协程，不能使用await，需要使用asyncio.run()或事件循环的其他API。',
          ),
          const CodeBlock(
            r'''import asyncio

async def fetch_data():
    await asyncio.sleep(1)
    return [1, 2, 3]

# 错误: 在同步函数中使用await
# def process():
#     data = await fetch_data()  # SyntaxError!

# 错误: 在同步函数中创建事件循环
# def process():
#     loop = asyncio.new_event_loop()
#     data = loop.run_until_complete(fetch_data())  # 可能有问题

# 正确方式1: 让调用者也变成异步
async def process_async():
    data = await fetch_data()
    return [x * 2 for x in data]

# 正确方式2: 使用asyncio.run() (注意: 不能嵌套)
def process():
    data = asyncio.run(fetch_data())
    return [x * 2 for x in data]

# 正确方式3: 如果已经运行在事件循环中
async def main():
    # 在异步函数中调用同步封装
    data = await process_async()
    print(data)

asyncio.run(main())''',
            language: 'Python',
          ),
          const Paragraph(
            '陷阱4：共享状态竞争。虽然asyncio是单线程的，但在await点可能会发生协程切换。'
            '如果两个协程之间有共享状态，仍然可能出现竞态条件。需要使用asyncio.Lock保护。',
          ),
          const CodeBlock(
            r'''import asyncio

# 竞态条件示例
counter = 0

async def unsafe_increment():
    global counter
    temp = counter          # 协程可能在这里切换
    await asyncio.sleep(0)  # 主动让出控制权
    counter = temp + 1

async def main_race():
    global counter
    counter = 0
    tasks = [unsafe_increment() for _ in range(100)]
    await asyncio.gather(*tasks)
    print(f"无锁结果: {counter} (期望: 100)")

# 正确: 使用锁
lock = asyncio.Lock()
counter_safe = 0

async def safe_increment():
    global counter_safe
    async with lock:
        temp = counter_safe
        await asyncio.sleep(0)  # 但此时不会有切换
        counter_safe = temp + 1

async def main_safe():
    global counter_safe
    counter_safe = 0
    tasks = [safe_increment() for _ in range(100)]
    await asyncio.gather(*tasks)
    print(f"有锁结果: {counter_safe} (期望: 100)")

async def main():
    await main_race()
    await main_safe()

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''无锁结果: 1 (期望: 100)
有锁结果: 100 (期望: 100)''',
          ),
          const Paragraph(
            '陷阱5：异常丢失。如果某个协程抛出了未捕获的异常，但这个协程没有被await，'
            '异常信息会被事件循环捕获并记录，而不会传播给调用者。这可能导致"静默失败"。',
          ),
          const CodeBlock(
            r'''import asyncio

async def problematic_task():
    """一个会出错的协程"""
    await asyncio.sleep(1)
    raise ValueError("出错了!")
    # 这个异常会被事件循环捕获并记录,但不会传播

async def main():
    # 陷阱: 异常丢失
    task = asyncio.create_task(problematic_task())
    await asyncio.sleep(2)
    print("任务完成了?")  # 实际上任务出错了，但我们不知道

    # 检查任务是否有异常
    if task.done() and not task.cancelled():
        try:
            result = task.result()  # 这会重新抛出异常
        except ValueError as e:
            print(f"发现隐藏的异常: {e}")

    # 更好的方式: 使用gather
    # gather默认会将异常传播
    task2 = asyncio.create_task(problematic_task())
    try:
        results = await asyncio.gather(task2)
    except ValueError as e:
        print(f"gather 捕获到: {e}")

    # 或者使用 add_done_callback
    def handle_exception(future):
        if future.exception():
            print(f"回调发现异常: {future.exception()}")

    task3 = asyncio.create_task(problematic_task())
    task3.add_done_callback(handle_exception)
    await asyncio.sleep(2)

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''任务完成了?
发现隐藏的异常: 出错了!
gather 捕获到: 出错了!
回调发现异常: 出错了!''',
          ),
          const TipBox(
            '始终保存你创建的Task的引用，并在适当的时候检查其状态。'
            '使用asyncio.gather(return_exceptions=True)可以捕获所有异常而不中断其他任务。',
            type: TipType.caution,
          ),

          // --- 4.3 Async context managers and generators ---
          const SectionHeader('4.3 异步上下文管理器和异步生成器', icon: Icons.view_list),
          const Paragraph(
            'Python 3.5+支持异步上下文管理器(async with)和异步迭代器(async for)，'
            'Python 3.6+支持异步生成器(使用yield in async def)。这些特性让异步资源管理更加自然。',
          ),
          const Paragraph(
            '异步上下文管理器：实现了__aenter__和__aexit__方法的对象。'
            '典型应用是管理数据库连接、文件句柄、网络连接等资源的生命周期。',
          ),
          const CodeBlock(
            r'''import asyncio

class AsyncDatabase:
    """模拟异步数据库连接"""

    async def __aenter__(self):
        """进入上下文时建立连接"""
        print("正在连接数据库...")
        await asyncio.sleep(1)  # 模拟连接耗时
        self.connected = True
        print("数据库连接成功")
        return self  # 返回资源对象

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """退出上下文时关闭连接"""
        print("正在关闭数据库连接...")
        await asyncio.sleep(0.5)  # 模拟关闭耗时
        self.connected = False
        print("数据库连接已关闭")
        # 返回False表示不抑制异常
        return False

    async def query(self, sql):
        """执行查询"""
        if not self.connected:
            raise RuntimeError("未连接到数据库")
        await asyncio.sleep(0.3)  # 模拟查询耗时
        return f"结果: {sql}"

async def use_database():
    """使用异步上下文管理器"""
    async with AsyncDatabase() as db:
        result = await db.query("SELECT * FROM users")
        print(result)
    # 退出async with块后，__aexit__会自动被调用

asyncio.run(use_database())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''正在连接数据库...
数据库连接成功
结果: SELECT * FROM users
正在关闭数据库连接...
数据库连接已关闭''',
          ),
          const Paragraph(
            '异步生成器：在async def函数中使用yield语句。它返回一个异步迭代器，'
            '可以通过async for来遍历。异步生成器实现了__aiter__和__anext__协议。',
          ),
          const CodeBlock(
            r'''import asyncio

async def async_range(start, end, delay=0.5):
    """异步版本的range: 每产生一个值就等待一段时间"""
    for i in range(start, end):
        await asyncio.sleep(delay)  # 模拟异步操作
        yield i  # 产生值

async def fetch_pages(base_url, page_count):
    """模拟异步获取多个页面"""
    for page in range(1, page_count + 1):
        print(f"正在获取第{page}页...")
        await asyncio.sleep(1)  # 模拟网络延迟
        yield {
            'page': page,
            'url': f"{base_url}/page/{page}",
            'content': f"第{page}页的内容",
        }

async def main():
    print("=== 异步生成器示例1: async_range ===")
    async for num in async_range(0, 5, delay=0.3):
        print(f"收到: {num}")

    print("\n=== 异步生成器示例2: fetch_pages ===")
    async for page_data in fetch_pages("https://example.com", 3):
        print(f"处理: {page_data['url']}")

    print("\n所有页面处理完成!")

asyncio.run(main())''',
            language: 'Python',
          ),
          const OutputBox(
            r'''=== 异步生成器示例1: async_range ===
收到: 0
收到: 1
收到: 2
收到: 3
收到: 4

=== 异步生成器示例2: fetch_pages ===
正在获取第1页...
处理: https://example.com/page/1
正在获取第2页...
处理: https://example.com/page/2
正在获取第3页...
处理: https://example.com/page/3

所有页面处理完成!''',
          ),
          const Paragraph(
            '异步生成器可以结合异步上下文管理器，用于实现资源流的惰性处理。'
            '例如，逐块读取一个大文件，并在读取完成后自动清理资源。',
          ),
          const CodeBlock(
            r'''import asyncio
from contextlib import asynccontextmanager

@asynccontextmanager
async def managed_resource():
    """使用装饰器创建异步上下文管理器"""
    print("获取资源")
    resource = {"value": 42}
    try:
        yield resource
    finally:
        print("释放资源")
        resource.clear()

async def use_managed():
    """使用装饰器创建的上下文管理器"""
    async with managed_resource() as res:
        print(f"使用资源: {res['value']}")
        await asyncio.sleep(0.5)
    print("资源已释放")

asyncio.run(use_managed())

# 更实用的例子: 异步文件读取
async def read_file_chunks(filename, chunk_size=1024):
    """异步生成器: 逐块读取文件"""
    # 使用run_in_executor避免阻塞
    loop = asyncio.get_running_loop()
    with open(filename, 'rb') as f:
        while True:
            chunk = await loop.run_in_executor(
                None, f.read, chunk_size
            )
            if not chunk:
                break
            yield chunk

async def process_large_file(filename):
    """处理大文件(逐块)"""
    async for chunk in read_file_chunks(filename):
        # 处理每个数据块
        print(f"处理 {len(chunk)} bytes")
        await asyncio.sleep(0.1)  # 模拟处理
    print("文件处理完成")

# 注意: 实际的异步文件IO可以使用 aiofiles 库
# pip install aiofiles''',
            language: 'Python',
          ),
          const TipBox(
            '@asynccontextmanager 装饰器(来自contextlib)可以让你不用定义类，'
            '直接用函数创建异步上下文管理器。async for 和 async with 结合使用'
            '是管理异步资源的推荐模式。',
            type: TipType.tip,
          ),

          // =================================================================
          // Summary
          // =================================================================
          const _AsyncTaskSimDemo(),
          const DividerLine(),

          const SectionHeader('本章总结', icon: Icons.summarize),
          const Paragraph(
            '本章详细介绍了Python异步IO的核心概念和实践。我们从协程的基础概念出发，'
            '理解了async/await语法、Coroutine/Task/Future的区别以及如何创建和运行协程。'
            '然后深入探讨了asyncio标准库，包括事件循环、任务管理、同步原语、超时处理、'
            '子进程管理和流API。接着学习了aiohttp库的使用，从基本的HTTP请求到并发请求、'
            '错误处理再到WebSocket。最后总结了异步编程的最佳实践和常见陷阱。',
          ),
          const Paragraph(
            '异步编程是Python生态系统中非常重要的一部分。掌握asyncio和aiohttp'
            '可以帮助你编写高性能的网络应用。在实际项目中，合理选择异步/同步/多线程/多进程'
            '的组合方式，才能构建出高效且可维护的系统。',
          ),
          const TipBox(
            '推荐继续学习: asyncio官方文档、aiohttp官方文档、Trio库(另一个异步框架)。'
            '实践是最好的学习方式，尝试用asyncio重写你的网络爬虫或Web应用吧!',
            type: TipType.tip,
          ),
          const Paragraph(
            '实践建议：从改写简单的同步网络程序开始，逐步过渡到完整的异步应用。'
            '记住，不要在所有场景下都使用异步——选择最适合你当前任务的工具。',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
