class CreateTagDto {
  final String name;

  CreateTagDto({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  factory CreateTagDto.fromJson(Map<String, dynamic> json) {
    return CreateTagDto(name: json['name'] as String);
  }
}

class CreateTagResponseDto {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateTagResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateTagResponseDto.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('Tag ID (_id) is missing or empty in JSON');
    }

    return CreateTagResponseDto(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? 'No description',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? '1970-01-01T00:00:00Z',
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? '1970-01-01T00:00:00Z',
      ),
    );
  }
}
