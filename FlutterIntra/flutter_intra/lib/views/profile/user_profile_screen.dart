import 'package:flutter/material.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/views/chat/chat_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  
  const UserProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? _user;
  List<Post> _userPosts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real app, we would fetch user and posts from the database
      // For this example, we'll just use placeholder data
      
      // Simulate fetching user
      await Future.delayed(const Duration(milliseconds: 300));
      _user = User(
        id: widget.userId,
        username: 'user${widget.userId}',
        email: 'user${widget.userId}@example.com',
        password: '',
        name: 'User ${widget.userId}',
        jobTitle: 'Developer',
        bio: 'This is a sample bio for user ${widget.userId}',
        role: 'employee',
        createdAt: DateTime.now(),
      );
      
      // Simulate fetching posts
      await Future.delayed(const Duration(milliseconds: 300));
      _userPosts = List.generate(
        3,
        (index) => Post(
          id: index + 1,
          userId: widget.userId,
          content: 'Sample post #${index + 1} by user ${widget.userId}',
          createdAt: DateTime.now().subtract(Duration(days: index)),
          likesCount: index + 1,
          commentsCount: index,
        ),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? 'Profil utilisateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _user == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          receiverId: _user!.id!,
                          receiverName: _user!.name ?? _user!.username,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erreur: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _user == null
                  ? const Center(child: Text('Utilisateur non trouvé'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _user?.profilePicture != null
                                ? NetworkImage(_user!.profilePicture!)
                                : null,
                            child: _user?.profilePicture == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user!.name ?? _user!.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_user!.jobTitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _user!.jobTitle!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    receiverId: _user!.id!,
                                    receiverName: _user!.name ?? _user!.username,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Envoyer un message'),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          if (_user!.bio != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'À propos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_user!.bio!),
                            const SizedBox(height: 16),
                            const Divider(),
                          ],
                          const SizedBox(height: 16),
                          const Text(
                            'Publications récentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_userPosts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Aucune publication'),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _userPosts.length,
                              itemBuilder: (context, index) {
                                final post = _userPosts[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.content),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${post.likesCount}'),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.comment, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${post.commentsCount}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }
}
