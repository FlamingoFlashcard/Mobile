import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  VerifyEmailPageState createState() => VerifyEmailPageState();
}

class VerifyEmailPageState extends State<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  int _seconds = 30;
  bool _canResend = false;
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Khởi tạo AnimationController cho hiệu ứng nút Back
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      vsync: this,
    )..addListener(() {
      setState(() {
        _scale = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
            _startCountdown();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomTheme.loginGradientStart,
                  CustomTheme.loginGradientEnd,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                stops: <double>[0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/app_mascot.png', width: 100),
                  const SizedBox(height: 20),
                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We\'ve sent a verification link to your email. Click the link to verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap:
                        _canResend
                            ? () {
                              _onResendCode(context);
                            }
                            : null,
                    child: Text(
                      _canResend
                          ? 'Resend Code'
                          : 'Resend code in $_seconds seconds',
                      style: TextStyle(
                        fontSize: 16,
                        color: _canResend ? Colors.black : const Color.fromARGB(255, 66, 61, 61),
                        decoration:
                            _canResend
                                ? TextDecoration.underline
                                : TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _onBackPressed(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: CustomTheme.mainColor1,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Back với hiệu ứng bấm
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTapDown: (_) => _controller.reverse(), // Nhấn xuống: Thu nhỏ
              onTapUp: (_) {
                _controller.forward(); // Thả ra: Trở về bình thường
                _onBackPressed(context);
              },
              child: Transform.scale(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onResendCode(BuildContext context) {
    // Gửi lại mã xác thực
    // Đoạn này sẽ gọi API gửi lại mã xác thực
  }

  void _onBackPressed(BuildContext context) {
    context.go(RouteName.login);
  }
}
