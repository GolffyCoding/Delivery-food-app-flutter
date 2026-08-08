import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

/// Authentication repository interface, matching the OpenDelivery backend's
/// `/auth` endpoints.
abstract class AuthRepository {
  Future<Result<AuthResult, Failure>> login({required String email, required String password});

  Future<Result<AuthResult, Failure>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  });

  Future<Result<void, Failure>> logout();

  Future<Result<UserEntity, Failure>> getCurrentUser();

  Future<Result<AuthResult, Failure>> refreshToken();

  bool get isAuthenticated;

  UserEntity? get currentUser;
}
