import 'package:equatable/equatable.dart';

/// Base failure class representing failures mapped from exceptions to the domain layer.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure resulting from server errors or bad HTTP responses.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Failure resulting from local storage read/write failures.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// Failure resulting from lack of internet connection or timeouts.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

/// Failure when API key is missing or unauthorized.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// General unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.statusCode});
}
