import 'package:flutter/material.dart';
import '../../models/group.dart';

class GroupTile extends StatelessWidget {
  final Group group;

  GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(group.name),
      subtitle: Text(group.isPrivate ? 'Private' : 'Public'),
      onTap: () {
        Navigator.pushNamed(context, '/group_detail', arguments: group);
      },
    );
  }
}