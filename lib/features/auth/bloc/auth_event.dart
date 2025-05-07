class AuthEvent {}

class AuthEventStarted extends AuthEvent {}

class AuthEventLogin extends AuthEvent {
  AuthEventLogin({required this.email, required this.password});

  final String email;
  final String password;
}

class AuthEventRegister extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String authProvider;

  AuthEventRegister({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
  });
}

class AuthAuthenticateStarted extends AuthEvent {}

class AuthEventLogout extends AuthEvent {}

class AuthEventSendMailVerify extends AuthEvent {
  AuthEventSendMailVerify({required this.email});

  final String email;
}

class AuthEventGoogleSignIn extends AuthEvent {}
