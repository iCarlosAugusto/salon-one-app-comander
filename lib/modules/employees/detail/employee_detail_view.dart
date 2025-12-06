import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/layouts/admin_layout.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/widgets/page_components.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'employee_detail_controller.dart';

/// Employee detail view - displays employee profile, schedule, and services
class EmployeeDetailView extends GetView<EmployeeDetailController> {
  const EmployeeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.employees,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'Loading employee...');
        }

        if (controller.hasError.value) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        final employee = controller.employee.value;
        if (employee == null) {
          return const ErrorState(message: 'Employee not found');
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = ShadTheme.of(context);
    final employee = controller.employee.value!;

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                onPressed: controller.goBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  'Employee Details',
                  style: TextStyle(
                    color: theme.colorScheme.foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ShadButton.outline(
                onPressed: controller.navigateToEdit,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 4),
                    Text('Edit'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Profile card
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ShadCard(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  children: [
                    UserAvatar(
                      imageUrl: employee.avatar,
                      initials: employee.initials,
                      size: 80,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      employee.fullName,
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        Formatters.capitalize(employee.role),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    if (employee.email != null)
                      _DetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: employee.email!,
                      ),
                    if (employee.phone != null)
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: Formatters.formatPhone(employee.phone!),
                      ),
                    if (employee.hiredAt != null)
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Hired',
                        value: employee.hiredAt!,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Schedule section
          _buildScheduleSection(context),
          const SizedBox(height: AppConstants.spacingLg),

          // Services section
          _buildServicesSection(context),
          const SizedBox(height: AppConstants.spacingLg),

          // Delete button
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ShadButton.destructive(
                onPressed: () => _showDeleteDialog(context),
                child: Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isDeleting.value)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.delete_outline, size: 18),
                      const SizedBox(width: 8),
                      const Text('Delete Employee'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ShadCard(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Schedule',
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Obx(() {
                if (controller.schedules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      child: Text(
                        'No schedule configured',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.schedules
                      .map(
                        (schedule) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spacingSm,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  schedule.shortDayName,
                                  style: TextStyle(
                                    color: theme.colorScheme.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  schedule.isAvailable
                                      ? schedule.timeRange
                                      : 'Off',
                                  style: TextStyle(
                                    color: schedule.isAvailable
                                        ? theme.colorScheme.foreground
                                        : theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                              Icon(
                                schedule.isAvailable
                                    ? Icons.check_circle
                                    : Icons.remove_circle,
                                size: 18,
                                color: schedule.isAvailable
                                    ? AppColors.success
                                    : theme.colorScheme.mutedForeground,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ShadCard(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Services',
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Obx(() {
                if (controller.services.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      child: Text(
                        'No services assigned',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: AppConstants.spacingSm,
                  runSpacing: AppConstants.spacingSm,
                  children: controller.services
                      .map(
                        (service) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd,
                            ),
                          ),
                          child: Text(
                            service.name,
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Employee',
      message:
          'Are you sure you want to delete "${controller.employee.value?.fullName}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteEmployee();
    }
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            '$label: ',
            style: TextStyle(color: theme.colorScheme.mutedForeground),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: theme.colorScheme.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
