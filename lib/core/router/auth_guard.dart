import '../../presentation/shared/providers/auth_provider.dart';
import 'routes.dart';

class AuthGuard {
  AuthGuard._();

  /// Authentication is mandatory: every route except the auth flow itself
  /// requires an authenticated user. Unauthenticated navigations land on
  /// the auth wall.
  static String? check(String location, AuthState authState) {
    final isAuthRoute = location == AppRoutes.authWall ||
        location == AppRoutes.welcome ||
        location == AppRoutes.onboarding ||
        location == AppRoutes.login ||
        location == AppRoutes.register;
    if (isAuthRoute || location == AppRoutes.splash) return null;

    // The stored session has not been checked yet (deep link or web
    // reload): let the splash restore it instead of showing the auth wall
    // to a signed-in user.
    if (authState.status == AuthStatus.initial) return AppRoutes.splash;
    if (!authState.isAuthenticated) return AppRoutes.authWall;
    return null;
  }
}
