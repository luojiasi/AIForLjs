// ============================================================
// 示例：单元测试
// 测试纯 Dart 类/函数，不涉及 UI
// ============================================================
// 后续有了 model 后，把测试写在 test/core/models/xxx_test.dart

import 'package:flutter_test/flutter_test.dart';

// ── 假设有一个 User 模型 ──
// class User {
//   final String name;
//   final int age;
//   User(this.name, this.age);
//   bool get isAdult => age >= 18;
// }

void main() {
  group('单元测试示例 - 等你有 model 后取消注释', () {
    // test('成年判断', () {
    //   final user = User('张三', 20);
    //   expect(user.isAdult, true);
    // });
    //
    // test('未成年判断', () {
    //   final user = User('李四', 16);
    //   expect(user.isAdult, false);
    // });
  });

  // ── 常用断言用法 ──
  group('常用断言', () {
    test('相等/不等', () {
      expect(1 + 1, 2);
      expect(1 + 1, isNot(3));
    });

    test('布尔值', () {
      expect(true, isTrue);
      expect(false, isFalse);
    });

    test('字符串包含', () {
      expect('Hello World', contains('World'));
    });

    test('列表', () {
      expect([1, 2, 3], hasLength(3));
      expect([1, 2, 3], contains(2));
    });

    test('异常抛出', () {
      expect(() => throw Exception('出错了'), throwsException);
    });
  });
}
