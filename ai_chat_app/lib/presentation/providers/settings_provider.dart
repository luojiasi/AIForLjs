import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_app/domain/repositories/settings_repository.dart';
import 'package:ai_chat_app/di/providers.dart';

class SettingsState {
  final Map<String, bool> apiKeyConfigured;
  final String themeMode;

  const SettingsState({
    this.apiKeyConfigured = const {},
    this.themeMode = 'system',
  });

  SettingsState copyWith({Map<String, bool>? apiKeyConfigured, String? themeMode}) =>
      SettingsState(
        apiKeyConfigured: apiKeyConfigured ?? this.apiKeyConfigured,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const SettingsState());

  Future<void> loadSettings() async {
    final themeMode = await _repo.getThemeMode();
    final openaiKey = await _repo.getApiKey('openai');
    final anthropicKey = await _repo.getApiKey('anthropic');
    state = state.copyWith(
      themeMode: themeMode,
      apiKeyConfigured: {
        'openai': openaiKey != null && openaiKey.isNotEmpty,
        'anthropic': anthropicKey != null && anthropicKey.isNotEmpty,
      },
    );
  }

  Future<void> saveApiKey(String providerId, String apiKey) async {
    await _repo.saveApiKey(providerId, apiKey);
    await loadSettings();
  }

  Future<void> removeApiKey(String providerId) async {
    await _repo.deleteApiKey(providerId);
    await loadSettings();
  }

  Future<void> setThemeMode(String mode) async {
    await _repo.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<String?> getApiKey(String providerId) => _repo.getApiKey(providerId);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});
