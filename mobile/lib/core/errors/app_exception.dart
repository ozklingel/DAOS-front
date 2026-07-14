sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Please check your connection.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please sign in again.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong. Please try again.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local storage error.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class AuthFailureException extends AppException {
  const AuthFailureException([super.message = 'Authentication failed.']);
}
