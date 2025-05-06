import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:lacquer/presentation/utils/validators.dart';
import '../../../widgets/snackbar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  //----------------------------- VARIABLES -----------------------------
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeConfirmPassword = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeName = FocusNode();

  bool _obscureTextPassword = true;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController =
      TextEditingController();

  //----------------------------- INIT -----------------------------
  @override
  void dispose() {
    focusNodePassword.dispose();
    focusNodeConfirmPassword.dispose();
    focusNodeEmail.dispose();
    focusNodeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    var registerWidget = (switch (authState) {
      AuthAuthenticatedUnknown() => _buildInitialRegisterWidget(),
      AuthRegisterInProgress() => _buildInRegisterProgressWidget(),
      AuthRegisterFailure() => _buildInRegisterFailureWidget(authState.message),
      AuthRegisterSuccess() => _buildInitialRegisterWidget(),
      _ => _buildInitialRegisterWidget(),
    });

    registerWidget = BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          context.go(RouteName.verify);
        }
      },
      child: registerWidget,
    );

    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: registerWidget,
    );
  }

  //----------------------------- WIDGETS -----------------------------
  Widget _buildInitialRegisterWidget() {
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
                height: 360.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 25.0,
                        right: 25.0,
                      ),
                      child: TextField(
                        focusNode: focusNodeName,
                        controller: signupNameController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: false,
                        style: const TextStyle(
                          fontFamily: 'WorkSansSemiBold',
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            FontAwesomeIcons.user,
                            color: Colors.black,
                          ),
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 16.0,
                          ),
                        ),
                        onSubmitted: (_) {
                          focusNodeEmail.requestFocus();
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
                      child: TextField(
                        focusNode: focusNodeEmail,
                        controller: signupEmailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
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
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 16.0,
                          ),
                        ),
                        onSubmitted: (_) {
                          focusNodePassword.requestFocus();
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
                      child: TextField(
                        focusNode: focusNodePassword,
                        controller: signupPasswordController,
                        obscureText: _obscureTextPassword,
                        autocorrect: false,
                        style: const TextStyle(
                          fontFamily: 'WorkSansSemiBold',
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.black,
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 16.0,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _toggleObscurePassword,
                            child: Icon(
                              _obscureTextPassword
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              size: 15.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onSubmitted: (_) {
                          focusNodeConfirmPassword.requestFocus();
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
                      child: TextField(
                        focusNode: focusNodeConfirmPassword,
                        controller: signupConfirmPasswordController,
                        obscureText: _obscureTextPassword,
                        autocorrect: false,
                        style: const TextStyle(
                          fontFamily: 'WorkSansSemiBold',
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.black,
                          ),
                          hintText: 'Confirmation',
                          hintStyle: const TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            fontSize: 16.0,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _toggleObscurePassword,
                            child: Icon(
                              _obscureTextPassword
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                              size: 15.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onSubmitted: (_) {
                          _toggleSignUpButton();
                        },
                        textInputAction: TextInputAction.go,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 350.0),
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
                    horizontal: 42.0,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontFamily: 'RobotoBold',
                    ),
                  ),
                ),
                onPressed: () => _toggleSignUpButton(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInRegisterProgressWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildInRegisterFailureWidget(String message) {
    return Center(child: Text(message));
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _toggleObscurePassword() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleSignUpButton() {
    final username = signupNameController.text.trim();
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text.trim();
    final confirmPassword = signupConfirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      CustomSnackBar(context, const Text("Please fill in all fields"));
      return;
    }
    if (!Validators.isValidEmail(email)) {
      CustomSnackBar(context, const Text("Invalid email format"));
      return;
    }
    if (password != confirmPassword) {
      CustomSnackBar(context, const Text("Passwords do not match"));
    }
    if (password.length < 8) {
      CustomSnackBar(
        context,
        const Text("Password must be at least 8 characters"),
      );
    }
    context.read<AuthBloc>().add(
      AuthEventRegister(
        username: username,
        email: email,
        password: password,
        authProvider: "local",
      ),
    );
  }
}
