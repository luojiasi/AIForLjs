import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a Python code execution
class ExecutionResult {
  final String output;
  final String? error;
  final bool success;
  final double? executionTimeMs;

  const ExecutionResult({
    this.output = '',
    this.error,
    this.success = false,
    this.executionTimeMs,
  });

  factory ExecutionResult.fromJson(Map<String, dynamic> json) {
    return ExecutionResult(
      output: (json['output'] as String?) ?? '',
      error: json['error'] as String?,
      success: (json['success'] as bool?) ?? false,
      executionTimeMs: (json['execution_time_ms'] as num?)?.toDouble(),
    );
  }
}

/// Service for executing Python code via a local Flask backend.
///
/// The backend server runs at http://localhost:8765 and must be started separately:
///   cd python_executor && pip install -r requirements.txt && python server.py
class PythonExecutorService {
  static const String _baseUrl = 'http://127.0.0.1:8765';
  static const int _timeoutSeconds = 30;

  static final PythonExecutorService _instance = PythonExecutorService._();
  factory PythonExecutorService() => _instance;
  PythonExecutorService._();

  /// Check if the Python executor server is running.
  Future<bool> isServerRunning() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Execute Python code on the local server.
  ///
  /// Returns an [ExecutionResult] with output or error details.
  /// Throws [PythonExecutorException] if the server is unreachable.
  Future<ExecutionResult> execute(String code) async {
    final stopwatch = Stopwatch()..start();

    try {
      final serverAvailable = await isServerRunning();
      if (!serverAvailable) {
        throw PythonExecutorException(
          'Python 执行服务未启动。\n\n'
          '请在终端中运行以下命令启动服务：\n'
          '  cd python_executor\n'
          '  pip install -r requirements.txt\n'
          '  python server.py',
        );
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/execute'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'code': code,
              'timeout': _timeoutSeconds,
            }),
          )
          .timeout(Duration(seconds: _timeoutSeconds + 5));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final result = ExecutionResult.fromJson(jsonDecode(response.body));
        return result;
      } else {
        return ExecutionResult(
          success: false,
          error: '服务器返回错误 (${response.statusCode})',
        );
      }
    } on PythonExecutorException {
      rethrow;
    } catch (e) {
      stopwatch.stop();
      return ExecutionResult(
        success: false,
        error: '请求失败: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
      );
    }
  }
}

class PythonExecutorException implements Exception {
  final String message;
  const PythonExecutorException(this.message);

  @override
  String toString() => message;
}
