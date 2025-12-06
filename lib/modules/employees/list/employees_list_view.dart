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
import '../../../data/models/employee_model.dart';
import 'employees_list_controller.dart';

/// Employees list view - displays grid of employee cards
class EmployeesListView extends GetView<EmployeesListController> {
  const EmployeesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.employees,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingState(message: 'Loading employees...');
              }

              if (controller.hasError.value) {
                return ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.refresh,
                );
              }

              final employees = controller.filteredEmployees;

              if (employees.isEmpty) {
                return EmptyState(
                  icon: Icons.people,
                  title: 'No employees found',
                  message: controller.employees.isEmpty
                      ? 'Add your first team member to get started'
                      : 'Try adjusting your search',
                  action: controller.employees.isEmpty
                      ? controller.navigateToCreate
                      : controller.clearSearch,
                  actionLabel: controller.employees.isEmpty
                      ? 'Add Employee'
                      : 'Clear Search',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: _buildEmployeesList(context, employees),
              );
            }),
          ),
        ],
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
                    'Employees',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Obx(
                    () => Text(
                      '${controller.activeCount} active of ${controller.totalCount}',
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              ShadButton(
                onPressed: controller.navigateToCreate,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 4),
                    Text('Add Employee'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          SizedBox(
            width: Responsive.isDesktop(context) ? 300 : double.infinity,
            child: ShadInput(
              placeholder: const Text('Search employees...'),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList(
    BuildContext context,
    List<EmployeeModel> employees,
  ) {
    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: ResponsiveGrid(
        mobileColumns: 1,
        tabletColumns: 2,
        desktopColumns: 3,
        children: employees
            .map(
              (employee) => _EmployeeCard(
                employee: employee,
                onTap: () => controller.navigateToDetail(employee.id),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, required this.onTap});

  final EmployeeModel employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: ShadCard(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: employee.avatar,
                initials: employee.initials,
                size: 56,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!employee.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: theme.colorScheme.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      Formatters.capitalize(employee.role),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (employee.email != null) ...[
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employee.email!,
                              style: TextStyle(
                                color: theme.colorScheme.mutedForeground,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
