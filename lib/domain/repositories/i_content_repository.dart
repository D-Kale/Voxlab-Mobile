import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../models/exercise.dart';

abstract class IContentRepository {
  Future<List<Track>> getTracks();
  Future<Exercise> getExercise(String id);
}

final contentRepositoryProvider = Provider<IContentRepository>((ref) {
  throw UnimplementedError('Must override contentRepositoryProvider');
});
