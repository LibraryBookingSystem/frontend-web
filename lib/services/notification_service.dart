import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../models/notification.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Notification service for notification operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class NotificationService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'NotificationService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get notifications by user ID
  Future<List<Notification>> getNotificationsByUserId(int userId) async {
    logMethodEntry('getNotificationsByUserId', {'userId': userId});
    
    try {
      final response = await _apiClient.get('${AppConfig.notificationsByUserEndpoint}/$userId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final notifications = data
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getNotificationsByUserId', '${notifications.length} notifications');
        return notifications;
      } else {
        throw ApiException('Failed to get notifications: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get notifications error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get unread notifications by user ID
  Future<List<Notification>> getUnreadNotifications(int userId) async {
    logMethodEntry('getUnreadNotifications', {'userId': userId});
    
    try {
      final response = await _apiClient.get('${AppConfig.unreadNotificationsEndpoint}/$userId/unread');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final notifications = data
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getUnreadNotifications', '${notifications.length} notifications');
        return notifications;
      } else {
        throw ApiException('Failed to get unread notifications: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get unread notifications error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get unread notification count
  Future<int> getUnreadCount(int userId) async {
    logMethodEntry('getUnreadCount', {'userId': userId});
    
    try {
      final response = await _apiClient.get('${AppConfig.unreadCountEndpoint}/$userId/unread/count');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final count = data['count'] as int? ?? 0;
        logMethodExit('getUnreadCount', count);
        return count;
      } else {
        throw ApiException('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get unread count error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Mark notification as read
  Future<Notification> markAsRead(int notificationId) async {
    logMethodEntry('markAsRead', {'notificationId': notificationId});
    
    try {
      final response = await _apiClient.put('${AppConfig.markAsReadEndpoint}/$notificationId/read');
      
      if (response.statusCode == 200) {
        final notification = Notification.fromJson(jsonDecode(response.body));
        logMethodExit('markAsRead', notification);
        return notification;
      } else {
        throw ApiException('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Mark as read error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(int userId) async {
    logMethodEntry('markAllAsRead', {'userId': userId});
    
    try {
      final response = await _apiClient.put('${AppConfig.markAllAsReadEndpoint}/$userId/read-all');
      
      if (response.statusCode != 204) {
        throw ApiException('Failed to mark all as read: ${response.statusCode}');
      }
      
      logMethodExit('markAllAsRead');
    } catch (e, stackTrace) {
      logError('Mark all as read error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.notificationHealthEndpoint);
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

