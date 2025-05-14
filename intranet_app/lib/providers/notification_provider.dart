import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications(String userId, {int page = 1}) async {
    _notifications = await _notificationService.getNotifications(userId, page: page);
    _unreadCount = await _notificationService.getUnreadCount(userId);
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    // Assuming userId is available; in practice, pass it
    await fetchNotifications(_notifications.isNotEmpty ? _notifications.first.userId : '');
  }

  Future<void> createNotification({
    required String userId,
    required String content,
    required String type,
    required String relatedId,
  }) async {
    await _notificationService.createNotification(
      userId: userId,
      content: content,
      type: type,
      relatedId: relatedId,
    );
    await fetchNotifications(userId);
  }
}