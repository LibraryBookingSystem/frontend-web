import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../models/user.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// User service for user management operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class UserService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'UserService';

  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    logMethodEntry('getCurrentUser');

    try {
      final response = await _apiClient.get(AppConfig.currentUserEndpoint);

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('getCurrentUser', user);
        return user;
      } else {
        throw ApiException(
            'Failed to get current user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get current user error', e, stackTrace);
      rethrow;
    }
  }

  /// Get user by ID
  Future<User> getUserById(int id) async {
    logMethodEntry('getUserById', {'id': id});

    try {
      final response =
          await _apiClient.get('${AppConfig.userByIdEndpoint}/$id');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('getUserById', user);
        return user;
      } else {
        throw ApiException('Failed to get user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get user by ID error', e, stackTrace);
      rethrow;
    }
  }

  /// Get user by username
  Future<User> getUserByUsername(String username) async {
    logMethodEntry('getUserByUsername', {'username': username});

    try {
      final response =
          await _apiClient.get('${AppConfig.userByUsernameEndpoint}/$username');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('getUserByUsername', user);
        return user;
      } else {
        throw ApiException(
            'Failed to get user by username: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get user by username error', e, stackTrace);
      rethrow;
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    logMethodEntry('getAllUsers');

    try {
      final response = await _apiClient.get(AppConfig.allUsersEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final users = data
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getAllUsers', '${users.length} users');
        return users;
      } else {
        throw ApiException('Failed to get all users: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get all users error', e, stackTrace);
      rethrow;
    }
  }

  /// Restrict a user
  Future<User> restrictUser(int id, String reason) async {
    logMethodEntry('restrictUser', {'id': id, 'reason': reason});

    try {
      final response = await _apiClient.post(
        '${AppConfig.restrictUserEndpoint}/$id/restrict',
        body: {'reason': reason},
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('restrictUser', user);
        return user;
      } else {
        throw ApiException('Failed to restrict user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Restrict user error', e, stackTrace);
      rethrow;
    }
  }

  /// Unrestrict a user
  Future<User> unrestrictUser(int id) async {
    logMethodEntry('unrestrictUser', {'id': id});

    try {
      final response = await _apiClient
          .post('${AppConfig.unrestrictUserEndpoint}/$id/unrestrict');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('unrestrictUser', user);
        return user;
      } else {
        throw ApiException('Failed to unrestrict user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Unrestrict user error', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is restricted
  Future<bool> isUserRestricted(int id) async {
    logMethodEntry('isUserRestricted', {'id': id});

    try {
      final response = await _apiClient
          .get('${AppConfig.userRestrictedEndpoint}/$id/restricted');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final restricted = data['restricted'] as bool? ?? false;
        logMethodExit('isUserRestricted', restricted);
        return restricted;
      } else {
        throw ApiException(
            'Failed to check user restriction: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Check user restriction error', e, stackTrace);
      rethrow;
    }
  }

  /// Get pending users
  Future<List<User>> getPendingUsers() async {
    logMethodEntry('getPendingUsers');

    try {
      final response =
          await _apiClient.get('${AppConfig.allUsersEndpoint}/pending');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final users = data
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getPendingUsers', '${users.length} pending users');
        return users;
      } else {
        throw ApiException(
            'Failed to get pending users: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get pending users error', e, stackTrace);
      rethrow;
    }
  }

  /// Get rejected users
  Future<List<User>> getRejectedUsers() async {
    logMethodEntry('getRejectedUsers');

    try {
      final response =
          await _apiClient.get('${AppConfig.allUsersEndpoint}/rejected');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final users = data
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getRejectedUsers', '${users.length} rejected users');
        return users;
      } else {
        throw ApiException(
            'Failed to get rejected users: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get rejected users error', e, stackTrace);
      rethrow;
    }
  }

  /// Approve a user (works for both pending and rejected users)
  Future<User> approveUser(int id) async {
    logMethodEntry('approveUser', {'id': id});

    try {
      final response =
          await _apiClient.post('${AppConfig.allUsersEndpoint}/$id/approve');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('approveUser', user);
        return user;
      } else {
        throw ApiException('Failed to approve user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Approve user error', e, stackTrace);
      rethrow;
    }
  }

  /// Reject a user
  Future<User> rejectUser(int id) async {
    logMethodEntry('rejectUser', {'id': id});

    try {
      final response =
          await _apiClient.post('${AppConfig.allUsersEndpoint}/$id/reject');

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        logMethodExit('rejectUser', user);
        return user;
      } else {
        throw ApiException('Failed to reject user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Reject user error', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(int id) async {
    logMethodEntry('deleteUser', {'id': id});

    try {
      final response =
          await _apiClient.delete('${AppConfig.allUsersEndpoint}/$id');

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete user: ${response.statusCode}');
      }
      logMethodExit('deleteUser');
    } catch (e, stackTrace) {
      logError('Delete user error', e, stackTrace);
      rethrow;
    }
  }
}
