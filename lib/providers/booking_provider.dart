import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

/// Booking provider for managing booking state
class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  List<Booking> _bookings = [];
  List<Booking> _userBookings = [];
  Booking? _selectedBooking;
  
  bool _isLoading = false;
  String? _error;
  
  List<Booking> get bookings => _bookings;
  List<Booking> get userBookings => _userBookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Create booking
  Future<Booking?> createBooking(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final booking = await _bookingService.createBooking(request);
      _bookings.add(booking);
      _userBookings.add(booking);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Load all bookings
  Future<void> loadAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _bookings = await _bookingService.getAllBookings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load user bookings
  Future<void> loadUserBookings(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userBookings = await _bookingService.getBookingsByUserId(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Get booking by ID
  Future<Booking?> getBookingById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final booking = await _bookingService.getBookingById(id);
      _selectedBooking = booking;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Update booking
  Future<bool> updateBooking(int id, Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final booking = await _bookingService.updateBooking(id, request);
      
      // Update in lists
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = booking;
      }
      
      final userIndex = _userBookings.indexWhere((b) => b.id == id);
      if (userIndex != -1) {
        _userBookings[userIndex] = booking;
      }
      
      if (_selectedBooking?.id == id) {
        _selectedBooking = booking;
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Cancel booking
  Future<bool> cancelBooking(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _bookingService.cancelBooking(id);
      
      // Update status in lists
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: BookingStatus.canceled);
      }
      
      final userIndex = _userBookings.indexWhere((b) => b.id == id);
      if (userIndex != -1) {
        _userBookings[userIndex] = _userBookings[userIndex].copyWith(status: BookingStatus.canceled);
      }
      
      if (_selectedBooking?.id == id) {
        _selectedBooking = _selectedBooking!.copyWith(status: BookingStatus.canceled);
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Check-in to booking
  Future<Booking?> checkIn(String qrCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final booking = await _bookingService.checkIn(qrCode);
      
      // Update in lists
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        _bookings[index] = booking;
      }
      
      final userIndex = _userBookings.indexWhere((b) => b.id == booking.id);
      if (userIndex != -1) {
        _userBookings[userIndex] = booking;
      }
      
      if (_selectedBooking?.id == booking.id) {
        _selectedBooking = booking;
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Select booking
  void selectBooking(Booking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }
  
  /// Get currently booked resource IDs
  Future<List<int>> getBookedResourceIds() async {
    try {
      return await _bookingService.getBookedResourceIds();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

