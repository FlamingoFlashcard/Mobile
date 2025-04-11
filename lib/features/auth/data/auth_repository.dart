import 'package:flutter/widgets.dart';
import 'package:lacquer/features/auth/data/auth_api_client.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';
import 'package:lacquer/features/auth/dtos/forget_dto.dart';
import 'package:lacquer/features/auth/dtos/login_dto.dart';
import 'package:lacquer/features/auth/dtos/register_dto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lacquer/features/result_type.dart';

class AuthRepository {
  final AuthApiClient authApiClient;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepository({
    required this.authApiClient,
    required this.authLocalDataSource,
  });

  Future<Result<void>> login(String email, String password) async {
    try {
      final loginSuccessDto = await authApiClient.login(
        LoginDto(email: email, password: password),
      );
      await authLocalDataSource.saveToken(loginSuccessDto.data.token);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> register(String username, String email, String password, String authProvider) async {
    try {
      await authApiClient.register(
       RegisterDto(username: username, email: email, password: password, authProvider: authProvider),
     );
    }
    catch (e) {
     return Failure(e.toString());
    }
    return Success(null);
   }

  Future<Result<String?>> getToken() async {
    try{
      final token = await authLocalDataSource.getToken();
      if (token != null) {
        return Success(token);
      } else {
        return Success(null);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  } 

  Future<Result<void>> logout() async {
    try {
      await authLocalDataSource.deleteToken();
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> forget(String email) async {
    try {
      await authApiClient.forget(
        ForgetDto(email: email),
      );
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<String?>> googleSignIn() async {
    try {
      debugPrint('Start Google Sign In');
      final GoogleSignInAccount? account = await GoogleSignIn(
        scopes: [
        'email'
        ],
        serverClientId: '352071145880-1stn4081qetb1epj5iflej9qkt0fvuun.apps.googleusercontent.com',
        ).signIn();
      if (account == null) {
        debugPrint('Account null');
        return Success(null);
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.idToken != null) {
        debugPrint('ID Token: ${auth.idToken}');

        final idToken = auth.idToken;
        final loginSuccessDto = await authApiClient.googleSignIn(idToken!);

        await authLocalDataSource.saveToken(loginSuccessDto.data.token);
        debugPrint('SuccessToken: ${loginSuccessDto.data.token}');
        return Success(idToken);
      } else {
        debugPrint('ID Token null');
        return Success(null);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
