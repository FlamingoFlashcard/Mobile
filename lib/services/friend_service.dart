import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class FriendService {
  final Dio _dio = Dio();

  Future<bool> sendFriendRequest(String friendId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.post(
        '${Env.serverURL}/friend/request',
        data: {'friendId': friendId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }
}
