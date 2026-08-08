import 'package:dio/dio.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Interceptor that retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = ApiConstants.maxRetries,
    this.initialDelay = ApiConstants.retryDelay,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['_retryCount'] as int? ?? 0;
    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      final delay = initialDelay * (1 << retryCount);
      await Future<void>.delayed(delay);

      err.requestOptions.extra['_retryCount'] = retryCount + 1;
      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    return statusCode != null && statusCode >= 500 && statusCode != 501 && statusCode != 505;
  }
}
