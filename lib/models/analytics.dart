/// Usage statistics response model
class UsageStatsResponse {
  final int resourceId;
  final String resourceName;
  final int totalBookings;
  final double totalHours;
  final double utilizationRate;
  
  const UsageStatsResponse({
    required this.resourceId,
    required this.resourceName,
    required this.totalBookings,
    required this.totalHours,
    required this.utilizationRate,
  });
  
  factory UsageStatsResponse.fromJson(Map<String, dynamic> json) {
    return UsageStatsResponse(
      resourceId: json['resourceId'] as int,
      resourceName: json['resourceName'] as String? ?? '',
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'resourceName': resourceName,
      'totalBookings': totalBookings,
      'totalHours': totalHours,
      'utilizationRate': utilizationRate,
    };
  }
}

/// Peak hours response model
class PeakHoursResponse {
  final List<int> peakHours;
  final String peakDay;
  final double averageBookingsPerHour;
  
  const PeakHoursResponse({
    required this.peakHours,
    required this.peakDay,
    required this.averageBookingsPerHour,
  });
  
  factory PeakHoursResponse.fromJson(Map<String, dynamic> json) {
    return PeakHoursResponse(
      peakHours: (json['peakHours'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      peakDay: json['peakDay'] as String? ?? '',
      averageBookingsPerHour:
          (json['averageBookingsPerHour'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'peakHours': peakHours,
      'peakDay': peakDay,
      'averageBookingsPerHour': averageBookingsPerHour,
    };
  }
}

/// Overall statistics response model
class OverallStatsResponse {
  final int totalBookings;
  final int totalUsers;
  final int totalResources;
  final double averageBookingDuration;
  final String mostBookedResource;
  
  const OverallStatsResponse({
    required this.totalBookings,
    required this.totalUsers,
    required this.totalResources,
    required this.averageBookingDuration,
    required this.mostBookedResource,
  });
  
  factory OverallStatsResponse.fromJson(Map<String, dynamic> json) {
    return OverallStatsResponse(
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalResources: json['totalResources'] as int? ?? 0,
      averageBookingDuration:
          (json['averageBookingDuration'] as num?)?.toDouble() ?? 0.0,
      mostBookedResource: json['mostBookedResource'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'totalUsers': totalUsers,
      'totalResources': totalResources,
      'averageBookingDuration': averageBookingDuration,
      'mostBookedResource': mostBookedResource,
    };
  }
}

