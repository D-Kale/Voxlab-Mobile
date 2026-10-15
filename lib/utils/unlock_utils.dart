import '../domain/models/track.dart';

/// Exercises the user may open: every completed exercise plus the next
/// incomplete one in path order (tracks, then modules, lessons and
/// exercises). Everything after it stays locked until the user gets there.
Set<String> unlockedExerciseIds(List<Track> tracks, Set<String> completed) {
  final unlocked = <String>{};
  var nextFound = false;
  for (final track in tracks) {
    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        for (final exercise in lesson.exercises) {
          if (completed.contains(exercise.id)) {
            unlocked.add(exercise.id);
          } else if (!nextFound) {
            unlocked.add(exercise.id);
            nextFound = true;
          }
        }
      }
    }
  }
  return unlocked;
}
