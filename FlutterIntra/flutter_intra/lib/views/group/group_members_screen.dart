import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/providers/providers.dart';
import 'package:flutter_intra/views/profile/user_profile_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  final int groupId;
  
  const GroupMembersScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        throw Exception('Vous devez être connecté pour voir les membres du groupe');
      }
      
      // Load group details if not already loaded
      if (groupProvider.currentGroup?.id != widget.groupId) {
        await groupProvider.loadGroup(widget.groupId);
      }
      
      // Check if user is an admin
      if (groupProvider.groupMembers.isNotEmpty) {
        _isAdmin = groupProvider.groupMembers.any(
          (member) => member.userId == authProvider.currentUser!.id! && 
                      member.role == 'admin',
        );
      }
      
      // In a real app, we would fetch user details for each member
      // For this example, we'll just use placeholder data
      _members = [];
      
      for (var member in groupProvider.groupMembers) {
        // Simulate fetching user
        await Future.delayed(const Duration(milliseconds: 50));
        
        _members.add({
          'member': member,
          'user': User(
            id: member.userId,
            username: 'user${member.userId}',
            email: 'user${member.userId}@example.com',
            password: '',
            name: 'User ${member.userId}',
            role: 'employee',
            createdAt: DateTime.now(),
          ),
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeMemberRole(GroupMember member, String newRole) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    try {
      await groupProvider.changeMemberRole(
        groupId: widget.groupId,
        adminId: authProvider.currentUser!.id!,
        memberId: member.userId,
        newRole: newRole,
      );
      
      // Reload members
      await _loadMembers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.currentGroup;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Membres ${group?.name ?? ''}'),
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
                        onPressed: _loadMembers,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _members.isEmpty
                  ? const Center(child: Text('Aucun membre dans ce groupe'))
                  : ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final memberData = _members[index];
                        final member = memberData['member'] as GroupMember;
                        final user = memberData['user'] as User;
                        
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(userId: user.id!),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: user.profilePicture != null
                                  ? NetworkImage(user.profilePicture!)
                                  : null,
                              child: user.profilePicture == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(userId: user.id!),
                                ),
                              );
                            },
                            child: Text(
                              user.name ?? user.username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Text(
                            member.role == 'admin' ? 'Administrateur' : 'Membre',
                          ),
                          trailing: _isAdmin && group?.creatorId != member.userId
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'make_admin') {
                                      _changeMemberRole(member, 'admin');
                                    } else if (value == 'remove_admin') {
                                      _changeMemberRole(member, 'member');
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (member.role != 'admin')
                                      const PopupMenuItem(
                                        value: 'make_admin',
                                        child: Text('Promouvoir administrateur'),
                                      )
                                    else
                                      const PopupMenuItem(
                                        value: 'remove_admin',
                                        child: Text('Rétrograder membre'),
                                      ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
    );
  }
}
