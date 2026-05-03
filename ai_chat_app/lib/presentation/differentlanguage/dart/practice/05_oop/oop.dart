library dart_oop;

import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

/// Dart 面向对象编程教程页面
/// 涵盖：类定义、构造函数、继承、抽象类、Mixin、接口、枚举、扩展方法、静态成员、运算符重载
class DartOOP extends StatelessWidget {
  const DartOOP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第5章 · 面向对象'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('面向对象编程（OOP）将数据和操作数据的方法封装在"对象"中。'
              'Dart 是纯面向对象语言——所有东西都是对象。'
              '本章深入讲解类的定义、继承、多态、Mixin、扩展方法等面向对象特性。'),

          // ============================================================
          // 1. 类定义与 Getter/Setter
          // ============================================================
          SectionHeader('1. 类定义与 Getter/Setter', icon: Icons.class_),
          Paragraph('class 定义类。Dart 提供简写构造函数语法（this.xxx）自动赋值。'
              'Getter 和 Setter 用于封装属性的读写访问，可以在访问时添加验证逻辑。'),
          CodeBlock(r'''
class Person {
  String name;   // 实例变量（字段）
  int _age;      // 私有字段（以下划线开头，仅在当前库可访问）

  // 简写构造函数：自动赋值给同名字段
  Person(this.name, int age) : _age = age;

  // Getter：像属性一样访问，但可以添加逻辑
  int get age => _age;

  // Setter：赋值时可以验证
  set age(int value) {
    if (value < 0 || value > 150) {
      throw ArgumentError('年龄必须在 0-150 之间');
    }
    _age = value;
  }

  // 计算属性（只读 Getter，没有对应的字段）
  bool get isAdult => _age >= 18;

  // 方法
  void sayHello() {
    print('你好，我是$name，今年${_age}岁');
  }

  // 私有方法（以下划线开头）
  void _internalCheck() {
    print('内部检查: $name');
  }
}

void main() {
  var p = Person('张三', 25);
  p.sayHello();                 // 你好，我是张三，今年25岁
  print('成年: ${p.isAdult}');  // true

  p.age = 30;                   // 通过 Setter 修改
  print('新年龄: ${p.age}');    // 通过 Getter 读取：30

  // p.age = 200;              // ❌ 抛出 ArgumentError：年龄超范围
}
''', language: 'Dart'),
          OutputBox('你好，我是张三，今年25岁\n成年: true\n新年龄: 30'),

          // ============================================================
          // 2. 构造函数进阶
          // ============================================================
          SectionHeader('2. 构造函数进阶', icon: Icons.add_box),
          Paragraph('Dart 支持多种构造函数：命名构造函数（多个构造方式）、'
              '重定向构造函数（委托给其他构造）、常量构造函数（编译时常量）'
              '和工厂构造函数（可返回缓存或子类实例）。'),
          CodeBlock(r'''
class Point {
  final int x, y;

  // 默认构造函数
  Point(this.x, this.y);

  // 命名构造函数：创建原点
  Point.origin() : x = 0, y = 0;

  // 命名构造函数：从 Map 创建
  Point.fromJson(Map<String, int> json)
      : x = json['x']!,
        y = json['y']!;

  // 重定向构造函数：委托给另一个构造函数
  Point.atOrigin() : this.origin();     // 委托给命名构造
  Point.zero() : this(0, 0);           // 委托给默认构造

  // 常量构造函数：可创建编译时常量（所有字段必须 final）
  const Point.constant(this.x, this.y);

  void show() => print('($x, $y)');
}

// 工厂构造函数
class Logger {
  static final Map<String, Logger> _cache = {};

  final String tag;

  // 工厂构造函数：可以返回缓存实例或子类实例
  factory Logger(String tag) {
    return _cache.putIfAbsent(tag, () => Logger._internal(tag));
  }

  // 私有命名构造函数：外部不能直接调用 new
  Logger._internal(this.tag);

  void log(String msg) => print('[$tag] $msg');
}

void main() {
  var p1 = Point(3, 4);
  var origin = Point.origin();
  var fromJson = Point.fromJson({'x': 10, 'y': 20});
  var zero = Point.zero();
  const constant = Point.constant(1, 1);  // 编译时常量

  p1.show();            // (3, 4)
  origin.show();        // (0, 0)
  fromJson.show();      // (10, 20)
  zero.show();          // (0, 0)

  // 工厂构造函数：相同的 tag 返回同一个实例
  var log1 = Logger('网络');
  var log2 = Logger('网络');
  print('同一个实例: ${identical(log1, log2)}');  // true
  log1.log('请求成功');  // [网络] 请求成功
  log2.log('响应成功');  // [网络] 响应成功（和 log1 是同一个对象）
}
''', language: 'Dart'),
          OutputBox('(3, 4)\n(0, 0)\n(10, 20)\n(0, 0)\n'
              '同一个实例: true\n[网络] 请求成功\n[网络] 响应成功'),
          TipBox('工厂构造函数（factory）不一定会创建新实例。'
              '它常用于：返回缓存的对象、返回子类的实例、'
              '或在创建前执行复杂逻辑。使用 factory 关键字后可以不写 return。'
              , type: TipType.info),

          // ============================================================
          // 3. 初始化列表与级联表示法
          // ============================================================
          SectionHeader('3. 初始化列表与级联表示法', icon: Icons.format_list_numbered),
          Paragraph('初始化列表（Initializer list）在构造函数体执行前执行，'
              '用于初始化 final 字段、执行 assert 验证或调用父类构造。'
              '级联表示法（..）允许在同一个对象上连续调用多个方法，代码更简洁。'),
          CodeBlock(r'''
class Dog {
  String name;
  int age;
  String breed;

  // 初始化列表：在构造函数体之前执行
  // 可以用于 assert 验证、给 final 字段赋值
  Dog(this.name, this.age, this.breed)
      : assert(age > 0, '年龄必须大于 0'),
        assert(name.isNotEmpty, '名字不能为空') {
    print('$name 创建完成');
  }
}

// 级联表示法
class StringBuilder {
  final StringBuffer _buffer = StringBuffer();

  StringBuilder write(String text) {
    _buffer.write(text);
    return this;  // 返回 this 支持链式调用
  }

  StringBuilder writeLine(String text) {
    _buffer.writeln(text);
    return this;
  }

  @override
  String toString() => _buffer.toString();
}

void main() {
  // 级联表示法 .. 在同一个对象上连续操作
  var sb = StringBuilder()
    ..write('Hello')        // 返回 StringBuilder 实例本身
    ..writeLine(' World')   // 继续操作同一个对象
    ..write('!');
  print(sb);  // Hello World\n!

  // 级联也可以调用父类方法或调用 setter
  var dog = Dog('旺财', 3, '金毛')
    ..age = 4                // 修改属性
    ..breed = '拉布拉多';     // 继续修改
  print('${dog.name} 今年 ${dog.age} 岁');
}
''', language: 'Dart'),
          OutputBox('旺财 创建完成\nHello World\n!\n旺财 今年 4 岁'),

          // ============================================================
          // 4. 继承与多态
          // ============================================================
          SectionHeader('4. 继承与多态', icon: Icons.account_tree),
          Paragraph('extends 实现继承，子类复用父类的属性和方法。'
              'super 调用父类构造函数和方法，@override 重写方法实现多态。'
              'covariant 关键字允许子类在重写时使用更具体的参数类型。'),
          CodeBlock(r'''
class Animal {
  String name;
  Animal(this.name);

  void speak() => print('$name 发出声音');
  void eat() => print('$name 在吃东西');
}

// covariant：允许子类重写时使用更具体的类型
class AnimalTrainer {
  void train(covariant Animal animal) {
    print('训练: ${animal.name}');
  }
}

class Dog extends Animal {
  String breed;

  // super.name 将参数传递给父类构造函数
  Dog(String name, this.breed) : super(name);

  // @override 重写父类方法
  @override
  void speak() => print('$name（$breed）: 汪汪！');

  // super 调用父类被重写的方法
  void parentSpeak() => super.speak();

  // 子类新增方法
  void fetch() => print('$name 捡球');
}

class Puppy extends Dog {
  Puppy(String name) : super(name, '幼犬');

  @override
  void speak() => print('$name: 嗷嗷！');
}

void main() {
  var dog = Dog('旺财', '金毛');
  var puppy = Puppy('小黄');

  // 多态：父类引用指向子类对象
  Animal animal = dog;
  animal.speak();     // 实际调用子类重写的方法
  animal.eat();       // 继承自父类的方法
  // animal.fetch();  // ❌ 编译错误：Animal 类型没有 fetch 方法

  // super 调用父类版本
  dog.parentSpeak();  // 旺财 发出声音

  // covariant 的使用
  var trainer = AnimalTrainer();
  trainer.train(dog);    // Dog 是 Animal 的子类型
  trainer.train(puppy);  // Puppy 也是 Animal 的子类型

  // is / as 类型判断和转换
  if (animal is Dog) {
    animal.fetch();  // 类型提升后可以调用 Dog 特有的方法
  }

  print(puppy.speak());  // 小黄: 嗷嗷！
}
''', language: 'Dart'),
          OutputBox('旺财（金毛）: 汪汪！\n旺财 在吃东西\n'
              '旺财 发出声音\n训练: 旺财\n'
              '训练: 小黄\n旺财 捡球\n小黄: 嗷嗷！'),

          // ============================================================
          // 5. 抽象类与接口
          // ============================================================
          SectionHeader('5. 抽象类与接口', icon: Icons.dashboard),
          Paragraph('abstract class 定义抽象类，不能直接实例化。'
              '抽象方法只有声明没有实现，子类必须实现所有抽象方法。'
              'implements 实现隐式接口——Dart 没有 interface 关键字，'
              '每个类都隐式定义了一个接口。一个类可以实现多个接口。'),
          CodeBlock(r'''
// 抽象类
abstract class Shape {
  // 抽象方法：没有方法体，子类必须实现
  double getArea();

  // 抽象 getter
  String get shapeName;

  // 普通方法：有实现，子类可以重写
  void describe() {
    print('$shapeName 的面积是 ${getArea()}');
  }
}

// 继承抽象类：必须实现所有抽象成员
class Circle extends Shape {
  double radius;
  Circle(this.radius);

  @override
  double getArea() => 3.14 * radius * radius;

  @override
  String get shapeName => '圆形';
}

// 隐式接口：每个类都是一个接口
class Printer {
  void printDoc(String doc) {
    print('打印: $doc');
  }

  void scanDoc(String doc) {
    print('扫描: $doc');
  }
}

// implements 实现多个接口
abstract class Drawable {
  void draw();
}

class MultiFunctionPrinter implements Printer, Drawable {
  @override
  void printDoc(String doc) {
    print('多功能打印机: $doc');
  }

  @override
  void scanDoc(String doc) {
    print('多功能扫描: $doc');
  }

  @override
  void draw() {
    print('画图模式');
  }
}

void main() {
  var circle = Circle(10);
  circle.describe();  // 圆形 的面积是 314.0

  var mfp = MultiFunctionPrinter();
  mfp.printDoc('报告');
  mfp.draw();
}
''', language: 'Dart'),
          OutputBox('圆形 的面积是 314.0\n多功能打印机: 报告\n画图模式'),
          TipBox('implements 和 extends 的区别：implements 只继承接口（必须重写所有方法），'
              'extends 继承实现（可以复用父类的方法）。'
              '一个类可以 implements 多个接口，但只能 extends 一个父类。'
              , type: TipType.info),

          // ============================================================
          // 6. Mixin（混入）
          // ============================================================
          SectionHeader('6. Mixin（混入）', icon: Icons.extension),
          Paragraph('Mixin 用 mixin 声明，用 with 使用。可以在不修改继承链的前提下'
              '为类添加功能。on 关键字限制 mixin 只能用于特定子类。'
              'Dart 3 的 mixin class 既是 mixin 又是普通类。'),
          CodeBlock(r'''
// 基本 Mixin
mixin Flyable {
  void fly() => print('我会飞！');
}

mixin Swimmable {
  void swim() => print('我会游泳！');
}

// on 关键字：这个 Mixin 只能用于 Animal 的子类
mixin Walkable on Animal {
  void walk() => print('$name 在走路');
}

class Animal {
  String name;
  Animal(this.name);
}

// with 混入多个功能（搭积木）
class Duck extends Animal with Flyable, Swimmable, Walkable {
  Duck(String name) : super(name);
}

// on 条件限制：只有 Animal 的子类才能用 Walkable
class Person2 extends Animal with Walkable {
  Person2(String name) : super(name);
}

// Dart 3：mixin class 既是普通类也是 mixin
mixin class Printable {
  void printInfo() => print('可打印对象: $runtimeType');
}

class Document with Printable {}

// mixin class 也可以直接实例化
void main() {
  var duck = Duck('唐老鸭');
  duck.fly();       // 我会飞！
  duck.swim();      // 我会游泳！
  duck.walk();      // 唐老鸭 在走路（调用了 Walkable 的 walk）

  var person = Person2('小明');
  person.walk();    // 小明 在走路

  var doc = Document();
  doc.printInfo();  // 可打印对象: Document

  // mixin class 可以直接实例化
  var p = Printable();
  p.printInfo();    // 可打印对象: Printable
}
''', language: 'Dart'),
          OutputBox('我会飞！\n我会游泳！\n唐老鸭 在走路\n小明 在走路\n'
              '可打印对象: Document\n可打印对象: Printable'),
          TipBox('Mixin 解决多重继承的菱形问题。与 Java 接口不同，'
              'Dart Mixin 可以包含方法和字段。'
              'mixin class 是 Dart 3 的新特性，让一个类型既可以作 mixin 也可以当普通类。'
              , type: TipType.tip),

          // ============================================================
          // 7. 枚举增强
          // ============================================================
          SectionHeader('7. 枚举增强（Dart 3+）', icon: Icons.list_alt),
          Paragraph('Dart 2.17+ 支持增强枚举，可以带字段、构造方法和实例方法。'
              '这让枚举的表达能力大大增强，可以携带丰富的数据和行为。'),
          CodeBlock(r'''
// 增强枚举：带字段和方法
enum Status {
  loading('加载中'),
  success('成功'),
  error('失败'),
  idle('空闲');

  final String label;

  // 常量构造函数
  const Status(this.label);

  // 枚举方法
  bool get isLoading => this == Status.loading;
  bool get isError => this == Status.error;
  bool get isSuccess => this == Status.success;

  // Getter 返回描述
  String get description {
    switch (this) {
      case Status.loading: return '正在加载数据...';
      case Status.success: return '操作成功完成';
      case Status.error: return '操作失败，请重试';
      case Status.idle: return '等待用户操作';
    }
  }
}

// 带多个字段的枚举
enum Planet {
  mercury(3.303e23, 2.4397e6),
  venus(4.869e24, 6.0518e6),
  earth(5.976e24, 6.37814e6),
  mars(6.421e23, 3.3972e6);

  final double mass;    // 质量（kg）
  final double radius;  // 半径（m）

  const Planet(this.mass, this.radius);

  // 计算属性
  double get density => mass / (4 / 3 * 3.14159 * radius * radius * radius);
}

void main() {
  var status = Status.loading;
  print('标签: ${status.label}');          // 加载中
  print('是否加载中: ${status.isLoading}'); // true
  print('描述: ${status.description}');     // 正在加载数据...

  // 遍历所有枚举值
  for (var s in Status.values) {
    print('${s.name}: ${s.label}');
  }

  // 增强枚举的字段访问
  print('\n--- 行星密度 ---');
  for (var planet in Planet.values) {
    print('${planet.name}: ${planet.density.toStringAsFixed(2)} kg/m3');
  }
}
''', language: 'Dart'),
          OutputBox('标签: 加载中\n是否加载中: true\n描述: 正在加载数据...\n'
              'loading: 加载中\nsuccess: 成功\nerror: 失败\nidle: 空闲\n\n'
              '--- 行星密度 ---\nmercury: 5427.09 kg/m3\n'
              'venus: 5242.32 kg/m3\nearth: 5514.67 kg/m3\n'
              'mars: 3933.39 kg/m3'),

          // ============================================================
          // 8. 扩展方法
          // ============================================================
          SectionHeader('8. 扩展方法', icon: Icons.extension),
          Paragraph('extension 可以为现有类型添加新方法，即使是第三方库或系统库的类型。'
              '扩展方法让代码更加流畅自然，而无需修改原始类。'
              '还支持泛型扩展，适用于集合等泛型类型。'),
          CodeBlock(r'''
// 为 String 添加扩展方法
extension StringExtension on String {
  // 判断是否为邮箱
  bool get isEmail => contains('@') && contains('.');

  // 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  // 反转字符串
  String get reversed => split('').reversed.join('');

  // 是否包含大写字母
  bool get hasUpperCase => this != toLowerCase();

  // 截取前 N 个字符，不够则补指定字符
  String padLeftWith(int length, [String char = ' ']) {
    return padLeft(length, char);
  }
}

// 泛型扩展：适用于 List<T>
extension ListExtension<T> on List<T> {
  // 获取中间元素
  T? get middle {
    if (isEmpty) return null;
    return this[length ~/ 2];
  }

  // 随机打乱后返回新列表（不改变原列表）
  List<T> shuffled() {
    var list = toList();
    list.shuffle();
    return list;
  }

  // 安全获取元素
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

// 数字扩展
extension IntExtension on int {
  // 生成从 1 到 n 的列表
  List<int> get to => [for (var i = 1; i <= this; i++) i];

  // 判断是否为偶数
  bool get isEven => this % 2 == 0;

  // 重复字符串
  String repeat(String str) => str * this;
}

void main() {
  // String 扩展
  print('hello@example.com 是邮箱: ${'hello@example.com'.isEmail}');
  print('hello world'.capitalize);  // Hello world
  print('dart'.reversed);           // trad

  // List 扩展
  var list = [1, 2, 3, 4, 5];
  print('中间元素: ${list.middle}');       // 3
  print('打乱: ${list.shuffled()}');       // 随机顺序
  print('安全获取[10]: ${list.safeGet(10)}');  // null（不抛异常）

  // Int 扩展
  print('1..5: ${5.to}');                  // [1, 2, 3, 4, 5]
  print('5.isEven: ${5.isEven}');          // false
  print('重复: ${3.repeat('哈')}');         // 哈哈哈
}
''', language: 'Dart'),
          OutputBox('hello@example.com 是邮箱: true\nHello world\ntrad\n'
              '中间元素: 3\n打乱: [1, 3, 5, 2, 4]\n'
              '安全获取[10]: null\n1..5: [1, 2, 3, 4, 5]\n'
              '5.isEven: false\n重复: 哈哈哈'),

          // ============================================================
          // 9. 静态成员
          // ============================================================
          SectionHeader('9. 静态成员', icon: Icons.electric_bolt),
          Paragraph('static 声明属于类本身的成员，不依赖任何实例。'
              '通过类名直接访问，无需创建对象。'
              'static const 定义编译时常量，static 方法不能访问非静态成员。'),
          CodeBlock(r'''
class MathUtils {
  // 静态常量（编译时常量）
  static const double pi = 3.141592653589793;
  static const double e = 2.718281828459045;

  // 静态变量
  static int instanceCount = 0;

  // 静态方法
  static int add(int a, int b) => a + b;

  // 静态方法可以递归
  static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }

  // 静态方法只能访问静态成员
  static double circleArea(double radius) {
    return pi * radius * radius;  // 可以访问静态常量 pi
  }
}

class Counter {
  static int _total = 0;

  final String name;
  int count = 0;

  Counter(this.name);

  void increment() {
    count++;
    _total++;  // 实例方法可以访问静态变量
  }

  // 静态方法
  static int get total => _total;
}

void main() {
  print('π = ${MathUtils.pi}');             // 3.14159...
  print('e = ${MathUtils.e}');              // 2.71828...
  print('3 + 5 = ${MathUtils.add(3, 5)}');  // 8
  print('5! = ${MathUtils.factorial(5)}');  // 120
  print('圆面积: ${MathUtils.circleArea(5)}');  // 78.5398...

  // 静态变量统计实例
  var c1 = Counter('A')..increment()..increment();
  var c2 = Counter('B')..increment();
  print('总计数: ${Counter.total}');  // 3（两个实例的增量之和）
}
''', language: 'Dart'),
          OutputBox('π = 3.141592653589793\ne = 2.718281828459045\n'
              '3 + 5 = 8\n5! = 120\n圆面积: 78.53981633974483\n'
              '总计数: 3'),

          // ============================================================
          // 10. 运算符重载
          // ============================================================
          SectionHeader('10. 运算符重载', icon: Icons.calculate),
          Paragraph('Dart 允许使用 operator 关键字重载运算符。'
              '通过重载 +、-、*、==、[] 等运算符，让自定义类型支持'
              '自然的算术运算和比较操作。'),
          CodeBlock(r'''
import 'dart:math' as Math;

class Vector2 {
  final double x, y;

  const Vector2(this.x, this.y);

  // 重载 + 运算符
  Vector2 operator +(Vector2 other) {
    return Vector2(x + other.x, y + other.y);
  }

  // 重载 - 运算符（二元）
  Vector2 operator -(Vector2 other) {
    return Vector2(x - other.x, y - other.y);
  }

  // 重载 * 运算符（标量乘法）
  Vector2 operator *(double scalar) {
    return Vector2(x * scalar, y * scalar);
  }

  // 重载 - 运算符（一元负号）
  Vector2 operator -() => Vector2(-x, -y);

  // 重载 == 比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector2 && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  // 重载 []（索引运算符）
  double operator [](int index) {
    if (index == 0) return x;
    if (index == 1) return y;
    throw IndexError(index, this);
  }

  // 重载 [] 的 setter（索引赋值）
  void operator []=(int index, double value) {
    throw UnsupportedError('Vector2 是不可变的');
  }

  // 欧几里得长度（只读属性，不是运算符）
  double get length => Math.sqrt(x * x + y * y);

  @override
  String toString() => 'Vector2($x, $y)';
}

void main() {
  var v1 = Vector2(1, 2);
  var v2 = Vector2(3, 4);

  print('v1 + v2 = ${v1 + v2}');     // Vector2(4, 6)
  print('v1 - v2 = ${v1 - v2}');     // Vector2(-2, -2)
  print('v1 * 3 = ${v1 * 3}');       // Vector2(3, 6)
  print('-v1 = ${-v1}');             // Vector2(-1, -2)

  // == 比较
  print('v1 == Vector2(1,2): ${v1 == Vector2(1, 2)}');  // true
  print('v1 == v2: ${v1 == v2}');                         // false

  // [] 索引
  print('v1[0] = ${v1[0]}');         // 1
  print('v1[1] = ${v1[1]}');         // 2

  // 长度
  print('|v2| = ${v2.length}');      // 5.0
}
''', language: 'Dart'),
          OutputBox('v1 + v2 = Vector2(4, 6)\nv1 - v2 = Vector2(-2, -2)\n'
              'v1 * 3 = Vector2(3, 6)\n-v1 = Vector2(-1, -2)\n'
              'v1 == Vector2(1,2): true\nv1 == v2: false\n'
              'v1[0] = 1\nv1[1] = 2\n|v2| = 5.0'),

          DividerLine(),
          SectionHeader('小练习', icon: Icons.assignment),
          Paragraph('1. 定义 Car 类，用 Getter/Setter 封装 speed 属性，限制速度 0-300。'),
          Paragraph('2. 为 Car 添加 factory 构造函数，缓存已创建的实例。'),
          Paragraph('3. 创建 Animal -> Dog -> Puppy 继承链，用 covariant 修饰参数。'),
          Paragraph('4. 定义 Loggable 和 Serializable 两个 Mixin，并用在 User 类上。'),
          Paragraph('5. 为 String 添加扩展方法 isUrl，判断字符串是否为合法 URL。'),
          Paragraph('6. 定义 Complex 复数类，重载 +、-、* 运算符，实现复数运算。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
