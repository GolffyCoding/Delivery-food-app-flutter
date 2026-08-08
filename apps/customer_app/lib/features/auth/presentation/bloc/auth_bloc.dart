import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;

  AuthBloc(this._getCurrentUser, this._logout) : super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginSuccess>(_onLoginSuccess);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUser();
    result.when(
      success: (user) => emit(AuthAuthenticated(user)),
      failure: (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoginSuccess(AuthLoginSuccess event, Emitter<AuthState> emit) async {
    emit(AuthAuthenticated(event.result.user));
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
