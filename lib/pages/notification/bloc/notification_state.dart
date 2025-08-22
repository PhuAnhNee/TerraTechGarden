// lib/pages/notification/bloc/notification_state.dart
import 'package:equatable/equatable.dart';
import '../../../models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  // Alternative constructor that calculates unreadCount automatically
  NotificationLoaded.fromNotifications(List<NotificationModel> notifications)
      : notifications = notifications,
        unreadCount = notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications, unreadCount];

  // Add copyWith method for easier state updates
  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationCreated extends NotificationState {
  final NotificationModel notification;
  const NotificationCreated(this.notification);

  @override
  List<Object?> get props => [notification];
}

class InAppNotificationShown extends NotificationState {
  final String title;
  final String message;

  const InAppNotificationShown({
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [title, message];
}
