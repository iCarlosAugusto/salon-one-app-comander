import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/page_components.dart';
import '../../data/models/salon_model.dart';
import 'settings_controller.dart';

/// Settings view with profile and booking configuration
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: Routes.settings,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'Loading settings...');
        }

        if (controller.hasError.value) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        // Show appropriate section
        switch (controller.currentSection.value) {
          case SettingsSection.profile:
            return _ProfileSection(
              salon: controller.salon.value!,
              onSave: controller.updateProfile,
              isSaving: controller.isSaving.value,
            );
          case SettingsSection.booking:
            return _BookingSettingsSection(
              salon: controller.salon.value!,
              onSave: controller.updateBookingSettings,
              isSaving: controller.isSaving.value,
              onBack: controller.goBack,
            );
        }
      }),
    );
  }
}

class _ProfileSection extends StatefulWidget {
  const _ProfileSection({
    required this.salon,
    required this.onSave,
    required this.isSaving,
  });

  final SalonModel salon;
  final Function(Map<String, dynamic>) onSave;
  final bool isSaving;

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.salon.name);
    _slugController = TextEditingController(text: widget.salon.slug);
    _descriptionController = TextEditingController(
      text: widget.salon.description ?? '',
    );
    _emailController = TextEditingController(text: widget.salon.email ?? '');
    _phoneController = TextEditingController(text: widget.salon.phone ?? '');
    _addressController = TextEditingController(
      text: widget.salon.address ?? '',
    );
    _cityController = TextEditingController(text: widget.salon.city ?? '');
    _stateController = TextEditingController(text: widget.salon.state ?? '');
    _zipCodeController = TextEditingController(
      text: widget.salon.zipCode ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.salon.website ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave({
      'name': _nameController.text.trim(),
      'slug': _slugController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'city': _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      'state': _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      'zipCode': _zipCodeController.text.trim().isEmpty
          ? null
          : _zipCodeController.text.trim(),
      'website': _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final controller = Get.find<SettingsController>();

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: theme.colorScheme.foreground,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            'Manage your barbershop settings',
            style: TextStyle(color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Quick access cards
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 2,
            children: [
              _SettingsCard(
                icon: Icons.store,
                title: 'Business Profile',
                description: 'Update your shop name, contact info, and address',
                isActive: true,
              ),
              _SettingsCard(
                icon: Icons.calendar_month,
                title: 'Booking Settings',
                description: 'Configure online booking options',
                onTap: () => controller.goToSection(SettingsSection.booking),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Profile form
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ShadCard(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Profile',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Basic info
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Business Name',
                            controller: _nameController,
                            placeholder: 'Your Barbershop',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _FormField(
                            label: 'URL Slug',
                            controller: _slugController,
                            placeholder: 'your-barbershop',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _FormField(
                      label: 'Description',
                      controller: _descriptionController,
                      placeholder: 'Tell customers about your business...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Contact info
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Email',
                            controller: _emailController,
                            placeholder: 'contact@yourbarbershop.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _FormField(
                            label: 'Phone',
                            controller: _phoneController,
                            placeholder: '(00) 00000-0000',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _FormField(
                      label: 'Website',
                      controller: _websiteController,
                      placeholder: 'https://yourbarbershop.com',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Address
                    Text(
                      'Address',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _FormField(
                      label: 'Street Address',
                      controller: _addressController,
                      placeholder: '123 Main Street',
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _FormField(
                            label: 'City',
                            controller: _cityController,
                            placeholder: 'City',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _FormField(
                            label: 'State',
                            controller: _stateController,
                            placeholder: 'State',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _FormField(
                            label: 'ZIP Code',
                            controller: _zipCodeController,
                            placeholder: '00000-000',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Save button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                              : const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSettingsSection extends StatefulWidget {
  const _BookingSettingsSection({
    required this.salon,
    required this.onSave,
    required this.isSaving,
    required this.onBack,
  });

  final SalonModel salon;
  final Function(Map<String, dynamic>) onSave;
  final bool isSaving;
  final VoidCallback onBack;

  @override
  State<_BookingSettingsSection> createState() =>
      _BookingSettingsSectionState();
}

class _BookingSettingsSectionState extends State<_BookingSettingsSection> {
  late bool _allowOnlineBooking;
  late bool _requireBookingApproval;
  late final TextEditingController _slotIntervalController;
  late final TextEditingController _maxAdvanceDaysController;
  late final TextEditingController _minAdvanceHoursController;

  @override
  void initState() {
    super.initState();
    _allowOnlineBooking = widget.salon.allowOnlineBooking;
    _requireBookingApproval = widget.salon.requireBookingApproval;
    _slotIntervalController = TextEditingController(
      text: widget.salon.defaultSlotInterval.toString(),
    );
    _maxAdvanceDaysController = TextEditingController(
      text: widget.salon.maxAdvanceBookingDays.toString(),
    );
    _minAdvanceHoursController = TextEditingController(
      text: widget.salon.minAdvanceBookingHours.toString(),
    );
  }

  @override
  void dispose() {
    _slotIntervalController.dispose();
    _maxAdvanceDaysController.dispose();
    _minAdvanceHoursController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave({
      'allowOnlineBooking': _allowOnlineBooking,
      'requireBookingApproval': _requireBookingApproval,
      'defaultSlotInterval': int.tryParse(_slotIntervalController.text) ?? 10,
      'maxAdvanceBookingDays':
          int.tryParse(_maxAdvanceDaysController.text) ?? 90,
      'minAdvanceBookingHours':
          int.tryParse(_minAdvanceHoursController.text) ?? 2,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    'Booking Settings',
                    style: TextStyle(
                      color: theme.colorScheme.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              ShadCard(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Online Booking',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _ToggleSetting(
                      title: 'Allow Online Booking',
                      description: 'Let customers book appointments online',
                      value: _allowOnlineBooking,
                      onChanged: (value) =>
                          setState(() => _allowOnlineBooking = value),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _ToggleSetting(
                      title: 'Require Approval',
                      description: 'Manually approve each booking request',
                      value: _requireBookingApproval,
                      onChanged: (value) =>
                          setState(() => _requireBookingApproval = value),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacingLg),
                    Text(
                      'Time Settings',
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _FormField(
                      label: 'Time Slot Interval (minutes)',
                      controller: _slotIntervalController,
                      placeholder: '10',
                      keyboardType: TextInputType.number,
                      helperText: 'How often to show available time slots',
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Max Advance Days',
                            controller: _maxAdvanceDaysController,
                            placeholder: '90',
                            keyboardType: TextInputType.number,
                            helperText: 'How far ahead customers can book',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: _FormField(
                            label: 'Min Advance Hours',
                            controller: _minAdvanceHoursController,
                            placeholder: '2',
                            keyboardType: TextInputType.number,
                            helperText: 'Minimum notice required',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton.outline(
                          onPressed: widget.onBack,
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
                              : const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isActive;

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
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? AppColors.primary
                      : theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.placeholder,
    this.maxLines,
    this.keyboardType,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? helperText;

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
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        ShadInput(
          controller: controller,
          placeholder: placeholder != null ? Text(placeholder!) : null,
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            helperText!,
            style: TextStyle(
              color: theme.colorScheme.mutedForeground,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  const _ToggleSetting({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ShadSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
