import 'package:ai_chat_app/domain/entities/conversation.dart';
import 'package:ai_chat_app/domain/entities/message.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation?> getConversation(String id);
  Future<Conversation> createConversation(Conversation conversation);
  Future<void> updateConversation(String id, {String? title});
  Future<void> deleteConversation(String id);

  Future<List<Message>> getMessages(String conversationId);
  Future<Message> addMessage(Message message);
  Future<void> updateMessageContent(String id, String content);
  Future<void> markMessageComplete(String id);
  Future<void> setMessageError(String id, String error);
}
