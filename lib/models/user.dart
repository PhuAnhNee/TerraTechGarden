import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? userId;
  final String username;
  final String passwordHash;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String dateOfBirth;
  final String gender;

  const User({
    this.userId,
    required this.username,
    required this.passwordHash,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int?,
      username: json['username'] as String,
      passwordHash: json['passwordHash'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'passwordHash': passwordHash,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        passwordHash,
        email,
        phoneNumber,
        fullName,
        dateOfBirth,
        gender,
      ];
}
