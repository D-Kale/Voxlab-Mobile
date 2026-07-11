import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/shared/providers/repository_providers.dart';
import '../models/progress.dart';
import '../models/lesson_status.dart';
import '../repositories/i_progress_repository.dart';

class CompleteLessonUseCase {
  CompleteLessonUseCase(this._repository);

  final IProgressRepository _repository;

  Future<Progress> call({
    required int lessonId,
    required int score,
    required bool isAuthenticated,
  }) async {
    if (isAuthenticated) {
      await _repository.completeLesson(lessonId, score);
      final progressList = await _repository.getLocalProgress();
      return progressList.firstWhere((p) => p.exerciseId == lessonId.toString());
    }

    await _repository.saveLocalProgress(
      exerciseId: lessonId.toString(),
      lessonId: lessonId,
      status: LessonStatus.completed,
      score: score,
    );

    final progressList = await _repository.getLocalProgress();
    return progressList.firstWhere((p) => p.exerciseId == lessonId.toString());
  }
}

final completeLessonUseCaseProvider = Provider<CompleteLessonUseCase>((ref) {
  final repo = ref.read(progressRepositoryProvider);
  return CompleteLessonUseCase(repo);
});
