import 'dart:io';
import 'package:lacquer/features/profile/data/profile_api_client.dart';
import 'package:lacquer/features/profile/dtos/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final ProfileApiClient _profileApiClient;

  ProfileRepository({required Dio dio})
    : _profileApiClient = ProfileApiClient(dio);

  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');
    final response = await _profileApiClient.getProfile(token);
    return Profile.fromJson(response.data['data']);
  }

  Future<Profile> updateProfile(
    String token, {
    String? username,
    String? password,
  }) async {
    final response = await _profileApiClient.updateProfile(
      token,
      username: username,
      password: password,
    );
    return Profile.fromJson(response.data['data']);
  }

  Future<String> uploadAvatar(String token, File avatarFile) async {
    final response = await _profileApiClient.uploadAvatar(token, avatarFile);
    return response.data['data']['avatar'];
  }
}
