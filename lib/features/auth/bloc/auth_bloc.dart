import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:lacquer/features/auth/data/auth_repository.dart';
import 'package:lacquer/features/result_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthEventStarted>(_onStarted);
    on<AuthEventLogin>(_onLogin);
    on<AuthEventRegister>(_onRegister);
    on<AuthAuthenticateStarted>(_onAuthenticateStarted);
    on<AuthEventLogout>(_onLogoutStarted);
    on<AuthEventSendMailVerify>(_onSendMailVerify);
    on<AuthEventGoogleSignIn>(_onGoogleSignIn);
    on<AuthEventDeleteProfile>(_onDeleteProfile);
  }

  final AuthRepository authRepository;

  void _onStarted(AuthEventStarted event, Emitter<AuthState> emit) {
    emit(AuthAuthenticatedUnknown());
  }

  void _onLogin(AuthEventLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoginInProgress());
    final result = await authRepository.login(event.email, event.password);
    return (switch (result) {
      Success() => emit(AuthLoginSuccess()),
      Failure() => emit(AuthLoginFailure(result.message)),
    });
  }

  void _onRegister(AuthEventRegister event, Emitter<AuthState> emit) async {
    emit(AuthRegisterInProgress());
    final result = await authRepository.register(
      event.username,
      event.email,
      event.password,
      event.authProvider,
    );
    return (switch (result) {
      Success() => emit(AuthRegisterSuccess()),
      Failure() => emit(AuthRegisterFailure(result.message)),
    });
  }

  void _onAuthenticateStarted(
    AuthAuthenticateStarted event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.getLocalSource();
    return (switch (result) {
      Success(data: final localsource) when localsource != null => emit(
        AuthAuthenticatedSuccess(localsource.token, localsource.userId),
      ),
      Success() => emit(AuthAuthenticatedUnknown()),
      Failure() => emit(AuthAuthenticatedFailure(result.message)),
    });
  }

  void _onLogoutStarted(AuthEventLogout event, Emitter<AuthState> emit) async {
    final result = await authRepository.logout();
    return (switch (result) {
      Success() => emit(AuthLogoutSuccess()),
      Failure() => emit(AuthLogoutFailure(result.message)),
    });
  }

  void _onSendMailVerify(
    AuthEventSendMailVerify event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthVerifyMailSending());
    final result = await authRepository.forget(event.email);
    return (switch (result) {
      Success() => emit(AuthVerifyMailSentSuccess()),
      Failure() => emit(AuthVerifyMailSentFailure(result.message)),
    });
  }

  void _onGoogleSignIn(
    AuthEventGoogleSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGoogleSignInInProgress());
    final result = await authRepository.googleSignIn();
    return (switch (result) {
      Success(data: final token) when token != null => emit(AuthLoginSuccess()),
      Success() => emit(AuthAuthenticatedUnknown()),
      Failure() => emit(AuthLoginFailure(result.message)),
    });
  }

  void _onDeleteProfile(
    AuthEventDeleteProfile event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.deleteprofile(event.token);
    return (switch (result) {
      Success() => emit(AuthDeleteProfileSuccess()),
      Failure() => emit(AuthDeleteProfileFailure(result.message)),
    });
  }
}
