import 'package:flutter/cupertino.dart';

class CustomTheme {
  const CustomTheme();

  static const Color primaryColor = Color(0xFFc13e80);
  static const Color secondaryColor = Color(0xFF317153);
  static const Color loginGradientStart = Color.fromARGB(255, 224, 150, 135);
  static const Color loginGradientEnd = Color(0xFFCD5036);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightbeige = Color(0xFFFCEEC6);
  static const Color cinnabar = Color(0xFFCD5036);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[loginGradientStart, loginGradientEnd],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

