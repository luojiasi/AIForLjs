library dart_fn;

import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Dart 函数教程页面
/// 涵盖：函数定义、参数类型、函数类型、匿名函数、闭包、
/// Tear-off、IIFE、生成器、函数式编程
class DartFunctions extends StatelessWidget {
  const DartFunctions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第3章 · 函数'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('函数是可复用的代码块。Dart 是纯面向对象语言，'
              '函数也是对象（Function 类型），可以作为参数传递、作为返回值返回。'
              '这种函数是一等公民的特性让 Dart 支持函数式编程风格。'),

          // 1. 函数定义
          SectionHeader('1. 函数定义', icon: Icons.functions),
          Paragraph('函数由返回值类型、函数名、参数列表和函数体组成。'
              '如果函数体只有一行表达式，可以用 => 箭头语法简写。'
              '无返回值时使用 void。'),
          CodeBlock(r'''
// 普通函数：带返回值类型和函数体
int add(int a, int b) {
  return a + b;  // 返回两数之和
}

// 箭头函数：=> 后面的表达式自动作为返回值
int addArrow(int a, int b) => a + b;

// 无返回值函数
void greet(String name) {
  print('你好，$name');
}

// 可选返回类型：省略时返回类型为 dynamic
sum(int a, int b) => a + b;  // 不推荐省略

void main() {
  print(add(3, 5));        // 8
  print(addArrow(3, 5));   // 8
  greet('张三');
}
''', language: 'Dart'),
          OutputBox('8\n8\n你好，张三'),

          // 2. 参数类型
          SectionHeader('2. 参数类型 —— Dart 特色', icon: Icons.settings),
          Paragraph('Dart 的参数系统非常灵活：\n'
              '• 命名参数 {} —— 调用时写参数名，更清晰\n'
              '• required —— 命名参数必填标记\n'
              '• 可选位置参数 [] —— 按位置传入，可省略\n'
              '• 默认值 —— 参数未传入时使用默认值，必须是编译时常量'),
          CodeBlock(r'''
// 命名参数：用 {} 包裹，调用时必须写参数名
void greet({required String name, int age = 18}) {
  print('你好，$name，年龄 $age');
}

// 位置可选参数：用 [] 包裹，可以不传
void say(String message, [String? punctuation]) {
  print('$message${punctuation ?? "."}');
}

// 默认值必须是编译时常量
void logMessage(String msg, [String level = 'INFO']) {
  print('[$level] $msg');
}

void main() {
  greet(name: '张三');             // age 使用默认值 18
  greet(name: '李四', age: 25);    // 指定 age
  say('Hello');                    // 不使用可选参数
  say('Hello', '!');               // 传入可选参数
  logMessage('系统启动');           // 使用默认等级 INFO
}
''', language: 'Dart'),
          OutputBox('你好，张三，年龄 18\n你好，李四，年龄 25\n'
              'Hello.\nHello!\n[INFO] 系统启动'),
          TipBox('required 只能用于命名参数（花括号内）。'
              '默认值必须是编译时常量，如 42、true、"hello"、const 对象等。'
              '不能使用运行时值（如 DateTime.now()）作为默认值。',
              type: TipType.tip),

          // 3. 函数类型
          SectionHeader('3. 函数类型与 typedef', icon: Icons.type_specimen),
          Paragraph('函数本身也是对象，拥有类型。函数类型写作 '
              '返回值类型 Function(参数类型)。'
              'Dart 3 推荐直接使用内联函数类型而非 typedef。'),
          CodeBlock(r'''
// 函数类型声明：返回值类型 Function(参数类型)
void applyOperation(int a, int b, int Function(int, int) operation) {
  // operation 参数接收一个 (int, int) -> int 的函数
  print('结果: ${operation(a, b)}');
}

void main() {
  // 传入匿名函数作为操作
  applyOperation(10, 5, (a, b) => a + b);  // 加法
  applyOperation(10, 5, (a, b) => a * b);  // 乘法

  // 使用变量存储函数类型
  int Function(int, int) multiply = (a, b) => a * b;
  print('3 x 4 = ${multiply(3, 4)}');

  // ---- typedef（传统方式，Dart 3 仍支持） ----
  // 旧方式：typedef Compare<T> = int Function(T, T);
  // Dart 3 推荐直接在参数位置写函数类型
}

// typedef 示例（传统写法，功能等价于内联类型）
typedef IntOperation = int Function(int, int);

int applyWithTypedef(int a, int b, IntOperation op) => op(a, b);
''', language: 'Dart'),
          OutputBox('结果: 15\n结果: 50\n3 x 4 = 12'),
          TipBox('Dart 3 推荐使用内联函数类型（如 void Function(int)）'
              '代替 typedef。但当函数类型复杂且多处复用时，'
              'typedef 仍可提高代码可读性。', type: TipType.info),

          // 4. 匿名函数
          SectionHeader('4. 匿名函数（Lambda）', icon: Icons.person_outline),
          Paragraph('匿名函数是没有名字的函数，常作为参数传递给其他函数。'
              'Dart 中匿名函数是一等公民，可以赋值给变量、作为参数传递、作为返回值。'),
          CodeBlock(r'''
void main() {
  var numbers = [1, 2, 3, 4, 5];

  // 匿名函数：没有函数名，直接作为参数传入
  numbers.forEach((item) {
    print('元素: $item');
  });

  print('---');

  // 箭头形式的匿名函数（更简洁）
  numbers.forEach((item) => print('值: $item'));

  print('---');

  // 匿名函数赋值给变量
  var square = (int x) => x * x;
  print('5 的平方: ${square(5)}');

  // 匿名函数作为返回值
  Function makeGreeter(String greeting) {
    return (String name) => '$greeting, $name!';
  }

  var sayHello = makeGreeter('你好');
  var sayGoodbye = makeGreeter('再见');
  print(sayHello('张三'));
  print(sayGoodbye('李四'));
}
''', language: 'Dart'),
          OutputBox('元素: 1\n元素: 2\n元素: 3\n元素: 4\n'
              '元素: 5\n---\n值: 1\n值: 2\n值: 3\n值: 4\n值: 5\n'
              '---\n5 的平方: 25\n你好, 张三!\n再见, 李四!'),

          // 5. 闭包
          SectionHeader('5. 闭包（Closure）', icon: Icons.lock_outline),
          Paragraph('闭包是函数捕获其外部作用域变量的能力。'
              '即使外部函数执行完毕，内部函数仍然可以访问和修改那些变量。'
              '这是 Dart 实现状态保持和函数工厂的基础。'),
          CodeBlock(r'''
// 闭包：内部函数"记住"了外部函数的变量
Function makeCounter() {
  int count = 0;           // 外部函数的局部变量
  return () {              // 返回匿名函数（闭包）
    count++;               // 捕获了 count 变量
    return count;
  };
}

void main() {
  var counter = makeCounter();  // 获取闭包
  print(counter());  // 1：count 从 0 变为 1
  print(counter());  // 2：count 从 1 变为 2
  print(counter());  // 3：count 从 2 变为 3

  print('---');

  // 多个闭包实例互不干扰
  var counterA = makeCounter();
  var counterB = makeCounter();
  print('A: ${counterA()}');  // 1
  print('A: ${counterA()}');  // 2
  print('B: ${counterB()}');  // 1（独立于 A）
  print('A: ${counterA()}');  // 3
  print('B: ${counterB()}');  // 2
}
''', language: 'Dart'),
          OutputBox('1\n2\n3\n---\nA: 1\nA: 2\nB: 1\nA: 3\nB: 2'),
          Paragraph('闭包的经典应用场景：'
              '函数工厂（生成不同行为的函数）、状态保持（计数器）、回调函数。'),

          // 6. Tear-off
          SectionHeader('6. Tear-off —— 方法引用', icon: Icons.link),
          Paragraph('Tear-off 是指将方法作为函数引用传递，'
              '而不立即调用它。当方法的签名与所需函数类型匹配时，'
              '可以用方法名直接引用。'),
          CodeBlock(r'''
void main() {
  var fruits = ['香蕉', '苹果', '橘子'];

  // 普通写法：用匿名函数包裹
  fruits.forEach((item) => print(item));

  print('---');

  // Tear-off：直接将 print 方法作为函数引用传递
  fruits.forEach(print);  // print 的签名匹配 (String) -> void

  print('---');

  // 实例方法的 tear-off
  var lowercase = fruits.map((s) => s.toLowerCase());
  print(lowercase);

  // 静态方法的 tear-off
  var numbers = ['3', '1', '4'];
  var parsed = numbers.map(int.parse);  // int.parse 的签名匹配
  print(parsed);  // (3, 1, 4)
}
''', language: 'Dart'),
          OutputBox('香蕉\n苹果\n橘子\n---\n'
              '香蕉\n苹果\n橘子\n---\n'
              '(香蕉, 苹果, 橘子)\n(3, 1, 4)'),
          TipBox('Tear-off 让代码更简洁。'
              '条件是方法的签名必须完全匹配期望的函数类型（参数和返回值一致）。'
              '常用于集合操作和事件处理。', type: TipType.tip),

          // 7. IIFE
          SectionHeader('7. IIFE —— 立即执行函数', icon: Icons.flash_on),
          Paragraph('IIFE（Immediately Invoked Function Expression）'
              '是在定义后立即执行的匿名函数。'
              '常用于创建独立的作用域，避免变量污染外部空间。'),
          CodeBlock(r'''
void main() {
  // 基本 IIFE：定义后立即调用
  (() {
    print('这是一个 IIFE');
  })();

  // 带参数的 IIFE
  var result = ((int a, int b) {
    return a + b;
  })(3, 4);
  print('3 + 4 = $result');

  // IIFE 创建独立作用域
  var message = ((String name) {
    var prefix = '你好';  // prefix 只在 IIFE 内部可见
    return '$prefix, $name!';
  })('世界');
  print(message);
  // print(prefix);  // ❌ 错误：prefix 不在作用域内

  print('---');

  // IIFE 结合闭包：创建私有状态
  var uniqueId = (() {
    int id = 0;
    return () => ++id;
  })();
  print(uniqueId());  // 1
  print(uniqueId());  // 2
  print(uniqueId());  // 3
}
''', language: 'Dart'),
          OutputBox('这是一个 IIFE\n3 + 4 = 7\n你好, 世界!\n---\n1\n2\n3'),
          TipBox('IIFE 在 Dart 中主要用于创建隔离的作用域，'
              '避免临时变量污染外部命名空间。'
              '在 Dart 中不如 JavaScript 常用，但在某些场景下非常有用。',
              type: TipType.info),

          // 8. 生成器
          SectionHeader('8. 生成器', icon: Icons.dynamic_feed),
          Paragraph('Dart 支持两种生成器：'
              'sync*（同步生成 Iterable）和 async*（异步生成 Stream）。'
              '使用 yield 产出值，yield* 委托给另一个生成器。'),
          CodeBlock(r'''
// sync* 生成器：返回 Iterable
Iterable<int> countDown(int n) sync* {
  while (n > 0) {
    yield n--;       // 产出当前值，暂停执行
  }
}

// sync* 中使用 yield* 委托
Iterable<int> combine() sync* {
  yield 1;
  yield 2;
  yield* countDown(3);  // 委托给另一个生成器
  yield 0;
}

// async* 生成器：返回 Stream
Stream<String> streamMessages() async* {
  for (int i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(milliseconds: 100));
    yield '消息 $i';    // 异步产出值
  }
}

void main() {
  // 同步生成器：惰性求值
  print('倒数: ${countDown(5).toList()}');
  print('合并: ${combine().toList()}');

  // 异步生成器：流式获取
  streamMessages().listen((msg) => print(msg));
}
''', language: 'Dart'),
          OutputBox('倒数: [5, 4, 3, 2, 1]\n合并: [1, 2, 3, 2, 1, 0]'),
          Paragraph('生成器的核心特性是惰性求值：'
              '值在需要时才计算，不会一次性生成所有数据。'
              '这对处理大量数据或无限序列非常高效。'),
          TipBox('sync* 与 Iterable 配合，async* 与 Stream 配合。'
              'yield 产出单个值，yield* 委托给另一个生成器。'
              '生成器函数体内不能使用 return 返回值。',
              type: TipType.warning),

          // 9. 高阶函数与函数式编程
          SectionHeader('9. 高阶函数与函数式编程', icon: Icons.transform),
          Paragraph('高阶函数指接收函数作为参数或将函数作为返回值的函数。'
              'Dart 集合提供了丰富的函数式方法处理数据。'),
          CodeBlock(r'''
// 高阶函数：接收函数作为参数
void repeat(int times, void Function(int) action) {
  for (int i = 1; i <= times; i++) {
    action(i);
  }
}

// 高阶函数：返回函数
Function makeMultiplier(int factor) {
  return (int x) => x * factor;
}

void main() {
  // 传入匿名函数
  repeat(3, (i) => print('第$i次'));

  print('---');

  // 函数作为返回值
  var double = makeMultiplier(2);
  var triple = makeMultiplier(3);
  print('double(5) = ${double(5)}');
  print('triple(5) = ${triple(5)}');

  print('---');

  // 函数式集合操作
  var numbers = [1, 2, 3, 4, 5, 6];

  var doubled = numbers.map((n) => n * 2);
  print('翻倍: $doubled');             // (2, 4, 6, 8, 10, 12)

  var evens = numbers.where((n) => n.isEven);
  print('偶数: $evens');               // (2, 4, 6)

  var sum = numbers.reduce((a, b) => a + b);
  print('总和: $sum');                 // 21

  var product = numbers.fold(1, (a, b) => a * b);
  print('乘积: $product');             // 720
}
''', language: 'Dart'),
          OutputBox('第1次\n第2次\n第3次\n---\n'
              'double(5) = 10\ntriple(5) = 15\n---\n'
              '翻倍: (2, 4, 6, 8, 10, 12)\n'
              '偶数: (2, 4, 6)\n总和: 21\n乘积: 720'),

          DividerLine(),
          SectionHeader('本章练习', icon: Icons.assignment),
          Paragraph('1. 写一个箭头函数计算两个数的乘积。'),
          Paragraph('2. 写一个函数，接收命名参数 name 和 age，age 默认值 0。'),
          Paragraph('3. 写一个闭包计数器，从 100 开始递增。'),
          Paragraph('4. 用 Tear-off 方式将 int.parse 应用到字符串列表的 map 中。'),
          Paragraph('5. 写一个 sync* 生成器，生成斐波那契数列的前 N 项。'),
          Paragraph('6. 用 map 和 where 处理整数列表：筛选出偶数并翻倍。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
