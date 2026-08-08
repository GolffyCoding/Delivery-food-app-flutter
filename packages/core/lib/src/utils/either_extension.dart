import 'package:opendelivery_core/opendelivery_core.dart';

/// Extensions on [Result] for cleaner error handling.
extension ResultExtension<T> on Result<T, Failure> {
  /// Maps the failure to a user-friendly message.
  String get errorMessage => when(
        success: (_) => '',
        failure: (failure) => failure.message,
      );
}
