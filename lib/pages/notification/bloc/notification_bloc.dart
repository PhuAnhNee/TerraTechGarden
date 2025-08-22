// lib/pages/notification/bloc/notification_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../notification/services/notification_service.dart';
import '../../../models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  Timer? _pollingTimer;
  final Duration pollingInterval = const Duration(seconds: 30);
  String? _currentUserId;
  List<NotificationModel> _lastNotifications = [];

  NotificationBloc() : super(NotificationInitial()) {
    on<StartNotificationPolling>(_onStartPolling);
    on<StopNotificationPolling>(_onStopPolling);
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<CreateNotification>(_onCreateNotification);
    on<ShowInAppNotification>(_onShowInAppNotification);
  }

  Future<void> _onStartPolling(
      StartNotificationPolling event, Emitter<NotificationState> emit) async {
    _currentUserId = event.userId;
    _pollingTimer?.cancel();

    // Fetch immediately
    add(FetchNotifications(event.userId));

    // Then start polling
    _pollingTimer = Timer.periodic(pollingInterval, (timer) {
      add(FetchNotifications(event.userId));
    });
  }

  void _onStopPolling(
      StopNotificationPolling event, Emitter<NotificationState> emit) {
    _pollingTimer?.cancel();
    _currentUserId = null;
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event, Emitter<NotificationState> emit) async {
    try {
      final notifications =
          await NotificationService.getNotificationsByUserId(event.userId);
      final unreadCount = notifications.where((n) => !n.isRead).length;

      // Check for new notifications to show in-app notification
      if (_lastNotifications.isNotEmpty) {
        final newNotifications = notifications
            .where((n) => !_lastNotifications.any((old) => old.id == n.id))
            .toList();

        for (final newNotif in newNotifications) {
          add(ShowInAppNotification(
            title: newNotif.title,
            message: newNotif.message,
          ));
        }
      }

      _lastNotifications = notifications;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError('Không thể tải thông báo: ${e.toString()}'));
    }
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      await NotificationService.markAsRead(event.notificationId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(
          'Không thể đánh dấu thông báo đã đọc: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNotification(
      DeleteNotification event, Emitter<NotificationState> emit) async {
    try {
      await NotificationService.deleteNotification(event.notificationId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError('Không thể xóa thông báo: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNotification(
      CreateNotification event, Emitter<NotificationState> emit) async {
    try {
      final notification = await NotificationService.createNotification(
        userId: event.userId,
        title: event.title,
        message: event.message,
      );

      emit(NotificationCreated(notification));

      // Refresh notifications after creating
      if (_currentUserId != null) {
        add(FetchNotifications(_currentUserId!));
      }
    } catch (e) {
      emit(NotificationError('Không thể tạo thông báo: ${e.toString()}'));
    }
  }

  void _onShowInAppNotification(
      ShowInAppNotification event, Emitter<NotificationState> emit) {
    emit(InAppNotificationShown(
      title: event.title,
      message: event.message,
    ));
  }

  // Helper methods
  void startPolling(String userId) {
    add(StartNotificationPolling(userId));
  }

  void stopPolling() {
    add(StopNotificationPolling());
  }

  void fetchNotifications(String userId) {
    add(FetchNotifications(userId));
  }

  void markAsRead(int notificationId) {
    add(MarkNotificationAsRead(notificationId));
  }

  void deleteNotification(int notificationId) {
    add(DeleteNotification(notificationId));
  }

  void createNotification(String userId, String title, String message) {
    add(CreateNotification(userId: userId, title: title, message: message));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
