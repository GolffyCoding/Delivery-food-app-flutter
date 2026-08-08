import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';

/// Remote data source for `/auth` endpoints.
class AuthRemoteDatasource {
  final DioClient _dioClient;

  AuthRemoteDatasource(this._dioClient);

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return _requireData(response.data, 'Login failed');
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null) 'phone': phone,
        'role': role,
      },
    );
    return _requireData(response.data, 'Registration failed');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return _requireData(response.data, 'Token refresh failed');
  }

  Future<void> logout() async {
    await _dioClient.post(ApiConstants.logout);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.get<Map<String, dynamic>>(ApiConstants.me);
    return _requireData(response.data, 'Failed to fetch profile');
  }

  Map<String, dynamic> _requireData(Map<String, dynamic>? data, String message) {
    if (data == null) {
      throw NetworkException(message: message, type: NetworkExceptionType.unknown);
    }
    return data;
  }
}
