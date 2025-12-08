import 'dart:developer' as developer;

/// Log level enumeration
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Mixin providing logging capabilities for classes
mixin LoggingMixin {
  
  /// Check if debug logging is enabled (can be configured)
  bool get isDebugEnabled => true; // Can be made configurable
  
  /// Log a debug message
  void logDebug(String message, [Object? error, StackTrace? stackTrace]) {
    if (isDebugEnabled) {
      developer.log(
        message,
        name: runtimeType.toString(),
        level: 100, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Log an info message
  void logInfo(String message) {
    developer.log(
      message,
      name: runtimeType.toString(),
      level: 800, // Info level
    );
  }
  
  /// Log a warning message
  void logWarning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: runtimeType.toString(),
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log an error message
  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: runtimeType.toString(),
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log method entry
  void logMethodEntry(String methodName, [Map<String, dynamic>? parameters]) {
    if (isDebugEnabled) {
      final params = parameters != null ? ' with parameters: $parameters' : '';
      logDebug('Entering $methodName$params');
    }
  }
  
  /// Log method exit
  void logMethodExit(String methodName, [Object? result]) {
    if (isDebugEnabled) {
      final resultStr = result != null ? ' with result: $result' : '';
      logDebug('Exiting $methodName$resultStr');
    }
  }
  
  /// Log state change
  void logStateChange(String stateName, dynamic oldValue, dynamic newValue) {
    if (isDebugEnabled) {
      logDebug('State change: $stateName from $oldValue to $newValue');
    }
  }
  
  /// Log user action
  void logUserAction(String action, [Map<String, dynamic>? details]) {
    logInfo('User action: $action${details != null ? ' - $details' : ''}');
  }
  
  /// Log performance metric
  void logPerformance(String operation, Duration duration) {
    if (isDebugEnabled) {
      logDebug('Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }
}

