class UpdateDeckDto {
  final String id;
  final String title;
  final String description;
  final List<String> tags;

  UpdateDeckDto({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description, 'tags': tags};
  }

  factory UpdateDeckDto.fromJson(Map<String, dynamic> json) {
    return UpdateDeckDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
    );
  }
}
