import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:lacquer/features/auth/data/auth_repository.dart';
import 'package:lacquer/presentation/pages/profile/edit_profile_page.dart';
import 'package:lacquer/config/env.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //----------------------------- VARIABLES ----------------------------
  String? token;
  String avatarUrl = '';
  String username = 'UnknownUser';
  String email = 'UnknownUser@gmail.com';
  //----------------------------- INIT -----------------------------
  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),

      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildAvatar(avatarUrl),
              _buildInfo(),
              _buildEdit(),
              _logoutButton(),
              _deleteButton(),
            ],
          ),
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
          case AuthDeleteProfileSuccess():
            context.read<AuthBloc>().add(AuthEventLogout());
            break;
          case AuthDeleteProfileFailure():
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(state.message),
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
  Widget _buildAvatar(String avatarUrl) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundImage:
              avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : AssetImage('assets/images/boy.png') as ImageProvider,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Text(
            username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(email, style: TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildEdit() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      EditProfileScreen(token: token, avatarUrl: avatarUrl),
            ),
          ).then((_) {
            fetchProfile();
          });
        },
        icon: Icon(Icons.person, size: 18, color: Colors.black),
        label: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12),
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 16, right: 16),
      child: InkWell(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Do you want to delete your account?'),
                content: Text(
                  'Are you sure you want to delete your account, all your personal data that Lacquer is storing will be permanently deleted?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancle'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes', style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            _deleteProfile();
          }
        },
        child: Card(
          color: CustomTheme.loginGradientStart,
          elevation: 4,
          shadowColor: Colors.black12,
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete profile'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5, left: 16, right: 16),
      child: InkWell(
        onTap: () => _handleLogout(),
        child: Card(
          color: CustomTheme.loginGradientStart,
          elevation: 4,
          shadowColor: Colors.black12,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _handleLogout() {
    context.read<AuthBloc>().add(AuthEventLogout());
  }

  void _deleteProfile() async {
    context.read<AuthBloc>().add(AuthEventDeleteProfile(token: token));
  }

  Future<void> fetchProfile() async {
    final authRepo = context.read<AuthRepository>();
    token = await authRepo.authLocalDataSource.getToken();

    final dio = Dio();

    try {
      final response = await dio.get(
        '${Env.serverURL}/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          username = data['data']['username'] ?? '';
          email = data['data']['email'] ?? '';
          avatarUrl = data['data']['avatar'] ?? '';
        });
      } else {
        final errorData = response.data;
        final errorMessage = errorData['message'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
