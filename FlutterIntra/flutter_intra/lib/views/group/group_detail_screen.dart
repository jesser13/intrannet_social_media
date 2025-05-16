import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/views/home/create_post_screen.dart';
import 'package:flutter_intra/views/group/group_members_screen.dart';
import 'package:flutter_intra/views/group/edit_group_screen.dart';
import 'package:flutter_intra/widgets/post_card.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _isLoading = false;
  bool _isJoining = false;
  bool _isLeaving = false;
  String? _error;
  bool _isMember = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        throw Exception('Vous devez être connecté pour voir les détails du groupe');
      }

      // Load group details
      await groupProvider.loadGroup(widget.groupId);

      // Check if user is a member
      if (groupProvider.groupMembers.isNotEmpty) {
        _isMember = groupProvider.groupMembers.any(
          (member) => member.userId == authProvider.currentUser!.id!,
        );

        // Check if user is an admin
        _isAdmin = groupProvider.groupMembers.any(
          (member) => member.userId == authProvider.currentUser!.id! &&
                      member.role == 'admin',
        );
      }

      // Load group posts
      if (_isMember || (groupProvider.currentGroup != null && !groupProvider.currentGroup!.isPrivate)) {
        await postProvider.loadGroupPosts(
          groupId: widget.groupId,
          refresh: true,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    setState(() {
      _isJoining = true;
    });

    try {
      await groupProvider.joinGroup(
        groupId: widget.groupId,
        userId: authProvider.currentUser!.id!,
      );

      setState(() {
        _isMember = true;
      });

      // Reload posts
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.loadGroupPosts(
        groupId: widget.groupId,
        refresh: true,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  Future<void> _leaveGroup() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (authProvider.currentUser == null) return;

    // Afficher une boîte de dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: const Text('Êtes-vous sûr de vouloir quitter ce groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLeaving = true;
    });

    try {
      final success = await groupProvider.leaveGroup(
        groupId: widget.groupId,
        userId: authProvider.currentUser!.id!,
      );

      if (success) {
        setState(() {
          _isMember = false;
          _isAdmin = false;
        });

        // Go back if private group
        if (mounted && groupProvider.currentGroup != null && groupProvider.currentGroup!.isPrivate) {
          Navigator.of(context).pop();
        }
      } else if (groupProvider.error != null && mounted) {
        // Afficher un message d'erreur plus convivial
        String errorMessage = groupProvider.error!;

        if (errorMessage.contains('Cannot leave group as the only admin')) {
          errorMessage = 'Vous ne pouvez pas quitter le groupe car vous êtes le seul administrateur. Veuillez d\'abord promouvoir un autre membre au rang d\'administrateur.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: theme.colorScheme.onError,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLeaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final group = groupProvider.currentGroup;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Détails du groupe'),
        actions: [
          if (_isAdmin && group != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditGroupScreen(group: group),
                  ),
                );
              },
            ),
          if (group != null)
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupMembersScreen(groupId: group.id!),
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
                        onPressed: _loadGroupDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : group == null
                  ? const Center(child: Text('Groupe non trouvé'))
                  : Column(
                      children: [
                        // Group header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Hero(
                                tag: 'group-${group.id}',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: group.image != null
                                      ? NetworkImage(group.image!)
                                      : null,
                                  child: group.image == null
                                      ? Icon(
                                          Icons.group,
                                          size: 50,
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                group.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      group.isPrivate ? Icons.lock : Icons.public,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      group.isPrivate ? 'Groupe privé' : 'Groupe public',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  group.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (!_isMember && !group.isPrivate)
                                ElevatedButton.icon(
                                  onPressed: _isJoining ? null : _joinGroup,
                                  icon: _isJoining
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.group_add),
                                  label: const Text('Rejoindre le groupe'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                )
                              else if (_isMember)
                                ElevatedButton.icon(
                                  onPressed: _isLeaving ? null : _leaveGroup,
                                  icon: _isLeaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.exit_to_app),
                                  label: const Text('Quitter le groupe'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Group content
                        if (group.isPrivate && !_isMember)
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 80,
                                      color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Ce groupe est privé',
                                      style: Theme.of(context).textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Vous devez être invité par un administrateur pour rejoindre ce groupe et voir son contenu.',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await postProvider.loadGroupPosts(
                                  groupId: widget.groupId,
                                  refresh: true,
                                );
                              },
                              child: postProvider.isLoading && postProvider.posts.isEmpty
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    )
                                  : postProvider.posts.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.article_outlined,
                                                  size: 80,
                                                  color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Aucune publication',
                                                  style: Theme.of(context).textTheme.titleLarge,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Soyez le premier à publier dans ce groupe !',
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 24),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => CreatePostScreen(groupId: widget.groupId),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.add),
                                                  label: const Text('Créer une publication'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: postProvider.posts.length,
                                          itemBuilder: (context, index) {
                                            return PostCard(post: postProvider.posts[index]);
                                          },
                                        ),
                            ),
                          ),
                      ],
                    ),
      floatingActionButton: _isMember && authProvider.currentUser != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(groupId: widget.groupId),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Publier'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 4,
            )
          : null,
    );
  }
}
