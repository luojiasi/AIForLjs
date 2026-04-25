import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';

/// Abstract interface for AI model providers.
/// To add a new provider: implement this interface, register in [ModelProviderRegistry].
abstract class ModelAdapter {
  String get providerId;
  String get providerName;
  String get baseUrl;
  List<ModelInfo> get supportedModels;

  Map<String, String> buildHeaders(String apiKey);
  Map<String, dynamic> buildRequestBody(ChatRequest request, {required bool stream});
  ChatResponseChunk? parseChunk(Map<String, dynamic> rawJson);
}

class ModelInfo {
  final String id;
  final String displayName;
  final int maxTokens;

  const ModelInfo({
    required this.id,
    required this.displayName,
    required this.maxTokens,
  });
}
