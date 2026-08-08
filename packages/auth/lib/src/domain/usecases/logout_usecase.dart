import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

class LogoutUseCase extends NoParamsUseCase<void> {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call() {
    return _repository.logout();
  }
}
