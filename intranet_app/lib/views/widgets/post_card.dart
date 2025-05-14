import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';

import '../widgets/comment_box.dart';

import 'dart:io';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final postProvider = Provider.of<PostProvider>(context);

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content, style: TextStyle(fontSize: 16)),
            if (post.imagePath != null) Image.file(File(post.imagePath!), height: 200),
            if (post.filePath != null)
              TextButton(
                onPressed: () {}, // Implement file download/view
                child: Text('View File: ${post.filePath!.split('/').last}'),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () => postProvider.likePost(post.id, user.id),
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => CommentBox(postId: post.id, post: post), // Added post argument
                    );
                  },
                ),
                if (post.userId == user.id)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await postProvider.deletePost(post.id, user.id);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}