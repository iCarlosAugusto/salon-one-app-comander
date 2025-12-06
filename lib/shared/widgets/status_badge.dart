import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/appointment_model.dart';

/// Badge showing appointment status with appropriate color
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.medium,
  });

  final AppointmentStatus status;
  final StatusBadgeSize size;

  Color get _backgroundColor {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.statusPending.withValues(alpha: 0.15);
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed.withValues(alpha: 0.15);
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgress.withValues(alpha: 0.15);
      case AppointmentStatus.completed:
        return AppColors.statusCompleted.withValues(alpha: 0.15);
      case AppointmentStatus.cancelled:
        return AppColors.statusCancelled.withValues(alpha: 0.15);
      case AppointmentStatus.noShow:
        return AppColors.statusNoShow.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.statusPending;
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed;
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgress;
      case AppointmentStatus.completed:
        return AppColors.statusCompleted;
      case AppointmentStatus.cancelled:
        return AppColors.statusCancelled;
      case AppointmentStatus.noShow:
        return AppColors.statusNoShow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = size == StatusBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final fontSize = size == StatusBadgeSize.small ? 10.0 : 12.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusBadgeSize { small, medium }

/// Generic badge for displaying labels
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.muted;
    final textColor = color ?? theme.colorScheme.foreground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
