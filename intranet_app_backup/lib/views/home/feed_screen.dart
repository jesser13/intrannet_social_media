import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/notification_provider.dart';
import '../widgets/post_card.dart';
import 'package:badges/badges.dart' as badges;

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        actions: [
          IconButton(
            icon: badges.Badge(
              badgeContent: Text(
                Provider.of<NotificationProvider>(context).unreadCount.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.notifications),
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () => Navigator.pushNamed(context, '/groups'),
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: postProvider.fetchPosts(authProvider.user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (postProvider.posts.isEmpty) {
            return Center(child: Text('No posts'));
          }
          return ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: postProvider.posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create_post'),
        child: Icon(Icons.add),
      ),
    );
  }
}