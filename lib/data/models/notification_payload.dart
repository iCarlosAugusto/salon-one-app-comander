import 'dart:convert';

/// Types of notifications that can trigger navigation
enum NotificationType {
  newAppointment,
  appointmentUpdated,
  appointmentCancelled,
  unknown;

  static NotificationType fromString(String? value) {
    switch (value) {
      case 'new_appointment':
        return NotificationType.newAppointment;
      case 'appointment_updated':
        return NotificationType.appointmentUpdated;
      case 'appointment_cancelled':
        return NotificationType.appointmentCancelled;
      default:
        return NotificationType.unknown;
    }
  }
}

/// Type-safe model for parsing push notification payloads
///
/// Expected payload format:
/// ```json
/// {
///   "appointmentId": "uuid-here",
///   "scheduledDate": "2025-12-20",
///   "type": "new_appointment"
/// }
/// ```
class NotificationPayload {
  final String? appointmentId;
  final DateTime? scheduledDate;
  final NotificationType type;
  final Map<String, dynamic> rawData;

  NotificationPayload({
    this.appointmentId,
    this.scheduledDate,
    this.type = NotificationType.unknown,
    this.rawData = const {},
  });

  /// Parse notification payload from RemoteMessage.data (Map<String, dynamic>)
  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      appointmentId: data['appointmentId'] as String?,
      scheduledDate: _parseDate(data['scheduledDate'] as String?),
      type: NotificationType.fromString(data['type'] as String?),
      rawData: data,
    );
  }

  /// Parse notification payload from JSON string (used in local notifications)
  factory NotificationPayload.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return NotificationPayload();
    }

    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return NotificationPayload.fromMap(data);
    } catch (e) {
      // Return empty payload if parsing fails
      return NotificationPayload();
    }
  }

  /// Convert to JSON string for storing in local notification payload
  String toJsonString() {
    return json.encode(rawData);
  }

  /// Parse date string (yyyy-MM-dd) to DateTime, handling timezone
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }

    try {
      // Parse as local date (yyyy-MM-dd format)
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      // Try ISO 8601 format as fallback
      return DateTime.parse(dateStr).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Check if this payload has valid navigation data
  bool get hasValidData => appointmentId != null || scheduledDate != null;

  /// Get scheduled date or fallback to today
  DateTime get scheduledDateOrToday => scheduledDate ?? DateTime.now();

  @override
  String toString() {
    return 'NotificationPayload(appointmentId: $appointmentId, scheduledDate: $scheduledDate, type: $type)';
  }
}
