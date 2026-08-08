import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

class LoginUseCase extends BaseUseCase<AuthResult, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<Result<AuthResult, Failure>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}
