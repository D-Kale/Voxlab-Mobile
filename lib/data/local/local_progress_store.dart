import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/models/progress.dart';

class LocalProgressStore {
  LocalProgressStore(this._storage);

  LocalProgressStore.test() : _storage = null;

  final SecureStorage? _storage;

  static String _keyForUser(String userId) =>
      '${AppConstants.secureStorageKeyLocalProgress}_$userId';

  Future<List<Progress>> load(String userId) async {
    if (_storage == null) return [];
    final key = _keyForUser(userId);
    final raw = await _storage.readString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Progress.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(String userId, List<Progress> entries) async {
    if (_storage == null) return;
    final key = _keyForUser(userId);
    final raw = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await _storage.writeString(key, raw);
  }

  Future<void> clear(String userId) async {
    if (_storage == null) return;
    final key = _keyForUser(userId);
    await _storage.delete(key);
  }
}

final localProgressStoreProvider = Provider<LocalProgressStore>((ref) {
  return LocalProgressStore(ref.read(secureStorageProvider));
});