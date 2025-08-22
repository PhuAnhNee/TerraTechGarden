// lib/pages/notification/bloc/notification_event.dart
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class StartNotificationPolling extends NotificationEvent {
  final String userId;
  const StartNotificationPolling(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StopNotificationPolling extends NotificationEvent {}

class FetchNotifications extends NotificationEvent {
  final String userId;
  const FetchNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;
  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;
  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class CreateNotification extends NotificationEvent {
  final String userId;
  final String title;
  final String message;

  const CreateNotification({
    required this.userId,
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, title, message];
}

class ShowInAppNotification extends NotificationEvent {
  final String title;
  final String message;

  const ShowInAppNotification({
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [title, message];
}
