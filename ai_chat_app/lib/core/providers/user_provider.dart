import 'dart:io';

import 'package:ai_chat_app/utils/app_directories.dart';
import 'package:ai_chat_app/utils/avatar_cache.dart';
import 'package:ai_chat_app/utils/sandbox_path_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const String _prefsUserNameKey = 'user_name';
  static const String _prefsAvatarTypeKey ='avatar_type';
  static const String _prefsAvatarValueKey = 'avatar_value';
  String _name = 'User';
  String get name => _name;
  bool _hasSavedName = false;
  String? _avatarType; 
  String? _avatarValue;
  String? get avatarType => _avatarType;
  String? get avatarValue => _avatarValue;
  UserProvider(){_load();}

  Future<void> _load() async{
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getString(_prefsUserNameKey);
    if (n != null && n.isNotEmpty) {
      _name = n;
      _hasSavedName = true;
      notifyListeners();
    }
    _avatarType = prefs.getString(_prefsAvatarTypeKey);
    final rawAvatar = prefs.getString(_prefsAvatarValueKey);
    _avatarValue = rawAvatar == null?null:SandboxPathResolver.fix(rawAvatar);
    if(rawAvatar!=null&&_avatarValue!=null&&rawAvatar!=_avatarValue){
      try {
        await prefs.setString(_prefsAvatarValueKey, _avatarValue!);
      } catch (_) {}
    }

  }
  void setDefaultNameIfUnset(String localizedDefaultName) {
    if (_hasSavedName) return;
    final v = localizedDefaultName.trim();
    if (v.isEmpty) return;
    if (_name != v) {
      _name = v;
      notifyListeners();
    }
  }

  // 保存用户名，空值/相同值直接跳过
  Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _name) return;
    _name = trimmed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUserNameKey, _name);
  }
  // 设头像为 emoji 类型 
  Future<void> setAvatarEmoji(String emoji) async {
    final e = emoji.trim();
    if (e.isEmpty) return;
    _avatarType = 'emoji';
    _avatarValue = e;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsAvatarTypeKey, _avatarType!);
    await prefs.setString(_prefsAvatarValueKey, _avatarValue!);
  }
  // 设头像为网络图片，同时调用 AvatarCache.getPath 预缓存，方便离线显示
  Future<void> setAvatarUrl(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;
    _avatarType = 'url';
    _avatarValue = u;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsAvatarTypeKey, _avatarType!);
    await prefs.setString(_prefsAvatarValueKey, _avatarValue!);
    try {
      await AvatarCache.getPath(u);
    } catch (_) {}
  }
  
  
  
  /// 1. SandboxPathResolver.fix(path)        → 修正沙盒路径
  /// 2. 检查源文件是否存在，不存在直接 return
  /// 3. 获取/创建 avatars 目录 (AppDirectories)
  /// 4. 提取扩展名（最多6字符，超长截断为 jpg）
  /// 5. 生成文件名 avatar_<时间戳>.jpg
  /// 6. 复制到 app 持久化存储 → 保证重装/更新后头像不丢
  /// 7. 清理旧头像文件（仅限 avatars 目录内的）
  /// 8. 保存新路径到 SharedPreferences
  Future<void> setAvatarFilePath(String path) async {
    final p = path.trim();
    if (p.isEmpty) return;
    final fixedInput = SandboxPathResolver.fix(p);
    // Copy the picked image into app persistent storage so it survives reinstall/update
    try {
      final src = File(fixedInput);
      if (!await src.exists()) return;
      final avatars = await AppDirectories.getAvatarsDirectory();
      if (!await avatars.exists()) {
        await avatars.create(recursive: true);
      }
      String ext = '';
      final dot = fixedInput.lastIndexOf('.');
      if (dot != -1 && dot < p.length - 1) {
        ext = fixedInput.substring(dot + 1).toLowerCase();
        // Basic sanitize
        if (ext.length > 6) ext = 'jpg';
      } else {
        ext = 'jpg';
      }
      final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final dest = File('${avatars.path}/$filename');
      await src.copy(dest.path);

      // Optionally clean old local avatar if it was stored inside our avatars folder
      if (_avatarType == 'file' && _avatarValue != null) {
        try {
          final old = File(_avatarValue!);
          if ((old.path.contains('/avatars/') ||
                  old.path.contains('\\avatars\\')) &&
              await old.exists()) {
            await old.delete();
          }
        } catch (_) {}
      }

      _avatarType = 'file';
      _avatarValue = dest.path;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsAvatarTypeKey, _avatarType!);
      await prefs.setString(_prefsAvatarValueKey, _avatarValue!);
    } catch (_) {
      // Fallback to original path if copy fails (may still be temporary)
      _avatarType = 'file';
      _avatarValue = fixedInput;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsAvatarTypeKey, _avatarType!);
      await prefs.setString(_prefsAvatarValueKey, _avatarValue!);
    }
  }


  Future<void> resetAvatar() async {
    _avatarType = null;
    _avatarValue = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsAvatarTypeKey);
    await prefs.remove(_prefsAvatarValueKey);
  }

}