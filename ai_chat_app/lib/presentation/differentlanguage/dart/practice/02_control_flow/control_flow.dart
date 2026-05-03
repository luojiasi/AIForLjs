library dart_cf;

import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Dart 控制流程教程页面
/// 涵盖：条件语句、switch 表达式、循环、break/continue/标签、
/// 断言、异常处理、模式匹配
class DartControlFlow extends StatelessWidget {
  const DartControlFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第2章 · 控制流程'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('控制流程决定程序按什么顺序执行代码。'
              'Dart 提供了条件语句、循环、异常处理等多种控制方式。'
              'Dart 3 还引入了增强的 switch 表达式和模式匹配。'),

          // 1. 条件语句
          SectionHeader('1. 条件语句', icon: Icons.call_split),
          Paragraph('if/else if/else 是最常用的条件判断。'
              'Dart 支持基于 is 和 null 检查的类型提升（type promotion）。'
              '此外 Dart 还提供了三元运算符 ?: 用于简洁的条件表达式。'),
          CodeBlock(r'''
void main() {
  int score = 85;

  // if / else if / else 判断成绩等级
  if (score >= 90) {
    print('优秀');
  } else if (score >= 60) {
    print('及格');
  } else {
    print('不及格');
  }

  // 类型提升：is 检查后自动转为更具体的类型
  Object value = 'Hello Dart';
  if (value is String) {
    // 此处 value 自动提升为 String，可直接使用 String 方法
    print('字符串长度: ${value.length}');
  }

  // null 检查后的类型提升
  String? nullableName = '张三';
  if (nullableName != null) {
    // 此处 nullableName 自动提升为非空 String
    print('姓名长度: ${nullableName.length}');
  }

  // 三元运算符 ?: —— 简洁的条件表达式
  int age = 20;
  String status = age >= 18 ? '成年' : '未成年';
  print('状态: $status');
}
''', language: 'Dart'),
          OutputBox('及格\n字符串长度: 10\n姓名长度: 2\n状态: 成年'),
          TipBox('类型提升是 Dart 空安全的核心特性之一。'
              '通过 is、== null、!= null 检查后，'
              'Dart 会自动将变量视为更具体的类型。', type: TipType.tip),

          // 2. switch 表达式
          SectionHeader('2. switch —— Dart 3 增强', icon: Icons.swap_horiz),
          Paragraph('Dart 3 引入了增强的 switch 表达式，'
              '支持 => 语法直接返回值、模式匹配、守卫条件（when）和析构。'),
          CodeBlock(r'''
void main() {
  // 传统 switch 语句
  String command = 'open';
  switch (command) {
    case 'open':
      print('打开文件');
    case 'save':
      print('保存文件');
    default:
      print('未知命令');
  }

  // Dart 3 switch 表达式（使用 => 直接返回值）
  String weather = 'sunny';
  String activity = switch (weather) {
    'sunny' => '去游泳',
    'rainy' => '在家看书',
    'cloudy' => '去散步',
    _ => '待定',       // _ 匹配所有其他情况
  };
  print('天气 $weather，适合 $activity');

  // 守卫条件（when）：在匹配基础上增加额外判断
  int value = 42;
  switch (value) {
    case int n when n > 100:
      print('$n 大于 100');
    case int n when n > 0:
      print('$n 是正数');
    default:
      print('其他情况');
  }
}
''', language: 'Dart'),
          OutputBox('打开文件\n天气 sunny，适合 去游泳\n42 是正数'),
          Paragraph('switch 表达式是 Dart 3 的重大改进，'
              '它让原本需要多个 if/else 的逻辑变得更加清晰简洁。'
              '注意：传统 switch 是语句（statement），'
              'Dart 3 的新语法是表达式（expression），可以直接赋值。'),

          // 3. 模式匹配与析构
          SectionHeader('3. 模式匹配与析构', icon: Icons.pattern),
          Paragraph('Dart 3 的 switch 支持模式匹配，可以对 Records、List 等类型'
              '进行解构匹配，结合守卫条件（when）实现强大的分支逻辑。'
              '还支持 OR 模式（|）同时匹配多种情况。'),
          CodeBlock(r'''
void main() {
  // 对 Record 进行模式匹配
  (String, int) person = ('张三', 25);

  switch (person) {
    case ('张三', var age):
      print('张三的年龄是 $age');
    case ('李四', 30):
      print('李四 30 岁');
    default:
      print('未知人员');
  }

  // 对列表进行模式匹配
  var numbers = [1, 2, 3];

  switch (numbers) {
    case [1, var b, var c]:
      print('第一个是 1，后两个是 $b 和 $c');
    default:
      print('不匹配');
  }

  // 守卫（when）：在匹配基础上增加额外条件
  (int, int) point = (10, 20);
  switch (point) {
    case (var x, var y) when x == y:
      print('坐标在对角线上');
    case (var x, var y) when x > y:
      print('x($x) 大于 y($y)');
    default:
      print('x: ${point.$1}, y: ${point.$2}');
  }

  // OR 模式（|）：匹配多种情况
  String grade = 'A';
  switch (grade) {
    case 'A' | 'A+':
      print('优秀');
    case 'B' | 'B+':
      print('良好');
    default:
      print('继续努力');
  }

  // 空值检查模式：一行代码处理 null
  String? maybeName = '李四';
  switch (maybeName) {
    case String name:
      print('名字: $name');
    case null:
      print('名字为空');
  }
}
''', language: 'Dart'),
          OutputBox('张三的年龄是 25\n第一个是 1，后两个是 2 和 3\n'
              'x: 10, y: 20\n优秀\n名字: 李四'),
          Paragraph('模式匹配是 Dart 3 最强大的特性之一，'
              '它让代码更加声明式、可读性更强。'
              '结合 Records 和 switch 表达式，可以写出非常简洁的数据处理逻辑。'),

          // 4. 循环
          SectionHeader('4. 循环', icon: Icons.loop),
          Paragraph('Dart 提供多种循环方式：for（传统计数）、for-in（遍历集合）、'
              'forEach（闭包遍历）、while（先判断后执行）和 do-while（至少执行一次）。'),
          CodeBlock(r'''
void main() {
  // for 循环：初始化; 条件; 步进
  print('--- for 循环 ---');
  for (int i = 1; i <= 3; i++) {
    print('第$i次');
  }

  // for-in 循环：遍历集合中的每个元素
  print('--- for-in 循环 ---');
  var fruits = ['苹果', '香蕉', '橘子'];
  for (var fruit in fruits) {
    print('我喜欢$fruit');
  }

  // forEach：使用闭包遍历
  print('--- forEach 闭包 ---');
  fruits.forEach((fruit) {
    print('水果: $fruit');
  });

  // while 循环：先判断条件，满足才执行
  print('--- while 循环 ---');
  int count = 0;
  while (count < 3) {
    print('count = $count');
    count++;
  }

  // do-while 循环：先执行一次，再判断
  print('--- do-while 循环 ---');
  int num = 5;
  do {
    print('num = $num');
    num++;
  } while (num < 3);  // 条件为 false，但已执行一次
}
''', language: 'Dart'),
          OutputBox('--- for 循环 ---\n第1次\n第2次\n第3次\n'
              '--- for-in 循环 ---\n我喜欢苹果\n我喜欢香蕉\n我喜欢橘子\n'
              '--- forEach 闭包 ---\n水果: 苹果\n水果: 香蕉\n水果: 橘子\n'
              '--- while 循环 ---\ncount = 0\ncount = 1\ncount = 2\n'
              '--- do-while 循环 ---\nnum = 5'),
          Paragraph('需要同时获取索引和值时，'
              '可用 for 循环 + 索引访问，或 Dart 的 .toList() 配合 for-in 循环。'
              'Dart 3 的 indexed 属性可直接返回索引和元素的配对。'),
          CodeBlock(r'''
void main() {
  var fruits = ['苹果', '香蕉', '橘子'];

  // 使用索引遍历
  for (int i = 0; i < fruits.length; i++) {
    print('[$i] ${fruits[i]}');
  }

  print('---');

  // Dart 3 indexed 属性：同时获取索引和值
  for (var entry in fruits.indexed) {
    print('${entry.$1}: ${entry.$2}');
  }
}
''', language: 'Dart'),
          OutputBox('[0] 苹果\n[1] 香蕉\n[2] 橘子\n---\n0: 苹果\n1: 香蕉\n2: 橘子'),
          TipBox('forEach 接受函数作为参数，'
              '无法使用 break/continue。需要提前终止时用 for-in 或标准 for 循环。'
              '.indexed 属性是 Dart 3 新增的便捷方法。',
              type: TipType.info),

          // 5. break、continue 和标签
          SectionHeader('5. break、continue 和标签', icon: Icons.skip_next),
          Paragraph('break 跳出整个循环；continue 跳过当前轮继续下一轮。'
              '使用标签（label）可以跳出或跳过指定的外层循环。'),
          CodeBlock(r'''
void main() {
  // break 和 continue
  for (int i = 1; i <= 5; i++) {
    if (i == 2) {
      continue;  // 跳过 i=2，进入 i=3
    }
    if (i == 4) {
      break;     // 在 i=4 时退出整个循环
    }
    print('i = $i');
  }

  print('--- 标签示例 ---');

  // 标签：跳出指定外层循环
  outerLoop:
  for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 3; j++) {
      if (i == 2 && j == 2) {
        break outerLoop;  // 跳出外层循环
      }
      print('($i, $j)');
    }
  }
}
''', language: 'Dart'),
          OutputBox('i = 1\ni = 3\n--- 标签示例 ---\n(1, 1)\n(1, 2)\n(1, 3)\n(2, 1)'),
          TipBox('continue 也可配合标签使用，跳过指定外层循环的当前轮次。'
              '标签名后跟冒号（如 outerLoop:），常用于嵌套循环的控制。',
              type: TipType.tip),

          // 6. 断言
          SectionHeader('6. assert —— 调试断言', icon: Icons.bug_report),
          Paragraph('assert 在调试时检查条件。条件为 false 时程序中断并抛出异常，'
              'true 则正常运行。发布模式下 assert 语句自动被移除。'
              'assert 的第二个参数是可选的错误消息字符串。'),
          CodeBlock(r'''
void main() {
  String name = 'Dart';

  // 断言 name 不为空，断言失败会抛异常
  assert(name.isNotEmpty, 'name 不能为空');

  int age = 25;
  assert(age >= 0, '年龄不能为负数');

  // assert 也可检查函数参数合法性
  String greet(String? name) {
    assert(name != null, 'name 不能为 null');
    return '你好，$name';
  }

  print(greet('张三'));
  print('断言全部通过，继续执行');
}

/// 推荐在实际开发中使用 assert 检查前置条件
int divide(int a, int b) {
  assert(b != 0, '除数不能为 0');
  return a ~/ b;
}
''', language: 'Dart'),
          OutputBox('你好，张三\n断言全部通过，继续执行'),
          TipBox('assert 只在 --debug 模式下生效，'
              '--release 模式下被自动移除。不要将业务逻辑放在 assert 里。'
              '断言常用于检查参数合法性、前置条件等。', type: TipType.warning),

          // 7. 异常处理
          SectionHeader('7. 异常处理', icon: Icons.error_outline),
          Paragraph('使用 try/on/catch/finally 捕获并处理异常。'
              'on 捕获特定类型，catch 获取异常对象和堆栈信息，'
              'finally 无论是否异常都会执行。'),
          CodeBlock(r'''
void main() {
  try {
    // 尝试执行可能出错的代码
    int result = 100 ~/ 0;  // 整数除以 0 会抛异常
  } on IntegerDivisionByZeroException {
    // on：只捕获特定类型的异常
    print('不能除以零');
  } catch (e) {
    // catch：捕获所有异常（如果 on 没命中）
    print('发生错误: $e');
  } finally {
    // finally：不管有没有异常都会执行
    print('清理工作完成');
  }
}
''', language: 'Dart'),
          OutputBox('不能除以零\n清理工作完成'),

          Paragraph('catch 可以接收堆栈跟踪信息，方便定位问题。'
              'rethrow 将异常重新抛出，交由上层调用者处理。'),
          CodeBlock(r'''
void main() {
  try {
    processData(-1);
  } catch (e, stackTrace) {
    // e 是异常对象，stackTrace 是堆栈跟踪
    print('捕获异常: $e');
    print('堆栈信息: $stackTrace');
  }
}

void processData(int value) {
  try {
    if (value < 0) {
      throw ArgumentError('值不能为负数: $value');
    }
    print('处理数据: $value');
  } catch (e) {
    print('processData 内部记录日志');
    rethrow;  // 重新抛出，让上层继续处理
  }
}
''', language: 'Dart'),
          Paragraph('使用 throw 可以主动抛出任何类型的异常。'
              '自定义异常通常继承 Exception 类。'),

          DividerLine(),
          SectionHeader('本章练习', icon: Icons.assignment),
          Paragraph('1. 写 if/else 判断成绩等级：90+ 为 A，80+ 为 B，60+ 为 C，其余为 D。'),
          Paragraph('2. 用 switch 表达式将星期数字（1-7）转为中文星期名称。'),
          Paragraph('3. 用 for-in 遍历姓名列表，遇到指定名字时用 break 退出。'),
          Paragraph('4. 使用标签跳出双层循环。'),
          Paragraph('5. 用 try/catch/finally 捕获异常，练习 rethrow 重新抛出。'),
          Paragraph('6. 对 Record 类型使用模式匹配进行解构。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
