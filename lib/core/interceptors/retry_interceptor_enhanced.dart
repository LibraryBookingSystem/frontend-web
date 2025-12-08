import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'interceptor_chain.dart';

/// Enhanced Retry Interceptor implementing Interceptor interface (AOP pattern)
class RetryInterceptorEnhanced extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptorEnhanced({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  @override
  Future<http.Response> onResponse(http.Response response) async {
    // Retry logic is handled at the chain level, not per response
    // This interceptor wraps the entire request execution
    return response;
  }

  @override
  Future<http.Response> onError(Object error, StackTrace stackTrace) async {
    // Retry logic is handled at the chain level
    throw error;
  }

  /// Execute request with retry logic (wrapper method)
  Future<http.Response> executeWithRetry(
    Future<http.Response> Function() requestFunction,
  ) async {
    debugPrint('🔍 DEBUG: RetryInterceptor.executeWithRetry started');
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        debugPrint(
            '🔍 DEBUG: RetryInterceptor calling requestFunction (Attempt ${attempt + 1})');
        final response = await requestFunction();
        debugPrint('🔍 DEBUG: RetryInterceptor requestFunction returned');

        // Retry on 5xx errors
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
