import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/core/storage/secure_storage.dart';
import 'package:voxlab/domain/repositories/i_auth_repository.dart';
import 'package:voxlab/domain/models/lesson_status.dart';
import 'package:voxlab/domain/models/progress.dart';
import 'package:voxlab/domain/models/user.dart';
import 'package:voxlab/presentation/features/analyze/analyze_screen.dart';
import 'package:voxlab/presentation/features/map/map_screen.dart';
import 'package:voxlab/presentation/features/games/game_catalog.dart';
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
    useReducedMotion(tester);
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
    testWidgets('renders the daily challenge and every minigame',
        (tester) async {
      await pump(tester, const PracticeScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Reto del día'), findsOneWidget);
      for (final game in GameId.values) {
        await tester.scrollUntilVisible(
          find.text(game.title),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(game.title), findsOneWidget);
      }
    });

    testWidgets('groups games by skill', (tester) async {
      await pump(tester, const PracticeScreen());

      expect(find.text(GameSkill.start.label), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(GameSkill.improv.label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(GameSkill.improv.label), findsOneWidget);
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
      await tester.scrollUntilVisible(
        find.text('Ejercicios completados'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Ejercicios completados'), findsOneWidget);
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