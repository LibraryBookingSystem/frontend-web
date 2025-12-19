import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';
import 'realtime_provider.dart';

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

  StreamSubscription<BookingEvent>? _bookingEventSubscription;
  StreamSubscription<void>? _realtimeUpdateSubscription;

  List<Resource> get resources => _filteredResources.isEmpty &&
          _searchQuery.isEmpty &&
          _filterType == null &&
          _filterFloor == null &&
          _filterStatus == null
      ? _resources
      : _filteredResources;
  List<Resource> get allResources =>
      _resources; // Get all resources (unfiltered) for getting available options
  Resource? get selectedResource => _selectedResource;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ResourceType? get filterType => _filterType;
  int? get filterFloor => _filterFloor;
  ResourceStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  /// Load resources
  /// Optionally sync with RealtimeProvider for up-to-date availability
  /// [syncWithRealtime]: whether to merge API data with real-time availability
  /// [refresh]: if true, performs a background refresh without setting loading state
  Future<void> loadResources({
    bool syncWithRealtime = true,
    bool refresh = false,
  }) async {
    if (!refresh) {
      _isLoading = true;
      notifyListeners();
    }
    _error = null;

    try {
      final apiResources = await _resourceService.getAllResources(
        type: _filterType,
        floor: _filterFloor,
        status: _filterStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      // Load resources from API
      _resources = apiResources;

      // CRITICAL: Sync with real-time availability AFTER loading
      // Real-time updates take precedence over API data
      if (syncWithRealtime &&
          _realtimeAvailabilityMap != null &&
          _realtimeAvailabilityMap!.isNotEmpty) {
        _syncWithRealtimeAvailability();
      }

      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!refresh) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Availability map from RealtimeProvider (set by screens that have access to both providers)
  Map<int, String>? _realtimeAvailabilityMap;

  /// Set the real-time availability map to sync with
  void setRealtimeAvailabilityMap(Map<int, String>? availabilityMap) {
    // Create a mutable copy to avoid "Cannot modify unmodifiable map" errors
    _realtimeAvailabilityMap =
        availabilityMap != null ? Map<int, String>.from(availabilityMap) : null;
  }

  /// Force notify listeners to trigger UI rebuild
  /// Use after batch updates to ensure UI refreshes
  void forceNotifyListeners() {
    _applyFilters();
    notifyListeners();
    debugPrint('ResourceProvider: Forced notification to listeners');
  }

  /// Sync resources with real-time availability map
  /// This should be called when RealtimeProvider has availability data
  /// Real-time updates ALWAYS take precedence over API data
  void _syncWithRealtimeAvailability() {
    if (_realtimeAvailabilityMap == null || _realtimeAvailabilityMap!.isEmpty) {
      return;
    }

    bool updated = false;

    // Update each resource with real-time availability
    // Real-time data is the source of truth for availability
    for (int i = 0; i < _resources.length; i++) {
      final resource = _resources[i];
      final realtimeStatus = _realtimeAvailabilityMap![resource.id];

      if (realtimeStatus != null) {
        ResourceStatus? status;
        switch (realtimeStatus.toLowerCase()) {
          case 'available':
            status = ResourceStatus.available;
            break;
          case 'unavailable':
            status = ResourceStatus.unavailable;
            break;
          case 'maintenance':
            status = ResourceStatus.maintenance;
            break;
        }

        // ALWAYS update if we have real-time data, even if status appears the same
        // This ensures real-time updates override API data
        if (status != null) {
          _resources[i] = resource.copyWith(status: status);
          updated = true;
        }
      }
    }

    if (updated) {
      _applyFilters();
      notifyListeners();
    }
  }

  /// Sync a specific resource with real-time availability
  void syncResourceWithRealtime(int resourceId, String? statusString) {
    if (statusString == null) return;

    // Ensure we have a mutable map (create copy if needed)
    if (_realtimeAvailabilityMap == null) {
      _realtimeAvailabilityMap = <int, String>{};
    } else {
      // Create a mutable copy if the map is unmodifiable
      _realtimeAvailabilityMap =
          Map<int, String>.from(_realtimeAvailabilityMap!);
    }
    _realtimeAvailabilityMap![resourceId] = statusString;

    ResourceStatus? status;
    switch (statusString.toLowerCase()) {
      case 'available':
        status = ResourceStatus.available;
        break;
      case 'unavailable':
        status = ResourceStatus.unavailable;
        break;
      case 'maintenance':
        status = ResourceStatus.maintenance;
        break;
    }

    if (status != null) {
      updateResourceAvailability(resourceId, status);
    }
  }

  /// Force sync all resources with current real-time availability map
  void syncAllResourcesWithRealtime() {
    if (_realtimeAvailabilityMap == null || _realtimeAvailabilityMap!.isEmpty) {
      return;
    }

    _syncWithRealtimeAvailability();
  }

  /// Apply filters
  void _applyFilters() {
    _filteredResources = _resources.where((resource) {
      if (_filterType != null && resource.type != _filterType) return false;
      if (_filterFloor != null && resource.floor != _filterFloor) return false;
      if (_filterStatus != null && resource.status != _filterStatus)
        return false;
      if (_searchQuery.isNotEmpty &&
          !resource.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
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

  RealtimeProvider? _realtimeProvider;

  /// Initialize real-time updates listener
  void initializeRealtimeUpdates(RealtimeProvider realtimeProvider) {
    _realtimeProvider = realtimeProvider;

    // Cancel existing subscription if any
    _bookingEventSubscription?.cancel();
    _realtimeUpdateSubscription?.cancel();

    // Listen to booking events for immediate updates
    _bookingEventSubscription = realtimeProvider.bookingEventStream.listen(
      (event) {
        if (event.resourceId != null) {
          // When a booking is created, the resource becomes unavailable
          // When a booking is cancelled, we need to check if there are other bookings
          if (event.type == BookingEventType.created) {
            updateResourceAvailability(
                event.resourceId!, ResourceStatus.unavailable);
          } else if (event.type == BookingEventType.cancelled) {
            // Check if resource should be available (no active bookings)
            // For now, mark as available - in production, check actual booking status
            updateResourceAvailability(
                event.resourceId!, ResourceStatus.available);
          } else if (event.type == BookingEventType.updated) {
            // Refresh the resource to get updated status
            _refreshResourceStatus(event.resourceId!);
          }
        }
      },
      onError: (error) {
        // Silently handle errors - real-time updates are optional
        debugPrint('Error in booking event stream: $error');
      },
    );

    // Listen to RealtimeProvider's notifyListeners to sync availability map
    // We'll check the availability map whenever RealtimeProvider notifies
    _realtimeUpdateSubscription =
        Stream.periodic(const Duration(milliseconds: 500)).listen(
      (_) {
        if (_realtimeProvider != null) {
          // Check if RealtimeProvider has updated availability for any of our resources
          for (final resource in _resources) {
            final realtimeStatus =
                _realtimeProvider!.getResourceStatus(resource.id);
            if (realtimeStatus != null) {
              final status = ResourceStatus.fromString(realtimeStatus);
              if (resource.status != status) {
                updateResourceAvailability(resource.id, status);
              }
            }
          }
        }
      },
    );
  }

  /// Refresh resource status from API
  Future<void> _refreshResourceStatus(int resourceId) async {
    try {
      final resources = await _resourceService.getAllResources();
      final updatedResource = resources.firstWhere(
        (r) => r.id == resourceId,
        orElse: () => _resources.firstWhere((r) => r.id == resourceId),
      );

      final index = _resources.indexWhere((r) => r.id == resourceId);
      if (index != -1) {
        _resources[index] = updatedResource;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - will retry on next update
      debugPrint('Error refreshing resource status: $e');
    }
  }

  /// Update resource availability (for real-time updates)
  void updateResourceAvailability(int resourceId, ResourceStatus status) {
    final index = _resources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      final oldStatus = _resources[index].status;
      _resources[index] = _resources[index].copyWith(status: status);

      // Debug: Log the update
      debugPrint(
          'ResourceProvider: Updated resource $resourceId from ${oldStatus.value} to ${status.value}');

      // Always notify if status changed
      if (oldStatus != status) {
        _applyFilters();
        notifyListeners();
        debugPrint('ResourceProvider: Notified listeners of status change');
      }
    } else {
      // Resource not in list yet, but we should still track it
      debugPrint(
          'ResourceProvider: Resource $resourceId not found in list (update will apply when resources load)');
    }
  }

  /// Add a new resource (for real-time resource creation)
  void addResource(Resource resource) {
    // Check if resource already exists
    final existingIndex = _resources.indexWhere((r) => r.id == resource.id);
    if (existingIndex == -1) {
      _resources.add(resource);
      _applyFilters();
      debugPrint(
          'ResourceProvider: Added new resource ${resource.id} - ${resource.name}');
      notifyListeners();
    } else {
      // Update existing resource
      _resources[existingIndex] = resource;
      _applyFilters();
      debugPrint(
          'ResourceProvider: Updated existing resource ${resource.id} - ${resource.name}');
      notifyListeners();
    }
  }

  /// Remove a resource (for real-time resource deletion)
  void removeResource(int resourceId) {
    _resources.removeWhere((r) => r.id == resourceId);
    _applyFilters();
    debugPrint('ResourceProvider: Removed resource $resourceId');
    notifyListeners();
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
