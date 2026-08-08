import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

/// Implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  UserEntity? _cachedUser;

  AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  /// Parses the `{"user": {...}, "token_pair": {"access_token","refresh_token","expires_at"}}`
  /// shape returned by /auth/login and /auth/register.
  Future<AuthResult> _handleAuthJson(Map<String, dynamic> json) async {
    final user = UserEntity.fromJson(json['user'] as Map<String, dynamic>);
    final tokenPair = json['token_pair'] as Map<String, dynamic>? ?? json;
    _cachedUser = user;

    final authResult = AuthResult(
      user: user,
      accessToken: tokenPair['access_token'] as String,
      refreshToken: tokenPair['refresh_token'] as String,
    );

    await _localDatasource.saveTokens(authResult);
    await _localDatasource.saveUser(user);
    return authResult;
  }

  @override
  Future<Result<AuthResult, Failure>> login({required String email, required String password}) async {
    try {
      final json = await _remoteDatasource.login(email: email, password: password);
      return Result.success(await _handleAuthJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      AppLogger.error('Login error', error: e);
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthResult, Failure>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  }) async {
    try {
      // POST /auth/register only returns the created `user`, no tokens — the
      // client must log in right after to get a token_pair.
      await _remoteDatasource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      final loginJson = await _remoteDatasource.login(email: email, password: password);
      return Result.success(await _handleAuthJson(loginJson));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      AppLogger.error('Register error', error: e);
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _remoteDatasource.logout();
    } catch (_) {
      // Still clear local session even if the server call fails.
    }
    await _localDatasource.clearAll();
    _cachedUser = null;
    return const Result.success(null);
  }

  @override
  Future<Result<UserEntity, Failure>> getCurrentUser() async {
    try {
      final userId = await _localDatasource.getUserId();
      if (userId == null) {
        return Result.failure(const AuthFailure(message: 'Not authenticated'));
      }

      _cachedUser ??= await _localDatasource.getCachedUser(userId);
      if (_cachedUser != null) {
        return Result.success(_cachedUser!);
      }

      final json = await _remoteDatasource.getProfile();
      final user = UserEntity.fromJson(json);
      _cachedUser = user;
      await _localDatasource.saveUser(user);
      return Result.success(user);
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthResult, Failure>> refreshToken() async {
    try {
      final token = await _localDatasource.getRefreshToken();
      if (token == null) {
        return Result.failure(const AuthFailure(message: 'No refresh token'));
      }
      final json = await _remoteDatasource.refreshToken(token);
      return Result.success(await _handleAuthJson(json));
    } on NetworkException catch (e) {
      return Result.failure(mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  bool get isAuthenticated => _cachedUser != null;

  @override
  UserEntity? get currentUser => _cachedUser;
}
