// ============================================================
// 示例：Widget 测试常用操作
// 后续有了更多 widget 后，参考这个模式写测试
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget 测试常用操作', () {
    testWidgets('点击按钮', (tester) async {
      int count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => count++,
              child: const Text('点击'),
            ),
          ),
        ),
      );

      // 查找按钮
      expect(find.text('点击'), findsOneWidget);

      // 点击
      await tester.tap(find.text('点击'));
      expect(count, 1);
    });

    testWidgets('输入文字', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(),
          ),
        ),
      );

      // 输入文字
      await tester.enterText(find.byType(TextField), 'hello');
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('滚动列表', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
              itemBuilder: (_, i) => Text('第 $i 项'),
            ),
          ),
        ),
      );

      // 验证第 0 项可见，第 49 项不可见
      expect(find.text('第 0 项'), findsOneWidget);
      expect(find.text('第 49 项'), findsNothing);

      // 向下滚动
      await tester.scrollUntilVisible(
        find.text('第 49 项'),
        200, // 每次滚动 200 像素
      );
      expect(find.text('第 49 项'), findsOneWidget);
    });
  });

  group('查找器', () {
    // 用 find 的 text、byType、byKey 等来定位 widget
    testWidgets('各种查找方式', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('按文字查找'),
                const Icon(Icons.star, key: Key('star_icon')),
                const Placeholder(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('按文字查找'), findsOneWidget);
      expect(find.byKey(const Key('star_icon')), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('断言', () {
    // findsOneWidget  — 找到恰好一个
    // findsWidgets   — 找到一个或多个
    // findsNothing   — 没找到
    // findsNWidgets(n) — 找到 N 个
  });
}
