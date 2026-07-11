import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/models/user.dart';

class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<({String token, User user})> login(
    String email,
    String password,
  ) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    return (token: data['token'] as String, user: _mapUser(data['user']));
  }

  Future<({String token, User user})> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    return (token: data['token'] as String, user: _mapUser(data['user']));
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<User> getMe() async {
    final response = await _dio.get('/auth/me');
    final data = response.data['data'] as Map<String, dynamic>;
    return _mapUser(data);
  }

  Future<User> updateProfile({String? name, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    final response = await _dio.put('/auth/profile', data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    return _mapUser(data);
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      xp: json['xp'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});
