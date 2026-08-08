import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Base interface for all BLoCs providing common functionality.
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// Safe emit that catches any errors.
  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Runs a use case and handles the result.
  /// Returns true if successful, false otherwise.
  Future<bool> runUseCase<T>(
    Future<Result<T, Failure>> useCaseFuture, {
    required void Function(T data) onSuccess,
    required void Function(Failure failure) onFailure,
  }) async {
    final result = await useCaseFuture;
    return result.when(
      success: (data) {
        onSuccess(data);
        return true;
      },
      failure: (failure) {
        onFailure(failure);
        return false;
      },
    );
  }
}
