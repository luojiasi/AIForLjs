import 'package:ai_chat_app/core/constants/api_endpoints.dart';
import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';
import 'model_adapter.dart';

class OpenAiAdapter implements ModelAdapter {
  const OpenAiAdapter();

  @override
  String get providerId => 'openai';

  @override
  String get providerName => 'OpenAI';

  @override
  String get baseUrl => ApiEndpoints.openaiDefaultBaseUrl;

  @override
  List<ModelInfo> get supportedModels => const [
        ModelInfo(id: 'gpt-4o', displayName: 'GPT-4o', maxTokens: 128000),
        ModelInfo(id: 'gpt-4o-mini', displayName: 'GPT-4o Mini', maxTokens: 128000),
        ModelInfo(id: 'gpt-4.1', displayName: 'GPT-4.1', maxTokens: 1000000),
        ModelInfo(id: 'o3', displayName: 'o3', maxTokens: 200000),
        ModelInfo(id: 'o4-mini', displayName: 'o4-mini', maxTokens: 200000),
      ];

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
    final finishReason = choices[0]['finish_reason'] as String?;
    final usage = rawJson['usage'] as Map<String, dynamic>?;
    return ChatResponseChunk(
      deltaContent: content,
      finishReason: finishReason,
      inputTokens: usage?['prompt_tokens'] as int?,
      outputTokens: usage?['completion_tokens'] as int?,
    );
  }
}
