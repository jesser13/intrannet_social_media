import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:io';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user.photo != null) Image.file(File(user.photo!), height: 100),
            Text('Name: ${user.name}', style: TextStyle(fontSize: 20)),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role}'),
            if (user.function != null) Text('Function: ${user.function}'),
            if (user.bio != null) Text('Bio: ${user.bio}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
              child: Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}