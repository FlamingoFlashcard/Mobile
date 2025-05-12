sealed class AuthState {}

class AuthInitial extends AuthState {}

//LOGIN
class AuthLoginInProgress extends AuthState {}

class AuthLoginSuccess extends AuthState {}
class AuthLoginFailure extends AuthState {
  final String message;

  AuthLoginFailure(this.message);
}

//REGISTER
class AuthRegisterInProgress extends AuthState {}
 
class AuthRegisterSuccess extends AuthState {}
class AuthRegisterFailure  extends AuthState {
   final String message;
 
   AuthRegisterFailure(this.message);
 }

//AUTHENTICATED
 class AuthAuthenticatedSuccess extends AuthState {
  final String token;
  final String userId;

  AuthAuthenticatedSuccess(this.token, this.userId);
 }

 class AuthAuthenticatedFailure extends AuthState {
    final String message;
  
    AuthAuthenticatedFailure(this.message);
 }

 class AuthAuthenticatedUnknown extends AuthState {}

//LOGOUT
 class AuthLogoutSuccess extends AuthState {}

 class AuthLogoutFailure extends AuthState {
    final String message;
  
    AuthLogoutFailure(this.message);
 }

 //VERIFY 
 class AuthVerifyMailSending extends AuthState {}

 class AuthVerifyMailSentSuccess extends AuthState {}
 class AuthVerifyMailSentFailure extends AuthState {
    final String message;
  
    AuthVerifyMailSentFailure(this.message);
  }

  //GOOGLE SIGN IN
  class AuthGoogleSignInInProgress extends AuthState {}