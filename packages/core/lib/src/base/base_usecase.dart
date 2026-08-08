import 'package:opendelivery_core/opendelivery_core.dart';

/// Base use case interface with a single parameter.
abstract class BaseUseCase<Type, Params> {
  Future<Result<Type, Failure>> call(Params params);
}

/// Use case that requires no parameters.
abstract class NoParamsUseCase<Type> {
  Future<Result<Type, Failure>> call();
}

/// Optional parameter wrapper.
class NoParams {
  const NoParams();
}
