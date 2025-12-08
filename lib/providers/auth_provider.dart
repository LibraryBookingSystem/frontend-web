import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../services/auth_service.dart';

/// Authentication provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider and check authentication status
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authService.isAuthenticated();
      if (hasToken) {
        await getCurrentUser();
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 DEBUG: AuthProvider.login started');
      final request = LoginRequest(username: username, password: password);
      print('🔍 DEBUG: Calling _authService.login');
      final response = await _authService.login(request);
      print('🔍 DEBUG: _authService.login returned');

      _currentUser = response.user;
      _isAuthenticated = true;
      _error = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register user
  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);

      _currentUser = response.user;
      _isAuthenticated = true;
      _error = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _isAuthenticated = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    final hasToken = await _authService.isAuthenticated();
    if (hasToken && _currentUser == null) {
      await getCurrentUser();
    } else if (!hasToken) {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
