import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;

/// Utility class for date and time operations
/// Uses system timezone - times are displayed in user's local timezone
class AppDateUtils {
  AppDateUtils._();
  
  /// Format date as YYYY-MM-DD
  static String formatDate(DateTime date) {
    return intl.DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format DateTime as ISO 8601 string in UTC (YYYY-MM-DDTHH:mm:ssZ)
  /// User selects times in local timezone, converts to UTC for backend storage
  static String formatDateTime(DateTime dateTime) {
    // User selects time in local timezone, convert to UTC for storage
    final utcDateTime = dateTime.toUtc();
    return '${intl.DateFormat('yyyy-MM-ddTHH:mm:ss').format(utcDateTime)}Z';
  }
  
  /// Format DateTime for display in local timezone (e.g., "Dec 4, 2025 10:30 AM")
  static String formatDateTimeDisplay(DateTime dateTime) {
    // Backend sends UTC, convert to local time for display
    final localTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return intl.DateFormat('MMM d, yyyy hh:mm a', 'en_US').format(localTime);
  }
  
  /// Format time for display in local timezone (e.g., "10:30 AM")
  static String formatTime(DateTime dateTime) {
    // Backend sends UTC, convert to local time for display
    final localTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return intl.DateFormat('hh:mm a', 'en_US').format(localTime);
  }
  
  /// Parse date from YYYY-MM-DD string
  static DateTime? parseDate(String dateString) {
    try {
      return intl.DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse DateTime from ISO 8601 string (handles UTC times with 'Z' suffix)
  /// Backend sends times in UTC but sometimes WITHOUT 'Z' suffix
  /// IMPORTANT: We treat ALL backend times as UTC, even without 'Z'
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      // Backend stores all times in UTC, but serializes without 'Z' suffix
      // We need to explicitly parse as UTC by adding 'Z' if missing
      String utcString = dateTimeString;
      if (!dateTimeString.endsWith('Z') && !dateTimeString.contains('+') && !dateTimeString.contains('-', 10)) {
        // No timezone indicator - backend sends UTC times, so add 'Z'
        utcString = '${dateTimeString}Z';
      }
      
      final parsed = DateTime.parse(utcString);
      
      if (kDebugMode) {
        debugPrint('🔍 DEBUG: Parsed time "$dateTimeString" -> "$utcString" -> $parsed (isUtc=${parsed.isUtc})');
      }
      
      return parsed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ERROR: Failed to parse DateTime "$dateTimeString": $e');
      }
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
  
  /// Check if date is today (in local timezone)
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final localDate = date.isUtc ? date.toLocal() : date;
    return localDate.year == now.year &&
        localDate.month == now.month &&
        localDate.day == now.day;
  }
  
  /// Check if date is in the past (in local timezone)
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final localDate = date.isUtc ? date.toLocal() : date;
    return localDate.isBefore(now);
  }
  
  /// Check if date is in the future (in local timezone)
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final localDate = date.isUtc ? date.toLocal() : date;
    return localDate.isAfter(now);
  }
  
  /// Get time remaining until a DateTime (in local timezone)
  static Duration? timeRemaining(DateTime target) {
    final now = DateTime.now();
    final localTarget = target.isUtc ? target.toLocal() : target;
    if (localTarget.isAfter(now)) {
      return localTarget.difference(now);
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
  
  /// Check if DateTime is within a time window (for check-in, in local timezone)
  static bool isWithinTimeWindow(DateTime startTime, DateTime endTime, {Duration? gracePeriod}) {
    final now = DateTime.now();
    final localStart = startTime.isUtc ? startTime.toLocal() : startTime;
    final localEnd = endTime.isUtc ? endTime.toLocal() : endTime;
    final grace = gracePeriod ?? const Duration(minutes: 15);
    final windowStart = localStart.subtract(grace);
    final windowEnd = localEnd.add(grace);
    
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

  /// Format relative time (e.g., "2 hours ago", "Just now", "Yesterday")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return formatDateTimeDisplay(dateTime);
    }
  }
}

