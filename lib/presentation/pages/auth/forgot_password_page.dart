import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  //----------------------------- VARIABLES -----------------------------
  ForgotPasswordPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final FocusNode focusNodeEmail = FocusNode();

  //----------------------------- INIT -----------------------------
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    var resultwidget = (switch (state) {
      AuthVerifyMailSending() => const Center(
        child: CircularProgressIndicator(color: CustomTheme.mainColor1),
      ),
      AuthVerifyMailSentSuccess() => const Center(
        child: Text(
          'Verification email sent successfully, please check your inbox.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CustomTheme.mainColor1,
          ),
        ),
      ),
      AuthVerifyMailSentFailure() => Center(
        child: Text(
          'Failed to send verification email: ${state.message}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CustomTheme.mainColor1,
          ),
        ),
      ),
      _ => const SizedBox.shrink(),
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              CustomTheme.loginGradientStart,
              CustomTheme.loginGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.0),
                    child: Text(
                      'Forgot\npassword?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: CustomTheme.mainColor1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter your email to reset your password:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomTheme.mainColor1,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2.0,
                  color: CustomTheme.lightbeige,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    width: 330.0,
                    height: 75.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                            left: 25.0,
                            right: 25.0,
                          ),
                          child: TextFormField(
                            focusNode: focusNodeEmail,
                            controller: emailController,
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
                            onFieldSubmitted: (_) {},
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: CustomTheme.primaryColor,
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: CustomTheme.loginGradientEnd,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 70.0,
                      ),
                      child: Text(
                        'Send mail verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontFamily: 'WorkSans',
                        ),
                      ),
                    ),
                    onPressed: () {
                      _onSendVerify(context);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    context.go(RouteName.login);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: CustomTheme.mainColor1,
                  ),
                  label: const Text(
                    'Back to login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.mainColor1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                resultwidget,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _onSendVerify(BuildContext context) {
    context.read<AuthBloc>().add(
      AuthEventSendMailVerify(email: emailController.text.trim()),
    );
  }
}
