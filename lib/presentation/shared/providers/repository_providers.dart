import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/remote/services/auth_service.dart';
import '../../../domain/repositories/i_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.read(authServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});
