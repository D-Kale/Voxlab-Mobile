import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/models/progress.dart';

class LocalProgressStore {
  LocalProgressStore(this._storage);

  final SecureStorage _storage;

  Future<List<Progress>> load() async {
    final raw = await _storage
        .readString(AppConstants.secureStorageKeyLocalProgress);
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

  Future<void> save(List<Progress> entries) async {
    final raw = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await _storage.writeString(
      AppConstants.secureStorageKeyLocalProgress,
      raw,
    );
  }
}

final localProgressStoreProvider = Provider<LocalProgressStore>((ref) {
  return LocalProgressStore(ref.read(secureStorageProvider));
});
