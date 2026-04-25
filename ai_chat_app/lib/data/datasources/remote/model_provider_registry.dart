import 'package:ai_chat_app/data/datasources/remote/adapters/model_adapter.dart';
import 'package:ai_chat_app/data/datasources/remote/adapters/openai_adapter.dart';
import 'package:ai_chat_app/data/datasources/remote/adapters/anthropic_adapter.dart';
import 'package:ai_chat_app/data/datasources/remote/adapters/openai_compatible_adapter.dart';

class ModelProviderRegistry {
  final Map<String, ModelAdapter> _adapters = {};

  ModelProviderRegistry() {
    _registerBuiltIn();
  }

  void _registerBuiltIn() {
    register(const OpenAiAdapter());
    register(const AnthropicAdapter());
  }

  void register(ModelAdapter adapter) {
    _adapters[adapter.providerId] = adapter;
  }

  void registerCustom(OpenAiCompatibleAdapter adapter) {
    _adapters[adapter.providerId] = adapter;
  }

  void unregister(String providerId) {
    _adapters.remove(providerId);
  }

  ModelAdapter? get(String providerId) => _adapters[providerId];

  ModelAdapter getRequired(String providerId) {
    final adapter = _adapters[providerId];
    if (adapter == null) {
      throw StateError('No adapter registered for provider: $providerId');
    }
    return adapter;
  }

  List<ModelAdapter> get allAdapters => _adapters.values.toList();
}
