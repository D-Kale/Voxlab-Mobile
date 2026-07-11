import 'package:flutter/foundation.dart';
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
  final progress = ref.watch(progressNotifierProvider);
  return progress.where((p) => p.status.isCompleted).length;
});

class ProgressNotifier extends Notifier<List<Progress>> {
  @override
  List<Progress> build() {
    ref.watch(authProvider);
    _loadForAuth();
    return [];
  }

  void _loadForAuth() {
    final auth = ref.read(authProvider);
    if (auth.isLoading) return;
    if (auth.isAuthenticated) {
      _loadFromServer();
    } else {
      _loadFromDb();
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

  Future<void> _loadFromDb() async {
    try {
      final repo = ref.read(progressRepositoryProvider);
      final list = await repo.getLocalProgress();
      _updateFromList(list);
    } catch (e) {
      debugPrint('ProgressNotifier._loadFromDb: $e');
    }
  }

  Future<void> _loadFromServer() async {
    try {
      final repo = ref.read(progressRepositoryProvider);
      final list = await repo.getRemoteProgress();
      _updateFromList(list);
    } catch (e) {
      debugPrint('ProgressNotifier._loadFromServer: $e');
    }
  }

  Future<void> reload() async {
    final auth = ref.read(authProvider);
    try {
      final repo = ref.read(progressRepositoryProvider);
      final list = auth.isAuthenticated
          ? await repo.getRemoteProgress()
          : await repo.getLocalProgress();
      _updateFromList(list);
    } catch (e) {
      debugPrint('ProgressNotifier.reload: $e');
    }
  }

  void _updateFromList(List<Progress> list) {
    if (list.isNotEmpty) {
      state = list;
      final total = list.fold(0, (int sum, p) => sum + (p.score ?? 0));
      ref.read(totalXpStateProvider.notifier).state = total;
      final completedIds = list
          .where((p) => p.status == LessonStatus.completed)
          .map((p) => p.exerciseId)
          .toSet();
      ref.read(completedExerciseIdsProvider.notifier).state = completedIds;
    }
  }

  void replaceFromServer(List<Progress> serverProgress) {
    _updateFromList(serverProgress);
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
