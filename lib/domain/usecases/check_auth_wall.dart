import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/shared/providers/repository_providers.dart';
import '../repositories/i_progress_repository.dart';
import '../repositories/i_auth_repository.dart';

class CheckAuthWallUseCase {
  CheckAuthWallUseCase(this._progressRepo, this._authRepo);

  final IProgressRepository _progressRepo;
  final IAuthRepository _authRepo;

  Future<bool> shouldShowAuthWall() async {
    final isAuthenticated = await _authRepo.isAuthenticated();
    if (isAuthenticated) return false;

    final completedCount = await _progressRepo.getCompletedLessonCount();
    return completedCount >= AppConstants.authWallLessonLimit;
  }
}

final checkAuthWallUseCaseProvider = Provider<CheckAuthWallUseCase>((ref) {
  return CheckAuthWallUseCase(
    ref.read(progressRepositoryProvider),
    ref.read(authRepositoryProvider),
  );
});
