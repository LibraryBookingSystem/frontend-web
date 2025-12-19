import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

/// Notification provider for managing notification state
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<Notification> _notifications = [];
  List<Notification> _unreadNotifications = [];
  int _unreadCount = 0;
  
  bool _isLoading = false;
  String? _error;
  
  List<Notification> get notifications => _notifications;
  List<Notification> get unreadNotifications => _unreadNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load notifications for user
  Future<void> loadNotifications(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _notifications = await _notificationService.getNotificationsByUserId(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load unread notifications
  Future<void> loadUnreadNotifications(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _unreadNotifications = await _notificationService.getUnreadNotifications(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load unread count
  Future<void> loadUnreadCount(int userId) async {
    try {
      _unreadCount = await _notificationService.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final notification = await _notificationService.markAsRead(notificationId);
      
      // Update in lists
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = notification;
      }
      
      _unreadNotifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      
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
  
  /// Mark all notifications as read
  Future<bool> markAllAsRead(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _notificationService.markAllAsRead(userId);
      
      // Update all notifications to read
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadNotifications.clear();
      _unreadCount = 0;
      
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
  
  /// Add notification (for real-time updates)
  void addNotification(Notification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadNotifications.insert(0, notification);
      _unreadCount++;
    }
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

