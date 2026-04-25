// ============================================================
// RequestLogger 测试
// 对应源文件: lib/core/services/network/request_logger.dart
//
// RequestLogger 中很多是纯工具方法，非常适合单元测试
// ============================================================

// import 'package:flutter_test/flutter_test.dart';
// import 'package:ai_chat_app/core/services/network/request_logger.dart';
//
// void main() {
//   setUp(() {
//     RequestLogger.setEnabled(false);
//     // 重置请求 ID，让每个测试从 0 开始
//     while (RequestLogger.nextRequestId() != 1) {}
//   });
//
//   group('nextRequestId', () {
//     test('从 1 开始递增', () {
//       expect(RequestLogger.nextRequestId(), 1);
//       expect(RequestLogger.nextRequestId(), 2);
//       expect(RequestLogger.nextRequestId(), 3);
//     });
//   });
//
//   group('setEnabled / enabled', () {
//     test('默认 disabled', () {
//       expect(RequestLogger.enabled, false);
//     });
//
//     test('设为 true 后生效', () async {
//       await RequestLogger.setEnabled(true);
//       expect(RequestLogger.enabled, true);
//     });
//
//     test('重复设为 false 不报错', () async {
//       await RequestLogger.setEnabled(false);
//       await RequestLogger.setEnabled(false);
//     });
//   });
//
//   group('encodeObject', () {
//     test('普通对象转 JSON', () {
//       final result = RequestLogger.encodeObject({'key': 'value', 'num': 42});
//       expect(result, contains('"key"'));
//       expect(result, contains('"value"'));
//       expect(result, contains('"num"'));
//       expect(result, contains('42'));
//     });
//
//     test('列表', () {
//       final result = RequestLogger.encodeObject([1, 2, 3]);
//       expect(result, contains('1'));
//       expect(result, contains('3'));
//     });
//
//     test('null', () {
//       expect(RequestLogger.encodeObject(null), '');
//     });
//
//     test('不可序列化的对象不抛异常', () {
//       // 循环引用等场景
//       final cyclic = <dynamic>[];
//       cyclic.add(cyclic);
//       expect(() => RequestLogger.encodeObject(cyclic), returnsNormally);
//     });
//   });
//
//   group('safeDecodeUtf8', () {
//     test('正常 UTF-8', () {
//       final bytes = 'hello'.codeUnits;
//       expect(RequestLogger.safeDecodeUtf8(bytes), 'hello');
//     });
//
//     test('非法字节不抛异常', () {
//       final bytes = [0xFF, 0xFE, 0x00];
//       expect(() => RequestLogger.safeDecodeUtf8(bytes), returnsNormally);
//     });
//
//     test('空列表返回空字符串', () {
//       expect(RequestLogger.safeDecodeUtf8([]), '');
//     });
//   });
//
//   group('escape', () {
//     test('转义反斜杠', () {
//       expect(RequestLogger.escape('a\\b'), r'a\\b');
//     });
//
//     test('转义换行', () {
//       expect(RequestLogger.escape('a\nb'), r'a\nb');
//     });
//
//     test('转义回车', () {
//       expect(RequestLogger.escape('a\rb'), r'a\rb');
//     });
//
//     test('转义制表符', () {
//       expect(RequestLogger.escape('a\tb'), r'a\tb');
//     });
//
//     test('组合转义', () {
//       expect(RequestLogger.escape('a\nb\tc\\d'), r'a\nb\tc\\d');
//     });
//
//     test('普通文本不变', () {
//       expect(RequestLogger.escape('hello world'), 'hello world');
//     });
//   });
//
//   group('logLine', () {
//     test('disabled 时不抛异常', () {
//       expect(() => RequestLogger.logLine('test'), returnsNormally);
//     });
//
//     test('enabled 时不抛异常', () async {
//       await RequestLogger.setEnabled(true);
//       expect(() => RequestLogger.logLine('[REQ 1] GET /api/chat'), returnsNormally);
//     });
//   });
//
//   group('cleanupLogs', () {
//     test('参数为 0 时不删除', () async {
//       // cleanupLogs 在 autoDeleteDays=0 或 maxSizeMB=0 时不应报错
//       await expectLater(
//         () => RequestLogger.cleanupLogs(autoDeleteDays: 0, maxSizeMB: 0),
//         returnsNormally,
//       );
//     });
//   });
// }
