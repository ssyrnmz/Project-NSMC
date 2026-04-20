import 'package:flutter/material.dart';

import '../../domain/app_notification.dart';
import '../../data/notification_repository.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../utils/data/results.dart';

class NotificationViewModel extends ChangeNotifier {
  //▫️Constructor:
  NotificationViewModel({
    required NotificationRepository notificationRepository,
    required AccountSession accountSession,
  }) : _repository = notificationRepository,
       _accountSession = accountSession;

  //▫️Variables:
  final NotificationRepository _repository;
  final AccountSession _accountSession;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  //▫️Getters:
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  //▫️Functions:
  Future<void> load() async {
    final session = _accountSession.session;

    // Support both user and admin
    final String userId;
    if (session is UserSession) {
      userId = session.userAccount.id;
    } else if (session is AdminSession) {
      userId = session.adminAccount.id;
    } else {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getNotifications(userId);

      switch (result) {
        case Ok<List<AppNotification>>():
          _notifications = result.value;
          debugPrint('[Notification] Loaded ${_notifications.length} notifications');
        case Error<List<AppNotification>>():
          debugPrint('[Notification] Load failed: ${result.error}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(AppNotification notif) async {
    final session = _accountSession.session;
    final String? userId = session is UserSession
        ? session.userAccount.id
        : session is AdminSession
            ? session.adminAccount.id
            : null;
    if (userId == null) return;

    final index = _notifications.indexWhere((n) => n.id == notif.id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = AppNotification(
        id: notif.id,
        userId: notif.userId,
        type: notif.type,
        title: notif.title,
        message: notif.message,
        isRead: true,
        isDismissed: notif.isDismissed,
        referenceId: notif.referenceId,
        createdAt: notif.createdAt,
      );
      notifyListeners();
    }

    await _repository.markRead(userId, notif.id);
  }

  Future<void> dismiss(AppNotification notif) async {
    final session = _accountSession.session;
    final String? userId = session is UserSession
        ? session.userAccount.id
        : session is AdminSession
            ? session.adminAccount.id
            : null;
    if (userId == null) return;

    _notifications.removeWhere((n) => n.id == notif.id);
    notifyListeners();

    await _repository.dismiss(userId, notif.id);
  }

  Future<void> dismissAll() async {
    final session = _accountSession.session;
    final String? userId = session is UserSession
        ? session.userAccount.id
        : session is AdminSession
            ? session.adminAccount.id
            : null;
    if (userId == null) return;

    _notifications.clear();
    notifyListeners();

    await _repository.dismissAll(userId);
  }
}