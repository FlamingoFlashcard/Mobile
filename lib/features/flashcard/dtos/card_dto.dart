class CardDto {
  final String? id;
  final String? word;
  final List<String>? pronunciations;
  final List<String>? img;
  final List<String>? meanings;
  final String? description;

  CardDto({
    this.id,
    this.word,
    this.pronunciations,
    this.img,
    this.meanings,
    this.description,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['_id'] as String?,
      word: json['word'] as String?,
      pronunciations: (json['pronunciations'] as List?)?.cast<String>(),
      img: (json['img'] as List?)?.cast<String>(),
      meanings: (json['meanings'] as List?)?.cast<String>(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'word': word,
      'pronunciations': pronunciations,
      'img': img,
      'meanings': meanings,
    };
  }
}
