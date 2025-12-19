import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/network/websocket_client.dart';
import '../core/config/app_config.dart';
import '../services/resource_service.dart';
import '../models/resource.dart';

/// Real-time provider for managing WebSocket connections and availability updates
class RealtimeProvider with ChangeNotifier {
  final WebSocketClient _websocketClient = WebSocketClient();
  final ResourceService _resourceService = ResourceService();

  WebSocketState _connectionStatus = WebSocketState.disconnected;
  DateTime? _lastUpdate;
  final Map<int, String> _availabilityMap = {}; // resourceId -> status

  StreamSubscription<WebSocketState>? _stateSubscription;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  Timer? _pollingTimer;
  
  // Callbacks for resource and policy events
  Function(Resource)? onResourceCreated;
  Function(int)? onResourceDeleted;
  Function(Map<String, dynamic>)? onPolicyCreated;
  Function(Map<String, dynamic>)? onPolicyUpdated;
  Function(int)? onPolicyDeleted;

  WebSocketState get connectionStatus => _connectionStatus;
  DateTime? get lastUpdate => _lastUpdate;
  Map<int, String> get availabilityMap => Map.unmodifiable(_availabilityMap);
  bool get isConnected => _connectionStatus == WebSocketState.connected;

  RealtimeProvider() {
    _initialize();
  }

  /// Initialize WebSocket client
  void _initialize() {
    // Listen to state changes
    _stateSubscription = _websocketClient.stateStream.listen((state) {
      _connectionStatus = state;
      
      // Stop polling when WebSocket connects successfully
      if (state == WebSocketState.connected) {
        _pollingTimer?.cancel();
        _pollingTimer = null;
      }
      // Start polling only if WebSocket disconnects or errors
      else if (state == WebSocketState.disconnected || state == WebSocketState.error) {
        if (_pollingTimer == null) {
          _startPollingFallback();
        }
      }
      
      notifyListeners();
    });

    // Listen to messages
    _messageSubscription =
        _websocketClient.messageStream.listen(_handleMessage);
  }

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_connectionStatus == WebSocketState.connected ||
        _connectionStatus == WebSocketState.connecting) {
      return;
    }

    try {
      await _websocketClient.connect();
      // Polling will be stopped automatically when WebSocket connects (via state listener)
    } catch (e) {
      // If WebSocket fails, start polling immediately
      // Don't log errors - WebSocket endpoint may not be available
      if (_connectionStatus != WebSocketState.connected) {
        _startPollingFallback();
      }
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _websocketClient.disconnect();
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Subscribe to resource availability updates
  void subscribeToResource(int resourceId) {
    _websocketClient.subscribe('resource_$resourceId');
  }

  /// Subscribe to multiple resources at once
  void subscribeToResources(List<int> resourceIds) {
    for (final resourceId in resourceIds) {
      subscribeToResource(resourceId);
    }
  }

  /// Unsubscribe from resource availability updates
  void unsubscribeFromResource(int resourceId) {
    _websocketClient.unsubscribe('resource_$resourceId');
  }

  /// Handle incoming WebSocket message
  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;

    if (type == 'availability_update') {
      final resourceId = message['resourceId'];
      final status = message['status'] as String?;

      // Handle both int and string resourceId
      int? id;
      if (resourceId is int) {
        id = resourceId;
      } else if (resourceId is String) {
        id = int.tryParse(resourceId);
      } else if (resourceId is num) {
        id = resourceId.toInt();
      }

      if (id != null && status != null) {
        // Always update, even if status is the same, to ensure UI refreshes
        final oldStatus = _availabilityMap[id];
        _availabilityMap[id] = status;
        _lastUpdate = DateTime.now();
        
        // Debug: Log the update
        debugPrint('RealtimeProvider: Received availability update - resourceId: $id, status: $status (old: $oldStatus)');
        
        // Always notify listeners when we receive an update
        notifyListeners();
      } else {
        debugPrint('RealtimeProvider: Failed to parse update - resourceId: $resourceId, status: $status');
      }
    } else if (type == 'resource_created') {
      // Handle resource creation
      final resourceData = message['resource'] as Map<String, dynamic>?;
      if (resourceData != null) {
        try {
          final resource = Resource.fromJson(resourceData);
          debugPrint('RealtimeProvider: Resource created - ${resource.id} - ${resource.name}');
          
          // Add to availability map
          _availabilityMap[resource.id] = resource.status.value.toLowerCase();
          _lastUpdate = DateTime.now();
          
          // Notify listeners and call callback
          notifyListeners();
          onResourceCreated?.call(resource);
        } catch (e) {
          debugPrint('RealtimeProvider: Failed to parse resource_created: $e');
        }
      }
    } else if (type == 'resource_deleted') {
      // Handle resource deletion
      final resourceId = message['resourceId'];
      int? id;
      if (resourceId is int) {
        id = resourceId;
      } else if (resourceId is String) {
        id = int.tryParse(resourceId);
      } else if (resourceId is num) {
        id = resourceId.toInt();
      }
      
      if (id != null) {
        debugPrint('RealtimeProvider: Resource deleted - $id');
        _availabilityMap.remove(id);
        _lastUpdate = DateTime.now();
        notifyListeners();
        onResourceDeleted?.call(id);
      }
    } else if (type == 'policy_created' || type == 'policy_updated' || type == 'policy_deleted') {
      // Handle policy events
      debugPrint('RealtimeProvider: Policy event - $type');
      _lastUpdate = DateTime.now();
      
      if (type == 'policy_created' && message['policy'] != null) {
        onPolicyCreated?.call(message['policy'] as Map<String, dynamic>);
      } else if (type == 'policy_updated' && message['policy'] != null) {
        onPolicyUpdated?.call(message['policy'] as Map<String, dynamic>);
      } else if (type == 'policy_deleted') {
        final policyId = message['policyId'];
        int? id;
        if (policyId is int) {
          id = policyId;
        } else if (policyId is String) {
          id = int.tryParse(policyId);
        } else if (policyId is num) {
          id = policyId.toInt();
        }
        if (id != null) {
          onPolicyDeleted?.call(id);
        }
      }
      
      notifyListeners();
    } else if (type == 'polling_update') {
      // Polling fallback triggered, refresh resources
      _refreshResources();
    }
  }

  /// Start polling fallback
  void _startPollingFallback() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(AppConfig.pollingInterval, (_) {
      _refreshResources();
    });

    // Initial refresh
    _refreshResources();
  }

  /// Refresh resources (polling fallback)
  /// Only updates resources that aren't already in the map or merges updates
  Future<void> _refreshResources() async {
    // Don't poll if WebSocket is connected - real-time updates are more accurate
    if (_connectionStatus == WebSocketState.connected) {
      return;
    }
    
    try {
      final resources = await _resourceService.getAllResources();

      // Only update availability map for resources we don't have recent updates for
      // This prevents polling from overriding real-time WebSocket updates
      final now = DateTime.now();
      for (final resource in resources) {
        // Only update if we don't have this resource or if last update was more than 10 seconds ago
        if (!_availabilityMap.containsKey(resource.id) || 
            _lastUpdate == null || 
            now.difference(_lastUpdate!).inSeconds > 10) {
          _availabilityMap[resource.id] = resource.status.value;
        }
      }

      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      // Silently fail - polling will retry
    }
  }

  /// Get resource availability status
  String? getResourceStatus(int resourceId) {
    return _availabilityMap[resourceId];
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _messageSubscription?.cancel();
    _pollingTimer?.cancel();
    _websocketClient.dispose();
    super.dispose();
  }
}
