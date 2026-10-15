import 'package:flutter/foundation.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../remote/services/auth_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required this.authService,
    required this.secureStorage,
  });

  final AuthService authService;
  final SecureStorage secureStorage;

  User? _cachedUser;

  @override
  Future<User> login(String email, String password) async {
    final result = await authService.login(email, password);
    await secureStorage.saveToken(result.token);
    _cachedUser = result.user;
    return result.user;
  }

  @override
  Future<User> register(String name, String email, String password) async {
    final result = await authService.register(name, email, password);
    await secureStorage.saveToken(result.token);
    _cachedUser = result.user;
    return result.user;
  }

  @override
  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      debugPrint('AuthRepo logout error: $e');
    }
    await secureStorage.clearToken();
    _cachedUser = null;
  }

  @override
  Future<void> deleteAccount() async {
    // Unlike logout, a failure here must reach the user: the account would
    // still exist.
    await authService.deleteAccount();
    await secureStorage.clearToken();
    _cachedUser = null;
  }

  @override
  Future<User> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser!;
    final user = await authService.getMe();
    _cachedUser = user;
    return user;
  }

  @override
  Future<User> updateProfile({String? name, String? avatarUrl}) async {
    final user = await authService.updateProfile(name: name, avatarUrl: avatarUrl);
    _cachedUser = user;
    return user;
  }

  @override
  Future<bool> isAuthenticated() async {
    return secureStorage.hasToken();
  }

  @override
  String? getToken() => null;
}
