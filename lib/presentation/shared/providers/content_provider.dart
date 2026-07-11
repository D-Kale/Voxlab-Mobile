import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/track.dart';
import '../../../domain/models/module.dart';
import '../../../domain/models/lesson.dart';
import '../../../domain/models/exercise.dart';
import '../../../data/repositories/content_repository_impl.dart';
import '../../../utils/exercise_name_utils.dart';

final tracksProvider = FutureProvider.autoDispose<List<Track>>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.getTracks();
});

final trackProvider = FutureProvider.autoDispose.family<Track, int>((ref, id) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.getTrack(id);
});

final moduleProvider = FutureProvider.autoDispose.family<Module, int>((ref, id) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.getModule(id);
});

final lessonProvider = FutureProvider.autoDispose.family<Lesson, int>((ref, id) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.getLesson(id);
});

final lessonExercisesProvider = FutureProvider.autoDispose.family<List<Exercise>, int>(
  (ref, lessonId) async {
    final repo = ref.read(contentRepositoryProvider);
    return repo.getLessonExercises(lessonId);
  },
);

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
