import '../core/utils/date_utils.dart' as date_utils;

/// Audit log model representing a system audit log entry
class AuditLog {
  final int id;
  final int? userId;
  final String? username;
  final String? userRole;
  final String actionType;
  final String? resourceType;
  final int? resourceId;
  final String? resourceName;
  final String? description;
  final String? ipAddress;
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;
  final String? metadata;
  
  const AuditLog({
    required this.id,
    this.userId,
    this.username,
    this.userRole,
    required this.actionType,
    this.resourceType,
    this.resourceId,
    this.resourceName,
    this.description,
    this.ipAddress,
    required this.success,
    this.errorMessage,
    required this.timestamp,
    this.metadata,
  });
  
  /// Create AuditLog from JSON
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      userRole: json['userRole'] as String?,
      actionType: json['actionType'] as String,
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as int?,
      resourceName: json['resourceName'] as String?,
      description: json['description'] as String?,
      ipAddress: json['ipAddress'] as String?,
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
      timestamp: date_utils.AppDateUtils.parseDateTime(json['timestamp'] as String) ?? DateTime.now(),
      metadata: json['metadata'] as String?,
    );
  }
  
  /// Convert AuditLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      if (username != null) 'username': username,
      if (userRole != null) 'userRole': userRole,
      'actionType': actionType,
      if (resourceType != null) 'resourceType': resourceType,
      if (resourceId != null) 'resourceId': resourceId,
      if (resourceName != null) 'resourceName': resourceName,
      if (description != null) 'description': description,
      if (ipAddress != null) 'ipAddress': ipAddress,
      'success': success,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'timestamp': date_utils.AppDateUtils.formatDateTime(timestamp),
      if (metadata != null) 'metadata': metadata,
    };
  }
  
  /// Get action type display name
  String get actionTypeDisplay {
    switch (actionType) {
      case 'CREATE':
        return 'Create';
      case 'UPDATE':
        return 'Update';
      case 'DELETE':
        return 'Delete';
      case 'LOGIN':
        return 'Login';
      case 'LOGOUT':
        return 'Logout';
      case 'VIEW':
        return 'View';
      case 'CHECK_IN':
        return 'Check In';
      case 'CANCEL':
        return 'Cancel';
      case 'APPROVE':
        return 'Approve';
      case 'MANAGE_USER':
        return 'Manage User';
      default:
        return actionType;
    }
  }
  
  /// Get resource type display name
  String get resourceTypeDisplay {
    if (resourceType == null) return 'N/A';
    switch (resourceType!) {
      case 'RESOURCE':
        return 'Resource';
      case 'BOOKING':
        return 'Booking';
      case 'POLICY':
        return 'Policy';
      case 'USER':
        return 'User';
      case 'NOTIFICATION':
        return 'Notification';
      case 'AUTH':
        return 'Authentication';
      default:
        return resourceType!;
    }
  }
}

/// Paginated audit log response
class AuditLogPage {
  final List<AuditLog> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;
  final bool first;
  final bool last;
  
  const AuditLogPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
    required this.first,
    required this.last,
  });
  
  factory AuditLogPage.fromJson(Map<String, dynamic> json) {
    return AuditLogPage(
      content: (json['content'] as List<dynamic>?)
          ?.map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 50,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
}
