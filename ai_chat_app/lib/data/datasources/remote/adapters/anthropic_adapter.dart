import 'package:ai_chat_app/core/constants/api_endpoints.dart';
import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';
import 'model_adapter.dart';

class AnthropicAdapter implements ModelAdapter {
  const AnthropicAdapter();

  @override
  String get providerId => 'anthropic';

  @override
  String get providerName => 'Anthropic Claude';

  @override
  String get baseUrl => ApiEndpoints.anthropicDefaultBaseUrl;

  @override
  List<ModelInfo> get supportedModels => const [
        ModelInfo(id: 'claude-sonnet-4-20250514', displayName: 'Claude Sonnet 4', maxTokens: 200000),
        ModelInfo(id: 'claude-opus-4-20250514', displayName: 'Claude Opus 4', maxTokens: 200000),
      ];

  @override
  Map<String, String> buildHeaders(String apiKey) => {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      };

  @override
  Map<String, dynamic> buildRequestBody(ChatRequest request, {required bool stream}) {
    final systemMessages = request.messages.where((m) => m.role == 'system');
    final chatMessages = request.messages.where((m) => m.role != 'system');

    final body = <String, dynamic>{
      'model': request.modelName,
      'messages': chatMessages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      'stream': stream,
      'max_tokens': request.maxTokens ?? 4096,
    };
    if (systemMessages.isNotEmpty) {
      body['system'] = systemMessages.map((m) => m.content).join('\n');
    }
    return body;
  }

  @override
  ChatResponseChunk? parseChunk(Map<String, dynamic> rawJson) {
    final type = rawJson['type'] as String?;
    if (type == 'content_block_delta') {
      final delta = rawJson['delta'] as Map<String, dynamic>?;
      if (delta?['type'] == 'text_delta') {
        return ChatResponseChunk(deltaContent: delta!['text'] as String);
      }
    }
    if (type == 'message_delta') {
      final usage = rawJson['usage'] as Map<String, dynamic>?;
      return ChatResponseChunk(
        deltaContent: '',
        inputTokens: usage?['input_tokens'] as int?,
        outputTokens: usage?['output_tokens'] as int?,
      );
    }
    return null;
  }
}
