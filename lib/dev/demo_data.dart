import 'package:dio/dio.dart';

import '../core/network/api_exceptions.dart';
import '../core/storage/secure_storage.dart';
import '../data/local/local_progress_store.dart';
import '../data/remote/services/analyzer_service.dart';
import '../domain/models/exercise.dart';
import '../domain/models/exercise_content.dart';
import '../domain/models/lesson.dart';
import '../domain/models/lesson_status.dart';
import '../domain/models/module.dart';
import '../domain/models/progress.dart';
import '../domain/models/track.dart';
import '../domain/models/user.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_content_repository.dart';

/// Offline data for `lib/main_demo.dart`: lets designers and developers walk
/// through every screen without a backend account. Never imported by the
/// production entrypoint.
const demoUser = User(
  id: 'demo',
  name: 'Alex',
  email: 'alex@voxlab.demo',
  role: 'user',
  xp: 0,
  streakDays: 4,
);

Exercise _reading(String id, String name) => Exercise(
  id: id,
  type: 'reading',
  name: name,
  content: ExerciseContent.reading(
    title: name,
    content:
        'Hablar en público es una habilidad que se entrena. '
        'Respirá profundo, mirá a tu audiencia y empezá con una idea '
        'clara. Las pausas no son silencios incómodos: le dan tiempo a '
        'la audiencia para entender lo que acabás de decir.',
    readingTimeSeconds: 45,
    points: 10,
  ),
);

Exercise _quiz(String id, String name) => Exercise(
  id: id,
  type: 'quiz',
  name: name,
  content: const ExerciseContent.quiz(
    pointsPerQuestion: 5,
    questions: [
      QuizQuestion(
        question: '¿Qué conviene hacer antes de empezar a hablar?',
        options: [
          'Respirar profundo',
          'Hablar lo más rápido posible',
          'Mirar el piso',
        ],
        correctIndex: 0,
        explanation: 'Respirar calma los nervios y estabiliza la voz.',
      ),
      QuizQuestion(
        question: '¿Para qué sirven las pausas?',
        options: [
          'Para rellenar el tiempo',
          'Para que la audiencia procese la idea',
          'No sirven, hay que evitarlas',
        ],
        correctIndex: 1,
        explanation: 'Una pausa breve marca las ideas importantes.',
      ),
    ],
  ),
);

Exercise _writing(String id, String name) => Exercise(
  id: id,
  type: 'writing',
  name: name,
  content: const ExerciseContent.writing(
    prompt: 'Escribí cómo te presentarías ante un grupo nuevo.',
    minWords: 20,
    maxWords: 120,
    requirements: ['Tu nombre', 'A qué te dedicás', 'Un dato curioso'],
    points: 15,
  ),
);

Exercise _oratory(String id, String name) => Exercise(
  id: id,
  type: 'oratory_minigame',
  name: name,
  content: ExerciseContent.oratory(
    prompt: 'Hablá sobre el tema sin detenerte.',
    topic: name,
    durationSeconds: 60,
    minDurationSeconds: 20,
    requirements: const ['Volumen claro', 'Sin muletillas'],
    points: 20,
  ),
);

Module _module(
  int id,
  String title,
  List<Exercise> exercises, {
  int trackId = 1,
}) => Module(
  id: id,
  trackId: trackId,
  title: title,
  description: '',
  orderIndex: id,
  lessons: [
    Lesson(id: id, title: title, description: '', exercises: exercises),
  ],
);

final demoTracks = <Track>[
  Track(
    id: 1,
    title: 'Voz y presencia',
    description: 'Hablá en público con seguridad.',
    isActive: true,
    modules: [
      _module(1, 'Primeros pasos', [
        _reading('d1', 'Lectura en voz alta'),
        _quiz('d2', 'Respiración'),
        _writing('d3', 'Escribí tu intro'),
        _oratory('d4', 'Presentación breve'),
      ]),
      _module(2, 'Voz en público', [
        _quiz('d5', 'Ritmo y pausas'),
        _reading('d6', 'Lectura exprés'),
        _writing('d7', 'Tu historia'),
        _oratory('d8', 'Discurso de 1 minuto'),
      ]),
      _module(3, 'Lenguaje corporal', [
        _reading('d9', 'Postura segura'),
        _quiz('d10', 'Contacto visual'),
        _oratory('d11', 'Gestos con intención'),
      ]),
    ],
  ),
  // Two more levels so the demo shows the level gates and landscapes.
  Track(
    id: 2,
    title: 'Persuadí con tu mensaje',
    description: 'Estructurá ideas que convencen.',
    isActive: true,
    modules: [
      _module(4, 'Abrí con impacto', trackId: 2, [
        _reading('d12', 'Los primeros 30 segundos'),
        _quiz('d13', 'Aperturas que enganchan'),
        _oratory('d14', 'Tu mejor apertura'),
      ]),
      _module(5, 'La regla de tres', trackId: 2, [
        _reading('d15', 'Tres ideas, un mensaje'),
        _writing('d16', 'Tus tres pilares'),
        _oratory('d17', 'Discurso en tres partes'),
      ]),
    ],
  ),
  Track(
    id: 3,
    title: 'Dominá el escenario',
    description: 'Nervios, voz y presencia frente a un público.',
    isActive: true,
    modules: [
      _module(6, 'Nervios bajo control', trackId: 3, [
        _reading('d18', 'Respirar antes de hablar'),
        _quiz('d19', 'Qué hacer con los nervios'),
        _oratory('d20', 'Hablá con calma'),
      ]),
    ],
  ),
];

class DemoAuthRepository implements IAuthRepository {
  @override
  Future<User> login(String email, String password) async => demoUser;

  /// A new account starts from zero (the seeded progress belongs to
  /// [demoUser], who signs in with login).
  @override
  Future<User> register(String name, String email, String password) async =>
      demoUser.copyWith(
        id: 'demo-new',
        name: name,
        email: email,
        streakDays: 0,
      );

  @override
  Future<void> logout() async {}

  @override
  Future<User> getCurrentUser() async => demoUser;

  @override
  Future<User> updateProfile({String? name, String? avatarUrl}) async =>
      demoUser;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  String? getToken() => 'demo';
}

class DemoContentRepository implements IContentRepository {
  @override
  Future<List<Track>> getTracks() async => demoTracks;

  @override
  Future<Exercise> getExercise(String id) async {
    for (final module in demoTracks.expand((t) => t.modules)) {
      for (final lesson in module.lessons) {
        for (final exercise in lesson.exercises) {
          if (exercise.id == id) return exercise;
        }
      }
    }
    throw StateError('Unknown demo exercise $id');
  }
}

/// Starts the demo signed in (and with the onboarding and tour already
/// seen) when built with `--dart-define=DEMO_SIGNED_IN=true`; otherwise every
/// run is a first launch.
const demoStartsSignedIn = bool.fromEnvironment('DEMO_SIGNED_IN');

/// Offline fixture content instead of the server's
/// (`--dart-define=DEMO_FIXTURES=true`).
const demoUsesFixtures = bool.fromEnvironment('DEMO_FIXTURES');

/// In-memory storage: nothing touches the platform keychain, so every demo
/// run starts from the same state.
class DemoSecureStorage extends SecureStorage {
  DemoSecureStorage({bool signedIn = demoStartsSignedIn})
    : _token = signedIn ? 'demo' : null {
    if (signedIn) {
      _values['voxlab_onboarding_seen'] = 'true';
      _values['voxlab_tour_seen'] = 'true';
    }
  }

  String? _token;
  final Map<String, String> _values = {};

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;

  @override
  Future<String?> readString(String key) async => _values[key];

  @override
  Future<void> writeString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clearAll() async {
    _token = null;
    _values.clear();
  }
}

/// In-memory progress so every demo run starts from the same state: the
/// first three exercises done, so the map, stats and chart have something
/// to show and the oratory exercise (recording) is the next one.
class DemoProgressStore extends LocalProgressStore {
  /// [seeded] marks the first fixture exercises as done; with server
  /// content the ids differ, so the demo starts from zero.
  DemoProgressStore({bool seeded = true}) : super.test() {
    if (!seeded) _data.clear();
  }

  final Map<String, List<Progress>> _data = {
    demoUser.id: [
      Progress(
        exerciseId: 'd1',
        lessonId: 1,
        status: LessonStatus.completed,
        score: 10,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Progress(
        exerciseId: 'd2',
        lessonId: 1,
        status: LessonStatus.completed,
        score: 10,
        completedAt: DateTime.now(),
      ),
      Progress(
        exerciseId: 'd3',
        lessonId: 1,
        status: LessonStatus.completed,
        score: 15,
        completedAt: DateTime.now(),
      ),
    ],
  };

  @override
  Future<List<Progress>> load(String userId) async => _data[userId] ?? [];

  @override
  Future<void> save(String userId, List<Progress> entries) async =>
      _data[userId] = entries;

  @override
  Future<void> clear(String userId) async => _data.remove(userId);
}

/// The demo token is fake, so the real AI endpoints would answer 401. Fail
/// fast instead and let the exercises use their on-device analysis. Test
/// the AI with the production entrypoint and a real account.
class DemoAnalyzerService extends AnalyzerService {
  DemoAnalyzerService() : super(Dio());

  @override
  Future<Map<String, dynamic>> analyzeText({
    required String text,
    required List<String> requirements,
    required int minWords,
    required int maxWords,
  }) => Future.error(NetworkException('IA no disponible en modo demo'));

  @override
  Future<Map<String, dynamic>> analyzeSpeech({
    required String path,
    required String fileName,
    int? minSeconds,
    int? targetSeconds,
    String? topic,
  }) => Future.error(NetworkException('IA no disponible en modo demo'));
}
