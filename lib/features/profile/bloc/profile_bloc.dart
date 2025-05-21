import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/profile/data/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lacquer/features/profile/bloc/profile_event.dart';
import 'package:lacquer/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProfileLoadFailure('Not authenticated'));
        return;
      }

      final profile = await _profileRepository.getProfile();
      emit(
        ProfileLoadSuccess(
          username: profile.username,
          email: profile.email,
          avatarUrl: profile.avatarUrl,
        ),
      );
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProfileUpdateFailure('Not authenticated'));
        return;
      }

      // Handle avatar upload first if present
      String? newAvatarUrl;
      if (event.avatarFile != null) {
        newAvatarUrl = await _profileRepository.uploadAvatar(
          token,
          event.avatarFile!,
        );
      }

      // Handle profile update
      final updatedProfile = await _profileRepository.updateProfile(
        token,
        username: event.username,
        password: event.password,
      );

      emit(
        ProfileUpdateSuccess(
          username: event.username ?? updatedProfile.username,
          email: updatedProfile.email,
          avatarUrl: newAvatarUrl ?? updatedProfile.avatarUrl,
        ),
      );
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
    }
  }
}
