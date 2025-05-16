import 'package:flutter/material.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/services.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<Map<String, dynamic>> _conversations = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  int? _currentConversationId;
  bool _isGroupChat = false;
  
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentConversationId => _currentConversationId;
  bool get isGroupChat => _isGroupChat;
  
  // Load user conversations
  Future<void> loadConversations(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _conversations = await _chatService.getUserConversationsList(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user-to-user conversation
  Future<void> loadUserConversation({
    required int userId1,
    required int userId2,
  }) async {
    _isLoading = true;
    _error = null;
    _currentConversationId = userId2;
    _isGroupChat = false;
    notifyListeners();
    
    try {
      _messages = await _chatService.getUserConversation(
        userId1: userId1,
        userId2: userId2,
      );
      
      // Mark messages as read
      await _chatService.markMessagesAsRead(
        userId: userId1,
        senderId: userId2,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load group conversation
  Future<void> loadGroupConversation({
    required int groupId,
    required int userId,
  }) async {
    _isLoading = true;
    _error = null;
    _currentConversationId = groupId;
    _isGroupChat = true;
    notifyListeners();
    
    try {
      _messages = await _chatService.getGroupConversation(
        groupId: groupId,
      );
      
      // Mark messages as read
      await _chatService.markMessagesAsRead(
        userId: userId,
        senderId: groupId,
        isGroup: true,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Send message to user
  Future<bool> sendUserMessage({
    required int senderId,
    required int receiverId,
    required String content,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final message = await _chatService.sendUserMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        attachments: attachments,
      );
      
      _messages.insert(0, message);
      
      // Update conversations list
      await loadConversations(senderId);
      
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
  
  // Send message to group
  Future<bool> sendGroupMessage({
    required int senderId,
    required int groupId,
    required String content,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final message = await _chatService.sendGroupMessage(
        senderId: senderId,
        groupId: groupId,
        content: content,
        attachments: attachments,
      );
      
      _messages.insert(0, message);
      
      // Update conversations list
      await loadConversations(senderId);
      
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
  
  // Get unread messages count
  Future<int> getUnreadMessagesCount(int userId) async {
    try {
      return await _chatService.getUnreadMessagesCount(userId);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
