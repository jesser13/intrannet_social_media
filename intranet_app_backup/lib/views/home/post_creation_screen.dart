import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import 'dart:io';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({Key? key}) : super(key: key);

  @override
  PostCreationScreenState createState() => PostCreationScreenState();
}

class PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  File? _file;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Add Image'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Add File'),
                ),
              ],
            ),
            if (_image != null) Image.file(_image!, height: 100),
            if (_file != null) Text('File: ${_file!.path.split('/').last}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);

                await postProvider.createPost(
                  authProvider.user!.id,
                  _contentController.text,
                  imagePath: _image?.path,
                  filePath: _file?.path,
                );

                if (mounted) {
                  navigator.pop();
                }
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}