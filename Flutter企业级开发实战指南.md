# Flutter 企业级开发实战指南

> 面向零基础新手，从入门到构建生产级 Flutter 应用
> 适用平台：Android / iOS / Web / Windows / macOS / Linux

---

## 目录

1. [Flutter 是什么](#1-flutter-是什么)
2. [开发环境搭建](#2-开发环境搭建)
3. [Dart 语言速通](#3-dart-语言速通)
4. [Flutter 核心：一切皆 Widget](#4-flutter-核心一切皆-widget)
5. [布局系统详解](#5-布局系统详解)
6. [状态管理](#6-状态管理)
7. [路由与导航](#7-路由与导航)
8. [网络请求与数据通信](#8-网络请求与数据通信)
9. [本地数据持久化](#9-本地数据持久化)
10. [项目架构设计](#10-项目架构设计)
11. [依赖注入](#11-依赖注入)
12. [主题与样式](#12-主题与样式)
13. [表单与输入](#13-表单与输入)
14. [动画](#14-动画)
15. [平台通道与原生交互](#15-平台通道与原生交互)
16. [测试](#16-测试)
17. [性能优化](#17-性能优化)
18. [打包与发布](#18-打包与发布)
19. [CI/CD 与自动化](#19-cicd-与自动化)
20. [企业级最佳实践](#20-企业级最佳实践)

---

## 1. Flutter 是什么

### 1.1 定义

Flutter 是 Google 推出的**开源 UI 工具包**，用于从同一份代码构建**跨平台**应用。

| 特性 | 说明 |
|------|------|
| 一套代码 | 写一次，运行在 Android、iOS、Web、Windows、macOS、Linux |
| 高性能 | 使用 Skia 图形引擎直接绘制，不依赖平台原生控件 |
| 热重载 | 修改代码后秒级生效，无需重新编译 |
| 声明式 UI | 用 Dart 语言描述界面，UI 是状态的函数 |

### 1.2 与传统开发对比

```
传统开发:
  Android (Java/Kotlin) + iOS (Swift) + Web (React/Vue) = 3 个团队

Flutter:
  1 个 Flutter 团队 = 覆盖所有平台
```

### 1.3 Flutter vs React Native vs 原生

| 维度 | Flutter | React Native | 原生开发 |
|------|---------|-------------|---------|
| 性能 | 接近原生（自绘引擎） | 依赖 JS Bridge，有损耗 | 最高 |
| 跨平台覆盖面 | 6 个平台 | 3 个平台 | 每个平台独立 |
| 学习曲线 | 学 Dart+Flutter | 学 React+JS | 学各平台语言 |
| 开发效率 | 高（热重载） | 高（Fast Refresh） | 低 |
| 企业应用 | 闲鱼、谷歌支付、宝马 | Facebook、Instagram | 大厂核心应用 |

### 1.4 适用场景

**适合用 Flutter 的场景：**
- 跨平台移动应用（MVP 快速验证）
- 企业级内部工具
- 需要同时覆盖桌面和移动的产品
- UI 一致性要求高的应用

**不适合的场景：**
- 重度原生功能调用（AR、蓝牙深度定制）
- 对包体积极其敏感
- 已有成熟的原生团队和代码库

---

## 2. 开发环境搭建

### 2.1 安装 Flutter SDK

**Windows 安装步骤：**

1. 访问 https://docs.flutter.dev/get-started/install
2. 下载 Flutter SDK 压缩包
3. 解压到 `C:\src\flutter`（或其他路径）
4. 将 `C:\src\flutter\bin` 添加到系统环境变量 PATH 中
5. 打开终端运行 `flutter doctor` 验证

**macOS / Linux 安装：**

```bash
# macOS (Intel)
cd ~
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.x.x-stable.zip

# 解压后添加到 PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2.2 安装 IDE

**推荐 VS Code：**
- 安装 Flutter 扩展（Dart 代码补全、热重载、调试）
- 安装 Android iOS Emulator 管理插件

**Android Studio 也可：**
- 内置 Flutter 和 Dart 插件
- 更完善的 Android 开发工具链

### 2.3 配置平台工具

**Android 开发：**
- 安装 Android Studio
- 在 SDK Manager 中安装 Android SDK
- 配置 Android 模拟器（AVD）或连接真机

**iOS 开发（仅 macOS）：**
- 安装 Xcode（App Store）
- 安装 CocoaPods：`sudo gem install cocoapods`

**Web 开发：**
- 安装 Chrome 浏览器

**Windows 桌面开发：**
- 安装 Visual Studio（需要"使用 C++ 的桌面开发"工作负载）
- 或安装 Windows SDK

### 2.4 验证环境

```bash
flutter doctor
```

理想输出（所有项目打勾）：

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on ...)
[✓] Windows Version (Windows 11 ...)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] VS Code (version x.x.x)
[✓] Connected device (2 available)
```

### 2.5 创建第一个项目

```bash
flutter create my_app
cd my_app
flutter run
```

---

## 3. Dart 语言速通

Flutter 使用 Dart 语言。你不需要成为 Dart 专家，但需要掌握核心概念。

### 3.1 Hello Dart

```dart
// 这是单行注释

/// 这是文档注释（用于生成文档）

void main() {
  print('Hello, Flutter!');
}
```

### 3.2 变量与类型

```dart
// 显式类型
String name = '张三';
int age = 28;
double height = 175.5;
bool isActive = true;

// 类型推断（推荐）
var city = '北京';         // 自动推断为 String
final country = '中国';    // 只能赋值一次（运行时确定）
const pi = 3.14159;        // 编译时常量

// 空安全（Null Safety）
String? nullableName;      // ? 表示可以为 null
String nonNull = '必须赋值'; // 不可为 null

// 安全访问
print(nullableName?.length); // 如果为 null，返回 null，不抛异常
print(nonNull.length);       // 总是安全的

// ?? 操作符：如果左边为 null，用右边
String displayName = nullableName ?? '默认名称';

// late 关键字：延迟初始化
late String lazyValue;
lazyValue = '稍后才赋值';
```

### 3.3 集合类型

```dart
// 列表 List（类似于数组）
List<String> fruits = ['苹果', '香蕉', '橘子'];
var numbers = [1, 2, 3, 4, 5];

fruits.add('草莓');
fruits.remove('香蕉');
print(fruits[0]);      // 苹果
print(fruits.length);  // 3

// 集合 Set（无重复元素）
Set<String> tags = {'flutter', 'dart', 'mobile'};
tags.add('flutter');  // 重复添加无效

// 映射 Map（键值对）
Map<String, dynamic> user = {
  'name': '张三',
  'age': 28,
  'isAdmin': false,
};
print(user['name']);  // 张三
user['email'] = 'zhangsan@example.com';

// 集合推导式
var squares = [for (var i = 1; i <= 5; i++) i * i]; // [1, 4, 9, 16, 25]
var evenNumbers = numbers.where((n) => n.isEven).toList();
```

### 3.4 函数

```dart
// 基本函数
int add(int a, int b) {
  return a + b;
}

// 箭头函数（单表达式）
int multiply(int a, int b) => a * b;

// 命名参数（推荐用于 Flutter Widget）
void greet({required String name, int age = 18}) {
  print('你好 $name，年龄 $age');
}

// 调用命名参数
greet(name: '张三', age: 28);
greet(name: '李四');  // age 使用默认值 18

// 可选位置参数
void log(String message, [String? level]) {
  print('[$level] $message');
}

// 函数作为参数（高阶函数）
void execute(Function callback) {
  callback();
}

// 匿名函数
fruits.forEach((fruit) {
  print(fruit);
});
```

### 3.5 类与对象

```dart
// 基础类
class User {
  final String name;
  final int age;
  final String? email;

  // 构造函数
  User({required this.name, required this.age, this.email});

  // 命名构造函数
  User.guest()
      : name = '游客',
        age = 0;

  // 方法
  String get displayName => '$name ($age岁)';

  void sayHello() {
    print('大家好，我是$name');
  }

  // 工厂构造函数
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  // 转为 JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };
}

// 继承
class AdminUser extends User {
  final String role;

  AdminUser({required super.name, required super.age, required this.role});

  @override
  void sayHello() {
    print('我是管理员 $name，角色 $role');
  }
}
```

### 3.6 异步编程

Dart 是单线程模型，但通过 `async/await` 实现非阻塞。

```dart
// Future：表示一个未来的值
Future<String> fetchUserData() async {
  // 模拟网络请求
  await Future.delayed(Duration(seconds: 2));
  return '用户数据';
}

// async/await 使用
void loadData() async {
  print('开始加载...');
  String data = await fetchUserData();
  print('加载完成: $data');
}

// 并行执行
void loadMultiple() async {
  var results = await Future.wait([
    fetchUserData(),
    fetchUserData(),
  ]);
}

// Stream：数据流（多个值的序列）
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;  // 发射一个值
  }
}

void listenToStream() {
  countStream(5).listen((value) {
    print('计数: $value');
  });
}
```

### 3.7 常用操作符

```dart
// 级联操作符 .. 链式调用
var user = User(name: '张三', age: 28)
  ..sayHello()
  ..email = 'new@email.com';

// 展开操作符 ...
var allFruits = [...fruits, '西瓜', '葡萄'];

// 空感知操作符
String? nullable;
print(nullable?.length ?? 0);  // 如果为 null 用 0

// 类型转换 as
dynamic value = 'hello';
String text = value as String;
```

### 3.8 枚举

```dart
enum AppTheme { light, dark, system }

// Dart 3 增强枚举
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String value;
  const HttpMethod(this.value);
}
```

### 3.9 扩展方法

```dart
// 给现有类型添加方法
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  bool get isValidEmail => contains('@');
}

// 使用
print('hello'.capitalize);       // Hello
print('test@email.com'.isValidEmail); // true
```

---

## 4. Flutter 核心：一切皆 Widget

### 4.1 Widget 哲学

在 Flutter 中，**一切皆是 Widget**。按钮是 Widget，文字是 Widget，边距是 Widget，甚至整个应用也是 Widget。

```
Widget 层级示例:
MaterialApp
 └── Scaffold
      ├── AppBar (标题栏)
      ├── body: Column
      │    ├── Text("Hello")
      │    ├── SizedBox(height: 16)
      │    └── ElevatedButton("点击")
      └── bottomNavigationBar: BottomNavigationBar
```

### 4.2 StatelessWidget vs StatefulWidget

**StatelessWidget（无状态）：** UI 一旦创建就不变化。

```dart
class GreetingText extends StatelessWidget {
  final String name;

  const GreetingText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('你好，$name！');
  }
}
```

**StatefulWidget（有状态）：** UI 可以随时间变化。

```dart
class CounterButton extends StatefulWidget {
  const CounterButton({super.key});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int _count = 0;  // 状态变量

  void _increment() {
    setState(() {
      _count++;  // 通知 Flutter 重新构建
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('点击了 $_count 次'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('点击'),
        ),
      ],
    );
  }
}
```

核心原则：**状态改变 → 调用 setState → 触发 build → UI 更新**。

### 4.3 常用基础 Widget

```dart
// 文本
Text(
  'Hello Flutter',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
);

// 图片
Image.network('https://example.com/image.png');
Image.asset('assets/images/logo.png');  // 需要先在 pubspec.yaml 声明

// 图标
Icon(Icons.favorite, color: Colors.red, size: 32);

// 按钮
ElevatedButton(
  onPressed: () {},
  child: const Text('凸起按钮'),
);

TextButton(
  onPressed: () {},
  child: const Text('文字按钮'),
);

OutlinedButton(
  onPressed: () {},
  child: const Text('边框按钮'),
);

IconButton(
  onPressed: () {},
  icon: const Icon(Icons.settings),
);

// 输入框
TextField(
  controller: _controller,
  decoration: const InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
);
```

### 4.4 Widget 生命周期

对于 StatefulWidget：

```
createState()          → 创建状态对象
initState()            → 初始化（只调用一次）
didChangeDependencies() → 依赖改变时（如 InheritedWidget）
build()                → 构建 UI（可调用多次）
didUpdateWidget()      → Widget 配置改变时
setState()             → 手动触发重绘
dispose()              → 销毁（清理资源）
```

```dart
class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  @override
  void initState() {
    super.initState();
    print('initState: 初始化，比如订阅数据流');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies: 依赖的 InheritedWidget 变了');
  }

  @override
  void didUpdateWidget(LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget: Widget 重建了');
  }

  @override
  void dispose() {
    print('dispose: 清理 Controller、Stream 等');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('生命周期示例');
  }
}
```

### 4.5 BuildContext

`BuildContext` 是 Widget 在 Widget 树中的位置引用。通过它你可以：

- 访问主题：`Theme.of(context)`
- 导航：`Navigator.of(context)`
- 查找祖先 Widget：`context.findAncestorWidgetOfExactType<T>()`

```dart
@override
Widget build(BuildContext context) {
  // 通过 BuildContext 获取主题色
  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;

  return Text(
    '主题色',
    style: TextStyle(color: primaryColor),
  );
}
```

---

## 5. 布局系统详解

### 5.1 布局的核心机制

Flutter 的布局遵循**约束向下，大小向上**的原则：

```
父 Widget 向子 Widget 传递"约束"（最大/最小宽高）
    ↓
子 Widget 根据约束决定自己的"大小"
    ↑
父 Widget 根据子 Widget 的大小进行定位
```

### 5.2 单子布局 Widget

```dart
// Center：居中
Center(child: Text('居中'))

// Padding：内边距
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Text('有边距'),
)

// EdgeInsets 的多种写法
EdgeInsets.all(16)                          // 四周相同
EdgeInsets.symmetric(horizontal: 16)        // 水平方向
EdgeInsets.symmetric(vertical: 8)           // 垂直方向
EdgeInsets.only(left: 16, top: 8)           // 单独指定
EdgeInsets.fromLTRB(16, 8, 16, 8)           // 左上右下

// Align：对齐
Align(
  alignment: Alignment.bottomRight,
  child: Text('右下角'),
)

// SizedBox：固定尺寸
SizedBox(width: 200, height: 100, child: ...)
SizedBox(height: 16)  // 仅用于间距（无子 Widget）

// ConstrainedBox：附加约束
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
  ),
  child: Text('有约束'),
)

// DecoratedBox：装饰
DecoratedBox(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(color: Colors.black26, blurRadius: 4),
    ],
  ),
  child: Text('带装饰'),
)
```

### 5.3 多子布局 Widget

```dart
// Row：水平排列
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // 主轴（水平）对齐
  crossAxisAlignment: CrossAxisAlignment.center,     // 交叉轴（垂直）对齐
  children: [
    Icon(Icons.star),
    Icon(Icons.star),
    Icon(Icons.star),
  ],
)

// Column：垂直排列（参数同 Row）
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('第一行'),
    Text('第二行'),
  ],
)

// Stack：层叠（子 Widget 可以重叠）
Stack(
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    Positioned(
      top: 20,
      right: 20,
      child: Text('浮动标签'),
    ),
  ],
)

// Expanded：占满剩余空间（用于 Row/Column 内）
Row(
  children: [
    Text('左侧'),
    Expanded(child: Container(color: Colors.red)),
    Text('右侧'),
  ],
)

// Flexible：按比例分配剩余空间
Row(
  children: [
    Flexible(flex: 2, child: ContainerA),
    Flexible(flex: 1, child: ContainerB),
  ],
)

// Wrap：自动换行
Wrap(
  spacing: 8,
  runSpacing: 4,
  children: [
    Chip(label: Text('标签1')),
    Chip(label: Text('标签2')),
    Chip(label: Text('标签3')),
  ],
)

// ListView：可滚动列表
ListView(
  children: [
    ListTile(title: Text('项目1')),
    ListTile(title: Text('项目2')),
  ],
)

// 性能优化：ListView.builder（按需构建，适合长列表）
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// GridView：网格布局
GridView.count(
  crossAxisCount: 2,
  children: [
    Card(child: Text('项目1')),
    Card(child: Text('项目2')),
  ],
)
```

### 5.4 BoxDecoration 详解

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    // 渐变
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 边框
    border: Border.all(
      color: Colors.grey,
      width: 1,
    ),
    // 圆角
    borderRadius: BorderRadius.circular(12),
    // 阴影
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: const Text('装饰容器'),
)
```

### 5.5 布局最佳实践

```dart
// ❌ 不要：层级过深
Container(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('标题'),
      ),
    ],
  ),
)

// ✅ 推荐：使用便捷属性
Padding(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('标题'),
      ),
    ],
  ),
)
```

---

## 6. 状态管理

状态管理是 Flutter 企业级开发中最重要的决策之一。

### 6.1 什么是状态

```
状态 = 影响 UI 的数据

本地状态：单个 Widget 内部使用（TextEditingController、动画进度）
共享状态：多个 Widget 共享（用户信息、购物车数据）
应用状态：全局共享（主题、语言设置）
```

### 6.2 setState（最简单的状态管理）

适用于局部状态，不需要跨组件共享。

```dart
class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : null,
      ),
      onPressed: () {
        setState(() {
          _isLiked = !_isLiked;
        });
      },
    );
  }
}
```

### 6.3 Riverpod（推荐方案）

本项目使用 `flutter_riverpod`，是目前 Flutter 社区最主流的状态管理方案。

#### 安装

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
```

#### Provider 类型一览

| Provider 类型 | 用途 | 场景 |
|-------------|------|------|
| `Provider` | 提供只读对象 | 配置、服务实例 |
| `StateProvider` | 简单状态 | 计数器、开关 |
| `StateNotifierProvider` | 复杂状态（已弃用，用 Notifier） | 表单、列表 |
| `NotifierProvider` | 复杂状态（推荐） | 业务逻辑 |
| `FutureProvider` | 异步数据 | API 请求结果 |
| `StreamProvider` | 流式数据 | WebSocket、实时数据 |
| `ChangeNotifierProvider` | 兼容 ChangeNotifier | 旧项目迁移 |

#### Provider（提供只读对象）

```dart
// 1. 定义 Provider
final apiProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: 'https://api.example.com');
});

// 2. 使用 Provider
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiProvider);
    return Text('API: ${api.baseUrl}');
  }
}
```

#### NotifierProvider（推荐用于业务逻辑）

```dart
// 1. 定义 Notifier
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;  // 初始值

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// 2. 定义 Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// 3. 使用
class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('计数: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('+1'),
        ),
      ],
    );
  }
}
```

#### 实战：用户信息管理

```dart
// ===== user_provider.dart =====
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 数据模型
class User {
  final String id;
  final String name;
  final String? avatar;
  final bool isLoggedIn;

  const User({
    required this.id,
    required this.name,
    this.avatar,
    this.isLoggedIn = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// 用户状态管理
class UserNotifier extends Notifier<User> {
  @override
  User build() {
    // 可以从本地缓存读取初始数据
    return const User(id: '', name: '', isLoggedIn: false);
  }

  Future<void> login(String username, String password) async {
    // 模拟登录
    state = User(
      id: '123',
      name: username,
      isLoggedIn: true,
    );
  }

  void logout() {
    state = const User(id: '', name: '', isLoggedIn: false);
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }
}

final userProvider = NotifierProvider<UserNotifier, User>(
  UserNotifier.new,
);

// ===== 使用 =====
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (!user.isLoggedIn) {
      return const LoginPrompt();
    }

    return Column(
      children: [
        Text('欢迎, ${user.name}'),
        ElevatedButton(
          onPressed: () => ref.read(userProvider.notifier).logout(),
          child: const Text('退出'),
        ),
      ],
    );
  }
}
```

#### FutureProvider（异步数据）

```dart
// 数据层
class Todo {
  final String id;
  final String title;
  final bool completed;

  const Todo({required this.id, required this.title, this.completed = false});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
    );
  }
}

// API 服务
class TodoService {
  Future<List<Todo>> fetchTodos() async {
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Todo(id: '1', title: '学习 Flutter'),
      const Todo(id: '2', title: '写代码'),
    ];
  }
}

// Provider
final todoServiceProvider = Provider<TodoService>((ref) => TodoService());

final todosProvider = FutureProvider<List<Todo>>((ref) async {
  final service = ref.read(todoServiceProvider);
  return service.fetchTodos();
});

// 使用
class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);

    return todosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
      data: (todos) => ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(todos[index].title));
        },
      ),
    );
  }
}
```

### 6.4 ref 的三种用法

```dart
class ExampleWidget extends ConsumerWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ref.watch() - 监听变化（在 build 中使用，值变时自动重建）
    final count = ref.watch(counterProvider);

    // 2. ref.read() - 一次性读取（不监听，在回调中使用）
    // 不要在 build 中使用 read 读取你关心的状态

    // 3. ref.listen() - 监听变化但不重建（执行副作用）
    ref.listen(counterProvider, (previous, next) {
      print('计数从 $previous 变为 $next');
    });

    return ElevatedButton(
      onPressed: () {
        // 正确的用法：回调中 read
        ref.read(counterProvider.notifier).increment();
      },
      child: const Text('点击'),
    );
  }
}
```

### 6.5 Provider 的自动释放

当没有任何 Widget 监听某个 Provider 时，Riverpod 会自动销毁它（`autoDispose`）。

```dart
// 默认自动释放
final userProvider = Provider.autoDispose<User>((ref) {
  return User(name: '张三');
});

// 也可以手动控制
final settingsProvider = NotifierProvider.autoDispose<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
```

### 6.6 其他状态管理方案对比

| 方案 | 复杂度 | 适用场景 |
|------|--------|---------|
| Riverpod ★ | 中等 | 企业级应用（首选） |
| Provider | 低 | 中小型应用 |
| Bloc | 高 | 大型团队，事件驱动 |
| GetX | 低 | 快速开发（注意：全局污染） |
| Redux | 高 | 大型应用，可预测状态 |

---

## 7. 路由与导航

### 7.1 基本导航

```dart
// 导航到新页面
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DetailPage()),
);

// 返回上一页
Navigator.pop(context);

// 传递参数到下一页
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailPage(id: '123'),
  ),
);

// 返回并传递结果
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => const SelectPage()),
);
```

### 7.2 GoRouter（推荐方案）

本项目使用 `go_router`，支持声明式路由、深度链接、嵌套导航。

#### 安装

```yaml
dependencies:
  go_router: ^14.8.1
```

#### 基本配置

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/detail/123'),
          child: const Text('查看详情'),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情 $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('返回'),
        ),
      ),
    );
  }
}

// 路由配置
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/detail/:id',  // :id 是路径参数
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailPage(id: id);
      },
    ),
  ],
);

// 应用入口
void main() {
  runApp(MaterialApp.router(
    routerConfig: router,
  ));
}
```

#### 导航方法

```dart
// context.go() - 替换当前路径（无返回按钮保存历史）
context.go('/settings');

// context.push() - 推入新页面（有返回按钮）
context.push('/detail/456');

// context.pop() - 返回上一页
context.pop();

// context.replace() - 替换当前页面（无返回）
context.replace('/login');

// 携带额外参数
context.push('/detail/789', extra: {'from': 'home'});
```

#### 嵌套路由与底部导航

```dart
// ===== app_router.dart =====
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 页面
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => _onTabTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/messages')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/messages');
      case 2: context.go('/profile');
    }
  }
}

// 路由配置
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    // 不在底部导航中的页面
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailPage(id: id);
      },
    ),
  ],
);
```

#### 重定向与鉴权

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    // 未登录且不在登录页 → 跳转到登录页
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // 已登录且在登录页 → 跳转到首页
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null; // 不拦截
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
  ],
);
```

---

## 8. 网络请求与数据通信

### 8.1 Dio（推荐）

本项目使用 `dio`，功能最强大的 Dart HTTP 客户端。

#### 安装

```yaml
dependencies:
  dio: ^5.7.0
```

#### 基础使用

```dart
import 'package:dio/dio.dart';

final dio = Dio();

// GET 请求
Future<void> getUsers() async {
  try {
    final response = await dio.get('https://api.example.com/users');
    print(response.data); // 自动解析 JSON
  } on DioException catch (e) {
    print('请求失败: ${e.message}');
  }
}

// POST 请求
Future<void> createUser() async {
  final response = await dio.post(
    'https://api.example.com/users',
    data: {'name': '张三', 'age': 28},
  );
}
```

#### 企业级封装

```dart
// ===== api_client.dart =====
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.post(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.put(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete(path);
  }
}

// ===== 鉴权拦截器 =====
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 从安全存储获取 token
    final token = 'your_token_here';
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token 过期，跳转登录
      print('需要重新登录');
    }
    handler.next(err);
  }
}

// ===== 日志拦截器 =====
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[请求] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[响应] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[错误] ${err.message}');
    handler.next(err);
  }
}

// ===== 错误处理拦截器 =====
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        message = '服务器响应超时';
      case DioExceptionType.badResponse:
        message = '服务器错误: ${err.response?.statusCode}';
      case DioExceptionType.cancel:
        message = '请求已取消';
      default:
        message = '网络异常，请稍后重试';
    }
    print(message);
    handler.next(err);
  }
}
```

#### 统一使用示例

```dart
// ===== 接口定义 =====
class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  Future<List<User>> getUsers() async {
    final response = await _client.get('/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<User> getUser(String id) async {
    final response = await _client.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> createUser({required String name, required int age}) async {
    final response = await _client.post('/users', data: {
      'name': name,
      'age': age,
    });
    return User.fromJson(response.data);
  }
}
```

### 8.2 数据模型与 JSON 序列化

```dart
// 手动序列化（简单模型）
class User {
  final String id;
  final String name;
  final int age;
  final String? email;

  const User({
    required this.id,
    required this.name,
    required this.age,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'email': email,
      };
}

// 使用 json_serializable（大型项目推荐）
// 1. 安装依赖
// pubspec.yaml:
//   dependencies:
//     json_annotation: ^4.9.0
//   dev_dependencies:
//     json_serializable: ^6.8.0
//     build_runner: ^2.4.0

// 2. 定义模型
// import 'package:json_annotation/json_annotation.dart';
// part 'user.g.dart';
//
// @JsonSerializable()
// class User {
//   final String id;
//   final String name;
//
//   User({required this.id, required this.name});
//
//   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
//   Map<String, dynamic> toJson() => _$UserToJson(this);
// }

// 3. 运行生成器
// flutter pub run build_runner build
```

### 8.3 Repository 模式

用 Repository 封装数据来源（网络、本地缓存），业务层不需要知道数据从哪里来。

```dart
// ===== user_repository.dart =====
class UserRepository {
  final UserApi _api;
  final UserLocalStorage _local;

  UserRepository(this._api, this._local);

  Future<List<User>> getUsers({bool forceRefresh = false}) async {
    // 优先返回缓存
    if (!forceRefresh) {
      final cached = await _local.getUsers();
      if (cached.isNotEmpty) return cached;
    }

    // 从网络获取
    final users = await _api.getUsers();

    // 缓存到本地
    await _local.saveUsers(users);

    return users;
  }
}

// ===== Provider =====
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.read(apiClientProvider);
  final local = ref.read(userLocalStorageProvider);
  return UserRepository(UserApi(api), local);
});
```

### 8.4 错误处理最佳实践

```dart
// ===== result.dart（统一返回类型）=====
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}

// ===== 使用 =====
Future<Result<List<User>>> fetchUsers() async {
  try {
    final users = await userRepository.getUsers();
    return Success(users);
  } catch (e) {
    return Failure('获取用户列表失败: $e');
  }
}

// ===== UI 层使用 =====
class UserListWidget extends ConsumerWidget {
  const UserListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(usersProvider).when(
          loading: () => const CircularProgressIndicator(),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                ElevatedButton(
                  onPressed: () => ref.invalidate(usersProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
          success: (users) => ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(users[index].name),
            ),
          ),
        );
  }
}
```

---

## 9. 本地数据持久化

### 9.1 shared_preferences（键值对）

适用于存储简单配置（用户偏好、token）。

```dart
import 'package:shared_preferences/shared_preferences.dart';

// 存储
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

// 读取
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

// 删除
Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}
```

### 9.2 flutter_secure_storage（安全存储）

适用于存储敏感信息（token、密码），加密存储。

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = const FlutterSecureStorage();

// 存储
await storage.write(key: 'jwt_token', value: 'your_jwt_token');

// 读取
final token = await storage.read(key: 'jwt_token');

// 删除
await storage.delete(key: 'jwt_token');

// 清空所有
await storage.deleteAll();
```

### 9.3 本地数据库（SQLite）

适用于结构化数据、需要查询的场景。

```dart
// 使用 sqflite 或 drift（推荐 drift）

// drift 示例：
// 1. 定义表
// @DataClassName('User')
// class Users extends Table {
//   TextColumn get id => text()();
//   TextColumn get name => text()();
//   IntColumn get age => integer()();
// }
//
// 2. 定义数据库
// @DriftDatabase(tables: [Users])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());
//
//   Future<List<User>> getAllUsers() => select(users).get();
//   Future<void> insertUser(UsersCompanion user) => into(users).insert(user);
// }
```

### 9.4 文件存储

适用于图片、文件等大体积数据。

```dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// 获取应用文档目录
Future<Directory> getDocumentsDir() async {
  return await getApplicationDocumentsDirectory();
}

// 写入文件
Future<void> saveToFile(String content) async {
  final dir = await getDocumentsDir();
  final file = File('${dir.path}/data.json');
  await file.writeAsString(content);
}

// 读取文件
Future<String> readFromFile() async {
  final dir = await getDocumentsDir();
  final file = File('${dir.path}/data.json');
  if (await file.exists()) {
    return await file.readAsString();
  }
  return '';
}
```

### 9.5 本地存储策略选择

| 方案 | 适合场景 | 不适合场景 |
|------|---------|-----------|
| SharedPreferences | 少量键值、用户设置 | 大量数据、敏感信息 |
| Secure Storage | Token、密码 | 大量数据 |
| 本地数据库 (SQLite/Drift) | 结构化数据、需查询 | 非常简单的配置 |
| 文件存储 | 图片、日志、大文件 | 频繁读写的小数据 |

---

## 10. 项目架构设计

### 10.1 推荐项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 根 Widget
│
├── core/                        # 核心基础设施
│   ├── constants/
│   │   ├── api_endpoints.dart   # API 地址常量
│   │   └── app_constants.dart   # 应用常量
│   ├── theme/
│   │   └── app_theme.dart       # 主题定义
│   ├── utils/
│   │   ├── validators.dart      # 表单验证工具
│   │   └── helpers.dart         # 通用帮助函数
│   └── network/
│       ├── api_client.dart      # Dio 封装
│       ├── interceptors.dart    # 拦截器
│       └── api_exceptions.dart  # 异常定义
│
├── data/                        # 数据层
│   ├── models/                  # 数据模型
│   │   ├── user.dart
│   │   └── todo.dart
│   ├── repositories/            # 仓库实现
│   │   ├── user_repository.dart
│   │   └── todo_repository.dart
│   └── datasources/             # 数据源
│       ├── remote/
│       │   ├── user_api.dart
│       │   └── todo_api.dart
│       └── local/
│           ├── user_storage.dart
│           └── database.dart
│
├── domain/                      # 领域层（可选）
│   ├── entities/                # 领域实体
│   ├── repositories/            # 仓库接口
│   └── usecases/                # 用例
│
├── presentation/                # 表现层
│   ├── providers/               # Riverpod Provider
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   └── settings_provider.dart
│   ├── router/
│   │   └── app_router.dart      # GoRouter 配置
│   ├── pages/                   # 页面（完整页面）
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── home_page_view.dart
│   │   ├── login/
│   │   │   └── login_page.dart
│   │   └── settings/
│   │       └── settings_page.dart
│   ├── widgets/                 # 可复用组件
│   │   ├── app_button.dart
│   │   ├── loading_overlay.dart
│   │   └── error_widget.dart
│   └── shared/                  # 共享组件
│       ├── app_scaffold.dart
│       └── app_drawer.dart
│
├── di/                          # 依赖注入
│   └── providers.dart           # 集中管理 Provider
│
└── l10n/                        # 国际化（可选）
    ├── app_en.arb
    └── app_zh.arb
```

### 10.2 各层职责

```
表现层（Presentation）：UI + 状态
    ↓ 调用
数据层（Data）：数据获取（网络/本地）
    ↓ 实现
领域层（Domain，可选）：业务规则
```

**表现层（Presentation）：**
- Flutter Widget + Riverpod Provider
- 只关心 UI 展示和用户交互
- 不直接调用 API 或数据库

**数据层（Data）：**
- Repository 模式封装数据来源
- DataSource 分为远程（API）和本地（数据库/文件）
- 处理数据转换（JSON → Model）

**核心层（Core）：**
- 主题、常量、工具函数
- 网络客户端封装
- 不包含业务逻辑

### 10.3 分层示例

```dart
// ===== 数据模型 =====
// data/models/user.dart
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );
}

// ===== 远程数据源 =====
// data/datasources/remote/user_api.dart
class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  Future<List<User>> fetchUsers() async {
    final response = await _client.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }
}

// ===== 仓库 =====
// data/repositories/user_repository.dart
class UserRepository {
  final UserApi _remoteApi;

  UserRepository(this._remoteApi);

  Future<List<User>> getUsers() async {
    return _remoteApi.fetchUsers();
  }
}

// ===== Provider =====
// presentation/providers/user_provider.dart
final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.read(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(userApiProvider));
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  return ref.read(userRepositoryProvider).getUsers();
});

// ===== 页面 =====
// presentation/pages/home/home_page.dart
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('错误: $e')),
      data: (users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) => Text(users[index].name),
      ),
    );
  }
}
```

---

## 11. 依赖注入

### 11.1 为什么需要依赖注入

```dart
// ❌ 不依赖注入：紧耦合，难以测试
class LoginPage {
  final api = UserApi();  // 直接创建依赖

  void login() {
    api.login();
  }
}

// ✅ 依赖注入：松耦合，易于测试
class LoginPage {
  final UserApi api;

  LoginPage({required this.api});  // 依赖从外部传入

  void login() {
    api.login();
  }
}
```

### 11.2 Riverpod 实现依赖注入

`Provider` 本身就是依赖注入容器。

```dart
// ===== di/providers.dart（集中管理所有 Provider）=====
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// --- 基础设施 ---
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com'));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

// --- 数据源 ---
final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.read(apiClientProvider));
});

final todoApiProvider = Provider<TodoApi>((ref) {
  return TodoApi(ref.read(apiClientProvider));
});

final userLocalStorageProvider = Provider<UserLocalStorage>((ref) {
  return UserLocalStorage();
});

// --- 仓库 ---
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    remoteApi: ref.read(userApiProvider),
    localStorage: ref.read(userLocalStorageProvider),
  );
});

// --- 状态管理 ---
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

### 11.3 依赖注入的好处

1. **可测试性**：依赖可以 mock
2. **松耦合**：类之间不直接依赖
3. **可替换**：切换实现只需改 Provider
4. **生命周期管理**：Riverpod 自动释放不再使用的 Provider

---

## 12. 主题与样式

### 12.1 定义主题

```dart
// ===== core/theme/app_theme.dart =====
import 'package:flutter/material.dart';

class AppTheme {
  // 亮色主题
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // 蓝色为主色
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // 文字主题
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // 卡片主题
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 暗色主题
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // ... 类似 light，但基于 dark colorScheme
    );
  }
}
```

### 12.2 使用主题

```dart
// 在 Widget 中使用主题
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '内容文本',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: const Text('主按钮'),
        ),
      ],
    );
  }
}
```

### 12.3 动态切换主题

```dart
// ===== settings_provider.dart =====
enum ThemeModeOption { light, dark, system }

class SettingsNotifier extends Notifier<ThemeModeOption> {
  @override
  ThemeModeOption build() => ThemeModeOption.system;

  void setTheme(ThemeModeOption mode) {
    state = mode;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, ThemeModeOption>(
  SettingsNotifier.new,
);

// ===== app.dart =====
class AiChatApp extends ConsumerWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider);

    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (themeMode) {
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
        ThemeModeOption.system => ThemeMode.system,
      },
      // ...
    );
  }
}
```

### 12.4 自定义组件样式最佳实践

```dart
// 定义 App 级别的样式常量
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}

// 使用
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
);
```

---

## 13. 表单与输入

### 13.1 TextEditingController 管理

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Controller 必须放在 State 中，需要手动释放
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // 释放 Controller 防止内存泄漏
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 表单验证通过
      print('邮箱: ${_emailController.text}');
      print('密码: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!value.contains('@')) {
                return '邮箱格式不正确';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return '密码至少 6 位';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
}
```

### 13.2 表单验证

```dart
// ===== core/utils/validators.dart =====
class Validators {
  static String? required(String? value, [String fieldName = '此项']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '邮箱格式不正确';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '手机号格式不正确';
    }
    return null;
  }

  static String? minLength(int min, String? value, [String fieldName = '密码']) {
    if (value != null && value.length < min) {
      return '$fieldName至少 $min 位';
    }
    return null;
  }

  static String? Function(String?)? combine(List<String?> Function(String?)? validators) {
    return (value) {
      // 组合多个验证器
      return null;
    };
  }
}

// 使用
TextFormField(
  validator: (value) {
    return Validators.required(value, '用户名')
        ?? Validators.minLength(3, value, '用户名');
  },
);
```

### 13.3 输入类型与键盘

```dart
// 文本输入
TextField(keyboardType: TextInputType.text);

// 邮箱
TextField(keyboardType: TextInputType.emailAddress);

// 数字
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
);

// 多行文本
TextField(maxLines: 5);

// 密码
TextField(
  obscureText: true,
  // 切换密码可见性
  suffixIcon: IconButton(
    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
    onPressed: () => setState(() => _showPassword = !_showPassword),
  ),
);
```

---

## 14. 动画

### 14.1 隐式动画（推荐优先使用）

自动处理开始和结束值之间的过渡。

```dart
class AnimatedBox extends StatefulWidget {
  const AnimatedBox({super.key});

  @override
  State<AnimatedBox> createState() => _AnimatedBoxState();
}

class _AnimatedBoxState extends State<AnimatedBox> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExpanded ? 200 : 100,
          height: 100,
          decoration: BoxDecoration(
            color: _isExpanded ? Colors.blue : Colors.red,
            borderRadius: BorderRadius.circular(_isExpanded ? 20 : 10),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: const Text('切换'),
        ),
      ],
    );
  }
}
```

**常用隐式动画 Widget：**

| Widget | 作用 |
|--------|------|
| AnimatedContainer | 尺寸、颜色、圆角等过渡 |
| AnimatedOpacity | 透明度过渡 |
| AnimatedPadding | 边距过渡 |
| AnimatedPositioned | 位置过渡（Stack 中） |
| AnimatedSwitcher | 切换子 Widget 的过渡 |
| TweenAnimationBuilder | 自定义值过渡 |
| AnimatedCrossFade | 两个 Widget 交叉淡入淡出 |

### 14.2 显式动画

需要更精细控制时使用 AnimationController。

```dart
class FadeInWidget extends StatefulWidget {
  const FadeInWidget({super.key});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,  // 提供 Ticker
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();  // 开始动画
  }

  @override
  void dispose() {
    _controller.dispose();  // 必须释放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Text('淡入文本'),
    );
  }
}
```

### 14.3 Hero 动画

页面间共享元素过渡。

```dart
// 页面 A - 列表页
Hero(
  tag: 'product_${product.id}',
  child: Image.network(product.imageUrl),
)

// 页面 B - 详情页（使用了相同的 tag）
Hero(
  tag: 'product_${product.id}',
  child: Image.network(product.imageUrl, width: 300, height: 300),
)

// 当 Navigator.push 时，Flutter 会自动创建过渡动画
```

### 14.4 动画最佳实践

```dart
// ✅ 优先用隐式动画
AnimatedOpacity(
  duration: Duration(milliseconds: 200),
  opacity: isVisible ? 1.0 : 0.0,
  child: widget,
);

// ✅ 用 AnimationController 时记得释放
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ 结合 Lottie/Rive 做复杂动画
// 1. 安装 lottie 包
// 2. Lottie.asset('assets/animations/loading.json')
```

---

## 15. 平台通道与原生交互

### 15.1 MethodChannel

调用原生平台能力（如摄像头、传感器）。

```dart
import 'package:flutter/services.dart';

// Dart 端
class BatteryPlugin {
  static const platform = MethodChannel('com.example.app/battery');

  Future<int> getBatteryLevel() async {
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('获取电池信息失败: ${e.message}');
    }
  }
}
```

### 15.2 EventChannel

从原生端接收连续事件流。

```dart
class SensorStream {
  static const eventChannel = EventChannel('com.example.app/accelerometer');

  Stream<Map<String, double>> get accelerometerEvents {
    return eventChannel.receiveBroadcastStream().map((event) {
      final data = event as List<double>;
      return {'x': data[0], 'y': data[1], 'z': data[2]};
    });
  }
}
```

### 15.3 常用原生插件

| 插件 | 用途 |
|------|------|
| camera | 拍照/录像 |
| image_picker | 选图片/视频 |
| geolocator | 定位 |
| local_auth | 指纹/面部识别 |
| flutter_local_notifications | 本地通知 |
| firebase_messaging | 推送通知 |
| url_launcher | 打开链接 |
| share_plus | 系统分享 |
| permission_handler | 权限管理 |
| file_picker | 文件选择 |

---

## 16. 测试

### 16.1 测试金字塔

```
     /\
    /  \          UI 测试（少）
   /    \
  / E2E  \        
 /--------\
/ Widget  \        Widget 测试（中）
/  测试    \
/------------\
/ 单元测试    \   单元测试（多，基础）
/              \
----------------
```

### 16.2 单元测试

```dart
// ===== test/models/user_test.dart =====
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_app/data/models/user.dart';

void main() {
  group('User 模型', () {
    test('fromJson 正确解析', () {
      final json = {
        'id': '1',
        'name': '张三',
        'email': 'zhangsan@example.com',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.name, '张三');
      expect(user.email, 'zhangsan@example.com');
    });

    test('toJson 正确转换', () {
      final user = User(
        id: '1',
        name: '张三',
        email: 'zhangsan@example.com',
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['name'], '张三');
    });
  });
}
```

### 16.3 Widget 测试

```dart
// ===== test/widgets/counter_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CounterButton 点击后计数增加', (tester) async {
    // 1. 构建 Widget
    await tester.pumpWidget(const MaterialApp(home: CounterButton()));

    // 2. 验证初始状态
    expect(find.text('点击了 0 次'), findsOneWidget);

    // 3. 执行交互
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // 4. 验证结果
    expect(find.text('点击了 1 次'), findsOneWidget);
  });
}
```

### 16.4 集成测试

```dart
// ===== test_driver/app_test.dart =====
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('完整流程测试', () {
    testWidgets('登录 → 首页 → 退出', (tester) async {
      await tester.pumpWidget(const MyApp());

      // 输入账号密码
      await tester.enterText(find.byKey(const Key('emailField')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));

      // 等待导航完成
      await tester.pumpAndSettle();

      // 验证在首页
      expect(find.text('欢迎回来'), findsOneWidget);
    });
  });
}
```

### 16.5 Mock 测试

```dart
// ===== test/repositories/user_repository_test.dart =====
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. 创建 Mock
class MockUserApi extends Mock implements UserApi {}

void main() {
  late UserRepository repository;
  late MockUserApi mockApi;

  setUp(() {
    mockApi = MockUserApi();
    repository = UserRepository(mockApi);
  });

  test('getUsers 返回用户列表', () async {
    // 2. 配置 Mock 行为
    when(() => mockApi.fetchUsers()).thenAnswer((_) async => [
          User(id: '1', name: '张三', email: 'test@test.com'),
        ]);

    // 3. 执行测试
    final users = await repository.getUsers();

    // 4. 验证
    expect(users.length, 1);
    expect(users[0].name, '张三');

    // 5. 验证调用
    verify(() => mockApi.fetchUsers()).called(1);
  });
}
```

### 16.6 测试运行

```bash
# 单元测试 + Widget 测试
flutter test

# 指定文件
flutter test test/models/user_test.dart

# 集成测试
flutter test integration_test/

# 带覆盖率
flutter test --coverage
```

---

## 17. 性能优化

### 17.1 列表性能优化

```dart
// ❌ 不好的做法：一次性构建所有 item
ListView(
  children: items.map((item) => ListItem(item: item)).toList(),
)

// ✅ 好的做法：按需构建
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
)

// ✅ 大型列表：分块 + 缓存
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (context, index) => ListItem(item: items[index]),
)
```

### 17.2 const 构造函数

```dart
// ✅ 所有不必要的重建都避免
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});  // 加上 const

  @override
  Widget build(BuildContext context) {
    return const Text('Hello');  // 尽量用 const
  }
}
```

### 17.3 RepaintBoundary

对不需要频繁重绘的区域使用边界隔离。

```dart
RepaintBoundary(
  child: ExpensiveWidget(),  // 这个区域不会随父 Widget 重绘
)
```

### 17.4 图片优化

```dart
// 缓存图片
Image.network(
  url,
  cacheWidth: 200,    // 指定渲染宽度（减少内存）
  cacheHeight: 200,   // 指定渲染高度
);

// 占位图
Image.network(
  url,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const CircularProgressIndicator();
  },
  errorBuilder: (context, error, stack) {
    return const Icon(Icons.error);
  },
);
```

### 17.5 内存管理

```dart
// ✅ 及时释放资源
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();  // 取消订阅
    super.dispose();
  }
}

// ❌ 避免在 build 中创建对象
@override
Widget build(BuildContext context) {
  // ❌ 每次 build 都创建新对象
  final style = TextStyle(fontSize: 16);
  return Text('Hello', style: style);

  // ✅ 提取为 const 或成员变量
}

// ✅ 使用 const 列表
const items = ['A', 'B', 'C'];
```

### 17.6 性能检测

```dart
// 使用 Flutter DevTools
flutter run --profile  // 性能分析模式
flutter run --release  // 发布模式

// 添加性能 Overlay
MaterialApp(
  showPerformanceOverlay: true,  // 显示 FPS
  // ...
);

// 检测 build 次数
class BuildLoggerWidget extends StatelessWidget {
  const BuildLoggerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print('Widget rebuilt: ${runtimeType}');
    return const Text('监控 build');
  }
}
```

---

## 18. 打包与发布

### 18.1 Android 打包

```bash
# 1. 生成签名密钥
keytool -genkey -v -keystore app-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. 将 keystore 放到 android/app/ 目录

# 3. 创建 key.properties（android/ 目录下）
# storePassword=your_password
# keyPassword=your_password
# keyAlias=upload
# storeFile=app-upload-key.jks

# 4. 打包 APK
flutter build apk --release

# 5. 打包 AppBundle（推荐 Google Play）
flutter build appbundle --release
```

### 18.2 iOS 打包（macOS）

```bash
# 1. 配置 Xcode 签名（在 Xcode 中打开 ios/Runner.xcworkspace）
# 2. 设置 Bundle Identifier
# 3. 选择 Team（开发者账号）

# 4. 打包
flutter build ipa --release

# 5. 通过 Xcode 上传到 App Store
# 或使用命令行
flutter build ipa --release --export-method app-store
# 然后使用 Application Loader 上传
```

### 18.3 Web 打包

```bash
# 打包
flutter build web --release

# 部署到 Firebase Hosting
firebase init hosting
firebase deploy --only hosting

# 部署到其他静态服务器
# 将 build/web/ 目录部署到 Nginx / Netlify / Vercel
```

### 18.4 Windows 打包

```bash
# 打包
flutter build windows --release

# 输出在 build/windows/runner/Release/
# 包含 .exe 文件和依赖的 DLL
```

### 18.5 版本管理

```yaml
# pubspec.yaml
version: 1.2.3+4  # 版本名: 1.2.3, 版本号: 4
```

### 18.6 多环境配置

```dart
// ===== core/constants/api_endpoints.dart =====
enum AppEnvironment { dev, staging, production }

class AppConfig {
  final AppEnvironment environment;

  const AppConfig({required this.environment});

  String get baseUrl {
    return switch (environment) {
      AppEnvironment.dev          => 'http://localhost:3000/api',
      AppEnvironment.staging      => 'https://staging-api.example.com',
      AppEnvironment.production   => 'https://api.example.com',
    };
  }

  bool get isDebug => environment != AppEnvironment.production;
}

// 通过 --dart-define 传入环境
// flutter run --dart-define=ENV=staging
// flutter build apk --dart-define=ENV=production

// 读取
const env = String.fromEnvironment('ENV', defaultValue: 'dev');
final config = AppConfig(
  environment: AppEnvironment.values.byName(env),
);
```

---

## 19. CI/CD 与自动化

### 19.1 GitHub Actions

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/*.apk
```

### 19.2 代码质量检查

```bash
# 静态分析
flutter analyze

# 格式化代码
dart format .

# 检查类型
dart analyze --fatal-infos
```

### 19.3 自动化版本更新

```bash
# 使用 fastlane 或 cider
# pub global activate cider
# cider version major|minor|patch

# 手动更新 pubspec.yaml 版本号
# version: 1.0.0+1
```

---

## 20. 企业级最佳实践

### 20.1 错误处理统一策略

```dart
// 全局错误处理
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 捕获未处理的错误
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 上报到 Sentry / 日志服务
    reportError(details.exception, details.stack);
  };

  // 捕获异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    reportError(error, stack);
    return true;
  };

  runApp(const MyApp());
}
```

### 20.2 日志系统

```dart
// ===== core/utils/logger.dart =====
enum LogLevel { debug, info, warning, error }

class Logger {
  final String tag;

  const Logger(this.tag);

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message) => _log(LogLevel.warning, message);
  void error(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.error, message);
    if (error != null) print('Error: $error');
    if (stack != null) print('Stack: $stack');
  }

  void _log(LogLevel level, String message) {
    // 开发环境打印日志
    assert(() {
      print('[$level][$tag] $message');
      return true;
    }());

    // 生产环境上报到日志服务
    if (level == LogLevel.error) {
      // reportToServer(level, tag, message);
    }
  }
}

// 使用
final log = Logger('LoginPage');
log.info('用户点击了登录按钮');
log.error('登录失败', error, stackTrace);
```

### 20.3 安全最佳实践

```dart
// 1. 敏感信息不要硬编码
// ❌ 不要
const apiKey = 'sk-xxx-private-key';

// ✅ 使用环境变量或后端转发
// flutter run --dart-define=API_KEY=xxx

// 2. Token 使用安全存储
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);

// 3. 网络请求验证证书（正式环境）
final dio = Dio();
(dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) => false; // 不信任自签名证书
  return client;
};

// 4. 输入验证
void processInput(String userInput) {
  // 过滤特殊字符
  final sanitized = userInput.replaceAll(RegExp(r'[<>\'"]'), '');
}

// 5. 混淆发布版本
// android/app/build.gradle:
// buildTypes {
//   release {
//     minifyEnabled true
//     proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
//   }
// }
```

### 20.4 无障碍支持

```dart
// 为组件添加语义标签
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.add),
  tooltip: '添加',  // 屏幕阅读器会读取
  // 或
  semanticLabel: '添加新项目',
)

// 图片添加描述
Image.asset(
  'logo.png',
  semanticLabel: '公司 Logo',
)

// 合并语义组（防止屏幕阅读器逐字朗读）
Semantics(
  label: '用户信息',
  child: Row(
    children: [
      Text('张三'),
      Text('28岁'),
    ],
  ),
)
```

### 20.5 国际化（i18n）

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  flutter_localizations:
    sdk: flutter
  intl_utils: ^2.8.0
```

```dart
// 使用 ARB 文件定义翻译
// lib/l10n/app_zh.arb
{
  "@@locale": "zh",
  "hello": "你好",
  "welcome": "欢迎, {name}",
  "@welcome": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}

// 代码中使用
Text(AppLocalizations.of(context)!.hello);
Text(AppLocalizations.of(context)!.welcome('张三'));
```

### 20.6 启动页优化

```dart
// 使用 flutter_native_splash 包
// pubspec.yaml:
// dependencies:
//   flutter_native_splash: ^2.4.0
//
// flutter_native_splash:
//   color: "#FFFFFF"
//   image: assets/splash.png
//   android_12:
//     color: "#FFFFFF"

// 初始化后再显示主页面
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载必要配置
  await Future.wait([
    _initDatabase(),
    _loadPreferences(),
    _initServices(),
  ]);

  runApp(const MyApp());
}
```

### 20.7 代码规范检查

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
    sort_child_properties_last: true
    use_key_in_widget_constructors: true
    prefer_const_literals_to_create_immutables: true

analyzer:
  errors:
    invalid_annotation_target: ignore
```

### 20.8 项目 Checklist

上生产前请逐项检查：

- [ ] 代码没有 `print()`（用 Logger 代替）
- [ ] 所有硬编码字符串已提取为常量
- [ ] 所有 Controller 在 `dispose()` 中释放
- [ ] 长列表使用 `ListView.builder`
- [ ] Widget 构造函数使用 `const`
- [ ] 错误处理覆盖所有网络请求
- [ ] 敏感信息使用 `flutter_secure_storage`
- [ ] 主题色统一，没有硬编码颜色
- [ ] 图片设置了 `cacheWidth` / `cacheHeight`
- [ ] 路由配置支持深度链接
- [ ] 单元测试覆盖核心逻辑
- [ ] 性能分析确认流畅（60 FPS）
- [ ] 打包为 release 模式
- [ ] 国际化支持（如果需要）

---

## 附录

### A. Flutter 学习路线

```
阶段一：基础（1-2周）
├── Dart 语法基础
├── Widget 概念
├── 常用 Widget（Text, Row, Column, ListView）
├── 状态管理入门（setState）
└── 第一个完整页面

阶段二：进阶（2-4周）
├── Riverpod 状态管理
├── GoRouter 路由
├── Dio 网络请求
├── 主题与样式
└── 表单处理

阶段三：实战（4-8周）
├── 完整项目架构
├── Repository 模式
├── 本地存储
├── 测试
└── 打包发布

阶段四：企业级（8周+）
├── CI/CD 自动化
├── 性能优化
├── 安全实践
├── 多平台适配
└── 大型项目架构演进
```

### B. 推荐学习资源

| 资源 | 地址 |
|------|------|
| Flutter 官方文档 | https://docs.flutter.dev |
| Dart 语言指南 | https://dart.dev/guides |
| Flutter 实战（书） | 网络搜索 |
| Awesome Flutter | https://github.com/Solido/awesome-flutter |
| Flutter Go（中文） | https://fluttergo.dev/ |

### C. 常用命令速查

```bash
# 项目
flutter create my_app          # 创建项目
flutter pub get                # 获取依赖
flutter pub add package_name   # 添加依赖
flutter pub upgrade            # 升级依赖

# 运行
flutter run                    # 运行（自动选择设备）
flutter run -d chrome          # 运行到 Chrome
flutter run -d windows         # 运行到 Windows
flutter run --release          # 发布模式

# 构建
flutter build apk              # Android APK
flutter build appbundle        # Android AppBundle
flutter build ios              # iOS
flutter build web              # Web
flutter build windows          # Windows

# 测试
flutter test                   # 运行测试
flutter test --coverage        # 带覆盖率
flutter analyze                # 静态分析

# 工具
flutter doctor                 # 环境检查
flutter clean                  # 清理构建缓存
flutter devices                # 列出设备
dart format .                  # 格式化代码
```

---

> 本指南由 AI 辅助编写，涵盖 Flutter 企业级开发的主要知识点。实际开发中请结合官方文档和社区实践不断积累经验。祝编码愉快！
