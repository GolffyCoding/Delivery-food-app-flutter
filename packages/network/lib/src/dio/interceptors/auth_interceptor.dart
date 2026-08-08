import 'package:dio/dio.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Interceptor that attaches JWT tokens to requests
/// and handles token refresh on 401 responses.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.get(StorageConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final token = await _secureStorage.get(StorageConstants.accessTokenKey);
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          AppLogger.error('Token refresh retry failed', error: e);
        }
      }
      await _secureStorage.delete(StorageConstants.accessTokenKey);
      await _secureStorage.delete(StorageConstants.refreshTokenKey);
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.get(StorageConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      // Envelope: {"success": true, "data": {"access_token","refresh_token","expires_at"}}
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null && data['access_token'] != null) {
        await _secureStorage.save(StorageConstants.accessTokenKey, data['access_token'] as String);
        if (data['refresh_token'] != null) {
          await _secureStorage.save(StorageConstants.refreshTokenKey, data['refresh_token'] as String);
        }
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Token refresh failed', error: e);
      return false;
    }
  }
}
