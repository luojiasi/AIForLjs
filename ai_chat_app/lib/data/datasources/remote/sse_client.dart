import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Low-level SSE-over-HTTP client shared by all model adapters.
class SseClient {
  final Dio _dio;

  SseClient({Dio? dio}) : _dio = dio ?? Dio();

  /// Connects to an SSE endpoint and returns a [Stream] of raw JSON data strings.
  Stream<String> connect({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    CancelToken? cancelToken,
  }) async* {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
    );

    final stream = response.data.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.isEmpty) continue;
      if (line.startsWith(':')) continue;
      // Anthropic SSE has event: lines followed by data: lines
      if (line.startsWith('event: ')) continue;
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') continue;
        yield data;
      }
    }
  }
}
