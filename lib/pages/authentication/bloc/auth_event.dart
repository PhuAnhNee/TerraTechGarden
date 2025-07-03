import 'package:equatable/equatable.dart';
import '../../../models/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username; // Changed from email to username
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final User user;

  const RegisterRequested({required this.user});

  @override
  List<Object?> get props => [user];
}
