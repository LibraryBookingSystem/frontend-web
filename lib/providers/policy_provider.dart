import 'package:flutter/foundation.dart';
import '../models/policy.dart';
import '../services/policy_service.dart';

/// Policy provider for managing policy state
class PolicyProvider with ChangeNotifier {
  final PolicyService _policyService = PolicyService();
  
  List<Policy> _policies = [];
  List<Policy> _activePolicies = [];
  Policy? _selectedPolicy;
  
  bool _isLoading = false;
  String? _error;
  
  List<Policy> get policies => _policies;
  List<Policy> get activePolicies => _activePolicies;
  Policy? get selectedPolicy => _selectedPolicy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load all policies
  Future<void> loadPolicies({bool? active}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _policies = await _policyService.getAllPolicies(active: active);
      _activePolicies = _policies.where((p) => p.active).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load active policies
  Future<void> loadActivePolicies() async {
    await loadPolicies(active: true);
  }
  
  /// Create policy
  Future<bool> createPolicy(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final policy = await _policyService.createPolicy(request);
      _policies.add(policy);
      if (policy.active) {
        _activePolicies.add(policy);
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Update policy
  Future<bool> updatePolicy(int id, Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final policy = await _policyService.updatePolicy(id, request);
      
      final index = _policies.indexWhere((p) => p.id == id);
      if (index != -1) {
        _policies[index] = policy;
      }
      
      // Update active policies list
      _activePolicies = _policies.where((p) => p.active).toList();
      
      if (_selectedPolicy?.id == id) {
        _selectedPolicy = policy;
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Delete policy
  Future<bool> deletePolicy(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _policyService.deletePolicy(id);
      _policies.removeWhere((p) => p.id == id);
      _activePolicies.removeWhere((p) => p.id == id);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Validate booking
  Future<PolicyValidationResponse?> validateBooking(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final validation = await _policyService.validateBooking(request);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return validation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Select policy
  void selectPolicy(Policy policy) {
    _selectedPolicy = policy;
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

