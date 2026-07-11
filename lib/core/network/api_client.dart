import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref: ref),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ),
  ]);

  return dio;
});

ApiException mapDioException(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      NetworkException('Tiempo de espera agotado'),
    DioExceptionType.connectionError =>
      NetworkException('Sin conexión a internet'),
    DioExceptionType.badResponse => _mapStatusCodeError(e),
    _ => NetworkException('Error inesperado: ${e.message}'),
  };
}

ApiException _mapStatusCodeError(DioException e) {
  final statusCode = e.response?.statusCode;
  final message =
      (e.response?.data is Map ? (e.response?.data as Map)['error'] : null)
          as String?;

  return switch (statusCode) {
    400 => ServerException(message ?? 'Solicitud inválida'),
    401 => UnauthorizedException(),
    404 => NotFoundException(message ?? 'Recurso no encontrado'),
    409 => ConflictException(message ?? 'El recurso ya existe'),
    502 || 503 => ServerException('Servicio temporalmente no disponible'),
    _ => ServerException(message ?? 'Error interno del servidor'),
  };
}
