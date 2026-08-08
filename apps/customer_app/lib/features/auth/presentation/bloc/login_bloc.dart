import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

sealed class LoginEvent {
  const LoginEvent();
}

class LoginWithEmail extends LoginEvent {
  final String email;
  final String password;
  const LoginWithEmail(this.email, this.password);
}

/// One-tap access for reviewers/testers: logs into a fixed demo account,
/// registering it first if this is a fresh backend where it doesn't exist
/// yet. Deliberately not hardcoded to "already exists" — a freshly seeded
/// database has no accounts at all, and this button needs to work there too.
class LoginDemo extends LoginEvent {
  const LoginDemo();
}

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final AuthResult result;
  const LoginSuccess(this.result);
}

class LoginError extends LoginState {
  final Failure failure;
  const LoginError(this.failure);
}

const demoEmail = 'demo@opendelivery.test';
const demoPassword = 'DemoPass123!';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  LoginBloc(this._loginUseCase, this._registerUseCase) : super(const LoginInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginDemo>(_onLoginDemo);
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.when(
      success: (data) => emit(LoginSuccess(data)),
      failure: (failure) => emit(LoginError(failure)),
    );
  }

  Future<void> _onLoginDemo(LoginDemo event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    final loginResult = await _loginUseCase(const LoginParams(email: demoEmail, password: demoPassword));
    if (loginResult case ResultSuccess(data: final data)) {
      emit(LoginSuccess(data));
      return;
    }

    // No such account yet on this backend — create it, then log in for real
    // rather than assuming the register response's token is already valid
    // (some backends require email verification before login succeeds).
    final registerResult = await _registerUseCase(const RegisterParams(
      firstName: 'Demo',
      lastName: 'User',
      email: demoEmail,
      password: demoPassword,
      role: 'customer',
    ));
    if (registerResult case ResultError(failure: final failure)) {
      emit(LoginError(failure));
      return;
    }

    final retryLogin = await _loginUseCase(const LoginParams(email: demoEmail, password: demoPassword));
    retryLogin.when(
      success: (data) => emit(LoginSuccess(data)),
      failure: (failure) => emit(LoginError(failure)),
    );
  }
}
