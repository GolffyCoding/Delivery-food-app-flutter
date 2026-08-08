import 'package:opendelivery_core/opendelivery_core.dart';

/// Generic base state for BLoC with loading, loaded, error states.
sealed class BaseState<T> {
  const BaseState();
  const factory BaseState.initial() = BaseInitial<T>;
  const factory BaseState.loading() = BaseLoading<T>;
  const factory BaseState.loaded(T data) = BaseLoaded<T>;
  const factory BaseState.error(Failure failure) = BaseError<T>;
}

class BaseInitial<T> extends BaseState<T> {
  const BaseInitial();
}

class BaseLoading<T> extends BaseState<T> {
  const BaseLoading();
}

class BaseLoaded<T> extends BaseState<T> {
  final T data;
  const BaseLoaded(this.data);
}

class BaseError<T> extends BaseState<T> {
  final Failure failure;
  const BaseError(this.failure);
}
