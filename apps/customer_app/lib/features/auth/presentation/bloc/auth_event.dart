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
