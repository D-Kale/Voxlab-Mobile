import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/drift/daos/progress_dao.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/progress_repository_impl.dart';
import '../../../data/remote/services/auth_service.dart';
import '../../../data/remote/services/progress_service.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_progress_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.read(authServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

final progressRepositoryProvider = Provider<IProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    progressDao: ref.read(progressDaoProvider),
    progressService: ref.read(progressServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});
