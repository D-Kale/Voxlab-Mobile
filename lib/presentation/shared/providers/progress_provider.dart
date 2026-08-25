import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/local_progress_store.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/models/progress.dart';

final totalXpStateProvider = Provider<int>((ref) {
  final entries = ref.watch(progressNotifierProvider);
  return entries.fold(0, (int sum, p) => sum + (p.score ?? 0));
});

final completedExerciseIdsProvider = Provider<Set<String>>((ref) {
  final entries = ref.watch(progressNotifierProvider);
  return entries.map((p) => p.exerciseId).toSet();
});

final completedExerciseCountProvider = Provider<int>((ref) {
  final completedIds = ref.watch(completedExerciseIdsProvider);
  return completedIds.length;
});

class ProgressNotifier extends Notifier<List<Progress>> {
  LocalProgressStore get _store => ref.read(localProgressStoreProvider);

  @override
  List<Progress> build() {
    final entriesAsync = ref.watch(_entriesProvider);
    return entriesAsync.valueOrNull ?? const <Progress>[];
  }

  void addProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
  }) {
    if (_containsExercise(exerciseId)) return;

    final entry = Progress(
      exerciseId: exerciseId,
      lessonId: lessonId,
      status: status,
      score: score,
      completedAt: status == LessonStatus.completed ? DateTime.now() : null,
    );

    state = [...state, entry];
    _persist();
  }

  Future<void> reload() async {
    final entries = await _store.load();
    state = entries;
  }

  Future<void> saveProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    String? exerciseType,
  }) async {
    addProgress(
      exerciseId: exerciseId,
      lessonId: lessonId,
      status: status,
      score: score,
    );
  }

  bool _containsExercise(String exerciseId) {
    return state.any((p) => p.exerciseId == exerciseId);
  }

  Future<void> _persist() async {
    try {
      await _store.save(state);
    } catch (e) {
      debugPrint('LocalProgressStore persist error: $e');
    }
  }
}

final _entriesProvider = FutureProvider<List<Progress>>((ref) async {
  return ref.watch(localProgressStoreProvider).load();
});

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, List<Progress>>(ProgressNotifier.new);
