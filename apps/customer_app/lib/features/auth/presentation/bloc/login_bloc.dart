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

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.when(
      success: (data) => emit(LoginSuccess(data)),
      failure: (failure) => emit(LoginError(failure)),
    );
  }
}
