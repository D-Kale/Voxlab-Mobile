import '../../presentation/shared/providers/auth_provider.dart';
import '../constants/app_constants.dart';
import 'routes.dart';

class AuthGuard {
  static String? check(
    String location,
    AuthState authState,
    int completedCount,
  ) {
    final isGuest = authState.isGuest;

    if (isGuest && completedCount >= AppConstants.authWallLessonLimit) {
      if (location != AppRoutes.authWall &&
          location != AppRoutes.login &&
          location != AppRoutes.register) {
        return AppRoutes.authWall;
      }
    }

    if (!isGuest && location == AppRoutes.splash) {
      return AppRoutes.map;
    }

    return null;
  }
}
