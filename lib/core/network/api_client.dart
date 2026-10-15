import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';

export 'api_exceptions.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref: ref),
    if (kDebugMode)
      LogInterceptor(
        // Headers carry the session token: keep them out of the logs.
        requestHeader: false,
        requestBody: false,
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
    DioExceptionType.sendTimeout => NetworkException(
      'Tiempo de espera agotado. Revisá tu conexión.',
    ),
    DioExceptionType.connectionError => NetworkException(
      'Sin conexión a internet.',
    ),
    DioExceptionType.badResponse => _mapStatusCodeError(e),
    _ => NetworkException('Ocurrió un error inesperado.'),
  };
}

ApiException _mapStatusCodeError(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = data is Map && data['error'] is String
      ? data['error'] as String
      : null;
  debugPrint('API error $statusCode: $message');

  return switch (statusCode) {
    400 => ServerException(message ?? 'Solicitud inválida'),
    401 => UnauthorizedException(),
    404 => NotFoundException('Recurso no encontrado'),
    409 => ConflictException(
      message == 'email already registered'
          ? 'Ese email ya está registrado. Probá iniciar sesión.'
          : 'Este recurso ya existe.',
    ),
    422 => ServerException('Revisá los datos ingresados'),
    502 || 503 => ServerException('Servicio temporalmente no disponible'),
    _ => ServerException('Error interno del servidor'),
  };
}

String friendlyErrorMessage(Object error) {
  if (error is String) return error;
  if (error is ApiException) return error.message;
  if (error is DioException) return mapDioException(error).message;
  if (error is FormatException) {
    return 'No pudimos procesar la respuesta del servidor. Intentá de nuevo.';
  }
  return 'Ocurrió un error inesperado.';
}
