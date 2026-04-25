abstract class SettingsRepository {
  Future<void> saveApiKey(String providerId, String apiKey);
  Future<String?> getApiKey(String providerId);
  Future<void> deleteApiKey(String providerId);
  Future<void> saveBaseUrl(String providerId, String baseUrl);
  Future<String?> getBaseUrl(String providerId);
  Future<void> setThemeMode(String mode); // 'light', 'dark', 'system'
  Future<String> getThemeMode();
}
