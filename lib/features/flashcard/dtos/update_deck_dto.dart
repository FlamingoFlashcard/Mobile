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

    return UpdateDeckDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: parsedTags,
    );
  }
}
