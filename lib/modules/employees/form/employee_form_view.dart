import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layouts/admin_layout.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/widgets/page_components.dart';
import 'employee_form_controller.dart';

/// Employee form view - shared for create and edit
class EmployeeFormView extends GetView<EmployeeFormController> {
  const EmployeeFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.employees,
      child: Obx(() {
        // Show loading only in edit mode while fetching employee
        if (controller.isEditMode && controller.isLoading.value) {
          return const LoadingState(message: 'Loading employee...');
        }

        if (controller.hasError.value) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadEmployee,
          );
        }

        return _EmployeeFormContent(
          employee: controller.employee.value,
          isEditMode: controller.isEditMode,
          isSaving: controller.isSaving.value,
          onSave: controller.saveEmployee,
          onCancel: controller.cancel,
        );
      }),
    );
  }
}

class _EmployeeFormContent extends StatefulWidget {
  const _EmployeeFormContent({
    required this.employee,
    required this.isEditMode,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  final dynamic employee;
  final bool isEditMode;
  final bool isSaving;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  @override
  State<_EmployeeFormContent> createState() => _EmployeeFormContentState();
}

class _EmployeeFormContentState extends State<_EmployeeFormContent> {
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
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        widget.isEditMode ? 'Edit Employee' : 'New Employee',
                        style: TextStyle(
                          color: theme.colorScheme.foreground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Name fields
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'First Name *',
                          child: ShadInput(
                            controller: _firstNameController,
                            placeholder: const Text('John'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _FormField(
                          label: 'Last Name *',
                          child: ShadInput(
                            controller: _lastNameController,
                            placeholder: const Text('Doe'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Email
                  _FormField(
                    label: 'Email',
                    child: ShadInput(
                      controller: _emailController,
                      placeholder: const Text('john@example.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Phone
                  _FormField(
                    label: 'Phone',
                    child: ShadInput(
                      controller: _phoneController,
                      placeholder: const Text('(11) 99999-9999'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Role
                  _FormField(
                    label: 'Role *',
                    child: ShadSelect<String>(
                      initialValue: _role,
                      placeholder: const Text('Select role'),
                      options: _roles
                          .map(
                            (role) => ShadOption(
                              value: role,
                              child: Text(
                                role[0].toUpperCase() + role.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _role = value);
                        }
                      },
                      selectedOptionBuilder: (context, value) =>
                          Text(value[0].toUpperCase() + value.substring(1)),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Bio
                  _FormField(
                    label: 'Bio',
                    child: ShadInput(
                      controller: _bioController,
                      placeholder: const Text(
                        'Brief description about the employee...',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Active toggle
                  Row(
                    children: [
                      ShadSwitch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: theme.colorScheme.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: widget.onCancel,
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
                            : Text(
                                widget.isEditMode
                                    ? 'Save Changes'
                                    : 'Create Employee',
                              ),
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

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        child,
      ],
    );
  }
}
