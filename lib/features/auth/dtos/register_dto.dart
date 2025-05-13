class RegisterDto {
  final String username;
  final String email;
  final String password;
  final String authProvider;

  RegisterDto({
    required this.username,
    required this.email,
    required this.password,
    required this.authProvider,
  });
}
