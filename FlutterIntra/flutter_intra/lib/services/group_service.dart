import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/database_service.dart';

class GroupService {
  final DatabaseService _databaseService = DatabaseService();

  // Create a new group
  Future<Group> createGroup({
    required String name,
    required String description,
    String? image,
    required bool isPrivate,
    required int creatorId,
  }) async {
    final db = await _databaseService.database;

    final group = Group(
      name: name,
      description: description,
      image: image,
      isPrivate: isPrivate,
      creatorId: creatorId,
      createdAt: DateTime.now(),
    );

    // Insert group
    final groupId = await db.insert('groups', group.toMap());

    // Add creator as admin
    final groupMember = GroupMember(
      groupId: groupId,
      userId: creatorId,
      role: 'admin',
      joinedAt: DateTime.now(),
    );

    await db.insert('group_members', groupMember.toMap());

    return group.copyWith(id: groupId);
  }

  // Get all public groups
  Future<List<Group>> getPublicGroups() async {
    final db = await _databaseService.database;

    final results = await db.query(
      'groups',
      where: 'isPrivate = 0',
      orderBy: 'name ASC',
    );

    return results.map((map) => Group.fromMap(map)).toList();
  }

  // Get groups user is a member of
  Future<List<Group>> getUserGroups(int userId) async {
    final db = await _databaseService.database;

    final results = await db.rawQuery('''
      SELECT g.* FROM groups g
      INNER JOIN group_members gm ON g.id = gm.groupId
      WHERE gm.userId = ?
      ORDER BY g.name ASC
    ''', [userId]);

    return results.map((map) => Group.fromMap(map)).toList();
  }

  // Liste de groupes réalistes
  final List<Map<String, dynamic>> _groupProfiles = [
    {
      'name': 'Équipe Développement',
      'description': 'Groupe de discussion pour l\'équipe de développement. Partagez vos idées, problèmes et solutions techniques.',
      'image': 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=500',
      'isPrivate': false,
      'creatorId': 1,
    },
    {
      'name': 'Marketing & Communication',
      'description': 'Espace dédié aux stratégies marketing et à la communication externe de l\'entreprise.',
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500',
      'isPrivate': false,
      'creatorId': 4,
    },
    {
      'name': 'Ressources Humaines',
      'description': 'Informations et discussions concernant les politiques RH, les événements d\'entreprise et le bien-être au travail.',
      'image': 'https://images.unsplash.com/photo-1600880292089-90a7e086ee0c?w=500',
      'isPrivate': true,
      'creatorId': 6,
    },
    {
      'name': 'Projet Alpha',
      'description': 'Groupe de travail pour le développement du projet Alpha. Réservé aux membres de l\'équipe projet.',
      'image': 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=500',
      'isPrivate': true,
      'creatorId': 3,
    },
    {
      'name': 'Idées & Innovation',
      'description': 'Partagez vos idées innovantes et discutez des nouvelles tendances technologiques.',
      'image': 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=500',
      'isPrivate': false,
      'creatorId': 2,
    },
    {
      'name': 'Événements d\'entreprise',
      'description': 'Informations sur les événements à venir, les team buildings et les célébrations d\'entreprise.',
      'image': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=500',
      'isPrivate': false,
      'creatorId': 6,
    },
    {
      'name': 'Support Technique',
      'description': 'Groupe d\'entraide pour résoudre les problèmes techniques rencontrés au quotidien.',
      'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=500',
      'isPrivate': false,
      'creatorId': 7,
    },
    {
      'name': 'Direction & Stratégie',
      'description': 'Discussions stratégiques et décisions de direction. Réservé aux membres de la direction.',
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500',
      'isPrivate': true,
      'creatorId': 9,
    },
  ];

  // Get a specific group
  Future<Group?> getGroup(int groupId) async {
    final db = await _databaseService.database;

    try {
      // Vérifier d'abord dans la base de données
      final results = await db.query(
        'groups',
        where: 'id = ?',
        whereArgs: [groupId],
      );

      if (results.isNotEmpty) {
        return Group.fromMap(results.first);
      }

      // Si le groupe n'est pas trouvé dans la base de données,
      // utiliser un profil fictif de notre liste
      final profileIndex = (groupId - 1) % _groupProfiles.length;
      final profile = _groupProfiles[profileIndex];

      // Créer un groupe avec le profil fictif
      return Group(
        id: groupId,
        name: profile['name'],
        description: profile['description'],
        image: profile['image'],
        isPrivate: profile['isPrivate'],
        creatorId: profile['creatorId'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
    } catch (e) {
      print('Erreur lors de la récupération du groupe: $e');
      return null;
    }
  }

  // Update a group
  Future<Group> updateGroup({
    required int groupId,
    required int userId,
    String? name,
    String? description,
    String? image,
    bool? isPrivate,
  }) async {
    final db = await _databaseService.database;

    // Check if user is admin
    final memberResults = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ? AND role = ?',
      whereArgs: [groupId, userId, 'admin'],
    );

    if (memberResults.isEmpty) {
      throw Exception('You do not have permission to update this group');
    }

    // Get current group
    final groupResults = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (groupResults.isEmpty) {
      throw Exception('Group not found');
    }

    final currentGroup = Group.fromMap(groupResults.first);

    // Update group
    final updatedGroup = currentGroup.copyWith(
      name: name,
      description: description,
      image: image,
      isPrivate: isPrivate,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'groups',
      updatedGroup.toMap(),
      where: 'id = ?',
      whereArgs: [groupId],
    );

    return updatedGroup;
  }

  // Join a group
  Future<void> joinGroup({
    required int groupId,
    required int userId,
  }) async {
    final db = await _databaseService.database;

    // Check if group exists and is public
    final groupResults = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (groupResults.isEmpty) {
      throw Exception('Group not found');
    }

    final group = Group.fromMap(groupResults.first);

    if (group.isPrivate) {
      throw Exception('Cannot join a private group directly');
    }

    // Check if already a member
    final memberResults = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );

    if (memberResults.isNotEmpty) {
      throw Exception('Already a member of this group');
    }

    // Add as member
    final groupMember = GroupMember(
      groupId: groupId,
      userId: userId,
      role: 'member',
      joinedAt: DateTime.now(),
    );

    await db.insert('group_members', groupMember.toMap());
  }

  // Leave a group
  Future<void> leaveGroup({
    required int groupId,
    required int userId,
  }) async {
    final db = await _databaseService.database;

    // Check if user is a member
    final memberResults = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );

    if (memberResults.isEmpty) {
      throw Exception('Not a member of this group');
    }

    // Check if user is the only admin
    final adminResults = await db.query(
      'group_members',
      where: 'groupId = ? AND role = ?',
      whereArgs: [groupId, 'admin'],
    );

    if (adminResults.length == 1 &&
        adminResults.first['userId'] == userId) {
      throw Exception('Cannot leave group as the only admin');
    }

    // Remove from group
    await db.delete(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );
  }

  // Get members of a group
  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    final db = await _databaseService.database;

    final results = await db.query(
      'group_members',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );

    return results.map((map) => GroupMember.fromMap(map)).toList();
  }

  // Check if user is a member of a group
  Future<bool> isGroupMember({
    required int groupId,
    required int userId,
  }) async {
    final db = await _databaseService.database;

    final results = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, userId],
    );

    return results.isNotEmpty;
  }

  // Change member role
  Future<void> changeMemberRole({
    required int groupId,
    required int adminId,
    required int memberId,
    required String newRole,
  }) async {
    final db = await _databaseService.database;

    // Check if admin is an admin
    final adminResults = await db.query(
      'group_members',
      where: 'groupId = ? AND userId = ? AND role = ?',
      whereArgs: [groupId, adminId, 'admin'],
    );

    if (adminResults.isEmpty) {
      throw Exception('You do not have permission to change roles');
    }

    // Update member role
    await db.update(
      'group_members',
      {'role': newRole},
      where: 'groupId = ? AND userId = ?',
      whereArgs: [groupId, memberId],
    );
  }
}
