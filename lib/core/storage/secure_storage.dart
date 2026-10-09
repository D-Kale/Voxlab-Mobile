import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.secureStorageKeyToken, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: AppConstants.secureStorageKeyToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.secureStorageKeyToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> writeString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) async {
    return _storage.read(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
