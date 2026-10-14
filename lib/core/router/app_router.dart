import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/auth/auth_wall_screen.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/auth/register_screen.dart';
import '../../presentation/features/analyze/analyze_screen.dart';
import '../../presentation/features/profile/profile_screen.dart';
import '../../presentation/features/map/map_screen.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';
import '../../presentation/features/onboarding/welcome_screen.dart';
import '../../presentation/features/practice/practice_screen.dart';
import '../../presentation/features/splash/splash_screen.dart';
import '../../presentation/features/exercise/exercise_player_screen.dart';
import '../../presentation/features/exercise/exercise_complete_screen.dart';
import '../../presentation/shared/providers/auth_provider.dart';
import 'app_shell.dart';
import 'auth_guard.dart';
import 'routes.dart';

GoRoute _slideRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: builder(context, state),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      return AuthGuard.check(state.matchedLocation, authState);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.map,
            builder: (_, _) => const MapScreen(),
          ),
          GoRoute(
            path: AppRoutes.practice,
            builder: (_, _) => const PracticeScreen(),
          ),
          GoRoute(
            path: AppRoutes.analyze,
            builder: (_, _) => const AnalyzeScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      _slideRoute(
        path: AppRoutes.exerciseComplete,
        builder: (_, _) => const ExerciseCompleteScreen(),
      ),
      _slideRoute(
        path: AppRoutes.exercise,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra is Map ? state.extra as Map : null;
          final lessonId = extra?['lessonId'] as int?;
          return ExercisePlayerScreen(
            exerciseId: id,
            lessonId: lessonId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      _slideRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      _slideRoute(
        path: AppRoutes.authWall,
        builder: (_, _) => const AuthWallScreen(),
      ),
      _slideRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      _slideRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
    ],
  );
});
