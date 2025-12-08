/// Aspect Registry for managing AOP aspects across the application
/// This provides a centralized way to register and manage cross-cutting concerns
class AspectRegistry {
  AspectRegistry._();
  
  static final AspectRegistry _instance = AspectRegistry._();
  static AspectRegistry get instance => _instance;
  
  // Registry of active aspects
  final Map<String, dynamic> _aspects = {};
  
  /// Register an aspect
  void registerAspect(String name, dynamic aspect) {
    _aspects[name] = aspect;
  }
  
  /// Get an aspect by name
  T? getAspect<T>(String name) {
    return _aspects[name] as T?;
  }
  
  /// Unregister an aspect
  void unregisterAspect(String name) {
    _aspects.remove(name);
  }
  
  /// Check if aspect is registered
  bool hasAspect(String name) {
    return _aspects.containsKey(name);
  }
  
  /// Get all registered aspect names
  List<String> getRegisteredAspects() {
    return _aspects.keys.toList();
  }
  
  /// Clear all aspects
  void clear() {
    _aspects.clear();
  }
}

/// Aspect types enumeration
enum AspectType {
  logging,
  errorHandling,
  authentication,
  validation,
  caching,
  retry,
  monitoring,
}

