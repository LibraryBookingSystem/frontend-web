/// Mixin providing validation methods for forms and inputs
mixin ValidationMixin {
  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  /// Password strength regex (at least 8 characters, one letter, one number)
  static final RegExp _passwordStrengthRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );
  
  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password strength
  String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    if (!_passwordStrengthRegex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }
  
  /// Validate required field
  String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate username (alphanumeric and underscores, 3-20 characters)
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3 || value.length > 20) {
      return 'Username must be between 3 and 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
  
  /// Validate password confirmation
  String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Validate date is not in the past
  String? validateDateNotPast(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    if (date.isBefore(DateTime.now())) {
      return 'Date cannot be in the past';
    }
    return null;
  }
  
  /// Validate time range (end time must be after start time)
  String? validateTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return 'Both start and end times are required';
    }
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return 'End time must be after start time';
    }
    return null;
  }
  
  /// Validate duration (minimum and maximum hours)
  String? validateDuration(
    DateTime startTime,
    DateTime endTime, {
    double? minHours,
    double? maxHours,
  }) {
    final duration = endTime.difference(startTime);
    final hours = duration.inMinutes / 60.0;
    
    if (minHours != null && hours < minHours) {
      return 'Booking duration must be at least ${minHours.toStringAsFixed(1)} hours';
    }
    
    if (maxHours != null && hours > maxHours) {
      return 'Booking duration cannot exceed ${maxHours.toStringAsFixed(1)} hours';
    }
    
    return null;
  }
  
  /// Validate numeric value
  String? validateNumeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
  
  /// Validate positive integer
  String? validatePositiveInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return '$fieldName must be a valid number';
    }
    if (intValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
  
  /// Validate non-empty string
  String? validateNonEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }
}

