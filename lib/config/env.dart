import 'dart:io' show Platform;

class Env {
  static String get serverURL => const String.fromEnvironment("SERVER_URL");

  static String get googleVisionApiKey {
    if (Platform.isAndroid) {
      return const String.fromEnvironment("VISION_KEY_ANDROID");
    } else if (Platform.isIOS) {
      return const String.fromEnvironment("VISION_KEY_IOS");
    } else {
      throw UnsupportedError("Unsupported platform for Vision API key");
    }
  }
}
