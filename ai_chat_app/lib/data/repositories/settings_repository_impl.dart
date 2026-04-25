import 'package:ai_chat_app/data/datasources/local/secure_storage_service.dart';
import 'package:ai_chat_app/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SecureStorageService _secureStorage;

  SettingsRepositoryImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> saveApiKey(String providerId, String apiKey) =>
      _secureStorage.saveApiKey(providerId, apiKey);

  @override
  Future<String?> getApiKey(String providerId) =>
      _secureStorage.getApiKey(providerId);

  @override
  Future<void> deleteApiKey(String providerId) =>
      _secureStorage.deleteApiKey(providerId);

  @override
  Future<void> saveBaseUrl(String providerId, String baseUrl) =>
      _secureStorage.saveBaseUrl(providerId, baseUrl);

  @override
  Future<String?> getBaseUrl(String providerId) =>
      _secureStorage.getBaseUrl(providerId);

  @override
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  @override
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode') ?? 'system';
  }
}
