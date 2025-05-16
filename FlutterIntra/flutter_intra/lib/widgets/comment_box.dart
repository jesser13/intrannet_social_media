import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/views/profile/user_profile_screen.dart';

class CommentBox extends StatefulWidget {
  final Comment comment;

  const CommentBox({
    super.key,
    required this.comment,
  });

  @override
  State<CommentBox> createState() => CommentBoxState();
}

class CommentBoxState extends State<CommentBox> {
  User? _commentAuthor;

  @override
  void initState() {
    super.initState();
    _loadCommentAuthor();
  }

  Future<void> _loadCommentAuthor() async {
    setState(() {});

    // In a real app, we would fetch user from the database
    // For this example, we'll just use placeholder data

    // Simulate fetching user
    await Future.delayed(const Duration(milliseconds: 100));
    _commentAuthor = User(
      id: widget.comment.userId,
      username: 'user${widget.comment.userId}',
      email: 'user${widget.comment.userId}@example.com',
      password: '',
      name: 'User ${widget.comment.userId}',
      role: 'employee',
      createdAt: DateTime.now(),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _commentAuthor == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(userId: _commentAuthor!.id!),
                            ),
                          );
                        },
                  child: Hero(
                    tag: 'comment-avatar-${widget.comment.id}',
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withAlpha(50),
                      backgroundImage: _commentAuthor?.profilePicture != null
                          ? NetworkImage(_commentAuthor!.profilePicture!)
                          : null,
                      child: _commentAuthor?.profilePicture == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _commentAuthor == null
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => UserProfileScreen(userId: _commentAuthor!.id!),
                                        ),
                                      );
                                    },
                              child: Text(
                                _commentAuthor?.name ?? _commentAuthor?.username ?? 'Utilisateur',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            dateFormat.format(widget.comment.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          widget.comment.content,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
