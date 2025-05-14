import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: FutureBuilder(
        future: chatProvider.fetchRecentConversations(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (chatProvider.recentConversations.isEmpty) {
            return Center(child: Text('No chats'));
          }
          return ListView.builder(
            itemCount: chatProvider.recentConversations.length,
            itemBuilder: (context, index) {
              final conversation = chatProvider.recentConversations[index];
              return ListTile(
                title: Text(conversation['contactName']),
                subtitle: Text(conversation['lastMessage'] ?? ''),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat_detail',
                    arguments: conversation['contactId'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}