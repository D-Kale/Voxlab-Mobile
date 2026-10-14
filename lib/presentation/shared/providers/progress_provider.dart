import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/local_progress_store.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/models/progress.dart';
import '../../../utils/unlock_utils.dart';
import '../providers/auth_provider.dart';
import 'content_provider.dart';

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

/// Exercises the user may open (see [unlockedExerciseIds]); null while the
/// content is still loading.
final unlockedExerciseIdsProvider = Provider<Set<String>?>((ref) {
  final tracks = ref.watch(tracksProvider).valueOrNull;
  if (tracks == null) return null;
  return unlockedExerciseIds(tracks, ref.watch(completedExerciseIdsProvider));
});

/// Local-only progression, scoped to the signed-in user.
///
/// Rebuilds whenever the authenticated user changes and loads that user's
/// entries from [LocalProgressStore]. There is no server-side progress.
class ProgressNotifier extends Notifier<List<Progress>> {
  String? _userId;

  LocalProgressStore get _store => ref.read(localProgressStoreProvider);

  @override
  List<Progress> build() {
    _userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (_userId != null) Future.microtask(reload);
    return const <Progress>[];
  }

  Future<void> reload() async {
    final userId = _userId;
    if (userId == null) {
      state = const <Progress>[];
      return;
    }
    final entries = await _store.load(userId);
    // Ignore a load that finished after the user changed.
    if (_userId == userId) state = entries;
  }

  Future<void> saveProgress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
  }) async {
    if (state.any((p) => p.exerciseId == exerciseId)) return;

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
    await _persist();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _store.save(userId, state);
    } catch (e) {
      debugPrint('LocalProgressStore persist error: $e');
    }
  }
}

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, List<Progress>>(ProgressNotifier.new);
