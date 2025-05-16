import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/services/services.dart';
import 'package:flutter_intra/widgets/post_card.dart';
import 'package:flutter_intra/widgets/comment_box.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => PostDetailScreenState();
}

class PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPostAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // In a real app, we would fetch the post and comments from the database
      // For this example, we'll just use placeholder data

      // Simulate fetching post
      await Future.delayed(const Duration(milliseconds: 300));
      _post = Post(
        id: widget.postId,
        userId: 1,
        content: 'Contenu de la publication #${widget.postId}',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 5,
        commentsCount: 3,
      );

      // Simulate fetching comments
      await Future.delayed(const Duration(milliseconds: 300));
      _comments = List.generate(
        3,
        (index) => Comment(
          id: index + 1,
          postId: widget.postId,
          userId: index + 2,
          content: 'Commentaire #${index + 1} sur la publication',
          createdAt: DateTime.now().subtract(Duration(minutes: index * 30)),
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

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vous devez être connecté pour commenter'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Utiliser le PostService pour ajouter le commentaire
      final postService = PostService();

      final newComment = await postService.addComment(
        postId: widget.postId,
        userId: authProvider.currentUser!.id!,
        content: _commentController.text.trim(),
      );

      // Mettre à jour l'interface utilisateur
      setState(() {
        _comments.insert(0, newComment);
        if (_post != null) {
          _post = _post!.copyWith(commentsCount: _post!.commentsCount + 1);
        }
      });

      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Commentaire ajouté avec succès'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }

      _commentController.clear();
    } catch (e) {
      _error = e.toString();

      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $_error'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la publication'),
        elevation: 2,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPostAndComments,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _post == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: theme.colorScheme.primary.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Publication non trouvée',
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              PostCard(post: _post!),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Commentaires (${_comments.length})',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_comments.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 60,
                                          color: theme.colorScheme.primary.withAlpha(100),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucun commentaire',
                                          style: theme.textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Soyez le premier à commenter cette publication !',
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    return CommentBox(comment: _comments[index]);
                                  },
                                ),
                              // Espace en bas pour éviter que le dernier commentaire soit caché par la zone de saisie
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Ajouter un commentaire...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest,
                                  ),
                                  maxLines: 3,
                                  minLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FloatingActionButton(
                                mini: true,
                                onPressed: _isSubmitting ? null : _addComment,
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
