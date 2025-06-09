import 'dart:io';
import 'package:lacquer/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      // Save token for authenticated requests
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
      }

      return response;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      return await _apiClient.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
        'authProvider': 'local',
      });
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Verify email
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      return await _apiClient.get('/redirect/verify?token=$token');
    } catch (e) {
      print('Email verification error: $e');
      rethrow;
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      return await _apiClient.post('/auth/forgot', {'email': email});
    } catch (e) {
      print('Forgot password error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      return await _apiClient.post('/redirect/reset?token=$token', {
        'newPassword': newPassword,
      });
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _apiClient.get('/auth/profile');
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _apiClient.put('/auth/profile', data);
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Upload avatar
  Future<Map<String, dynamic>> uploadAvatar(File avatar) async {
    try {
      final files = [MapEntry('avatar', avatar)];
      return await _apiClient.postMultipart('/auth/avatar', {}, files);
    } catch (e) {
      print('Upload avatar error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      return await _apiClient.delete('/auth/delete');
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Friends API

  // Get friends list
  Future<List<dynamic>> getFriends() async {
    try {
      final response = await _apiClient.get('/friend/friends');

      // Handle the new response format
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      print('Get friends error: $e');
      rethrow;
    }
  }

  // Send friend request
  Future<Map<String, dynamic>> sendFriendRequest(String friendId) async {
    try {
      return await _apiClient.post('/friend/request', {'friendId': friendId});
    } catch (e) {
      print('Send friend request error: $e');
      rethrow;
    }
  }

  // Accept friend request
  Future<Map<String, dynamic>> acceptFriendRequest(String friendshipId) async {
    try {
      return await _apiClient.post('/friend/accept', {'friendshipId': friendshipId});
    } catch (e) {
      print('Accept friend request error: $e');
      rethrow;
    }
  }

  // Reject friend request
  Future<Map<String, dynamic>> rejectFriendRequest(String friendshipId) async {
    try {
      return await _apiClient.post('/friend/reject', {'friendshipId': friendshipId});
    } catch (e) {
      print('Reject friend request error: $e');
      rethrow;
    }
  }

  // Get friend requests
  Future<List<dynamic>> getFriendRequests() async {
    try {
      final response = await _apiClient.get('/friend/requests');

      // Handle the new response format
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      print('Get friend requests error: $e');
      rethrow;
    }
  }

  // Get blocked users
  Future<List<dynamic>> getBlockedUsers() async {
    try {
      final response = await _apiClient.get('/friend/blocked');

      // Handle the new response format
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      print('Get blocked users error: $e');
      rethrow;
    }
  }

  // Block friend
  Future<Map<String, dynamic>> blockFriend(String friendId) async {
    try {
      return await _apiClient.post('/friend/block', {'friendId': friendId});
    } catch (e) {
      print('Block friend error: $e');
      rethrow;
    }
  }

  // Unblock friend
  Future<Map<String, dynamic>> unblockFriend(String friendId) async {
    try {
      return await _apiClient.post('/friend/unblock', {'friendId': friendId});
    } catch (e) {
      print('Unblock friend error: $e');
      rethrow;
    }
  }

  // Remove friend
  Future<Map<String, dynamic>> removeFriend(String friendId) async {
    try {
      return await _apiClient.post('/friend/remove', {'friendId': friendId});
    } catch (e) {
      print('Remove friend error: $e');
      rethrow;
    }
  }
}
