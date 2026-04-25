import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/core/utils/monitoring.dart';
import 'package:ai_chat_app/data/datasources/local/storage_service.dart';
import 'package:ai_chat_app/data/datasources/local/secure_storage_service.dart';
import 'package:ai_chat_app/data/datasources/remote/model_provider_registry.dart';
import 'package:ai_chat_app/data/datasources/remote/sse_client.dart';
import 'package:ai_chat_app/data/repositories/chat_repository_impl.dart';
import 'package:ai_chat_app/data/repositories/conversation_repository_impl.dart';
import 'package:ai_chat_app/data/repositories/settings_repository_impl.dart';
import 'package:ai_chat_app/domain/repositories/chat_repository.dart';
import 'package:ai_chat_app/domain/repositories/conversation_repository.dart';
import 'package:ai_chat_app/domain/repositories/settings_repository.dart';
import 'package:ai_chat_app/domain/usecases/stream_chat.dart';
import 'package:ai_chat_app/domain/usecases/manage_conversations.dart';

// ── Data Sources ──
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final modelProviderRegistryProvider = Provider<ModelProviderRegistry>((ref) => ModelProviderRegistry());

final sseClientProvider = Provider<SseClient>((ref) {
  final dio = Dio();
  dio.interceptors.add(Monitoring.dioInterceptor);
  return SseClient(dio: dio);
});

// ── Repositories ──
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(
    storage: ref.watch(storageServiceProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    registry: ref.watch(modelProviderRegistryProvider),
    sseClient: ref.watch(sseClientProvider),
  );
});

// ── Use Cases ──
final manageConversationsProvider = Provider<ManageConversations>((ref) {
  return ManageConversations(ref.watch(conversationRepositoryProvider));
});

final streamChatProvider = Provider<StreamChat>((ref) {
  return StreamChat(
    ref.watch(chatRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
});
