import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voxlab/core/constants/app_colors.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/domain/models/lesson_status.dart';
import 'package:voxlab/domain/models/progress.dart';
import 'package:voxlab/domain/models/user.dart';
import 'package:voxlab/presentation/features/analyze/analyze_screen.dart';
import 'package:voxlab/presentation/features/analyze/providers/weekly_progress_provider.dart';
import 'package:voxlab/presentation/features/practice/practice_screen.dart';
import 'package:voxlab/presentation/features/profile/profile_screen.dart';
import 'package:voxlab/presentation/features/splash/splash_screen.dart';
import 'package:voxlab/presentation/shared/providers/auth_provider.dart';
import 'package:voxlab/presentation/shared/providers/content_provider.dart';
import 'package:voxlab/presentation/shared/providers/progress_provider.dart';
import 'package:voxlab/core/storage/secure_storage.dart';
import 'package:voxlab/domain/repositories/i_auth_repository.dart';

import '../fixtures/map_fixtures.dart';
import 'golden_fonts.dart';

class _FakeProgressNotifier extends ProgressNotifier {
  @override
  List<Progress> build() => [
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
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(Ref ref)
      : super(_FakeRepo(), SecureStorage()) {
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

class _FakeRepo implements IAuthRepository {
  @override
  Future<User> login(String email, String password) => throw UnimplementedError();

  @override
  Future<User> register(String name, String email, String password) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}

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

void main() {
  setUpAll(loadGoldenFonts);

// Pays the first-use cost of the heaviest DM Sans weight and of the Voxi
  // asset decode, outside the goldens (see golden_fonts.dart).
  testWidgets('warm up text pipeline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/voxi_awake.png',
                  width: 48,
                  height: 48,
                ),
                Image.asset(
                  'assets/images/voxi_sleeping.png',
                  width: 48,
                  height: 48,
                ),
                Text(
                  'Practicar Libre',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await settleImages(tester);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    useReducedMotion(tester);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tracksProvider.overrideWith((_) async => [buildDemoTrack()]),
          progressNotifierProvider.overrideWith(_FakeProgressNotifier.new),
          // A fixed Tuesday keeps the weekly chart golden stable.
          clockProvider.overrideWithValue(() => DateTime(2026, 3, 17, 12)),
          authProvider.overrideWith((ref) => _FakeAuthNotifier(ref)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: screen,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('practice golden', (tester) async {
    await pump(tester, const PracticeScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tab_practice.png'),
    );
  });

  testWidgets('analyze golden', (tester) async {
    await pump(tester, const AnalyzeScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tab_analyze.png'),
    );
  });

  testWidgets('profile golden', (tester) async {
    await pump(tester, const ProfileScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tab_profile.png'),
    );
  });

  testWidgets('splash golden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    useReducedMotion(tester);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier(ref)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tab_splash.png'),
    );
  });
}