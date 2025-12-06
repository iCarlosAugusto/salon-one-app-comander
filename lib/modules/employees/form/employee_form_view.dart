import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
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

/// Model for work schedule entry
class WorkScheduleEntry {
  final int dayOfWeek;
  bool isEnabled;
  String startTime;
  String endTime;

  WorkScheduleEntry({
    required this.dayOfWeek,
    this.isEnabled = true,
    this.startTime = '08:00',
    this.endTime = '18:00',
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
  };

  static String getDayName(int dayOfWeek) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayOfWeek];
  }

  static String getShortDayName(int dayOfWeek) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek];
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

  // Work schedule state
  late List<WorkScheduleEntry> _workSchedule;
  bool _showScheduleSection = false;

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

    // Initialize work schedule - default Mon-Sat 08:00-18:00
    _workSchedule = List.generate(
      7,
      (index) => WorkScheduleEntry(
        dayOfWeek: index,
        isEnabled: index != 0, // Sunday off by default
        startTime: '08:00',
        endTime: '18:00',
      ),
    );

    // Show schedule section by default for new employees
    _showScheduleSection = !widget.isEditMode;
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
      // Build work schedule from enabled days
      final workScheduleData = _workSchedule
          .where((entry) => entry.isEnabled)
          .map((entry) => entry.toJson())
          .toList();

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
        'workSchedule': workScheduleData,
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
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              // Main form card
              ShadCard(
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
                            widget.isEditMode
                                ? 'Edit Employee'
                                : 'New Employee',
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
                            onChanged: (value) =>
                                setState(() => _isActive = value),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Work Schedule Section
              ShadCard(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(
                        () => _showScheduleSection = !_showScheduleSection,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.spacingSm),
                              Text(
                                'Work Schedule',
                                style: TextStyle(
                                  color: theme.colorScheme.foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${_workSchedule.where((e) => e.isEnabled).length} days',
                                style: TextStyle(
                                  color: theme.colorScheme.mutedForeground,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showScheduleSection
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_showScheduleSection) ...[
                      const SizedBox(height: AppConstants.spacingMd),
                      const Divider(height: 1),
                      const SizedBox(height: AppConstants.spacingMd),
                      ..._workSchedule.map(
                        (entry) => _ScheduleDayRow(
                          entry: entry,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

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
              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row widget for editing a single day's schedule
class _ScheduleDayRow extends StatelessWidget {
  const _ScheduleDayRow({required this.entry, required this.onChanged});

  final WorkScheduleEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          // Day toggle
          ShadSwitch(
            value: entry.isEnabled,
            onChanged: (value) {
              entry.isEnabled = value;
              onChanged();
            },
          ),
          const SizedBox(width: AppConstants.spacingSm),

          // Day name
          SizedBox(
            width: 80,
            child: Text(
              WorkScheduleEntry.getDayName(entry.dayOfWeek),
              style: TextStyle(
                color: entry.isEnabled
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (entry.isEnabled) ...[
            const SizedBox(width: AppConstants.spacingSm),

            // Start time
            Expanded(
              child: _TimeField(
                value: entry.startTime,
                label: 'Start',
                onChanged: (value) {
                  entry.startTime = value;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),

            Text(
              'to',
              style: TextStyle(color: theme.colorScheme.mutedForeground),
            ),
            const SizedBox(width: AppConstants.spacingSm),

            // End time
            Expanded(
              child: _TimeField(
                value: entry.endTime,
                label: 'End',
                onChanged: (value) {
                  entry.endTime = value;
                  onChanged();
                },
              ),
            ),
          ] else ...[
            const Spacer(),
            Text(
              'Day off',
              style: TextStyle(
                color: theme.colorScheme.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Time input field widget
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final String value;
  final String label;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Parse current time
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final time = TimeOfDay(hour: hour, minute: minute);

    return InkWell(
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: theme.colorScheme.card,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selected != null) {
          final formattedHour = selected.hour.toString().padLeft(2, '0');
          final formattedMinute = selected.minute.toString().padLeft(2, '0');
          onChanged('$formattedHour:$formattedMinute');
        }
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSm,
          vertical: AppConstants.spacingXs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
