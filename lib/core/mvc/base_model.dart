import '../services/base_service.dart';
import '../mixins/logging_mixin.dart';
import '../aspects/aspect_registry.dart';

/// Base Model class for MVC architecture
/// Integrates with SOA (Services) and AOP (LoggingMixin)
///
/// MVC Pattern:
/// - Model: Represents data and business logic
/// - Uses Services (SOA) for business operations
/// - Uses AOP aspects for cross-cutting concerns (logging)
///
/// Note: In Flutter, Models are typically data classes.
/// This base class provides integration with Services and AOP.
abstract class BaseModel with LoggingMixin {
  /// Model name for logging (AOP aspect)
  String get modelName;

  /// Associated service for business operations (SOA)
  BaseService? get service;

  /// Initialize model
  Future<void> initialize() async {
    logInfo('Initializing $modelName');
    // Register model with aspect registry (AOP)
    AspectRegistry.instance.registerAspect('model.$modelName', this);
  }

  /// Dispose model resources
  void dispose() {
    logInfo('Disposing $modelName');
    // Unregister from aspect registry (AOP)
    AspectRegistry.instance.unregisterAspect('model.$modelName');
  }

  /// Validate model data
  bool validate() {
    logDebug('Validating $modelName');
    return true; // Override in subclasses
  }

  /// Convert model to JSON (for serialization)
  Map<String, dynamic> toJson();

  /// Create model from JSON (for deserialization)
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclass');
  }
}
