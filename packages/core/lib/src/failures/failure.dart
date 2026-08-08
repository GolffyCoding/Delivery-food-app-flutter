import 'package:equatable/equatable.dart';

/// Base failure class representing domain-level errors.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure({required String message, this.statusCode}) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}

class LocalFailure extends Failure {
  const LocalFailure({required String message}) : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required String message, this.statusCode}) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message);
}

/// The backend rejected the request because server-side state has already
/// moved on (HTTP 409) — e.g. a merchant tries to update an order a driver
/// has already picked up, or accepts an order another driver already took.
/// Callers should refresh from the server rather than retry the same write.
class ConflictFailure extends Failure {
  const ConflictFailure({required String message}) : super(message);
}
