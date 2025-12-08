import 'package:flutter/foundation.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';

/// Resource provider for managing resource state
class ResourceProvider with ChangeNotifier {
  final ResourceService _resourceService = ResourceService();
  
  List<Resource> _resources = [];
  List<Resource> _filteredResources = [];
  Resource? _selectedResource;
  
  ResourceType? _filterType;
  int? _filterFloor;
  ResourceStatus? _filterStatus;
  String _searchQuery = '';
  
  bool _isLoading = false;
  String? _error;
  
  List<Resource> get resources => _filteredResources.isEmpty && _searchQuery.isEmpty && _filterType == null && _filterFloor == null && _filterStatus == null
      ? _resources
      : _filteredResources;
  Resource? get selectedResource => _selectedResource;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  ResourceType? get filterType => _filterType;
  int? get filterFloor => _filterFloor;
  ResourceStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  
  /// Load resources
  Future<void> loadResources() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _resources = await _resourceService.getAllResources(
        type: _filterType,
        floor: _filterFloor,
        status: _filterStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Apply filters
  void _applyFilters() {
    _filteredResources = _resources.where((resource) {
      if (_filterType != null && resource.type != _filterType) return false;
      if (_filterFloor != null && resource.floor != _filterFloor) return false;
      if (_filterStatus != null && resource.status != _filterStatus) return false;
      if (_searchQuery.isNotEmpty && !resource.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
  
  /// Filter resources
  void filterResources({
    ResourceType? type,
    int? floor,
    ResourceStatus? status,
    String? search,
  }) {
    _filterType = type;
    _filterFloor = floor;
    _filterStatus = status;
    _searchQuery = search ?? '';
    _applyFilters();
    notifyListeners();
  }
  
  /// Search resources
  void searchResources(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  
  /// Clear filters
  void clearFilters() {
    _filterType = null;
    _filterFloor = null;
    _filterStatus = null;
    _searchQuery = '';
    _filteredResources = [];
    notifyListeners();
  }
  
  /// Refresh resources
  Future<void> refreshResources() async {
    await loadResources();
  }
  
  /// Select resource
  void selectResource(Resource resource) {
    _selectedResource = resource;
    notifyListeners();
  }
  
  /// Update resource availability (for real-time updates)
  void updateResourceAvailability(int resourceId, ResourceStatus status) {
    final index = _resources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      _resources[index] = _resources[index].copyWith(status: status);
      _applyFilters();
      notifyListeners();
    }
  }
  
  /// Create resource
  Future<bool> createResource(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final resource = await _resourceService.createResource(request);
      _resources.add(resource);
      _applyFilters();
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
  
  /// Update resource
  Future<bool> updateResource(int id, Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final resource = await _resourceService.updateResource(id, request);
      final index = _resources.indexWhere((r) => r.id == id);
      if (index != -1) {
        _resources[index] = resource;
        _applyFilters();
      }
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
  
  /// Delete resource
  Future<bool> deleteResource(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _resourceService.deleteResource(id);
      _resources.removeWhere((r) => r.id == id);
      _applyFilters();
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
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

