import 'package:dio/dio.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Centralized Dio HTTP client with all interceptors configured.
class DioClient {
  late final Dio _dio;

  DioClient({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required RetryInterceptor retryInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      retryInterceptor,
      authInterceptor,
      loggingInterceptor,
      errorInterceptor,
    ]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? decoder,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return ApiResponse<T>.fromResponse(response, decoder ?? _identity);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    T Function(dynamic json)? decoder,
    String? idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withIdempotency(options, idempotencyKey),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
    return ApiResponse<T>.fromResponse(response, decoder ?? _identity);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? decoder,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return ApiResponse<T>.fromResponse(response, decoder ?? _identity);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? decoder,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return ApiResponse<T>.fromResponse(response, decoder ?? _identity);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? decoder,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return ApiResponse<T>.fromResponse(response, decoder ?? _identity);
  }

  Options _withIdempotency(Options? options, String? idempotencyKey) {
    if (idempotencyKey == null) return options ?? Options();
    final merged = options ?? Options();
    return merged.copyWith(headers: {
      ...?merged.headers,
      ApiConstants.idempotencyKeyHeader: idempotencyKey,
    });
  }

  T? _identity<T>(dynamic json) => json as T?;
}
