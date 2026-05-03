import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';

/// Desktop system font scanner and loader.
/// Replaces the removed google_fonts' SystemFonts class (google_fonts >= 8.0.0).
class SystemFonts {
  /// Returns list of available system font family names.
  Future<List<String>> getSystemFonts() async {
    final dirs = _fontDirectories();
    final patterns = ['*.ttf', '*.otf', '*.ttc'];
    final families = <String>{};
    for (final dir in dirs) {
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final name = entity.path.toLowerCase();
            if (patterns.any((p) => name.endsWith(p.replaceAll('*', '')))) {
              // Attempt to parse font family from file name
              final base = entity.uri.pathSegments.last.replaceAll(
                RegExp(r'\.(ttf|otf|ttc)$', caseSensitive: false),
                '',
              );
              // Heuristic: strip weight/style suffixes to get family name
              final family = _guessFamily(base);
              if (family.isNotEmpty) families.add(family);
            }
          }
        }
      } catch (_) {}
    }
    final sorted = families.toList()..sort();
    return sorted;
  }

  /// Load a system font by family name and register it dynamically.
  Future<void> loadFont(String family) async {
    final file = await _findFontFile(family);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final loader = FontLoader(family);
    loader.addFont(Future.value(bytes.buffer.asByteData()));
    await loader.load();
  }

  Future<File?> _findFontFile(String family) async {
    final dirs = _fontDirectories();
    final lower = family.toLowerCase().replaceAll(' ', '');
    for (final dir in dirs) {
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final name = entity.path.toLowerCase();
            if (name.endsWith('.ttf') ||
                name.endsWith('.otf') ||
                name.endsWith('.ttc')) {
              final base = entity.uri.pathSegments.last.toLowerCase();
              if (base.replaceAll(' ', '').contains(lower)) {
                return entity;
              }
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  List<Directory> _fontDirectories() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        final windir = Platform.environment['WINDIR'] ?? r'C:\Windows';
        return [
          Directory('$windir\\Fonts'),
          Directory(
            '${Platform.environment['LOCALAPPDATA'] ?? r'C:\Users\Default\AppData\Local'}\\Microsoft\\Windows\\Fonts',
          ),
        ];
      case TargetPlatform.macOS:
        return [
          Directory('/System/Library/Fonts'),
          Directory('/Library/Fonts'),
          Directory(
            '${Platform.environment['HOME'] ?? '/Users'}/Library/Fonts',
          ),
        ];
      case TargetPlatform.linux:
        return [
          Directory('/usr/share/fonts'),
          Directory('/usr/local/share/fonts'),
          Directory(
            '${Platform.environment['HOME'] ?? '/home'}/.local/share/fonts',
          ),
          Directory('${Platform.environment['HOME'] ?? '/home'}/.fonts'),
        ];
      default:
        return [];
    }
  }

  /// Heuristic to guess font family from file name.
  String _guessFamily(String fileName) {
    // Remove common weight/style suffixes like -Regular, -Bold, _Italic etc.
    String s = fileName
        .replaceAll(RegExp(r'[-_](Regular|Bold|Italic|BoldItalic|Medium|Light|Thin|Black|Heavy|Semibold|ExtraBold|ExtraLight|SemiBold)$', caseSensitive: false), '');
    // Title case each word
    return s
        .split(RegExp(r'[-_\s]+'))
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
