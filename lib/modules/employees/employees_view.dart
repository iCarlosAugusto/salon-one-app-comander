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
import '../../shared/widgets/common_widgets.dart';
import '../../data/models/employee_model.dart';
import 'employees_controller.dart';

/// Employees list view
class EmployeesView extends GetView<EmployeesController> {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.employees,
      child: Obx(() {
        // Show form when in form mode
        if (controller.isFormMode.value) {
          return _EmployeeFormView(
            employee: controller.editingEmployee.value,
            onSave: (data) async {
              bool success;
              if (controller.editingEmployee.value != null) {
                success = await controller.updateEmployee(
                  controller.editingEmployee.value!.id,
                  data,
                );
              } else {
                success = await controller.createEmployee(data);
              }
              if (success) {
                controller.cancelForm();
              }
            },
            onCancel: controller.cancelForm,
            isSaving: controller.isSaving.value,
          );
        }

        // Show detail view when employee is selected
        if (controller.selectedEmployee.value != null) {
          return _EmployeeDetailView(
            employee: controller.selectedEmployee.value!,
            schedules: controller.employeeSchedules,
            services: controller.employeeServices,
            onBack: controller.clearSelection,
            onEdit: () =>
                controller.editEmployee(controller.selectedEmployee.value!),
            onDelete: () =>
                _showDeleteDialog(context, controller.selectedEmployee.value!),
          );
        }

        return Column(
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
                        ? controller.createNewEmployee
                        : () => controller.searchQuery.value = '',
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
        );
      }),
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
                onPressed: controller.createNewEmployee,
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
              // prefix: const Padding(
              //   padding: EdgeInsets.only(left: 8),
              //   child: Icon(Icons.search, size: 18),
              // ),
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
                onTap: () => controller.selectEmployee(employee),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, EmployeeModel employee) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Employee',
      message:
          'Are you sure you want to delete "${employee.fullName}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteEmployee(employee.id);
    }
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

class _EmployeeDetailView extends StatelessWidget {
  const _EmployeeDetailView({
    required this.employee,
    required this.schedules,
    required this.services,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final EmployeeModel employee;
  final List schedules;
  final List services;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
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
                onPressed: onEdit,
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
          Center(
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
                    if (schedules.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          child: Text(
                            'No schedule configured',
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    else
                      ...schedules.map(
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
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Services section
          Center(
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
                    if (services.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          child: Text(
                            'No services assigned',
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppConstants.spacingSm,
                        runSpacing: AppConstants.spacingSm,
                        children: services
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
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Delete button
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ShadButton.destructive(
                onPressed: onDelete,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Delete Employee'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
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

class _EmployeeFormView extends StatefulWidget {
  const _EmployeeFormView({
    required this.employee,
    required this.onSave,
    required this.onCancel,
    required this.isSaving,
  });

  final EmployeeModel? employee;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  @override
  State<_EmployeeFormView> createState() => _EmployeeFormViewState();
}

class _EmployeeFormViewState extends State<_EmployeeFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late String _role;
  late bool _isActive;

  final _roles = ['barber', 'stylist', 'manager', 'receptionist'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.employee?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.employee?.lastName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.employee?.phone ?? '',
    );
    _bioController = TextEditingController(text: widget.employee?.bio ?? '');
    _role = widget.employee?.role ?? 'barber';
    _isActive = widget.employee?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'role': _role,
        'isActive': _isActive,
        'hiredAt':
            widget.employee?.hiredAt ??
            DateTime.now().toIso8601String().split('T')[0],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isEdit = widget.employee != null;

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ShadCard(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        isEdit ? 'Edit Employee' : 'New Employee',
                        style: TextStyle(
                          color: theme.colorScheme.foreground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Name *',
                              style: TextStyle(
                                color: theme.colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            ShadInput(
                              controller: _firstNameController,
                              placeholder: const Text('John'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Name *',
                              style: TextStyle(
                                color: theme.colorScheme.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            ShadInput(
                              controller: _lastNameController,
                              placeholder: const Text('Doe'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Email',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _emailController,
                    placeholder: const Text('john@example.com'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Phone',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _phoneController,
                    placeholder: const Text('(00) 00000-0000'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Role *',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadSelect<String>(
                    initialValue: _role,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _role = value);
                      }
                    },
                    options: _roles
                        .map(
                          (role) => ShadOption(
                            value: role,
                            child: Text(Formatters.capitalize(role)),
                          ),
                        )
                        .toList(),
                    selectedOptionBuilder: (context, value) =>
                        Text(Formatters.capitalize(value)),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Bio',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ShadInput(
                    controller: _bioController,
                    placeholder: const Text('Brief description...'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    children: [
                      ShadSwitch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Active',
                        style: TextStyle(color: theme.colorScheme.foreground),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: widget.isSaving ? null : widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      ShadButton(
                        onPressed: widget.isSaving ? null : _handleSave,
                        child: widget.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEdit ? 'Save Changes' : 'Create Employee'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
