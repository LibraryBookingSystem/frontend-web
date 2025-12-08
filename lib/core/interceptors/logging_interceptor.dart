import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Log level enumeration
enum LogLevel {
  none,
  basic,
  headers,
  body,
}

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor {
  
  final LogLevel _logLevel;
  
  LoggingInterceptor({LogLevel logLevel = LogLevel.basic})
      : _logLevel = logLevel;
  
  /// Log HTTP request
  void logRequest(http.BaseRequest request) {
    if (_logLevel == LogLevel.none) return;
    
    developer.log(
      '→ ${request.method} ${request.url}',
      name: 'HTTP Request',
    );
    
    if (_logLevel == LogLevel.headers || _logLevel == LogLevel.body) {
      developer.log(
        'Headers: ${request.headers}',
        name: 'HTTP Request',
      );
    }
    
    if (_logLevel == LogLevel.body && request is http.Request) {
      developer.log(
        'Body: ${request.body}',
        name: 'HTTP Request',
      );
    }
  }
  
  /// Log HTTP response
  void logResponse(http.Response response, {Duration? duration}) {
    if (_logLevel == LogLevel.none) return;
    
    final statusEmoji = _getStatusEmoji(response.statusCode);
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    
    developer.log(
      '$statusEmoji ${response.statusCode} ${response.request?.url}$durationStr',
      name: 'HTTP Response',
    );
    
    if (_logLevel == LogLevel.headers || _logLevel == LogLevel.body) {
      developer.log(
        'Headers: ${response.headers}',
        name: 'HTTP Response',
      );
    }
    
    if (_logLevel == LogLevel.body) {
      developer.log(
        'Body: ${response.body}',
        name: 'HTTP Response',
      );
    }
  }
  
  /// Log HTTP error
  void logError(Object error, [StackTrace? stackTrace]) {
    developer.log(
      '✗ Error: $error',
      name: 'HTTP Error',
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Get emoji for HTTP status code
  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✓';
    if (statusCode >= 300 && statusCode < 400) return '→';
    if (statusCode >= 400 && statusCode < 500) return '✗';
    if (statusCode >= 500) return '⚠';
    return '?';
  }
}

