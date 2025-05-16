import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/message.dart';

class ChatService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    final db = await _dbService.database;
    final message = Message(
      id: Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getConversation(String userId1, String userId2) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentConversations(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT 
        CASE 
          WHEN senderId = ? THEN receiverId 
          ELSE senderId 
        END as contactId,
        u.name as contactName,
        (SELECT content FROM messages m2 
         WHERE (m2.senderId = m.senderId AND m2.receiverId = m.receiverId) 
            OR (m2.senderId = m.receiverId AND m2.receiverId = m.senderId)
         ORDER BY m2.createdAt DESC LIMIT 1) as lastMessage
      FROM messages m
      JOIN users u ON u.id = CASE WHEN senderId = ? THEN receiverId ELSE senderId END
      WHERE senderId = ? OR receiverId = ?
      ORDER BY (SELECT MAX(createdAt) FROM messages m2 
                WHERE (m2.senderId = m.senderId AND m2.receiverId = m.receiverId) 
                   OR (m2_demandeurId = m.receiverId AND m2.senderId = m.senderId)) DESC
    ''', [userId, userId, userId, userId]);
    return maps;
  }
}