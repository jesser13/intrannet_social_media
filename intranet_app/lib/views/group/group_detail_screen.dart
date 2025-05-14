import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/group_service.dart';
import '../../models/group.dart';
import '../widgets/post_card.dart';

class GroupDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final group = ModalRoute.of(context)!.settings.arguments as Group;
    final user = Provider.of<AuthProvider>(context).user!;
    final postProvider = Provider.of<PostProvider>(context);
    final groupService = GroupService();

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          FutureBuilder<bool>(
            future: groupService.isGroupMember(group.id, user.id),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    await Provider.of<GroupProvider>(context, listen: false).leaveGroup(group.id, user.id);
                    Navigator.pop(context);
                  },
                );
              }
              return IconButton(
                icon: Icon(Icons.group_add),
                onPressed: () async {
                  await Provider.of<GroupProvider>(context, listen: false).joinGroup(group.id, user.id);
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: groupService.getGroupPosts(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return PostCard(post: snapshot.data![index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create_post', arguments: group.id),
        child: Icon(Icons.add),
      ),
    );
  }
}