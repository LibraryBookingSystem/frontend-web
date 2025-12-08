import '../core/utils/date_utils.dart' as date_utils;

/// Policy rule type enumeration
enum RuleType {
  maxDurationHours('MAX_DURATION_HOURS'),
  advanceBookingDays('ADVANCE_BOOKING_DAYS'),
  maxConcurrentBookings('MAX_CONCURRENT_BOOKINGS'),
  gracePeriodMinutes('GRACE_PERIOD_MINUTES'),
  maxBookingsPerDay('MAX_BOOKINGS_PER_DAY');
  
  final String value;
  const RuleType(this.value);
  
  static RuleType fromString(String value) {
    return RuleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RuleType.maxDurationHours,
    );
  }
}

/// Policy model representing a booking policy rule
class Policy {
  final int id;
  final String name;
  final String? description;
  final RuleType ruleType;
  final String ruleValue;
  final bool active;
  final DateTime createdAt;
  
  const Policy({
    required this.id,
    required this.name,
    this.description,
    required this.ruleType,
    required this.ruleValue,
    this.active = true,
    required this.createdAt,
  });
  
  /// Create Policy from JSON
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      ruleType: RuleType.fromString(json['ruleType'] as String? ?? 'MAX_DURATION_HOURS'),
      ruleValue: json['ruleValue'] as String,
      active: json['active'] as bool? ?? true,
      createdAt: date_utils.AppDateUtils.parseDateTime(json['createdAt'] as String) ?? DateTime.now(),
    );
  }
  
  /// Convert Policy to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'ruleType': ruleType.value,
      'ruleValue': ruleValue,
      'active': active,
      'createdAt': date_utils.AppDateUtils.formatDateTime(createdAt),
    };
  }
  
  /// Create a copy with modified fields
  Policy copyWith({
    int? id,
    String? name,
    String? description,
    RuleType? ruleType,
    String? ruleValue,
    bool? active,
    DateTime? createdAt,
  }) {
    return Policy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ruleType: ruleType ?? this.ruleType,
      ruleValue: ruleValue ?? this.ruleValue,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Get rule value as integer
  int? get ruleValueAsInt => int.tryParse(ruleValue);
  
  /// Get rule value as double
  double? get ruleValueAsDouble => double.tryParse(ruleValue);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Policy &&
        other.id == id &&
        other.name == name &&
        other.ruleType == ruleType &&
        other.ruleValue == ruleValue &&
        other.active == active;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, name, ruleType, ruleValue, active);
  }
  
  @override
  String toString() {
    return 'Policy(id: $id, name: $name, ruleType: ${ruleType.value}, ruleValue: $ruleValue, active: $active)';
  }
}

/// Policy validation response model
class PolicyValidationResponse {
  final bool valid;
  final String message;
  
  const PolicyValidationResponse({
    required this.valid,
    required this.message,
  });
  
  factory PolicyValidationResponse.fromJson(Map<String, dynamic> json) {
    return PolicyValidationResponse(
      valid: json['valid'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'message': message,
    };
  }
}

