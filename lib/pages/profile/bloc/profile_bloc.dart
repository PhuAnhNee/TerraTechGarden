import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../api/terra_api.dart';
import '../../../models/user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Dio _dio = Dio();

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<UpdateBackgroundEvent>(_onUpdateBackground);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await _dio.get(
        TerraApi.getMyProfile(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        final profileData = response.data['data'];

        // Normalize gender value
        String apiGender = profileData['gender'] ?? '';
        String normalizedGender = apiGender.isEmpty
            ? ''
            : apiGender.toLowerCase() == 'male'
                ? 'Male'
                : apiGender.toLowerCase() == 'female'
                    ? 'Female'
                    : apiGender.toLowerCase() == 'other'
                        ? 'Other'
                        : '';

        final user = User(
          userId: 0,
          username: '',
          passwordHash: '',
          email: profileData['email'] ?? '',
          phoneNumber: profileData['phoneNumber'] ?? '',
          fullName: profileData['fullName'] ?? '',
          dateOfBirth: _formatDateOfBirth(profileData['dateOfBirth']),
          gender: normalizedGender,
          avatarUrl: profileData['avatarUrl'],
          backgroundUrl: profileData['backgroundUrl'],
        );

        emit(ProfileLoaded(user: user));
      } else {
        emit(ProfileError(
            'Failed to load profile: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ProfileError('Unauthorized. Please login again.'));
        } else {
          emit(ProfileError('Network error: ${e.message}'));
        }
      } else {
        emit(ProfileError('Failed to load profile: $e'));
      }
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final requestData = {
        "fullName": event.user.fullName,
        "gender": event.user.gender,
        "phoneNumber": event.user.phoneNumber,
        "dateOfBirth": _formatDateOfBirthForApi(event.user.dateOfBirth),
        "email": event.user.email,
      };

      final response = await _dio.put(
        TerraApi.updateMyProfile(),
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        // After successful update, reload the profile to get latest data
        add(LoadProfileEvent(token: event.token));
      } else {
        emit(ProfileError(
            'Failed to update profile: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ProfileError('Unauthorized. Please login again.'));
        } else if (e.response?.statusCode == 400) {
          emit(ProfileError('Invalid data. Please check your input.'));
        } else {
          emit(ProfileError('Network error: ${e.message}'));
        }
      } else {
        emit(ProfileError('Failed to update profile: $e'));
      }
    }
  }

  Future<void> _onUpdateAvatar(
      UpdateAvatarEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      String fileName = event.avatarFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "File": await MultipartFile.fromFile(
          event.avatarFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        TerraApi.uploadProfileAvatar(),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        // After successful avatar update, reload the profile
        add(LoadProfileEvent(token: event.token));
      } else {
        emit(ProfileError(
            'Failed to update avatar: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ProfileError('Unauthorized. Please login again.'));
        } else {
          emit(ProfileError('Failed to upload avatar: ${e.message}'));
        }
      } else {
        emit(ProfileError('Failed to update avatar: $e'));
      }
    }
  }

  Future<void> _onUpdateBackground(
      UpdateBackgroundEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      String fileName = event.backgroundFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "File": await MultipartFile.fromFile(
          event.backgroundFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        TerraApi.uploadProfileBackground(),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${event.token}',
            'accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        // After successful background update, reload the profile
        add(LoadProfileEvent(token: event.token));
      } else {
        emit(ProfileError(
            'Failed to update background: ${response.data['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(ProfileError('Unauthorized. Please login again.'));
        } else {
          emit(ProfileError('Failed to upload background: ${e.message}'));
        }
      } else {
        emit(ProfileError('Failed to update background: $e'));
      }
    }
  }

  String _formatDateOfBirth(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateOfBirthForApi(String dateString) {
    if (dateString.isEmpty) return DateTime.now().toIso8601String();

    try {
      // Convert from dd/MM/yyyy to ISO 8601 format
      List<String> parts = dateString.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        DateTime date = DateTime(year, month, day);
        return date.toIso8601String();
      }
    } catch (e) {
      // If parsing fails, return current date
      return DateTime.now().toIso8601String();
    }

    return DateTime.now().toIso8601String();
  }
}
