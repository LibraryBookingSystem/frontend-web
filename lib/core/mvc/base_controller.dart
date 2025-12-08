import 'package:flutter/foundation.dart';
import '../mixins/logging_mixin.dart';
import '../aspects/aspect_registry.dart';

/// Base Controller class for MVC architecture
/// Integrates with AOP (via LoggingMixin) and SOA (via Services)
///
/// MVC Pattern:
/// - Controller: Coordinates between Model (Services) and View (Widgets)
/// - Uses AOP aspects for cross-cutting concerns (logging, error handling)
/// - Delegates business logic to Services (SOA)
abstract class BaseController with ChangeNotifier, LoggingMixin {
  /// Controller name for logging (AOP aspect)
  String get controllerName;

  /// Error message (if any)
  String? _error;
  String? get error => _error;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Set loading state
  @protected
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
      logDebug('$controllerName: Loading state changed to $value');
    }
  }

  /// Set error message
  @protected
  void setError(String? errorMessage) {
    if (_error != errorMessage) {
      _error = errorMessage;
      notifyListeners();
      if (errorMessage != null) {
        logError('$controllerName: Error set', Exception(errorMessage),
            StackTrace.current);
      }
    }
  }

  /// Clear error
  void clearError() {
    setError(null);
  }

  /// Execute async operation with automatic loading and error handling (AOP aspect)
  @protected
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    setLoading(true);
    setError(null);

    try {
      logMethodEntry('$controllerName.executeWithErrorHandling');
      final result = await operation();
      logMethodExit('$controllerName.executeWithErrorHandling', result);
      return result;
    } catch (e, stackTrace) {
      logError('$controllerName: Operation failed', e, stackTrace);
      setError(errorMessage ?? e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Initialize controller (called when controller is created)
  Future<void> initialize() async {
    logInfo('Initializing $controllerName');
    // Register controller with aspect registry (AOP)
    AspectRegistry.instance.registerAspect('controller.$controllerName', this);
  }

  /// Dispose controller resources
  @override
  void dispose() {
    logInfo('Disposing $controllerName');
    // Unregister from aspect registry (AOP)
    AspectRegistry.instance.unregisterAspect('controller.$controllerName');
    super.dispose();
  }
}
