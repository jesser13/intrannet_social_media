import 'package:flutter/material.dart';
import '../services/group_service.dart';
import '../models/group.dart';

class GroupProvider with ChangeNotifier {
  final GroupService _groupService = GroupService();
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  Future<void> fetchGroups(String userId) async {
    _groups = await _groupService.getUserGroups(userId);
    notifyListeners();
  }

  Future<void> createGroup(String name, String creatorId, bool isPrivate) async {
    await _groupService.createGroup(name, creatorId, isPrivate);
    await fetchGroups(creatorId);
  }

  Future<void> joinGroup(String groupId, String userId) async {
    await _groupService.joinGroup(groupId, userId);
    await fetchGroups(userId);
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    await _groupService.leaveGroup(groupId, userId);
    await fetchGroups(userId);
  }
}