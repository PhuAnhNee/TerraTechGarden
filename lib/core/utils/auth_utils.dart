import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../pages/notification/services/notification_service.dart';

Future<String?> getStoredToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

Future<String?> getStoredUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<void> saveFcmToken(String userId) async {
  try {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await NotificationService.saveFcmToken(
        userId: userId,
        fcmToken: fcmToken,
      );
      print('FCM token saved for user $userId: $fcmToken');
    }
  } catch (e) {
    print('Error saving FCM token: $e');
  }
}

String? extractUserIdFromRole(String? role) {
  if (role != null && role.contains('_')) {
    return role.split('_').last;
  }
  return role;
}
