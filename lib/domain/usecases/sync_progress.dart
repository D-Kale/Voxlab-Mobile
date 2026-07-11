import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/drift/app_database.dart';
import '../../core/storage/drift/daos/progress_dao.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/remote/services/auth_service.dart';
import '../../data/remote/services/progress_service.dart';
import '../../domain/models/progress.dart';
import '../../domain/models/user.dart';

class SyncResult {
  const SyncResult({required this.progress, required this.user});

  final List<Progress> progress;
  final User user;
}

class SyncProgressUseCase {
  SyncProgressUseCase({
    required this.progressService,
    required this.progressDao,
    required this.secureStorage,
    required this.authService,
  });

  final ProgressService progressService;
  final ProgressDao progressDao;
  final SecureStorage secureStorage;
  final AuthService authService;

  Future<SyncResult?> call() async {
    final rows = await progressDao.getAllGuestProgress();
    if (rows.isEmpty) return null;

    final byLesson = <int, List<GuestProgress>>{};
    for (final row in rows) {
      if (row.lessonId == null) continue;
      byLesson.putIfAbsent(row.lessonId!, () => []).add(row);
    }

    if (byLesson.isEmpty) return null;

    final items = byLesson.entries.map((e) {
      final lessonRows = e.value;
      final totalScore = lessonRows.fold<int>(
        0,
        (sum, r) => sum + (r.score ?? 0),
      );

      String? completedAt;
      for (final r in lessonRows) {
        if (r.completedAt != null) {
          completedAt = r.completedAt!.toUtc().toIso8601String();
          break;
        }
      }

      return {
        'lesson_id': e.key,
        'score': totalScore,
        'status': 'completed',
        'completed_at': completedAt,
      };
    }).toList();

    await progressService.syncProgress(items);

    final serverProgress = await progressService.getProgress();
    final user = await authService.getMe();

    await progressDao.clearAll();
    await secureStorage.saveTotalXp(0);
    await secureStorage.saveCompletedExerciseIds({});

    return SyncResult(progress: serverProgress, user: user);
  }
}

final syncProgressUseCaseProvider = Provider<SyncProgressUseCase>((ref) {
  return SyncProgressUseCase(
    progressService: ref.read(progressServiceProvider),
    progressDao: ref.read(progressDaoProvider),
    secureStorage: ref.read(secureStorageProvider),
    authService: ref.read(authServiceProvider),
  );
});
