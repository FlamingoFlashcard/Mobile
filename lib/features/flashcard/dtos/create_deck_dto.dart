class CreateDeckDto {
  final String title;
  final String description;
  final List<String> tags;
  final List<String> cardIds;

  CreateDeckDto({
    required this.title,
    required this.description,
    required this.tags,
    required this.cardIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'cards': cardIds,
    };
  }

  factory CreateDeckDto.fromJson(Map<String, dynamic> json) {
    return CreateDeckDto(
      title: json['title'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
      cardIds: (json['cards'] as List).map((e) => e as String).toList(),
    );
  }
}

class CreateDeckResponseDto {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? tag;
  final List<String>? cardIds;
  final String? userId;
  final DateTime? createdAt;

  CreateDeckResponseDto({
    this.id,
    this.title,
    this.description,
    this.image,
    this.tag,
    this.cardIds,
    this.userId,
    this.createdAt,
  });

  factory CreateDeckResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateDeckResponseDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      tag: json['tag'] as String?,
      cardIds:
          (json['cards'] as List<dynamic>?)?.map((e) => e as String).toList(),
      userId: json['userId'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
    );
  }

  @override
  String toString() {
    return 'CreateDeckResponseDto(id: $id, title: $title)';
  }
}
