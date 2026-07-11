import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/shared/providers/auth_provider.dart';
import '../../presentation/shared/providers/progress_provider.dart';
import '../constants/app_constants.dart';
import 'routes.dart';

class AuthGuard {
  const AuthGuard({required this.ref});

  final Ref ref;

  String? call(String location) {
    final authState = ref.read(authProvider);
    final completedCount = ref.read(completedExerciseCountProvider);

    final isGuest = authState.isGuest;

    if (isGuest && completedCount >= AppConstants.authWallLessonLimit) {
      if (location != AppRoutes.authWall &&
          location != AppRoutes.login &&
          location != AppRoutes.register) {
        return AppRoutes.authWall;
      }
    }

    if (!isGuest && location == AppRoutes.splash) {
      return AppRoutes.home;
    }

    return null;
  }
}
