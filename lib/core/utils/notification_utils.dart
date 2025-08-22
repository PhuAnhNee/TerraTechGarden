import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pages/notification/bloc/notification_bloc.dart';
import '../../pages/notification/bloc/notification_event.dart';
import 'firebase_messaging_setup.dart';

class NotificationUtils {
  static Future<void> initializeNotifications(BuildContext context) async {
    try {
      await setupFirebaseMessaging(context);
      final userId = getCurrentUserIdFromContext(context);
      if (userId != null) {
        context.read<NotificationBloc>().add(StartNotificationPolling(userId));
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1D7020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
