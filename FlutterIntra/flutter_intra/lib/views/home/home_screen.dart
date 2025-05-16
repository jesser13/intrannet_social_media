import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/views/home/create_post_screen.dart';
import 'package:flutter_intra/views/group/groups_screen.dart';
import 'package:flutter_intra/views/chat/chat_list_screen.dart';
import 'package:flutter_intra/views/profile/profile_screen.dart';
import 'package:flutter_intra/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _screens.add(const FeedScreen());
    _screens.add(const GroupsScreen());
    _screens.add(const ChatListScreen());
    _screens.add(const ProfileScreen());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_currentIndex == 0) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        if (!postProvider.isLoading && postProvider.hasMorePosts) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.currentUser != null) {
            postProvider.loadUserFeed(userId: authProvider.currentUser!.id!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intranet Entreprise'),
        elevation: 2,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Groupes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFeed() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      postProvider.loadUserFeed(
        userId: authProvider.currentUser!.id!,
        refresh: true,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (!postProvider.isLoading && postProvider.hasMorePosts) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          postProvider.loadUserFeed(userId: authProvider.currentUser!.id!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(
        child: Text('Veuillez vous connecter pour voir le fil d\'actualité'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadFeed();
      },
      child: postProvider.isLoading && postProvider.posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : postProvider.posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Aucune publication pour le moment'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreatePostScreen(),
                            ),
                          );
                        },
                        child: const Text('Créer une publication'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: postProvider.posts.length +
                      (postProvider.isLoading || postProvider.hasMorePosts ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == postProvider.posts.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final post = postProvider.posts[index];
                    return PostCard(post: post);
                  },
                ),
    );
  }
}
