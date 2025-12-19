import '../core/utils/date_utils.dart' as date_utils;

/// Resource type enumeration
enum ResourceType {
  studyRoom('STUDY_ROOM'),
  groupRoom('GROUP_ROOM'),
  computerStation('COMPUTER_STATION'),
  seat('SEAT');
  
  final String value;
  const ResourceType(this.value);
  
  static ResourceType fromString(String value) {
    return ResourceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ResourceType.studyRoom,
    );
  }
  
  // Legacy support for old enum values
  static ResourceType fromLegacyString(String value) {
    switch (value.toUpperCase()) {
      case 'ROOM':
        return ResourceType.studyRoom;
      case 'EQUIPMENT':
        return ResourceType.computerStation;
      case 'BOOK':
        return ResourceType.seat;
      default:
        return fromString(value);
    }
  }
}

/// Resource status enumeration
enum ResourceStatus {
  available('AVAILABLE'),
  unavailable('UNAVAILABLE'),
  maintenance('MAINTENANCE');
  
  final String value;
  const ResourceStatus(this.value);
  
  static ResourceStatus fromString(String value) {
    return ResourceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ResourceStatus.available,
    );
  }
  
  // Legacy support for old enum values
  static ResourceStatus fromLegacyString(String value) {
    switch (value.toUpperCase()) {
      case 'OCCUPIED':
        return ResourceStatus.unavailable;
      case 'RESERVED':
        return ResourceStatus.available;
      default:
        return fromString(value);
    }
  }
}

/// Resource model representing a bookable library resource
class Resource {
  final int id;
  final String name;
  final String? description;
  final ResourceType type;
  final int floor;
  final int capacity;
  final double? locationX;
  final double? locationY;
  final List<String>? amenities;
  final ResourceStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const Resource({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.floor,
    required this.capacity,
    this.locationX,
    this.locationY,
    this.amenities,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create Resource from JSON
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ResourceType.fromString(json['type'] as String? ?? 'STUDY_ROOM'),
      floor: json['floor'] as int,
      capacity: json['capacity'] as int,
      locationX: (json['locationX'] as num?)?.toDouble(),
      locationY: (json['locationY'] as num?)?.toDouble(),
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities'] as List)
          : null,
      status: ResourceStatus.fromString(json['status'] as String? ?? 'AVAILABLE'),
      createdAt: date_utils.AppDateUtils.parseDateTime(json['createdAt'] as String) ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? date_utils.AppDateUtils.parseDateTime(json['updatedAt'] as String)
          : null,
    );
  }
  
  /// Convert Resource to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'type': type.value,
      'floor': floor,
      'capacity': capacity,
      if (locationX != null) 'locationX': locationX,
      if (locationY != null) 'locationY': locationY,
      if (amenities != null) 'amenities': amenities,
      'status': status.value,
      'createdAt': date_utils.AppDateUtils.formatDateTime(createdAt),
      if (updatedAt != null) 'updatedAt': date_utils.AppDateUtils.formatDateTime(updatedAt!),
    };
  }
  
  /// Create a copy with modified fields
  Resource copyWith({
    int? id,
    String? name,
    String? description,
    ResourceType? type,
    int? floor,
    int? capacity,
    double? locationX,
    double? locationY,
    List<String>? amenities,
    ResourceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      locationX: locationX ?? this.locationX,
      locationY: locationY ?? this.locationY,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if resource is available for booking
  bool get isAvailable => status == ResourceStatus.available;
  
  /// Check if resource is occupied/unavailable
  bool get isOccupied => status == ResourceStatus.unavailable;
  
  /// Check if resource is in maintenance
  bool get isInMaintenance => status == ResourceStatus.maintenance;
  
  /// Check if resource is unavailable (replaces reserved)
  bool get isUnavailable => status == ResourceStatus.unavailable;
  
  /// Check if resource can be booked
  bool get canBeBooked => status == ResourceStatus.available;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Resource &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.floor == floor &&
        other.capacity == capacity &&
        other.status == status;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, name, type, floor, capacity, status);
  }
  
  @override
  String toString() {
    return 'Resource(id: $id, name: $name, type: ${type.value}, floor: $floor, status: ${status.value})';
  }
}

