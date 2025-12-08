import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../models/resource.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Resource service for resource catalog operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class ResourceService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'ResourceService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get all resources with optional filters
  Future<List<Resource>> getAllResources({
    ResourceType? type,
    int? floor,
    ResourceStatus? status,
    String? search,
  }) async {
    logMethodEntry('getAllResources', {
      'type': type?.value,
      'floor': floor,
      'status': status?.value,
      'search': search,
    });
    
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type.value;
      if (floor != null) queryParams['floor'] = floor.toString();
      if (status != null) queryParams['status'] = status.value;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final response = await _apiClient.get(
        AppConfig.allResourcesEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resources = data
            .map((json) => Resource.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getAllResources', '${resources.length} resources');
        return resources;
      } else {
        throw ApiException('Failed to get resources: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get all resources error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get resource by ID
  Future<Resource> getResourceById(int id) async {
    logMethodEntry('getResourceById', {'id': id});
    
    try {
      final response = await _apiClient.get('${AppConfig.resourceByIdEndpoint}/$id');
      
      if (response.statusCode == 200) {
        final resource = Resource.fromJson(jsonDecode(response.body));
        logMethodExit('getResourceById', resource);
        return resource;
      } else {
        throw ApiException('Failed to get resource: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get resource by ID error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Create a new resource
  Future<Resource> createResource(Map<String, dynamic> request) async {
    logMethodEntry('createResource', request);
    
    try {
      final response = await _apiClient.post(
        AppConfig.createResourceEndpoint,
        body: request,
      );
      
      if (response.statusCode == 201) {
        final resource = Resource.fromJson(jsonDecode(response.body));
        logMethodExit('createResource', resource);
        return resource;
      } else {
        throw ApiException('Failed to create resource: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Create resource error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Update resource
  Future<Resource> updateResource(int id, Map<String, dynamic> request) async {
    logMethodEntry('updateResource', {'id': id, ...request});
    
    try {
      final response = await _apiClient.put(
        '${AppConfig.updateResourceEndpoint}/$id',
        body: request,
      );
      
      if (response.statusCode == 200) {
        final resource = Resource.fromJson(jsonDecode(response.body));
        logMethodExit('updateResource', resource);
        return resource;
      } else {
        throw ApiException('Failed to update resource: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Update resource error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Delete resource
  Future<void> deleteResource(int id) async {
    logMethodEntry('deleteResource', {'id': id});
    
    try {
      final response = await _apiClient.delete('${AppConfig.deleteResourceEndpoint}/$id');
      
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete resource: ${response.statusCode}');
      }
      
      logMethodExit('deleteResource');
    } catch (e, stackTrace) {
      logError('Delete resource error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Search resources by name
  Future<List<Resource>> searchResources(String query) async {
    return getAllResources(search: query);
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.resourceHealthEndpoint);
      if (response.statusCode == 200) {
        return response.body;
      }
      throw ApiException('Health check failed: ${response.statusCode}');
    } catch (e, stackTrace) {
      logError('Health check error', e, stackTrace);
      rethrow;
    }
  }
}

