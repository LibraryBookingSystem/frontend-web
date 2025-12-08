import 'package:http/http.dart' as http;

  /// Base interface for all interceptors (AOP pattern)
abstract class Interceptor {
  /// Intercept request before sending
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    return request;
  }
  
  /// Intercept response after receiving
  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }
  
  /// Intercept error
  Future<http.Response> onError(Object error, StackTrace stackTrace) async {
    throw error;
  }
}

/// Interceptor chain manager for AOP cross-cutting concerns
class InterceptorChain {
  final List<Interceptor> _interceptors = [];
  
  /// Add interceptor to chain
  void addInterceptor(Interceptor interceptor) {
    _interceptors.add(interceptor);
  }
  
  /// Remove interceptor from chain
  void removeInterceptor(Interceptor interceptor) {
    _interceptors.remove(interceptor);
  }
  
  /// Execute request through interceptor chain
  Future<http.Response> execute(
    Future<http.Response> Function() requestFunction,
  ) async {
    try {
      // Execute request
      http.Response response = await requestFunction();
      
      // Process response through interceptor chain
      for (final interceptor in _interceptors) {
        response = await interceptor.onResponse(response);
      }
      
      return response;
    } catch (e, stackTrace) {
      // Process error through interceptor chain
      Object lastError = e;
      for (final interceptor in _interceptors) {
        try {
          final result = await interceptor.onError(lastError, stackTrace);
          // If interceptor returns a response, use it
          return result;
        } catch (handledError) {
          // If interceptor throws, continue with that error
          lastError = handledError;
        }
      }
      // Re-throw the last error
      throw lastError;
    }
  }
  
  /// Process request through interceptor chain
  Future<http.BaseRequest> processRequest(http.BaseRequest request) async {
    http.BaseRequest processedRequest = request;
    
    for (final interceptor in _interceptors) {
      processedRequest = await interceptor.onRequest(processedRequest);
    }
    
    return processedRequest;
  }
}

