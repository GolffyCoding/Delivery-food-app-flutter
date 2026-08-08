import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

class RegisterSubmit extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const RegisterSubmit(this.firstName, this.lastName, this.email, this.password);
}

sealed class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final AuthResult result;
  const RegisterSuccess(this.result);
}

class RegisterError extends RegisterState {
  final Failure failure;
  const RegisterError(this.failure);
}

@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterBloc(this._registerUseCase) : super(const RegisterInitial()) {
    on<RegisterSubmit>(_onRegister);
  }

  Future<void> _onRegister(RegisterSubmit event, Emitter<RegisterState> emit) async {
    emit(const RegisterLoading());
    final result = await _registerUseCase(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        role: 'customer',
      ),
    );
    result.when(
      success: (data) => emit(RegisterSuccess(data)),
      failure: (failure) => emit(RegisterError(failure)),
    );
  }
}
