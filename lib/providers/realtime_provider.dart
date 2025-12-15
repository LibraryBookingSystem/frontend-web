import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/network/websocket_client.dart';
import '../core/config/app_config.dart';
import '../services/resource_service.dart';

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
