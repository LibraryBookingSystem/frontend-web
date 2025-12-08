import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Secure storage wrapper for sensitive data like JWT tokens and user IDs
class SecureStorage {
  // Private constructor for singleton pattern
  SecureStorage._();

  // Singleton instance
  static final SecureStorage _instance = SecureStorage._();
  static SecureStorage get instance => _instance;

  // Flutter Secure Storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store JWT token securely
  Future<void> storeToken(String token) async {
    try {
      await _storage.write(key: AppConfig.jwtTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to store token: $e');
    }
  }

  /// Retrieve JWT token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConfig.jwtTokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve token: $e');
    }
  }

  /// Store user ID securely
  Future<void> storeUserId(String userId) async {
    try {
      await _storage.write(key: AppConfig.userIdKey, value: userId);
    } catch (e) {
      throw Exception('Failed to store user ID: $e');
    }
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: AppConfig.userIdKey);
    } catch (e) {
      throw Exception('Failed to retrieve user ID: $e');
    }
  }

  /// Store user role securely
  Future<void> storeUserRole(String role) async {
    try {
      await _storage.write(key: AppConfig.userRoleKey, value: role);
    } catch (e) {
      throw Exception('Failed to store user role: $e');
    }
  }

  /// Retrieve user role
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: AppConfig.userRoleKey);
    } catch (e) {
      throw Exception('Failed to retrieve user role: $e');
    }
  }

  /// Clear all stored data (used on logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete key $key: $e');
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
