import 'package:intl/intl.dart' as intl;

/// Utility class for date and time operations
class AppDateUtils {
  AppDateUtils._();
  
  /// Format date as YYYY-MM-DD
  static String formatDate(DateTime date) {
    return intl.DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format DateTime as ISO 8601 string (YYYY-MM-DDTHH:mm:ss)
  static String formatDateTime(DateTime dateTime) {
    return intl.DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }
  
  /// Format DateTime for display (e.g., "Dec 4, 2025 10:30 AM")
  static String formatDateTimeDisplay(DateTime dateTime) {
    return intl.DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
  }
  
  /// Format time for display (e.g., "10:30 AM")
  static String formatTime(DateTime dateTime) {
    return intl.DateFormat('hh:mm a').format(dateTime);
  }
  
  /// Parse date from YYYY-MM-DD string
  static DateTime? parseDate(String dateString) {
    try {
      return intl.DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse DateTime from ISO 8601 string
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  /// Calculate duration between two DateTime objects in hours
  static double calculateDurationHours(DateTime start, DateTime end) {
    return end.difference(start).inMinutes / 60.0;
  }
  
  /// Calculate duration between two DateTime objects as Duration
  static Duration calculateDuration(DateTime start, DateTime end) {
    return end.difference(start);
  }
  
  /// Format duration as "X hours Y minutes"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  
  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  /// Get time remaining until a DateTime
  static Duration? timeRemaining(DateTime target) {
    final now = DateTime.now();
    if (target.isAfter(now)) {
      return target.difference(now);
    }
    return null;
  }
  
  /// Format time remaining as "X hours Y minutes remaining"
  static String formatTimeRemaining(DateTime target) {
    final remaining = timeRemaining(target);
    if (remaining == null) {
      return 'Expired';
    }
    return '${formatDuration(remaining)} remaining';
  }
  
  /// Check if DateTime is within a time window (for check-in)
  static bool isWithinTimeWindow(DateTime startTime, DateTime endTime, {Duration? gracePeriod}) {
    final now = DateTime.now();
    final grace = gracePeriod ?? const Duration(minutes: 15);
    final windowStart = startTime.subtract(grace);
    final windowEnd = endTime.add(grace);
    
    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  /// Compare dates ignoring time
  static int compareDates(DateTime date1, DateTime date2) {
    final d1 = startOfDay(date1);
    final d2 = startOfDay(date2);
    return d1.compareTo(d2);
  }
}

