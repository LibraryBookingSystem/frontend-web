import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'interceptor_chain.dart';
import 'error_interceptor.dart' show ApiException;
import '../config/app_config.dart';

/// Enhanced Error Interceptor implementing Interceptor interface (AOP pattern)
class ErrorInterceptorEnhanced extends Interceptor {
  @override
  Future<http.Response> onResponse(http.Response response) async {
    // Process response and throw exception if error
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // Extract error message from response
    String errorMessage = _extractErrorMessage(response);

    // Create appropriate exception
    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  @override
  Future<http.Response> onError(Object error, StackTrace stackTrace) async {
    // Handle network errors
    if (error is! ApiException) {
      throw handleNetworkError(error);
    }
    throw error;
  }

  /// Extract error message from response
  String _extractErrorMessage(http.Response response) {
    try {
      // Try to parse JSON error response
      final body = response.body;
      if (body.isNotEmpty && body.trim().isNotEmpty) {
        // Simple JSON parsing (can be enhanced with json_serializable)
        if (body.contains('"message"') || body.contains("'message'")) {
          final messageMatch =
              RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(body);
          if (messageMatch != null) {
            return messageMatch.group(1) ??
                _getDefaultErrorMessage(response.statusCode);
          }
        }

        if (body.contains('"error"') || body.contains("'error'")) {
          final errorMatch =
              RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(body);
          if (errorMatch != null) {
            return errorMatch.group(1) ??
                _getDefaultErrorMessage(response.statusCode);
          }
        }
      }
    } catch (e) {
      // If parsing fails (including empty body), use default message
      // This handles cases where the response body is empty or invalid JSON
    }

    // Return default message for the status code (handles empty bodies gracefully)
    return _getDefaultErrorMessage(response.statusCode);
  }

  /// Get default error message based on status code
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You do not have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource may have been modified.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred (Status: $statusCode)';
    }
  }

  /// Handle network errors
  ApiException handleNetworkError(Object error) {
    // Log the actual error for debugging
    debugPrint('❌ Network Error Details:');
    debugPrint('Error type: ${error.runtimeType}');
    debugPrint('Error: $error');

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable')) {
      return ApiException(
          'Cannot connect to server. Please check:\n1. Backend is running\n2. Attempting to connect to: ${AppConfig.baseApiUrl}\n3. Your internet connection');
    }

    if (errorString.contains('timeout')) {
      return ApiException('Request timed out. Please try again.');
    }

    return ApiException('Network error: $error');
  }
}
