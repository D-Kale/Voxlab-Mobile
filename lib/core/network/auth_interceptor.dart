import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/shared/providers/auth_provider.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.ref});

  /// Set to true in [RequestOptions.extra] for optional calls (AI analysis)
  /// whose 401 must not sign the user out in the middle of an exercise:
  /// the caller falls back to on-device analysis instead, and the next
  /// regular request still detects an expired session.
  static const skipLogoutOn401 = 'skipLogoutOn401';

  final Ref ref;
  bool _handling401 = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final optional = err.requestOptions.extra[skipLogoutOn401] == true;
    if (err.response?.statusCode == 401 && !optional && !_handling401) {
      _handling401 = true;
      try {
        final storage = ref.read(secureStorageProvider);
        await storage.clearToken();
        await ref.read(authProvider.notifier).logout();
        debugPrint('AuthInterceptor: 401 detected, logged out');
      } finally {
        _handling401 = false;
      }
    }

    handler.next(err);
  }
}
