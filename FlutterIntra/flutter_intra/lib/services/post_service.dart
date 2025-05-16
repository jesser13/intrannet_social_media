import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/database_service.dart';

class PostService {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new post
  Future<Post> createPost({
    required int userId,
    int? groupId,
    required String content,
    List<String>? attachments,
  }) async {
    final db = await _databaseService.database;
    
    final post = Post(
      userId: userId,
      groupId: groupId,
      content: content,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
    
    final id = await db.insert('posts', post.toMap());
    
    return post.copyWith(id: id);
  }

  // Get all public posts with pagination
  Future<List<Post>> getPublicPosts({
    int limit = 10,
    int offset = 0,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    final db = await _databaseService.database;
    
    final orderDirection = descending ? 'DESC' : 'ASC';
    
    final results = await db.query(
      'posts',
      where: 'groupId IS NULL',
      orderBy: '$sortBy $orderDirection',
      limit: limit,
      offset: offset,
    );
    
    return results.map((map) => Post.fromMap(map)).toList();
  }

  // Get posts for a specific group
  Future<List<Post>> getGroupPosts({
    required int groupId,
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    
    final results = await db.query(
      'posts',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((map) => Post.fromMap(map)).toList();
  }

  // Get posts for user feed (public + user's groups)
  Future<List<Post>> getUserFeed({
    required int userId,
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    
    // Get groups the user is a member of
    final groupResults = await db.query(
      'group_members',
      columns: ['groupId'],
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    final groupIds = groupResults.map((map) => map['groupId'] as int).toList();
    
    if (groupIds.isEmpty) {
      // If user is not in any groups, just return public posts
      return getPublicPosts(limit: limit, offset: offset);
    }
    
    // Build query for public posts + posts from user's groups
    final placeholders = List.filled(groupIds.length, '?').join(',');
    
    final results = await db.rawQuery('''
      SELECT * FROM posts
      WHERE groupId IS NULL OR groupId IN ($placeholders)
      ORDER BY createdAt DESC
      LIMIT ? OFFSET ?
    ''', [...groupIds, limit, offset]);
    
    return results.map((map) => Post.fromMap(map)).toList();
  }

  // Get a specific post
  Future<Post?> getPost(int postId) async {
    final db = await _databaseService.database;
    
    final results = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Post.fromMap(results.first);
  }

  // Update a post
  Future<Post> updatePost({
    required int postId,
    required int userId,
    String? content,
    List<String>? attachments,
  }) async {
    final db = await _databaseService.database;
    
    // Get current post
    final results = await db.query(
      'posts',
      where: 'id = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    
    if (results.isEmpty) {
      throw Exception('Post not found or you are not the author');
    }
    
    final currentPost = Post.fromMap(results.first);
    
    // Update post
    final updatedPost = currentPost.copyWith(
      content: content,
      attachments: attachments,
      updatedAt: DateTime.now(),
    );
    
    await db.update(
      'posts',
      updatedPost.toMap(),
      where: 'id = ?',
      whereArgs: [postId],
    );
    
    return updatedPost;
  }

  // Delete a post
  Future<void> deletePost({
    required int postId,
    required int userId,
  }) async {
    final db = await _databaseService.database;
    
    // Check if user is the author
    final results = await db.query(
      'posts',
      where: 'id = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    
    if (results.isEmpty) {
      throw Exception('Post not found or you are not the author');
    }
    
    // Delete related comments and likes first
    await db.delete(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
    );
    
    await db.delete(
      'likes',
      where: 'postId = ?',
      whereArgs: [postId],
    );
    
    // Delete the post
    await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  // Like a post
  Future<void> likePost({
    required int postId,
    required int userId,
  }) async {
    final db = await _databaseService.database;
    
    // Check if already liked
    final likeResults = await db.query(
      'likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    
    if (likeResults.isNotEmpty) {
      // Already liked, do nothing
      return;
    }
    
    // Create like
    final like = Like(
      postId: postId,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    await db.insert('likes', like.toMap());
    
    // Update likes count
    await db.rawUpdate('''
      UPDATE posts
      SET likesCount = likesCount + 1
      WHERE id = ?
    ''', [postId]);
  }

  // Unlike a post
  Future<void> unlikePost({
    required int postId,
    required int userId,
  }) async {
    final db = await _databaseService.database;
    
    // Delete like
    final result = await db.delete(
      'likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    
    if (result > 0) {
      // Update likes count
      await db.rawUpdate('''
        UPDATE posts
        SET likesCount = likesCount - 1
        WHERE id = ?
      ''', [postId]);
    }
  }

  // Check if user liked a post
  Future<bool> isPostLiked({
    required int postId,
    required int userId,
  }) async {
    final db = await _databaseService.database;
    
    final results = await db.query(
      'likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    
    return results.isNotEmpty;
  }

  // Add comment to a post
  Future<Comment> addComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    final db = await _databaseService.database;
    
    final comment = Comment(
      postId: postId,
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
    );
    
    final id = await db.insert('comments', comment.toMap());
    
    // Update comments count
    await db.rawUpdate('''
      UPDATE posts
      SET commentsCount = commentsCount + 1
      WHERE id = ?
    ''', [postId]);
    
    return comment.copyWith(id: id);
  }

  // Get comments for a post
  Future<List<Comment>> getComments({
    required int postId,
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await _databaseService.database;
    
    final results = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'createdAt ASC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((map) => Comment.fromMap(map)).toList();
  }
}
