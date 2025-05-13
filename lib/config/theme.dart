import 'package:flutter/material.dart';

class CustomTheme {
  const CustomTheme();

  static const Color primaryColor = Color(0xFFA31D1D);
  static const Color secondaryColor = Color(0xFFC8872B);
  static const Color loginGradientStart = Color(0xFFFFFFFF);
  static const Color loginGradientEnd = Color(0xFFFEF9E1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightbeige = Colors.white;
  static const Color cinnabar = Colors.white;
  static const Color mainColor1 = Color(0xFF6D2323);
  static const Color mainColor2 = Color(0xFFE5D0AC);
  static const Color mainColor3 = Color(0xFFFEF9E1);
  static const Color chatbotprimary = Colors.purple;
  static const Color chatbotsecondary = Colors.blue;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[loginGradientStart, loginGradientEnd],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
