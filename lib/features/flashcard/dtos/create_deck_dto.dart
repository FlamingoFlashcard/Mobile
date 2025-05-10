class CreateDeckDto {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> cardIds;

  CreateDeckDto({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cardIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'img': imageUrl,
      'cards': cardIds,
    };
  }

  factory CreateDeckDto.fromJson(Map<String, dynamic> json) {
    return CreateDeckDto(
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['img'] as String,
      cardIds: (json['cards'] as List).map((e) => e as String).toList(),
    );
  }
}

class CreateDeckResponseDto {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String tag;
  final List<String> cardIds;
  final String userId;
  final DateTime createdAt;

  CreateDeckResponseDto({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tag,
    required this.cardIds,
    required this.userId,
    required this.createdAt,
  });

  factory CreateDeckResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateDeckResponseDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['img'] as String,
      tag: json['tag'] as String,
      cardIds: (json['cards'] as List).map((e) => e as String).toList(),
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
