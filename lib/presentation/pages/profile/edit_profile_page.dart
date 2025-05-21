import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lacquer/config/env.dart';
import 'package:lacquer/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/profile/bloc/profile_state.dart';
import 'package:lacquer/features/profile/bloc/profile_event.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                borderRadius: BorderRadius.circular(100),
              ),
              prefixIconColor: Colors.black,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black),
              ),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              centerTitle: true,
            ),
            body: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoadSuccess || state is ProfileUpdateSuccess) {
      final currentProfile = state as dynamic;
      _usernameController.text = currentProfile.username;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAvatarSection(currentProfile.avatarUrl),
                const SizedBox(height: 20),
                _buildUsernameField(),
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 20),
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
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(FontAwesomeIcons.user),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
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
        border: const OutlineInputBorder(),
      ),
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  Future<void> updateProfile() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      CustomSnackBar(context, const Text("Please fill in one of the blanks"));
      return;
    }

    setState(() => _isLoading = true);

    final dio = Dio();
    try {
      final response = await dio.put(
        '${Env.serverURL}/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {'username': username, 'password': password},
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<ProfileBloc>().add(
            ProfileUpdateRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
              avatarFile: _selectedAvatar,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.deepOrange,
      ),
      child: const Text('SAVE', style: TextStyle(fontSize: 18)),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _newAvatarFile = file);
      await _uploadAvatar(file);
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    final dio = Dio();

    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: path.basename(imageFile.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    try {
      final response = await dio.put(
        '${Env.serverURL}/auth/avatar',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          avatarUrl = data['data']['avatar'] ?? avatarUrl;
        });

        CustomSnackBar(context, Text(data['message']));
      } else {
        final errorData = response.data;
        final errorMessage = errorData['message'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      debugPrint('Upload error: $e');

      if (!mounted) return;

      CustomSnackBar(context, const Text('Error occurred while uploading'));
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }
}
