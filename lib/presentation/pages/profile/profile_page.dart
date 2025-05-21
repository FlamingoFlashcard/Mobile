import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_event.dart';
import 'package:lacquer/presentation/pages/profile/edit_profile_page.dart';
import 'package:lacquer/features/profile/bloc/profile_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lacquer/features/profile/bloc/profile_state.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, profileState) {
            if (profileState is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            } else if (profileState is ProfileUpdateFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(profileState.error)));
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthLogoutSuccess) {
              context.read<AuthBloc>().add(AuthEventStarted());
              context.pushReplacement(RouteName.login);
            } else if (authState is AuthLogoutFailure) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                        'An error occurred while logging out',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            } else if (authState is AuthDeleteProfileSuccess) {
              context.read<AuthBloc>().add(AuthEventLogout());
            } else if (authState is AuthDeleteProfileFailure) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(authState.message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: _buildContent(profileState),
          );
        },
      ),
    );
  }

  Widget _buildContent(ProfileState state) {
    if (state is ProfileLoadInProgress || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileLoadFailure) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state is ProfileLoadSuccess || state is ProfileUpdateSuccess) {
      final profileData = state as dynamic;
      return SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              _buildAvatar(profileData.avatarUrl),
              _buildInfo(profileData.username, profileData.email),
              _buildEditButton(),
              _logoutButton(),
              _deleteButton(),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  Widget _buildAvatar(String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CircleAvatar(
        radius: 60,
        backgroundImage:
            avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/boy.png') as ImageProvider,
      ),
    );
  }

  Widget _buildInfo(String username, String email) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Text(
            username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: ElevatedButton.icon(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            ),
        icon: const Icon(Icons.person, size: 18),
        label: const Text('Edit Profile', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 12),
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5, left: 16, right: 16),
      child: Card(
        color: CustomTheme.loginGradientStart,
        elevation: 4,
        child: ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.read<AuthBloc>().add(AuthEventLogout()),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 16, right: 16),
      child: Card(
        color: CustomTheme.loginGradientStart,
        elevation: 4,
        child: ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteConfirmationDialog(context),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account?'),
            content: const Text(
              'All your personal data will be permanently deleted. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _handleDelete(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!context.mounted) return;

    Navigator.pop(context, true);
    context.read<AuthBloc>().add(AuthEventDeleteProfile(token: token));
  }
}
