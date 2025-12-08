import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// User provider for managing user state
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  List<User> _users = [];
  List<User> _pendingUsers = [];
  List<User> _rejectedUsers = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  List<User> get pendingUsers => _pendingUsers;
  List<User> get rejectedUsers => _rejectedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load current user
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all users
  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restrict user
  Future<bool> restrictUser(int id, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userService.restrictUser(id, reason);

      // Update in list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
      }

      // Update current user if it's the same
      if (_currentUser?.id == id) {
        _currentUser = user;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Unrestrict user
  Future<bool> unrestrictUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userService.unrestrictUser(id);

      // Update in list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
      }

      // Update current user if it's the same
      if (_currentUser?.id == id) {
        _currentUser = user;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load pending users
  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingUsers = await _userService.getPendingUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load rejected users
  Future<void> loadRejectedUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rejectedUsers = await _userService.getRejectedUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a user (works for both pending and rejected users)
  Future<bool> approveUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userService.approveUser(id);

      // Remove from pending and rejected lists
      _pendingUsers.removeWhere((u) => u.id == id);
      _rejectedUsers.removeWhere((u) => u.id == id);

      // Update in main users list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
      }

      // Update current user if it's the same
      if (_currentUser?.id == id) {
        _currentUser = user;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reject a user
  Future<bool> rejectUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userService.rejectUser(id);

      // Remove from pending list and add to rejected list
      _pendingUsers.removeWhere((u) => u.id == id);
      _rejectedUsers.removeWhere((u) => u.id == id);
      _rejectedUsers.add(user);

      // Update in main users list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
      }

      // Update current user if it's the same
      if (_currentUser?.id == id) {
        _currentUser = user;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.deleteUser(id);

      // Remove from all lists
      _users.removeWhere((u) => u.id == id);
      _pendingUsers.removeWhere((u) => u.id == id);
      _rejectedUsers.removeWhere((u) => u.id == id);

      // If current user is deleted (shouldn't happen typically), logout
      if (_currentUser?.id == id) {
        _currentUser = null;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
