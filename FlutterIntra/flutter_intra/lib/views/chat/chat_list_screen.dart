import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/views/chat/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await chatProvider.loadConversations(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);

    if (authProvider.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'Veuillez vous connecter pour voir vos messages',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: chatProvider.isLoading && chatProvider.conversations.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : chatProvider.conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: theme.colorScheme.primary.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune conversation',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Ici, vous pourriez ajouter une navigation vers un écran
                          // pour démarrer une nouvelle conversation
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nouvelle conversation'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: chatProvider.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = chatProvider.conversations[index];
                    final message = conversation['message'];
                    final isGroup = conversation['isGroup'] as bool;

                    String name;
                    String? image;
                    int receiverId;

                    if (isGroup) {
                      final group = conversation['group'];
                      name = group['name'];
                      image = group['image'];
                      receiverId = group['id'];
                    } else {
                      final user = conversation['user'];
                      name = user['name'] ?? user['username'];
                      image = user['profilePicture'];
                      receiverId = user['id'];
                    }

                    final isUnread = !message.isRead &&
                        message.senderId != authProvider.currentUser!.id!;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      elevation: isUnread ? 2 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isUnread
                            ? BorderSide(color: theme.colorScheme.primary, width: 1)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Hero(
                          tag: 'avatar-${isGroup ? "group" : "user"}-$receiverId',
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: isGroup
                                ? theme.colorScheme.secondary.withAlpha(50)
                                : theme.colorScheme.primary.withAlpha(50),
                            backgroundImage: image != null
                                ? NetworkImage(image)
                                : null,
                            child: image == null
                                ? Icon(
                                    isGroup ? Icons.group : Icons.person,
                                    color: isGroup
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                        title: Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (message.senderId == authProvider.currentUser!.id!)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.reply,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                message.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                  color: isUnread
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(message.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isUnread
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Nouveau',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                receiverId: receiverId,
                                receiverName: name,
                                isGroup: isGroup,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}
