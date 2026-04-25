import 'package:ai_chat_app/utils/app_directories.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 手动初始化测试绑定（test 模式下不会自动初始化）
  TestWidgetsFlutterBinding.ensureInitialized();

  // 每个测试之前设置 mock 环境
  setUp(() {
    // Mock path_provider 的平台通道，让它返回一个固定的路径
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '/data/user/0/com.example.app/files';
        }
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return '/data/user/0/com.example.app/support';
        }
        return null;
      },
    );
  });

  // 测试结束后清理 mock
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  test('getUploadDirectory returns path ending with /upload', () async {
    final dir = await AppDirectories.getUploadDirectory();
    expect(dir.path, endsWith('/upload'));
  });

  test('getImagesDirectory returns path ending with /images', () async {
    final dir = await AppDirectories.getImagesDirectory();
    expect(dir.path, endsWith('/images'));
  });

  test('getAvatarDirectory returns path ending with /avatars', () async {
    final dir = await AppDirectories.getAvatarDirectory();
    expect(dir.path, endsWith('/avatars'));
  });
}
