import 'package:ai_chat_app/domain/entities/conversation.dart';
import 'package:ai_chat_app/domain/entities/message.dart';
import 'package:ai_chat_app/domain/repositories/conversation_repository.dart';
import 'package:uuid/uuid.dart';

class ManageConversations {
  final ConversationRepository _repo;
  final Uuid _uuid;

  ManageConversations(this._repo) : _uuid = const Uuid();

  Future<List<Conversation>> getConversations() => _repo.getConversations();

  Future<Conversation> createConversation({
    required String title,
    required String modelProviderId,
    required String modelName,
  }) async {
    final now = DateTime.now();
    final conv = Conversation(
      id: _uuid.v4(),
      title: title,
      modelProviderId: modelProviderId,
      modelName: modelName,
      createdAt: now,
      updatedAt: now,
    );
    return _repo.createConversation(conv);
  }

  Future<void> renameConversation(String id, String title) =>
      _repo.updateConversation(id, title: title);

  Future<void> deleteConversation(String id) =>
      _repo.deleteConversation(id);

  Future<List<Message>> getMessages(String conversationId) =>
      _repo.getMessages(conversationId);

  Future<Message> addUserMessage(String conversationId, String content) async {
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    return _repo.addMessage(message);
  }

  Future<Message> createAssistantPlaceholder(String conversationId) async {
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    return _repo.addMessage(message);
  }

  Future<void> updateMessageContent(String id, String content) =>
      _repo.updateMessageContent(id, content);

  Future<void> markMessageComplete(String id) =>
      _repo.markMessageComplete(id);

  Future<void> setMessageError(String id, String error) =>
      _repo.setMessageError(id, error);
}
