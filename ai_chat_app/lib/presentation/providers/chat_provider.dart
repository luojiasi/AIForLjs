import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/data/datasources/remote/adapters/model_adapter.dart';
import 'package:ai_chat_app/data/models/chat_request.dart';
import 'package:ai_chat_app/data/models/message_model.dart';
import 'package:ai_chat_app/domain/entities/conversation.dart';
import 'package:ai_chat_app/domain/entities/message.dart';
import 'package:ai_chat_app/domain/usecases/manage_conversations.dart';
import 'package:ai_chat_app/domain/usecases/stream_chat.dart';
import 'package:ai_chat_app/di/providers.dart';

class ChatState {
  final String? currentConversationId;
  final List<Conversation> conversations;
  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final String streamingMessageId;

  const ChatState({
    this.currentConversationId,
    this.conversations = const [],
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.streamingMessageId = '',
  });

  ChatState copyWith({
    String? currentConversationId,
    List<Conversation>? conversations,
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    String? streamingMessageId,
  }) =>
      ChatState(
        currentConversationId: currentConversationId ?? this.currentConversationId,
        conversations: conversations ?? this.conversations,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        streamingMessageId: streamingMessageId ?? this.streamingMessageId,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ManageConversations _manageConv;
  final StreamChat _streamChat;
  StreamSubscription? _activeSub;
  Timer? _debounceTimer;
  String _accumulatedText = '';

  ChatNotifier(
    this._manageConv,
    this._streamChat,
  ) : super(const ChatState());

  Future<void> loadConversations() async {
    final conversations = await _manageConv.getConversations();
    state = state.copyWith(conversations: conversations);
  }

  Future<void> selectConversation(String id) async {
    final messages = await _manageConv.getMessages(id);
    state = state.copyWith(
      currentConversationId: id,
      messages: messages,
      errorMessage: null,
    );
  }

  Future<void> createNewChat(ModelInfo model, ModelAdapter adapter) async {
    final conv = await _manageConv.createConversation(
      title: '新对话',
      modelProviderId: adapter.providerId,
      modelName: model.id,
    );
    await loadConversations();
    state = state.copyWith(
      currentConversationId: conv.id,
      messages: [],
      errorMessage: null,
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isLoading) return;

    final convId = state.currentConversationId;
    if (convId == null) return;

    // Add user message
    final userMsg = await _manageConv.addUserMessage(convId, content);
    // Create assistant placeholder
    final assistantMsg = await _manageConv.createAssistantPlaceholder(convId);

    // Update conversation updatedAt
    await _manageConv.renameConversation(convId, state.conversations
        .firstWhere((c) => c.id == convId)
        .title);

    // Refresh conversations list
    await loadConversations();

    state = state.copyWith(
      messages: [...state.messages, userMsg, assistantMsg],
      isLoading: true,
      streamingMessageId: assistantMsg.id,
      errorMessage: null,
    );

    _accumulatedText = '';

    final conv = await _manageConv.getConversations().then(
          (list) => list.firstWhere((c) => c.id == convId));

    final request = ChatRequest(
      modelName: conv.modelName,
      messages: _buildMessageList(content),
      stream: true,
    );

    try {
      final stream = _streamChat(request, conv.modelProviderId);
      _activeSub = stream.listen(
        (chunk) {
          _accumulatedText += chunk.deltaContent;
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 80), () {
            _manageConv.updateMessageContent(assistantMsg.id, _accumulatedText);
            _updateMessageInState(assistantMsg.id, _accumulatedText);
          });
        },
        onDone: () {
          _manageConv.markMessageComplete(assistantMsg.id);
          _manageConv.updateMessageContent(assistantMsg.id, _accumulatedText);
          _updateMessageInState(assistantMsg.id, _accumulatedText, isStreaming: false);
          state = state.copyWith(isLoading: false);
        },
        onError: (e) {
          _manageConv.setMessageError(assistantMsg.id, e.toString());
          _updateMessageInState(assistantMsg.id, _accumulatedText,
              isStreaming: false, error: e.toString());
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        },
      );
    } catch (e) {
      _manageConv.setMessageError(assistantMsg.id, e.toString());
      _updateMessageInState(assistantMsg.id, '', isStreaming: false, error: e.toString());
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  List<MessageModel> _buildMessageList(String newContent) {
    final msgs = state.messages
        .where((m) => !m.isStreaming && m.errorMessage == null)
        .map((m) => MessageModel(role: m.role, content: m.content))
        .toList();
    msgs.add(MessageModel(role: 'user', content: newContent));
    return msgs;
  }

  void _updateMessageInState(String id, String content, {bool isStreaming = true, String? error}) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          content: content,
          isStreaming: isStreaming,
          errorMessage: error ?? m.errorMessage,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void cancelStream() {
    _activeSub?.cancel();
    _activeSub = null;
    _debounceTimer?.cancel();
    if (state.streamingMessageId.isNotEmpty) {
      _manageConv.markMessageComplete(state.streamingMessageId);
      _updateMessageInState(state.streamingMessageId, _accumulatedText, isStreaming: false);
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> deleteConversation(String id) async {
    await _manageConv.deleteConversation(id);
    await loadConversations();
    if (state.currentConversationId == id) {
      state = state.copyWith(currentConversationId: null, messages: []);
    }
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(manageConversationsProvider),
    ref.watch(streamChatProvider),
  );
});
