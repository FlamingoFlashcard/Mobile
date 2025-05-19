import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/presentation/widgets/snackbar.dart';
import 'package:lacquer/config/theme.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String? token;
  final String avatarUrl;

  const EditProfileScreen({
    required this.token,
    required this.avatarUrl,
    super.key,
  });

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  String avatarUrl = '';
  File? _newAvatarFile;

  bool _isLoading = false;
  bool _secureText = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    avatarUrl = widget.avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
          prefixIconColor: Colors.black,
          floatingLabelStyle: TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
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
            title: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildAvatar(),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 40.0,
                                  bottom: 10.0,
                                  left: 50.0,
                                  right: 50.0,
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    label: Text('User Name'),
                                    prefixIcon: Icon(FontAwesomeIcons.user),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 20.0,
                                  left: 50.0,
                                  right: 50.0,
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    label: Text('Password'),
                                    prefixIcon: Icon(
                                      FontAwesomeIcons.fingerprint,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _secureText
                                            ? FontAwesomeIcons.eye
                                            : FontAwesomeIcons.eyeSlash,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _secureText = !_secureText;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _secureText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      updateProfile();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    backgroundColor: Colors.deepOrange,
                                    minimumSize: Size.fromHeight(
                                      50,
                                    ), // Chiều cao tùy ý
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  //---------------------------- WIDGETS ----------------------------
  Widget _buildAvatar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage:
                _newAvatarFile != null
                    ? FileImage(_newAvatarFile!)
                    : (avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : AssetImage('assets/images/boy.png') as ImageProvider),
          ),
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
        'https://lacquer.up.railway.app/auth/profile',
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
        'https://lacquer.up.railway.app/auth/avatar',
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
    }
  }
}
