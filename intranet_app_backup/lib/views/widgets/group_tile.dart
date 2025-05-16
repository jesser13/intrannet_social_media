import 'package:flutter/material.dart';
import '../../models/group.dart';

class GroupTile extends StatelessWidget {
  final Group group;

  const GroupTile({Key? key, required this.group}) : super(key: key);

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