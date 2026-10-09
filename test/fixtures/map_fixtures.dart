import 'package:voxlab/domain/models/exercise.dart';
import 'package:voxlab/domain/models/exercise_content.dart';
import 'package:voxlab/domain/models/lesson.dart';
import 'package:voxlab/domain/models/module.dart';
import 'package:voxlab/domain/models/track.dart';

Exercise _exercise({
  required String id,
  required String type,
  required String name,
}) {
  // The parsed content must match `type`: screens derive behavior (filter
  // chips, XP reward) from the content, not from the raw string.
  final content = switch (type) {
    'reading' => ExerciseContent.reading(
        title: name,
        content: 'Texto de lectura de prueba.',
        readingTimeSeconds: 60,
        points: 10,
      ),
    'writing' => ExerciseContent.writing(
        prompt: 'Escribí tu presentación.',
        minWords: 50,
        maxWords: 200,
        requirements: const ['Claro', 'Breve'],
        points: 10,
      ),
    'oratory' || 'oratory_minigame' => ExerciseContent.oratory(
        prompt: 'Hablá durante un minuto.',
        topic: name,
        durationSeconds: 60,
        minDurationSeconds: 30,
        requirements: const ['Volumen'],
        points: 10,
      ),
    _ => ExerciseContent.quiz(
        questions: const [],
        pointsPerQuestion: 10,
      ),
  };

  return Exercise(id: id, type: type, name: name, content: content);
}

Lesson _lesson({required int id, required List<Exercise> exercises}) {
  return Lesson(
    id: id,
    title: 'Lección $id',
    description: '',
    exercises: exercises,
  );
}

Module _module({
  required int id,
  required String title,
  required List<Lesson> lessons,
}) {
  return Module(
    id: id,
    trackId: 1,
    title: title,
    description: '',
    orderIndex: id,
    lessons: lessons,
  );
}

/// Demo track: 2 units, 7 exercises covering every exercise type.
Track buildDemoTrack() {
  return Track(
    id: 1,
    title: 'Voz y presencia',
    description: 'Habla en público con seguridad.',
    iconUrl: '🎙️',
    isActive: true,
    modules: [
      _module(
        id: 1,
        title: 'Primeros pasos',
        lessons: [
          _lesson(id: 1, exercises: [
            _exercise(
              id: 'e1',
              type: 'reading',
              name: 'Lectura en voz alta',
            ),
            _exercise(
              id: 'e2',
              type: 'quiz',
              name: 'Pronunciación',
            ),
            _exercise(
              id: 'e3',
              type: 'writing',
              name: 'Escribe tu intro',
            ),
            _exercise(
              id: 'e4',
              type: 'oratory',
              name: 'Presentación breve',
            ),
          ]),
        ],
      ),
      _module(
        id: 2,
        title: 'Voz en público',
        lessons: [
          _lesson(id: 2, exercises: [
            _exercise(id: 'e5', type: 'quiz', name: 'Ritmo y pausas'),
            _exercise(
              id: 'e6',
              type: 'reading',
              name: 'Lectura exprés',
            ),
            _exercise(
              id: 'e7',
              type: 'oratory_minigame',
              name: 'Discurso de 1 minuto',
            ),
          ]),
        ],
      ),
    ],
  );
}

Set<String> allExerciseIds(Track track) {
  final ids = <String>{};
  for (final module in track.modules) {
    for (final lesson in module.lessons) {
      for (final exercise in lesson.exercises) {
        ids.add(exercise.id);
      }
    }
  }
  return ids;
}
