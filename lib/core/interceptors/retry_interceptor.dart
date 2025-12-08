import 'dart:async';
import 'package:http/http.dart' as http;

/// Interceptor for retrying failed HTTP requests
class RetryInterceptor {
  final int maxRetries;
  final Duration baseDelay;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });
  
  /// Execute request with retry logic
  Future<http.Response> executeWithRetry(
    Future<http.Response> Function() requestFunction,
  ) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final response = await requestFunction();
        
        // Retry on 5xx errors or network errors
        if (_shouldRetry(response.statusCode)) {
          attempt++;
          if (attempt >= maxRetries) {
            return response; // Return last response after max retries
          }
          
          // Exponential backoff
          final delay = Duration(
            milliseconds: baseDelay.inMilliseconds * (1 << (attempt - 1)),
          );
          await Future.delayed(delay);
          continue;
        }
        
        return response;
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow; // Re-throw after max retries
        }
        
        // Only retry on network errors, not on 4xx errors
        if (!_isNetworkError(e)) {
          rethrow;
        }
        
        // Exponential backoff
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * (1 << (attempt - 1)),
        );
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
  
  /// Check if status code should trigger retry
  bool _shouldRetry(int statusCode) {
    // Retry on 5xx server errors
    return statusCode >= 500 && statusCode < 600;
  }
  
  /// Check if error is a network error (retryable)
  bool _isNetworkError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('timeout') ||
        errorString.contains('network');
  }
}

