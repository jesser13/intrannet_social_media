import 'package:flutter/material.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/services.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMorePosts = true;
  String? _error;
  int _currentPage = 0;
  final int _postsPerPage = 10;
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMorePosts => _hasMorePosts;
  String? get error => _error;
  
  // Load public posts
  Future<void> loadPublicPosts({bool refresh = false}) async {
    if (refresh) {
      _posts = [];
      _currentPage = 0;
      _hasMorePosts = true;
    }
    
    if (_isLoading || !_hasMorePosts) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPosts = await _postService.getPublicPosts(
        limit: _postsPerPage,
        offset: _currentPage * _postsPerPage,
      );
      
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user feed
  Future<void> loadUserFeed({
    required int userId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _posts = [];
      _currentPage = 0;
      _hasMorePosts = true;
    }
    
    if (_isLoading || !_hasMorePosts) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPosts = await _postService.getUserFeed(
        userId: userId,
        limit: _postsPerPage,
        offset: _currentPage * _postsPerPage,
      );
      
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load group posts
  Future<void> loadGroupPosts({
    required int groupId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _posts = [];
      _currentPage = 0;
      _hasMorePosts = true;
    }
    
    if (_isLoading || !_hasMorePosts) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPosts = await _postService.getGroupPosts(
        groupId: groupId,
        limit: _postsPerPage,
        offset: _currentPage * _postsPerPage,
      );
      
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a post
  Future<bool> createPost({
    required int userId,
    int? groupId,
    required String content,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPost = await _postService.createPost(
        userId: userId,
        groupId: groupId,
        content: content,
        attachments: attachments,
      );
      
      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update a post
  Future<bool> updatePost({
    required int postId,
    required int userId,
    String? content,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedPost = await _postService.updatePost(
        postId: postId,
        userId: userId,
        content: content,
        attachments: attachments,
      );
      
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a post
  Future<bool> deletePost({
    required int postId,
    required int userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _postService.deletePost(
        postId: postId,
        userId: userId,
      );
      
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Like a post
  Future<bool> likePost({
    required int postId,
    required int userId,
  }) async {
    try {
      await _postService.likePost(
        postId: postId,
        userId: userId,
      );
      
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          likesCount: _posts[index].likesCount + 1,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Unlike a post
  Future<bool> unlikePost({
    required int postId,
    required int userId,
  }) async {
    try {
      await _postService.unlikePost(
        postId: postId,
        userId: userId,
      );
      
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          likesCount: _posts[index].likesCount - 1,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
