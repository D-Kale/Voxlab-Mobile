import '../../domain/models/progress.dart';
import '../../domain/models/lesson_status.dart';

abstract class IProgressRepository {
  Future<void> saveLocalProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    String? exerciseType,
  });

  Future<List<Progress>> getLocalProgress();
  Future<List<Progress>> getUnsyncedProgress();
  Future<Progress?> getProgress(String exerciseId);
  Future<void> syncProgress();
  Future<List<Progress>> getRemoteProgress();
  Future<void> completeLesson(int lessonId, int score);
  Future<int> getCompletedLessonCount();
}
