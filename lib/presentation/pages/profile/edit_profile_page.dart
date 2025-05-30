import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lacquer/config/env.dart';
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

class EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  bool _secureText = true;
  File? _selectedAvatar;

  late AnimationController _animationController;
  late AnimationController _avatarAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _aboutController.dispose();
    _animationController.dispose();
    _avatarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          Navigator.pop(context);
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                CustomTheme.loginGradientEnd,
                CustomTheme.loginGradientStart,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(),
            body: _buildBody(state),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.3)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoadSuccess || state is ProfileUpdateSuccess) {
      final currentProfile = state as dynamic;
      _usernameController.text = currentProfile.username;
      _aboutController.text = currentProfile.about;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatarSection(currentProfile.avatarUrl),
                          const SizedBox(height: 40),
                          _buildAnimatedField(_buildUsernameField(), 0),
                          const SizedBox(height: 25),
                          _buildAnimatedField(_buildPasswordField(), 1),
                          const SizedBox(height: 25),
                          _buildAnimatedField(_buildAboutField(), 2),
                          const SizedBox(height: 40),
                          _buildAnimatedField(_buildSaveButton(), 3),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (state is ProfileUpdateInProgress) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Updating profile...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  Widget _buildAnimatedField(Widget child, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOutCubic.transform(
          (_animationController.value - delay).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, (1 - animationValue) * 30),
          child: Opacity(opacity: animationValue, child: child),
        );
      },
    );
  }

  Widget _buildAvatarSection(String currentAvatarUrl) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(255, 87, 34, 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _avatarAnimationController.forward().then((_) {
                _avatarAnimationController.reverse();
              });
              _pickImage();
            },
            child: AnimatedBuilder(
              animation: _avatarAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_avatarAnimationController.value * 0.1),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 63,
                      backgroundImage:
                          _selectedAvatar != null
                              ? FileImage(_selectedAvatar!)
                              : (currentAvatarUrl.isNotEmpty
                                      ? NetworkImage(currentAvatarUrl)
                                      : const AssetImage(
                                        'assets/images/boy.png',
                                      ))
                                  as ImageProvider,
                      child:
                          _selectedAvatar == null && currentAvatarUrl.isEmpty
                              ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              )
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildUsernameField() {
    return _buildGlassCard(
      child: TextFormField(
        controller: _usernameController,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Username',
          labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.7)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 87, 34, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.user,
              color: Colors.deepOrange,
              size: 18,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildGlassCard(
      child: TextFormField(
        controller: _passwordController,
        obscureText: _secureText,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.7)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 87, 34, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.lock,
              color: Colors.deepOrange,
              size: 18,
            ),
          ),
          suffixIcon: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 87, 34, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _secureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                color: Colors.deepOrange,
                size: 18,
              ),
            ),
            onPressed: () => setState(() => _secureText = !_secureText),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutField() {
    return _buildGlassCard(
      child: SizedBox(
        height: 120,
        child: TextFormField(
          controller: _aboutController,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'About',
            labelStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.7)),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(20),
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      onTapCancel: () => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              Colors.deepOrange.shade400,
              Colors.deepOrange.shade600,
              Colors.deepOrange.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
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
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(255, 87, 34, 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
