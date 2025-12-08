/// User role enumeration
enum Role {
  student('STUDENT'),
  faculty('FACULTY'),
  admin('ADMIN');

  final String value;
  const Role(this.value);

  static Role fromString(String value) {
    // Handle backward compatibility: STAFF maps to FACULTY
    final normalizedValue = value.toUpperCase();
    if (normalizedValue == 'STAFF') {
      return Role.faculty;
    }

    return Role.values.firstWhere(
      (role) => role.value == normalizedValue,
      orElse: () => Role.student,
    );
  }
}

/// User model representing a system user
class User {
  final int id;
  final String username;
  final String email;
  final Role role;
  final bool restricted;
  final String? restrictionReason;
  final bool pendingApproval;
  final bool rejected;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.restricted = false,
    this.restrictionReason,
    this.pendingApproval = false,
    this.rejected = false,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: Role.fromString(json['role'] as String? ?? 'STUDENT'),
      restricted: json['restricted'] as bool? ?? false,
      restrictionReason: json['restrictionReason'] as String?,
      pendingApproval: json['pendingApproval'] as bool? ?? false,
      rejected: json['rejected'] as bool? ?? false,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.value,
      'restricted': restricted,
      if (restrictionReason != null) 'restrictionReason': restrictionReason,
      'pendingApproval': pendingApproval,
      'rejected': rejected,
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    Role? role,
    bool? restricted,
    String? restrictionReason,
    bool? pendingApproval,
    bool? rejected,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      restricted: restricted ?? this.restricted,
      restrictionReason: restrictionReason ?? this.restrictionReason,
      pendingApproval: pendingApproval ?? this.pendingApproval,
      rejected: rejected ?? this.rejected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.role == role &&
        other.restricted == restricted &&
        other.restrictionReason == restrictionReason &&
        other.pendingApproval == pendingApproval &&
        other.rejected == rejected;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      email,
      role,
      restricted,
      restrictionReason,
      pendingApproval,
      rejected,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: ${role.value}, restricted: $restricted, pendingApproval: $pendingApproval, rejected: $rejected)';
  }
}
