import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final contactId = ModalRoute.of(context)!.settings.arguments as String;
    final user = Provider.of<AuthProvider>(context).user!;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: chatProvider.fetchConversation(user.id, contactId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: chatProvider.messages[index], userId: user.id);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await chatProvider.sendMessage(
                        user.id,
                        contactId,
                        _messageController.text,
                      );
                      _messageController.clear();
                      // Trigger notification
                      Provider.of<NotificationProvider>(context, listen: false).createNotification(
                        userId: contactId,
                        content: 'New message from ${user.name}',
                        type: 'message',
                        relatedId: user.id,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}