import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../models/module.dart';
import '../models/lesson.dart';
import '../models/exercise.dart';

abstract class IContentRepository {
  Future<List<Track>> getTracks();
  Future<Track> getTrack(int id);
  Future<Module> getModule(int id);
  Future<Lesson> getLesson(int id);
  Future<List<Exercise>> getLessonExercises(int lessonId);
  Future<Exercise> getExercise(String id);
}

final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  throw UnimplementedError('Must override contentRepositoryProvider');
});
