part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLogin extends AuthEvent {

  AuthLogin({
    required this.email,
    required this.password
  });

  final String email;
  final String password;
}

class AuthRequestResetPassword extends AuthEvent {

  AuthRequestResetPassword({
    required this.email
  });

  final String email;
}

class AuthRegister extends AuthEvent {

  AuthRegister({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword
  });

  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

}

class AuthUpdateState extends AuthEvent {

  AuthUpdateState({
    required this.state
  });

  final AuthState state;
}

class AuthRefreshToken extends AuthEvent {}

class AuthLogout extends AuthEvent {}
