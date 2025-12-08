import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import 'interceptor_chain.dart';

/// Enhanced Auth Interceptor implementing Interceptor interface (AOP pattern)
class AuthInterceptorEnhanced extends Interceptor {
  final SecureStorage _storage = SecureStorage.instance;

  @override
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    // Get JWT token from secure storage
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Get user ID from secure storage
    final userId = await _storage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      request.headers['X-User-Id'] = userId;
    }

    // Get user role from secure storage (for backend authorization checks)
    final userRole = await _storage.getUserRole();
    if (userRole != null && userRole.isNotEmpty) {
      request.headers['X-User-Role'] = userRole;
    }

    return request;
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    // Handle 401 unauthorized responses
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  /// Handle unauthorized response
  Future<void> _handleUnauthorized() async {
    // Clear stored tokens on unauthorized
    await _storage.clearAll();
  }

  /// Check if request needs authentication
  bool needsAuthentication(String url) {
    // Public endpoints that don't need authentication
    final publicEndpoints = [
      '/api/auth/register',
      '/api/auth/login',
      '/api/auth/health',
      '/api/health',
      '/api/resources/health',
      '/api/bookings/health',
      '/api/policies/health',
      '/api/notifications/health',
      '/api/analytics/health',
    ];

    return !publicEndpoints.any((endpoint) => url.contains(endpoint));
  }
}
