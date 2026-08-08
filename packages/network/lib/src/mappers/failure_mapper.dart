import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Maps [NetworkException] to domain [Failure].
Failure mapNetworkExceptionToFailure(NetworkException exception) {
  return switch (exception.type) {
    NetworkExceptionType.unauthorized => AuthFailure(message: exception.message),
    NetworkExceptionType.noConnection => NetworkFailure(message: exception.message),
    NetworkExceptionType.timeout => NetworkFailure(message: exception.message),
    NetworkExceptionType.serverError => ServerFailure(message: exception.message, statusCode: exception.statusCode),
    NetworkExceptionType.validation => ServerFailure(message: exception.message, statusCode: exception.statusCode),
    NetworkExceptionType.conflict => ConflictFailure(message: exception.message),
    _ => UnknownFailure(message: exception.message),
  };
}
