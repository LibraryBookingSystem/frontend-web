import 'package:flutter/foundation.dart';
import '../models/analytics.dart';
import '../services/analytics_service.dart';

/// Analytics provider for managing analytics state
class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  List<UsageStatsResponse> _utilizationStats = [];
  PeakHoursResponse? _peakHours;
  OverallStatsResponse? _overallStats;
  
  DateTime? _dateRangeStart;
  DateTime? _dateRangeEnd;
  
  bool _isLoading = false;
  String? _error;
  
  List<UsageStatsResponse> get utilizationStats => _utilizationStats;
  PeakHoursResponse? get peakHours => _peakHours;
  OverallStatsResponse? get overallStats => _overallStats;
  DateTime? get dateRangeStart => _dateRangeStart;
  DateTime? get dateRangeEnd => _dateRangeEnd;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load utilization statistics
  Future<void> loadUtilizationStats(
    DateTime startDate,
    DateTime endDate, {
    int? resourceId,
  }) async {
    _isLoading = true;
    _error = null;
    _dateRangeStart = startDate;
    _dateRangeEnd = endDate;
    notifyListeners();
    
    try {
      _utilizationStats = await _analyticsService.getUtilizationStats(
        startDate,
        endDate,
        resourceId: resourceId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load peak hours
  Future<void> loadPeakHours(
    DateTime startTime,
    DateTime endTime,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _peakHours = await _analyticsService.getPeakHours(startTime, endTime);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load overall statistics
  Future<void> loadOverallStats(
    DateTime startTime,
    DateTime endTime,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _overallStats = await _analyticsService.getOverallStats(startTime, endTime);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Set date range
  void setDateRange(DateTime start, DateTime end) {
    _dateRangeStart = start;
    _dateRangeEnd = end;
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

