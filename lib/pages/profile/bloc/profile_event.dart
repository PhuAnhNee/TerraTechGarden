import 'package:equatable/equatable.dart';
import '../../../models/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final User user;

  const UpdateProfileEvent({required this.user});

  @override
  List<Object> get props => [user];
}
