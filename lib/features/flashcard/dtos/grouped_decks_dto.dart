import 'package:lacquer/features/flashcard/dtos/get_deck_dto.dart';

class GroupedDecksResponseDto {
  final int count;
  final List<GroupedDeckItem> data;

  GroupedDecksResponseDto({required this.count, required this.data});

  factory GroupedDecksResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      return GroupedDecksResponseDto(count: 0, data: []);
    }
    final deckList = data['data'] as List<dynamic>? ?? [];
    return GroupedDecksResponseDto(
      count: data['count'] as int? ?? 0,
      data:
          deckList
              .map(
                (item) =>
                    GroupedDeckItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  String toString() => 'GroupedDecksResponseDto(count: $count, data: $data)';
}

class GroupedDeckItem {
  final TagDto tag;
  final List<GetDeckDto> decks;

  GroupedDeckItem({required this.tag, required this.decks});

  factory GroupedDeckItem.fromJson(Map<String, dynamic> json) {
    return GroupedDeckItem(
      tag: TagDto.fromJson(json['tag']),
      decks:
          (json['decks'] as List<dynamic>? ?? [])
              .map((deck) => GetDeckDto.fromJson(deck))
              .toList(),
    );
  }
}

class TagDto {
  final String id;
  final String name;
  final String description;

  TagDto({required this.id, required this.name, required this.description});

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
