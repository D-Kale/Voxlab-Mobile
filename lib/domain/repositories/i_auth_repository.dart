import '../models/user.dart';

abstract class IAuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout();
  Future<User> getCurrentUser();
  Future<User> updateProfile({String? name, String? avatarUrl});
  Future<bool> isAuthenticated();
  String? getToken();
}
