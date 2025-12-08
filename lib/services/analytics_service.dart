import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../core/utils/date_utils.dart' as date_utils;
import '../models/analytics.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Analytics service for analytics and reporting operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class AnalyticsService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'AnalyticsService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get utilization statistics
  Future<List<UsageStatsResponse>> getUtilizationStats(
    DateTime startDate,
    DateTime endDate, {
    int? resourceId,
  }) async {
    logMethodEntry('getUtilizationStats', {
      'startDate': date_utils.AppDateUtils.formatDate(startDate),
      'endDate': date_utils.AppDateUtils.formatDate(endDate),
      'resourceId': resourceId,
    });
    
    try {
      final queryParams = <String, dynamic>{
        'startDate': date_utils.AppDateUtils.formatDate(startDate),
        'endDate': date_utils.AppDateUtils.formatDate(endDate),
      };
      if (resourceId != null) {
        queryParams['resourceId'] = resourceId.toString();
      }
      
      final response = await _apiClient.get(
        AppConfig.utilizationStatsEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final stats = data
            .map((json) => UsageStatsResponse.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getUtilizationStats', '${stats.length} stats');
        return stats;
      } else {
        throw ApiException('Failed to get utilization stats: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get utilization stats error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get peak hours
  Future<PeakHoursResponse> getPeakHours(
    DateTime startTime,
    DateTime endTime,
  ) async {
    logMethodEntry('getPeakHours', {
      'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
      'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
    });
    
    try {
      final queryParams = <String, dynamic>{
        'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
        'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
      };
      
      final response = await _apiClient.get(
        AppConfig.peakHoursEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final peakHours = PeakHoursResponse.fromJson(jsonDecode(response.body));
        logMethodExit('getPeakHours', peakHours);
        return peakHours;
      } else {
        throw ApiException('Failed to get peak hours: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get peak hours error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get overall statistics
  Future<OverallStatsResponse> getOverallStats(
    DateTime startTime,
    DateTime endTime,
  ) async {
    logMethodEntry('getOverallStats', {
      'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
      'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
    });
    
    try {
      final queryParams = <String, dynamic>{
        'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
        'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
      };
      
      final response = await _apiClient.get(
        AppConfig.overallStatsEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final stats = OverallStatsResponse.fromJson(jsonDecode(response.body));
        logMethodExit('getOverallStats', stats);
        return stats;
      } else {
        throw ApiException('Failed to get overall stats: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get overall stats error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.analyticsHealthEndpoint);
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

