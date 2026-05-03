import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Dart 基础语法教程页面
/// 涵盖：Dart 简介、main 函数、注释、变量声明、Null Safety、
/// 基本数据类型、字符串操作、类型转换、运算符、Records
class DartBasics extends StatelessWidget {
  const DartBasics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第1章 · 基础语法'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('欢迎来到 Dart 语言的世界！Dart 是 Google 开发的编程语言，'
              '也是 Flutter 框架的基石。它同时支持 JIT（即时编译，实现热重载）'
              '和 AOT（预先编译，原生性能）两种编译方式。'),

          // 1. Dart 简介
          SectionHeader('1. Dart 简介', icon: Icons.language),
          Paragraph('Dart 于 2011 年由 Google 推出，专为构建高性能跨平台应用设计。'
              '开发时使用 JIT 编译，支持热重载（修改代码后秒级生效）；'
              '发布时使用 AOT 编译为原生机器码，启动快、性能高。'),
          Paragraph('Dart 是类型安全的语言，采用基于类的面向对象编程。'
              '它吸收了 Java、C# 和 JavaScript 的优点，语法简洁现代。'
              'Dart 3 引入了 Records、Patterns、Switch 表达式等重大特性。'),

          // 2. main 函数
          SectionHeader('2. main 函数 —— 程序入口', icon: Icons.play_arrow),
          Paragraph('每个 Dart 程序必须有一个 main() 函数作为入口点。'
              'main() 可以带可选的 List<String> 参数，接收命令行传入的参数。'),
          CodeBlock(r'''
// void 表示无返回值，main 是固定函数名
void main() {
  print('Hello, Dart!');  // 打印到控制台
}
''', language: 'Dart'),
          OutputBox('Hello, Dart!'),
          Paragraph('main() 也可接收命令行参数：'),
          CodeBlock(r'''
// args 接收命令行传入的参数
void main(List<String> args) {
  print('收到 ${args.length} 个参数:');
  for (final arg in args) {
    print('  - $arg');
  }
}
''', language: 'Dart'),
          Paragraph('在终端运行 dart run hello.dart arg1 arg2，'
              '则 args 为 [arg1, arg2]。'),
          TipBox('main() 是 Dart 的固定入口点，每个程序只能有一个。'
              '无参数和带参数的版本必须二选一。', type: TipType.info),

          // 3. 注释
          SectionHeader('3. 注释', icon: Icons.comment),
          Paragraph('Dart 支持三种注释方式：// 单行注释、/* */ 多行注释、/// 文档注释。'
              '文档注释是 Dart 官方推荐的 API 文档写法，'
              'dart doc 工具会自动扫描 /// 并生成 HTML 文档。'),
          CodeBlock(r'''
// 单行注释：从 // 到行尾，适用于简短说明

/*
  多行注释：以 /* 开头，以 */ 结尾
  可跨越多行，适用于大段说明
  注意不支持嵌套
*/

/// 文档注释：三个斜杠，推荐用于类和函数
/// 使用 [param] 方括号引用参数
/// 使用 [ClassName] 引用其他类
/// dart doc 会自动生成漂亮的 API 文档
int add(int a, int b) => a + b;
''', language: 'Dart'),
          TipBox('/// 文档注释非常重要。开发库或框架时，'
              '良好的文档注释能让使用者通过编辑器直接看到说明。'
              'dart doc 命令可从文档注释生成 HTML 文档。', type: TipType.tip),

          // 4. 变量声明
          SectionHeader('4. 变量声明 —— 核心概念', icon: Icons.edit),
          Paragraph('Dart 提供多种变量声明方式，适应不同场景：'
              'var（类型推断）、final（一次赋值）、const（编译时常量）、'
              'late（延迟初始化）、dynamic（动态类型）、Object?（可空基类型）。'),
          CodeBlock(r'''
void main() {
  // var —— 类型推断，可重新赋值
  var name = 'Dart';                // 推断为 String
  name = 'DartLang';                // ✅ var 可以重新赋值

  // final —— 运行时常量，只能赋值一次
  final now = DateTime.now().year;  // 运行时确定
  // now = 2025;                    // ❌ 编译错误：final 不可修改

  // const —— 编译时常量，值在编译时确定
  const pi = 3.14159;              // 编译时已知
  const String greeting = '你好';   // 类型标注可选
  // const now2 = DateTime.now();   // ❌ 错误：DateTime.now() 非编译时常量

  // late —— 延迟初始化，首次使用时才初始化
  late String later;
  // print(later);                  // ❌ 运行时报错：未初始化
  later = '准备好了';
  print(later);                    // ✅ 已赋值，可以访问

  // late final —— 延迟初始化的运行时常量
  late final int expensive;
  expensive = _computeExpensive();  // 首次访问时计算
  // expensive = 42;                // ❌ 错误：late final 只能赋值一次

  // dynamic —— 动态类型，关闭编译期类型检查
  dynamic something = '你好';
  something = 42;                  // 可随意改变类型
  something = true;
  print(something);                // true

  // Object? —— 可空的根类型
  Object? value = '任何类型';
  value = null;                    // 显式允许 null
  print(value);                    // null
}

int _computeExpensive() => 99;
''', language: 'Dart'),
          OutputBox('准备好了\ntrue\nnull'),
          TipBox('尽可能使用 var/final/const 而非 dynamic，'
              '让编译器帮你做类型检查，减少运行时错误。'
              'late 变量如果从未被访问，初始化代码不会执行（惰性求值）。',
              type: TipType.tip),

          // 5. Null Safety
          SectionHeader('5. Null Safety —— Dart 独有', icon: Icons.shield),
          Paragraph('Dart 是空安全语言，变量默认不可为 null。'
              '这是 Dart 2.12+ 最重要的特性，能有效避免空指针异常。'
              'Dart 提供了一套运算符安全地处理可能为 null 的值。'),
          CodeBlock(r'''
void main() {
  // ? 声明可空类型
  String? nullableName;             // 初始值为 null
  // String name = null;            // ❌ 错误：非空类型不可赋 null

  // ?? 空值合并：左边为 null 时使用右边
  String display = nullableName ?? '默认名字';
  print(display);                   // 默认名字

  // ??= 空值赋值：变量为 null 时才赋值
  nullableName ??= '被赋值了';
  print(nullableName);              // 被赋值了

  // ! 强制访问：断言值不为 null（谨慎使用）
  String? maybeHello = 'Hello';
  String definitelyHello = maybeHello!;  // 我确定不为 null
  print(definitelyHello.length);    // 5

  // ?. 安全访问：为 null 时短路返回 null
  String? empty;
  print(empty?.length);             // null，不崩溃

  // late 延迟初始化
  late String databaseUrl;
  databaseUrl = 'http://localhost:8080';
  print(databaseUrl);
}
''', language: 'Dart'),
          OutputBox('默认名字\n被赋值了\n5\nnull\nhttp://localhost:8080'),
          TipBox('! 强制访问仅在确认值不为 null 时使用，'
              '否则会运行时报错。推荐优先用 ?? 提供默认值。'
              '?. 在链式调用中非常有用：obj?.prop?.method()。',
              type: TipType.caution),

          // 6. 基本数据类型
          SectionHeader('6. 基本数据类型', icon: Icons.data_object),
          Paragraph('Dart 内置 int（整型）、double（浮点型）、num（数字基类）、'
              'String（字符串）、bool（布尔值）、Symbol（符号）、'
              'Runes（Unicode 码点）等类型。'),
          CodeBlock(r'''
void main() {
  // 数字类型
  int age = 25;                     // 整型（64位）
  double price = 19.99;             // 浮点型（64位双精度）
  num anyNum = 100;                 // num 是 int 和 double 的父类
  num pi = 3.14159;

  // 布尔类型 —— 只有 true 和 false
  bool isFun = true;
  bool isDone = false;

  // Symbol —— 编译时常量，用于反射
  Symbol sym = #myVariable;

  // Runes —— UTF-32 码点（处理 emoji 等 4 字节字符）
  Runes heart = Runes('♥');    // ♥
  Runes smile = Runes('\u{1F600}'); // 😀
  print(String.fromCharCodes(heart));
  print(String.fromCharCodes(smile));
}
''', language: 'Dart'),
          OutputBox('♥\n😀'),
          Paragraph('num 是 int 和 double 的共同父类型，'
              '可以同时容纳整数和浮点数。'),
          TipBox('Runes 用于正确处理 4 字节 Unicode 字符。'
              'String 的 length 返回 UTF-16 码元数，'
              '对于 emoji 可能不准确，可使用 runes 属性遍历。',
              type: TipType.info),

          // 7. 字符串操作
          SectionHeader('7. 字符串操作', icon: Icons.text_fields),
          Paragraph('String 是不可变的 UTF-16 编码序列。'
              'Dart 支持插值、多行字符串、原始字符串、拼接等操作。'),
          CodeBlock(r'''
void main() {
  // 插值 $variable 和 ${expression}
  String lang = 'Dart';
  print('我爱 $lang');
  print('${lang} 有 ${lang.length} 个字符');

  // 多行字符串 """ """ 保留换行和缩进
  String multi = """第一行
第二行
第三行""";
  print(multi);

  // 原始字符串 r'' 忽略转义序列
  String raw = r'反斜杠 \ 和美元 $ 都是普通字符';
  print(raw);

  // 自动拼接相邻字符串字面量
  String s = 'Hello' ' ' 'Dart';
  print(s);
}
''', language: 'Dart'),
          OutputBox('我爱 Dart\nDart 有 4 个字符\n'
              '第一行\n第二行\n第三行\n'
              r'反斜杠 \ 和美元 $ 都是普通字符\n'
              'Hello Dart'),
          Paragraph('常用方法：toUpperCase()、toLowerCase()、'
              'trim()、split()、substring()、contains()、replaceAll()。'
              '可以用 isEmpty / isNotEmpty 检查空字符串。'),

          // 8. 类型转换
          SectionHeader('8. 类型转换', icon: Icons.swap_horiz),
          Paragraph('Dart 支持字符串与数字互转、运行时类型检查以及显式向下转型。'
              '转换失败时 parse 会抛 FormatException，as 会抛 TypeError。'),
          CodeBlock(r'''
void main() {
  // 字符串 -> 数字
  int num = int.parse('42');
  double pi = double.parse('3.14');
  print('$num, $pi');               // 42, 3.14

  // 数字 -> 字符串
  String s = 42.toString();
  String piStr = 3.14159.toStringAsFixed(2);
  print('$s, $piStr');              // 42, 3.14

  // is —— 类型检查（触发类型提升）
  Object value = 'Hello Dart';
  if (value is String) {
    // 此处 value 自动提升为 String 类型
    print('value 是字符串，长度: ${value.length}');
  }

  // is! —— 类型否定
  if (value is! int) {
    print('value 不是整数');
  }

  // as —— 强制类型转换（转型失败抛 TypeError）
  Object obj = 'World';
  String text = obj as String;
  print('text 长度: ${text.length}');
}
''', language: 'Dart'),
          OutputBox('42, 3.14\n42, 3.14\n'
              'value 是字符串，长度: 11\n'
              'value 不是整数\ntext 长度: 5'),
          TipBox('is 类型检查后 Dart 会自动类型提升（type promotion），'
              '在作用域内变量被视为更具体的类型，无需再次转型。'
              '优先使用 is + 自动提升，而非 as 强制转换。',
              type: TipType.tip),

          // 9. 高级运算符
          SectionHeader('9. 高级运算符', icon: Icons.calculate),
          Paragraph('Dart 提供了一系列高级运算符，让代码更加简洁富有表达力。'),
          CodeBlock(r'''
void main() {
  // .. 级联运算符：连续调用同一对象的方法
  var buf = StringBuffer()
    ..write('Hello')
    ..write(' ')
    ..write('Dart');
  print(buf.toString());            // Hello Dart

  // ?.. 空安全级联：对象为 null 时不执行
  StringBuffer? nullableBuf;
  nullableBuf?..write('安全');      // null，不执行

  // ... 展开运算符：将集合展开为单个元素
  var list1 = [1, 2, 3];
  var list2 = [0, ...list1, 4];    // [0, 1, 2, 3, 4]
  print(list2);

  // ...? 空安全展开：集合可能为 null
  List<int>? nullableList;
  var list3 = [1, ...?nullableList]; // [1]
  print(list3);

  // => 箭头函数：单表达式简写
  var nums = [1, 2, 3];
  print(nums.map((n) => n * 2));   // (2, 4, 6)
}
''', language: 'Dart'),
          OutputBox('Hello Dart\n[0, 1, 2, 3, 4]\n[1, 2]\n(2, 4, 6)'),

          // 10. Records
          SectionHeader('10. Records —— Dart 3 新特性', icon: Icons.table_chart),
          Paragraph('Records 是 Dart 3 引入的轻量级数据聚合类型，'
              '无需定义类即可组合多个值。支持位置参数和命名参数，'
              '类型完全由编译器推断。'),
          CodeBlock(r'''
void main() {
  // 位置参数 Record，用 $1, $2, ... 访问
  var person = ('张三', 25, true);
  print('姓名: ${person.$1}');
  print('年龄: ${person.$2}');

  // 命名参数 Record，用 .name 访问
  var point = (x: 10, y: 20);
  print('坐标: (${point.x}, ${point.y})');

  // 混合使用位置和命名参数
  var mixed = ('标签', x: 1, y: 2);
  print('${mixed.$1} at (${mixed.x}, ${mixed.y})');

  // 显式类型标注
  (String, int) record = ('Alice', 30);
  ({double lat, double lng}) geo = (lat: 39.9, lng: 116.4);
  print('${record.$1} 经纬度: (${geo.lat}, ${geo.lng})');
}
''', language: 'Dart'),
          OutputBox('姓名: 张三\n年龄: 25\n'
              '坐标: (10, 20)\n标签 at (1, 2)\n'
              'Alice 经纬度: (39.9, 116.4)'),
          TipBox('Records 非常适合函数返回多个值，'
              '相比创建新类更加轻量灵活。'
              '位置参数用 \$1、\$2 访问，命名参数用 .名称 访问。',
              type: TipType.tip),

          DividerLine(),
          SectionHeader('本章练习', icon: Icons.assignment),
          Paragraph('1. 声明 var、final、const 变量各一个，说出它们的区别。'),
          Paragraph('2. 创建一个可空的 String 变量，用 ?? 提供默认值。'),
          Paragraph('3. 用 r 原始字符串写一段包含反斜杠和美元符号的文本。'),
          Paragraph('4. 用 Records 创建（姓名，年龄，城市）三元组并访问每个字段。'),
          Paragraph('5. 用级联运算符在 StringBuffer 上连续添加三段文字。'),
          Paragraph('6. 用 is 检查一个 Object 是否为 int 类型。'),
          Paragraph('7. 用展开运算符 ... 将三个数组合并为一个新列表。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
