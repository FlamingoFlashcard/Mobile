import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  //----------------------------- VARIABLES -----------------------------
  const ProfilePage({super.key});

  //----------------------------- INIT -----------------------------
  @override
  Widget build(BuildContext context) {
    Widget widget = Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),

      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleLogout(context),
          child: const Text('Log out'),
        ),
      ),
    );

    widget = BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthLogoutSuccess():
            context.read<AuthBloc>().add(AuthEventStarted());
            context.pushReplacement(RouteName.login);
            break;
          case AuthLogoutFailure():
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('An error occurred while logging out'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            break;
          default:
            break;
        }
      },
      child: widget,
    );

    return widget;
  }
  //---------------------------- WIDGETS ----------------------------

  //----------------------------- FUNCTIONS -----------------------------
  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(AuthEventLogout());
  }
}
