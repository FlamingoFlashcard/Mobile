class GetDeckDto {
  final String id;
  final String title;
  final List<String> tags;
  final String? description;
  final String? img;
  final List<Map<String, dynamic>>? cards;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDone;

  GetDeckDto({
    required this.id,
    required this.title,
    required this.tags,
    this.description,
    this.img,
    this.cards,
    this.createdAt,
    this.updatedAt,
    this.isDone,
  });

  factory GetDeckDto.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    final tagsData = json['tags'];
    if (tagsData is List) {
      for (var tag in tagsData) {
        if (tag is String) {
          parsedTags.add(tag);
        } else if (tag is Map<String, dynamic>) {
          parsedTags.add(tag['_id'] as String? ?? tag['id'] as String? ?? '');
        }
      }
    }

    return GetDeckDto(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tags: parsedTags,
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
      isDone: json['isDone'] as bool? ?? false,
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
      'isDone': isDone,
    };
  }
}
