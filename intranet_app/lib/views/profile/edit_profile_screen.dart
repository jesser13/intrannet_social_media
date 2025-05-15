import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _functionController;
  late TextEditingController _bioController;
  File? _photo;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name);
    _functionController = TextEditingController(text: user.function);
    _bioController = TextEditingController(text: user.bio);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _functionController,
              decoration: InputDecoration(labelText: 'Function'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickPhoto,
              child: Text('Change Photo'),
            ),
            if (_photo != null) Image.file(_photo!, height: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final updatedUser = User(
                  id: authProvider.user!.id,
                  name: _nameController.text,
                  email: authProvider.user!.email,
                  password: authProvider.user!.password,
                  role: authProvider.user!.role,
                  photo: _photo?.path ?? authProvider.user!.photo,
                  function: _functionController.text,
                  bio: _bioController.text,
                );
                await authProvider.updateProfile(updatedUser);
                if (mounted) {
                  navigator.pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}