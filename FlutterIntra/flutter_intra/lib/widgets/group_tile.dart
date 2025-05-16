import 'package:flutter/material.dart';
import 'package:flutter_intra/models/models.dart';

class GroupTile extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final bool isMember;
  
  const GroupTile({
    super.key,
    required this.group,
    required this.onTap,
    this.onJoin,
    this.isMember = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: group.image != null
              ? NetworkImage(group.image!)
              : null,
          child: group.image == null
              ? const Icon(Icons.group)
              : null,
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  group.isPrivate ? Icons.lock : Icons.public,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  group.isPrivate ? 'Privé' : 'Public',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: onJoin != null
            ? ElevatedButton(
                onPressed: onJoin,
                child: const Text('Rejoindre'),
              )
            : isMember
                ? const Chip(
                    label: Text('Membre'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                : null,
        onTap: onTap,
      ),
    );
  }
}
