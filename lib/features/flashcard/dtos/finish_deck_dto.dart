class FinishDeckResponseDto {
  final bool success;
  final String message;
  final DeckDto data;

  FinishDeckResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FinishDeckResponseDto.fromJson(Map<String, dynamic> json) {
    return FinishDeckResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DeckDto.fromJson(json['data']),
    );
  }
}

class DeckDto {
  final String id;
  final String title;
  final List<String> tags;
  final String? description;
  final String? img;
  final List<String>?
  cards; // Changed from List<Map<String, dynamic>> to List<String>
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDone;
  final String? owner; // Added
  final int? v; // Added for __v

  DeckDto({
    required this.id,
    required this.title,
    required this.tags,
    this.description,
    this.img,
    this.cards,
    this.createdAt,
    this.updatedAt,
    this.isDone,
    this.owner,
    this.v,
  });

  factory DeckDto.fromJson(Map<String, dynamic> json) {
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

    return DeckDto(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tags: parsedTags,
      description: json['description'] as String?,
      img: json['img'] as String?,
      cards:
          (json['cards'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isDone: json['isDone'] as bool? ?? false,
      owner: json['owner'] as String?,
      v: json['__v'] as int?,
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
      'owner': owner,
      '__v': v,
    };
  }
}
