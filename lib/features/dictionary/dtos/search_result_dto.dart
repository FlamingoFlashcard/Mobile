class SearchWordResultDto {
  final bool success;
  final String message;
  final Vocabulary data;

  const SearchWordResultDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SearchWordResultDto.fromJson(Map<String, dynamic> json) {
    return SearchWordResultDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Vocabulary.fromJson(json['data'] ?? {}),
    );
  }
}

class SearchQueryResultDto {
  final bool success;
  final String message;
  final Data data;

  const SearchQueryResultDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SearchQueryResultDto.fromJson(Map<String, dynamic> json) {
    return SearchQueryResultDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? []),
    );
  }
}

class Data {
  final List<Vocabulary> vocabularies;

  Data({required this.vocabularies});

  factory Data.fromJson(List<dynamic> json) {
    return Data(
      vocabularies:
          json
              .map((e) => Vocabulary.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Vocabulary {
  final String id;
  final List<String> img;
  final String word;
  final String pronunciation;
  final List<WordType> wordTypes;
  final String difficulty;
  final List<Example> examples;

  const Vocabulary({
    required this.id,
    required this.img,
    required this.word,
    required this.pronunciation,
    required this.wordTypes,
    required this.difficulty,
    required this.examples,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['_id'] ?? '',
      img:
          (json['img'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      wordTypes:
          (json['wordTypes'] as List<dynamic>?)
              ?.map((e) => WordType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      difficulty: json['difficulty'] ?? '',
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((e) => Example.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WordType {
  final String type;
  final List<String> definitions;
  final List<Example> examples;

  const WordType({
    required this.type,
    required this.definitions,
    required this.examples,
  });

  factory WordType.fromJson(Map<String, dynamic> json) {
    return WordType(
      type: json['type'] ?? '',
      definitions:
          (json['definitions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((e) => Example.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Example {
  final String english;
  final String vietnamese;

  const Example({required this.english, required this.vietnamese});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      english: json['english'] ?? '',
      vietnamese: json['vietnamese'] ?? '',
    );
  }
}
