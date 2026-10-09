import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/track.dart';
import '../../../domain/models/exercise.dart';
import '../../../data/repositories/content_repository_impl.dart';
import '../../../utils/exercise_name_utils.dart';

final tracksProvider = FutureProvider.autoDispose<List<Track>>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.getTracks();
});

final exerciseProvider = FutureProvider.autoDispose.family<Exercise, String>(
  (ref, id) async {
    final repo = ref.read(contentRepositoryProvider);
    return repo.getExercise(id);
  },
);

final exerciseNameMapProvider = Provider<Map<String, String>>((ref) {
  final tracksAsync = ref.watch(tracksProvider);
  return tracksAsync.when(
    data: (tracks) => buildExerciseNameMap(tracks),
    loading: () => const {},
    error: (_, __) => const {},
  );
});

final totalExercisesProvider = Provider<int>((ref) {
  final tracksAsync = ref.watch(tracksProvider);
  return tracksAsync.when(
    data: (tracks) => tracks.fold(0, (sum, t) =>
      sum + t.modules.fold(0, (mSum, m) =>
        mSum + m.lessons.fold(0, (lSum, l) =>
          lSum + l.exercises.length))),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
