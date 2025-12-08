import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

/// Interceptor for adding authentication headers to HTTP requests
class AuthInterceptor {
  final SecureStorage _storage = SecureStorage.instance;

  /// Intercept request and add authentication headers
  Future<http.BaseRequest> interceptRequest(http.BaseRequest request) async {
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

  /// Handle 401 unauthorized responses
  Future<bool> handleUnauthorized() async {
    // Clear stored tokens on unauthorized
    await _storage.clearAll();
    return false; // Indicates authentication failed
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
