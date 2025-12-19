import '../core/utils/date_utils.dart' as date_utils;

/// Policy model representing a booking policy
/// Matches backend PolicyResponse structure
class Policy {
  final int id;
  final String name;
  final int? maxDurationMinutes;
  final int? maxAdvanceDays;
  final int? maxConcurrentBookings;
  final int? gracePeriodMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Policy({
    required this.id,
    required this.name,
    this.maxDurationMinutes,
    this.maxAdvanceDays,
    this.maxConcurrentBookings,
    this.gracePeriodMinutes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Policy from JSON (matches backend PolicyResponse)
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      maxDurationMinutes: json['maxDurationMinutes'] as int?,
      maxAdvanceDays: json['maxAdvanceDays'] as int?,
      maxConcurrentBookings: json['maxConcurrentBookings'] as int?,
      gracePeriodMinutes: json['gracePeriodMinutes'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? date_utils.AppDateUtils.parseDateTime(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? date_utils.AppDateUtils.parseDateTime(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Policy to JSON for create/update requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxDurationMinutes': maxDurationMinutes,
      'maxAdvanceDays': maxAdvanceDays,
      'maxConcurrentBookings': maxConcurrentBookings,
      'gracePeriodMinutes': gracePeriodMinutes,
    };
  }

  /// Create a copy with modified fields
  Policy copyWith({
    int? id,
    String? name,
    int? maxDurationMinutes,
    int? maxAdvanceDays,
    int? maxConcurrentBookings,
    int? gracePeriodMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Policy(
      id: id ?? this.id,
      name: name ?? this.name,
      maxDurationMinutes: maxDurationMinutes ?? this.maxDurationMinutes,
      maxAdvanceDays: maxAdvanceDays ?? this.maxAdvanceDays,
      maxConcurrentBookings: maxConcurrentBookings ?? this.maxConcurrentBookings,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get max duration in hours for display
  double? get maxDurationHours =>
      maxDurationMinutes != null ? maxDurationMinutes! / 60.0 : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Policy &&
        other.id == id &&
        other.name == name &&
        other.maxDurationMinutes == maxDurationMinutes &&
        other.maxAdvanceDays == maxAdvanceDays &&
        other.maxConcurrentBookings == maxConcurrentBookings &&
        other.gracePeriodMinutes == gracePeriodMinutes &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, maxDurationMinutes, maxAdvanceDays,
        maxConcurrentBookings, gracePeriodMinutes, isActive);
  }

  @override
  String toString() {
    return 'Policy(id: $id, name: $name, maxDurationMinutes: $maxDurationMinutes, '
        'maxAdvanceDays: $maxAdvanceDays, maxConcurrentBookings: $maxConcurrentBookings, '
        'gracePeriodMinutes: $gracePeriodMinutes, isActive: $isActive)';
  }
}

/// Policy validation response model
/// Matches backend PolicyValidationResponse structure
class PolicyValidationResponse {
  final bool valid;
  final List<String> violations;

  const PolicyValidationResponse({
    required this.valid,
    required this.violations,
  });

  factory PolicyValidationResponse.fromJson(Map<String, dynamic> json) {
    return PolicyValidationResponse(
      valid: json['valid'] as bool? ?? true,
      violations: json['violations'] != null
          ? List<String>.from(json['violations'] as List)
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'violations': violations,
    };
  }

  /// Get formatted message from violations
  String get message {
    if (valid || violations.isEmpty) {
      return 'Booking is valid';
    }
    return violations.join('\n');
  }

  /// Check if there are any violations
  bool get hasViolations => !valid && violations.isNotEmpty;
}
