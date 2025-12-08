/// Application constants
class AppConstants {
  AppConstants._();
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String websocketUrl = 'ws://localhost:8080/ws/availability';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // Polling Configuration
  static const Duration pollingInterval = Duration(seconds: 5);
  
  // WebSocket Configuration
  static const Duration websocketReconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 10;
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Authentication failed. Please login again.';
  static const String notFoundError = 'Resource not found.';
  static const String validationError = 'Invalid input. Please check your data.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String bookingCreated = 'Booking created successfully!';
  static const String bookingCanceled = 'Booking canceled successfully!';
  static const String checkInSuccess = 'Check-in successful!';
  
  // Booking Configuration
  static const Duration defaultGracePeriod = Duration(minutes: 15);
  static const int defaultMaxBookingDurationHours = 4;
  static const int defaultAdvanceBookingDays = 7;
}

