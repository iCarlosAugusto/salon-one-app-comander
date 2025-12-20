import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/notification_payload.dart';
import '../../shared/routes/app_routes.dart';
import '../../modules/appointments/appointments_controller.dart';

/// Centralized service for handling navigation from push notifications
///
/// Handles:
/// - Navigation to Appointments screen with date filter
/// - Edge cases: already on target screen, invalid dates
/// - Different app states: terminated, background, foreground
class NotificationNavigationService extends GetxService {
  /// Navigate based on notification payload
  ///
  /// Called when user taps a notification (from any app state)
  void navigateFromNotification(NotificationPayload payload) {
    debugPrint('Navigating from notification: $payload');

    if (!payload.hasValidData) {
      debugPrint('No valid navigation data in payload, skipping navigation');
      return;
    }

    switch (payload.type) {
      case NotificationType.newAppointment:
      case NotificationType.appointmentUpdated:
      case NotificationType.appointmentCancelled:
        _navigateToAppointments(payload.scheduledDateOrToday);
        break;
      case NotificationType.unknown:
        // For unknown types, still try to navigate if we have a date
        if (payload.scheduledDate != null) {
          _navigateToAppointments(payload.scheduledDate!);
        }
        break;
    }
  }

  /// Navigate to Appointments screen with specified date filter
  void _navigateToAppointments(DateTime date) {
    // Check if already on Appointments screen
    if (_isOnAppointmentsScreen()) {
      _updateAppointmentsDate(date);
    } else {
      _pushAppointmentsScreen(date);
    }
  }

  /// Check if currently on appointments screen
  bool _isOnAppointmentsScreen() {
    final currentRoute = Get.currentRoute;
    return currentRoute == Routes.appointments;
  }

  /// Update date on existing Appointments screen (avoid duplicate screens)
  void _updateAppointmentsDate(DateTime date) {
    debugPrint('Already on Appointments, updating date to: $date');

    try {
      final controller = Get.find<AppointmentsController>();
      controller.setCalendarDate(date);
    } catch (e) {
      // Controller not found, fallback to navigation
      debugPrint('AppointmentsController not found, navigating instead');
      _pushAppointmentsScreen(date);
    }
  }

  /// Push Appointments screen with date argument
  void _pushAppointmentsScreen(DateTime date) {
    debugPrint('Navigating to Appointments with date: $date');

    // Use offAllNamed to clear stack and go to appointments
    // This ensures clean navigation from any state
    Get.offAllNamed(Routes.appointments, arguments: {'initialDate': date});
  }

  /// Navigate to appointments with date (public convenience method)
  void goToAppointmentsWithDate(DateTime date) {
    _navigateToAppointments(date);
  }
}
