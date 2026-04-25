import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';
import 'model_adapter.dart';

/// Handles any API that follows the OpenAI Chat Completions format
/// but with a different base URL (DeepSeek, Groq, Ollama, etc.).
class OpenAiCompatibleAdapter implements ModelAdapter {
  @override
  final String providerId;
  @override
  final String providerName;
  @override
  final String baseUrl;
  final List<ModelInfo> _models;

  const OpenAiCompatibleAdapter({
    required this.providerId,
    required this.providerName,
    required this.baseUrl,
    required List<ModelInfo> models,
  }) : _models = models;

  @override
  List<ModelInfo> get supportedModels => _models;

  @override
  Map<String, String> buildHeaders(String apiKey) => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      };

  @override
  Map<String, dynamic> buildRequestBody(ChatRequest request, {required bool stream}) {
    return {
      'model': request.modelName,
      'messages': request.messages.map((m) => m.toJson()).toList(),
      'stream': stream,
      if (request.maxTokens != null) 'max_tokens': request.maxTokens,
      if (request.temperature != null) 'temperature': request.temperature,
    };
  }

  @override
  ChatResponseChunk? parseChunk(Map<String, dynamic> rawJson) {
    final choices = rawJson['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;
    final delta = choices[0]['delta'] as Map<String, dynamic>?;
    if (delta == null) return null;
    final content = delta['content'] as String?;
    if (content == null) return null;
    return ChatResponseChunk(deltaContent: content);
  }
}
