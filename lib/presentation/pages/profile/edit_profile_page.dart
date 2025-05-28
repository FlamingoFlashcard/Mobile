import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lacquer/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/profile/bloc/profile_state.dart';
import 'package:lacquer/features/profile/bloc/profile_event.dart';
import 'package:lacquer/config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  bool _secureText = true;
  File? _selectedAvatar;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          Navigator.pop(context);
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              prefixIconColor: Colors.black,
              floatingLabelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(width: 2, color: Colors.black),
              ),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  CustomTheme.loginGradientEnd, // Màu dưới
                  CustomTheme.loginGradientStart, // Màu trên
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: _buildBody(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoadSuccess || state is ProfileUpdateSuccess) {
      final currentProfile = state as dynamic;
      _usernameController.text = currentProfile.username;
      _aboutController.text = currentProfile.about;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAvatarSection(currentProfile.avatarUrl),
                const SizedBox(height: 30),
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildAboutField(),
                const SizedBox(height: 30),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      );
    }

    if (state is ProfileUpdateInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container();
  }

  Widget _buildAvatarSection(String currentAvatarUrl) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundImage:
            _selectedAvatar != null
                ? FileImage(_selectedAvatar!)
                : (currentAvatarUrl.isNotEmpty
                        ? NetworkImage(currentAvatarUrl)
                        : const AssetImage('assets/images/boy.png'))
                    as ImageProvider,
        child:
            _selectedAvatar == null && currentAvatarUrl.isEmpty
                ? const Icon(Icons.add_a_photo, size: 40)
                : null,
      ),
    );
  }

  Widget _buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
          prefixIcon: Icon(FontAwesomeIcons.user),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildAboutField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: SizedBox(
        height: 200,
        child: TextFormField(
          controller: _aboutController,
          decoration: InputDecoration(
            labelText: 'About',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _secureText,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(FontAwesomeIcons.fingerprint),
          suffixIcon: IconButton(
            icon: Icon(
              _secureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            ),
            onPressed: () => setState(() => _secureText = !_secureText),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<ProfileBloc>().add(
              ProfileUpdateRequested(
                username: _usernameController.text.trim(),
                password: _passwordController.text.trim(),
                avatarFile: _selectedAvatar,
                about: _aboutController.text.trim(),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.deepOrange,
        ),
        child: const Text(
          'SAVE',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }
}
