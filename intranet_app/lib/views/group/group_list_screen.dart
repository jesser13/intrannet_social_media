import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../widgets/group_tile.dart';

class GroupListScreen extends StatelessWidget {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isPrivate = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Groups')),
      body: FutureBuilder(
        future: groupProvider.fetchGroups(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (groupProvider.groups.isEmpty) {
            return Center(child: Text('No groups'));
          }
          return ListView.builder(
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              return GroupTile(group: groupProvider.groups[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Create Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(labelText: 'Group Name'),
                  ),
                  CheckboxListTile(
                    title: Text('Private'),
                    value: _isPrivate,
                    onChanged: (value) {
                      _isPrivate = value!;
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Create Group'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _groupNameController,
                                decoration: InputDecoration(labelText: 'Group Name'),
                              ),
                              CheckboxListTile(
                                title: Text('Private'),
                                value: _isPrivate,
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await groupProvider.createGroup(
                                  _groupNameController.text,
                                  user.id,
                                  _isPrivate,
                                );
                                Navigator.pop(context);
                              },
                              child: Text('Create'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await groupProvider.createGroup(
                      _groupNameController.text,
                      user.id,
                      _isPrivate,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Create'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}