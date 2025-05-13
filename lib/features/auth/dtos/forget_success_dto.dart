class ForgetSuccessDto {
  final bool success;
  final String message;
  final String? data;

  ForgetSuccessDto({required this.success, required this.message, this.data});

  factory ForgetSuccessDto.fromJson(Map<String, dynamic> json) {
    return ForgetSuccessDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as String?,
    );
  }
}
