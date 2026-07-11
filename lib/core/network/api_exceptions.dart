sealed class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Token de autenticación inválido');
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Recurso no encontrado'])
    : super(message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Error interno del servidor'])
    : super(message);
}

class ConflictException extends ApiException {
  ConflictException([String message = 'El recurso ya existe'])
    : super(message);
}
