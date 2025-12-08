import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../core/storage/secure_storage.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Authentication service for user registration and login
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class AuthService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'AuthService';

  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;

  // Secure storage for token management
  final SecureStorage _storage = SecureStorage.instance;

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    logMethodEntry(
        'register', {'username': request.username, 'email': request.email});

    try {
      // Log the request details
      debugPrint('📤 Register Request:');
      debugPrint('URL: ${AppConfig.buildUrl(AppConfig.registerEndpoint)}');
      debugPrint('Body: ${jsonEncode(request.toJson())}');

      final response = await _apiClient.post(
        AppConfig.registerEndpoint,
        body: request.toJson(),
      );

      debugPrint('📥 Register Response:');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Store token and user data
        await _storage.storeToken(authResponse.token);
        await _storage.storeUserId(authResponse.user.id.toString());
        await _storage.storeUserRole(authResponse.user.role.value);

        logMethodExit('register', authResponse);
        return authResponse;
      } else if (response.statusCode == 401) {
        // Check if this is a pending approval message
        final body = jsonDecode(response.body);
        if (body['message'] != null &&
            body['message'].toString().toLowerCase().contains('approval')) {
          // treat as a special success case: user created but not logged in
          debugPrint('📝 User created but pending approval');
          // We return a "dummy" AuthResponse or throw a specific exception?
          // Throwing exception with the message is better for UI handling
          throw ApiException(body['message']);
        }
        throw ApiException('Registration failed: ${response.statusCode}');
      } else {
        throw ApiException('Registration failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Registration Exception:');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      logError('Registration error', e, stackTrace);
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    logMethodEntry('login', {'username': request.username});

    try {
      print('🔍 DEBUG: AuthService.login started');
      final response = await _apiClient.post(
        AppConfig.loginEndpoint,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Store token and user data
        await _storage.storeToken(authResponse.token);
        await _storage.storeUserId(authResponse.user.id.toString());
        await _storage.storeUserRole(authResponse.user.role.value);

        logMethodExit('login', authResponse);
        return authResponse;
      } else {
        throw ApiException('Login failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Login error', e, stackTrace);
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    logMethodEntry('logout');

    try {
      // Clear stored tokens
      await _storage.clearAll();
      logMethodExit('logout');
    } catch (e, stackTrace) {
      logError('Logout error', e, stackTrace);
      rethrow;
    }
  }

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

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.hasToken();
  }

  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.authHealthEndpoint);
      if (response.statusCode == 200) {
        return response.body;
      }
      throw ApiException('Health check failed: ${response.statusCode}');
    } catch (e, stackTrace) {
      logError('Health check error', e, stackTrace);
      rethrow;
    }
  }
}
