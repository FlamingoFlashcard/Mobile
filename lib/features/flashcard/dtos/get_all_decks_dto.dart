class GetAllDeckDto {
  final String id;
  final String title;
  final List<String> tags;

  GetAllDeckDto({required this.id, required this.title, required this.tags});

  factory GetAllDeckDto.fromJson(Map<String, dynamic> json) {
    return GetAllDeckDto(
      id: json['id'],
      title: json['title'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'tags': tags};
  }
}
