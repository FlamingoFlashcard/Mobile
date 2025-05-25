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
    // Handle tags parsing - they might be objects or strings
    List<String> parsedTags = [];
    final tagsData = json['tags'];
    if (tagsData is List) {
      for (var tag in tagsData) {
        if (tag is String) {
          parsedTags.add(tag);
        } else if (tag is Map<String, dynamic>) {
          // If tag is an object, extract the ID or name
          parsedTags.add(tag['_id'] as String? ?? tag['id'] as String? ?? '');
        }
      }
    }

    // Handle cards parsing - they might be objects or strings
    List<String> parsedCards = [];
    final cardsData = json['cards'];
    if (cardsData is List) {
      for (var card in cardsData) {
        if (card is String) {
          parsedCards.add(card);
        } else if (card is Map<String, dynamic>) {
          // If card is an object, extract the ID
          parsedCards.add(
            card['_id'] as String? ?? card['id'] as String? ?? '',
          );
        }
      }
    }

    return CreateDeckDto(
      title: json['title'] as String,
      description: json['description'] as String,
      tags: parsedTags,
      cardIds: parsedCards,
    );
  }
}

class CreateDeckResponseDto {
  final String? id;
  final String? title;
  final String? description;
  final String? img;
  final List<String>? tags;
  final List<String>? cardIds;
  final String? userId;
  final DateTime? createdAt;

  CreateDeckResponseDto({
    this.id,
    this.title,
    this.description,
    this.img,
    this.tags,
    this.cardIds,
    this.userId,
    this.createdAt,
  });

  factory CreateDeckResponseDto.fromJson(Map<String, dynamic> json) {
    // Handle tags parsing - they might be objects or strings
    List<String>? parsedTags;
    final tagsData = json['tags'];
    if (tagsData is List) {
      parsedTags = [];
      for (var tag in tagsData) {
        if (tag is String) {
          parsedTags.add(tag);
        } else if (tag is Map<String, dynamic>) {
          // If tag is an object, extract the ID or name
          parsedTags.add(tag['_id'] as String? ?? tag['id'] as String? ?? '');
        }
      }
    }

    // Handle cards parsing - they might be objects or strings
    List<String>? parsedCards;
    final cardsData = json['cards'];
    if (cardsData is List) {
      parsedCards = [];
      for (var card in cardsData) {
        if (card is String) {
          parsedCards.add(card);
        } else if (card is Map<String, dynamic>) {
          // If card is an object, extract the ID
          parsedCards.add(
            card['_id'] as String? ?? card['id'] as String? ?? '',
          );
        }
      }
    }

    return CreateDeckResponseDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      img: json['img'] as String?,
      tags: parsedTags,
      cardIds: parsedCards,
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
