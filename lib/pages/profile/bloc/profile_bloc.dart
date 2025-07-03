import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../api/terra_api.dart'; // Adjust the import path as needed
import '../../../models/user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // TODO: Replace with actual API call to TerraApi.getUserProfile()
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      final user = User(
        userId: 1,
        username: 'johndoe',
        passwordHash: 'hashedpassword123',
        email: 'john.doe@example.com',
        phoneNumber: '+84123456789',
        fullName: 'John Doe',
        dateOfBirth: '1990-01-01',
        gender: 'Male',
      );
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // TODO: Replace with actual API call to TerraApi.updateAccount()
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      emit(ProfileLoaded(user: event.user));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }
}
