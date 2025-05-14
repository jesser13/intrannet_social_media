import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final userId = Provider.of<AuthProvider>(context).user!.id;

    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: FutureBuilder(
        future: notificationProvider.fetchNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (notificationProvider.notifications.isEmpty) {
            return Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return ListTile(
                title: Text(notification.content),
                subtitle: Text(notification.type),
                trailing: Icon(
                  notification.isRead ? Icons.check : Icons.circle_notifications,
                ),
                onTap: () async {
                  await notificationProvider.markAsRead(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}