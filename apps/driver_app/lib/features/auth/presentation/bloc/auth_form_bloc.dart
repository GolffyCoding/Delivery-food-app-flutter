import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:driver_app/data/driver_repository.dart';

sealed class AuthFormEvent {}

class SubmitLogin extends AuthFormEvent {
  final String email;
  final String password;
  SubmitLogin(this.email, this.password);
}

class SubmitRegister extends AuthFormEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String vehicleType;
  SubmitRegister(this.firstName, this.lastName, this.email, this.password, this.vehicleType);
}

sealed class AuthFormState {}

class AuthFormIdle extends AuthFormState {}

class AuthFormLoading extends AuthFormState {}

class AuthFormSuccess extends AuthFormState {
  final AuthResult result;
  AuthFormSuccess(this.result);
}

class AuthFormError extends AuthFormState {
  final String message;
  AuthFormError(this.message);
}

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final DriverRepository _driverRepository;

  AuthFormBloc(this._loginUseCase, this._registerUseCase, this._driverRepository) : super(AuthFormIdle()) {
    on<SubmitLogin>(_onLogin);
    on<SubmitRegister>(_onRegister);
  }

  Future<void> _onLogin(SubmitLogin event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.when(
      success: (data) => emit(AuthFormSuccess(data)),
      failure: (failure) => emit(AuthFormError(failure.message)),
    );
  }

  Future<void> _onRegister(SubmitRegister event, Emitter<AuthFormState> emit) async {
    emit(AuthFormLoading());
    final result = await _registerUseCase(RegisterParams(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      password: event.password,
      role: 'driver',
    ));

    await result.when(
      success: (data) async {
        // The `driver` role only grants access; the vehicle profile is a
        // separate resource that must be created right after.
        final driverRegisterResult = await _driverRepository.register(vehicleType: event.vehicleType);
        driverRegisterResult.when(
          success: (_) => emit(AuthFormSuccess(data)),
          failure: (failure) => emit(AuthFormError('Registered, but driver profile setup failed: ${failure.message}')),
        );
      },
      failure: (failure) async => emit(AuthFormError(failure.message)),
    );
  }
}
