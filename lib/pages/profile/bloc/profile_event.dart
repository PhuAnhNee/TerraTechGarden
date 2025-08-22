import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../../models/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final String token;

  const LoadProfileEvent({required this.token});

  @override
  List<Object> get props => [token];
}

class UpdateProfileEvent extends ProfileEvent {
  final User user;
  final String token;

  const UpdateProfileEvent({required this.user, required this.token});

  @override
  List<Object> get props => [user, token];
}

class UpdateAvatarEvent extends ProfileEvent {
  final File avatarFile;
  final String token;

  const UpdateAvatarEvent({required this.avatarFile, required this.token});

  @override
  List<Object> get props => [avatarFile, token];
}

class UpdateBackgroundEvent extends ProfileEvent {
  final File backgroundFile;
  final String token;

  const UpdateBackgroundEvent(
      {required this.backgroundFile, required this.token});

  @override
  List<Object> get props => [backgroundFile, token];
}
