import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({required super.child, required String key})
    : super(
        key: ValueKey(key),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

class SlideUpTransitionPage extends CustomTransitionPage<void> {
  SlideUpTransitionPage({required super.child, required String key})
    : super(
        key: ValueKey(key),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

class SlideDownTransitionPage extends CustomTransitionPage<void> {
  SlideDownTransitionPage({required super.child, required String key})
    : super(
        key: ValueKey(key),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

class ScaleTransitionPage extends CustomTransitionPage<void> {
  ScaleTransitionPage({required super.child, required String key})
    : super(
        key: ValueKey(key),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return ScaleTransition(scale: animation.drive(tween), child: child);
        },
      );
}
