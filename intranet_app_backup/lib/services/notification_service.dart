import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/notification.dart';

class NotificationService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createNotification({
    required String userId,
    required String content,
    required String type,
    required String relatedId,
  }) async {
    final db = await _dbService.database;
    final notification = AppNotification(
      id: Uuid().v4(),
      userId: userId,
      content: content,
      type: type,
      relatedId: relatedId,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
    );
    await db.insert('notifications', notification.toMap());
  }

  Future<List<AppNotification>> getNotifications(String userId, {int page = 1, int limit = 10}) async {
    final db = await _dbService.database;
    final offset = (page - 1) * limit;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => AppNotification.fromMap(map)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final db = await _dbService.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<int> getUnreadCount(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.query(
      'notifications',
      where: 'userId = ? AND isRead = ?',
      whereArgs: [userId, 0],
    );
    return result.length;
  }
}