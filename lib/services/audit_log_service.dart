import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../core/utils/date_utils.dart' as date_utils;
import '../models/audit_log.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Audit log service for audit log operations
/// Follows Service-Oriented Architecture (SOA) pattern
class AuditLogService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'AuditLogService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get audit logs with filters
  Future<AuditLogPage> getAuditLogs({
    int? userId,
    String? actionType,
    String? resourceType,
    DateTime? startTime,
    DateTime? endTime,
    int page = 0,
    int size = 50,
  }) async {
    logMethodEntry('getAuditLogs', {
      'userId': userId,
      'actionType': actionType,
      'resourceType': resourceType,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'page': page,
      'size': size,
    });
    
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      if (actionType != null && actionType.isNotEmpty) {
        queryParams['actionType'] = actionType;
      }
      if (resourceType != null && resourceType.isNotEmpty) {
        queryParams['resourceType'] = resourceType;
      }
      if (startTime != null) {
        queryParams['startTime'] = date_utils.AppDateUtils.formatDateTime(startTime);
      }
      if (endTime != null) {
        queryParams['endTime'] = date_utils.AppDateUtils.formatDateTime(endTime);
      }
      
      final response = await _apiClient.get(
        AppConfig.auditLogsEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final page = AuditLogPage.fromJson(jsonDecode(response.body));
        logMethodExit('getAuditLogs', '${page.content.length} logs');
        return page;
      } else {
        throw ApiException('Failed to get audit logs: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get audit logs error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get audit logs by user ID
  Future<AuditLogPage> getAuditLogsByUserId(
    int userId, {
    int page = 0,
    int size = 50,
  }) async {
    logMethodEntry('getAuditLogsByUserId', {'userId': userId, 'page': page, 'size': size});
    
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      final response = await _apiClient.get(
        '${AppConfig.auditLogsByUserEndpoint}/$userId',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final page = AuditLogPage.fromJson(jsonDecode(response.body));
        logMethodExit('getAuditLogsByUserId', '${page.content.length} logs');
        return page;
      } else {
        throw ApiException('Failed to get audit logs by user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get audit logs by user error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get failed audit logs (for security monitoring)
  Future<List<AuditLog>> getFailedAuditLogs({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    logMethodEntry('getFailedAuditLogs', {
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    });
    
    try {
      final queryParams = <String, dynamic>{};
      
      if (startTime != null) {
        queryParams['startTime'] = date_utils.AppDateUtils.formatDateTime(startTime);
      }
      if (endTime != null) {
        queryParams['endTime'] = date_utils.AppDateUtils.formatDateTime(endTime);
      }
      
      final response = await _apiClient.get(
        AppConfig.failedAuditLogsEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final logs = data
            .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getFailedAuditLogs', '${logs.length} failed logs');
        return logs;
      } else {
        throw ApiException('Failed to get failed audit logs: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get failed audit logs error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.auditLogsHealthEndpoint);
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





