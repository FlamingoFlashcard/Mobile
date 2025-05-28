class Profile {
  final String username;
  final String email;
  final String avatarUrl;
  final String about;

  Profile({
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.about,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'] ?? '',
      about: json['about'] ?? '',
    );
  }
}
