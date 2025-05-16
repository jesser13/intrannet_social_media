import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ChatService {
  final DatabaseService _databaseService = DatabaseService();

  // Send a message to a user
  Future<Message> sendUserMessage({
    required int senderId,
    required int receiverId,
    required String content,
    List<String>? attachments,
  }) async {
    final db = await _databaseService.database;
    
    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      isGroupMessage: false,
      content: content,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
    
    final id = await db.insert('messages', message.toMap());
    
    return message.copyWith(id: id);
  }

  // Send a message to a group
  Future<Message> sendGroupMessage({
    required int senderId,
    required int groupId,
    required String content,
    List<String>? attachments,
  }) async {
    final db = await _databaseService.database;
    
    // Check if sender is a member of the group
    final memberResults = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, senderId],
    );
    
    if (memberResults.isEmpty) {
      throw Exception('You are not a member of this group');
    }
    
    final message = Message(
      senderId: senderId,
      receiverId: groupId,
      isGroupMessage: true,
      content: content,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
    
    final id = await db.insert('messages', message.toMap());
    
    return message.copyWith(id: id);
  }

  // Get user-to-user conversation
  Future<List<Message>> getUserConversation({
    required int userId1,
    required int userId2,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    
    final results = await db.rawQuery('''
      SELECT * FROM messages
      WHERE isGroupMessage = 0
      AND ((senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?))
      ORDER BY createdAt DESC
      LIMIT ? OFFSET ?
    ''', [userId1, userId2, userId2, userId1, limit, offset]);
    
    return results.map((map) => Message.fromMap(map)).toList();
  }

  // Get group conversation
  Future<List<Message>> getGroupConversation({
    required int groupId,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    
    final results = await db.query(
      'messages',
      where: 'isGroupMessage = 1 AND receiverId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((map) => Message.fromMap(map)).toList();
  }

  // Get user's conversations list (preview of last message with each contact)
  Future<List<Map<String, dynamic>>> getUserConversationsList(int userId) async {
    final db = await _databaseService.database;
    
    // Get direct messages
    final directResults = await db.rawQuery('''
      WITH LastMessages AS (
        SELECT 
          m.*,
          ROW_NUMBER() OVER (
            PARTITION BY 
              CASE 
                WHEN senderId = ? THEN receiverId 
                ELSE senderId 
              END
            ORDER BY createdAt DESC
          ) as rn
        FROM messages m
        WHERE isGroupMessage = 0
        AND (senderId = ? OR receiverId = ?)
      )
      SELECT * FROM LastMessages
      WHERE rn = 1
      ORDER BY createdAt DESC
    ''', [userId, userId, userId]);
    
    final directMessages = directResults.map((map) => Message.fromMap(map)).toList();
    
    // Get user info for each conversation
    List<Map<String, dynamic>> conversations = [];
    
    for (var message in directMessages) {
      final otherUserId = message.senderId == userId 
          ? message.receiverId 
          : message.senderId;
      
      final userResults = await db.query(
        'users',
        columns: ['id', 'username', 'name', 'profilePicture'],
        where: 'id = ?',
        whereArgs: [otherUserId],
      );
      
      if (userResults.isNotEmpty) {
        conversations.add({
          'message': message,
          'user': userResults.first,
          'isGroup': false,
        });
      }
    }
    
    // Get group conversations
    final groupIds = await db.rawQuery('''
      SELECT groupId FROM group_members
      WHERE userId = ?
    ''', [userId]);
    
    for (var groupIdMap in groupIds) {
      final groupId = groupIdMap['groupId'] as int;
      
      final groupResults = await db.query(
        'groups',
        columns: ['id', 'name', 'image'],
        where: 'id = ?',
        whereArgs: [groupId],
      );
      
      if (groupResults.isEmpty) continue;
      
      final messageResults = await db.query(
        'messages',
        where: 'isGroupMessage = 1 AND receiverId = ?',
        whereArgs: [groupId],
        orderBy: 'createdAt DESC',
        limit: 1,
      );
      
      if (messageResults.isNotEmpty) {
        conversations.add({
          'message': Message.fromMap(messageResults.first),
          'group': groupResults.first,
          'isGroup': true,
        });
      }
    }
    
    // Sort by most recent message
    conversations.sort((a, b) {
      final aMessage = a['message'] as Message;
      final bMessage = b['message'] as Message;
      return bMessage.createdAt.compareTo(aMessage.createdAt);
    });
    
    return conversations;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required int userId,
    required int senderId,
    bool isGroup = false,
  }) async {
    final db = await _databaseService.database;
    
    if (isGroup) {
      // Mark group messages as read
      await db.update(
        'messages',
        {'isRead': 1},
        where: 'isGroupMessage = 1 AND receiverId = ? AND senderId != ? AND isRead = 0',
        whereArgs: [senderId, userId],
      );
    } else {
      // Mark direct messages as read
      await db.update(
        'messages',
        {'isRead': 1},
        where: 'isGroupMessage = 0 AND senderId = ? AND receiverId = ? AND isRead = 0',
        whereArgs: [senderId, userId],
      );
    }
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(int userId) async {
    final db = await _databaseService.database;
    
    // Count direct unread messages
    final directResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM messages
      WHERE isGroupMessage = 0 AND receiverId = ? AND isRead = 0
    ''', [userId]);
    
    final directCount = directResult.isNotEmpty ? 
        (directResult.first['count'] as int? ?? 0) : 0;
    
    // Count group unread messages
    final groupIds = await db.rawQuery('''
      SELECT groupId FROM group_members
      WHERE userId = ?
    ''', [userId]);
    
    int groupCount = 0;
    
    for (var groupIdMap in groupIds) {
      final groupId = groupIdMap['groupId'] as int;
      
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM messages
        WHERE isGroupMessage = 1 AND receiverId = ? AND senderId != ? AND isRead = 0
      ''', [groupId, userId]);
      
      groupCount += result.isNotEmpty ? 
          (result.first['count'] as int? ?? 0) : 0;
    }
    
    return directCount + groupCount;
  }
}
