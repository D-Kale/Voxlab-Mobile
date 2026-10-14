import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/models/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'repository_providers.dart';

enum AuthStatus { initial, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isBusy = false,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isBusy;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => isBusy;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isBusy,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

String _friendlyError(Object e) {
  if (e is! DioException && e is! ApiException) {
    debugPrint('Auth unexpected error: ${e.runtimeType}: $e');
  }
  return friendlyErrorMessage(e);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._storage) : super(const AuthState());

  final IAuthRepository _repository;
  final SecureStorage _storage;

  Future<void> checkAuth() async {
    try {
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final user = await _repository.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      debugPrint('AuthNotifier checkAuth error: $e');
      await _storage.clearToken().catchError((_) {});
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(error: null, isBusy: true);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      final msg = _friendlyError(e);
      debugPrint('AuthNotifier login error: $msg');
      state = state.copyWith(error: msg, isBusy: false);
      return msg;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    state = state.copyWith(error: null, isBusy: true);
    try {
      final user = await _repository.register(name, email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      final msg = _friendlyError(e);
      debugPrint('AuthNotifier register error: $msg');
      state = state.copyWith(error: msg, isBusy: false);
      return msg;
    }
  }

  Future<void> logout() async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true);
    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('AuthNotifier logout error: $e');
    }
    await _storage.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void showError(Object error) {
    state = state.copyWith(error: friendlyErrorMessage(error), isBusy: false);
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