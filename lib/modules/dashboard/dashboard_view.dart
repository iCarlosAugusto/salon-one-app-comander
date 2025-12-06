import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/page_components.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/appointment_model.dart';
import 'dashboard_controller.dart';

/// Dashboard view displaying overview statistics and quick access
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.dashboard,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'Loading dashboard...');
        }

        if (controller.hasError.value) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Responsive.padding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStatsGrid(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildMainContent(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = ShadTheme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontSize: Responsive.value(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Obx(
          () => Text(
            controller.salon.value?.name ?? 'Welcome to your dashboard',
            style: TextStyle(
              color: theme.colorScheme.mutedForeground,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  Widget _buildStatsGrid(BuildContext context) {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 2,
      desktopColumns: 4,
      children: [
        Obx(
          () => StatCard(
            title: "Today's Appointments",
            value: controller.totalAppointmentsToday.value.toString(),
            subtitle: '${controller.completedToday.value} completed',
            icon: Icons.calendar_today,
            iconColor: AppColors.primary,
          ),
        ),
        Obx(
          () => StatCard(
            title: "Today's Revenue",
            value: Formatters.formatCurrency(controller.totalRevenue.value),
            subtitle: 'From completed appointments',
            icon: Icons.attach_money,
            iconColor: AppColors.success,
          ),
        ),
        Obx(
          () => StatCard(
            title: 'Active Employees',
            value: controller.activeEmployees.value.toString(),
            subtitle: '${controller.employees.length} total',
            icon: Icons.people,
            iconColor: AppColors.info,
          ),
        ),
        Obx(
          () => StatCard(
            title: 'Active Services',
            value: controller.activeServices.value.toString(),
            subtitle: '${controller.services.length} total',
            icon: Icons.spa,
            iconColor: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        children: [
          _buildUpcomingAppointments(context),
          const SizedBox(height: AppConstants.spacingLg),
          _buildQuickActions(context),
        ],
      ),
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildUpcomingAppointments(context)),
          const SizedBox(width: AppConstants.spacingLg),
          Expanded(child: _buildQuickActions(context)),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ShadButton.ghost(
                onPressed: () => Get.toNamed(Routes.appointments),
                size: ShadButtonSize.sm,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Obx(() {
            if (controller.upcomingAppointments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingLg,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        'No upcoming appointments',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.upcomingAppointments.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final apt = controller.upcomingAppointments[index];
                return _AppointmentListTile(appointment: apt);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: theme.colorScheme.foreground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'New Appointment',
            onTap: () => Get.toNamed(Routes.appointmentForm),
          ),
          _QuickActionButton(
            icon: Icons.person_add_outlined,
            label: 'Add Employee',
            onTap: () => Get.toNamed(Routes.employeeCreate),
          ),
          _QuickActionButton(
            icon: Icons.add_box_outlined,
            label: 'Add Service',
            onTap: () => Get.toNamed(Routes.serviceForm),
          ),
          _QuickActionButton(
            icon: Icons.settings_outlined,
            label: 'Salon Settings',
            onTap: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
    );
  }
}

class _AppointmentListTile extends StatelessWidget {
  const _AppointmentListTile({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        children: [
          UserAvatar(
            initials: Formatters.getInitials(appointment.clientName),
            size: 40,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: TextStyle(
                    color: theme.colorScheme.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.formatDate(appointment.date)} • ${appointment.timeRange}',
                  style: TextStyle(
                    color: theme.colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: appointment.status, size: StatusBadgeSize.small),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingSm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.mutedForeground,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
