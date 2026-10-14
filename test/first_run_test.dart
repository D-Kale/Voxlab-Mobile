import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:voxlab/core/constants/app_colors.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/core/router/routes.dart';
import 'package:voxlab/core/storage/secure_storage.dart';
import 'package:voxlab/data/local/onboarding_store.dart';
import 'package:voxlab/data/repositories/content_repository_impl.dart';
import 'package:voxlab/domain/models/exercise.dart';
import 'package:voxlab/domain/models/lesson_status.dart';
import 'package:voxlab/domain/models/progress.dart';
import 'package:voxlab/domain/models/track.dart';
import 'package:voxlab/domain/repositories/i_content_repository.dart';
import 'package:voxlab/presentation/features/auth/register_screen.dart';
import 'package:voxlab/presentation/features/exercise/exercise_player_screen.dart';
import 'package:voxlab/presentation/features/map/widgets/map_path_model.dart';
import 'package:voxlab/presentation/features/map/widgets/track_path.dart';
import 'package:voxlab/presentation/features/onboarding/onboarding_screen.dart';
import 'package:voxlab/presentation/features/onboarding/welcome_screen.dart';
import 'package:voxlab/presentation/features/splash/splash_screen.dart';
import 'package:voxlab/presentation/features/tour/app_tour.dart';
import 'package:voxlab/presentation/shared/providers/content_provider.dart';
import 'package:voxlab/presentation/shared/providers/progress_provider.dart';
import 'package:voxlab/utils/unlock_utils.dart';

import 'fixtures/map_fixtures.dart';
import 'golden/golden_fonts.dart';

/// Keychain stand-in: flags and token live in memory.
class _MemoryStorage extends SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> getToken() async => null;

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async =>
      values[key] = value;
}

class _FakeProgressNotifier extends ProgressNotifier {
  _FakeProgressNotifier(this._done);

  final Set<String> _done;

  @override
  List<Progress> build() => [
    for (final id in _done)
      Progress(exerciseId: id, status: LessonStatus.completed, score: 10),
  ];
}

class _FixtureContent implements IContentRepository {
  @override
  Future<List<Track>> getTracks() async => [buildDemoTrack()];

  @override
  Future<Exercise> getExercise(String id) async => buildDemoTrack().modules
      .expand((m) => m.lessons)
      .expand((l) => l.exercises)
      .firstWhere((e) => e.id == id);
}

Placeholder _stub(String label) => Placeholder(child: Text(label));

void main() {
  setUpAll(loadGoldenFonts);

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    useReducedMotion(tester);
  }

  group('unlock rule', () {
    test('completed exercises plus the next one are unlocked', () {
      final track = buildDemoTrack();
      expect(unlockedExerciseIds([track], {}), {'e1'});
      expect(unlockedExerciseIds([track], {'e1', 'e2'}), {'e1', 'e2', 'e3'});
      // Out-of-order history stays reviewable; only one new exercise opens.
      expect(unlockedExerciseIds([track], {'e5'}), {'e1', 'e5'});
    });
  });

  group('first launch', () {
    Future<_MemoryStorage> pumpSplash(
      WidgetTester tester, {
      required bool onboardingSeen,
    }) async {
      phone(tester);
      final storage = _MemoryStorage();
      if (onboardingSeen) storage.values['voxlab_onboarding_seen'] = 'true';
      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
              routes: [
                GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
                GoRoute(
                  path: AppRoutes.welcome,
                  builder: (_, _) => _stub('WELCOME'),
                ),
                GoRoute(
                  path: AppRoutes.authWall,
                  builder: (_, _) => _stub('AUTH_WALL'),
                ),
              ],
            ),
          ),
        ),
      );
      // Splash waits at least 1.5 s before routing.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      return storage;
    }

    testWidgets('fresh install opens the welcome screen', (tester) async {
      await pumpSplash(tester, onboardingSeen: false);
      expect(find.text('WELCOME'), findsOneWidget);
    });

    testWidgets('returning signed-out user sees the auth wall', (
      tester,
    ) async {
      await pumpSplash(tester, onboardingSeen: true);
      expect(find.text('AUTH_WALL'), findsOneWidget);
    });

    testWidgets('onboarding questions end on the register screen', (
      tester,
    ) async {
      phone(tester);
      final storage = _MemoryStorage();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
              initialLocation: AppRoutes.welcome,
              routes: [
                GoRoute(
                  path: AppRoutes.welcome,
                  builder: (_, _) => const WelcomeScreen(),
                ),
                GoRoute(
                  path: AppRoutes.onboarding,
                  builder: (_, _) => const OnboardingScreen(),
                ),
                GoRoute(
                  path: AppRoutes.register,
                  builder: (_, _) => const RegisterScreen(),
                ),
                GoRoute(
                  path: AppRoutes.login,
                  builder: (_, _) => _stub('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¡Hola! Soy Voxi.'), findsOneWidget);
      await tester.tap(find.text('EMPEZAR'));
      await tester.pumpAndSettle();

      // Continue stays disabled until an answer is picked.
      expect(find.text('¿Para qué querés mejorar tu oratoria?'), findsOneWidget);
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();
      expect(find.text('¿Para qué querés mejorar tu oratoria?'), findsOneWidget);

      await tester.tap(find.text('Ganar confianza'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cómo te sentís al hablar en público?'), findsOneWidget);
      await tester.tap(find.text('Me pongo muy nervioso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Serio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.text('Meta diaria: 30 XP'), findsOneWidget);
      expect(find.text('Enfoque: Ganar confianza'), findsOneWidget);
      await tester.tap(find.text('CREAR MI PERFIL'));
      await tester.pumpAndSettle();

      expect(find.text('¡Último paso!'), findsOneWidget);
      expect(storage.values['voxlab_onboarding_seen'], 'true');
      final profile = await OnboardingStore(storage).loadProfile();
      expect(profile?.dailyGoalXp, 30);
      expect(profile?.motivation, 'confidence');
      expect(profile?.level, 'nervous');
    });

    testWidgets('"Ya tengo una cuenta" skips the questions', (tester) async {
      phone(tester);
      final storage = _MemoryStorage();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: GoRouter(
              initialLocation: AppRoutes.welcome,
              routes: [
                GoRoute(
                  path: AppRoutes.welcome,
                  builder: (_, _) => const WelcomeScreen(),
                ),
                GoRoute(
                  path: AppRoutes.login,
                  builder: (_, _) => _stub('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('YA TENGO UNA CUENTA'));
      await tester.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
      expect(storage.values['voxlab_onboarding_seen'], 'true');
    });
  });

  group('app tour', () {
    testWidgets('walks through every step and can be skipped', (
      tester,
    ) async {
      phone(tester);
      final first = GlobalKey();
      final second = GlobalKey();
      var finished = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  SizedBox(key: first, height: 80, width: 200),
                  const Spacer(),
                  SizedBox(key: second, height: 80, width: 200),
                  TextButton(
                    onPressed: () async {
                      await showAppTour(context, [
                        const TourStep(title: 'Hola', body: 'Intro'),
                        TourStep(target: first, title: 'Uno', body: 'A'),
                        TourStep(target: second, title: 'Dos', body: 'B'),
                      ]);
                      finished = true;
                    },
                    child: const Text('START'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      expect(find.text('Hola'), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pumpAndSettle();
      expect(find.text('Uno'), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pumpAndSettle();
      expect(find.text('Dos'), findsOneWidget);
      expect(find.text('SALTAR'), findsNothing);

      await tester.tap(find.text('¡VAMOS!'));
      await tester.pumpAndSettle();
      expect(find.text('Dos'), findsNothing);
      expect(finished, isTrue);

      // Second run, skipped from the first step.
      finished = false;
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SALTAR'));
      await tester.pumpAndSettle();
      expect(find.text('Hola'), findsNothing);
      expect(finished, isTrue);
    });
  });

  group('locked lessons', () {
    testWidgets('a locked map node shows why and cannot start', (
      tester,
    ) async {
      phone(tester);
      var started = 0;
      final model = MapPathModel.build([buildDemoTrack()], const {'e1'});
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: buildMapSlivers(
                model: model,
                onStart: (_) => started++,
                onGuide: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.lock_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('BLOQUEADO'), findsOneWidget);
      expect(
        find.text('Completá los ejercicios anteriores para desbloquearlo.'),
        findsOneWidget,
      );
      await tester.tap(find.text('BLOQUEADO'));
      await tester.pumpAndSettle();
      expect(started, 0);
    });

    Future<void> pumpPlayer(
      WidgetTester tester,
      String exerciseId,
      Set<String> done,
    ) async {
      phone(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contentRepositoryProvider.overrideWithValue(_FixtureContent()),
            tracksProvider.overrideWith((_) async => [buildDemoTrack()]),
            progressNotifierProvider.overrideWith(
              () => _FakeProgressNotifier(done),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ExercisePlayerScreen(exerciseId: exerciseId),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opening a locked exercise directly is blocked', (
      tester,
    ) async {
      await pumpPlayer(tester, 'e4', {'e1'});
      expect(find.text('Ejercicio bloqueado'), findsOneWidget);
      expect(find.text('VOLVER AL MAPA'), findsOneWidget);
    });

    testWidgets('the next exercise opens normally', (tester) async {
      await pumpPlayer(tester, 'e3', {'e1', 'e2'});
      expect(find.text('Ejercicio bloqueado'), findsNothing);
      expect(find.text('Escribí tu presentación.'), findsOneWidget);
    });
  });
}
