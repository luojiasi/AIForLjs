import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Python 第17章：进程和线程
/// 涵盖：进程与线程、threading 模块、同步原语、线程池、GIL、multiprocessing 模块、
/// threading.local()、分布式进程、asyncio 对比、常见陷阱与实战案例
class PythonMultithreadingTutorial extends StatelessWidget {
  const PythonMultithreadingTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第17章 进程和线程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Overview =====
          const SectionHeader('本章内容', icon: Icons.list),
          const Paragraph(
            '1 进程 vs 线程  2 Thread 类基础  3 start() 与 join()\n'
            '4 Daemon 线程  5 线程命名与识别  6 Lock 与 RLock 同步\n'
            '7 Condition 生产者-消费者  8 Event 线程信号  9 Semaphore 信号量\n'
            '10 Barrier 栅栏  11 线程池 ThreadPoolExecutor  12 Queue 安全队列\n'
            '13 Timer 定时器  14 threading.local() 线程局部存储  15 GIL 深入解析\n'
            '16 Process 与 Pool  17 IPC Queue Pipe 共享内存  18 Manager 与高级 IPC\n'
            '19 ProcessPoolExecutor  20 进程线程深入对比  21 分布式进程\n'
            '22 asyncio 对比  23 陷阱与最佳实践  24 实战案例  25 调试与日志',
          ),
          const TipBox(
            '多线程和多进程是 Python 进阶的重要主题。理解 GIL 的影响、正确使用同步机制'
            '以及合理选择并发模型，是写出高效、安全并发程序的关键。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ===== 1. Process vs Thread =====
          const SectionHeader('1. 进程 vs 线程', icon: Icons.compare_arrows),
          const Paragraph(
            '进程（Process）是操作系统资源分配的最小单位，每个进程有独立的地址空间、'
            '内存、文件描述符等。线程（Thread）是 CPU 调度的最小单位，同一进程内的'
            '多个线程共享地址空间和资源。',
          ),
          const Paragraph(
            '核心区别：\n'
            '  • 进程间相互独立，一个进程崩溃不影响其他进程\n'
            '  • 线程间共享内存，通信更高效，但需要同步保护\n'
            '  • 创建进程的开销远大于创建线程\n'
            '  • 进程切换开销大，线程切换开销小\n'
            '  • 多进程适合 CPU 密集型任务，多线程适合 I/O 密集型任务',
          ),
          const CodeBlock(
            r'''import os
import threading

print(f"主进程 PID: {os.getpid()}")
print(f"主线程名: {threading.current_thread().name}")

# 当前活动线程数
print(f"活动线程数: {threading.active_count()}")''',
            language: 'Python',
          ),
          const OutputBox(
            '主进程 PID: 12345\n'
            '主线程名: MainThread\n'
            '活动线程数: 1',
          ),
          const Paragraph(
            '进程与线程详细对比：\n'
            '  • 资源开销：进程开销大（独立内存空间），线程开销小（共享内存）\n'
            '  • 数据共享：进程需 IPC（Queue、Pipe 等），线程可直接读写共享变量\n'
            '  • 隔离性：进程完全隔离（一个崩溃不影响其他），线程共享风险（需同步）\n'
            '  • GIL 影响：多进程无 GIL 限制，多线程受 GIL 限制（CPU 密集型）\n'
            '  • 创建速度：进程创建慢（fork/spawn），线程创建快\n'
            '  • 适用场景：进程适合 CPU 密集型，线程适合 I/O 密集型',
          ),
          const DividerLine(),

          // ===== 2. Thread Class =====
          const SectionHeader('2. Thread 类基础', icon: Icons.play_circle_outline),
          const Paragraph(
            'threading 模块是 Python 多线程编程的核心模块。创建线程有两种方式：'
            '直接传入 target 函数，或继承 Thread 类重写 run() 方法。推荐使用第一种方式，'
            '更简洁、更 Pythonic。',
          ),
          const Paragraph(
            '构造参数：\n'
            '  • target：线程要执行的函数\n'
            '  • args：传递给 target 的元组参数\n'
            '  • kwargs：传递给 target 的字典参数\n'
            '  • name：线程名\n'
            '  • daemon：是否为守护线程',
          ),
          const CodeBlock(
            r'''import threading
import time

def worker(name, delay):
    """模拟耗时任务"""
    print(f"线程 {name} 启动")
    time.sleep(delay)
    print(f"线程 {name} 结束，经过 {delay} 秒")

# 创建线程
t1 = threading.Thread(target=worker, args=("A", 2))
t2 = threading.Thread(target=worker, args=("B", 1))

# 启动线程
t1.start()
t2.start()

# 等待线程结束
t1.join()
t2.join()

print("所有线程执行完毕")''',
            language: 'Python',
          ),
          const OutputBox(
            '线程 A 启动\n'
            '线程 B 启动\n'
            '线程 B 结束，经过 1 秒\n'
            '线程 A 结束，经过 2 秒\n'
            '所有线程执行完毕',
          ),
          const DividerLine(),

          // ===== 3. start() 与 join() =====
          const SectionHeader('3. start() 与 join()', icon: Icons.directions_run),
          const Paragraph(
            'start() 调用后线程进入就绪状态，等待操作系统调度。join(timeout) 使主线程'
            '阻塞等待子线程结束，timeout 可指定最长等待秒数。不调用 join() 可能造成'
            '主线程提前退出而子线程未完成的问题。',
          ),
          const CodeBlock(
            r'''import threading
import time

def slow_task(n):
    time.sleep(n)
    print(f"任务完成，耗时 {n} 秒")

threads = []
for i in range(3):
    t = threading.Thread(target=slow_task, args=(i + 1,))
    t.start()
    threads.append(t)

print("所有线程已启动，等待完成...")

# 逐个等待，最多等 2 秒
for t in threads:
    t.join(timeout=2)
    if t.is_alive():
        print(f"线程 {t.name} 还未完成")

print("主线程继续执行")''',
            language: 'Python',
          ),
          const TipBox(
            'join(timeout) 是超时等待，时间到后主线程不再等待该线程，但线程仍在后台运行。'
            '如果需要确保所有线程完成，应使用不超时的 join()。',
            type: TipType.warning,
          ),
          const OutputBox(
            '所有线程已启动，等待完成...\n'
            '任务完成，耗时 1 秒\n'
            '任务完成，耗时 2 秒\n'
            '线程 Thread-3 还未完成\n'
            '主线程继续执行\n'
            '任务完成，耗时 3 秒',
          ),
          const DividerLine(),

          // ===== 4. Daemon =====
          const SectionHeader('4. Daemon 守护线程', icon: Icons.shield_outlined),
          const Paragraph(
            '守护线程（Daemon Thread）是在后台运行的低优先级线程。当所有非守护线程'
            '结束时，Python 程序会自动退出，不会等待守护线程完成。守护线程常用于'
            '后台监控、垃圾回收、心跳检测等场景。',
          ),
          const Paragraph(
            '关键点：\n'
            '  • 必须在 start() 之前设置 daemon=True\n'
            '  • 守护线程中不应操作资源（可能被突然终止）\n'
            '  • 不能 join() 守护线程（无意义）',
          ),
          const CodeBlock(
            r'''import threading
import time

def background_monitor():
    """后台监控线程"""
    count = 0
    while True:
        count += 1
        print(f"[守护] 心跳检测 #{count}")
        time.sleep(1)

def user_task():
    """用户主任务"""
    print("[主任务] 开始工作...")
    time.sleep(3)
    print("[主任务] 工作完成")

# 创建守护线程
daemon = threading.Thread(
    target=background_monitor,
    daemon=True,       # 设置为守护线程
    name="Heartbeat"
)
daemon.start()

# 主任务运行
user_task()
print("主程序退出，守护线程自动终止")''',
            language: 'Python',
          ),
          const OutputBox(
            '[守护] 心跳检测 #1\n'
            '[主任务] 开始工作...\n'
            '[守护] 心跳检测 #2\n'
            '[守护] 心跳检测 #3\n'
            '[主任务] 工作完成\n'
            '主程序退出，守护线程自动终止',
          ),
          const TipBox(
            '守护线程会在程序退出时被强制终止，不会执行清理操作。如果线程需要优雅退出，'
            '应使用 Event 信号机制让线程自行退出。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ===== 5. Thread naming =====
          const SectionHeader('5. 线程命名与识别', icon: Icons.badge_outlined),
          const Paragraph(
            '给线程起一个有意义的名字对调试至关重要。threading.current_thread() 返回'
            '当前线程对象，通过 name 属性可以获取或设置线程名。Python 会自动为未命名'
            '线程分配 Thread-1, Thread-2 等名称。',
          ),
          const CodeBlock(
            r'''import threading
import time

def worker():
    current = threading.current_thread()
    print(f"当前线程: {current.name}, ID: {current.ident}")
    time.sleep(0.5)
    print(f"{current.name} 结束")

# 创建命名线程
threads = [
    threading.Thread(target=worker, name=f"Worker-{i}")
    for i in range(3)
]

for t in threads:
    t.start()

# 枚举所有活动线程
print("\n活动线程列表:")
for thread in threading.enumerate():
    print(f"  - {thread.name} (daemon={thread.daemon})")

for t in threads:
    t.join()

print(f"\n主线程: {threading.current_thread().name}")''',
            language: 'Python',
          ),
          const OutputBox(
            '当前线程: Worker-0, ID: 12356\n'
            '当前线程: Worker-1, ID: 12357\n'
            '当前线程: Worker-2, ID: 12358\n'
            '\n'
            '活动线程列表:\n'
            '  - MainThread (daemon=False)\n'
            '  - Worker-0 (daemon=False)\n'
            '  - Worker-1 (daemon=False)\n'
            '  - Worker-2 (daemon=False)\n'
            '\n'
            'Worker-0 结束\n'
            'Worker-1 结束\n'
            'Worker-2 结束\n'
            '\n'
            '主线程: MainThread',
          ),
          const DividerLine(),

          // ===== 6. Lock & RLock =====
          const SectionHeader('6. 线程同步：Lock 与 RLock', icon: Icons.lock_outline),
          const Paragraph(
            '当多个线程同时访问共享资源时，会发生"竞态条件"（Race Condition）。'
            'Lock（互斥锁）确保同一时刻只有一个线程能访问被保护的代码段。'
            'RLock（可重入锁）允许同一线程多次 acquire() 而不死锁。',
          ),
          const CodeBlock(
            r'''import threading

# ===== 没有锁的情况 =====
counter = 0

def unsafe_increment():
    global counter
    for _ in range(100000):
        temp = counter      # 读取
        counter = temp + 1  # 写入 —— 不是原子操作！

threads = [threading.Thread(target=unsafe_increment) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"无锁结果: {counter} (期望 1000000)")


# ===== 使用 Lock 同步 =====
counter2 = 0
lock = threading.Lock()

def safe_increment():
    global counter2
    for _ in range(100000):
        with lock:          # 自动 acquire/release
            temp = counter2
            counter2 = temp + 1

threads = [threading.Thread(target=safe_increment) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
print(f"有锁结果: {counter2} (期望 1000000)")''',
            language: 'Python',
          ),
          const OutputBox(
            '无锁结果: 782341 (期望 1000000)\n'
            '有锁结果: 1000000 (期望 1000000)',
          ),
          const Paragraph(
            'RLock 与 Lock 的区别：RLock 允许同一线程多次 acquire()，适用于递归调用'
            '或函数链式调用的场景。用 with 语句管理锁是最安全的方式。',
          ),
          const CodeBlock(
            r'''import threading

rlock = threading.RLock()

def func1():
    with rlock:          # 第一次获取
        print("func1 获得锁")
        func2()          # 会再次获取同一锁

def func2():
    with rlock:          # 第二次获取 —— Lock 会死锁，RLock 不会
        print("func2 获得锁（重入）")

threading.Thread(target=func1).start()
# 如果用 Lock，func2 中的 acquire() 会导致死锁！''',
            language: 'Python',
          ),
          const OutputBox(
            'func1 获得锁\n'
            'func2 获得锁（重入）',
          ),
          const TipBox(
            'with lock 是推荐用法：自动 acquire/release，即使发生异常也会释放锁。'
            '避免手动 acquire()/release()，容易忘记 release 导致死锁。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== 7. Condition =====
          const SectionHeader('7. Condition 条件变量', icon: Icons.compare_arrows),
          const Paragraph(
            'Condition 变量用于线程间的相互通知。一个线程等待某个条件满足，'
            '另一个线程在条件满足后通知等待线程。典型的"生产者-消费者"模式：'
            '生产者生产数据后通知消费者，消费者消费数据后通知生产者。',
          ),
          const CodeBlock(
            r'''import threading
import time
import random

# 生产者-消费者模式
buffer = []
MAX_SIZE = 5
condition = threading.Condition()

def producer():
    for i in range(10):
        with condition:
            while len(buffer) >= MAX_SIZE:
                print("[生产者] 缓冲区满了，等待消费...")
                condition.wait()          # 等待消费者通知
            item = random.randint(1, 100)
            buffer.append(item)
            print(f"[生产者] 生产 {item}，缓冲区: {buffer}")
            condition.notify()            # 通知消费者
        time.sleep(random.uniform(0.1, 0.5))

def consumer():
    for i in range(10):
        with condition:
            while not buffer:
                print("[消费者] 缓冲区空了，等待生产...")
                condition.wait()          # 等待生产者通知
            item = buffer.pop(0)
            print(f"[消费者] 消费 {item}，缓冲区: {buffer}")
            condition.notify()            # 通知生产者
        time.sleep(random.uniform(0.2, 0.6))

t1 = threading.Thread(target=producer, name="Producer")
t2 = threading.Thread(target=consumer, name="Consumer")
t1.start(); t2.start()
t1.join(); t2.join()
print("生产-消费完成")''',
            language: 'Python',
          ),
          const Paragraph(
            'wait() 会释放锁并阻塞当前线程，直到被 notify() 唤醒。'
            'notify() 唤醒一个等待线程，notify_all() 唤醒所有等待线程。'
            '注意：condition.wait() 必须在 with 块内调用。',
          ),
          const DividerLine(),

          // ===== 8. Event =====
          const SectionHeader('8. Event 事件信号', icon: Icons.signal_cellular_alt),
          const Paragraph(
            'Event 是线程间发送信号的简单机制。一个 Event 对象维护一个内部标志位，'
            'set() 设置为 True，clear() 重置为 False，wait() 阻塞直到标志为 True。'
            '适合"等一个信号再继续"的场景。',
          ),
          const CodeBlock(
            r'''import threading
import time

# 用 Event 控制多个线程同时启动
ready_event = threading.Event()
results = []

def worker(name):
    print(f"{name} 准备就绪，等待发令枪...")
    ready_event.wait()       # 阻塞等待 Event 信号
    print(f"{name} 起跑！")
    time.sleep(0.5)
    results.append(name)
    print(f"{name} 到达终点")

# 创建运动员线程
runners = []
for name in ["博尔特", "加特林", "鲍威尔"]:
    t = threading.Thread(target=worker, args=(name,))
    t.start()
    runners.append(t)

time.sleep(1)
print("\n发令枪响！\n")
ready_event.set()            # 所有线程同时启动

for t in runners:
    t.join()

print(f"\n排名: {results}")''',
            language: 'Python',
          ),
          const OutputBox(
            '博尔特 准备就绪，等待发令枪...\n'
            '加特林 准备就绪，等待发令枪...\n'
            '鲍威尔 准备就绪，等待发令枪...\n'
            '\n'
            '发令枪响！\n'
            '\n'
            '博尔特 起跑！\n'
            '加特林 起跑！\n'
            '鲍威尔 起跑！\n'
            '博尔特 到达终点\n'
            '加特林 到达终点\n'
            '鲍威尔 到达终点\n'
            '\n'
            "排名: ['博尔特', '加特林', '鲍威尔']",
          ),
          const TipBox(
            'Event 是一次性的——set() 后所有 wait() 都会立即返回。如果需要反复使用，'
            '可以在每次 wait() 完成后调用 clear() 重置。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ===== 9. Semaphore =====
          const SectionHeader('9. Semaphore 信号量', icon: Icons.toll),
          const Paragraph(
            'Semaphore（信号量）限制同时访问某资源的线程数量。内部维护一个计数器，'
            'acquire() 使计数器减一（为 0 时阻塞），release() 使计数器加一。'
            'BoundedSemaphore 确保 release() 不会超过初始值，防止编程错误。',
          ),
          const CodeBlock(
            r'''import threading
import time
import random

# 限制最多 3 个线程同时下载
semaphore = threading.Semaphore(3)

def download_file(file_id):
    with semaphore:  # acquire/release
        print(f"[下载] 文件 #{file_id} 开始下载（当前并发: {3 - semaphore._value}）")
        time.sleep(random.uniform(1, 3))
        print(f"[下载] 文件 #{file_id} 下载完成")
    # 信号量在此自动释放

files = list(range(1, 9))
threads = []
for fid in files:
    t = threading.Thread(target=download_file, args=(fid,))
    t.start()
    threads.append(t)

for t in threads:
    t.join()
print("所有文件下载完毕")''',
            language: 'Python',
          ),
          const Paragraph(
            '信号量适合限制并发访问量，比如：\n'
            '  • 数据库连接池（限制同时查询数）\n'
            '  • API 限流（控制请求频率）\n'
            '  • 文件下载器（限制并发下载数）',
          ),
          const DividerLine(),

          // ===== 10. Barrier =====
          const SectionHeader('10. Barrier 栅栏', icon: Icons.flag),
          const Paragraph(
            'Barrier（栅栏）让 N 个线程在某个"会合点"同步等待。当所有线程都到达'
            'Barrier 后，它们才被释放继续执行。这在分治算法（如并行排序、矩阵计算）'
            '中非常有用。',
          ),
          const CodeBlock(
            r'''import threading
import time
import random

def worker(barrier, name, workload):
    # 第一阶段：独立工作
    print(f"{name} 开始第一阶段计算（工作量: {workload}s）")
    time.sleep(workload)
    print(f"{name} 第一阶段完成，到达栅栏等待其他人...")

    # 等待所有线程到达
    barrier.wait()

    # 第二阶段：所有线程同步后继续
    print(f"{name} 通过栅栏，开始第二阶段工作")
    time.sleep(random.uniform(0.5, 1))
    print(f"{name} 全部完成")

# 3 个线程的会合栅栏
barrier = threading.Barrier(3)

names = ["线程A", "线程B", "线程C"]
workloads = [random.uniform(0.5, 2) for _ in range(3)]

threads = [
    threading.Thread(target=worker, args=(barrier, n, w))
    for n, w in zip(names, workloads)
]

for t in threads: t.start()
for t in threads: t.join()
print("所有线程完成全部工作！")''',
            language: 'Python',
          ),
          const TipBox(
            'Barrier 的 action 参数可以指定一个回调函数，在所有线程到达栅栏后、'
            '释放前执行。适合做阶段间的汇总或日志。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== 11. ThreadPoolExecutor =====
          const SectionHeader('11. 线程池 ThreadPoolExecutor', icon: Icons.pool),
          const Paragraph(
            '频繁创建销毁线程开销很大。线程池预先创建一组线程，复用它们执行任务。'
            'concurrent.futures.ThreadPoolExecutor 提供了高级 API：submit() 提交单个任务'
            '返回 Future，map() 批量提交并收集结果。',
          ),
          const CodeBlock(
            r'''from concurrent.futures import ThreadPoolExecutor
import time

def fetch_url(url):
    """模拟网络请求"""
    time.sleep(1)
    return f"[完成] {url}"

# 方式一：使用上下文管理器
with ThreadPoolExecutor(max_workers=3) as executor:
    urls = [
        "https://api.example.com/data/1",
        "https://api.example.com/data/2",
        "https://api.example.com/data/3",
        "https://api.example.com/data/4",
        "https://api.example.com/data/5",
    ]

    # submit() 提交单个任务
    futures = [executor.submit(fetch_url, url) for url in urls]

    # 按提交顺序获取结果
    for future in futures:
        result = future.result()    # 阻塞等待结果
        print(result)

print("--- 用 map() 更简洁 ---")

with ThreadPoolExecutor(max_workers=3) as executor:
    results = executor.map(fetch_url, urls)
    for r in results:
        print(r)''',
            language: 'Python',
          ),
          const OutputBox(
            '[完成] https://api.example.com/data/1\n'
            '[完成] https://api.example.com/data/2\n'
            '[完成] https://api.example.com/data/3\n'
            '[完成] https://api.example.com/data/4\n'
            '[完成] https://api.example.com/data/5\n'
            '--- 用 map() 更简洁 ---\n'
            '[完成] https://api.example.com/data/1\n'
            '[完成] https://api.example.com/data/2\n'
            '[完成] https://api.example.com/data/3\n'
            '[完成] https://api.example.com/data/4\n'
            '[完成] https://api.example.com/data/5',
          ),
          const Paragraph(
            'Future 对象提供：\n'
            '  • result(timeout)：获取结果，超时可选\n'
            '  • done()：是否完成\n'
            '  • cancel()：取消未启动的任务\n'
            '  • add_done_callback()：完成后自动回调',
          ),
          const Paragraph(
            '线程池的最佳实践：\n'
            '  • 使用上下文管理器（with 语句）确保线程池正确关闭\n'
            '  • max_workers 通常设置为 CPU 核数的 4-8 倍（I/O 密集型）\n'
            '  • 避免提交耗时过长的任务阻塞线程池\n'
            '  • 使用 futures.as_completed() 按完成顺序获取结果',
          ),
          const DividerLine(),

          // ===== 12. Queue =====
          const SectionHeader('12. Queue 线程安全队列', icon: Icons.queue),
          const Paragraph(
            'queue.Queue 是线程安全的生产者-消费者队列，内部已自动加锁，'
            '无需额外同步。常用方法：put(item, block, timeout) 放入数据，'
            'get(block, timeout) 取出数据，task_done() 标记任务完成。',
          ),
          const CodeBlock(
            r'''from queue import Queue
import threading
import time
import random

# 线程安全的任务队列
task_queue = Queue()

def producer(queue, num_tasks):
    """生产者：生成任务"""
    for i in range(num_tasks):
        task = f"任务-{i}"
        queue.put(task)
        print(f"[生产者] 添加 {task}")
        time.sleep(random.uniform(0.1, 0.3))
    queue.put(None)   # 发送停止信号

def worker(queue, name):
    """消费者：执行任务"""
    while True:
        task = queue.get()
        if task is None:    # 收到停止信号
            queue.put(None)  # 传递给下一个消费者
            break
        print(f"[{name}] 执行 {task}...")
        time.sleep(random.uniform(0.5, 1))
        queue.task_done()
    print(f"[{name}] 停止工作")

# 启动生产和消费
q = Queue()
threads = [
    threading.Thread(target=producer, args=(q, 8)),
    threading.Thread(target=worker, args=(q, "Worker-1")),
    threading.Thread(target=worker, args=(q, "Worker-2")),
]

for t in threads: t.start()
for t in threads: t.join()

print("任务处理完毕")''',
            language: 'Python',
          ),
          const TipBox(
            'queue.Queue 的 block=False 参数可实现非阻塞操作：'
            'get(block=False) 在队列空时抛出 queue.Empty，'
            'put(block=False) 在队列满时抛出 queue.Full。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== 13. Timer =====
          const SectionHeader('13. Timer 定时器', icon: Icons.timer),
          const Paragraph(
            'threading.Timer 用于延迟执行函数，类似于"定时炸弹"——等待指定时间后'
            '执行目标函数。Timer 是 Thread 的子类，可以 cancel() 取消。适合定时任务、'
            '超时处理、延迟加载等场景。',
          ),
          const CodeBlock(
            r'''import threading
import time

def timeout_handler():
    print("超时！任务执行时间过长，已取消")
    # 在这里做超时恢复操作

def long_task():
    print("[任务] 开始执行")
    for i in range(5):
        print(f"[任务] 进度 {i+1}/5")
        time.sleep(1.5)
    print("[任务] 完成")

# 创建 3 秒超时定时器
timer = threading.Timer(3.0, timeout_handler)
timer.start()

# 执行主任务
long_task()

# 如果任务在 3 秒内完成，取消定时器
if timer.is_alive():
    timer.cancel()
    print("定时器已取消（任务提前完成）")

print("程序结束")''',
            language: 'Python',
          ),
          const OutputBox(
            '[任务] 开始执行\n'
            '[任务] 进度 1/5\n'
            '[任务] 进度 2/5\n'
            '超时！任务执行时间过长，已取消\n'
            '[任务] 进度 3/5\n'
            '[任务] 进度 4/5\n'
            '[任务] 进度 5/5\n'
            '[任务] 完成\n'
            '程序结束',
          ),
          const DividerLine(),

          // ===== 14. threading.local() =====
          const SectionHeader('14. threading.local() 线程局部存储', icon: Icons.storage),
          const Paragraph(
            'threading.local() 创建线程局部存储（TLS），每个线程独立拥有自己的数据副本，'
            '互不干扰。非常适合保存每个线程特有的上下文，如数据库连接、用户会话、'
            '事务 ID 等。',
          ),
          const CodeBlock(
            r'''import threading
import random

# 线程局部存储
thread_data = threading.local()

def process_item(item):
    """处理数据项——每个线程有独立的数据"""
    # 为当前线程初始化唯一 ID
    if not hasattr(thread_data, 'thread_id'):
        thread_data.thread_id = threading.current_thread().ident
        thread_data.processed = 0

    # 使用线程局部数据
    thread_data.processed += 1
    current = threading.current_thread()
    print(
        f"[线程 {current.name}] "
        f"处理: {item}, "
        f"已处理: {thread_data.processed}, "
        f"线程ID: {thread_data.thread_id}"
    )

# 启动多个线程，验证数据相互隔离
items = list(range(8))
threads = []
for i in range(4):
    t = threading.Thread(
        target=lambda: [process_item(random.choice(items)) for _ in range(2)],
        name=f"Worker-{i}"
    )
    t.start()
    threads.append(t)

for t in threads: t.join()

print("\n每个线程的 thread_data 互不干扰！")''',
            language: 'Python',
          ),
          const TipBox(
            'threading.local() 非常适用于 Web 框架（如 Flask）保存请求上下文。'
            '每个请求由一个线程处理，request/response 数据存在 TLS 中，天然隔离。',
            type: TipType.info,
          ),
          const Paragraph(
            '典型应用场景：\n'
            '  • Web 框架请求上下文：Flask 的 request、session 对象存入 TLS，\n'
            '    每个请求线程获得自己的请求数据\n'
            '  • 数据库连接管理：每个线程持有独立的数据库连接/Session，避免连接冲突\n'
            '  • 事务追踪：独立的事务 ID 或日志上下文',
          ),
          const CodeBlock(
            r'''import threading
from threading import local

# 模拟 Web 请求的 TLS 上下文
request_context = threading.local()

def handle_request(request_id, user):
    """模拟处理一个 HTTP 请求"""
    request_context.request_id = request_id
    request_context.user = user
    request_context.db_conn = f"conn_{request_id}"

    print(f"[请求 {request_id}] 用户: {user}, "
          f"连接: {request_context.db_conn}")

    # 在子函数中自动获取上下文
    process_data()

def process_data():
    """子函数读取 TLS 中的请求上下文"""
    ctx = request_context
    print(f"[处理] 请求 {ctx.request_id} 的数据处理中，"
          f"用户: {ctx.user}")

# 模拟并发请求
threads = []
for i in range(3):
    t = threading.Thread(
        target=handle_request,
        args=(i, f"User-{i}"),
        name=f"Request-{i}"
    )
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print("\n每个请求的上下文完全隔离！")''',
            language: 'Python',
          ),
          const Paragraph(
            'threading.local() 与普通全局变量的区别：\n'
            '  • 普通全局变量被所有线程共享，需要 Lock 保护\n'
            '  • threading.local() 每个线程有独立副本，无需加锁\n'
            '  • 修改普通全局变量影响所有线程，修改 TLS 只影响当前线程\n'
            '  • TLS 适合"每个线程一份"的数据，不适合需要共享的数据',
          ),
          const DividerLine(),

          // ===== 15. GIL =====
          const SectionHeader('15. GIL 全局解释器锁', icon: Icons.info),
          const Paragraph(
            'GIL（Global Interpreter Lock，全局解释器锁）是 CPython 解释器的一个设计决策。'
            '它确保同一时刻只有一个线程在执行 Python 字节码。这意味着多线程在 CPU 密集型'
            '任务中不能利用多核优势。',
          ),
          const Paragraph(
            '为什么需要 GIL：\n'
            '  • CPython 的内存管理不是线程安全的（引用计数）\n'
            '  • 去掉 GIL 会导致单线程性能大幅下降（曾尝试过）\n'
            '  • GIL 简化了 C 扩展的编写\n'
            '\n'
            'GIL 的影响：\n'
            '  • I/O 密集型任务：多线程有效（GIL 在 I/O 等待时释放）\n'
            '  • CPU 密集型任务：多线程无效甚至更慢（GIL 竞争）\n'
            '  • 会释放 GIL 的操作：I/O、time.sleep()、C 扩展',
          ),
          const CodeBlock(
            r'''import threading
import time

# ===== CPU 密集型：多线程反而更慢 =====
def count_down(n):
    while n > 0:
        n -= 1            # CPU 计算，不释放 GIL

# 串行执行
start = time.time()
count_down(50000000)
count_down(50000000)
serial_time = time.time() - start
print(f"串行: {serial_time:.2f}s")

# 并行（实则并发，GIL 下轮流执行）
start = time.time()
t1 = threading.Thread(target=count_down, args=(50000000,))
t2 = threading.Thread(target=count_down, args=(50000000,))
t1.start(); t2.start()
t1.join(); t2.join()
parallel_time = time.time() - start
print(f"多线程: {parallel_time:.2f}s")
print(f"开销比: {parallel_time/serial_time:.2f}x（大于 1 说明更慢）")

# ===== I/O 密集型：多线程显著加速 =====
def io_task():
    time.sleep(1)         # I/O 等待，释放 GIL

start = time.time()
for _ in range(10): io_task()
serial_io = time.time() - start

start = time.time()
threads = [threading.Thread(target=io_task) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()
parallel_io = time.time() - start

print(f"\nI/O 串行: {serial_io:.2f}s")
print(f"I/O 多线程: {parallel_io:.2f}s")
print(f"加速比: {serial_io/parallel_io:.1f}x")''',
            language: 'Python',
          ),
          const OutputBox(
            '串行: 3.12s\n'
            '多线程: 3.85s\n'
            '开销比: 1.23x（大于 1 说明更慢）\n'
            '\n'
            'I/O 串行: 10.02s\n'
            'I/O 多线程: 1.01s\n'
            '加速比: 9.9x',
          ),
          const TipBox(
            'GIL 不是 Python 语言本身的特性，而是 CPython 实现的特性。'
            '其他实现如 Jython、IronPython 没有 GIL，但主流仍是 CPython。'
            '绕开 GIL 的方式：多进程、异步编程、C 扩展、使用不依赖 GIL 的库。',
            type: TipType.caution,
          ),
          const Paragraph(
            'GIL 的运作机制：\n'
            '  • CPython 使用检查间隔机制切换线程持有 GIL\n'
            '  • Python 3.2+ 改用超时机制（默认约 5ms）\n'
            '  • 当前线程执行一定时间或遇到 I/O 阻塞时释放 GIL\n'
            '  • sys.setswitchinterval() 可调整线程切换间隔\n'
            '\n'
            '会释放 GIL 的操作：\n'
            '  • I/O 操作（文件读写、网络请求、print 等）\n'
            '  • time.sleep() 和阻塞等待\n'
            '  • 部分 C 扩展（如 numpy、pandas 的底层操作）\n'
            '  • 加密/哈希库的部分操作\n'
            '\n'
            '不会释放 GIL 的操作：\n'
            '  • 纯 Python 的数值计算、循环\n'
            '  • 字符串/列表操作\n'
            '  • 字典查找和操作',
          ),
          const DividerLine(),

          // ===== 16. multiprocessing Process & Pool =====
          const SectionHeader('16. multiprocessing：Process 与 Pool', icon: Icons.memory),
          const Paragraph(
            'multiprocessing.Process 的 API 与 threading.Thread 非常相似，但创建的是'
            '独立的进程而非线程。每个子进程有独立的 Python 解释器、GIL 和内存空间，'
            '因此可以真正并行利用多核 CPU。',
          ),
          const Paragraph(
            'Process 类构造参数：\n'
            '  • target：进程要执行的函数\n'
            '  • args：传递给 target 的元组参数\n'
            '  • kwargs：传递给 target 的字典参数\n'
            '  • name：进程名\n'
            '  • daemon：是否为守护进程',
          ),
          const CodeBlock(
            r'''from multiprocessing import Process
import os
import time

def worker(name, delay):
    """工作进程函数"""
    print(f"子进程 {name} 启动, PID: {os.getpid()}, "
          f"父进程 PID: {os.getppid()}")
    time.sleep(delay)
    print(f"子进程 {name} 结束")

if __name__ == "__main__":
    print(f"主进程 PID: {os.getpid()}")

    # 创建多个子进程
    processes = []
    for i in range(4):
        p = Process(target=worker, args=(f"Worker-{i}", i * 0.5))
        processes.append(p)
        p.start()
        print(f"已启动 Worker-{i}")

    # 等待所有子进程结束
    for p in processes:
        p.join()
        print(f"{p.name} 已结束")

    print("所有子进程执行完毕")''',
            language: 'Python',
          ),
          const OutputBox(
            '主进程 PID: 12345\n'
            '已启动 Worker-0\n'
            '子进程 Worker-0 启动, PID: 12346, 父进程 PID: 12345\n'
            '已启动 Worker-1\n'
            '子进程 Worker-1 启动, PID: 12347, 父进程 PID: 12345\n'
            '已启动 Worker-2\n'
            '已启动 Worker-3\n'
            '子进程 Worker-2 启动, PID: 12348, 父进程 PID: 12345\n'
            '子进程 Worker-3 启动, PID: 12349, 父进程 PID: 12345\n'
            '子进程 Worker-0 结束\n'
            'Worker-0 已结束\n'
            '子进程 Worker-1 结束\n'
            'Worker-1 已结束\n'
            '子进程 Worker-2 结束\n'
            'Worker-2 已结束\n'
            '子进程 Worker-3 结束\n'
            'Worker-3 已结束\n'
            '所有子进程执行完毕',
          ),
          const TipBox(
            '在 Windows 上，multiprocessing 需要使用 if __name__ == "__main__": 保护'
            '主模块代码，避免递归创建进程。Linux/macOS 上 fork 模式无此限制。',
            type: TipType.warning,
          ),
          const Paragraph(
            '进程池 Pool 管理一组工作进程，自动分配任务并收集结果。'
            '比手动管理 Process 更简洁，支持 map、starmap、apply_async 等多种模式。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Pool
import time

def square(n):
    """计算平方"""
    return n * n

def cpu_heavy(n):
    """CPU 密集型计算"""
    total = 0
    for i in range(n):
        total += i ** 2
    return total

if __name__ == "__main__":
    # 基本 map 用法——阻塞分发并收集结果
    with Pool(processes=4) as pool:
        result = pool.map(square, range(10))
        print(f"平方结果: {result}")

    # apply_async 异步提交
    with Pool(processes=4) as pool:
        future = pool.apply_async(cpu_heavy, (5000000,))
        print("异步计算已提交，等待结果...")
        result = future.get(timeout=10)
        print(f"计算结果: {result}")

    # imap 惰性求值——边计算边返回
    with Pool(processes=4) as pool:
        for result in pool.imap(square, range(10)):
            print(f"获得结果: {result}")''',
            language: 'Python',
          ),
          const OutputBox(
            '平方结果: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]\n'
            '异步计算已提交，等待结果...\n'
            '计算结果: 4166667916666675000000\n'
            '\n'
            '获得结果: 0\n'
            '获得结果: 1\n'
            '...',
          ),
          const Paragraph(
            'Pool 常用方法：\n'
            '  • map(func, iterable)：阻塞分发并收集结果，等价于内置 map()\n'
            '  • imap(func, iterable)：惰性版本，边计算边返回结果\n'
            '  • starmap(func, iterable)：支持多参数解包，如 starmap(f, [(a,b), (c,d)])\n'
            '  • apply(func, args)：阻塞执行单个任务\n'
            '  • apply_async(func, args)：异步提交单个任务，返回 AsyncResult\n'
            '  • map_async(func, iterable)：异步版本的 map，返回 AsyncResult\n'
            '  • close() 与 join()：停止接受任务并等待所有工作进程结束',
          ),
          const DividerLine(),

          // ===== 17. IPC: Queue, Pipe, Shared Memory =====
          const SectionHeader('17. 进程间通信：Queue、Pipe 与共享内存', icon: Icons.webhook),
          const Paragraph(
            '进程间通信（IPC, Inter-Process Communication）是多进程编程的核心挑战。'
            'multiprocessing 提供了多种 IPC 机制：Queue 用于队列传递，Pipe 用于'
            '双端通信，Value/Array 用于共享内存，Manager 用于高级共享数据结构。',
          ),
          const Paragraph(
            'Queue 是进程安全的先进先出队列，可以在多个进程间安全传递 Python 对象'
            '（对象必须可 pickle 序列化）。适合生产-消费者模式。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Process, Queue
import time

def producer(queue, items):
    """生产者：向队列发送数据"""
    for item in items:
        queue.put(item)
        print(f"[生产者] 发送: {item}")
        time.sleep(0.2)
    queue.put(None)  # 结束信号

def consumer(queue, name):
    """消费者：从队列接收数据"""
    while True:
        item = queue.get()
        if item is None:
            queue.put(None)  # 传递给下一个消费者
            break
        print(f"[{name}] 收到: {item}")
        time.sleep(0.3)

if __name__ == "__main__":
    q = Queue()
    items = [f"数据-{i}" for i in range(6)]

    p1 = Process(target=producer, args=(q, items))
    p2 = Process(target=consumer, args=(q, "消费者-1"))
    p3 = Process(target=consumer, args=(q, "消费者-2"))

    p1.start(); p2.start(); p3.start()
    p1.join(); p2.join(); p3.join()
    print("所有进程完成")''',
            language: 'Python',
          ),
          const Paragraph(
            'Pipe 提供双向通信通道，返回两个连接端（两端都可收发）。'
            '适合两个进程间的直接通信，速度比 Queue 快。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Process, Pipe

def worker(conn, name):
    """工作进程：通过管道通信"""
    conn.send(f"{name} 发送了消息")
    reply = conn.recv()
    print(f"{name} 收到回复: {reply}")
    conn.close()

if __name__ == "__main__":
    # 创建管道，返回 (parent_conn, child_conn)
    parent_conn, child_conn = Pipe()

    p = Process(target=worker, args=(child_conn, "子进程"))
    p.start()

    # 主进程接收消息
    msg = parent_conn.recv()
    print(f"主进程收到: {msg}")

    # 主进程回复
    parent_conn.send("消息已收到，over")
    p.join()
    print("管道通信完成")''',
            language: 'Python',
          ),
          const OutputBox(
            '主进程收到: 子进程 发送了消息\n'
            '子进程 收到回复: 消息已收到，over\n'
            '管道通信完成',
          ),
          const Paragraph(
            'Value 和 Array 提供共享内存，性能远高于 Queue/Pipe。'
            '只能存储基本 C 类型（int、float、char 等），需要 Lock 保护。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Process, Value, Array, Lock

def increment(shared_val, shared_arr, lock):
    """在共享内存中递增"""
    for _ in range(1000):
        with lock:
            shared_val.value += 1
            for i in range(len(shared_arr)):
                shared_arr[i] += 1

if __name__ == "__main__":
    lock = Lock()
    # 'i' 表示整数类型，'d' 表示双精度浮点
    counter = Value('i', 0)
    arr = Array('i', [0, 1, 2, 3])

    processes = [
        Process(target=increment, args=(counter, arr, lock))
        for _ in range(4)
    ]

    for p in processes: p.start()
    for p in processes: p.join()

    print(f"共享计数值: {counter.value}")
    print(f"共享数组: {list(arr)}")''',
            language: 'Python',
          ),
          const OutputBox(
            '共享计数值: 4000\n'
            '共享数组: [4000, 4001, 4002, 4003]',
          ),
          const TipBox(
            'Value/Array 的速度远快于 Queue 或 Pipe，但只能存储基本类型。'
            '对于复杂数据结构，应使用 Manager 或先将数据序列化为字符串。',
            type: TipType.info,
          ),
          const DividerLine(),

          // ===== 18. Manager =====
          const SectionHeader('18. Manager 与高级共享数据', icon: Icons.hub),
          const Paragraph(
            'Manager 提供更高级的共享数据方式，支持 dict、list、Namespace 等容器类型。'
            'Manager 启动一个服务器进程来管理共享对象，所有子进程通过代理访问。'
            '虽然速度比 Value/Array 慢，但支持任意可 pickle 的类型。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Process, Manager, Lock

def worker(shared_dict, shared_list, lock, name):
    """工作进程修改共享数据"""
    with lock:
        shared_dict[name] = len(shared_dict)
        shared_list.append(name)
        print(f"{name} 修改了共享数据")

if __name__ == "__main__":
    with Manager() as manager:
        # 创建共享数据结构
        shared_dict = manager.dict()
        shared_list = manager.list()
        lock = Lock()

        workers = [
            Process(target=worker, args=(
                shared_dict, shared_list, lock, f"进程-{i}"))
            for i in range(4)
        ]

        for w in workers: w.start()
        for w in workers: w.join()

        print(f"共享字典: {dict(shared_dict)}")
        print(f"共享列表: {list(shared_list)}")

    # Manager 随上下文管理器自动清理
    print("Manager 已关闭")''',
            language: 'Python',
          ),
          const OutputBox(
            '进程-0 修改了共享数据\n'
            '进程-1 修改了共享数据\n'
            '进程-2 修改了共享数据\n'
            '进程-3 修改了共享数据\n'
            "共享字典: {'进程-0': 0, '进程-1': 1, '进程-2': 2, '进程-3': 3}\n"
            "共享列表: ['进程-0', '进程-1', '进程-2', '进程-3']\n"
            'Manager 已关闭',
          ),
          const Paragraph(
            'Namespace 提供属性访问风格的共享对象，比 dict 更直观。'
            '可以通过 ns.attr 语法直接读写属性。',
          ),
          const CodeBlock(
            r'''from multiprocessing import Manager

def worker(ns):
    """修改 Namespace 对象"""
    ns.counter += 1
    ns.items.append(ns.counter)

if __name__ == "__main__":
    with Manager() as manager:
        ns = manager.Namespace()
        ns.counter = 0
        ns.items = manager.list()

        processes = [
            Process(target=worker, args=(ns,))
            for _ in range(5)
        ]

        for p in processes: p.start()
        for p in processes: p.join()

        print(f"计数: {ns.counter}")
        print(f"项目: {list(ns.items)}")''',
            language: 'Python',
          ),
          const OutputBox(
            '计数: 5\n'
            '项目: [1, 2, 3, 4, 5]',
          ),
          const Paragraph(
            'IPC 方式选择指南：\n'
            '  • Queue：生产-消费者模式，多对多通信，使用最广泛\n'
            '  • Pipe：双进程双向通信，速度快且简单\n'
            '  • Value/Array：简单类型共享，性能最高\n'
            '  • Manager：复杂数据结构共享，方便但速度较慢\n'
            '  • 外部消息队列（Redis/RabbitMQ）：跨机器分布式场景',
          ),
          const DividerLine(),

          // ===== 19. ProcessPoolExecutor =====
          const SectionHeader('19. ProcessPoolExecutor vs ThreadPoolExecutor', icon: Icons.compare),
          const Paragraph(
            'concurrent.futures 提供了统一的高层接口：ThreadPoolExecutor 和 '
            'ProcessPoolExecutor。切换时只需改类名，API 完全兼容。',
          ),
          const CodeBlock(
            r'''from concurrent.futures import (
    ThreadPoolExecutor,
    ProcessPoolExecutor
)
import time
import math

def compute_factorial(n):
    """计算阶乘——CPU 密集型"""
    return math.factorial(n)

def fetch_mock_data(n):
    """模拟网络请求——I/O 密集型"""
    time.sleep(0.1)
    return n * 2

numbers = list(range(5000, 5100))

# CPU 密集型用多进程
print("=== CPU 密集型 ===")
for name, Executor in [("ThreadPool", ThreadPoolExecutor),
                        ("ProcessPool", ProcessPoolExecutor)]:
    start = time.time()
    with Executor(max_workers=4) as executor:
        results = list(executor.map(compute_factorial, numbers))
    print(f"{name}: {time.time() - start:.3f}s")

# I/O 密集型用多线程
print("\n=== I/O 密集型 ===")
for name, Executor in [("ThreadPool", ThreadPoolExecutor),
                        ("ProcessPool", ProcessPoolExecutor)]:
    start = time.time()
    with Executor(max_workers=8) as executor:
        results = list(executor.map(fetch_mock_data, range(100)))
    print(f"{name}: {time.time() - start:.3f}s")''',
            language: 'Python',
          ),
          const Paragraph(
            '选择指南：\n'
            '  • CPU 密集型 → ProcessPoolExecutor（绕开 GIL）\n'
            '  • I/O 密集型 → ThreadPoolExecutor（线程开销小）\n'
            '  • 大内存共享 → ThreadPoolExecutor（进程间共享复杂）\n'
            '  • 纯计算无 I/O → ProcessPoolExecutor',
          ),
          const TipBox(
            'ProcessPoolExecutor 的任务参数和返回值必须可 pickle 序列化。'
            '如果传递不可 pickle 的对象（如 lambda），会抛出 PicklingError。'
            '此时应使用 ThreadPoolExecutor 或自定义序列化。',
            type: TipType.warning,
          ),
          const DividerLine(),

          // ===== 20. Process vs Thread in-depth =====
          const SectionHeader('20. 进程 vs 线程深入对比', icon: Icons.compare_arrows),
          const Paragraph(
            '在多线程和多进程之间做选择时，需要考虑任务类型、数据共享需求、'
            '性能要求和开发复杂度等多个维度。以下是对比指南。',
          ),
          const Paragraph(
            '决策流程：\n'
            '  ┌─ 任务是 CPU 密集型还是 I/O 密集型？\n'
            '  ├─ CPU 密集型 → 需要多核并行 → multiprocessing\n'
            '  ├─ I/O 密集型 → 需要高并发 → threading 或 asyncio\n'
            '  ├─ 需要共享大量数据？→ threading（进程间共享成本高）\n'
            '  └─ 需要跨机器分布？→ 分布式消息队列 + multiprocessing\n'
            '\n'
            '详细对比维度：\n'
            '  • 内存占用：每个进程约 10-50MB，每个线程约 50KB\n'
            '  • 创建时间：进程约 10ms，线程约 50us（差 200 倍）\n'
            '  • 切换开销：进程切换需 TLB 刷新，线程切换轻量\n'
            '  • 数据共享：进程需序列化传输，线程直接读内存\n'
            '  • 安全性：进程天然隔离，线程需 Lock 保护\n'
            '  • 可扩展性：进程可跨机器分布，线程限单机\n'
            '  • 调试难度：进程易调试，线程难调试（非确定性）',
          ),
          const Paragraph(
            'GIL 影响分析：\n'
            '  • 纯 Python 数值计算：多线程无加速，建议用多进程\n'
            '  • 文件/网络 I/O：多线程有效加速（GIL 在 I/O 时释放）\n'
            '  • 混合型任务（少量计算 + 大量 I/O）：多线程即可\n'
            '  • numpy/pandas 密集操作：多线程可用（C 扩展释放 GIL）\n'
            '  • 高并发网络服务：asyncio > 多线程 > 多进程',
          ),
          const CodeBlock(
            r'''from concurrent.futures import (
    ThreadPoolExecutor, ProcessPoolExecutor
)
import time
import math

# 明确对比四种场景
def is_prime(n):
    """素数检测——纯 CPU 计算"""
    if n < 2: return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0: return False
    return True

def io_simulate(n):
    """模拟 I/O 等待"""
    time.sleep(0.05)
    return n * 2

numbers = list(range(1, 2001))

# 1. CPU 密集型对比
print("=== CPU 密集型：素数检测 2000 个数字 ===")
for name, Executor in [
    ("单线程", None),
    ("多线程", ThreadPoolExecutor),
    ("多进程", ProcessPoolExecutor)
]:
    start = time.time()
    if Executor is None:
        result = [is_prime(n) for n in numbers]
    else:
        with Executor(max_workers=4) as ex:
            result = list(ex.map(is_prime, numbers))
    print(f"  {name}: {time.time() - start:.3f}s")

# 2. I/O 密集型对比
print("\n=== I/O 密集型：200 次模拟 I/O ===")
io_numbers = list(range(200))
for name, Executor in [
    ("单线程", None),
    ("多线程", ThreadPoolExecutor),
    ("多进程", ProcessPoolExecutor)
]:
    start = time.time()
    if Executor is None:
        result = [io_simulate(n) for n in io_numbers]
    else:
        with Executor(max_workers=8) as ex:
            result = list(ex.map(io_simulate, io_numbers))
    print(f"  {name}: {time.time() - start:.3f}s")''',
            language: 'Python',
          ),
          const OutputBox(
            '=== CPU 密集型：素数检测 2000 个数字 ===\n'
            '  单线程: 0.820s\n'
            '  多线程: 0.835s\n'
            '  多进程: 0.250s\n'
            '\n'
            '=== I/O 密集型：200 次模拟 I/O ===\n'
            '  单线程: 10.021s\n'
            '  多线程: 1.262s\n'
            '  多进程: 1.315s',
          ),
          const TipBox(
            '选择建议：CPU 密集型且数据独立 -> multiprocessing；'
            'I/O 密集型 -> threading；高并发网络服务 -> asyncio；'
            '混合型 -> 结合使用（多进程 + 每个进程内多线程）',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== 21. Distributed processes =====
          const SectionHeader('21. 分布式进程', icon: Icons.lan),
          const Paragraph(
            '分布式进程是将任务分发到多台机器上执行的技术。Python 的 '
            'multiprocessing.Manager 支持通过网络连接远程 Manager，实现跨机器进程通信。'
            '更常见的方案是使用消息队列（Redis、RabbitMQ）或 RPC 框架。',
          ),
          const Paragraph(
            '使用 BaseManager 实现远程共享队列：',
          ),
          const CodeBlock(
            r'''from multiprocessing import managers
import queue

# 共享任务队列和结果队列
task_queue = queue.Queue()
result_queue = queue.Queue()

class QueueManager(managers.BaseManager):
    """自定义 Manager 管理共享队列"""
    pass

# 注册共享队列到 Manager（服务器端）
QueueManager.register('get_task_queue',
                      callable=lambda: task_queue)
QueueManager.register('get_result_queue',
                      callable=lambda: result_queue)

if __name__ == "__main__":
    manager = QueueManager(
        address=('0.0.0.0', 5000),
        authkey=b'secret-key'
    )
    server = manager.get_server()
    print("Manager 服务器已启动，等待工作进程连接...")
    server.serve_forever()''',
            language: 'Python',
          ),
          const Paragraph(
            '工作进程连接远程 Manager 获取任务：',
          ),
          const CodeBlock(
            r'''from multiprocessing import managers

class QueueManager(managers.BaseManager):
    pass

# 注册与服务器相同的类型（只读方式）
QueueManager.register('get_task_queue')
QueueManager.register('get_result_queue')

if __name__ == "__main__":
    # 连接到远程 Manager
    manager = QueueManager(
        address=('server_ip', 5000),
        authkey=b'secret-key'
    )
    manager.connect()

    task_queue = manager.get_task_queue()
    result_queue = manager.get_result_queue()

    # 从队列获取任务并处理
    while True:
        try:
            task = task_queue.get(timeout=5)
        except queue.Empty:
            break
        if task is None:
            break
        result = task * 2  # 处理任务
        result_queue.put(result)

    print("工作进程完成")''',
            language: 'Python',
          ),
          const Paragraph(
            '更常用的分布式方案是结合外部消息队列（如 Redis）：',
          ),
          const CodeBlock(
            r'''import json
import time

# 模拟 Redis 任务队列操作
# 实际使用时需要安装 redis 包

class RedisTaskQueue:
    """模拟 Redis 任务队列"""

    def __init__(self):
        self.queue = []

    def push(self, task):
        """发布任务"""
        self.queue.append(json.dumps(task))
        print(f"发布任务: {task}")

    def pop(self, timeout=0):
        """获取任务（阻塞）"""
        if self.queue:
            return json.loads(self.queue.pop(0))
        return None

def worker_process(queue, worker_id):
    """工作进程——从队列获取并处理任务"""
    while True:
        task = queue.pop(timeout=5)
        if task is None:
            break
        print(f"[Worker-{worker_id}] 处理: {task}")
        time.sleep(0.2)  # 模拟处理
        # 处理完成，结果可放入结果队列

# 创建任务
queue = RedisTaskQueue()
for i in range(10):
    queue.push({"id": i, "value": i * 10})

# 启动多个工作进程（实际场景中在不同机器上运行）
from multiprocessing import Process
workers = [
    Process(target=worker_process, args=(queue, i))
    for i in range(3)
]
for w in workers: w.start()
for w in workers: w.join()
print("所有任务处理完成")''',
            language: 'Python',
          ),
          const Paragraph(
            '分布式进程的核心模式——任务队列：\n'
            '  • 任务生产者将任务描述发送到共享队列\n'
            '  • 多个工作进程从队列获取并执行任务\n'
            '  • 结果放入结果队列供收集\n'
            '  • 工作进程可运行在不同机器上\n'
            '  • 通过队列解耦生产和消费，天然支持负载均衡\n'
            '\n'
            '常见分布式任务框架：\n'
            '  • Celery：最流行的 Python 分布式任务队列\n'
            '  • RQ (Redis Queue)：轻量级 Redis 任务队列\n'
            '  • Apache Airflow：工作流调度系统\n'
            '  • Ray：高性能分布式计算框架',
          ),
          const DividerLine(),

          // ===== 22. asyncio comparison =====
          const SectionHeader('22. asyncio 协程对比', icon: Icons.sync),
          const Paragraph(
            'asyncio 是 Python 3.4+ 引入的异步 I/O 框架，使用协程（coroutine）实现'
            '单线程并发。与多线程和多进程相比，asyncio 提供了一种不同的并发模型：'
            '合作式多任务（cooperative multitasking），程序员控制切换点。',
          ),
          const Paragraph(
            '三种并发模型对比：\n'
            '  • threading：抢占式多任务，操作系统控制切换，适合 I/O 密集型\n'
            '  • multiprocessing：多进程并行，绕开 GIL，适合 CPU 密集型\n'
            '  • asyncio：协作式多任务，await 切换，适合高并发 I/O',
          ),
          const CodeBlock(
            r'''import asyncio
import time

# ===== asyncio 版并发 =====
async def fetch_data(url, delay):
    """模拟异步网络请求"""
    print(f"开始获取 {url}")
    await asyncio.sleep(delay)  # 模拟 I/O——不阻塞事件循环
    print(f"完成获取 {url}")
    return f"数据来自 {url}"

async def main():
    """并发执行多个请求"""
    tasks = [
        fetch_data("https://api.example.com/data/1", 2),
        fetch_data("https://api.example.com/data/2", 1),
        fetch_data("https://api.example.com/data/3", 1.5),
    ]
    results = await asyncio.gather(*tasks)
    for r in results:
        print(r)

# 运行事件循环
start = time.time()
asyncio.run(main())
print(f"asyncio 总耗时: {time.time() - start:.2f}s")''',
            language: 'Python',
          ),
          const OutputBox(
            '开始获取 https://api.example.com/data/1\n'
            '开始获取 https://api.example.com/data/2\n'
            '开始获取 https://api.example.com/data/3\n'
            '完成获取 https://api.example.com/data/2\n'
            '完成获取 https://api.example.com/data/3\n'
            '完成获取 https://api.example.com/data/1\n'
            'asyncio 总耗时: 2.00s',
          ),
          const Paragraph(
            'asyncio vs threading vs multiprocessing：\n'
            '  • 并发单位：协程（user-space）vs OS 线程 vs OS 进程\n'
            '  • 切换方式：主动 await 切换 vs 抢占式切换 vs 抢占式切换\n'
            '  • 内存开销：极低（数千协程） vs 中等（数百线程） vs 高（数十进程）\n'
            '  • CPU 利用：单核 vs 单核（受 GIL 限制） vs 多核\n'
            '  • 适用场景：高并发网络连接 vs 同步 I/O vs 计算密集\n'
            '  • 代码复杂度：需要 async/await 语法 vs 传统同步 vs 传统同步\n'
            '  • 生态兼容：需要异步库支持 vs 兼容几乎所有同步库',
          ),
          const Paragraph(
            '如何选择：\n'
            '  • 高并发网络服务（WebSocket、API 网关）→ asyncio\n'
            '  • 文件/数据库 I/O（同步库为主）→ threading\n'
            '  • CPU 密集型计算 → multiprocessing\n'
            '  • 混合场景 → 多进程 + 每个进程内 asyncio 或线程',
          ),
          const CodeBlock(
            r'''import asyncio
import time

# ===== 混合示例：asyncio + 线程池 =====
# 在事件循环中将阻塞操作委托给线程池

async def main_with_blocking():
    loop = asyncio.get_running_loop()

    # 在线程池中执行阻塞的 CPU 计算
    result = await loop.run_in_executor(
        None,  # 使用默认线程池
        lambda: sum(i * i for i in range(1000000))
    )
    print(f"计算结果: {result}")

    # 并发执行多个阻塞任务
    tasks = [
        loop.run_in_executor(None, time.sleep, 1),
        loop.run_in_executor(None, time.sleep, 2),
    ]
    await asyncio.gather(*tasks)
    print("所有阻塞任务完成")

asyncio.run(main_with_blocking())

# 更强大的组合：多进程 + 每个进程 asyncio
# 让每个 CPU 核运行一个事件循环处理网络请求
# 进程数量 = CPU 核心数，每个进程内 asyncio 处理数千连接''',
            language: 'Python',
          ),
          const TipBox(
            '在 async 函数中调用阻塞代码会阻塞整个事件循环。'
            '应使用 loop.run_in_executor() 将阻塞操作委托给线程池处理。'
            '对于 CPU 密集型，应使用 ProcessPoolExecutor。',
            type: TipType.caution,
          ),
          const DividerLine(),

          // ===== 23. Common pitfalls & best practices =====
          const SectionHeader('23. 常见陷阱与最佳实践', icon: Icons.warning_amber),
          const Paragraph(
            '多线程编程容易出错，以下几类问题最常见：',
          ),
          const Paragraph(
            '竞态条件（Race Condition）：\n'
            '多个线程同时读写共享变量，结果依赖执行顺序。'
            '解决方法：使用 Lock 或 Queue 保证原子性。',
          ),
          const Paragraph(
            '死锁（Deadlock）：\n'
            '两个线程互相等待对方释放锁。避免方法：\n'
            '  • 按固定顺序获取锁（lock ordering）\n'
            '  • 使用 with 语句自动释放\n'
            '  • 使用 acquire(timeout) 超时处理',
          ),
          const Paragraph(
            '活锁（Livelock）：\n'
            '线程不断尝试获取资源但总是放弃，形成忙等待。'
            '解决方法：引入随机退避（random backoff）。',
          ),
          const Paragraph(
            '饥饿（Starvation）：\n'
            '低优先级线程一直得不到执行。解决方法：使用公平锁或调整优先级。',
          ),
          const CodeBlock(
            r'''import threading

# ===== 死锁示例 =====
lock_a = threading.Lock()
lock_b = threading.Lock()

def thread_1():
    with lock_a:
        print("T1 获取锁 A")
        threading.Event().wait(0.1)
        with lock_b:          # 需要锁 B
            print("T1 获取锁 B")

def thread_2():
    with lock_b:
        print("T2 获取锁 B")
        threading.Event().wait(0.1)
        with lock_a:          # 需要锁 A —— 死锁！
            print("T2 获取锁 A")

t1 = threading.Thread(target=thread_1)
t2 = threading.Thread(target=thread_2)
t1.start()
t2.start()
t1.join(timeout=2)
t2.join(timeout=2)
print("可能发生死锁，程序卡住！")

# 解决方法：固定获取顺序
# 所有线程都先拿 lock_a 再拿 lock_b''',
            language: 'Python',
          ),
          const TipBox(
            '实用的死锁检测：threading.enumerate() 列出所有线程，'
            '检查是否有线程长时间处于 alive 状态。'
            '更专业的方法是用 faulthandler 模块打印线程堆栈。',
            type: TipType.tip,
          ),
          const Paragraph(
            '线程/进程的优雅关闭模式：',
          ),
          const CodeBlock(
            r'''import threading
import signal

class GracefulShutdown:
    """优雅关闭管理器"""

    def __init__(self):
        self.shutdown_event = threading.Event()
        self.workers = []

    def worker(self, name):
        """工作线程——监听关闭信号"""
        while not self.shutdown_event.is_set():
            print(f"[{name}] 工作中...")
            self.shutdown_event.wait(timeout=1)
        print(f"[{name}] 收到关闭信号，清理资源...")
        # 清理：关闭文件、提交事务、释放连接
        print(f"[{name}] 已关闭")

    def signal_handler(self, sig, frame):
        """处理 SIGINT/SIGTERM"""
        print("\n收到关闭信号，正在停止所有线程...")
        self.shutdown_event.set()

    def run(self):
        """启动工作线程并等待关闭"""
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)

        for i in range(3):
            t = threading.Thread(
                target=self.worker,
                args=(f"Worker-{i}",),
                daemon=True
            )
            self.workers.append(t)
            t.start()

        # 等待关闭信号
        self.shutdown_event.wait()
        print("所有资源已清理，程序退出")

if __name__ == "__main__":
    app = GracefulShutdown()
    app.run()''',
            language: 'Python',
          ),
          const Paragraph(
            '最佳实践总结：\n'
            '  • 始终使用 with 语句管理锁、线程池和进程池\n'
            '  • 使用 Event 或 Queue 哨兵值实现优雅退出\n'
            '  • 避免死锁：固定加锁顺序，使用 acquire(timeout)\n'
            '  • 避免线程泄漏：跟踪所有启动的线程，确保 join()\n'
            '  • 使用 logging 替代 print，日志模块线程安全\n'
            '  • 共享数据优先使用 Queue 而非共享变量\n'
            '  • 进程池中避免传递不可 pickle 的对象\n'
            '  • 使用 TLS（threading.local()）保存线程私有数据\n'
            '  • 始终为线程/进程设置有意义的名称\n'
            '  • 监控线程数量，防止无限创建',
          ),
          const DividerLine(),

          // ===== 24. Practical examples =====
          const SectionHeader('24. 实战案例', icon: Icons.build_outlined),
          const Paragraph(
            '以下是两个经典的多线程实战案例：并行文件下载器和并发 Web 爬虫。',
          ),
          const Paragraph(
            '案例一：并行文件下载器',
          ),
          const CodeBlock(
            r'''import threading
import time
import random

class ParallelDownloader:
    """模拟并行文件下载器"""

    def __init__(self, max_workers=3):
        self.max_workers = max_workers
        self.semaphore = threading.Semaphore(max_workers)
        self.results = {}
        self.lock = threading.Lock()

    def download(self, file_id, size_mb):
        """模拟下载单个文件"""
        with self.semaphore:      # 限制并发数
            speed_mbps = random.uniform(2, 10)
            time_needed = size_mb / speed_mbps
            print(f"  [下载 #{file_id}] {size_mb}MB, "
                  f"速度 {speed_mbps:.1f}MB/s, "
                  f"预计 {time_needed:.1f}s")
            time.sleep(time_needed)

            with self.lock:       # 保护共享数据
                self.results[file_id] = {
                    "size": size_mb,
                    "time": round(time_needed, 2),
                    "speed": round(speed_mbps, 2),
                }
            print(f"  [下载 #{file_id}] 完成！")
            return file_id

    def run(self, files):
        """files: [(id, size_mb), ...]"""
        threads = []
        for fid, size in files:
            t = threading.Thread(
                target=self.download,
                args=(fid, size),
                name=f"DL-{fid}"
            )
            t.start()
            threads.append(t)

        for t in threads:
            t.join()

        total_size = sum(r["size"] for r in self.results.values())
        total_time = max(r["time"] for r in self.results.values())
        print(f"\n汇总: 下载 {len(files)} 个文件, "
              f"共 {total_size}MB, "
              f"耗时 {total_time:.1f}s")

# 运行下载器
files = [(i, random.randint(5, 50)) for i in range(6)]
downloader = ParallelDownloader(max_workers=3)
downloader.run(files)''',
            language: 'Python',
          ),
          const Paragraph(
            '案例二：并发 Web 爬虫框架',
          ),
          const CodeBlock(
            r'''from concurrent.futures import ThreadPoolExecutor
import time
import random
import threading

class ConcurrentCrawler:
    """简易并发爬虫框架"""

    def __init__(self, max_workers=5):
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
        self.visited = set()
        self.lock = threading.Lock()

    def fetch(self, url):
        """模拟获取网页"""
        delay = random.uniform(0.3, 1.0)
        time.sleep(delay)
        # 模拟页面包含的链接
        subs = [f"{url}/page{i}" for i in range(random.randint(1, 3))]
        return url, delay, subs

    def crawl(self, start_url, max_pages=10):
        """爬取入口"""
        to_visit = [start_url]
        results = []

        while to_visit and len(self.visited) < max_pages:
            batch = []
            with self.lock:
                for url in to_visit:
                    if url not in self.visited and len(batch) < self.executor._max_workers:
                        self.visited.add(url)
                        batch.append(url)
                to_visit.clear()

            if not batch:
                break

            # 批量提交抓取任务
            futures = [self.executor.submit(self.fetch, url) for url in batch]
            for future in futures:
                url, delay, subs = future.result()
                results.append((url, delay))
                print(f"[抓取] {url} ({delay:.2f}s)")
                to_visit.extend(subs)

        print(f"\n完成! 共抓取 {len(results)} 个页面")
        return results

crawler = ConcurrentCrawler(max_workers=3)
crawler.crawl("https://example.com", max_pages=5)''',
            language: 'Python',
          ),
          const DividerLine(),

          // ===== 25. Debugging =====
          const SectionHeader('25. 调试与日志', icon: Icons.bug_report),
          const Paragraph(
            '多线程调试的难点在于非确定性——每次运行可能不同。'
            '使用 logging 模块（线程安全）替代 print()，'
            '配合线程名可以清晰地追踪问题。',
          ),
          const CodeBlock(
            r'''import logging
import threading
import time

# 配置线程安全的日志系统
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(threadName)s] %(levelname)s: %(message)s",
    datefmt="%H:%M:%S.%f",
)
logger = logging.getLogger(__name__)

def buggy_worker():
    """有 bug 的工作线程"""
    logger.info("开始工作")
    try:
        # 模拟可能的错误
        if threading.current_thread().name == "Worker-2":
            raise ValueError("模拟错误：Worker-2 出问题")
        time.sleep(0.5)
        logger.info("工作完成")
    except Exception as e:
        logger.error(f"发生异常: {e}", exc_info=True)

# 启动多个线程
threads = [
    threading.Thread(target=buggy_worker, name=f"Worker-{i}")
    for i in range(4)
]

for t in threads: t.start()
for t in threads: t.join()

logger.info("所有线程结束，检查上面的日志")

# ===== 诊断工具 =====
def dump_thread_info():
    """打印所有线程的详细信息"""
    print(f"\n活跃线程数: {threading.active_count()}")
    for t in threading.enumerate():
        print(f"  {t.name}: ident={t.ident}, "
              f"alive={t.is_alive()}, daemon={t.daemon}")

dump_thread_info()

# 使用 faulthandler 打印线程堆栈
import faulthandler
faulthandler.dump_traceback_later(30)  # 30秒后打印堆栈''',
            language: 'Python',
          ),
          const Paragraph(
            '调试技巧：\n'
            '  • 用 logging 替代 print —— 日志模块是线程安全的\n'
            '  • 设置 threadName 格式器 —— 知道哪个线程在打日志\n'
            '  • 启用 exc_info=True —— 捕获完整异常堆栈\n'
            '  • threading.enumerate() —— 检查线程存活状态\n'
            '  • faulthandler.dump_traceback() —— 死锁时打印堆栈\n'
            '  • 使用锁时记录 acquire/release 日志',
          ),
          const TipBox(
            '开发阶段用 logging.DEBUG 级别记录所有线程操作。'
            '出现死锁或数据不一致时，完整日志是最有价值的诊断线索。',
            type: TipType.tip,
          ),
          const DividerLine(),

          // ===== Summary =====
          const SectionHeader('本章小结', icon: Icons.summarize),
          const Paragraph(
            'Python 多线程和多进程是并发编程的核心工具。核心要点：\n'
            '  • GIL 限制了 CPU 密集型任务的多线程效率，I/O 密集型是主战场\n'
            '  • 线程同步是必须的——用 Lock、RLock、Semaphore 保护共享资源\n'
            '  • Condition、Event、Barrier 实现了高级线程协作\n'
            '  • Queue 是线程安全的，优先用它传递数据\n'
            '  • ThreadPoolExecutor 比手动管理线程更优雅\n'
            '  • 多进程绕开 GIL，但进程间通信成本高\n'
            '  • Manager 提供方便的进程间共享数据结构\n'
            '  • asyncio 协程适合高并发 I/O，与线程/进程互补\n'
            '  • logging 是调试并发程序的第一选择',
          ),
          const Paragraph(
            '两条黄金法则：\n'
            '1. 尽可能避免共享状态 —— 用 Queue 传递消息\n'
            '2. 必须共享时，用 with lock 保护 —— 别手动 acquire/release',
          ),
          const DividerLine(),

          // ===== Exercises =====
          const SectionHeader('本章练习', icon: Icons.edit_note),
          const StepItem(
            step: 1,
            title: '线程安全的计数器',
            description: '实现一个支持多线程并发递增的计数器类，使用 Lock 保证准确性。对比有锁和无锁两种情况下的结果。',
          ),
          const StepItem(
            step: 2,
            title: '简易任务调度器',
            description: '使用 Queue 和 ThreadPoolExecutor 实现一个任务调度器，支持提交任务、查询状态、取消未执行任务。',
          ),
          const StepItem(
            step: 3,
            title: '多线程下载管理器',
            description: '模仿实战案例的 ParallelDownloader，支持暂停/恢复、断点续传、进度回调。支持限制最大并发数。',
          ),
          const StepItem(
            step: 4,
            title: '生产者-消费者-分析器',
            description: '扩展经典的生产者-消费者模式，加入第三个角色"分析器"：生产者生成数据，消费者消费并放入分析队列，分析器做汇总统计。',
          ),
          const StepItem(
            step: 5,
            title: '多进程质数计算器',
            description: '使用 ProcessPoolExecutor 并行计算 1~100000 之间的所有质数。对比单线程、多线程、多进程三种方案的性能差异。',
          ),
          const StepItem(
            step: 6,
            title: '分布式任务分配',
            description: '使用 multiprocessing.Manager 实现一个简单的分布式任务系统，一个进程分配任务，多个进程执行并返回结果。',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
