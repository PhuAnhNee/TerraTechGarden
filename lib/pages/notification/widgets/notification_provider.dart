// lib/pages/notification/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';
import '../widgets/in_app_notification.dart';

class NotificationProvider extends StatefulWidget {
  final Widget child;
  final String? userId;

  const NotificationProvider({
    super.key,
    required this.child,
    this.userId,
  });

  @override
  State<NotificationProvider> createState() => _NotificationProviderState();
}

class _NotificationProviderState extends State<NotificationProvider>
    with WidgetsBindingObserver {
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startNotificationServices();
    _setupHeartbeat();
  }

  @override
  void didUpdateWidget(NotificationProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _restartNotificationServices();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopNotificationServices();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startNotificationServices();
        break;
      case AppLifecycleState.paused:
        _stopNotificationServices();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _setupHeartbeat() {
    // Check connection and restart polling every 5 minutes if needed
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (widget.userId != null && mounted) {
        final bloc = context.read<NotificationBloc>();
        // Only restart if not currently polling
        if (bloc.state is! NotificationLoading) {
          bloc.fetchNotifications(widget.userId!);
        }
      }
    });
  }

  void _startNotificationServices() {
    if (widget.userId != null && mounted) {
      context.read<NotificationBloc>().startPolling(widget.userId!);
    }
  }

  void _stopNotificationServices() {
    if (mounted) {
      context.read<NotificationBloc>().stopPolling();
    }
  }

  void _restartNotificationServices() {
    _stopNotificationServices();
    _startNotificationServices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is InAppNotificationShown) {
          _showInAppNotification(state.title, state.message);
        }
      },
      child: widget.child,
    );
  }

  void _showInAppNotification(String title, String message) {
    if (!mounted) return;

    InAppNotificationService.show(
      context,
      title: title,
      message: message,
      onTap: () {
        // Navigate to notification screen when tapped
        if (widget.userId != null) {
          Navigator.pushNamed(
            context,
            '/notification',
            arguments: widget.userId,
          );
        }
      },
    );
  }
}

// Helper widget for notification badge
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final String? userId;

  const NotificationBadge({
    super.key,
    required this.child,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Stack(
          children: [
            child,
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Helper for getting notification status
class NotificationHelper {
  static int getUnreadCount(BuildContext context) {
    final state = context.read<NotificationBloc>().state;
    if (state is NotificationLoaded) {
      return state.unreadCount;
    }
    return 0;
  }

  static bool hasUnreadNotifications(BuildContext context) {
    return getUnreadCount(context) > 0;
  }

  static void refreshNotifications(BuildContext context, String userId) {
    context.read<NotificationBloc>().fetchNotifications(userId);
  }

  static void markAllAsRead(BuildContext context) {
    final bloc = context.read<NotificationBloc>();
    if (bloc.state is NotificationLoaded) {
      final notifications = (bloc.state as NotificationLoaded).notifications;
      for (final notification in notifications) {
        if (!notification.isRead) {
          bloc.markAsRead(notification.id);
        }
      }
    }
  }
}
