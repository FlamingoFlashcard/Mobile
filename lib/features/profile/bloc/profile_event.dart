import 'dart:io';

class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? username;
  final String? password;
  final File? avatarFile;

  ProfileUpdateRequested({this.username, this.password, this.avatarFile});
}

class ProfileDeleteRequested extends ProfileEvent {}
