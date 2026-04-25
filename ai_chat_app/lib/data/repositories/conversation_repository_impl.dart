import 'package:ai_chat_app/data/datasources/local/storage_service.dart';
import 'package:ai_chat_app/domain/entities/conversation.dart';
import 'package:ai_chat_app/domain/entities/message.dart';
import 'package:ai_chat_app/domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final StorageService _storage;

  static const _conversationsFile = 'conversations.json';
  static const _messagesFile = 'messages.json';

  ConversationRepositoryImpl({required StorageService storage})
      : _storage = storage;

  @override
  Future<List<Conversation>> getConversations() async {
    final data = await _storage.readAll(_conversationsFile);
    return data
        .map((json) => Conversation.fromJson(json))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Conversation?> getConversation(String id) async {
    final json = await _storage.readOne(_conversationsFile, id);
    if (json == null) return null;
    return Conversation.fromJson(json);
  }

  @override
  Future<Conversation> createConversation(Conversation conversation) async {
    await _storage.insertOne(_conversationsFile, conversation.toJson());
    return conversation;
  }

  @override
  Future<void> updateConversation(String id, {String? title}) async {
    final updates = <String, dynamic>{'updatedAt': DateTime.now().toIso8601String()};
    if (title != null) updates['title'] = title;
    await _storage.updateOne(_conversationsFile, id, updates);
  }

  @override
  Future<void> deleteConversation(String id) async {
    // Delete conversation and its messages
    await _storage.deleteOne(_conversationsFile, id);
    final allMessages = await _storage.readAll(_messagesFile);
    allMessages.removeWhere((m) => m['conversationId'] == id);
    await _storage.writeAll(_messagesFile, allMessages);
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final all = await _storage.readAll(_messagesFile);
    return all
        .where((json) => json['conversationId'] == conversationId)
        .map((json) => Message.fromJson(json))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Message> addMessage(Message message) async {
    await _storage.insertOne(_messagesFile, message.toJson());
    return message;
  }

  @override
  Future<void> updateMessageContent(String id, String content) async {
    await _storage.updateOne(_messagesFile, id, {'content': content});
  }

  @override
  Future<void> markMessageComplete(String id) async {
    await _storage.updateOne(_messagesFile, id, {'isStreaming': false});
  }

  @override
  Future<void> setMessageError(String id, String error) async {
    await _storage.updateOne(_messagesFile, id, {
      'isStreaming': false,
      'errorMessage': error,
    });
  }
}
