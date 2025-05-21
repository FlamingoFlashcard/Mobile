class Profile {
  final String username;
  final String email;
  final String avatarUrl;

  Profile({
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'] ?? '',
    );
  }
}
