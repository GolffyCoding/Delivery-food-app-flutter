import 'package:dio/dio.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Interceptor that converts DioExceptions to NetworkExceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final networkException = NetworkException.fromDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: networkException,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
