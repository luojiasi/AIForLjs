import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';

abstract class ChatRepository {
  Stream<ChatResponseChunk> streamChat(ChatRequest request, String providerId, String apiKey);
  Future<String> sendChat(ChatRequest request, String providerId, String apiKey);
}
