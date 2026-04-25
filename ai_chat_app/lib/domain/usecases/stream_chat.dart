import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/chat_response_chunk.dart';
import 'package:ai_chat_app/domain/repositories/chat_repository.dart';
import 'package:ai_chat_app/domain/repositories/settings_repository.dart';

class StreamChat {
  final ChatRepository _chatRepo;
  final SettingsRepository _settingsRepo;

  StreamChat(this._chatRepo, this._settingsRepo);

  Stream<ChatResponseChunk> call(ChatRequest request, String providerId) async* {
    final apiKey = await _settingsRepo.getApiKey(providerId);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured for $providerId');
    }
    yield* _chatRepo.streamChat(request, providerId, apiKey);
  }
}
