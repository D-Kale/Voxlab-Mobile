import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_database.dart';
import '../database_provider.dart';
import 'package:voxlab/domain/models/lesson_status.dart';

class ProgressDao {
  ProgressDao(this.db);

  final AppDatabase db;

  Future<List<GuestProgress>> getAllGuestProgress() {
    return db.select(db.guestProgressTable).get();
  }

  Future<List<GuestProgress>> getUnsyncedProgress() {
    return (db.select(db.guestProgressTable)
          ..where((t) => t.isSynced.equals(false))
        ).get();
  }

  Future<void> upsertProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    String? exerciseType,
  }) async {
    await db.into(db.guestProgressTable).insertOnConflictUpdate(
      GuestProgressTableCompanion(
        exerciseId: Value(exerciseId),
        lessonId: Value(lessonId),
        score: Value(score),
        status: Value(status.name),
        exerciseType: Value(exerciseType),
        completedAt: Value(
          status == LessonStatus.completed ? DateTime.now() : null,
        ),
      ),
    );
  }

  Future<GuestProgress?> getProgress(String exerciseId) async {
    final rows = await (db.select(db.guestProgressTable)
          ..where((t) => t.exerciseId.equals(exerciseId))
        ).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> markAsSynced(String exerciseId) async {
    await (db.update(db.guestProgressTable)
          ..where((t) => t.exerciseId.equals(exerciseId)))
        .write(const GuestProgressTableCompanion(isSynced: Value(true)));
  }

  Future<void> markAllSynced() async {
    await (db.update(db.guestProgressTable))
        .write(const GuestProgressTableCompanion(isSynced: Value(true)));
  }

  Future<int> getCompletedCount() async {
    final rows = await (db.select(db.guestProgressTable)
          ..where((t) => t.status.equals('completed'))
        ).get();
    return rows.length;
  }

  Future<void> clearAll() async {
    await db.delete(db.guestProgressTable).go();
  }
}

final progressDaoProvider = Provider<ProgressDao>((ref) {
  final db = ref.read(databaseProvider);
  return ProgressDao(db);
});
