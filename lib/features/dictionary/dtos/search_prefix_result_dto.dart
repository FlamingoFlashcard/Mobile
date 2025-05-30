class SearchPrefixResultDto {
  final bool success;
  final String message;
  final List<String> data;

  const SearchPrefixResultDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SearchPrefixResultDto.fromJson(Map<String, dynamic> json) {
    return SearchPrefixResultDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}



