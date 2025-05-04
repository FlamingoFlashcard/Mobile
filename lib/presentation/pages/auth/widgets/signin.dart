import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/config/theme.dart';
import '../../../widgets/snackbar.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  //----------------------------- VARIABLES -----------------------------
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  Color _googleButtonColor = Colors.white;
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  bool _obscureTextPassword = true;

  //----------------------------- INIT -----------------------------
  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    var loginWidget = (switch (authState) {
      AuthAuthenticatedUnknown() => _buildInitialLoginWidget(),
      AuthLoginInProgress() => _buildInLoginProgressWidget(),
      AuthLoginFailure() => _buildLoginFailureWidget(authState.message),
      AuthLoginSuccess() => _buildLoginSuccessWidget(),
      _ => _buildInitialLoginWidget(),
    });

    loginWidget = BlocListener<AuthBloc, AuthState>(
      listener: (cotext, state) {
        switch (state) {
          case AuthLoginSuccess():
            context.read<AuthBloc>().add(AuthAuthenticateStarted());
            break;
          case AuthAuthenticatedSuccess():
            context.go(RouteName.home);
            break;
          default:
            break;
        }
      },
      child: loginWidget,
    );

    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: loginWidget,
    );
  }

  //----------------------------- WIDGETS -----------------------------
  Widget _buildInitialLoginWidget() {
    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Card(
              elevation: 2.0,
              color: CustomTheme.lightbeige,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SizedBox(
                width: 330.0,
                height: 190.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 25.0,
                        right: 25.0,
                      ),
                      child: TextFormField(
                        focusNode: focusNodeEmail,
                        controller: loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: 'WorkSansSemiBold',
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.black,
                            size: 22.0,
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 17.0,
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          focusNodePassword.requestFocus();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email cannot be empty';
                          } else if (!value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: 250.0,
                      height: 1.0,
                      color: Colors.grey[400],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 25.0,
                        right: 25.0,
                      ),
                      child: TextFormField(
                        focusNode: focusNodePassword,
                        controller: loginPasswordController,
                        obscureText: _obscureTextPassword,
                        style: const TextStyle(
                          fontFamily: 'WorkSansSemiBold',
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(
                            FontAwesomeIcons.lock,
                            size: 22.0,
                            color: Colors.black,
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 17.0,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _toggleLogin,
                            child: Icon(
                              _obscureTextPassword
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              size: 15.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          _toggleSignInButton(context);
                        },
                        textInputAction: TextInputAction.go,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 180.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: CustomTheme.secondaryColor,
              ),
              child: MaterialButton(
                highlightColor: Colors.transparent,
                splashColor: CustomTheme.loginGradientEnd,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 36.0,
                  ),
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontFamily: 'WorkSansBold',
                    ),
                  ),
                ),
                onPressed: () {
                  _toggleSignInButton(context);
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: TextButton(
            onPressed: () {
              context.go(RouteName.forgotPassword);
            },
            child: const Text(
              'Forgot Your Password?',
              style: TextStyle(
                color: CustomTheme.lightbeige,
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'WorkSansMedium',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Colors.white10, Colors.white],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 1.0),
                    stops: <double>[0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                width: 100.0,
                height: 1.0,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Text(
                  'Or',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontFamily: 'WorkSansMedium',
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Colors.white, Colors.white10],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 1.0),
                    stops: <double>[0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                width: 100.0,
                height: 1.0,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: _buildGoogleButton(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: () => _onGoogleButtonTapUp(context),
      onTapDown: (_) => _onGoogleButtonTapDown(),
      onTapCancel: () => _onGoogleButtonTapUp(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: 50,
          right: 50,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          color: _googleButtonColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/crypto%2Fsearch%20(2).png?alt=media&token=24a918f7-3564-4290-b7e4-08ff54b3c94c",
              width: 20,
            ),
            const SizedBox(width: 20),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInLoginProgressWidget() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildLoginFailureWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Login failed: $message",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _returntoLogin(context),
            label: Text("Return to Login"),
            icon: Icon(Icons.refresh),
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => CustomTheme.primaryGradient.colors.first,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSuccessWidget() {
    return Container();
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _onGoogleButtonTapDown() {
    setState(() {
      _googleButtonColor = Colors.grey[300]!;
    });
  }

  void _onGoogleButtonTapUp(BuildContext context) {
    setState(() {
      _googleButtonColor = Colors.white;
    });
    CustomSnackBar(context, const Text('Google button pressed'));
    context.read<AuthBloc>().add(
      AuthEventGoogleSignIn(),
    );
  }

  void _toggleSignInButton(BuildContext context) {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar(context, const Text("Please fill in both fields"));
      return;
    }
    context.read<AuthBloc>().add(
      AuthEventLogin(email: email, password: password),
    );
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _returntoLogin(BuildContext context) {
    context.read<AuthBloc>().add(AuthEventStarted());
  }
}
