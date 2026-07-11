import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/models/progress.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

final totalXpStateProvider = StateProvider<int>((ref) => 0);

final completedExerciseIdsProvider =
    StateProvider<Set<String>>((ref) => {});

final loadXpFromStorageProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(secureStorageProvider);
  final xp = await storage.getTotalXp();
  if (xp != null && xp > 0) {
    ref.read(totalXpStateProvider.notifier).state = xp;
  }
  final ids = await storage.getCompletedExerciseIds();
  if (ids.isNotEmpty) {
    ref.read(completedExerciseIdsProvider.notifier).state = ids;
  }
});

final completedExerciseCountProvider = Provider<int>((ref) {
  final completedIds = ref.watch(completedExerciseIdsProvider);
  return completedIds.length;
});

final progressFetchProvider = FutureProvider<List<Progress>>((ref) async {
  final auth = ref.watch(authProvider);
  final repo = ref.read(progressRepositoryProvider);

  if (auth.isLoading) return [];
  if (auth.isAuthenticated) {
    return await repo.getRemoteProgress();
  } else {
    return await repo.getLocalProgress();
  }
});

class ProgressNotifier extends Notifier<List<Progress>> {
  @override
  List<Progress> build() {
    final progressAsync = ref.watch(progressFetchProvider);
    return progressAsync.when(
      data: (list) {
        _updateCompanionProviders(list);
        return list;
      },
      loading: () => [],
      error: (_, _) => [],
    );
  }

  void _updateCompanionProviders(List<Progress> list) {
    if (list.isNotEmpty) {
      final total = list.fold(0, (int sum, p) => sum + (p.score ?? 0));
      ref.read(totalXpStateProvider.notifier).state = total;
      final completedIds = list
          .expand((p) => p.completedExercises.map((e) => e.exerciseId))
          .toSet();
      ref.read(completedExerciseIdsProvider.notifier).state = completedIds;
    }
  }

  void addProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
  }) {
    state = [
      ...state,
      Progress(
        exerciseId: exerciseId,
        lessonId: lessonId,
        status: status,
        score: score,
        completedAt: status == LessonStatus.completed ? DateTime.now() : null,
      ),
    ];
  }

  Future<void> reload() async {
    ref.invalidate(progressFetchProvider);
    await ref.read(progressFetchProvider.future);
  }

  void replaceFromServer(List<Progress> serverProgress) {
    _updateCompanionProviders(serverProgress);
  }

  Future<void> saveProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    String? exerciseType,
  }) async {
    await ref.read(progressRepositoryProvider).saveLocalProgress(
      exerciseId: exerciseId,
      lessonId: lessonId,
      status: status,
      score: score,
      exerciseType: exerciseType,
    );
  }
}

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, List<Progress>>(ProgressNotifier.new);
