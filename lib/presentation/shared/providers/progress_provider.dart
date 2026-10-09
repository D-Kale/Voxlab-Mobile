import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/local_progress_store.dart';
import '../../../data/remote/services/progress_api_service.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/models/progress.dart';
import '../providers/auth_provider.dart';

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
  String? _currentUserId;
  final List<ProgressSubmitRequest> _pendingSync = [];

  LocalProgressStore get _store => ref.read(localProgressStoreProvider);
  ProgressApiService get _api => ref.read(progressApiServiceProvider);

  @override
  List<Progress> build() {
    final entriesAsync = ref.watch(_entriesProvider);
    return entriesAsync.valueOrNull ?? const <Progress>[];
  }

  void setUserId(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    reload();
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
    if (_currentUserId == null) {
      state = const <Progress>[];
      return;
    }
    final entries = await _store.load(_currentUserId!);
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

    if (status == LessonStatus.completed) {
      Future.microtask(() => _submitToServer(exerciseId, score, lessonId));
    }
  }

  Future<void> _submitToServer(
    String exerciseId,
    int? score,
    int? lessonId,
  ) async {
    if (_currentUserId == null) return;

    final request = ProgressSubmitRequest(
      exerciseId: exerciseId,
      score: score ?? 0,
      completedAt: DateTime.now().toUtc().toIso8601String(),
      lessonId: lessonId,
    );

    try {
      final response = await _api.submitProgress(request);
      _mergeServerState(response);
    } catch (e) {
      debugPrint('Server sync failed, queuing for retry: $e');
      _queueForRetry(request);
    }
  }

  void _mergeServerState(ProgressSubmitData server) {
    final serverCompleted = server.newlyCompleted.toSet();
    final updatedEntries = state.map((p) {
      if (serverCompleted.contains(p.exerciseId)) {
        return p.copyWith(
          status: LessonStatus.completed,
          score: p.score ?? 100,
          completedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    state = updatedEntries;
    _persist();
  }

  void _queueForRetry(ProgressSubmitRequest request) {
    _pendingSync.add(request);
  }

  Future<void> flushPendingSync() async {
    if (_pendingSync.isEmpty || _currentUserId == null) return;
    final toSync = List<ProgressSubmitRequest>.from(_pendingSync);
    _pendingSync.clear();
    for (final req in toSync) {
      try {
        await _api.submitProgress(req);
      } catch (e) {
        debugPrint('Retry sync failed: $e');
        _pendingSync.add(req);
      }
    }
  }

  Future<void> loadFromServer() async {
    if (_currentUserId == null) return;
    try {
      final progress = await _api.getProgress();
      final serverCompleted = progress.completedExerciseIds.toSet();
      final updatedEntries = state.map((p) {
        if (serverCompleted.contains(p.exerciseId)) {
          return p.copyWith(
            status: LessonStatus.completed,
            score: p.score ?? 100,
            completedAt: DateTime.now(),
          );
        }
        return p;
      }).toList();
      state = updatedEntries;
      await _persist();
    } catch (e) {
      debugPrint('Failed to load progress from server: $e');
    }
  }

  bool _containsExercise(String exerciseId) {
    return state.any((p) => p.exerciseId == exerciseId);
  }

  Future<void> _persist() async {
    if (_currentUserId == null) return;
    try {
      await _store.save(_currentUserId!, state);
    } catch (e) {
      debugPrint('LocalProgressStore persist error: $e');
    }
  }
}

final _entriesProvider = FutureProvider<List<Progress>>((ref) async {
  final notifier = ref.read(progressNotifierProvider.notifier);
  final userId = ref.watch(authProvider.select((s) => s.user?.id));
  notifier.setUserId(userId);
  return ref.watch(localProgressStoreProvider).load(userId ?? '');
});

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, List<Progress>>(ProgressNotifier.new);