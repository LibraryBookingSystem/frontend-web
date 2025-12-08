import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../interceptors/interceptor_chain.dart';
import '../interceptors/auth_interceptor_enhanced.dart';
import '../interceptors/logging_interceptor_enhanced.dart';
import '../interceptors/error_interceptor_enhanced.dart';
import '../interceptors/retry_interceptor_enhanced.dart';
import '../interceptors/error_interceptor.dart' show ApiException;

/// HTTP API client with interceptor chain support (AOP pattern)
class ApiClient {
  // Private constructor for singleton pattern
  ApiClient._() {
    _initializeInterceptorChain();
  }

  // Singleton instance
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  // HTTP client instance
  final http.Client _client = http.Client();

  // Interceptor chain (AOP pattern)
  final InterceptorChain _interceptorChain = InterceptorChain();

  // Individual interceptors for AOP cross-cutting concerns
  late final AuthInterceptorEnhanced _authInterceptor;
  late final LoggingInterceptorEnhanced _loggingInterceptor;
  late final ErrorInterceptorEnhanced _errorInterceptor;
  late final RetryInterceptorEnhanced _retryInterceptor;

  /// Initialize interceptor chain with all interceptors
  void _initializeInterceptorChain() {
    // Create interceptors
    _authInterceptor = AuthInterceptorEnhanced();
    _loggingInterceptor = LoggingInterceptorEnhanced();
    _errorInterceptor = ErrorInterceptorEnhanced();
    _retryInterceptor = RetryInterceptorEnhanced();

    // Add interceptors to chain in order (AOP aspect weaving)
    // Order matters: Auth -> Logging -> Error -> Retry
    _interceptorChain.addInterceptor(_authInterceptor);
    _interceptorChain.addInterceptor(_loggingInterceptor);
    _interceptorChain.addInterceptor(_errorInterceptor);
    // Retry is handled separately as it wraps the entire execution
  }

  /// GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      () => _buildRequest('GET', endpoint,
          headers: headers, queryParameters: queryParameters),
    );
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      () => _buildRequest('POST', endpoint,
          headers: headers, body: body, queryParameters: queryParameters),
    );
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      () => _buildRequest('PUT', endpoint,
          headers: headers, body: body, queryParameters: queryParameters),
    );
  }

  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      () => _buildRequest('DELETE', endpoint,
          headers: headers, queryParameters: queryParameters),
    );
  }

  /// Build HTTP request
  Future<http.Request> _buildRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    // Build URL
    var url = Uri.parse(AppConfig.buildUrl(endpoint));

    // Add query parameters
    if (queryParameters != null && queryParameters.isNotEmpty) {
      url = url.replace(
          queryParameters:
              queryParameters.map((k, v) => MapEntry(k, v.toString())));
    }

    // Create request
    final request = http.Request(method, url);

    // Add headers
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    });

    // Add body
    if (body != null) {
      if (body is Map || body is List) {
        request.body = jsonEncode(body);
      } else if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
      }
    }

    // Apply auth interceptor if needed (AOP aspect)
    if (_authInterceptor.needsAuthentication(endpoint)) {
      return await _interceptorChain.processRequest(request) as http.Request;
    }

    return request;
  }

  /// Execute request with interceptor chain and retry logic (AOP pattern)
  Future<http.Response> _executeRequest(
    Future<http.Request> Function() requestBuilder,
  ) async {
    debugPrint('🔍 DEBUG: ApiClient._executeRequest started');
    final stopwatch = Stopwatch()..start();

    try {
      // Execute with retry interceptor (wraps entire execution)
      return await _retryInterceptor.executeWithRetry(() async {
        debugPrint('🔍 DEBUG: ApiClient execution closure started');
        // Build request
        final request = await requestBuilder();

        // Execute request through interceptor chain (AOP aspect weaving)
        final streamedResponse =
            await _client.send(request).timeout(AppConfig.requestTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        stopwatch.stop();

        // Process response through interceptor chain
        // This will apply: logging, error handling, auth checks
        return await _interceptorChain.execute(() async => response);
      });
    } catch (e) {
      stopwatch.stop();

      // Process error through interceptor chain (includes logging and error handling)
      try {
        return await _interceptorChain.execute(() async {
          // ignore: use_rethrow_when_possible
          throw e; // Cannot use 'rethrow' here - we're inside a lambda, not a catch clause
        });
      } catch (processedError) {
        // Re-throw ApiException, wrap others
        if (processedError is ApiException) {
          rethrow;
        }

        // Handle network errors (fallback if interceptor chain doesn't handle)
        throw _errorInterceptor.handleNetworkError(processedError);
      }
    }
  }

  /// Close HTTP client
  void close() {
    _client.close();
  }
}
