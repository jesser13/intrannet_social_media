import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/views/group/create_group_screen.dart';
import 'package:flutter_intra/views/group/group_detail_screen.dart';
import 'package:flutter_intra/widgets/group_tile.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadGroups() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      groupProvider.loadUserGroups(authProvider.currentUser!.id!);
      groupProvider.loadPublicGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    
    if (authProvider.currentUser == null) {
      return const Center(
        child: Text('Veuillez vous connecter pour voir les groupes'),
      );
    }
    
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes groupes'),
            Tab(text: 'Découvrir'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // My Groups Tab
              RefreshIndicator(
                onRefresh: () async {
                  await groupProvider.loadUserGroups(authProvider.currentUser!.id!);
                },
                child: groupProvider.isLoading && groupProvider.userGroups.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : groupProvider.userGroups.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Vous n\'avez rejoint aucun groupe'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const CreateGroupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Créer un groupe'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: groupProvider.userGroups.length,
                            itemBuilder: (context, index) {
                              final group = groupProvider.userGroups[index];
                              return GroupTile(
                                group: group,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GroupDetailScreen(groupId: group.id!),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
              
              // Discover Tab
              RefreshIndicator(
                onRefresh: () async {
                  await groupProvider.loadPublicGroups();
                },
                child: groupProvider.isLoading && groupProvider.publicGroups.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : groupProvider.publicGroups.isEmpty
                        ? const Center(
                            child: Text('Aucun groupe public disponible'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: groupProvider.publicGroups.length,
                            itemBuilder: (context, index) {
                              final group = groupProvider.publicGroups[index];
                              
                              // Check if user is already a member
                              final isMember = groupProvider.userGroups.any(
                                (userGroup) => userGroup.id == group.id,
                              );
                              
                              return GroupTile(
                                group: group,
                                isMember: isMember,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GroupDetailScreen(groupId: group.id!),
                                    ),
                                  );
                                },
                                onJoin: isMember
                                    ? null
                                    : () async {
                                        await groupProvider.joinGroup(
                                          groupId: group.id!,
                                          userId: authProvider.currentUser!.id!,
                                        );
                                      },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateGroupScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un groupe'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}
