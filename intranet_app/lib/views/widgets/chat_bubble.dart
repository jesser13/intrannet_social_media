import 'package:flutter/material.dart';
import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final String userId;

  ChatBubble({required this.message, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == userId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message.content),
      ),
    );
  }
}