import '../domain/app_notification.dart';
import 'notification_service.dart';
import '../../../utils/data/results.dart';

class NotificationRepository {
  NotificationRepository({required NotificationService notificationService})
      : _service = notificationService;

  final NotificationService _service;

  Future<Result<List<AppNotification>>> getNotifications(
      String userId) async {
    return await _service.getNotifications(userId);
  }

  Future<void> markRead(String userId, int notifId) async {
    await _service.markRead(userId, notifId);
  }

  Future<void> dismiss(String userId, int notifId) async {
    await _service.dismiss(userId, notifId);
  }

  Future<void> dismissAll(String userId) async {
    await _service.dismissAll(userId);
  }
}
