import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppDirectories {
  AppDirectories._();
  static Future<Directory> getAppDataDirectory() async{
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return await getApplicationSupportDirectory();
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return await getApplicationDocumentsDirectory();
    }
  }

  /// 获取软甲更新文件夹位置
  static Future<Directory> getUploadDirectory() async{
    final root = await getAppDataDirectory();
    return Directory('${root.path}/upload');
  }
  ///获取软件图片存储位置
  static Future<Directory> getImagesDirectory() async{
    final root = await getAppDataDirectory();
    return Directory('${root.path}/images');
  }
  ///获取软件avatars的位置
  static Future<Directory> getAvatarsDirectory() async{
    final root = await getAppDataDirectory();
    return Directory('${root.path}/avatars');
  }
    ///获取软件缓存的位置
  static Future<Directory> getCacheDirectory() async{
    final root = await getAppDataDirectory();
    return Directory('${root.path}/cache');
  }

    /// Gets the platform-provided application cache directory.
  ///
  /// - Android: /data/user/0/`<package>`/cache
  /// - iOS/macOS: Caches directory
  /// - Windows/Linux: platform cache directory (app-specific on Linux via XDG)
  static Future<Directory> getSystemCacheDirectory() async{
    return await getApplicationCacheDirectory();
  }

  static Future<Directory> getAvatarCacheDirectory() async{
    final root = await getAppDataDirectory();
    return Directory('${root.path}/cache/avatars');
  }

}