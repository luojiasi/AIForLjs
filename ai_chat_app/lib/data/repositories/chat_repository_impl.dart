import 'package:ai_chat_app/data/datasources/remote/model_provider_registry.dart';
import 'package:ai_chat_app/data/datasources/remote/sse_client.dart';
import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';
import 'package:ai_chat_app/domain/repositories/chat_repository.dart';
import 'dart:convert';

class ChatRepositoryImpl implements ChatRepository {
  final ModelProviderRegistry _registry;
  final SseClient _sseClient;

  ChatRepositoryImpl({
    required ModelProviderRegistry registry,
    SseClient? sseClient,
  })  : _registry = registry,
        _sseClient = sseClient ?? SseClient();

  @override
  Stream<ChatResponseChunk> streamChat(
    ChatRequest request,
    String providerId,
    String apiKey,
  ) async* {
    final adapter = _registry.getRequired(providerId);
    final baseUrl = adapter.baseUrl;
    final endpoint = providerId == 'anthropic'
        ? '/messages'
        : '/chat/completions';
    final url = '$baseUrl$endpoint';

    final headers = adapter.buildHeaders(apiKey);
    final body = adapter.buildRequestBody(request, stream: true);

    final rawStream = _sseClient.connect(
      url: url,
      headers: headers,
      body: body,
    );

    await for (final rawJson in rawStream) {
      try {
        final json = jsonDecode(rawJson) as Map<String, dynamic>;
        final chunk = adapter.parseChunk(json);
        if (chunk != null) yield chunk;
      } catch (_) {
        // Skip malformed SSE data
      }
    }
  }

  @override
  Future<String> sendChat(
    ChatRequest request,
    String providerId,
    String apiKey,
  ) async {
    // Non-streaming fallback — collect all streaming chunks.
    final buffer = StringBuffer();
    await for (final chunk in streamChat(request, providerId, apiKey)) {
      buffer.write(chunk.deltaContent);
    }
    return buffer.toString();
  }
}
