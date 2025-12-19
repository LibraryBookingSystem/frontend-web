import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import 'realtime_provider.dart';

/// Booking provider for managing booking state
class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  List<Booking> _userBookings = [];
  Booking? _selectedBooking;

  bool _isLoading = false;
  String? _error;

  // Real-time updates subscription
  StreamSubscription<BookingEvent>? _bookingEventSubscription;
  int? _currentUserId;

  List<Booking> get bookings => _bookings;
  List<Booking> get userBookings => _userBookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize real-time booking updates
  void initializeRealtimeUpdates(
      RealtimeProvider realtimeProvider, int? userId) {
    _currentUserId = userId;

    // Cancel existing subscription if any
    _bookingEventSubscription?.cancel();

    // Listen to booking events from RealtimeProvider
    _bookingEventSubscription = realtimeProvider.bookingEventStream.listen(
      (event) {
        _handleBookingEvent(event);
      },
      onError: (error) {
        // Silently handle errors - real-time updates are optional
        debugPrint('Error in booking event stream: $error');
      },
    );
  }

  /// Handle booking event from real-time updates
  void _handleBookingEvent(BookingEvent event) {
    // Only refresh if the event affects the current user's bookings
    // or if we're viewing all bookings
    final shouldRefresh = _currentUserId == null ||
        event.userId == _currentUserId ||
        _userBookings.any((b) => b.id == event.bookingId);

    if (!shouldRefresh) {
      return;
    }

    switch (event.type) {
      case BookingEventType.created:
        // Refresh user bookings to include the new booking
        if (_currentUserId != null && event.userId == _currentUserId) {
          loadUserBookings(_currentUserId!);
        }
        break;

      case BookingEventType.cancelled:
        // Update the booking status in local lists
        _updateBookingStatus(event.bookingId, BookingStatus.canceled);
        break;

      case BookingEventType.updated:
        // Refresh the specific booking
        if (_userBookings.any((b) => b.id == event.bookingId) ||
            _bookings.any((b) => b.id == event.bookingId)) {
          // Refresh user bookings to get updated data
          if (_currentUserId != null) {
            loadUserBookings(_currentUserId!);
          }
        }
        break;
    }
  }

  /// Update booking status in local lists
  void _updateBookingStatus(int bookingId, BookingStatus status) {
    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex != -1) {
      _bookings[bookingIndex] =
          _bookings[bookingIndex].copyWith(status: status);
    }

    final userBookingIndex = _userBookings.indexWhere((b) => b.id == bookingId);
    if (userBookingIndex != -1) {
      _userBookings[userBookingIndex] =
          _userBookings[userBookingIndex].copyWith(status: status);
    }

    if (_selectedBooking?.id == bookingId) {
      _selectedBooking = _selectedBooking!.copyWith(status: status);
    }

    notifyListeners();
  }

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
        _bookings[index] =
            _bookings[index].copyWith(status: BookingStatus.canceled);
      }

      final userIndex = _userBookings.indexWhere((b) => b.id == id);
      if (userIndex != -1) {
        _userBookings[userIndex] =
            _userBookings[userIndex].copyWith(status: BookingStatus.canceled);
      }

      if (_selectedBooking?.id == id) {
        _selectedBooking =
            _selectedBooking!.copyWith(status: BookingStatus.canceled);
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

  @override
  void dispose() {
    _bookingEventSubscription?.cancel();
    super.dispose();
  }
}
