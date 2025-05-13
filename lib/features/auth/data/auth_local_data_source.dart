import 'package:lacquer/features/auth/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this.sf);

  final SharedPreferences sf;

  Future<void> saveToken(String token) async {
    // Save token to local storage
    await sf.setString(AuthDataConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    // Get token from local storage
    return sf.getString(AuthDataConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    // Delete token from local storage
    await sf.remove(AuthDataConstants.tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    // Save userId to local storage
    await sf.setString(AuthDataConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    // Get userId from local storage
    return sf.getString(AuthDataConstants.userIdKey);
  }

  Future<void> deleteUserId() async {
    // Delete userId from local storage
    await sf.remove(AuthDataConstants.userIdKey);
  }
}