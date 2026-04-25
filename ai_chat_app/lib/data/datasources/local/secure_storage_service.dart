import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for encrypted API key storage.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveApiKey(String providerId, String apiKey) async {
    await _storage.write(key: 'api_key_$providerId', value: apiKey);
  }

  Future<String?> getApiKey(String providerId) async {
    return await _storage.read(key: 'api_key_$providerId');
  }

  Future<void> deleteApiKey(String providerId) async {
    await _storage.delete(key: 'api_key_$providerId');
  }

  Future<void> saveBaseUrl(String providerId, String baseUrl) async {
    await _storage.write(key: 'base_url_$providerId', value: baseUrl);
  }

  Future<String?> getBaseUrl(String providerId) async {
    return await _storage.read(key: 'base_url_$providerId');
  }
}
