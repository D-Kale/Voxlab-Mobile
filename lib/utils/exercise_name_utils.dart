import '../domain/models/track.dart';

Map<String, String> buildExerciseNameMap(List<Track> tracks) {
  final map = <String, String>{};
  for (final track in tracks) {
    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        for (final exercise in lesson.exercises) {
          map[exercise.id] = exercise.name.isNotEmpty
              ? exercise.name
              : formatExerciseType(exercise.type);
        }
      }
    }
  }
  return map;
}

String formatExerciseType(String type) {
  return switch (type) {
    'reading' => 'Lectura',
    'quiz' => 'Quiz',
    'oratory_minigame' => 'Oratoria',
    'writing' => 'Escritura',
    'audio' => 'Audio',
    'video' => 'Video',
    _ => 'Ejercicio',
  };
}

String resolveExerciseName(
  String exerciseId,
  String exerciseType,
  Map<String, String> nameMap,
) {
  return nameMap[exerciseId] ?? formatExerciseType(exerciseType);
}
