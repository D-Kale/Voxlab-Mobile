import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/track.dart';
import '../../domain/models/module.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/exercise.dart';
import '../../domain/repositories/i_content_repository.dart';
import '../remote/services/content_service.dart';

class ContentRepositoryImpl implements IContentRepository {
  ContentRepositoryImpl(this._service);

  final ContentService _service;

  @override
  Future<List<Track>> getTracks() => _service.getTracks();

  @override
  Future<Track> getTrack(int id) => _service.getTrack(id);

  @override
  Future<Module> getModule(int id) => _service.getModule(id);

  @override
  Future<Lesson> getLesson(int id) => _service.getLesson(id);

  @override
  Future<List<Exercise>> getLessonExercises(int lessonId) =>
      _service.getLessonExercises(lessonId);

  @override
  Future<Exercise> getExercise(String id) => _service.getExercise(id);
}

final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  return ContentRepositoryImpl(ref.read(contentServiceProvider));
});
