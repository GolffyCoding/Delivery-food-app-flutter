import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

class RegisterParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;
  final String role;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
    this.role = 'customer',
  });
}

class RegisterUseCase extends BaseUseCase<AuthResult, RegisterParams> {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  @override
  Future<Result<AuthResult, Failure>> call(RegisterParams params) {
    return _repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      phone: params.phone,
      role: params.role,
    );
  }
}
