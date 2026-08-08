import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum NetworkExceptionType {
  timeout,
  noConnection,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  tooManyRequests,
  serverError,
  sslError,
  cancelled,
  unknown,
}

/// Typed network exception with user-friendly messages.
class NetworkException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final NetworkExceptionType type;

  /// The backend's machine-readable `error.code` (e.g. "ORDER_NOT_FOUND"),
  /// when present. Prefer switching on this over parsing [message].
  final String? code;

  const NetworkException({
    required this.message,
    this.statusCode,
    required this.type,
    this.code,
  });

  factory NetworkException.fromDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
          type: NetworkExceptionType.timeout,
        );
      case DioExceptionType.badResponse:
        return _fromStatusCode(err.response?.statusCode, err.response?.data);
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          type: NetworkExceptionType.cancelled,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
          type: NetworkExceptionType.noConnection,
        );
      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'SSL certificate error.',
          type: NetworkExceptionType.sslError,
        );
      case DioExceptionType.unknown:
      default:
        return const NetworkException(
          message: 'An unexpected error occurred. Please try again.',
          type: NetworkExceptionType.unknown,
        );
    }
  }

  static NetworkException _fromStatusCode(int? statusCode, dynamic data) {
    // Envelope shape: {"success": false, "error": {"code": "...", "message": "..."}}
    final error = (data is Map<String, dynamic>) ? data['error'] as Map<String, dynamic>? : null;
    final message = error?['message'] as String?;
    final code = error?['code'] as String?;
    switch (statusCode) {
      case 400:
        return NetworkException(message: message ?? 'Invalid request.', statusCode: statusCode, type: NetworkExceptionType.badRequest, code: code);
      case 401:
        return NetworkException(message: message ?? 'Session expired. Please login again.', statusCode: statusCode, type: NetworkExceptionType.unauthorized, code: code);
      case 403:
        return NetworkException(message: message ?? 'Access denied.', statusCode: statusCode, type: NetworkExceptionType.forbidden, code: code);
      case 404:
        return NetworkException(message: message ?? 'Resource not found.', statusCode: statusCode, type: NetworkExceptionType.notFound, code: code);
      case 409:
        return NetworkException(message: message ?? 'Conflict occurred.', statusCode: statusCode, type: NetworkExceptionType.conflict, code: code);
      case 422:
        return NetworkException(message: message ?? 'Validation error.', statusCode: statusCode, type: NetworkExceptionType.validation, code: code);
      case 429:
        return NetworkException(message: 'Too many requests. Please wait.', statusCode: statusCode, type: NetworkExceptionType.tooManyRequests, code: code);
      case 500:
        return NetworkException(message: message ?? 'Server error. Please try again later.', statusCode: statusCode, type: NetworkExceptionType.serverError, code: code);
      default:
        return NetworkException(message: message ?? 'Something went wrong.', statusCode: statusCode, type: NetworkExceptionType.unknown, code: code);
    }
  }

  @override
  List<Object?> get props => [message, statusCode, type, code];
}
