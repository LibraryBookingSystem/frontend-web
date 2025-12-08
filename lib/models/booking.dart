import '../core/utils/date_utils.dart' as date_utils;

/// Booking status enumeration
enum BookingStatus {
  confirmed('CONFIRMED'),
  checkedIn('CHECKED_IN'),
  completed('COMPLETED'),
  canceled('CANCELED'),
  noShow('NO_SHOW');
  
  final String value;
  const BookingStatus(this.value);
  
  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}

/// Booking model representing a resource booking
class Booking {
  final int id;
  final int userId;
  final int resourceId;
  final String resourceName;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final String? qrCode;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  
  const Booking({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.qrCode,
    this.checkedInAt,
    required this.createdAt,
  });
  
  /// Create Booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      userId: json['userId'] as int,
      resourceId: json['resourceId'] as int,
      resourceName: json['resourceName'] as String? ?? '',
      startTime: date_utils.AppDateUtils.parseDateTime(json['startTime'] as String) ?? DateTime.now(),
      endTime: date_utils.AppDateUtils.parseDateTime(json['endTime'] as String) ?? DateTime.now(),
      status: BookingStatus.fromString(json['status'] as String? ?? 'CONFIRMED'),
      qrCode: json['qrCode'] as String?,
      checkedInAt: json['checkedInAt'] != null
          ? date_utils.AppDateUtils.parseDateTime(json['checkedInAt'] as String)
          : null,
      createdAt: date_utils.AppDateUtils.parseDateTime(json['createdAt'] as String) ?? DateTime.now(),
    );
  }
  
  /// Convert Booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
      'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
      'status': status.value,
      if (qrCode != null) 'qrCode': qrCode,
      if (checkedInAt != null) 'checkedInAt': date_utils.AppDateUtils.formatDateTime(checkedInAt!),
      'createdAt': date_utils.AppDateUtils.formatDateTime(createdAt),
    };
  }
  
  /// Create a copy with modified fields
  Booking copyWith({
    int? id,
    int? userId,
    int? resourceId,
    String? resourceName,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    String? qrCode,
    DateTime? checkedInAt,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Check if booking is active (confirmed or checked in)
  bool get isActive => status == BookingStatus.confirmed || status == BookingStatus.checkedIn;
  
  /// Check if booking can be checked in
  bool canCheckIn({Duration? gracePeriod}) {
    if (status != BookingStatus.confirmed) {
      return false;
    }
    return date_utils.AppDateUtils.isWithinTimeWindow(startTime, endTime, gracePeriod: gracePeriod);
  }
  
  /// Check if booking can be canceled
  bool get canCancel => status == BookingStatus.confirmed || status == BookingStatus.checkedIn;
  
  /// Get time remaining until booking starts
  Duration? get timeUntilStart {
    final now = DateTime.now();
    if (startTime.isAfter(now)) {
      return startTime.difference(now);
    }
    return null;
  }
  
  /// Get time remaining until booking ends
  Duration? get timeUntilEnd {
    final now = DateTime.now();
    if (endTime.isAfter(now)) {
      return endTime.difference(now);
    }
    return null;
  }
  
  /// Get booking duration
  Duration get duration => endTime.difference(startTime);
  
  /// Check if booking is in the past
  bool get isPast => endTime.isBefore(DateTime.now());
  
  /// Check if booking is upcoming
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  
  /// Check if booking is currently active (between start and end time)
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.userId == userId &&
        other.resourceId == resourceId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.status == status;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, userId, resourceId, startTime, endTime, status);
  }
  
  @override
  String toString() {
    return 'Booking(id: $id, resource: $resourceName, status: ${status.value}, start: ${date_utils.AppDateUtils.formatDateTimeDisplay(startTime)})';
  }
}

