import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../data/models/appointment_model.dart';

/// Bottom sheet showing appointment details with actions
class AppointmentDetailsSheet extends StatelessWidget {
  const AppointmentDetailsSheet({
    super.key,
    required this.appointment,
    required this.employeeName,
    required this.onStatusChange,
    required this.onCancel,
  });

  final AppointmentModel appointment;
  final String employeeName;
  final Function(AppointmentStatus) onStatusChange;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: context.appTextTheme.sectionTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.timeRange} • ${appointment.totalDuration} min',
                      style: context.appTextTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppointmentStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          const Divider(),
          const SizedBox(height: AppConstants.spacingMd),

          // Details
          DetailRow(
            icon: Icons.person_outline,
            label: 'Professional',
            value: employeeName,
          ),
          if (appointment.clientPhone.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingSm),
            DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: appointment.clientPhone,
            ),
          ],
          const SizedBox(height: AppConstants.spacingLg),

          // Actions
          if (appointment.status != AppointmentStatus.cancelled &&
              appointment.status != AppointmentStatus.completed) ...[
            Row(
              children: [
                if (appointment.status == AppointmentStatus.pending)
                  Expanded(
                    child: ShadButton(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.confirmed),
                      child: const Text('Confirm'),
                    ),
                  ),
                if (appointment.status == AppointmentStatus.confirmed) ...[
                  Expanded(
                    child: ShadButton(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.inProgress),
                      child: const Text('Start'),
                    ),
                  ),
                ],
                if (appointment.status == AppointmentStatus.inProgress) ...[
                  Expanded(
                    child: ShadButton(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.completed),
                      child: const Text('Complete'),
                    ),
                  ),
                ],
                const SizedBox(width: AppConstants.spacingSm),
                ShadButton.destructive(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }
}

/// Status badge for appointments
class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.capitalize!,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
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
}

/// Detail row for appointment info
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: AppConstants.spacingSm),
        Text(
          '$label: ',
          style: TextStyle(
            color: theme.colorScheme.mutedForeground,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
