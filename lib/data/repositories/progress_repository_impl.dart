import 'package:flutter/foundation.dart';
import '../../core/storage/drift/daos/progress_dao.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/models/lesson_status.dart';
import '../../domain/models/progress.dart';
import '../../domain/repositories/i_progress_repository.dart';
import '../remote/services/progress_service.dart';

class ProgressRepositoryImpl implements IProgressRepository {
  ProgressRepositoryImpl({
    required this.progressDao,
    required this.progressService,
    required this.secureStorage,
  });

  final ProgressDao progressDao;
  final ProgressService progressService;
  final SecureStorage secureStorage;

  @override
  Future<void> saveLocalProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    String? exerciseType,
  }) async {
    await progressDao.upsertProgress(
      exerciseId: exerciseId,
      lessonId: lessonId,
      status: status,
      score: score,
      exerciseType: exerciseType,
    );
  }

  @override
  Future<Progress?> getProgress(String exerciseId) async {
    final row = await progressDao.getProgress(exerciseId);
    if (row == null) return null;

    return Progress(
      exerciseId: row.exerciseId,
      status: LessonStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => LessonStatus.available,
      ),
      score: row.score,
      completedAt: row.completedAt,
    );
  }

  @override
  Future<List<Progress>> getLocalProgress() async {
    final rows = await progressDao.getAllGuestProgress();
    return rows
        .map(
          (r) => Progress(
            exerciseId: r.exerciseId,
            lessonId: r.lessonId,
            status: LessonStatus.values.firstWhere(
              (s) => s.name == r.status,
              orElse: () => LessonStatus.available,
            ),
            score: r.score,
            completedAt: r.completedAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<Progress>> getUnsyncedProgress() async {
    final rows = await progressDao.getUnsyncedProgress();
    return rows
        .map(
          (r) => Progress(
            exerciseId: r.exerciseId,
            lessonId: r.lessonId,
            status: LessonStatus.values.firstWhere(
              (s) => s.name == r.status,
              orElse: () => LessonStatus.available,
            ),
            score: r.score,
            completedAt: r.completedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> syncProgress() async {
    final hasToken = await secureStorage.hasToken();
    if (!hasToken) return;

    try {
      final unsynced = await progressDao.getUnsyncedProgress();

      for (final item in unsynced) {
        if (item.score != null && item.lessonId != null) {
          try {
            await progressService.completeLesson(
              item.lessonId!,
              item.score!,
            );
            await progressDao.markAsSynced(item.exerciseId);
          } catch (e) {
            debugPrint('ProgressRepo sync item error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('ProgressRepo sync outer error: $e');
    }
  }

  @override
  Future<List<Progress>> getRemoteProgress() async {
    final hasToken = await secureStorage.hasToken();
    if (!hasToken) return [];

    try {
      return await progressService.getProgress();
    } catch (e) {
      debugPrint('ProgressRepo getRemoteProgress error: $e');
      return [];
    }
  }

  @override
  Future<void> completeLesson(int lessonId, int score) async {
    await progressService.completeLesson(lessonId, score);
  }

  @override
  Future<int> getCompletedLessonCount() async {
    return progressDao.getCompletedCount();
  }
}
