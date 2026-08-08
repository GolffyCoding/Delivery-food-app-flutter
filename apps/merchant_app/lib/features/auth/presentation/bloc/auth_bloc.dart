import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLoginSuccess extends AuthEvent {
  final AuthResult result;
  const AuthLoginSuccess(this.result);
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;

  AuthBloc(this._getCurrentUser, this._logout) : super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginSuccess>((event, emit) => emit(AuthAuthenticated(event.result.user)));
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUser();
    result.when(
      success: (user) => emit(AuthAuthenticated(user)),
      failure: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
