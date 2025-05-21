sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoadInProgress extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final String username;
  final String email;
  final String avatarUrl;

  ProfileLoadSuccess({
    required this.username,
    required this.email,
    required this.avatarUrl,
  });
}

class ProfileLoadFailure extends ProfileState {
  final String error;

  ProfileLoadFailure(this.error);
}

class ProfileUpdateInProgress extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String username;
  final String email;
  final String avatarUrl;

  ProfileUpdateSuccess({
    required this.username,
    required this.email,
    required this.avatarUrl,
  });
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  ProfileUpdateFailure(this.error);
}
