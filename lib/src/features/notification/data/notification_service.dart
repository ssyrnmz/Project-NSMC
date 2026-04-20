import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../domain/app_notification.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class NotificationService {
  NotificationService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _path = 'notification/';

  // Fetch all non-dismissed notifications for a user
  Future<Result<List<AppNotification>>> getNotifications(
      String userId) async {
    try {
      final response = await _apiClient.get(
        '${_path}get_notifications.php?user_id=$userId',
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final notifications = parsed
            .map((e) => AppNotification.fromJson(e))
            .toList();
        return Result.ok(notifications);
      } else {
        return Result.error(
          Exception('Failed to load notifications: ${response.body}'),
        );
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // Mark a single notification as read
  Future<void> markRead(String userId, int notifId) async {
    try {
      await _apiClient.post(
        '${_path}update_notification.php',
        auth: AuthType.required,
        body: {
          'action': 'read',
          'notif_id': notifId.toString(),
          'user_id': userId,
        },
      );
    } catch (e) {
      debugPrint('[Notification] markRead failed (non-critical): $e');
    }
  }

  // Dismiss a single notification
  Future<void> dismiss(String userId, int notifId) async {
    try {
      await _apiClient.post(
        '${_path}update_notification.php',
        auth: AuthType.required,
        body: {
          'action': 'dismiss',
          'notif_id': notifId.toString(),
          'user_id': userId,
        },
      );
    } catch (e) {
      debugPrint('[Notification] dismiss failed (non-critical): $e');
    }
  }

  // Dismiss all notifications for a user
  Future<void> dismissAll(String userId) async {
    try {
      await _apiClient.post(
        '${_path}update_notification.php',
        auth: AuthType.required,
        body: {
          'action': 'dismiss_all',
          'user_id': userId,
        },
      );
    } catch (e) {
      debugPrint('[Notification] dismissAll failed (non-critical): $e');
    }
  }
}
