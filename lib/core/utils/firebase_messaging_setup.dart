import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../navigation/routes.dart';
import '../utils/auth_utils.dart';
import '../../pages/notification/bloc/notification_bloc.dart';
import '../../pages/notification/bloc/notification_event.dart';
import '../../pages/authentication/bloc/auth_bloc.dart';
import '../../pages/notification/widgets/in_app_notification.dart';
import '../../pages/notification/services/notification_service.dart';

Future<void> setupFirebaseMessaging(BuildContext context) async {
  try {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
      final userId = getCurrentUserIdFromContext(context);
      if (userId != null) {
        await saveFcmToken(userId);
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification received: ${message.notification?.title}');
      if (message.notification != null && context.mounted) {
        InAppNotificationService.show(
          context,
          title: message.notification!.title ?? 'Thông báo',
          message: message.notification!.body ?? '',
          onTap: () {
            final userId = getCurrentUserIdFromContext(context);
            if (userId != null) {
              Navigator.pushNamed(
                context,
                Routes.notification,
                arguments: userId,
              );
            }
          },
        );
      }

      final userId = getCurrentUserIdFromContext(context);
      if (userId != null && context.mounted) {
        context.read<NotificationBloc>().add(FetchNotifications(userId));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Notification opened from background: ${message.notification?.title}');
      final userId = getCurrentUserIdFromContext(context);
      if (userId != null) {
        Navigator.pushNamed(
          context,
          Routes.notification,
          arguments: userId,
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App opened from terminated state via notification: ${initialMessage.notification?.title}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = getCurrentUserIdFromContext(context);
        if (userId != null) {
          Navigator.pushNamed(
            context,
            Routes.notification,
            arguments: userId,
          );
        }
      });
    }
  } catch (e) {
    print('Error setting up Firebase messaging: $e');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // await Firebase.initializeApp();
    print('Background notification: ${message.notification?.title}');
    // Do not access context or AuthBloc here; handle user-specific logic in foreground
  } catch (e) {
    print('Error handling background message: $e');
  }
}

String? getCurrentUserIdFromContext(BuildContext context) {
  try {
    final authState = context.read<AuthBloc>().state;
    // if (authState is AuthSuccess && authState.role != null) {
    //   return extractUserIdFromRole(authState.role);
    // }
  } catch (e) {
    print('Error getting current user ID: $e');
  }
  return null;
}
