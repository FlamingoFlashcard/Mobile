class RegisterSuccessDto {
  final String message;

  RegisterSuccessDto({required this.message});

  factory RegisterSuccessDto.fromJson(Map<String, dynamic> json) {
    return RegisterSuccessDto(message: json['message'] as String);
  }
}
