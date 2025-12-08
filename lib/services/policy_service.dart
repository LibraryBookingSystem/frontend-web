import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../models/policy.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Policy service for policy management operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class PolicyService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'PolicyService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get all policies
  Future<List<Policy>> getAllPolicies({bool? active}) async {
    logMethodEntry('getAllPolicies', {'active': active});
    
    try {
      final queryParams = active != null ? {'active': active.toString()} : null;
      
      final response = await _apiClient.get(
        AppConfig.allPoliciesEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final policies = data
            .map((json) => Policy.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getAllPolicies', '${policies.length} policies');
        return policies;
      } else {
        throw ApiException('Failed to get policies: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get all policies error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get policy by ID
  Future<Policy> getPolicyById(int id) async {
    logMethodEntry('getPolicyById', {'id': id});
    
    try {
      final response = await _apiClient.get('${AppConfig.policyByIdEndpoint}/$id');
      
      if (response.statusCode == 200) {
        final policy = Policy.fromJson(jsonDecode(response.body));
        logMethodExit('getPolicyById', policy);
        return policy;
      } else {
        throw ApiException('Failed to get policy: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get policy by ID error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Create a new policy
  Future<Policy> createPolicy(Map<String, dynamic> request) async {
    logMethodEntry('createPolicy', request);
    
    try {
      final response = await _apiClient.post(
        AppConfig.createPolicyEndpoint,
        body: request,
      );
      
      if (response.statusCode == 201) {
        final policy = Policy.fromJson(jsonDecode(response.body));
        logMethodExit('createPolicy', policy);
        return policy;
      } else {
        throw ApiException('Failed to create policy: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Create policy error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Update policy
  Future<Policy> updatePolicy(int id, Map<String, dynamic> request) async {
    logMethodEntry('updatePolicy', {'id': id, ...request});
    
    try {
      final response = await _apiClient.put(
        '${AppConfig.updatePolicyEndpoint}/$id',
        body: request,
      );
      
      if (response.statusCode == 200) {
        final policy = Policy.fromJson(jsonDecode(response.body));
        logMethodExit('updatePolicy', policy);
        return policy;
      } else {
        throw ApiException('Failed to update policy: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Update policy error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Delete policy
  Future<void> deletePolicy(int id) async {
    logMethodEntry('deletePolicy', {'id': id});
    
    try {
      final response = await _apiClient.delete('${AppConfig.deletePolicyEndpoint}/$id');
      
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete policy: ${response.statusCode}');
      }
      
      logMethodExit('deletePolicy');
    } catch (e, stackTrace) {
      logError('Delete policy error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Validate booking request against policies
  Future<PolicyValidationResponse> validateBooking(Map<String, dynamic> request) async {
    logMethodEntry('validateBooking', request);
    
    try {
      final response = await _apiClient.post(
        AppConfig.validatePolicyEndpoint,
        body: request,
      );
      
      if (response.statusCode == 200) {
        final validation = PolicyValidationResponse.fromJson(jsonDecode(response.body));
        logMethodExit('validateBooking', validation);
        return validation;
      } else {
        throw ApiException('Failed to validate booking: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Validate booking error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.policyHealthEndpoint);
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

