import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? username;
  final String? password;
  final File? avatarFile;

  const ProfileUpdateRequested({this.username, this.password, this.avatarFile});
}

class ProfileDeleteRequested extends ProfileEvent {}
