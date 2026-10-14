import '../models/track.dart';
import '../models/exercise.dart';

abstract class IContentRepository {
  Future<List<Track>> getTracks();
  Future<Exercise> getExercise(String id);
}
