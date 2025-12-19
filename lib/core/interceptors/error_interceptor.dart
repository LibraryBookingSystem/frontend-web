import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  
  ApiException(this.message, {this.statusCode, this.responseBody});
  
  @override
  String toString() => message;
}

/// Interceptor for handling HTTP errors
class ErrorInterceptor {
  /// Process response and throw exception if error
  http.Response processResponse(http.Response response) {
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
  
  /// Extract error message from response
  String _extractErrorMessage(http.Response response) {
    try {
      // Try to parse JSON error response
      final body = response.body;
      if (body.isNotEmpty) {
        // Try to parse as JSON first
        try {
          final json = jsonDecode(body);
          if (json is Map<String, dynamic>) {
            // Check for message field
            if (json.containsKey('message')) {
              return json['message'] as String? ?? _getDefaultErrorMessage(response.statusCode);
            }
            // Check for error field
            if (json.containsKey('error')) {
              return json['error'] as String? ?? _getDefaultErrorMessage(response.statusCode);
            }
          }
        } catch (_) {
          // Not valid JSON, try regex parsing
        }
        
        // Simple JSON parsing fallback (can be enhanced with json_serializable)
        if (body.contains('"message"') || body.contains("'message'")) {
          final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"')
              .firstMatch(body);
          if (messageMatch != null) {
            return messageMatch.group(1) ?? _getDefaultErrorMessage(response.statusCode);
          }
        }
        
        if (body.contains('"error"') || body.contains("'error'")) {
          final errorMatch = RegExp(r'"error"\s*:\s*"([^"]+)"')
              .firstMatch(body);
          if (errorMatch != null) {
            return errorMatch.group(1) ?? _getDefaultErrorMessage(response.statusCode);
          }
        }
      }
    } catch (e) {
      // If parsing fails, use default message
    }
    
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
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused')) {
      return ApiException('Network error. Please check your internet connection.');
    }
    
    if (errorString.contains('timeout')) {
      return ApiException('Request timed out. Please try again.');
    }
    
    return ApiException('Network error: $error');
  }
}

