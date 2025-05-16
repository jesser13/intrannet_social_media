import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/services/services.dart';
import 'package:flutter_intra/views/home/post_detail_screen.dart';
import 'package:flutter_intra/views/profile/user_profile_screen.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  User? _postAuthor;
  Group? _postGroup;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  Future<void> _loadPostDetails() async {
    if (!mounted) return;

    setState(() {});

    try {
      // Get services
      final userService = UserService();
      final groupService = GroupService();
      final postService = PostService();

      // Get post author
      _postAuthor = await userService.getUser(widget.post.userId);

      // Get group if post is in a group
      if (widget.post.groupId != null) {
        _postGroup = await groupService.getGroup(widget.post.groupId!);
      }

      // Check if current user liked the post
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null && mounted) {
        _isLiked = await postService.isPostLiked(
          postId: widget.post.id!,
          userId: currentUser.id!,
        );
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error loading post details: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _toggleLike() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      postProvider.likePost(
        postId: widget.post.id!,
        userId: authProvider.currentUser!.id!,
      );
    } else {
      postProvider.unlikePost(
        postId: widget.post.id!,
        userId: authProvider.currentUser!.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: _postAuthor == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(userId: _postAuthor!.id!),
                        ),
                      );
                    },
              child: Hero(
                tag: 'profile-${_postAuthor?.id ?? "unknown"}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: _postAuthor?.profilePicture != null
                      ? NetworkImage(_postAuthor!.profilePicture!)
                      : null,
                  child: _postAuthor?.profilePicture == null
                      ? Icon(Icons.person, color: theme.colorScheme.primary)
                      : null,
                ),
              ),
            ),
            title: GestureDetector(
              onTap: _postAuthor == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(userId: _postAuthor!.id!),
                        ),
                      );
                    },
              child: Text(
                _postAuthor?.name ?? _postAuthor?.username ?? 'Utilisateur',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(widget.post.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
                if (_postGroup != null)
                  Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    label: Text(
                      _postGroup!.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            trailing: authProvider.currentUser?.id == widget.post.userId
                ? PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Navigate to edit post screen
                      } else if (value == 'delete') {
                        // Show delete confirmation
                        _showDeleteConfirmation();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.post.content,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          if (widget.post.attachments != null && widget.post.attachments!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.post.attachments!.map((attachment) {
                      final isImage = _isImageFile(attachment);

                      return isImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(attachment),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Chip(
                              avatar: Icon(
                                Icons.attach_file,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              label: Text(
                                attachment,
                                style: theme.textTheme.bodyMedium,
                              ),
                              backgroundColor: theme.colorScheme.surface,
                              side: BorderSide(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.all(8),
                            );
                    }).toList(),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.likesCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.commentsCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: authProvider.currentUser == null ? null : _toggleLike,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    'J\'aime',
                    style: TextStyle(
                      color: _isLiked ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(postId: widget.post.id!),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.comment_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    'Commenter',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette publication ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePost();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _deletePost() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await postProvider.deletePost(
      postId: widget.post.id!,
      userId: authProvider.currentUser!.id!,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(postProvider.error ?? 'Erreur lors de la suppression'),
        ),
      );
    }
  }
}
