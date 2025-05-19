class GetDeckDto {
  final String id;
  final String title;
  final List<String> tags;
  final String? description;
  final String? img;
  final List<Map<String, dynamic>>? cards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetDeckDto({
    required this.id,
    required this.title,
    required this.tags,
    this.description,
    this.img,
    this.cards,
    this.createdAt,
    this.updatedAt,
  });

  factory GetDeckDto.fromJson(Map<String, dynamic> json) {
    return GetDeckDto(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] as String?,
      img: json['img'] as String?,
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map((card) => card as Map<String, dynamic>)
              .toList(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'description': description,
      'img': img,
      'cards': cards,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
