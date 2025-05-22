import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/widgets/snackbar.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? token;
  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: CustomTheme.lightbeige,
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Text(
                      'Enter new password below to reset your password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CustomTheme.lightbeige,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPasswordInput(),
                const SizedBox(height: 20),
                _buildConfirmPasswordInput(),
                const SizedBox(height: 20),
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return _buildInputField(
      controller: passwordController,
      focusNode: _focusNodePassword,
      hintText: 'New Password',
      obscureText: _obscurePassword,
      toggleVisibility: _togglePasswordVisibility,
    );
  }

  Widget _buildConfirmPasswordInput() {
    return _buildInputField(
      controller: confirmPasswordController,
      focusNode: _focusNodeConfirmPassword,
      hintText: 'Confirm Password',
      obscureText: _obscurePassword,
      toggleVisibility: _togglePasswordVisibility,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return Card(
      elevation: 2.0,
      color: CustomTheme.lightbeige,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
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
              size: 22.0,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'WorkSansSemiBold',
              fontSize: 17.0,
            ),
            suffixIcon: GestureDetector(
              onTap: toggleVisibility,
              child: Icon(
                obscureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                size: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: CustomTheme.secondaryColor,
      ),
      child: MaterialButton(
        highlightColor: Colors.transparent,
        splashColor: CustomTheme.loginGradientEnd,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 80.0),
          child: Text(
            'Reset Password',
            style: TextStyle(
              color: CustomTheme.lightbeige,
              fontSize: 17.0,
              fontFamily: 'WorkSans',
            ),
          ),
        ),
        onPressed: () => _toggleResetPasswordButton(),
      ),
    );
  }

  void _toggleResetPasswordButton() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      CustomSnackBar(context, const Text("Please fill in all fields"));
      return;
    }
    if (password != confirmPassword) {
      CustomSnackBar(context, const Text("Passwords do not match"));
      return;
    }
    if (password.length < 8) {
      CustomSnackBar(
        context,
        const Text("Password must be at least 8 characters"),
      );
      return;
    }
  }
}
