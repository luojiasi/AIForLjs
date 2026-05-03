import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ─────────────────────────────────────────────────────────────
// 交互式演示组件
// ─────────────────────────────────────────────────────────────

/// Future 状态机演示：模拟异步任务的 pending→fulfilled/rejected 状态变化
class _FutureStateDemo extends StatefulWidget {
  const _FutureStateDemo();
  @override
  State<_FutureStateDemo> createState() => _FutureStateDemoState();
}

class _FutureStateDemoState extends State<_FutureStateDemo> {
  int _delaySeconds = 2;
  bool _shouldFail = false;
  String _state = 'idle'; // idle | pending | fulfilled | rejected
  String _result = '';

  void _runFuture() {
    setState(() { _state = 'pending'; _result = ''; });
    Future.delayed(Duration(seconds: _delaySeconds), () {
      if (!mounted) return;
      if (_shouldFail) {
        setState(() { _state = 'rejected'; _result = 'Exception: 网络请求失败'; });
      } else {
        setState(() { _state = 'fulfilled'; _result = '{"user": "张三", "age": 25}'; });
      }
    });
  }

  Color get _stateColor => switch (_state) {
    'pending' => Colors.orange,
    'fulfilled' => Colors.green,
    'rejected' => Colors.red,
    _ => Colors.grey,
  };

  String get _stateLabel => switch (_state) {
    'pending' => 'Pending（等待中）',
    'fulfilled' => 'Fulfilled（已完成）',
    'rejected' => 'Rejected（已拒绝）',
    _ => 'Idle（未开始）',
  };

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '⏳ Future 状态机演示',
      subtitle: '点击"执行"观察 Future 从 pending → fulfilled/rejected 的状态变化',
      children: [
        ParamIntSlider(label: '延迟时间', value: _delaySeconds, min: 1, max: 5, unit: ' 秒',
          onChanged: (v) => setState(() => _delaySeconds = v)),
        ParamSwitch(label: '模拟失败', value: _shouldFail, onChanged: (v) => setState(() => _shouldFail = v),
          trueLabel: '失败', falseLabel: '成功'),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _stateColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _stateColor.withOpacity(0.5), width: 2),
          ),
          child: Row(children: [
            if (_state == 'pending')
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(
                _state == 'fulfilled' ? Icons.check_circle : _state == 'rejected' ? Icons.error : Icons.circle_outlined,
                color: _stateColor, size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_stateLabel, style: TextStyle(fontWeight: FontWeight.bold, color: _stateColor)),
              if (_result.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_result, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: _stateColor)),
              ],
            ])),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: _state == 'pending' ? null : _runFuture,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: Text(_state == 'pending' ? '执行中...' : '▶ 执行 Future'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() { _state = 'idle'; _result = ''; }),
            child: const Text('重置'),
          ),
        ]),
        LiveCodeBlock(
          'Future<String> fetchUser() async {\n'
          '  await Future.delayed(Duration(seconds: $_delaySeconds));\n'
          '  ${_shouldFail ? 'throw Exception("网络请求失败");' : 'return \'{"user": "张三", "age": 25}\';'}\n'
          '}\n\n'
          'try {\n'
          '  final result = await fetchUser();\n'
          '  print(result);   // ${_state == 'fulfilled' ? _result : '...'}\n'
          '} catch (e) {\n'
          '  print("错误: \$e");\n'
          '}',
        ),
      ],
    );
  }
}

/// Stream 数据流可视化演示
class _StreamVisualizationDemo extends StatefulWidget {
  const _StreamVisualizationDemo();
  @override
  State<_StreamVisualizationDemo> createState() => _StreamVisualizationDemoState();
}

class _StreamVisualizationDemoState extends State<_StreamVisualizationDemo> {
  int _interval = 1;
  int _count = 5;
  String _transform = 'none'; // none | map | where
  List<int> _emitted = [];
  List<int> _received = [];
  bool _running = false;
  StreamSubscription<int>? _sub;
  int _mapFactor = 2;

  List<int> _applyTransform(List<int> source) {
    switch (_transform) {
      case 'map': return source.map((n) => n * _mapFactor).toList();
      case 'where': return source.where((n) => n % 2 == 0).toList();
      default: return source;
    }
  }

  void _startStream() {
    setState(() { _emitted = []; _received = []; _running = true; });
    int emitted = 0;
    _sub = Stream.periodic(Duration(seconds: _interval), (i) => i + 1)
        .take(_count)
        .listen((value) {
          if (!mounted) return;
          setState(() {
            _emitted.add(value);
            final transformed = _applyTransform([value]);
            _received.addAll(transformed);
          });
          emitted++;
          if (emitted >= _count) setState(() => _running = false);
        });
  }

  void _stop() {
    _sub?.cancel();
    setState(() => _running = false);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: '🌊 Stream 数据流可视化',
      subtitle: '实时观察 Stream 发出和接收数据的过程',
      children: [
        ParamIntSlider(label: '发射间隔', value: _interval, min: 1, max: 3, unit: ' 秒',
          onChanged: (v) { if (!_running) setState(() => _interval = v); }),
        ParamIntSlider(label: '总数量', value: _count, min: 3, max: 8,
          onChanged: (v) { if (!_running) setState(() => _count = v); }),
        ParamChoiceChips<String>(
          label: '变换操作',
          value: _transform,
          options: [('none', '无'), ('map', '.map(×$_mapFactor)'), ('where', '.where(偶数)')],
          onChanged: (v) { if (!_running) setState(() => _transform = v); },
        ),
        if (_transform == 'map')
          ParamIntSlider(label: '乘法因子', value: _mapFactor, min: 2, max: 5,
            onChanged: (v) => setState(() => _mapFactor = v)),
        const SizedBox(height: 8),
        // 可视化：已发射 + 已接收
        if (_emitted.isNotEmpty) ...[
          Row(children: [
            const Text('发射：', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Expanded(child: Wrap(spacing: 4, children: _emitted.map((n) =>
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.7), shape: BoxShape.circle),
                child: Center(child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
              )
            ).toList())),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('接收：', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            Expanded(child: Wrap(spacing: 4, children: _received.map((n) =>
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Center(child: Text('$n', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold))),
              )
            ).toList())),
          ]),
        ],
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: _running ? null : _startStream,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: Text(_running ? '运行中...' : '▶ 启动 Stream'),
          ),
          const SizedBox(width: 8),
          if (_running) TextButton.icon(
            onPressed: _stop,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('停止'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() { _emitted = []; _received = []; }),
            child: const Text('清空'),
          ),
        ]),
        LiveCodeBlock(
          'final stream = Stream.periodic(\n'
          '  Duration(seconds: $_interval), (i) => i + 1,\n'
          ').take($_count)'
          '${_transform == 'map' ? '.map((n) => n * $_mapFactor)' : _transform == 'where' ? '.where((n) => n % 2 == 0)' : ''};\n\n'
          'await for (final value in stream) {\n'
          '  print(value);  // ${_received.isEmpty ? '...' : _received.join(', ')}\n'
          '}',
        ),
      ],
    );
  }
}

/// Dart 异步编程教程页面
/// 涵盖：事件循环、Future、async/await、Stream、async* 生成器、await for、Isolate
class DartAsync extends StatelessWidget {
  const DartAsync({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第6章 · 异步编程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('异步编程让程序在执行耗时操作时不阻塞界面。Dart 是单线程模型，'
              '通过事件循环（Event Loop）和微任务队列实现异步。'
              '本章深入讲解 Future、Stream、async/await、async* 生成器和 Isolate。'),

          // ============================================================
          // 1. 事件循环
          // ============================================================
          SectionHeader('1. 事件循环与队列', icon: Icons.loop),
          Paragraph('Dart 的事件循环维护两个队列：微任务队列（Microtask Queue）'
              '和事件队列（Event Queue）。微任务优先级高，事件队列处理 IO、'
              '定时器、用户交互等事件。每次事件循环先处理完所有微任务再处理事件。'),
          CodeBlock(r'''
import 'dart:async';

void main() {
  print('1. 同步代码开始');

  // Future()：加入事件队列（优先级低）
  Future(() => print('2. 事件队列 Future'));

  // scheduleMicrotask：加入微任务队列（优先级高）
  scheduleMicrotask(() => print('3. 微任务'));

  // Future.microtask：也加入微任务队列
  Future.microtask(() => print('4. 另一个微任务'));

  // Future.delayed：加入事件队列，延迟执行
  Future.delayed(Duration.zero, () => print('5. 延迟事件'));

  print('6. 同步代码结束');
  // 执行顺序：同步代码 > 微任务 > 事件队列
}
''', language: 'Dart'),
          OutputBox('1. 同步代码开始\n6. 同步代码结束\n3. 微任务\n'
              '4. 另一个微任务\n2. 事件队列 Future\n5. 延迟事件'),
          TipBox('执行优先级：同步代码 > 微任务队列 > 事件队列。'
              '每次事件循环中，微任务队列会被完全清空后才会处理事件队列。'
              '过多微任务会导致事件队列"饿死"，UI 无法响应用户操作。',
              type: TipType.warning),

          // ============================================================
          // 2. Future 详解
          // ============================================================
          SectionHeader('2. Future 详解', icon: Icons.hourglass_empty),
          Paragraph('Future 表示一个未来会完成的异步任务，有三种状态：未完成、'
              '已完成（有值）、已失败（有错误）。'
              'Dart 提供多种 Future 创建方式，满足不同场景。'),
          CodeBlock(r'''
import 'dart:async';

void main() {
  // Future.value：直接返回一个已完成的值
  Future.value('立即成功').then((v) {
    print('value: $v');
  });

  // Future.error：直接返回一个错误
  Future.error('出错了').catchError((e) {
    print('error: $e');
  });

  // Future.delayed：延迟指定时间后执行
  Future.delayed(Duration(seconds: 1), () {
    return '1 秒后返回';
  }).then((v) => print(v));

  // Future.microtask：放入微任务队列，优先执行
  Future.microtask(() {
    print('微任务优先');
    return '微任务结果';
  }).then((v) => print(v));

  // Future.sync：同步执行函数体，但包装为 Future 返回
  Future.sync(() {
    print('同步执行（在 then 注册前就执行了）');
    return '包裹成 Future';
  }).then((v) => print(v));

  // Future 的状态
  var future = Future.value(42);
  print('Future 类型: ${future.runtimeType}');
}
''', language: 'Dart'),
          OutputBox('value: 立即成功\nerror: 出错了\n同步执行（在 then 注册前就执行了）\n'
              '微任务优先\n微任务结果\n1 秒后返回\n包裹成 Future'),

          // ============================================================
          // 3. async/await
          // ============================================================
          SectionHeader('3. async/await', icon: Icons.accessible),
          Paragraph('async 标记函数为异步函数，自动返回 Future。'
              'await 暂停当前 async 函数直到 Future 完成，但不阻塞线程。'
              'async/await 让异步代码看起来像同步代码，是最推荐的写法。'),
          CodeBlock(r'''
import 'dart:async';

// 模拟网络请求
Future<String> fetchUserData() async {
  print('  开始获取用户数据...');
  await Future.delayed(Duration(seconds: 1));  // 模拟网络延迟
  return '用户数据';
}

Future<String> fetchOrders() async {
  print('  开始获取订单数据...');
  await Future.delayed(Duration(milliseconds: 800));
  return '订单数据';
}

// async 函数返回 Future<void>
Future<void> loadDashboard() async {
  print('加载面板开始');

  // await 暂停当前函数，线程可以去处理其他任务
  String user = await fetchUserData();
  print('用户数据到达: $user');

  String orders = await fetchOrders();
  print('订单数据到达: $orders');

  print('面板加载完成');
}

// async 函数内部可以混用同步和异步代码
Future<int> calculateSum(int a, int b) async {
  // 同步计算
  int sum = a + b;
  // 模拟异步
  await Future.delayed(Duration(milliseconds: 100));
  return sum;  // 自动包裹成 Future<int>
}

void main() async {
  print('主程序开始');

  // await 只能在 async 函数中使用
  await loadDashboard();

  var sum = await calculateSum(10, 20);
  print('计算结果: $sum');  // 30

  print('主程序结束');
}
''', language: 'Dart'),
          OutputBox('主程序开始\n加载面板开始\n'
              '  开始获取用户数据...\n用户数据到达: 用户数据\n'
              '  开始获取订单数据...\n订单数据到达: 订单数据\n'
              '面板加载完成\n计算结果: 30\n主程序结束'),

          // ============================================================
          // 4. 错误处理
          // ============================================================
          SectionHeader('4. 错误处理', icon: Icons.error_outline),
          Paragraph('异步错误处理有两种方式：try/catch（配合 async/await）'
              '和 catchError（链式调用）。推荐用 try/catch 更直观，'
              '支持 on 关键字捕获特定类型异常，finally 确保清理资源。'),
          CodeBlock(r'''
import 'dart:async';

// 可能会失败的异步函数
Future<String> fetchData({required bool shouldFail}) async {
  await Future.delayed(Duration(milliseconds: 300));

  if (shouldFail) {
    throw Exception('网络连接失败');
  }
  return '数据加载成功';
}

// 方式一：try/catch（推荐）
Future<void> loadWithTryCatch() async {
  try {
    print('开始请求...');
    String data = await fetchData(shouldFail: true);
    print('成功: $data');
  } on Exception catch (e) {
    // 仅捕获 Exception 类型的异常
    print('捕获异常: $e');
  } catch (e, stackTrace) {
    // 捕获所有异常（包括非 Exception 类型）
    print('未知错误: $e');
    print('堆栈: $stackTrace');
  } finally {
    // 无论如何都会执行
    print('清理资源（关闭连接、释放内存等）');
  }
}

// 方式二：catchError 链式调用
void loadWithCatchError() {
  fetchData(shouldFail: true)
      .then((data) {
        print('成功: $data');
      })
      .catchError((e) {
        print('链式捕获: $e');
      })
      .whenComplete(() {
        print('链式清理（类似 finally）');
      });
}

// 多个 Future 的错误处理
Future<void> multipleFutures() async {
  try {
    var results = await Future.wait([
      fetchData(shouldFail: false),
      fetchData(shouldFail: true),  // 这个会失败
      fetchData(shouldFail: false),
    ]);
    print('全部成功: $results');
  } catch (e) {
    print('至少一个 Future 失败: $e');
  }
}

void main() async {
  print('--- try/catch 方式 ---');
  await loadWithTryCatch();

  print('\n--- catchError 方式 ---');
  loadWithCatchError();

  // 确保 catchError 的 Future 完成
  await Future.delayed(Duration(milliseconds: 500));

  print('\n--- 多个 Future ---');
  await multipleFutures();
}
''', language: 'Dart'),
          OutputBox('--- try/catch 方式 ---\n开始请求...\n'
              '捕获异常: Exception: 网络连接失败\n清理资源（关闭连接、释放内存等）\n\n'
              '--- catchError 方式 ---\n链式捕获: Exception: 网络连接失败\n'
              '链式清理（类似 finally）\n\n'
              '--- 多个 Future ---\n至少一个 Future 失败: Exception: 网络连接失败'),
          TipBox('catchError 只捕获它之前的 then 链中的错误。'
              '如果 catchError 本身后面还有 then，那个 then 的错误需要另一个 catchError。'
              '建议用 try/catch 让代码更清晰，调试更方便。', type: TipType.tip),

          // ============================================================
          // 5. Stream
          // ============================================================
          SectionHeader('5. Stream —— 数据流', icon: Icons.waves),
          Paragraph('Stream 像管道——数据源源不断地流过来。'
              '单订阅 Stream（Single-subscription）只能有一个监听者，'
              '广播 Stream（Broadcast）可以有多个监听者。'
              'StreamController 可以手动控制数据的推送。'),
          CodeBlock(r'''
import 'dart:async';

// async* 创建单订阅 Stream
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i;  // 产出一个值
  }
}

// 广播 Stream：多个监听者可以同时监听
Stream<int> createTimerStream(int max) {
  final controller = StreamController<int>.broadcast();

  // 在 Future 中异步推送数据
  Future(() async {
    for (int i = 1; i <= max; i++) {
      controller.add(i);
      await Future.delayed(Duration(milliseconds: 200));
    }
    controller.close();  // 关闭流
  });

  return controller.stream;
}

void main() {
  // 单订阅 Stream：只能有一个监听者
  print('--- 单订阅 Stream ---');
  var singleStream = countStream(3);
  singleStream.listen(
    (data) => print('收到: $data'),   // 每次收到数据触发
    onError: (e) => print('错误: $e'), // 错误处理
    onDone: () => print('流结束'),     // 流结束时触发
    cancelOnError: false,              // 发生错误是否自动取消
  );

  // 广播 Stream：可以多个监听者
  print('\n--- 广播 Stream ---');
  var broadcastStream = createTimerStream(3);
  broadcastStream.listen((d) => print('监听者1: $d'));
  broadcastStream.listen((d) => print('监听者2: $d'));
}
''', language: 'Dart'),
          OutputBox('--- 单订阅 Stream ---\n收到: 1\n收到: 2\n收到: 3\n流结束\n\n'
              '--- 广播 Stream ---\n监听者1: 1\n监听者2: 1\n'
              '监听者1: 2\n监听者2: 2\n'
              '监听者1: 3\n监听者2: 3'),

          // ============================================================
          // 6. Stream 常用方法
          // ============================================================
          SectionHeader('6. Stream 常用方法', icon: Icons.transform),
          Paragraph('Stream 和 Iterable 一样支持 map、where、distinct、take 等'
              '转换方法。transform 可以使用 StreamTransformer 进行更复杂的转换。'
              '这些方法返回新的 Stream，可以链式调用。'),
          CodeBlock(r'''
import 'dart:async';

// 基础数据源：1 秒生成一个值
Stream<int> numberStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(milliseconds: 100));
    yield i;
  }
}

void main() async {
  // map：转换每个元素
  print('--- map 翻倍 ---');
  var doubled = numberStream(5).map((n) => n * 2);
  await for (var v in doubled) {
    print('翻倍: $v');  // 2, 4, 6, 8, 10
  }

  // where：筛选符合条件的元素
  print('\n--- where 偶数 ---');
  var evens = numberStream(8).where((n) => n.isEven);
  await for (var v in evens) {
    print('偶数: $v');  // 2, 4, 6, 8
  }

  // distinct：去重连续重复的值
  print('\n--- distinct 去重 ---');
  var repeat = Stream.fromIterable([1, 1, 2, 2, 2, 3, 1]);
  await for (var v in repeat.distinct()) {
    print('去重: $v');  // 1, 2, 3, 1（只去连续重复）
  }

  // take：取前 N 个
  print('\n--- take 前 3 个 ---');
  var first3 = numberStream(10).take(3);
  await for (var v in first3) {
    print(v);  // 1, 2, 3
  }

  // skip：跳过前 N 个
  print('\n--- skip 前 3 个 ---');
  var after3 = numberStream(6).skip(3);
  await for (var v in after3) {
    print(v);  // 4, 5, 6
  }

  // transform：使用 StreamTransformer
  print('\n--- transform ---');
  var transformer = StreamTransformer<int, String>.fromHandlers(
    handleData: (value, sink) {
      sink.add('数字: $value');
    },
  );
  var transformed = numberStream(3).transform(transformer);
  await for (var v in transformed) {
    print(v);  // 数字: 1, 数字: 2, 数字: 3
  }
}
''', language: 'Dart'),
          OutputBox('--- map 翻倍 ---\n翻倍: 2\n翻倍: 4\n翻倍: 6\n翻倍: 8\n翻倍: 10\n\n'
              '--- where 偶数 ---\n偶数: 2\n偶数: 4\n偶数: 6\n偶数: 8\n\n'
              '--- distinct 去重 ---\n去重: 1\n去重: 2\n去重: 3\n去重: 1\n\n'
              '--- take 前 3 个 ---\n1\n2\n3\n\n'
              '--- skip 前 3 个 ---\n4\n5\n6\n\n'
              '--- transform ---\n数字: 1\n数字: 2\n数字: 3'),

          // ============================================================
          // 7. async* 生成器与 await for
          // ============================================================
          SectionHeader('7. async* 生成器与 await for', icon: Icons.generating_tokens),
          Paragraph('async* 函数可以多次 yield 值，生成一个 Stream。'
              'await for 循环依次消费 Stream 的每个值。两者配合使用'
              '让 Stream 编程像同步 for 循环一样直观。yield* 可以委托给另一个生成器。'),
          CodeBlock(r'''
import 'dart:async';

// async* 生成器：用 yield 产生多个值
Stream<String> createCountdown(int seconds) async* {
  for (int i = seconds; i > 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield '倒计时: $i 秒';  // yield 产出一个值
  }
  yield '时间到！';        // 最后一个值
}

// await for：消费 Stream 的值
Future<void> runCountdown() async {
  print('倒计时开始');

  // await for 遍历 Stream，每次等待一个值到达
  await for (final message in createCountdown(3)) {
    print('  $message');
  }

  print('倒计时结束');
}

// yield*：委托给另一个 Stream
Stream<int> mainStream() async* {
  yield 1;
  yield 2;

  // yield* 将 subStream 的所有值"展开"插入到这里
  yield* subStream();

  yield 5;
}

Stream<int> subStream() async* {
  yield 3;
  yield 4;
}

// 定期产生值的生成器
Stream<int> periodicCounter(int intervalMs) async* {
  int count = 0;
  while (true) {
    await Future.delayed(Duration(milliseconds: intervalMs));
    yield ++count;
  }
}

void main() async {
  // await for
  await runCountdown();

  // yield* 委托
  print('\n--- yield* 委托 ---');
  await for (var v in mainStream()) {
    print('值: $v');  // 1, 2, 3, 4, 5
  }

  // 使用 break 终止无限 Stream
  print('\n--- 有限消费无限 Stream ---');
  var counter = periodicCounter(200);
  int i = 0;
  await for (var v in counter) {
    print('计数: $v');
    i++;
    if (i >= 3) break;  // 取前 3 个后退出
  }
}
''', language: 'Dart'),
          OutputBox('倒计时开始\n  倒计时: 3 秒\n  倒计时: 2 秒\n'
              '  倒计时: 1 秒\n  时间到！\n倒计时结束\n\n'
              '--- yield* 委托 ---\n值: 1\n值: 2\n值: 3\n值: 4\n值: 5\n\n'
              '--- 有限消费无限 Stream ---\n计数: 1\n计数: 2\n计数: 3'),

          // ============================================================
          // 8. Isolate
          // ============================================================
          SectionHeader('8. Isolate —— 并行计算', icon: Icons.memory),
          Paragraph('Isolate 是 Dart 的并行方案。每个 Isolate 有独立的内存和事件循环，'
              '不共享变量，通过消息传递通信。Isolate.spawn 创建新 Isolate，'
              'ReceivePort/SendPort 在 Isolate 间传递消息。'
              'Flutter 的 compute() 函数简化了 Isolate 的使用。'),
          CodeBlock(r'''
import 'dart:async';
import 'dart:isolate';

// ---- 方式一：Isolate.spawn ----
// 在另一个 Isolate 中执行的函数（必须是顶层函数或静态方法）
void calculateSum(SendPort sendPort) {
  // 执行耗时计算
  int sum = 0;
  for (int i = 0; i <= 100000000; i++) {
    sum += i;
  }
  // 通过 SendPort 发送结果到主 Isolate
  sendPort.send(sum);
}

Future<int> runInIsolate() async {
  // 创建 ReceivePort：主 Isolate 用来接收消息
  ReceivePort receivePort = ReceivePort();

  // spawn 启动新 Isolate，传入 SendPort
  await Isolate.spawn(calculateSum, receivePort.sendPort);

  // 等待第一个消息（阻塞当前 async 函数）
  int result = await receivePort.first as int;

  // 关闭 ReceivePort 释放资源
  receivePort.close();
  return result;
}

// ---- 方式二：传递参数 ----
void calculateWithParam(List<dynamic> args) {
  SendPort sendPort = args[0] as SendPort;
  int max = args[1] as int;

  int sum = 0;
  for (int i = 0; i <= max; i++) sum += i;
  sendPort.send(sum);
}

Future<int> runWithParam(int max) async {
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(calculateWithParam, [receivePort.sendPort, max]);
  int result = await receivePort.first as int;
  receivePort.close();
  return result;
}

// ---- 方式三：双向通信 ----
Future<void> bidirectionalCommunication() async {
  // 主 Isolate 的 ReceivePort
  ReceivePort mainReceivePort = ReceivePort();

  // 启动工作 Isolate
  await Isolate.spawn(worker, mainReceivePort.sendPort);

  // 接收工作 Isolate 的 SendPort
  SendPort workerSendPort = await mainReceivePort.first as SendPort;

  // 发送任务并接收结果
  var receivePort2 = ReceivePort();
  workerSendPort.send({'data': 'Hello from main!', 'reply': receivePort2.sendPort});
  var response = await receivePort2.first;
  print('工作 Isolate 回复: $response');
}

void worker(SendPort mainSendPort) {
  // 创建自己的 ReceivePort
  ReceivePort workerReceivePort = ReceivePort();

  // 把自己的 SendPort 发给主 Isolate
  mainSendPort.send(workerReceivePort.sendPort);

  // 监听消息
  workerReceivePort.listen((message) {
    if (message is Map) {
      String data = message['data'];
      SendPort replyTo = message['reply'];

      // 处理并回复
      String result = '处理结果: ${data.toUpperCase()}';
      replyTo.send(result);
    }
  });
}

void main() async {
  print('开始并行计算...');
  int result = await runInIsolate();
  print('1 到 1 亿的和: $result');

  int result2 = await runWithParam(50000000);
  print('1 到 5000 万的和: $result2');

  await bidirectionalCommunication();
}
''', language: 'Dart'),
          OutputBox('开始并行计算...\n1 到 1 亿的和: 5000000050000000\n'
              '1 到 5000 万的和: 1250000025000000\n'
              '工作 Isolate 回复: 处理结果: HELLO FROM MAIN!'),
          TipBox('并发（Concurrency）是单核快速切换任务——看起来像同时。'
              '并行（Parallelism）是多核同时执行——真正的同时。'
              'Isolate 实现真正的并行，每个 Isolate 有独立内存空间。'
              'Flutter 中可用 compute() 函数简化：await compute(myFunc, param)。'
              , type: TipType.info),

          // ============================================================
          // 9. Future.wait 与并行
          // ============================================================
          SectionHeader('9. Future.wait —— 并行任务', icon: Icons.group),
          Paragraph('Future.wait 等待多个 Future 全部完成，返回所有结果。'
              '与串行 await 不同，Future.wait 可以并行执行互不依赖的任务，'
              '总耗时等于最慢任务的耗时，而不是各任务耗时之和。'
              'Future.any 返回最先完成的 Future 的结果。'),
          CodeBlock(r'''
import 'dart:async';

Future<String> fetchUser() async {
  await Future.delayed(Duration(seconds: 2));
  return '用户信息';
}

Future<String> fetchPosts() async {
  await Future.delayed(Duration(seconds: 3));
  return '帖子列表';
}

Future<String> fetchNotifications() async {
  await Future.delayed(Duration(seconds: 1));
  return '通知消息';
}

// 模拟可能失败的任务
Future<String> fetchTask(int id, int delaySec, {bool fail = false}) async {
  await Future.delayed(Duration(seconds: delaySec));
  if (fail) throw Exception('任务 $id 失败');
  return '任务 $id 完成';
}

void main() async {
  // ---- 串行执行（总耗时约 6 秒）----
  print('--- 串行执行（依次等待）---');
  var start = DateTime.now();

  var user = await fetchUser();
  var posts = await fetchPosts();
  var notifs = await fetchNotifications();

  print('结果: $user, $posts, $notifs');
  print('串行耗时: ${DateTime.now().difference(start).inSeconds} 秒');

  // ---- 并行执行（总耗时约 3 秒）----
  print('\n--- Future.wait（并行执行）---');
  start = DateTime.now();

  var results = await Future.wait([
    fetchUser(),
    fetchPosts(),
    fetchNotifications(),
  ]);

  print('结果: ${results[0]}, ${results[1]}, ${results[2]}');
  print('并行耗时: ${DateTime.now().difference(start).inSeconds} 秒');

  // ---- Future.any：最先完成的 ----
  print('\n--- Future.any（竞速）---');
  var first = await Future.any([
    Future.delayed(Duration(seconds: 3), () => '慢任务'),
    Future.delayed(Duration(seconds: 1), () => '快任务'),
  ]);
  print('最先完成: $first');  // 快任务

  // ---- Future.wait 的错误处理 ----
  print('\n--- Future.wait 错误处理 ---');
  try {
    await Future.wait([
      fetchTask(1, 1),
      fetchTask(2, 2, fail: true),  // 这个任务会失败
      fetchTask(3, 1),
    ]);
  } catch (e) {
    print('捕获到错误: $e');
    // 注意：即使某个任务失败，其他任务仍会继续执行
  }
}
''', language: 'Dart'),
          OutputBox('--- 串行执行（依次等待）---\n结果: 用户信息, 帖子列表, 通知消息\n'
              '串行耗时: 6 秒\n\n'
              '--- Future.wait（并行执行）---\n结果: 用户信息, 帖子列表, 通知消息\n'
              '并行耗时: 3 秒\n\n'
              '--- Future.any（竞速）---\n最先完成: 快任务\n\n'
              '--- Future.wait 错误处理 ---\n捕获到错误: Exception: 任务 2 失败'),
          TipBox('串行 await 总耗时 = 各任务耗时之和。'
              'Future.wait 并行执行，总耗时 = 最慢任务的耗时。'
              '仅当任务间互不依赖时才能用 Future.wait。'
              '注意：其中一个失败会立即抛出异常，但其他任务仍会继续。'
              , type: TipType.info),

          const _FutureStateDemo(),
          const _StreamVisualizationDemo(),
          DividerLine(),
          SectionHeader('小练习', icon: Icons.assignment),
          Paragraph('1. 创建三个 Future.delayed（1s、2s、3s），用 Future.wait 同时执行。'),
          Paragraph('2. 用 async/await 和 try/catch 模拟 API 请求，处理网络错误。'),
          Paragraph('3. 用 StreamController.broadcast() 创建广播流，添加两个监听者。'),
          Paragraph('4. 用 async* 创建每 0.5 秒产生一个值的 Stream，用 await for 消费前 5 个。'),
          Paragraph('5. 用 Future.wait 同时请求三个 API 并合并结果。'),
          Paragraph('6. 用 Isolate.spawn 在后台计算 1 到 2000 万的和。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
