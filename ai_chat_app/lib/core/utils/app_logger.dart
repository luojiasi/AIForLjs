import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._();
  factory AppLogger() => _instance;
  AppLogger._();

  bool fileLoggingEnabled = true;
  File? _logFile;
  final StreamController<String> _queue = StreamController<String>.broadcast();
  StreamSubscription<String>? _subscription;

  static const int maxFileSize = 5 * 1024 * 1024;

  Future<void> init() async {
    if (!fileLoggingEnabled) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logFile = File('${logDir.path}/app.log');

      if (await _logFile!.exists() &&
          await _logFile!.length() > maxFileSize) {
        await _logFile!.rename('${logDir.path}/app.1.log');
        _logFile = File('${logDir.path}/app.log');
      }

      _subscription = _queue.stream.listen(_writeToFile);
    } catch (_) {
      fileLoggingEnabled = false;
    }
  }

  void _write(
    String level,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    final now = DateTime.now();
    final ts =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)} ${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';
    final buf = StringBuffer('[$ts] [$level] $message');
    if (error != null) buf.write(' | $error');

    final line = buf.toString();
    debugPrint(line);

    if (fileLoggingEnabled && _logFile != null) {
      final fileBuf = StringBuffer('$line\n');
      if (stack != null) fileBuf.write('${stack.toString()}\n');
      _queue.add(fileBuf.toString());
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void debug(String msg) => _write('DEBUG', msg);
  void info(String msg) => _write('INFO', msg);
  void warn(String msg, [Object? error]) => _write('WARN', msg, error);
  void error(String msg, [Object? error, StackTrace? stack]) =>
      _write('ERROR', msg, error, stack);

  Future<void> _writeToFile(String line) async {
    try {
      await _logFile!.writeAsString(line, mode: FileMode.append);
    } catch (_) {}
  }

  void dispose() {
    _subscription?.cancel();
    _queue.close();
  }
}
