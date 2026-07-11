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

  Future<void> saveGuestId(String id) async {
    await _storage.write(key: AppConstants.secureStorageKeyGuestId, value: id);
  }

  Future<String?> getGuestId() async {
    return _storage.read(key: AppConstants.secureStorageKeyGuestId);
  }

  Future<void> saveTotalXp(int xp) async {
    await _storage.write(key: AppConstants.secureStorageKeyTotalXp, value: xp.toString());
  }

  Future<int?> getTotalXp() async {
    final value = await _storage.read(key: AppConstants.secureStorageKeyTotalXp);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> saveCompletedExerciseIds(Set<String> ids) async {
    await _storage.write(key: AppConstants.secureStorageKeyCompletedIds, value: ids.join(','));
  }

  Future<Set<String>> getCompletedExerciseIds() async {
    final value = await _storage.read(key: AppConstants.secureStorageKeyCompletedIds);
    if (value == null || value.isEmpty) return {};
    return value.split(',').toSet();
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
