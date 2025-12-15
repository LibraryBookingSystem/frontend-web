import 'dart:io';
import 'package:flutter/foundation.dart';

/// Application configuration class containing all API endpoints, timeouts, and settings
class AppConfig {
  // Private constructor for singleton pattern
  AppConfig._();

  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;

  // Base URLs

  static String get baseApiUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://192.168.1.17:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  static String get websocketUrl {
    if (kIsWeb) return 'ws://localhost:8080/ws/';
    try {
      if (Platform.isAndroid) return 'ws://192.168.1.17:8080/ws/';
    } catch (_) {}
    return 'ws://localhost:8080/ws/';
  }

  // Service Endpoints
  static const String authEndpoint = '/api/auth';
  static const String usersEndpoint = '/api/users';
  static const String resourcesEndpoint = '/api/resources';
  static const String bookingsEndpoint = '/api/bookings';
  static const String policiesEndpoint = '/api/policies';
  static const String notificationsEndpoint = '/api/notifications';
  static const String analyticsEndpoint = '/api/analytics';

  // Auth Endpoints
  static const String registerEndpoint = '$authEndpoint/register';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String authHealthEndpoint = '$authEndpoint/health';

  // User Endpoints
  static const String currentUserEndpoint = '$usersEndpoint/me';
  static const String userByIdEndpoint = usersEndpoint;
  static const String userByUsernameEndpoint = '$usersEndpoint/username';
  static const String allUsersEndpoint = usersEndpoint;
  static const String restrictUserEndpoint = usersEndpoint;
  static const String unrestrictUserEndpoint = usersEndpoint;
  static const String userRestrictedEndpoint = usersEndpoint;
  static const String userHealthEndpoint = '/api/health';

  // Resource Endpoints
  static const String allResourcesEndpoint = resourcesEndpoint;
  static const String resourceByIdEndpoint = resourcesEndpoint;
  static const String createResourceEndpoint = resourcesEndpoint;
  static const String updateResourceEndpoint = resourcesEndpoint;
  static const String deleteResourceEndpoint = resourcesEndpoint;
  static const String resourceHealthEndpoint = '$resourcesEndpoint/health';

  // Booking Endpoints
  static const String createBookingEndpoint = bookingsEndpoint;
  static const String allBookingsEndpoint = bookingsEndpoint;
  static const String bookingByIdEndpoint = bookingsEndpoint;
  static const String bookingsByUserEndpoint = '$bookingsEndpoint/user';
  static const String bookingsByResourceEndpoint = '$bookingsEndpoint/resource';
  static const String updateBookingEndpoint = bookingsEndpoint;
  static const String cancelBookingEndpoint = bookingsEndpoint;
  static const String checkInEndpoint = '$bookingsEndpoint/checkin';
  static const String bookingHealthEndpoint = '$bookingsEndpoint/health';

  // Policy Endpoints
  static const String allPoliciesEndpoint = policiesEndpoint;
  static const String policyByIdEndpoint = policiesEndpoint;
  static const String createPolicyEndpoint = policiesEndpoint;
  static const String updatePolicyEndpoint = policiesEndpoint;
  static const String deletePolicyEndpoint = policiesEndpoint;
  static const String validatePolicyEndpoint = '$policiesEndpoint/validate';
  static const String policyHealthEndpoint = '$policiesEndpoint/health';

  // Notification Endpoints
  static const String notificationsByUserEndpoint =
      '$notificationsEndpoint/user';
  static const String unreadNotificationsEndpoint =
      '$notificationsEndpoint/user';
  static const String unreadCountEndpoint = '$notificationsEndpoint/user';
  static const String markAsReadEndpoint = notificationsEndpoint;
  static const String markAllAsReadEndpoint = '$notificationsEndpoint/user';
  static const String notificationHealthEndpoint =
      '$notificationsEndpoint/health';

  // Analytics Endpoints
  static const String utilizationStatsEndpoint =
      '$analyticsEndpoint/utilization';
  static const String peakHoursEndpoint = '$analyticsEndpoint/peak-hours';
  static const String overallStatsEndpoint = '$analyticsEndpoint/overall';
  static const String analyticsHealthEndpoint = '$analyticsEndpoint/health';

  // Timeout Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Polling Configuration
  static const Duration pollingInterval = Duration(seconds: 5);

  // WebSocket Configuration
  static const Duration websocketReconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts =
      3; // Reduced to prevent excessive retries when endpoint doesn't exist

  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseApiUrl$endpoint';
  }

  // Helper method to build WebSocket URL
  static String buildWebSocketUrl() {
    return websocketUrl;
  }
}
