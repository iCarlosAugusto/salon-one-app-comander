import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_one_comander/shared/widgets/generic_list_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layouts/admin_layout.dart';
import '../../../shared/routes/app_routes.dart';
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
              final employees = controller.filteredEmployees;

              return GenericListView(
                onRefresh: controller.refresh,
                onRetry: controller.refresh,
                emptyTitle: 'Você não tem funcionários cadastrados.',
                emptyMessage: "Cadastre agora!",
                emptyAction: controller.navigateToCreate,
                items: employees,
                itemBuilder: (_, _, index) => _NewEmployeeCard(
                  employee: employees[index],
                  onTap: () => controller.navigateToDetail(employees[index].id),
                ),
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
}

class _NewEmployeeCard extends StatelessWidget {
  const _NewEmployeeCard({required this.employee, required this.onTap});

  final EmployeeModel employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ShadTheme.of(context).colorScheme.border),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: ListTile(
        leading: UserAvatar(
          imageUrl: employee.avatar,
          initials: employee.initials,
          size: 40,
        ),
        title: Text(employee.fullName),
        subtitle: Text(employee.role),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
