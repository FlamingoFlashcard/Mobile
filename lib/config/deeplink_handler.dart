import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initDeepLinks() async {
    try {
      // Handle app launch from deep link (when app is closed)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // Handle deep links while app is running
      _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri);
        },
        onError: (err) {
          print('Deep link error: $err');
        },
      );
    } catch (e) {
      print('Failed to initialize deep links: $e');
    }
  }

  static void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');

    // Check if this is a reset password link
    if (uri.host == 'lacquer-server.onrender.com' &&
        uri.path == '/redirect/reset') {
      // Extract the token from query parameters
      String? token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        print('Reset token extracted: $token');

        // Navigate to password reset screen
        GoRouter.of(navigatorKey.currentContext!).go(
          '/reset-password?token=$token'          
        );
      } else {
        print('No token found in reset link');
        // Handle error - maybe show a snackbar
        _showError('Invalid reset link');
      }
    } else {
      print('Unknown deep link: $uri');
    }
  }

  static void _showError(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
