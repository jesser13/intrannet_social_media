import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/post.dart';
import '../../models/comment.dart';

class CommentBox extends StatelessWidget {
  final String postId;
  final Post post; // Added post parameter
  final TextEditingController _commentController = TextEditingController();

  CommentBox({required this.postId, required this.post});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final postProvider = Provider.of<PostProvider>(context);

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          FutureBuilder<List<Comment>>(
            future: postProvider.getComments(postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final comment = snapshot.data![index];
                  return ListTile(
                    title: Text(comment.content),
                    subtitle: Text('By User ${comment.userId}'),
                  );
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Add Comment'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      await postProvider.addComment(postId, user.id, _commentController.text);
                      _commentController.clear();
                      // Trigger notification
                      Provider.of<NotificationProvider>(context, listen: false).createNotification(
                        userId: post.userId, // Use post.userId from parameter
                        content: 'New comment on your post',
                        type: 'comment',
                        relatedId: postId,
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