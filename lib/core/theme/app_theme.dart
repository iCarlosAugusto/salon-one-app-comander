import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../constants/app_colors.dart';

/// App theme configuration using shadcn_ui
class AppTheme {
  AppTheme._();

  /// Dark theme configuration
  static ShadThemeData get darkTheme {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadSlateColorScheme.dark(),
    );
  }

  /// Light theme configuration
  static ShadThemeData get lightTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadSlateColorScheme.light(),
    );
  }
}

/// Extension to get status colors based on appointment status
extension AppointmentStatusColor on String {
  Color get statusColor {
    switch (toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'no_show':
        return AppColors.statusNoShow;
      default:
        return AppColors.mutedForeground;
    }
  }
}
