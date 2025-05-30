import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ProfileApiClient {
  final Dio _dio;

  ProfileApiClient(this._dio);

  Future<Response> getProfile(String token) async {
    return _dio.get(
      '/auth/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> updateProfile(
    String token, {
    String? username,
    String? password,
  }) async {
    return _dio.put(
      '/auth/profile',
      data: {
        if (username != null) 'username': username,
        if (password != null) 'password': password,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> updateAbout(String token, {String? about}) async {
    return _dio.put(
      '/auth/about',
      data: {if (about != null) 'about': about},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> uploadAvatar(String token, File avatarFile) async {
    try {
      // Kiểm tra kích thước file (ví dụ: max 5MB)
      if (await avatarFile.length() > 5 * 1024 * 1024) {
        throw Exception('File size too large (max 5MB)');
      }

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: path.basename(avatarFile.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      return await _dio.put(
        '/auth/avatar',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          // Không throw exception với status code 500
          validateStatus: (status) => status! < 500,
        ),
      );
    } catch (e) {
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }
}
