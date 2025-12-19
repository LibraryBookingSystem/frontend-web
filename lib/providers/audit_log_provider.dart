import 'package:flutter/foundation.dart';
import '../models/audit_log.dart';
import '../services/audit_log_service.dart';

/// Audit log provider for managing audit log state
class AuditLogProvider with ChangeNotifier {
  final AuditLogService _auditLogService = AuditLogService();
  
  List<AuditLog> _auditLogs = [];
  AuditLogPage? _currentPage;
  bool _isLoading = false;
  String? _error;
  
  // Filters
  int? _filterUserId;
  String? _filterActionType;
  String? _filterResourceType;
  DateTime? _filterStartTime;
  DateTime? _filterEndTime;
  
  List<AuditLog> get auditLogs => _auditLogs;
  AuditLogPage? get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int? get filterUserId => _filterUserId;
  String? get filterActionType => _filterActionType;
  String? get filterResourceType => _filterResourceType;
  DateTime? get filterStartTime => _filterStartTime;
  DateTime? get filterEndTime => _filterEndTime;
  
  /// Load audit logs with current filters
  Future<void> loadAuditLogs({int page = 0, int size = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final pageResult = await _auditLogService.getAuditLogs(
        userId: _filterUserId,
        actionType: _filterActionType,
        resourceType: _filterResourceType,
        startTime: _filterStartTime,
        endTime: _filterEndTime,
        page: page,
        size: size,
      );
      
      if (page == 0) {
        _auditLogs = pageResult.content;
      } else {
        _auditLogs.addAll(pageResult.content);
      }
      
      _currentPage = pageResult;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Set filters
  void setFilters({
    int? userId,
    String? actionType,
    String? resourceType,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    _filterUserId = userId;
    _filterActionType = actionType;
    _filterResourceType = resourceType;
    _filterStartTime = startTime;
    _filterEndTime = endTime;
    notifyListeners();
  }
  
  /// Clear filters
  void clearFilters() {
    _filterUserId = null;
    _filterActionType = null;
    _filterResourceType = null;
    _filterStartTime = null;
    _filterEndTime = null;
    notifyListeners();
  }
  
  /// Refresh audit logs
  Future<void> refresh() async {
    await loadAuditLogs(page: 0);
  }
  
  /// Load more audit logs (pagination)
  Future<void> loadMore() async {
    if (_currentPage != null && !_currentPage!.last && !_isLoading) {
      await loadAuditLogs(page: _currentPage!.currentPage + 1);
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
