import 'dart:async';
import 'package:flutter/foundation.dart';
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
    } catch (e) {
      // If WebSocket fails, start polling immediately
      // Don't log errors - WebSocket endpoint may not be available
      _startPollingFallback();
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

  /// Unsubscribe from resource availability updates
  void unsubscribeFromResource(int resourceId) {
    _websocketClient.unsubscribe('resource_$resourceId');
  }

  /// Handle incoming WebSocket message
  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;

    if (type == 'availability_update') {
      final resourceId = message['resourceId'] as int?;
      final status = message['status'] as String?;

      if (resourceId != null && status != null) {
        _availabilityMap[resourceId] = status;
        _lastUpdate = DateTime.now();
        notifyListeners();
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
  Future<void> _refreshResources() async {
    try {
      final resources = await _resourceService.getAllResources();

      // Update availability map
      for (final resource in resources) {
        _availabilityMap[resource.id] = resource.status.value;
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
