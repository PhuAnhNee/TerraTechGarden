import 'package:equatable/equatable.dart';
import '../../../models/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final User user;

  const RegisterRequested({required this.user});

  @override
  List<Object?> get props => [user];
}
