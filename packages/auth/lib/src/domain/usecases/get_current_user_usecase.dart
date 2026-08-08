import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

class GetCurrentUserUseCase extends NoParamsUseCase<UserEntity> {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<UserEntity, Failure>> call() {
    return _repository.getCurrentUser();
  }
}
