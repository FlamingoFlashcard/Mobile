class LoginSuccessDto {
  final bool success;
  final String message;
  final Data data;

  const LoginSuccessDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginSuccessDto.fromJson(Map<String, dynamic> json) {
    return LoginSuccessDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Data {
  final String token;
  final String userId;
  final String username;

  const Data({
    required this.token,
    required this.userId,
    required this.username,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      token: json['token'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }
}
