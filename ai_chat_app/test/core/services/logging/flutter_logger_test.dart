// ============================================================
// FlutterLogger 测试
// 对应源文件: lib/core/services/logging/flutter_logger.dart
//
// 测试范围:
//   - 纯逻辑（不依赖文件系统/平台）
//   - 需要平台 mocking 的（文件写入）用注释标出
// ============================================================

// import 'package:flutter_test/flutter_test.dart';
// import 'package:ai_chat_app/core/services/logging/flutter_logger.dart';
//
// void main() {
//   setUp(() {
//     // 每个测试前重置状态
//     FlutterLogger.setEnabled(false);
//   });
//
//   tearDown(() {
//     FlutterLogger.setEnabled(false);
//   });
//
//   group('installGlobalHandlers', () {
//     test('替换 FlutterError.onError', () {
//       final original = FlutterError.onError;
//       FlutterLogger.installGlobalHandlers();
//       expect(FlutterError.onError, isNot(original));
//     });
//
//     test('多次调用只安装一次', () {
//       FlutterLogger.installGlobalHandlers();
//       final handler = FlutterError.onError;
//       FlutterLogger.installGlobalHandlers();
//       expect(FlutterError.onError, handler);
//     });
//
//     test('原始 handler 仍然被调用', () {
//       Object? captured;
//       FlutterError.onError = (details) {
//         captured = details.exception;
//       };
//       FlutterLogger.installGlobalHandlers();
//
//       FlutterError.onError!(FlutterErrorDetails(
//         exception: Exception('test'),
//       ));
//       expect(captured, isA<Exception>());
//     });
//   });
//
//   group('setEnabled', () {
//     test('默认 disabled', () {
//       expect(FlutterLogger.enabled, false);
//     });
//
//     test('设为 true 后 enabled 返回 true', () async {
//       await FlutterLogger.setEnabled(true);
//       expect(FlutterLogger.enabled, true);
//     });
//
//     test('不重复设置相同值', () async {
//       // 应该不会报错
//       await FlutterLogger.setEnabled(false);
//       await FlutterLogger.setEnabled(false);
//       expect(FlutterLogger.enabled, false);
//     });
//   });
//
//   group('log', () {
//     test('disabled 时不抛出异常', () {
//       // 即使 logger 没启用，调用 log 也不该崩溃
//       expect(() => FlutterLogger.log('test'), returnsNormally);
//     });
//
//     test('带 tag', () async {
//       await FlutterLogger.setEnabled(true);
//       expect(() => FlutterLogger.log('test', tag: 'API'), returnsNormally);
//     });
//
//     test('多行文本', () async {
//       await FlutterLogger.setEnabled(true);
//       expect(
//         () => FlutterLogger.log('line1\nline2\nline3'),
//         returnsNormally,
//       );
//     });
//   });
// }
//
// ═══════════════════════════════════════════════════════════
// 💡 文件写入测试（高级）
// ═══════════════════════════════════════════════════════════
// FlutterLogger 内部调用 AppDirectories.getAppDataDirectory()
// 需要 path_provider 的平台插件，在测试中无法直接使用。
// 如果要测文件写入，有两种方式:
//
// 方案 A: 用 TestWidgetsFlutterBinding + mock path_provider
//   import 'package:flutter_test/flutter_test.dart';
//
//   setUpAll(() {
//     TestWidgetsFlutterBinding.ensureInitialized();
//   });
//
//   这样 path_provider 在测试环境会返回临时目录，
//   可以验证文件是否被创建:
//
//   test('启用后创建日志文件', () async {
//     await FlutterLogger.setEnabled(true);
//     FlutterLogger.log('测试写入');
//
//     // 等待异步写入完成
//     await Future.delayed(const Duration(milliseconds: 100));
//
//     // 验证日志目录存在
//     // 需要读取 AppDirectories.getAppDataDirectory() 来确认
//   });
//
// 方案 B: 提取纯函数单独测试
//   把时间戳格式化、行拼接等逻辑提取成可见的静态方法，
//   然后直接测字符串输出格式:
//
//   test('日志格式正确', () {
//     // 假设 formatLogLine 是可见的静态方法
//     final line = FlutterLogger.formatLogLine('test', tag: 'API');
//     expect(line, matches(r'\[\d{4}-\d{2}-\d{2}.*\] \[API\] test'));
//   });
