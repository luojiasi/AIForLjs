import 'package:flutter/material.dart';
import '../../../../shared/tutorial_widgets.dart';

// ============================================================
// Interactive Demo: _ListManipDemo
// ============================================================
class _ListManipDemo extends StatefulWidget {
  const _ListManipDemo();

  @override
  State<_ListManipDemo> createState() => _ListManipDemoState();
}

class _ListManipDemoState extends State<_ListManipDemo> {
  List<String> _items = ['苹果', '香蕉', '橘子', '葡萄', '西瓜'];
  String _operation = 'add';
  final String _newItem = '芒果';

  static const List<(String, String)> _ops = [
    ('add', '添加'),
    ('remove', '删除首个'),
    ('sort', '排序'),
    ('reverse', '反转'),
    ('reset', '重置'),
  ];

  void _applyOperation() {
    setState(() {
      switch (_operation) {
        case 'add':
          _items.add(_newItem);
          break;
        case 'remove':
          if (_items.isNotEmpty) _items.removeAt(0);
          break;
        case 'sort':
          _items.sort();
          break;
        case 'reverse':
          _items = _items.reversed.toList();
          break;
        case 'reset':
          _items = ['苹果', '香蕉', '橘子', '葡萄', '西瓜'];
          break;
      }
    });
  }

  String get _codeSnippet {
    switch (_operation) {
      case 'add':
        return "items.add('$_newItem');";
      case 'remove':
        return 'items.removeAt(0); // 删除第一个元素';
      case 'sort':
        return 'items.sort(); // 字母顺序排序';
      case 'reverse':
        return 'items = items.reversed.toList();';
      case 'reset':
        return "items = ['苹果', '香蕉', '橘子', '葡萄', '西瓜'];";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePlayground(
      title: 'List 操作演示',
      subtitle: '交互式体验 List 的常用操作方法',
      children: [
        ParamChoiceChips<String>(
          label: '选择操作',
          value: _operation,
          options: _ops,
          onChanged: (v) => setState(() => _operation = v),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (int i = 0; i < _items.length; i++)
              Chip(label: Text('[$i] ${_items[i]}')),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _applyOperation,
          child: const Text('执行操作'),
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_codeSnippet),
        LiveOutputBox('${_items.length} 个元素: ${_items.join(', ')}'),
      ],
    );
  }
}

// ============================================================
// Interactive Demo: _SetMapDemo
// ============================================================
class _SetMapDemo extends StatefulWidget {
  const _SetMapDemo();

  @override
  State<_SetMapDemo> createState() => _SetMapDemoState();
}

class _SetMapDemoState extends State<_SetMapDemo> {
  final Set<int> _setA = {1, 2, 3, 4, 5};
  final Set<int> _setB = {3, 4, 5, 6, 7};
  String _operation = '&';

  static const List<(String, String)> _ops = [
    ('&', '交集 ∩'),
    ('|', '并集 ∪'),
    ('-', '差集 A-B'),
    ('contains', '包含关系'),
  ];

  Set<int> get _result {
    switch (_operation) {
      case '&':
        return _setA.intersection(_setB);
      case '|':
        return _setA.union(_setB);
      case '-':
        return _setA.difference(_setB);
      case 'contains':
        return _setA.where((e) => _setB.contains(e)).toSet();
      default:
        return {};
    }
  }

  String get _codeSnippet {
    switch (_operation) {
      case '&':
        return 'var result = setA.intersection(setB);\n// 两个集合共同拥有的元素';
      case '|':
        return 'var result = setA.union(setB);\n// 两个集合所有元素的合并';
      case '-':
        return 'var result = setA.difference(setB);\n// 在 A 中但不在 B 中的元素';
      case 'contains':
        return 'var inBoth = setA.where((e) => setB.contains(e)).toSet();\n// setA 中同时存在于 setB 的元素';
      default:
        return '';
    }
  }

  String get _outputLabel {
    switch (_operation) {
      case '&':
        return '交集';
      case '|':
        return '并集';
      case '-':
        return '差集 A-B';
      case 'contains':
        return 'A 中属于 B 的元素';
      default:
        return '结果';
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return InteractivePlayground(
      title: 'Set 集合运算演示',
      subtitle: '交互式体验 Set 的集合运算',
      children: [
        ParamChoiceChips<String>(
          label: '选择运算',
          value: _operation,
          options: _ops,
          onChanged: (v) => setState(() => _operation = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('集合 A', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_setA}'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('集合 B', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_setB}'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_outputLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$result'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        LiveCodeBlock(_codeSnippet),
        LiveOutputBox('$_outputLabel: $result'),
      ],
    );
  }
}

// ============================================================
// Interactive Demo: _CollectionMethodsDemo
// ============================================================
class _CollectionMethodsDemo extends StatefulWidget {
  const _CollectionMethodsDemo();

  @override
  State<_CollectionMethodsDemo> createState() => _CollectionMethodsDemoState();
}

class _CollectionMethodsDemoState extends State<_CollectionMethodsDemo> {
  final List<int> _numbers = [1, 2, 3, 4, 5, 6, 7, 8];
  String _method = 'where';
  int _threshold = 3;
  int _factor = 2;

  static const List<(String, String)> _methods = [
    ('where', 'where 筛选'),
    ('map', 'map 转换'),
    ('fold', 'fold 归约'),
    ('take', 'take 截取'),
    ('skip', 'skip 跳过'),
  ];

  dynamic get _result {
    switch (_method) {
      case 'where':
        return _numbers.where((n) => n > _threshold).toList();
      case 'map':
        return _numbers.map((n) => n * _factor).toList();
      case 'fold':
        return _numbers.fold(0, (acc, n) => acc + n);
      case 'take':
        return _numbers.take(_threshold).toList();
      case 'skip':
        return _numbers.skip(_threshold).toList();
      default:
        return [];
    }
  }

  String get _codeSnippet {
    switch (_method) {
      case 'where':
        return 'var result = numbers.where((n) => n > $_threshold).toList();\n// 筛选大于 $_threshold 的元素';
      case 'map':
        return 'var result = numbers.map((n) => n * $_factor).toList();\n// 每个元素乘以 $_factor';
      case 'fold':
        return 'var result = numbers.fold(0, (acc, n) => acc + n);\n// 从初始值 0 开始累加所有元素';
      case 'take':
        return 'var result = numbers.take($_threshold).toList();\n// 取前 $_threshold 个元素';
      case 'skip':
        return 'var result = numbers.skip($_threshold).toList();\n// 跳过前 $_threshold 个元素';
      default:
        return '';
    }
  }

  String get _outputText {
    final r = _result;
    if (_method == 'fold') return '所有元素之和: $r';
    return '$r';
  }

  @override
  Widget build(BuildContext context) {
    final showThreshold = ['where', 'take', 'skip'].contains(_method);
    final showFactor = _method == 'map';
    return InteractivePlayground(
      title: '集合函数式方法演示',
      subtitle: '交互式体验 map / where / fold / take / skip',
      children: [
        ParamChoiceChips<String>(
          label: '选择方法',
          value: _method,
          options: _methods,
          onChanged: (v) => setState(() => _method = v),
        ),
        if (showThreshold)
          ParamIntSlider(
            label: '阈值 (threshold)',
            value: _threshold,
            min: 1,
            max: 7,
            onChanged: (v) => setState(() => _threshold = v),
          ),
        if (showFactor)
          ParamIntSlider(
            label: '倍数 (factor)',
            value: _factor,
            min: 2,
            max: 5,
            onChanged: (v) => setState(() => _factor = v),
          ),
        const SizedBox(height: 8),
        LiveCodeBlock(_codeSnippet),
        LiveOutputBox(_outputText),
      ],
    );
  }
}

/// Dart 集合类型教程页面
/// 涵盖：List、Set、Map、泛型、集合操作符、不可变集合、Iterable 惰性求值
class DartCollections extends StatelessWidget {
  const DartCollections({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第4章 · 集合类型'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Paragraph('集合是编程中最常用的数据结构。Dart 提供 List（列表）、Set（集合）、'
              'Map（映射）三种核心集合类型。本章深入讲解集合的创建、操作方法、'
              '泛型系统以及不可变集合等进阶话题。'),

          // ============================================================
          // 1. List 基础
          // ============================================================
          SectionHeader('1. List —— 有序列表', icon: Icons.list),
          Paragraph('List 是有序的元素集合，允许重复元素，通过索引访问。'
              'Dart 的 List 分为可增长（growable）和固定长度（fixed-length）两种。'
              '同时支持 ... 展开运算符、collection-if 和 collection-for 语法糖。'),
          CodeBlock(r'''
void main() {
  // ---- 可增长列表（默认） ----
  var fruits = ['苹果', '香蕉', '橘子'];
  fruits.add('葡萄');            // 添加元素
  fruits.insert(0, '西瓜');      // 在指定位置插入
  fruits.remove('苹果');         // 删除元素
  fruits[0] = '芒果';            // 修改元素
  print('水果: $fruits');        // [芒果, 香蕉, 橘子, 葡萄]
  print('长度: ${fruits.length}');
  print('第一个: ${fruits[0]}');  // 索引从 0 开始

  // ---- 固定长度列表 ----
  var fixed = List.generate(3, (i) => i * 10);
  print('固定长度: $fixed');     // [0, 10, 20]
  // fixed.add(30);  // ❌ 运行时错误：固定列表不能改变长度

  var zeros = List.filled(5, 0);
  print('填充零: $zeros');      // [0, 0, 0, 0, 0]

  // List.of / List.from 复制列表
  var copy = List.of(fruits);
  print('复制: $copy');

  // ---- 展开运算符 ... 和 ...? ----
  var a = [1, 2];
  var b = [3, 4];
  var combined = [...a, ...b];
  print('展开合并: $combined');  // [1, 2, 3, 4]

  List<int>? nullable;
  var safe = [0, ...?nullable];   // ...? 安全展开 null 值
  print('安全展开: $safe');       // [0]

  // ---- collection-if ----
  bool isLoggedIn = true;
  var menu = ['首页', '设置', if (isLoggedIn) '个人中心'];
  print('菜单: $menu');

  // ---- collection-for ----
  var squares = [for (int i = 1; i <= 4; i++) i * i];
  print('平方: $squares');        // [1, 4, 9, 16]
}
''', language: 'Dart'),
          OutputBox('水果: [芒果, 香蕉, 橘子, 葡萄]\n长度: 4\n第一个: 芒果\n'
              '固定长度: [0, 10, 20]\n填充零: [0, 0, 0, 0, 0]\n'
              '复制: [芒果, 香蕉, 橘子, 葡萄]\n展开合并: [1, 2, 3, 4]\n'
              '安全展开: [0]\n菜单: [首页, 设置, 个人中心]\n平方: [1, 4, 9, 16]'),

          // ============================================================
          // 2. List 高级方法
          // ============================================================
          SectionHeader('2. List 高级方法', icon: Icons.transform),
          Paragraph('List 继承了 Iterable 接口，提供丰富的函数式编程方法。'
              '这些方法支持链式调用，让数据转换和处理变得简洁优雅。'
              '映射、筛选、归约是最常用的三类操作。'),
          CodeBlock(r'''
void main() {
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8];

  // map：对每个元素执行转换
  var doubled = numbers.map((n) => n * 2);
  print('翻倍: ${doubled.toList()}');    // [2, 4, 6, 8, 10, 12, 14, 16]

  // where：筛选满足条件的元素
  var evens = numbers.where((n) => n.isEven);
  print('偶数: ${evens.toList()}');      // [2, 4, 6, 8]

  // firstWhere：第一个满足条件的元素（没找到抛异常）
  int firstBig = numbers.firstWhere((n) => n > 5);
  print('第一个大于5: $firstBig');       // 6

  // singleWhere：唯一满足条件的元素
  var single = [1, 2, 3].singleWhere((n) => n == 2);
  print('唯一等于2: $single');            // 2

  // reduce：归约，整个列表化为单个值
  int sum = numbers.reduce((a, b) => a + b);
  print('总和: $sum');                    // 36

  // fold：带初始值的归约（即使空列表也有默认值）
  int product = numbers.fold(1, (prev, n) => prev * n);
  print('乘积: $product');                // 40320

  // any：是否有任一元素满足条件
  bool hasEven = numbers.any((n) => n.isEven);
  print('包含偶数: $hasEven');            // true

  // every：是否全部满足条件
  bool allPositive = numbers.every((n) => n > 0);
  print('全部正数: $allPositive');         // true

  // take：取前 N 个
  var first3 = numbers.take(3);
  print('前3个: ${first3.toList()}');     // [1, 2, 3]

  // skip：跳过前 N 个
  var after4 = numbers.skip(4);
  print('跳过4个: ${after4.toList()}');   // [5, 6, 7, 8]

  // contains：是否包含某元素
  print('包含5: ${numbers.contains(5)}');  // true

  // elementAt：按索引取元素
  print('索引3: ${numbers.elementAt(3)}');  // 4

  // first / last：首尾元素
  print('第一个: ${numbers.first}');       // 1
  print('最后一个: ${numbers.last}');       // 8

  // isEmpty / isNotEmpty
  print('是否为空: ${numbers.isEmpty}');   // false

  // ---- 链式调用 ----
  var result = numbers
      .where((n) => n.isOdd)     // 筛选奇数 [1, 3, 5, 7]
      .map((n) => n * n)         // 平方 [1, 9, 25, 49]
      .take(3)                   // 取前3个
      .toList();
  print('前3个奇数的平方: $result');  // [1, 9, 25]
}
''', language: 'Dart'),
          OutputBox('翻倍: [2, 4, 6, 8, 10, 12, 14, 16]\n'
              '偶数: [2, 4, 6, 8]\n第一个大于5: 6\n唯一等于2: 2\n'
              '总和: 36\n乘积: 40320\n包含偶数: true\n全部正数: true\n'
              '前3个: [1, 2, 3]\n跳过4个: [5, 6, 7, 8]\n'
              '包含5: true\n索引3: 4\n第一个: 1\n最后一个: 8\n是否为空: false\n'
              '前3个奇数的平方: [1, 9, 25]'),
          TipBox('map、where、take、skip 等方法返回的是 Iterable 而不是 List。'
              'Iterable 是惰性求值的——元素在遍历时才计算。'
              '调用 .toList() 可得到真正的 List 进行后续操作。', type: TipType.info),

          // ============================================================
          // 3. Set
          // ============================================================
          SectionHeader('3. Set —— 无重复集合', icon: Icons.filter_none),
          Paragraph('Set 是元素唯一的无序集合。Dart 提供三种 Set 实现：'
              'HashSet（无序最快）、LinkedHashSet（保持插入顺序，默认）、'
              'SplayTreeSet（自动排序）。集合运算包括并集、交集、差集。'),
          CodeBlock(r'''
import 'dart:collection';

void main() {
  // ---- 三种 Set 实现 ----
  // HashSet：无序，访问速度最快
  var hashSet = HashSet<int>();
  hashSet.addAll([5, 3, 1, 4, 2]);
  print('HashSet: $hashSet');             // 顺序不确定

  // LinkedHashSet：保持插入顺序（默认）
  var linked = LinkedHashSet<int>();
  linked.addAll([3, 1, 4, 1, 5, 9]);
  print('LinkedHashSet: $linked');        // {3, 1, 4, 5, 9} 保持顺序且去重

  // SplayTreeSet：自动排序
  var sorted = SplayTreeSet<int>();
  sorted.addAll([3, 1, 4, 1, 5, 9]);
  print('SplayTreeSet: $sorted');         // {1, 3, 4, 5, 9} 已排序

  // ---- 集合运算 ----
  var setA = {1, 2, 3, 4, 5};
  var setB = {4, 5, 6, 7, 8};

  print('并集: ${setA.union(setB)}');             // {1,2,3,4,5,6,7,8}
  print('交集: ${setA.intersection(setB)}');      // {4,5}
  print('差集 A-B: ${setA.difference(setB)}');    // {1,2,3}
  print('差集 B-A: ${setB.difference(setA)}');    // {6,7,8}

  // 集合关系检查
  print('包含3: ${setA.contains(3)}');             // true
  var sub = {1, 2};
  print('{1,2} 是子集: ${sub.isSubsetOf(setA)}');  // true
  print('setA 是超集: ${setA.isSupersetOf(sub)}');  // true

  // 查找和操作
  setA.add(6);                              // 添加
  setA.remove(1);                           // 删除
  print('增删后: $setA');                    // {2, 3, 4, 5, 6}

  // 去重利器
  var list = [1, 1, 2, 2, 3, 3, 3];
  var unique = list.toSet();
  print('去重: $unique');                    // {1, 2, 3}

  // 基本操作
  print('长度: ${unique.length}');           // 3
  print('是否为空: ${unique.isEmpty}');       // false

  // 遍历 Set
  for (var item in unique) {
    print('元素: $item');
  }
}
''', language: 'Dart'),
          OutputBox('HashSet: {5, 3, 1, 4, 2}\n'
              'LinkedHashSet: {3, 1, 4, 5, 9}\n'
              'SplayTreeSet: {1, 3, 4, 5, 9}\n'
              '并集: {1, 2, 3, 4, 5, 6, 7, 8}\n交集: {4, 5}\n'
              '差集 A-B: {1, 2, 3}\n差集 B-A: {6, 7, 8}\n'
              '包含3: true\n{1,2} 是子集: true\nsetA 是超集: true\n'
              '增删后: {2, 3, 4, 5, 6}\n去重: {1, 2, 3}\n长度: 3\n'
              '是否为空: false\n元素: 1\n元素: 2\n元素: 3'),

          // ============================================================
          // 4. Map
          // ============================================================
          SectionHeader('4. Map —— 键值对', icon: Icons.map),
          Paragraph('Map 以键值对方式存储数据，每个键唯一。'
              '除了字面量写法，Dart 还提供 Map.fromEntries、Map.fromIterable 等'
              '多种构建方式，以及 null-safe 访问和展开运算符。'),
          CodeBlock(r'''
void main() {
  // ---- 多种构建方式 ----
  // 字面量
  var scores = {'张三': 95, '李四': 87};

  // Map.fromEntries：从 MapEntry 列表构建
  var entries = [
    MapEntry('苹果', 5.5),
    MapEntry('香蕉', 3.0),
    MapEntry('橘子', 4.0),
  ];
  var prices = Map.fromEntries(entries);
  print('价格: $prices');

  // Map.fromIterable：从 Iterable 构建
  var cities = ['北京', '上海', '广州'];
  var cityMap = Map.fromIterable(
    cities,
    key: (c) => c,
    value: (c) => '${c}市',
  );
  print('城市: $cityMap');

  // Map.of / Map.from 复制
  var copy = Map.of(scores);
  print('复制: $copy');

  // ---- Map 展开运算符 ----
  var defaults = {'theme': 'light', 'lang': 'zh'};
  var config = {'lang': 'en', 'fontSize': 14};
  var merged = {...defaults, ...config};  // 后者覆盖前者
  print('合并: $merged');

  // ---- null-safe 访问 ----
  var map = <String, int>{'a': 1, 'b': 2};
  print('a: ${map['a']}');     // 1
  print('c: ${map['c']}');     // null（不存在的键返回 null）

  // ?? 提供默认值
  var val = map['c'] ?? -1;
  print('c 的默认值: $val');    // -1

  // putIfAbsent：不存在才写入
  map.putIfAbsent('c', () => 3);
  map.putIfAbsent('a', () => 999);  // 已存在，忽略
  print('putIfAbsent: $map');  // {a: 1, b: 2, c: 3}

  // update：更新已有键的值
  map.update('a', (v) => v + 10);
  map.update('x', (v) => v, ifAbsent: () => 0);
  print('update: $map');       // {a: 11, b: 2, c: 3, x: 0}

  // removeWhere：按条件删除
  map.removeWhere((key, value) => value == 0);
  print('移除0值后: $map');    // {a: 11, b: 2, c: 3}

  // containsKey / containsValue
  print('包含键a: ${map.containsKey('a')}');     // true
  print('包含值11: ${map.containsValue(11)}');    // true

  // 遍历 Map
  scores.forEach((name, score) {
    print('$name: $score 分');
  });
}
''', language: 'Dart'),
          OutputBox('价格: {苹果: 5.5, 香蕉: 3.0, 橘子: 4.0}\n'
              '城市: {北京: 北京市, 上海: 上海市, 广州: 广州市}\n'
              '复制: {张三: 95, 李四: 87}\n'
              '合并: {theme: light, lang: en, fontSize: 14}\n'
              'a: 1\nc: null\nc 的默认值: -1\n'
              'putIfAbsent: {a: 1, b: 2, c: 3}\n'
              'update: {a: 11, b: 2, c: 3, x: 0}\n'
              '移除0值后: {a: 11, b: 2, c: 3}\n'
              '包含键a: true\n包含值11: true\n'
              '张三: 95 分\n李四: 87 分'),
          TipBox('Map 的 [] 操作符访问不存在的键会返回 null 而不会抛异常。'
              '可以用 ?? 提供默认值，或 putIfAbsent 在不存在时自动填充。'
              '这些特性让 Map 使用起来非常安全。', type: TipType.tip),

          // ============================================================
          // 5. Iterable 与 List —— 惰性求值
          // ============================================================
          SectionHeader('5. Iterable 与 List —— 惰性求值', icon: Icons.repeat),
          Paragraph('Iterable 是 Dart 所有集合的基类。Iterable 的方法（map、where 等）'
              '是惰性求值的——只在遍历时才会真正计算。'
              '而 List 是急切求值的。理解这一区别对写出高效代码非常重要。'),
          CodeBlock(r'''
void main() {
  var numbers = [1, 2, 3, 4, 5];

  // map 返回的是 Iterable——惰性求值
  var doubled = numbers.map((n) {
    print('计算: $n * 2');
    return n * 2;
  });
  print('map 已返回但还未计算任何值');

  // 只有在遍历时才会真正执行 map 中的函数
  print('开始遍历:');
  for (var v in doubled) {
    print('结果: $v');
  }

  // toList() 将 Iterable 转为 List（会触发全部计算）
  var eager = numbers.map((n) => n * 3).toList();
  print('转 List: $eager');

  // toSet() 转为 Set（自动去重）
  var listWithDups = [1, 2, 2, 3, 3, 3];
  var asSet = listWithDups.toSet();
  print('转 Set: $asSet');                // {1, 2, 3}

  // expand：将每个元素展开为多个
  var nested = [[1, 2], [3, 4], [5]];
  var flattened = nested.expand((x) => x).toList();
  print('展平: $flattened');              // [1, 2, 3, 4, 5]

  // followedBy：连接两个 Iterable
  var concatenated = [1, 2].followedBy([3, 4]).toList();
  print('连接: $concatenated');            // [1, 2, 3, 4]

  // cast：类型转换
  var objects = <Object>[1, 2, 3];
  var ints = objects.cast<int>().toList();
  print('类型转换: $ints');

  // whereType：按类型筛选
  var mixed = [1, 'a', 2, 'b', 3];
  var onlyInts = mixed.whereType<int>().toList();
  print('Int 类型: $onlyInts');           // [1, 2, 3]
}
''', language: 'Dart'),
          OutputBox('map 已返回但还未计算任何值\n开始遍历:\n'
              '计算: 1 * 2\n结果: 2\n计算: 2 * 2\n结果: 4\n'
              '计算: 3 * 2\n结果: 6\n计算: 4 * 2\n结果: 8\n'
              '计算: 5 * 2\n结果: 10\n'
              '转 List: [3, 6, 9, 12, 15]\n'
              '转 Set: {1, 2, 3}\n展平: [1, 2, 3, 4, 5]\n'
              '连接: [1, 2, 3, 4]\n类型转换: [1, 2, 3]\nInt 类型: [1, 2, 3]'),
          TipBox('惰性求值是函数式编程的核心特性。链式调用高效的原因：'
              'Dart 不会为每个中间步骤创建新集合，而是一次性计算最终结果。'
              '但如果需要多次遍历同一个 Iterable，调用 toList() 缓存可以避免重复计算。',
              type: TipType.info),

          // ============================================================
          // 6. 泛型进阶
          // ============================================================
          SectionHeader('6. 泛型进阶', icon: Icons.code),
          Paragraph('泛型让代码可以处理多种类型而又保持类型安全。'
              'Dart 支持泛型函数、泛型类、类型约束 <T extends Type>'
              '以及多个类型参数。泛型在编译时进行类型检查，避免运行时错误。'),
          CodeBlock(r'''
// ---- 泛型函数 ----
T first<T>(List<T> items) => items[0];

// ---- 泛型类 ----
class Box<T> {
  T value;
  Box(this.value);

  T getValue() => value;
  void setValue(T v) => value = v;
}

// ---- 类型约束 <T extends SomeType> ----
// T 必须是 num（int 或 double）的子类型
class NumberHolder<T extends num> {
  final List<T> _items = [];

  void add(T item) => _items.add(item);

  T sum() {
    if (_items.isEmpty) throw StateError('列表为空');
    dynamic total = 0;
    for (var item in _items) {
      total += item;
    }
    return total as T;
  }
}

// ---- 多个类型参数 ----
class Pair<K, V> {
  final K key;
  final V value;
  Pair(this.key, this.value);

  @override
  String toString() => '{$key: $value}';
}

void main() {
  // 泛型函数
  print(first<int>([1, 2, 3]));       // 1
  print(first<String>(['a', 'b']));   // a

  // 泛型类
  var intBox = Box<int>(42);
  print('int: ${intBox.getValue()}');  // 42

  var strBox = Box<String>('Hello');
  print('str: ${strBox.getValue()}');  // Hello

  // 类型约束确保类型安全
  var nums = NumberHolder<int>();
  nums.add(10);
  nums.add(20);
  nums.add(30);
  print('数字和: ${nums.sum()}');      // 60

  // 多类型参数
  var pair = Pair<String, int>('年龄', 25);
  print(pair);                         // {年龄: 25}

  // Dart 自动类型推断
  var inferred = Box('auto');
  print('推断类型: ${inferred.runtimeType}');  // Box<String>
}
''', language: 'Dart'),
          OutputBox('1\na\nint: 42\nstr: Hello\n数字和: 60\n{年龄: 25}\n推断类型: Box<String>'),
          TipBox('类型约束 <T extends num> 表示 T 必须是 num 的子类型。'
              '常见的约束包括：num（int/double）、Object（任意非空类型）、'
              'Comparable（可比较类型）等。', type: TipType.info),

          // ============================================================
          // 7. 不可变集合
          // ============================================================
          SectionHeader('7. 不可变集合', icon: Icons.lock),
          Paragraph('为了防止内部数据被外部意外修改，Dart 提供了不可变集合视图。'
              '使用 UnmodifiableListView 和 UnmodifiableMapView 包装原始集合，'
              '外部只能读取不能修改。这是封装安全性的重要手段。'),
          CodeBlock(r'''
import 'dart:collection';

class Student {
  final String name;
  final List<int> _scores;  // 私有字段

  Student(this.name, this._scores);

  // 返回不可修改的只读视图
  List<int> get scores => UnmodifiableListView(_scores);
}

class Config {
  final Map<String, String> _settings;

  Config(this._settings);

  Map<String, String> get settings => UnmodifiableMapView(_settings);
}

void main() {
  var student = Student('张三', [90, 85, 92]);
  print('成绩: ${student.scores}');       // [90, 85, 92]
  // student.scores.add(100);  // ❌ 运行时错误：不可修改

  var cfg = Config({'host': 'localhost', 'port': '8080'});
  print('主机: ${cfg.settings['host']}');  // localhost
  // cfg.settings['host'] = 'evil.com';  // ❌ 运行时错误：不可修改

  // List.unmodifiable 创建不可变列表
  var immutableList = List.unmodifiable([1, 2, 3]);
  print('不可变列表: $immutableList');
  // immutableList[0] = 99;  // ❌ 运行时错误

  // 只读集合仍然反映原始集合的变化
  var original = [1, 2, 3];
  var view = UnmodifiableListView(original);
  print('视图: $view');
  original.add(4);  // 修改原始列表
  print('视图更新: $view');  // 视图也变了！
}
''', language: 'Dart'),
          OutputBox('成绩: [90, 85, 92]\n主机: localhost\n不可变列表: [1, 2, 3]\n'
              '视图: [1, 2, 3]\n视图更新: [1, 2, 3, 4]'),
          TipBox('UnmodifiableListView 是原始集合的视图（View），不是副本。'
              '原始集合变化后，视图也会反映这些变化。'
              '如果需要完全独立的不可变副本，应在构造函数中复制一份。',
              type: TipType.warning),

          // ============================================================
          // 8. 集合排序
          // ============================================================
          SectionHeader('8. 集合排序', icon: Icons.sort),
          Paragraph('Dart 提供了多种排序方式：List.sort 就地排序、'
              'sorted 方法返回排序副本、reversed 反转。'
              '可以自定义比较器实现复杂排序规则。'),
          CodeBlock(r'''
void main() {
  // ---- 基本排序 ----
  var numbers = [3, 1, 4, 1, 5, 9, 2, 6];
  numbers.sort();
  print('升序: $numbers');             // [1, 1, 2, 3, 4, 5, 6, 9]

  // ---- 降序排序 ----
  numbers.sort((a, b) => b.compareTo(a));
  print('降序: $numbers');             // [9, 6, 5, 4, 3, 2, 1, 1]

  // ---- reversed：反转 ----
  var list = [1, 2, 3];
  var reversed = list.reversed.toList();
  print('反转: $reversed');            // [3, 2, 1]

  // ---- 自定义对象排序 ----
  var students = [
    {'name': '张三', 'score': 85},
    {'name': '李四', 'score': 92},
    {'name': '王五', 'score': 78},
  ];

  // 按分数升序
  students.sort((a, b) => a['score']!.compareTo(b['score']!));
  print('按分数排序: $students');

  // ---- 字符串排序 ----
  var names = ['Charlie', 'Alice', 'Bob'];
  names.sort();
  print('名字排序: $names');           // [Alice, Bob, Charlie]

  // 忽略大小写排序
  names = ['banana', 'Apple', 'cherry'];
  names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  print('忽略大小写: $names');          // [Apple, banana, cherry]
}
''', language: 'Dart'),
          OutputBox('升序: [1, 1, 2, 3, 4, 5, 6, 9]\n'
              '降序: [9, 6, 5, 4, 3, 2, 1, 1]\n'
              '反转: [3, 2, 1]\n'
              '按分数排序: [{name: 王五, score: 78}, {name: 张三, score: 85}, {name: 李四, score: 92}]\n'
              '名字排序: [Alice, Bob, Charlie]\n'
              '忽略大小写: [Apple, banana, cherry]'),

          const _ListManipDemo(),
          const _SetMapDemo(),
          const _CollectionMethodsDemo(),
          DividerLine(),
          SectionHeader('小练习', icon: Icons.assignment),
          Paragraph('1. 创建一个 List.generate 列表 [0,2,4,6,8]，取前 3 个元素。'),
          Paragraph('2. 用 where 筛选 [10,15,20,25,30] 中能被 3 整除的数。'),
          Paragraph('3. 用 LinkedHashSet 存储 [3,1,4,1,5,9,2,6]，验证去重和顺序保持。'),
          Paragraph('4. 用 Map.fromIterable 构建一个字符串到其长度的映射。'),
          Paragraph('5. 定义一个泛型类 Stack<T>，包含 push、pop、peek 方法。'),
          Paragraph('6. 对学生列表自定义排序：按分数降序，分数相同按名字升序。'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
