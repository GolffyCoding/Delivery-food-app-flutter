import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

/// Local data source for auth token & user caching.
class AuthLocalDatasource {
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  AuthLocalDatasource(this._secureStorage, this._localStorage);

  Future<void> saveTokens(AuthResult authResult) async {
    await _secureStorage.save(StorageConstants.accessTokenKey, authResult.accessToken);
    await _secureStorage.save(StorageConstants.refreshTokenKey, authResult.refreshToken);
    await _secureStorage.save(StorageConstants.userIdKey, authResult.user.id);
    await _secureStorage.save(StorageConstants.userRoleKey, authResult.user.role);
  }

  Future<String?> getAccessToken() => _secureStorage.get(StorageConstants.accessTokenKey);

  Future<String?> getRefreshToken() => _secureStorage.get(StorageConstants.refreshTokenKey);

  Future<String?> getUserId() => _secureStorage.get(StorageConstants.userIdKey);

  Future<void> saveUser(UserEntity user) async {
    await _localStorage.save('cached_user_${user.id}', user.toJson());
  }

  Future<UserEntity?> getCachedUser(String userId) async {
    final json = await _localStorage.get<Map<String, dynamic>>('cached_user_$userId');
    if (json == null) return null;
    return UserEntity.fromJson(json);
  }

  Future<void> clearAll() async {
    await _secureStorage.delete(StorageConstants.accessTokenKey);
    await _secureStorage.delete(StorageConstants.refreshTokenKey);
    await _secureStorage.delete(StorageConstants.userIdKey);
    await _secureStorage.delete(StorageConstants.userRoleKey);
  }
}
