import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    return _parseAuthResponse(response.data as Map<String, dynamic>);
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
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  ({String token, User user}) _parseAuthResponse(Map<String, dynamic> data) {
    final Map<String, dynamic> body;
    if (data['token'] is String && data['user'] is Map) {
      body = data;
    } else if (data['success'] == true && data['data'] is Map) {
      body = data['data'] as Map<String, dynamic>;
    } else {
      debugPrint('Unexpected auth envelope: $data');
      throw ServerException('No pudimos procesar la respuesta del servidor.');
    }

    final token = body['token'];
    final userJson = body['user'];
    if (token is! String || userJson is! Map<String, dynamic>) {
      debugPrint('Incomplete auth payload: $data');
      throw ServerException('No pudimos procesar la respuesta del servidor.');
    }
    return (token: token, user: _mapUser(userJson));
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
