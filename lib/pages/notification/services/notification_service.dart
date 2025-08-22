// lib/services/notification_service.dart
import 'package:dio/dio.dart';
import '../../../api/terra_api.dart';
import '../../../models/notification_model.dart';

class NotificationService {
  static final Dio _dio = Dio();

  // Get all notifications
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _dio.get(TerraApi.getAllNotifications());
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Get notifications by user ID
  static Future<List<NotificationModel>> getNotificationsByUserId(
      String userId) async {
    try {
      final response =
          await _dio.get(TerraApi.getNotificationsByUserId(userId));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user notifications: $e');
    }
  }

  // Get notification by ID
  static Future<NotificationModel?> getNotificationById(int id) async {
    try {
      final response =
          await _dio.get(TerraApi.getNotificationById(id.toString()));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return NotificationModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  // Create notification
  static Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        TerraApi.createNotification(),
        data: {
          'userId': int.tryParse(userId) ?? 0,
          'title': title,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return NotificationModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create notification');
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _dio.put(
        TerraApi.markNotificationAsRead(notificationId.toString()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _dio.delete(
        TerraApi.deleteNotification(notificationId.toString()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Save FCM Token
  static Future<bool> saveFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        TerraApi.saveFcmToken(),
        data: {
          'userId': userId,
          'fcmToken': fcmToken,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  // Delete FCM Token
  static Future<bool> deleteFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.delete(
        TerraApi.deleteFcmToken(userId, fcmToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete FCM token: $e');
    }
  }
}
