import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/core/storage/secure_storage.dart';
import 'package:voxlab/data/remote/services/progress_api_service.dart';
import 'package:voxlab/domain/repositories/i_auth_repository.dart';
import 'package:voxlab/domain/models/lesson_status.dart';
import 'package:voxlab/domain/models/progress.dart';
import 'package:voxlab/domain/models/user.dart';
import 'package:voxlab/presentation/features/analyze/analyze_screen.dart';
import 'package:voxlab/presentation/features/map/map_screen.dart';
import 'package:voxlab/presentation/features/practice/practice_screen.dart';
import 'package:voxlab/presentation/features/profile/profile_screen.dart';
import 'package:voxlab/presentation/shared/providers/auth_provider.dart';
import 'package:voxlab/presentation/shared/providers/content_provider.dart';
import 'package:voxlab/presentation/shared/providers/progress_provider.dart';

import 'fixtures/map_fixtures.dart';
import 'golden/golden_fonts.dart';

class _FakeProgressNotifier extends ProgressNotifier {
  _FakeProgressNotifier(this._entries);

  final List<Progress> _entries;

  @override
  List<Progress> build() => _entries;
}

class _EmptyProgressNotifier extends ProgressNotifier {
  @override
  List<Progress> build() => const [];
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(Ref ref)
      : super(
          _FakeAuthRepository(),
          SecureStorage(),
          ref,
          _FakeProgressApi(),
        ) {
    state = AuthState(
      user: User(
        id: 'u1',
        name: 'Alex',
        email: 'alex@test.com',
        role: 'user',
        xp: 255,
        streakDays: 3,
      ),
      status: AuthStatus.authenticated,
    );
  }
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<User> login(String email, String password) => throw UnimplementedError();

  @override
  Future<User> register(String name, String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<User> getCurrentUser() => throw UnimplementedError();

  @override
  Future<User> updateProfile({String? name, String? avatarUrl}) =>
      throw UnimplementedError();

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  String? getToken() => null;
}

class _FakeProgressApi extends ProgressApiService {
  @override
  Future<UserProgress> getProgress() async => throw UnimplementedError();

  @override
  Future<ProgressSubmitData> submitProgress(ProgressSubmitRequest request) =>
      throw UnimplementedError();

  @override
  Future<ProgressSubmitData> syncProgress(
    List<ProgressSubmitRequest> entries,
  ) => throw UnimplementedError();
}

List<Progress> _sampleProgress() => [
      Progress(
        exerciseId: 'e1',
        status: LessonStatus.completed,
        score: 92,
        completedAt: DateTime(2026, 3, 14, 10, 30),
      ),
      Progress(
        exerciseId: 'e2',
        status: LessonStatus.completed,
        score: 78,
        completedAt: DateTime(2026, 3, 15, 18, 5),
      ),
      Progress(
        exerciseId: 'e5',
        status: LessonStatus.completed,
        score: 85,
        completedAt: DateTime(2026, 3, 16, 9, 15),
      ),
    ];

void main() {
  setUpAll(loadGoldenFonts);

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    List<Override> overrides = const [],
    Size size = const Size(390, 844),
    bool withRouter = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final content = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: screen,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tracksProvider.overrideWith((_) async => [buildDemoTrack()]),
          progressNotifierProvider
              .overrideWith(() => _FakeProgressNotifier(_sampleProgress())),
          authProvider.overrideWith((ref) => _FakeAuthNotifier(ref)),
          ...overrides,
        ],
        child: withRouter
            ? MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                routerConfig: GoRouter(
                  routes: [GoRoute(path: '/', builder: (_, __) => screen)],
                ),
              )
            : content,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Practice tab', () {
    testWidgets('every type renders a human label, never the raw type',
        (tester) async {
      await pump(tester, const PracticeScreen());

      // The fixture contains both 'oratory' and 'oratory_minigame'.
      expect(find.text('Ejercicio'), findsNothing);
      expect(find.text('oratory'), findsNothing);
      expect(find.text('oratory_minigame'), findsNothing);
    });

    testWidgets('renders header, filter chips and every exercise',
        (tester) async {
      await pump(tester, const PracticeScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Practicar Libre'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('7 ejercicios disponibles'), findsOneWidget);
      expect(find.text('Lectura en voz alta'), findsOneWidget);
    });

    testWidgets('filtering by type narrows the list', (tester) async {
      await pump(tester, const PracticeScreen());

      // The type name also appears inside every exercise tile chip, so the
      // tap must be scoped to the filter row.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('practice-type-filters')),
          matching: find.text('Quiz'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('2 ejercicios disponibles'), findsOneWidget);
      expect(find.text('Lectura en voz alta'), findsNothing);
      expect(find.text('Pronunciación'), findsWidgets);
    });

    testWidgets('one chip per kind even when the backend varies the type',
        (tester) async {
      await pump(tester, const PracticeScreen());

      // The fixture has both 'oratory' and 'oratory_minigame'.
      expect(
        find.descendant(
          of: find.byKey(const Key('practice-type-filters')),
          matching: find.text('Oratoria'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no overflow on a narrow screen', (tester) async {
      await pump(tester, const PracticeScreen(), size: const Size(320, 700));
      expect(tester.takeException(), isNull);
    });
  });

  group('Analyze tab', () {
    testWidgets('renders progress, weekly chart and history', (tester) async {
      await pump(tester, const AnalyzeScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Tu Progreso'), findsOneWidget);
      expect(find.text('Actividad semanal'), findsOneWidget);
      expect(find.text('Historial reciente'), findsOneWidget);
    });

    testWidgets('shows empty state without progress', (tester) async {
      await pump(
        tester,
        const AnalyzeScreen(),
        overrides: [
          progressNotifierProvider
              .overrideWith(_EmptyProgressNotifier.new),
        ],
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Tu Progreso'), findsNothing);
    });

    testWidgets('no overflow on a narrow screen', (tester) async {
      await pump(tester, const AnalyzeScreen(), size: const Size(320, 700));
      expect(tester.takeException(), isNull);
    });
  });

  group('Profile tab', () {
    testWidgets('renders header, xp, stats and completed list', (tester) async {
      await pump(tester, const ProfileScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Experiencia'), findsOneWidget);
    });

    testWidgets('no overflow on a narrow screen', (tester) async {
      await pump(tester, const ProfileScreen(), size: const Size(320, 700));
      expect(tester.takeException(), isNull);
    });
  });

  group('Map tab', () {
    testWidgets('renders the whole path with no exceptions', (tester) async {
      await pump(tester, const MapScreen(), withRouter: true);

      expect(tester.takeException(), isNull);
      expect(find.text('UNIDAD 1'), findsOneWidget);
    });

    testWidgets('no overflow on a narrow screen', (tester) async {
      await pump(
        tester,
        const MapScreen(),
        size: const Size(320, 700),
        withRouter: true,
      );
      expect(tester.takeException(), isNull);
    });
  });
}