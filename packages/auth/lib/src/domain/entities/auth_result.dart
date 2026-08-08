import 'package:equatable/equatable.dart';
import 'package:opendelivery_auth/opendelivery_auth.dart';

class AuthResult extends Equatable {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  const AuthResult({required this.user, required this.accessToken, required this.refreshToken});

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
