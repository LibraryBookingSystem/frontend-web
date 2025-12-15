import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';

/// WebSocket connection state
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  error,
}

/// WebSocket client with polling fallback
class WebSocketClient {
  WebSocketChannel? _channel;
  WebSocketState _state = WebSocketState.disconnected;
  Timer? _reconnectTimer;
  Timer? _pollingTimer;
  int _reconnectAttempts = 0;

  // Event streams
  final _stateController = StreamController<WebSocketState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  // Subscriptions
  final Set<String> _subscriptions = {};

  // Polling fallback
  bool _usePolling = false;

  /// Get current connection state
  WebSocketState get state => _state;

  /// State stream
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// Message stream
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      return;
    }

    // If we've exceeded max reconnect attempts, don't try again
    if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      if (!_usePolling) {
        _startPollingFallback();
      }
      return;
    }

    _setState(WebSocketState.connecting);

    try {
      final uri = Uri.parse(AppConfig.buildWebSocketUrl());
      _channel = WebSocketChannel.connect(uri);

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          // Silently handle errors - WebSocket endpoint may not be available
          _handleError(error);
        },
        onDone: () {
          _handleDisconnect();
        },
        cancelOnError: false,
      );

      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _usePolling = false;

      debugPrint('WebSocketClient: Connected successfully to ${uri.toString()}');

      // Cancel polling if active
      _pollingTimer?.cancel();

      // Resubscribe to all subscriptions
      for (final subscription in _subscriptions) {
        subscribe(subscription);
      }
    } catch (e) {
      // Silently handle connection errors - WebSocket may not be available
      _handleError(e);
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _reconnectTimer?.cancel();
    _pollingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _setState(WebSocketState.disconnected);
    _reconnectAttempts = 0;
  }

  /// Subscribe to an event
  void subscribe(String event) {
    _subscriptions.add(event);

    if (_state == WebSocketState.connected && _channel != null) {
      // Send both 'topic' and 'event' for compatibility
      _sendMessage({'type': 'subscribe', 'topic': event, 'event': event});
    }
  }

  /// Unsubscribe from an event
  void unsubscribe(String event) {
    _subscriptions.remove(event);

    if (_state == WebSocketState.connected && _channel != null) {
      _sendMessage({'type': 'unsubscribe', 'topic': event, 'event': event});
    }
  }

  /// Send message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (_state == WebSocketState.connected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        _handleError(e);
      }
    }
  }

  /// Handle incoming message
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data) as Map<String, dynamic>;
      debugPrint('WebSocketClient: Received message: $message');
      _messageController.add(message);
    } catch (e) {
      debugPrint('WebSocketClient: Failed to parse message: $e');
      // Invalid JSON, ignore
    }
  }

  /// Handle WebSocket error
  void _handleError(Object error) {
    // Don't spam console with WebSocket errors if endpoint doesn't exist
    // The app will gracefully fall back to polling
    _setState(WebSocketState.error);

    // Start polling fallback immediately
    if (!_usePolling) {
      _startPollingFallback();
    }

    // Only attempt reconnection if we haven't exceeded max attempts
    if (_reconnectAttempts < AppConfig.maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    _setState(WebSocketState.disconnected);

    // Start polling fallback
    if (!_usePolling) {
      _startPollingFallback();
    }

    // Attempt reconnection
    _scheduleReconnect();
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      // Stop trying to reconnect, rely on polling fallback
      return;
    }

    _reconnectTimer?.cancel();

    // Use exponential backoff with a cap
    final backoffMultiplier = (1 << _reconnectAttempts.clamp(0, 4));
    final delay = Duration(
      milliseconds:
          AppConfig.websocketReconnectDelay.inMilliseconds * backoffMultiplier,
    );

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Start polling fallback
  void _startPollingFallback() {
    if (_usePolling) return;

    _usePolling = true;
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(AppConfig.pollingInterval, (_) {
      // Poll for availability updates
      // This would typically call an HTTP endpoint
      // For now, we'll just emit a polling event
      _messageController.add({
        'type': 'polling_update',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Update connection state
  void _setState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}
