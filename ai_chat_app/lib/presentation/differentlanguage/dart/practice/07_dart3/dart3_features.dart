library dart3;

import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Dart 教程 · 第七章：Dart 3 新特性
/// Records、Patterns、Sealed Class、Switch 增强、Class Modifiers
class Dart3Features extends StatelessWidget {
  const Dart3Features({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dart 3 新特性'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Paragraph(
            'Dart 3 是 Dart 语言史上最大的一次更新，引入了大量现代语言特性。'
            '本章涵盖最重要的几个：Records、Pattern Matching、Sealed Class、'
            '增强 Switch、以及 Class Modifiers。',
          ),
          const TipBox(
            'Dart 3 要求最低 SDK 版本为 3.0.0。项目 pubspec.yaml 中 sdk: ^3.11.5，'
            '所以可以放心使用本章的所有特性！',
            type: TipType.info,
          ),

          // ── 1. Records 深入 ──
          SectionHeader('1. Records —— 记录类型', icon: Icons.notes),
          const Paragraph(
            'Records 是 Dart 3 最重要的新特性之一。'
            '它让你把多个值打包在一起，不需要创建专门的类。\n\n'
            '适用场景：\n'
            '• 函数返回多个值\n'
            '• 临时组合数据\n'
            '• 替代小型的「一次性」数据类',
          ),
          const CodeBlock(r'''
void main() {
  // 位置 Records：按顺序访问
  var pos = ('张三', 25, true);
  print(pos.$1);  // 第一个字段：张三
  print(pos.$2);  // 第二个字段：25

  // 命名 Records：按名称访问（推荐）
  var named = (name: '李四', age: 30, isStudent: false);
  print(named.name);  // 李四
  print(named.age);   // 30

  // 函数返回多个值
  (int, int) minMax(List<int> nums) {
    int min = nums.reduce((a, b) => a < b ? a : b);
    int max = nums.reduce((a, b) => a > b ? a : b);
    return (min, max);  // 返回两个值，不用定义类
  }

  var result = minMax([3, 1, 4, 1, 5]);
  print('最小值: ${result.$1}, 最大值: ${result.$2}');
  // 输出：最小值: 1, 最大值: 5
}
''', language: 'Dart'),
          const OutputBox('张三\n25\n李四\n30\n最小值: 1, 最大值: 5'),
          const TipBox(
            'Records 的两个核心特点：\n'
            '1. 值相等：两个 Records 内容相同就相等（不需要重写 ==）\n'
            '2. 类型安全：类型信息在编译时完整保留',
            type: TipType.tip,
          ),

          // ── 2. Switch 增强 ──
          const DividerLine(),
          SectionHeader('2. Switch 表达式', icon: Icons.switch_left),
          const Paragraph(
            'Dart 3 对 switch 做了巨大改进。现在 switch 不只是语句，还是表达式！\n'
            '可以直接返回结果，支持模式匹配、逻辑组合、类型判断。',
          ),
          const CodeBlock(r'''
// 传统 switch 语句（写法冗长）
String oldWay(String fruit) {
  switch (fruit) {
    case '苹果':
      return '红色';
    case '香蕉':
      return '黄色';
    case '西瓜':
      return '绿色';
    default:
      return '未知';
  }
}

// Dart 3 switch 表达式（简洁！）
String newWay(String fruit) => switch (fruit) {
  '苹果' => '红色',     // case → 箭头返回值
  '香蕉' => '黄色',
  '西瓜' => '绿色',
  _ => '未知',           // _ 替代 default
};

void main() {
  print(newWay('苹果'));  // 红色
  print(newWay('葡萄'));  // 未知
}
''', language: 'Dart'),
          const OutputBox('红色\n未知'),
          const Paragraph(
            'Switch 表达式是 Dart 3 最常用的新特性：\n'
            '• 用 => 替代冒号 + break\n'
            '• 用 _ 替代 default\n'
            '• 本身就是表达式，可以赋值给变量',
          ),

          // ── 3. Pattern Matching ──
          const DividerLine(),
          SectionHeader('3. 模式匹配（Pattern Matching）⭐', icon: Icons.pattern),
          const Paragraph(
            '模式匹配是 Dart 3 最强大的新特性。你可以把「匹配」和「解构」结合起来，'
            '一次完成检查、提取、赋值的操作。',
          ),
          const CodeBlock(r'''
void main() {
  // 3.1 解构 List
  var list = [1, 2, 3];
  var [a, b, c] = list;        // 解构赋值
  print('$a, $b, $c');         // 1, 2, 3

  // 3.2 解构 Map
  var map = {'name': '张三', 'age': 25};
  var {'name': name, 'age': age} = map;
  print('$name, $age');        // 张三, 25

  // 3.3 解构 Records
  var record = (x: 10, y: 20);
  var (x: xVal, y: yVal) = record;  // 命名解构
  var (x: xv, y: _) = record;       // 只取 x，忽略 y
  print('($xVal, $yVal)');     // (10, 20)

  // 3.4 在 switch 中解构
  var value = (1, 'hello');
  switch (value) {
    case (1, var msg):         // 同时匹配和解构
      print('数字是1，消息是: $msg');
    case (var id, _):
      print('其他数字: $id');
  }
}
''', language: 'Dart'),
          const OutputBox('1, 2, 3\n张三, 25\n(10, 20)\n数字是1，消息是: hello'),
          const TipBox(
            '模式匹配的威力在于「组合使用」——匹配 + 解构 + 条件过滤一次完成。'
            '这在处理复杂数据结构时非常强大。',
            type: TipType.tip,
          ),

          // ── 4. Sealed Class ──
          const DividerLine(),
          SectionHeader('4. Sealed Class —— 密封类', icon: Icons.shield),
          const Paragraph(
            'sealed class 是 Dart 3 新增的关键字。密封类限制了它的子类只能在同一个文件中定义。\n\n'
            '好处：\n'
            '• switch 必须覆盖所有子类（编译器检查）\n'
            '• 忘记处理某个分支时，编译器会报错\n'
            '• 没有 default 分支 —— 因为所有可能都在这里了',
          ),
          const CodeBlock(r'''
// 密封类：所有子类必须在同一个文件中
sealed class Result<T> {
  // 私有构造函数：外部不能继承
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

// 编译器知道 Result 只有 Success 和 Failure 两种可能
String handleResult(Result<int> result) =>
  switch (result) {
    Success(data: var d) => '成功: $d',
    Failure(message: var m) => '失败: $m',
    // 不需要 default！编译器已检查所有情况
  };

void main() {
  print(handleResult(const Success(42)));   // 成功: 42
  print(handleResult(const Failure('网络错误'))); // 失败: 网络错误
}
''', language: 'Dart'),
          const OutputBox('成功: 42\n失败: 网络错误'),
          const TipBox(
            'Sealed Class 最重要的价值：编译器强制你处理所有分支。'
            '添加新的子类后，所有 switch 的地方编译器都会报错提醒你更新。',
            type: TipType.caution,
          ),

          // ── 5. Class Modifiers ──
          const DividerLine(),
          SectionHeader('5. Class Modifiers', icon: Icons.class_),
          const Paragraph(
            'Dart 3 引入了多个类修饰符，让你精确控制类的使用方式：\n\n'
            '🔹 base —— 只能被继承（不能实现接口）\n'
            '🔸 interface —— 只能被实现（不能继承）\n'
            '🔹 sealed —— 在本文件中限制继承\n'
            '🔸 final —— 不能被继承或实现\n'
            '🔹 mixin —— 声明 mixin 类型',
          ),
          const CodeBlock(r'''
// base：只能继承，不能 implement
base class Animal {
  void speak() => print('...');
}
class Dog extends Animal {}  // ✅ 可以继承
// class FakeAnimal implements Animal {} // ❌ 不能实现

// interface：只能实现，不能继承
interface class Printable {
  void print() => print('打印');
}
class Doc implements Printable {  // ✅ 可以实现
  void print() => print('文档');
}
// class BadDoc extends Printable {} // ❌ 不能继承

// final：不能继承也不能实现
final class Config {
  static const version = '1.0';
}
// class MyConfig extends Config {} // ❌ 错误
// class MyConfig implements Config {} // ❌ 错误
''', language: 'Dart'),
          const Paragraph(
            'Class Modifiers 让 API 设计更加清晰：告诉使用者这个类「应该怎么用」。'
            '类似于 Java 的 final / Kotlin 的 sealed。',
          ),

          // ── 6. 综合实战 ──
          const DividerLine(),
          SectionHeader('6. ✨ 综合实战：模式匹配的威力', icon: Icons.rocket_launch),
          const Paragraph(
            '下面是一个结合了 Records + Sealed Class + Switch 表达式的实际例子。'
            '这段代码清晰地表达了「UI 状态管理」的常见模式。',
          ),
          const CodeBlock(r'''
// 定义 UI 状态（sealed class）
sealed class UiState<T> {
  const UiState();
}
class Initial<T> extends UiState<T> { const Initial(); }
class Loading<T> extends UiState<T> { const Loading(); }
class Data<T> extends UiState<T> {
  final T value;
  const Data(this.value);
}
class Error<T> extends UiState<T> {
  final String message;
  const Error(this.message);
}

// 使用：编译器确保覆盖所有状态
Widget buildUI<T>(UiState<T> state) => switch (state) {
  Initial() => const Text('准备加载...'),
  Loading() => const CircularProgressIndicator(),
  Data(value: var v) => Text('数据: $v'),
  Error(message: var m) => Text('错误: $m'),
  // 如果新加一个 Empty 子类，这里编译会报错！
};
''', language: 'Dart'),
          const OutputBox('用 sealed class 管理 UI 状态是 Flutter 社区的最佳实践。\n'
              '新加状态 → 编译器提醒所有 switch 要更新 → 减少线上 bug。'),

          const DividerLine(),
          SectionHeader('小练习', icon: Icons.assignment),
          const Paragraph('1. 用 Record 返回 (name, age, email) 三元组信息'),
          const Paragraph('2. 用 switch 表达式将分数转换为 A/B/C/D 等级'),
          const Paragraph('3. 用 sealed class 定义 NetworkState（idle/loading/success/error）'),
          const Paragraph('4. 用模式匹配解构一个嵌套的 Record: ((x, y), color)'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
