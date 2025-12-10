import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/page_components.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/appointment_model.dart';
import 'appointments_controller.dart';
import 'widgets/day_calendar_view.dart';

/// Appointments list view
class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.appointments,
      child: Stack(
        children: [
          Obx(() {
            final isCalendarMode =
                controller.viewMode.value == AppointmentViewMode.calendar;

            return Column(
              children: [
                _buildHeader(context),
                if (isCalendarMode) _buildDaySelector(context),
                Expanded(child: _buildContent(context, isCalendarMode)),
              ],
            );
          }),
          // FAB
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(Routes.appointmentForm),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isCalendarMode) {
    if (controller.isLoading.value) {
      return const LoadingState(message: 'Loading appointments...');
    }

    if (controller.hasError.value) {
      return ErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.refresh,
      );
    }

    if (isCalendarMode) {
      return _buildCalendarView(context);
    }

    final appointments = controller.filteredAppointments;

    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today,
        title: 'No appointments found',
        message: controller.appointments.isEmpty
            ? 'Create your first appointment to get started'
            : 'Try adjusting your filters',
        action: controller.appointments.isEmpty
            ? () => Get.toNamed(Routes.appointmentForm)
            : controller.clearFilters,
        actionLabel: controller.appointments.isEmpty
            ? 'New Appointment'
            : 'Clear Filters',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primary,
      child: _buildAppointmentsList(context, appointments),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final appointments = controller.appointmentsForCalendarDate;

    return DayCalendarView(
      selectedDate: controller.calendarDate.value,
      appointments: appointments,
      getEmployeeName: controller.getEmployeeName,
      onAppointmentTap: (apt) => _showAppointmentDetails(context, apt),
      onTimeSlotTap: (time) {
        // Could open new appointment form with pre-filled time
        Get.toNamed(Routes.appointmentForm);
      },
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final theme = ShadTheme.of(context);
    final calendarDate = controller.calendarDate.value;
    final now = DateTime.now();

    // Generate 7 days centered on selected date
    final startOfWeek = calendarDate.subtract(
      Duration(days: calendarDate.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Column(
        children: [
          // Month and navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(calendarDate),
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.mutedForeground,
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.goToPreviousDay,
                    icon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme.foreground,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  ShadButton.ghost(
                    onPressed: controller.goToToday,
                    size: ShadButtonSize.sm,
                    child: const Text('Hoje'),
                  ),
                  IconButton(
                    onPressed: controller.goToNextDay,
                    icon: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.foreground,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          // Week day selector
          Row(
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isSelected =
                  date.year == calendarDate.year &&
                  date.month == calendarDate.month &&
                  date.day == calendarDate.day;
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setCalendarDate(date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _weekdayAbbr(date.weekday),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.mutedForeground,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday && !isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? AppColors.primary
                                  : theme.colorScheme.foreground,
                              fontSize: 14,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _weekdayAbbr(int weekday) {
    const abbrs = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
    return abbrs[weekday - 1];
  }

  void _showAppointmentDetails(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    Get.bottomSheet(
      _AppointmentDetailsSheet(
        appointment: appointment,
        employeeName: controller.getEmployeeName(appointment.employeeId),
        onStatusChange: (status) =>
            controller.updateStatus(appointment.id, status),
        onCancel: () => _showCancelDialog(context, appointment),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointments',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Obx(
                    () => Text(
                      '${controller.todayCount} today • ${controller.pendingCount} pending',
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Obx(
                    () => ShadButton.outline(
                      onPressed: controller.toggleViewMode,
                      size: ShadButtonSize.sm,
                      child: Icon(
                        controller.viewMode.value == AppointmentViewMode.list
                            ? Icons.calendar_month
                            : Icons.list,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  ShadButton(
                    onPressed: () => Get.toNamed(Routes.appointmentForm),
                    size: ShadButtonSize.sm,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 4),
                        Text('New'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildFilters(context),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: [
        // Employee filter
        Obx(
          () => _FilterChip(
            label: controller.selectedEmployeeId.value != null
                ? controller.getEmployeeName(
                    controller.selectedEmployeeId.value,
                  )
                : 'All employees',
            isSelected: controller.selectedEmployeeId.value != null,
            onTap: () => _showEmployeeFilter(context),
            onClear: controller.selectedEmployeeId.value != null
                ? () => controller.selectedEmployeeId.value = null
                : null,
          ),
        ),
        // Status filter
        Obx(
          () => _FilterChip(
            label:
                controller.selectedStatus.value?.displayName ?? 'All statuses',
            isSelected: controller.selectedStatus.value != null,
            onTap: () => _showStatusFilter(context),
            onClear: controller.selectedStatus.value != null
                ? () => controller.selectedStatus.value = null
                : null,
          ),
        ),
      ],
    );
  }

  void _showEmployeeFilter(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: ShadTheme.of(context).colorScheme.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Employee',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...controller.employees.map(
              (employee) => ListTile(
                leading: UserAvatar(initials: employee.initials, size: 36),
                title: Text(employee.fullName),
                trailing: controller.selectedEmployeeId.value == employee.id
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  controller.selectedEmployeeId.value = employee.id;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: ShadTheme.of(context).colorScheme.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Status',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...AppointmentStatus.values.map(
              (status) => ListTile(
                leading: StatusBadge(status: status),
                title: Text(status.displayName),
                trailing: controller.selectedStatus.value == status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  controller.selectedStatus.value = status;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<AppointmentModel> appointments,
  ) {
    return ListView.builder(
      padding: Responsive.padding(context),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return _AppointmentCard(
          appointment: apt,
          employeeName: controller.getEmployeeName(apt.employeeId),
          onStatusChange: (status) => controller.updateStatus(apt.id, status),
          onCancel: () => _showCancelDialog(context, apt),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: ShadTheme.of(context).colorScheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Text(
                    'Cancel Appointment',
                    style: TextStyle(
                      color: ShadTheme.of(context).colorScheme.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'Are you sure you want to cancel this appointment with ${appointment.clientName}?',
                style: TextStyle(
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ShadInput(
                controller: reasonController,
                placeholder: const Text('Reason for cancellation (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShadButton.outline(
                    onPressed: () => Get.back(),
                    child: const Text('Keep'),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  ShadButton.destructive(
                    onPressed: () {
                      Get.back();
                      controller.cancelAppointment(
                        appointment.id,
                        reason: reasonController.text.isNotEmpty
                            ? reasonController.text
                            : null,
                      );
                    },
                    child: const Text('Cancel Appointment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSm,
            vertical: AppConstants.spacingXs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.foreground,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.mutedForeground,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
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
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: ShadCard(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  initials: Formatters.getInitials(appointment.clientName),
                  size: 48,
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appointment.clientName,
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StatusBadge(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatDate(appointment.date),
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.timeRange,
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            employeeName,
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          Text(
                            Formatters.formatCurrency(appointment.totalPrice),
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (appointment.canBeCancelled) ...[
              const SizedBox(height: AppConstants.spacingMd),
              const Divider(height: 1),
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (appointment.status == AppointmentStatus.pending)
                    ShadButton.outline(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.confirmed),
                      size: ShadButtonSize.sm,
                      child: const Text('Confirm'),
                    ),
                  if (appointment.status == AppointmentStatus.confirmed)
                    ShadButton.outline(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.inProgress),
                      size: ShadButtonSize.sm,
                      child: const Text('Start'),
                    ),
                  if (appointment.status == AppointmentStatus.inProgress)
                    ShadButton(
                      onPressed: () =>
                          onStatusChange(AppointmentStatus.completed),
                      size: ShadButtonSize.sm,
                      child: const Text('Complete'),
                    ),
                  const SizedBox(width: AppConstants.spacingSm),
                  ShadButton.ghost(
                    onPressed: onCancel,
                    size: ShadButtonSize.sm,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for appointment details (calendar mode)
class _AppointmentDetailsSheet extends StatelessWidget {
  const _AppointmentDetailsSheet({
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
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          // Client info
          Row(
            children: [
              UserAvatar(
                initials: Formatters.getInitials(appointment.clientName),
                size: 48,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appointment.clientPhone,
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Divider(),
          const SizedBox(height: AppConstants.spacingMd),
          // Details
          _DetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: appointment.timeRange,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _DetailRow(
            icon: Icons.person,
            label: 'Employee',
            value: employeeName,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _DetailRow(
            icon: Icons.attach_money,
            label: 'Total',
            value: Formatters.formatCurrency(appointment.totalPrice),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          // Actions
          if (appointment.canBeCancelled)
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () {
                      Get.back();
                      onCancel();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                if (appointment.status == AppointmentStatus.pending)
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        Get.back();
                        onStatusChange(AppointmentStatus.confirmed);
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                if (appointment.status == AppointmentStatus.confirmed)
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        Get.back();
                        onStatusChange(AppointmentStatus.inProgress);
                      },
                      child: const Text('Start'),
                    ),
                  ),
                if (appointment.status == AppointmentStatus.inProgress)
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        Get.back();
                        onStatusChange(AppointmentStatus.completed);
                      },
                      child: const Text('Complete'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
