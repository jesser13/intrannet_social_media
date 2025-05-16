import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Message> _messages = [];
  List<Map<String, dynamic>> _recentConversations = [];

  List<Message> get messages => _messages;
  List<Map<String, dynamic>> get recentConversations => _recentConversations;

  Future<void> fetchConversation(String userId1, String userId2) async {
    _messages = await _chatService.getConversation(userId1, userId2);
    notifyListeners();
  }

  Future<void> fetchRecentConversations(String userId) async {
    _recentConversations = await _chatService.getRecentConversations(userId);
    notifyListeners();
  }

  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    await _chatService.sendMessage(senderId, receiverId, content);
    await fetchConversation(senderId, receiverId);
  }
}