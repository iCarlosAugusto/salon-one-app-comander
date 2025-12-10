import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/appointment_model.dart';

/// Individual appointment block displayed in the calendar
class AppointmentBlock extends StatelessWidget {
  const AppointmentBlock({
    super.key,
    required this.appointment,
    required this.employeeName,
    this.onTap,
  });

  final AppointmentModel appointment;
  final String employeeName;
  final VoidCallback? onTap;

  Color get _statusColor {
    switch (appointment.status) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_statusColor, _statusColor.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: _statusColor, width: 4)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: AppConstants.spacingXs,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 50;

                if (isCompact) {
                  // Minimal view for short appointments
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.clientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        appointment.timeRange,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }

                // Full view for longer appointments
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.timeRange,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                    if (constraints.maxHeight > 70) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employeeName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
