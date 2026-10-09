import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/local/local_progress_store.dart';
import '../../../data/remote/services/progress_api_service.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/models/progress.dart';
import '../../../domain/models/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'repository_providers.dart';
import 'progress_provider.dart';

enum AuthStatus { initial, guest, authenticated }

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

  bool get isGuest => status == AuthStatus.guest || status == AuthStatus.initial;
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
  AuthNotifier(this._repository, this._storage, this._ref, this._progressApi) : super(const AuthState());

  final IAuthRepository _repository;
  final SecureStorage _storage;
  final Ref _ref;
  final ProgressApiService _progressApi;

  Future<void> _loadProgressFromServer(String userId) async {
    try {
      final progress = await _progressApi.getProgress();
      final entries = progress.completedExerciseIds.map((exerciseId) => Progress(
        exerciseId: exerciseId,
        status: LessonStatus.completed,
        score: 100,
        completedAt: DateTime.now(),
      )).toList();
      await _ref.read(localProgressStoreProvider).save(userId, entries);
      _ref.read(progressNotifierProvider.notifier).setUserId(userId);
      await _ref.read(progressNotifierProvider.notifier).reload();
    } catch (e) {
      debugPrint('Failed to load progress from server: $e');
      _ref.read(progressNotifierProvider.notifier).setUserId(userId);
    }
  }

  Future<void> checkAuth() async {
    try {
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        state = state.copyWith(status: AuthStatus.guest);
        _ref.read(progressNotifierProvider.notifier).setUserId(null);
        return;
      }

      final user = await _repository.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _loadProgressFromServer(user.id);
    } catch (e) {
      debugPrint('AuthNotifier checkAuth error: $e');
      await _storage.clearToken().catchError((_) {});
      state = state.copyWith(status: AuthStatus.guest);
      _ref.read(progressNotifierProvider.notifier).setUserId(null);
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(error: null, isBusy: true);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      await _loadProgressFromServer(user.id);
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
      await _loadProgressFromServer(user.id);
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
    state = const AuthState(status: AuthStatus.guest);
    _ref.read(progressNotifierProvider.notifier).setUserId(null);
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
      _ref.read(progressNotifierProvider.notifier).setUserId(user.id);
    } catch (e) {
      debugPrint('AuthNotifier refreshUser error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  final progressApi = ref.read(progressApiServiceProvider);
  return AuthNotifier(repo, storage, ref, progressApi);
});