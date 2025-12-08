import 'dart:convert';

/// Utility class for QR code generation and validation
class QRCodeUtils {
  QRCodeUtils._();
  
  /// QR code data structure separator
  static const String separator = '|';
  
  /// QR code prefix
  static const String prefix = 'BOOKING';
  
  /// Generate QR code data from booking information
  /// Format: BOOKING|{bookingId}|{resourceId}|{timestamp}
  static String generateQRCodeData({
    required int bookingId,
    required int resourceId,
    required DateTime timestamp,
  }) {
    final timestampString = timestamp.toIso8601String();
    return '$prefix$separator$bookingId$separator$resourceId$separator$timestampString';
  }
  
  /// Parse QR code data
  /// Returns map with bookingId, resourceId, and timestamp
  static Map<String, dynamic>? parseQRCodeData(String qrData) {
    try {
      final parts = qrData.split(separator);
      
      if (parts.length != 4) {
        return null;
      }
      
      if (parts[0] != prefix) {
        return null;
      }
      
      final bookingId = int.tryParse(parts[1]);
      final resourceId = int.tryParse(parts[2]);
      final timestamp = DateTime.tryParse(parts[3]);
      
      if (bookingId == null || resourceId == null || timestamp == null) {
        return null;
      }
      
      return {
        'bookingId': bookingId,
        'resourceId': resourceId,
        'timestamp': timestamp,
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Validate QR code format
  static bool isValidQRCodeFormat(String qrData) {
    return parseQRCodeData(qrData) != null;
  }
  
  /// Generate QR code data from JSON (alternative format)
  static String generateQRCodeDataFromJson({
    required int bookingId,
    required int resourceId,
    required DateTime timestamp,
  }) {
    final data = {
      'bookingId': bookingId,
      'resourceId': resourceId,
      'timestamp': timestamp.toIso8601String(),
    };
    return jsonEncode(data);
  }
  
  /// Parse QR code data from JSON
  static Map<String, dynamic>? parseQRCodeDataFromJson(String qrData) {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      
      final bookingId = data['bookingId'] as int?;
      final resourceId = data['resourceId'] as int?;
      final timestampString = data['timestamp'] as String?;
      
      if (bookingId == null || resourceId == null || timestampString == null) {
        return null;
      }
      
      final timestamp = DateTime.tryParse(timestampString);
      if (timestamp == null) {
        return null;
      }
      
      return {
        'bookingId': bookingId,
        'resourceId': resourceId,
        'timestamp': timestamp,
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Check if QR code is expired (older than 24 hours)
  static bool isQRCodeExpired(String qrData, {Duration? maxAge}) {
    final parsed = parseQRCodeData(qrData) ?? parseQRCodeDataFromJson(qrData);
    if (parsed == null) {
      return true;
    }
    
    final timestamp = parsed['timestamp'] as DateTime;
    final age = DateTime.now().difference(timestamp);
    final max = maxAge ?? const Duration(hours: 24);
    
    return age > max;
  }
}

