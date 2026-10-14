import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/router/auth_guard.dart';
import 'package:voxlab/core/router/routes.dart';
import 'package:voxlab/domain/models/user.dart';
import 'package:voxlab/presentation/shared/providers/auth_provider.dart';

void main() {
  const user = User(
    id: 'u1',
    name: 'Alex',
    email: 'alex@test.com',
    role: 'user',
    xp: 0,
    streakDays: 0,
  );

  test('unchecked session goes through the splash, not the auth wall', () {
    expect(
      AuthGuard.check(AppRoutes.practice, const AuthState()),
      AppRoutes.splash,
    );
  });

  test('signed-out user lands on the auth wall', () {
    expect(
      AuthGuard.check(
        AppRoutes.map,
        const AuthState(status: AuthStatus.unauthenticated),
      ),
      AppRoutes.authWall,
    );
  });

  test('signed-in user keeps the requested route', () {
    expect(
      AuthGuard.check(
        AppRoutes.profile,
        const AuthState(status: AuthStatus.authenticated, user: user),
      ),
      isNull,
    );
  });

  test('auth routes and the splash are always reachable', () {
    for (final route in [
      AppRoutes.splash,
      AppRoutes.authWall,
      AppRoutes.login,
      AppRoutes.register,
    ]) {
      expect(AuthGuard.check(route, const AuthState()), isNull);
    }
  });
}
