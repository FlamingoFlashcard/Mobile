import 'package:lacquer/features/flashcard/dtos/card_dto.dart';

class CreateDeckDto {
  final String title;
  final String description;
  final List<String> tags;
  final List<CardDto> cards;

  CreateDeckDto({
    required this.title,
    required this.description,
    required this.tags,
    required this.cards,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  factory CreateDeckDto.fromJson(Map<String, dynamic> json) {
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

    List<CardDto> parsedCards = [];
    final cardsData = json['cards'];
    if (cardsData is List) {
      for (var card in cardsData) {
        if (card is Map<String, dynamic>) {
          parsedCards.add(CardDto.fromJson(card));
        }
      }
    }

    return CreateDeckDto(
      title: json['title'] as String,
      description: json['description'] as String,
      tags: parsedTags,
      cards: parsedCards,
    );
  }
}

class CreateDeckResponseDto {
  final String? id;
  final String? title;
  final String? description;
  final String? img;
  final List<String>? tags;
  final List<CardDto>? cards;
  final String? userId;
  final DateTime? createdAt;
  final bool? isDone;

  CreateDeckResponseDto({
    this.id,
    this.title,
    this.description,
    this.img,
    this.tags,
    this.cards,
    this.userId,
    this.createdAt,
    this.isDone,
  });

  factory CreateDeckResponseDto.fromJson(Map<String, dynamic> json) {
    List<String>? parsedTags;
    final tagsData = json['tags'];
    if (tagsData is List) {
      parsedTags = [];
      for (var tag in tagsData) {
        if (tag is String) {
          parsedTags.add(tag);
        } else if (tag is Map<String, dynamic>) {
          parsedTags.add(tag['_id'] as String? ?? tag['id'] as String? ?? '');
        }
      }
    }

    List<CardDto>? parsedCards;
    final cardsData = json['cards'];
    if (cardsData is List) {
      parsedCards = [];
      for (var card in cardsData) {
        if (card is Map<String, dynamic>) {
          parsedCards.add(CardDto.fromJson(card));
        }
      }
    }

    return CreateDeckResponseDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      img: json['img'] as String?,
      tags: parsedTags,
      cards: parsedCards,
      userId: json['userId'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'CreateDeckResponseDto(id: $id, title: $title)';
  }
}
