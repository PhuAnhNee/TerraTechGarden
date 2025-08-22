// lib/models/notification.dart
import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String message;
  final bool isRead;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
    };
  }

  @override
  List<Object?> get props => [id, userId, title, message, isRead];
}
