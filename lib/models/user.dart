class User {
  final int userId;
  final String username;
  final String passwordHash;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String? avatarUrl;
  final String? backgroundUrl;

  const User({
    this.userId = 0, // Default value for registration
    required this.username,
    required this.passwordHash,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
    this.backgroundUrl,
  });

  // Constructor specifically for registration (without userId, avatarUrl, backgroundUrl)
  const User.forRegistration({
    required this.username,
    required this.passwordHash,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
  })  : userId = 0,
        avatarUrl = null,
        backgroundUrl = null;

  User copyWith({
    int? userId,
    String? username,
    String? passwordHash,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? avatarUrl,
    String? backgroundUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
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
      'avatarUrl': avatarUrl,
      'backgroundUrl': backgroundUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      avatarUrl: json['avatarUrl'],
      backgroundUrl: json['backgroundUrl'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          username == other.username &&
          passwordHash == other.passwordHash &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          fullName == other.fullName &&
          dateOfBirth == other.dateOfBirth &&
          gender == other.gender &&
          avatarUrl == other.avatarUrl &&
          backgroundUrl == other.backgroundUrl;

  @override
  int get hashCode =>
      userId.hashCode ^
      username.hashCode ^
      passwordHash.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      fullName.hashCode ^
      dateOfBirth.hashCode ^
      gender.hashCode ^
      avatarUrl.hashCode ^
      backgroundUrl.hashCode;
}
