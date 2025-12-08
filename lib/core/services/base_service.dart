import '../network/api_client.dart';
import '../mixins/logging_mixin.dart';

/// Base service interface for Service-Oriented Architecture (SOA)
/// All services should extend or implement this pattern
abstract class BaseService with LoggingMixin {
  /// API client instance (shared across all services)
  final ApiClient apiClient = ApiClient.instance;
  
  /// Service name for logging
  String get serviceName;
  
  /// Health check method (should be implemented by all services)
  Future<String> healthCheck();
  
  /// Initialize service (optional)
  Future<void> initialize() async {
    logInfo('Initializing $serviceName');
  }
  
  /// Dispose service resources (optional)
  void dispose() {
    logInfo('Disposing $serviceName');
  }
}

