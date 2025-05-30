class CardDto {
  final String? id;
  final String? word;
  final String? pronunciation;
  final CardMeaningDto? meaning;
  final String? description;

  CardDto({
    this.id,
    this.word,
    this.pronunciation,
    this.meaning,
    this.description,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['_id'] as String?,
      word: json['word'] as String?,
      pronunciation: json['pronunciation'] as String?,
      meaning:
          json['meaning'] != null
              ? CardMeaningDto.fromJson(json['meaning'] as Map<String, dynamic>)
              : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning?.toJson(),
      'description': description,
    };
  }
}

class CardMeaningDto {
  final String? type;
  final String? definition;

  CardMeaningDto({this.type, this.definition});

  factory CardMeaningDto.fromJson(Map<String, dynamic> json) {
    return CardMeaningDto(
      type: json['type'] as String?,
      definition: json['definition'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'definition': definition};
  }
}
