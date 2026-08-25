import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/models/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'repository_providers.dart';

enum AuthStatus { initial, guest, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final User? user;
  final String? error;

  bool get isGuest => status == AuthStatus.guest || status == AuthStatus.initial;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.initial;

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._storage) : super(const AuthState());

  final IAuthRepository _repository;
  final SecureStorage _storage;

  Future<void> checkAuth() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.guest);
      return;
    }

    try {
      final user = await _repository.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _storage.clearToken();
      state = state.copyWith(status: AuthStatus.guest);
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(error: null);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      final msg = e.toString();
      debugPrint('AuthNotifier login error: $msg');
      state = state.copyWith(error: msg);
      return msg;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    state = state.copyWith(error: null);
    try {
      final user = await _repository.register(name, email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      final msg = e.toString();
      debugPrint('AuthNotifier register error: $msg');
      state = state.copyWith(error: msg);
      return msg;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.guest);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      debugPrint('AuthNotifier refreshUser error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthNotifier(repo, storage);
});
