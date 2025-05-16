import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> fetchPosts(String userId, {int page = 1}) async {
    _posts = await _postService.getFeed(userId, page: page);
    notifyListeners();
  }

  Future<void> createPost(String userId, String content, {String? imagePath, String? filePath, String? groupId}) async {
    await _postService.createPost(userId, content, imagePath: imagePath, filePath: filePath, groupId: groupId);
    await fetchPosts(userId);
  }

  Future<void> likePost(String postId, String userId) async {
    await _postService.likePost(postId, userId);
    notifyListeners();
  }

  Future<List<Comment>> getComments(String postId) async {
    return await _postService.getComments(postId);
  }

  Future<void> addComment(String postId, String userId, String content) async {
    await _postService.addComment(postId, userId, content);
    notifyListeners();
  }

  Future<void> deletePost(String postId, String userId) async {
    await _postService.deletePost(postId);
    await fetchPosts(userId);
  }
}