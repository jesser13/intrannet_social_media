import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/group.dart';
import '../models/post.dart';

class GroupService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createGroup(String name, String creatorId, bool isPrivate) async {
    final db = await _dbService.database;
    final group = Group(
      id: Uuid().v4(),
      name: name,
      isPrivate: isPrivate,
      creatorId: creatorId,
    );
    await db.insert('groups', group.toMap());
    await joinGroup(group.id, creatorId);
  }

  Future<void> joinGroup(String groupId, String userId) async {
    final db = await _dbService.database;
    await db.insert('group_members', {
      'groupId': groupId,
      'userId': userId,
    });
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
  }

  Future<List<Group>> getUserGroups(String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.* FROM groups g
      INNER JOIN group_members gm ON g.id = gm.groupId
      WHERE gm.userId = ?
    ''', [userId]);
    return maps.map((map) => Group.fromMap(map)).toList();
  }

  Future<List<Post>> getGroupPosts(String groupId, {int page = 1, int limit = 10}) async {
    final db = await _dbService.database;
    final offset = (page - 1) * limit;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Post.fromMap(map)).toList();
  }

  Future<bool> isGroupMember(String groupId, String userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
    return result.isNotEmpty;
  }
}