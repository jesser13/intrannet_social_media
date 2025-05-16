import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/models/models.dart';

class CreatePostScreen extends StatefulWidget {
  final int? groupId;

  const CreatePostScreen({
    Key? key,
    this.groupId,
  }) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final List<File> _selectedFiles = [];
  final List<String> _fileNames = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedFiles.add(File(image.path));
        _fileNames.add(image.name);
      });
    }
  }

  // Temporairement désactivé car file_picker cause des problèmes de compilation
  Future<void> _pickFile() async {
    // Utilisons image_picker comme alternative temporaire
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickMedia();

    if (file != null) {
      setState(() {
        _selectedFiles.add(File(file.path));
        _fileNames.add(file.name);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer du contenu')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour publier')),
      );
      return;
    }

    // In a real app, we would upload files to a server and get URLs
    // For this example, we'll just use file names as placeholders
    final List<String> attachments = _fileNames.isNotEmpty ? _fileNames : [];

    final success = await postProvider.createPost(
      userId: authProvider.currentUser!.id!,
      groupId: widget.groupId,
      content: _contentController.text.trim(),
      attachments: attachments.isNotEmpty ? attachments : null,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.error ?? 'Erreur lors de la publication'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    String title = 'Nouvelle publication';
    if (widget.groupId != null && groupProvider.currentGroup != null) {
      title = 'Publication dans ${groupProvider.currentGroup!.name}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _createPost,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text(
                    'Publier',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: authProvider.currentUser?.profilePicture != null
                      ? NetworkImage(authProvider.currentUser!.profilePicture!)
                      : null,
                  child: authProvider.currentUser?.profilePicture == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  authProvider.currentUser?.name ??
                      authProvider.currentUser?.username ??
                      'Utilisateur',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Que voulez-vous partager ?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFiles.isNotEmpty) ...[
              const Text(
                'Fichiers joints:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  final fileName = _fileNames[index];

                  return ListTile(
                    leading: _isImageFile(fileName)
                        ? Image.file(
                            file,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.insert_drive_file),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeFile(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Ajouter une image'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Ajouter un fichier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
  }
}
