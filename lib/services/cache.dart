import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _profileKey = 'cached_profile';

  // Cache profile data
  static Future<void> cacheProfile({
    required String username,
    required String email,
    required String avatarUrl,
    required String about,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'username': username,
      'email': email,
      'avatar': avatarUrl,
      'about': about,
    };
    await prefs.setString(_profileKey, jsonEncode(profileData));
  }

  // Get cached profile data
  static Future<Map<String, String>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_profileKey);

    if (cachedData != null) {
      final decodedData = jsonDecode(cachedData) as Map<String, dynamic>;
      return {
        'username': decodedData['username'] ?? '',
        'email': decodedData['email'] ?? '',
        'avatar': decodedData['avatar'] ?? '',
        'about': decodedData['about'] ?? '',
      };
    }

    return null;
  }

  // Clear cached profile data
  static Future<void> clearProfileCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // Check if profile is cached
  static Future<bool> hasProfileCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }
}
