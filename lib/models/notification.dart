import '../core/utils/date_utils.dart' as date_utils;

/// Notification type enumeration
/// Matches backend NotificationType enum
enum NotificationType {
  bookingConfirmed('BOOKING_CONFIRMED'),
  bookingReminder('BOOKING_REMINDER'),
  bookingCanceled('BOOKING_CANCELED'),
  checkInReminder('CHECK_IN_REMINDER'),
  noShowAlert('NO_SHOW_ALERT'),
  resourceCreated('RESOURCE_CREATED'),
  resourceDeleted('RESOURCE_DELETED'),
  policyCreated('POLICY_CREATED'),
  policyUpdated('POLICY_UPDATED'),
  policyDeleted('POLICY_DELETED'),
  // Legacy/additional types for frontend
  bookingExpired('BOOKING_EXPIRED'),
  noShow('NO_SHOW'),
  system('SYSTEM');
  
  final String value;
  const NotificationType(this.value);
  
  static NotificationType fromString(String value) {
    // Handle legacy mapping
    if (value == 'NO_SHOW') {
      return NotificationType.noShowAlert;
    }
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Notification model representing a user notification
class Notification {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final bool? emailSent;
  final DateTime createdAt;
  
  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.emailSent,
    required this.createdAt,
  });
  
  /// Create Notification from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      userId: json['userId'] as int,
      type: NotificationType.fromString(json['type'] as String? ?? 'SYSTEM'),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      emailSent: json['emailSent'] as bool?,
      createdAt: date_utils.AppDateUtils.parseDateTime(json['createdAt'] as String) ?? DateTime.now(),
    );
  }
  
  /// Convert Notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'isRead': isRead,
      if (emailSent != null) 'emailSent': emailSent,
      'createdAt': date_utils.AppDateUtils.formatDateTime(createdAt),
    };
  }
  
  /// Create a copy with modified fields
  Notification copyWith({
    int? id,
    int? userId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    bool? emailSent,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      emailSent: emailSent ?? this.emailSent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Check if notification is unread
  bool get isUnread => !isRead;
  
  /// Legacy getter for backward compatibility
  bool get read => isRead;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.isRead == isRead;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, userId, type, isRead);
  }
  
  @override
  String toString() {
    return 'Notification(id: $id, type: ${type.value}, title: $title, isRead: $isRead)';
  }
}

