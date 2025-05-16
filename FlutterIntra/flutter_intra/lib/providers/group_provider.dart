import 'package:flutter/material.dart';
import 'package:flutter_intra/models/models.dart';
import 'package:flutter_intra/services/services.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  
  List<Group> _publicGroups = [];
  List<Group> _userGroups = [];
  Group? _currentGroup;
  List<GroupMember> _groupMembers = [];
  bool _isLoading = false;
  String? _error;
  
  List<Group> get publicGroups => _publicGroups;
  List<Group> get userGroups => _userGroups;
  Group? get currentGroup => _currentGroup;
  List<GroupMember> get groupMembers => _groupMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load public groups
  Future<void> loadPublicGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _publicGroups = await _groupService.getPublicGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user groups
  Future<void> loadUserGroups(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userGroups = await _groupService.getUserGroups(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load a specific group
  Future<void> loadGroup(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentGroup = await _groupService.getGroup(groupId);
      if (_currentGroup != null) {
        _groupMembers = await _groupService.getGroupMembers(groupId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a group
  Future<bool> createGroup({
    required String name,
    required String description,
    String? image,
    required bool isPrivate,
    required int creatorId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newGroup = await _groupService.createGroup(
        name: name,
        description: description,
        image: image,
        isPrivate: isPrivate,
        creatorId: creatorId,
      );
      
      _userGroups.add(newGroup);
      if (!isPrivate) {
        _publicGroups.add(newGroup);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update a group
  Future<bool> updateGroup({
    required int groupId,
    required int userId,
    String? name,
    String? description,
    String? image,
    bool? isPrivate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedGroup = await _groupService.updateGroup(
        groupId: groupId,
        userId: userId,
        name: name,
        description: description,
        image: image,
        isPrivate: isPrivate,
      );
      
      // Update in current group
      _currentGroup = updatedGroup;
      
      // Update in user groups
      final userIndex = _userGroups.indexWhere((group) => group.id == groupId);
      if (userIndex != -1) {
        _userGroups[userIndex] = updatedGroup;
      }
      
      // Update in public groups
      final publicIndex = _publicGroups.indexWhere((group) => group.id == groupId);
      if (publicIndex != -1) {
        if (updatedGroup.isPrivate) {
          _publicGroups.removeAt(publicIndex);
        } else {
          _publicGroups[publicIndex] = updatedGroup;
        }
      } else if (!updatedGroup.isPrivate) {
        _publicGroups.add(updatedGroup);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Join a group
  Future<bool> joinGroup({
    required int groupId,
    required int userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _groupService.joinGroup(
        groupId: groupId,
        userId: userId,
      );
      
      // Reload user groups
      await loadUserGroups(userId);
      
      // If current group is loaded, reload members
      if (_currentGroup?.id == groupId) {
        _groupMembers = await _groupService.getGroupMembers(groupId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Leave a group
  Future<bool> leaveGroup({
    required int groupId,
    required int userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _groupService.leaveGroup(
        groupId: groupId,
        userId: userId,
      );
      
      // Remove from user groups
      _userGroups.removeWhere((group) => group.id == groupId);
      
      // If current group is loaded, reload members
      if (_currentGroup?.id == groupId) {
        _groupMembers = await _groupService.getGroupMembers(groupId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Change member role
  Future<bool> changeMemberRole({
    required int groupId,
    required int adminId,
    required int memberId,
    required String newRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _groupService.changeMemberRole(
        groupId: groupId,
        adminId: adminId,
        memberId: memberId,
        newRole: newRole,
      );
      
      // If current group is loaded, reload members
      if (_currentGroup?.id == groupId) {
        _groupMembers = await _groupService.getGroupMembers(groupId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
