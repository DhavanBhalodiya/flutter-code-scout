/// Base exception for application-level data errors.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

/// Exception thrown when remote server returns an error or non-200 status.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
  });
}

/// Exception thrown when local cache / storage operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.statusCode,
  });
}

/// Exception thrown when there is no internet connection or network timeout occurs.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
  });
}

/// Exception thrown when JSON parsing or data mapping fails.
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.statusCode,
  });
}
