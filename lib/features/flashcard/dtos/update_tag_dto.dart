class UpdateTagDto {
  final String id;
  final String name;
  final String? description;

  UpdateTagDto({required this.id, required this.name, this.description});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
  };
}
