import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoadInProgress extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final String username;
  final String email;
  final String avatarUrl;

  const ProfileLoadSuccess({
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  @override
  List<Object> get props => [username, email, avatarUrl];
}

class ProfileLoadFailure extends ProfileState {
  final String error;

  const ProfileLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ProfileUpdateInProgress extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String username;
  final String email;
  final String avatarUrl;

  const ProfileUpdateSuccess({
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  @override
  List<Object> get props => [username, email, avatarUrl];
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}
