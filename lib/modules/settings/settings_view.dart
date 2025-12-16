import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_theme.dart';
import '../../core/utils/responsive.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../shared/routes/app_routes.dart';
import '../../shared/widgets/page_components.dart';
import '../../data/models/salon_model.dart';
import '../../data/models/operating_hour.dart';
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

        return _ProfileSection(
          salon: controller.salon.value!,
          onSave: controller.updateProfile,
          isSaving: controller.isSaving.value,
        );
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

  // Operating hours state
  late List<OperatingHour> _operatingHours;

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

    // Initialize operating hours from salon or use defaults
    _operatingHours = widget.salon.operatingHours.isNotEmpty
        ? List.from(widget.salon.operatingHours)
        : OperatingHour.defaultHours();
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

  void _updateOperatingHour(int index, OperatingHour hour) {
    setState(() {
      _operatingHours[index] = hour;
    });
  }

  void _handleSave() {
    // Filter only open days and convert to API format
    final operatingHoursData = _operatingHours
        .where((h) => h.isOpen)
        .map((h) => h.toJson())
        .toList();

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
      'operatingHours': operatingHoursData,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Responsive.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Barbershop Settings', style: context.appTextTheme.pageTitle),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            'Manage your barbershop settings',
            style: context.appTextTheme.cardSubtitle,
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Profile form
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Business Profile Card
                  ShadCard(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Profile',
                          style: context.appTextTheme.sectionTitle,
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
                          style: context.appTextTheme.sectionTitle,
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
                          style: context.appTextTheme.sectionTitle,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingLg),

                  // Operating Hours Card
                  ShadCard(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operating Hours',
                          style: context.appTextTheme.sectionTitle,
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          'Set your business hours for each day of the week',
                          style: context.appTextTheme.helper,
                        ),
                        const SizedBox(height: AppConstants.spacingLg),

                        // Operating hours list
                        ...List.generate(7, (index) {
                          final hour = _operatingHours.firstWhere(
                            (h) => h.dayOfWeek == index,
                            orElse: () => OperatingHour(
                              dayOfWeek: index,
                              startTime: '08:00',
                              endTime: '18:00',
                              isOpen: false,
                            ),
                          );
                          final hourIndex = _operatingHours.indexWhere(
                            (h) => h.dayOfWeek == index,
                          );

                          return _OperatingHourRow(
                            hour: hour,
                            onChanged: (updated) {
                              if (hourIndex >= 0) {
                                _updateOperatingHour(hourIndex, updated);
                              }
                            },
                          );
                        }),
                      ],
                    ),
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

                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row for editing a single day's operating hours
class _OperatingHourRow extends StatelessWidget {
  const _OperatingHourRow({required this.hour, required this.onChanged});

  final OperatingHour hour;
  final ValueChanged<OperatingHour> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        children: [
          // Day toggle
          SizedBox(
            width: 44,
            child: ShadSwitch(
              value: hour.isOpen,
              onChanged: (value) {
                onChanged(hour.copyWith(isOpen: value));
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),

          // Day name
          SizedBox(
            width: 100,
            child: Text(
              hour.dayName,
              style: TextStyle(
                color: hour.isOpen
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
                fontWeight: hour.isOpen ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),

          // Time pickers (only shown if open)
          if (hour.isOpen) ...[
            const SizedBox(width: AppConstants.spacingMd),
            _TimeDropdown(
              value: hour.startTime,
              onChanged: (value) {
                onChanged(hour.copyWith(startTime: value));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
              ),
              child: Text(
                'to',
                style: TextStyle(color: theme.colorScheme.mutedForeground),
              ),
            ),
            _TimeDropdown(
              value: hour.endTime,
              onChanged: (value) {
                onChanged(hour.copyWith(endTime: value));
              },
            ),
          ] else ...[
            const SizedBox(width: AppConstants.spacingMd),
            Text(
              'Closed',
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

/// Time dropdown selector
class _TimeDropdown extends StatelessWidget {
  const _TimeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const List<String> _times = [
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>(
      placeholder: const Text('Select time'),
      selectedOptionBuilder: (context, value) => Text(value),
      options: _times.map((time) {
        return ShadOption(value: time, child: Text(time));
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      initialValue: value,
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
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final int? maxLines;
  final TextInputType? keyboardType;

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
      ],
    );
  }
}
