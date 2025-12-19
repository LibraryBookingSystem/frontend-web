import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../core/storage/secure_storage.dart';
import '../models/booking.dart';
import '../core/mixins/logging_mixin.dart';
import '../core/interceptors/error_interceptor.dart' show ApiException;

/// Booking service for booking management operations
/// Follows Service-Oriented Architecture (SOA) pattern
/// Uses Aspect-Oriented Programming (AOP) via LoggingMixin
class BookingService with LoggingMixin {
  // Service name for logging (SOA pattern)
  static const String serviceName = 'BookingService';
  
  // Shared API client instance (SOA pattern - service independence)
  final ApiClient _apiClient = ApiClient.instance;
  
  // Secure storage for user context
  final SecureStorage _storage = SecureStorage.instance;
  
  /// Create a new booking
  Future<Booking> createBooking(Map<String, dynamic> request) async {
    logMethodEntry('createBooking', request);
    
    try {
      // JWT token contains userId - backend extracts it automatically
      // No need to send X-User-Id header
      final response = await _apiClient.post(
        AppConfig.createBookingEndpoint,
        body: request,
      );
      
      if (response.statusCode == 201) {
        final booking = Booking.fromJson(jsonDecode(response.body));
        logMethodExit('createBooking', booking);
        return booking;
      } else {
        throw ApiException('Failed to create booking: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Create booking error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get all bookings
  Future<List<Booking>> getAllBookings() async {
    logMethodEntry('getAllBookings');
    
    try {
      final response = await _apiClient.get(AppConfig.allBookingsEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final bookings = data
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getAllBookings', '${bookings.length} bookings');
        return bookings;
      } else {
        throw ApiException('Failed to get bookings: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get all bookings error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get booking by ID
  Future<Booking> getBookingById(int id) async {
    logMethodEntry('getBookingById', {'id': id});
    
    try {
      final response = await _apiClient.get('${AppConfig.bookingByIdEndpoint}/$id');
      
      if (response.statusCode == 200) {
        final booking = Booking.fromJson(jsonDecode(response.body));
        logMethodExit('getBookingById', booking);
        return booking;
      } else {
        throw ApiException('Failed to get booking: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get booking by ID error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get bookings by user ID
  Future<List<Booking>> getBookingsByUserId(int userId) async {
    logMethodEntry('getBookingsByUserId', {'userId': userId});
    
    try {
      final response = await _apiClient.get('${AppConfig.bookingsByUserEndpoint}/$userId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final bookings = data
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getBookingsByUserId', '${bookings.length} bookings');
        return bookings;
      } else {
        throw ApiException('Failed to get user bookings: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get bookings by user ID error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get bookings by resource ID
  Future<List<Booking>> getBookingsByResourceId(int resourceId) async {
    logMethodEntry('getBookingsByResourceId', {'resourceId': resourceId});
    
    try {
      final response = await _apiClient.get('${AppConfig.bookingsByResourceEndpoint}/$resourceId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final bookings = data
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
        logMethodExit('getBookingsByResourceId', '${bookings.length} bookings');
        return bookings;
      } else {
        throw ApiException('Failed to get resource bookings: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get bookings by resource ID error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Update booking
  Future<Booking> updateBooking(int id, Map<String, dynamic> request) async {
    logMethodEntry('updateBooking', {'id': id, ...request});
    
    try {
      // JWT token contains userId - backend extracts it automatically
      final response = await _apiClient.put(
        '${AppConfig.updateBookingEndpoint}/$id',
        body: request,
      );
      
      if (response.statusCode == 200) {
        final booking = Booking.fromJson(jsonDecode(response.body));
        logMethodExit('updateBooking', booking);
        return booking;
      } else {
        throw ApiException('Failed to update booking: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Update booking error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Cancel booking
  Future<void> cancelBooking(int id) async {
    logMethodEntry('cancelBooking', {'id': id});
    
    try {
      // JWT token contains userId - backend extracts it automatically
      final response = await _apiClient.delete(
        '${AppConfig.cancelBookingEndpoint}/$id',
      );
      
      if (response.statusCode != 204) {
        throw ApiException('Failed to cancel booking: ${response.statusCode}');
      }
      
      logMethodExit('cancelBooking');
    } catch (e, stackTrace) {
      logError('Cancel booking error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Check-in to booking using QR code
  Future<Booking> checkIn(String qrCode) async {
    logMethodEntry('checkIn', {'qrCode': qrCode});
    
    try {
      final response = await _apiClient.post(
        AppConfig.checkInEndpoint,
        body: {'qrCode': qrCode},
      );
      
      if (response.statusCode == 200) {
        final booking = Booking.fromJson(jsonDecode(response.body));
        logMethodExit('checkIn', booking);
        return booking;
      } else {
        throw ApiException('Failed to check in: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Check-in error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Get currently booked resource IDs
  Future<List<int>> getBookedResourceIds() async {
    logMethodEntry('getBookedResourceIds');
    
    try {
      final response = await _apiClient.get('${AppConfig.bookingsEndpoint}/booked-resources');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resourceIds = data.map((id) => id as int).toList();
        logMethodExit('getBookedResourceIds', '${resourceIds.length} booked resources');
        return resourceIds;
      } else {
        throw ApiException('Failed to get booked resources: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logError('Get booked resources error', e, stackTrace);
      rethrow;
    }
  }
  
  /// Health check
  Future<String> healthCheck() async {
    try {
      final response = await _apiClient.get(AppConfig.bookingHealthEndpoint);
      if (response.statusCode == 200) {
        return response.body;
      }
      throw ApiException('Health check failed: ${response.statusCode}');
    } catch (e, stackTrace) {
      logError('Health check error', e, stackTrace);
      rethrow;
    }
  }
}

