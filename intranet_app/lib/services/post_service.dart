import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createPost(String userId, String content, {String? imagePath, String? filePath, String? groupId}) async {
    final db = await _dbService.database;
    final post = Post(
      id: Uuid().v4(),
      userId: userId,
      content: content,
      imagePath: imagePath,
      filePath: filePath,
      groupId: groupId,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getFeed(String userId, {int page = 1, int limit = 10}) async {
    final db = await _dbService.database;
    final offset = (page - 1) * limit;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM posts p
      LEFT JOIN group_members gm ON p.groupId = gm.groupId
      WHERE p.groupId IS NULL OR gm.userId = ?
      ORDER BY p.createdAt DESC
      LIMIT ? OFFSET ?
    ''', [userId, limit, offset]);
    return maps.map((map) => Post.fromMap(map)).toList();
  }

  Future<void> likePost(String postId, String userId) async {
    final db = await _dbService.database;
    await db.insert('likes', {
      'id': Uuid().v4(),
      'postId': postId,
      'userId': userId,
    });
  }

  Future<void> addComment(String postId, String userId, String content) async {
    final db = await _dbService.database;
    final comment = Comment(
      id: Uuid().v4(),
      postId: postId,
      userId: userId,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('comments', comment.toMap());
  }

  Future<List<Comment>> getComments(String postId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Comment.fromMap(map)).toList();
  }

  Future<void> deletePost(String postId) async {
    final db = await _dbService.database;
    await db.delete('posts', where: 'id = ?', whereArgs: [postId]);
    await db.delete('comments', where: 'postId = ?', whereArgs: [postId]);
    await db.delete('likes', where: 'postId = ?', whereArgs: [postId]);
  }
}