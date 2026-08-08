/// Lightweight Result type used across the app instead of a third-party
/// package, so every layer (usecase/repository/bloc) shares one consistent
/// `.when(success:, failure:)` API.
sealed class Result<T, F> {
  const Result();

  const factory Result.success(T data) = ResultSuccess<T, F>;
  const factory Result.failure(F failure) = ResultError<T, F>;

  R when<R>({
    required R Function(T data) success,
    required R Function(F failure) failure,
  }) {
    final self = this;
    return switch (self) {
      ResultSuccess<T, F>() => success(self.data),
      ResultError<T, F>() => failure(self.failure),
    };
  }

  bool get isSuccess => this is ResultSuccess<T, F>;

  bool get isFailure => this is ResultError<T, F>;
}

final class ResultSuccess<T, F> extends Result<T, F> {
  final T data;
  const ResultSuccess(this.data);
}

final class ResultError<T, F> extends Result<T, F> {
  final F failure;
  const ResultError(this.failure);
}
