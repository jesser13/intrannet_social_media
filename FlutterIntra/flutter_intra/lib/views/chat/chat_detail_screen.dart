import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/widgets/chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.isGroup = false,
  });

  @override
  State<ChatDetailScreen> createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedFiles = [];
  final List<String> _fileNames = [];
  bool _isSubmitting = false;
  bool _showAttachments = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    if (widget.isGroup) {
      await chatProvider.loadGroupConversation(
        groupId: widget.receiverId,
        userId: authProvider.currentUser!.id!,
      );
    } else {
      await chatProvider.loadUserConversation(
        userId1: authProvider.currentUser!.id!,
        userId2: widget.receiverId,
      );
    }

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedFiles.add(File(image.path));
        _fileNames.add(image.name);
        _showAttachments = true;
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
        _showAttachments = true;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
      if (_fileNames.isEmpty) {
        _showAttachments = false;
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _fileNames.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour envoyer un message')),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // In a real app, we would upload files to a server and get URLs
    // For this example, we'll just use file names as placeholders
    final List<String> attachments = _fileNames.isNotEmpty ? _fileNames : [];

    bool success;

    if (widget.isGroup) {
      success = await chatProvider.sendGroupMessage(
        senderId: authProvider.currentUser!.id!,
        groupId: widget.receiverId,
        content: _messageController.text.trim().isEmpty
            ? 'Fichier(s) joint(s)'
            : _messageController.text.trim(),
        attachments: attachments.isNotEmpty ? attachments : null,
      );
    } else {
      success = await chatProvider.sendUserMessage(
        senderId: authProvider.currentUser!.id!,
        receiverId: widget.receiverId,
        content: _messageController.text.trim().isEmpty
            ? 'Fichier(s) joint(s)'
            : _messageController.text.trim(),
        attachments: attachments.isNotEmpty ? attachments : null,
      );
    }

    if (success) {
      _messageController.clear();
      setState(() {
        _selectedFiles.clear();
        _fileNames.clear();
        _showAttachments = false;
      });

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.error ?? 'Erreur lors de l\'envoi du message'),
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: authProvider.currentUser == null
          ? const Center(
              child: Text('Veuillez vous connecter pour voir vos messages'),
            )
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: chatProvider.isLoading && chatProvider.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : chatProvider.messages.isEmpty
                          ? const Center(
                              child: Text('Aucun message'),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              itemCount: chatProvider.messages.length,
                              itemBuilder: (context, index) {
                                final message = chatProvider.messages[index];
                                final isMe = message.senderId == authProvider.currentUser!.id!;

                                return ChatBubble(
                                  message: message,
                                  isMe: isMe,
                                );
                              },
                            ),
                ),

                // Attachments preview
                if (_showAttachments)
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[200],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        final fileName = _fileNames[index];

                        return Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _isImageFile(fileName)
                                    ? Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.insert_drive_file),
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeFile(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Message input
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Image'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.attach_file),
                                  title: const Text('Fichier'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickFile();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Votre message...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.send),
                        onPressed: _isSubmitting ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
  }
}
